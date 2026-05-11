/* eslint-disable @typescript-eslint/no-explicit-any */
import { useState, useRef, useCallback, useEffect } from 'react';
import { supabase } from '@/integrations/supabase/client';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Card, CardContent } from '@/components/ui/card';
import { Progress } from '@/components/ui/progress';
import {
  Mic,
  Upload,
  Square,
  AlertCircle,
  CheckCircle2,
  Brain,
} from 'lucide-react';
import { toast } from 'sonner';
import type { CotObservation, NeoResults } from '@/types/observation';

interface Props {
  observation: CotObservation;
  onSaved: (obs: CotObservation) => void;
}

type NeoPhase = 'idle' | 'recording' | 'uploading' | 'processing' | 'completed' | 'failed';
type Language = 'en' | 'ur';

const translations: Record<Language, Record<string, string>> = {
  en: {
    'Coach Debrief': 'Coach Debrief',
    'Record your verbal feedback': 'Record your verbal feedback with the teacher. Neo will analyze your coaching communication quality.',
    'Record': 'Record',
    'Upload Audio': 'Upload Audio',
    'Recording': 'Recording',
    'Stop & Upload': 'Stop & Upload',
    'Uploading audio': 'Uploading audio...',
    'Neo is analyzing': 'Neo is analyzing your debrief (max ~2 minutes)...',
    'Debrief Analysis Complete': 'Debrief Analysis Complete',
    'Overall Score': 'Overall Score',
    'Section Scores': 'Section Scores',
    'Section': 'Section',
    'Detailed Feedback': 'Detailed Feedback',
    'Strengths': '✓ Strengths',
    'Next Steps for Growth': '→ Next Steps for Growth',
    'Analysis Failed': 'Analysis Failed',
    'Try Again': 'Try Again',
  },
  ur: {
    'Coach Debrief': 'کوچ کا جائزہ',
    'Record your verbal feedback': 'اپنی شفاہی تنقید ریکارڈ کریں۔ Neo آپ کی کوچنگ کی معیار کا تجزیہ کرے گا۔',
    'Record': 'ریکارڈ کریں',
    'Upload Audio': 'آڈیو اپ لوڈ کریں',
    'Recording': 'ریکارڈنگ',
    'Stop & Upload': 'روکیں اور اپ لوڈ کریں',
    'Uploading audio': 'آڈیو اپ لوڈ کیا جا رہا ہے...',
    'Neo is analyzing': 'Neo آپ کے جائزے کا تجزیہ کر رہا ہے (زیادہ سے زیادہ 2 منٹ)...',
    'Debrief Analysis Complete': 'جائزہ کا تجزیہ مکمل ہو گیا',
    'Overall Score': 'کل اسکور',
    'Section Scores': 'سیکشن کے اسکور',
    'Section': 'سیکشن',
    'Detailed Feedback': 'تفصیلی تنقید',
    'Strengths': '✓ طاقتیں',
    'Next Steps for Growth': '→ ترقی کے اگلے قدم',
    'Analysis Failed': 'تجزیہ ناکام',
    'Try Again': 'دوبارہ کوشش کریں',
  },
};

export function NeoAnalysis({ observation, onSaved }: Props) {
  const [phase, setPhase] = useState<NeoPhase>('idle');
  const [language, setLanguage] = useState<Language>('en');
  const t = (key: string) => translations[language][key] || key;
  const [recordingTime, setRecordingTime] = useState(0);
  const [uploadProgress, setUploadProgress] = useState(0);
  const [pollProgress, setPollProgress] = useState(0);
  const [error, setError] = useState<string | null>(null);
  const mediaRecorderRef = useRef<MediaRecorder | null>(null);
  const audioChunksRef = useRef<Blob[]>([]);
  const recordingIntervalRef = useRef<number | null>(null);
  const pollIntervalRef = useRef<number | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  // Update from observation real-time
  useEffect(() => {
    if (observation.neo_status === 'completed') {
      setPhase('completed');
    } else if (observation.neo_status === 'failed') {
      setPhase('failed');
      setError(observation.neo_error || 'Neo processing failed');
    } else if (observation.neo_status === 'processing') {
      setPhase('processing');
    }
  }, [observation.neo_status, observation.neo_error]);

  const startRecording = async () => {
    try {
      console.log('Starting recording - requesting microphone access...');
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      console.log('Microphone access granted. Stream:', stream);

      const mediaRecorder = new MediaRecorder(stream);
      mediaRecorderRef.current = mediaRecorder;
      audioChunksRef.current = [];
      console.log('MediaRecorder created');

      mediaRecorder.ondataavailable = (event) => {
        console.log(`dataavailable event fired: ${event.data.size} bytes`);
        if (event.data.size > 0) {
          audioChunksRef.current.push(event.data);
          console.log(`Audio chunk captured: ${event.data.size} bytes, total chunks: ${audioChunksRef.current.length}`);
        } else {
          console.log('dataavailable event had 0 bytes');
        }
      };

      mediaRecorder.onstart = () => {
        console.log('Recording started');
        setPhase('recording');
        setRecordingTime(0);
        recordingIntervalRef.current = window.setInterval(() => {
          setRecordingTime((t) => t + 1);
        }, 1000);
      };

      mediaRecorder.onstop = () => {
        console.log(`Recording stopped. Total chunks collected: ${audioChunksRef.current.length}`);
        if (recordingIntervalRef.current) {
          clearInterval(recordingIntervalRef.current);
        }
        // Stop tracks after a small delay to ensure final dataavailable event is processed
        setTimeout(() => {
          stream.getTracks().forEach((track) => {
            console.log(`Stopping audio track: ${track.kind}`);
            track.stop();
          });
        }, 100);
      };

      console.log('Calling mediaRecorder.start(1000)...');
      mediaRecorder.start(1000); // Collect data every 1 second
    } catch (err) {
      console.error('Microphone error:', err);
      toast.error('Could not access microphone');
      setError(err instanceof Error ? err.message : 'Microphone access denied');
    }
  };

  const stopRecording = () => {
    if (mediaRecorderRef.current && phase === 'recording') {
      console.log('Stopping recording...');
      mediaRecorderRef.current.stop();

      // Wait a moment for the final dataavailable event to be processed
      setTimeout(() => {
        console.log(`Stop recording confirmed. Chunks: ${audioChunksRef.current.length}`);
        if (audioChunksRef.current.length === 0) {
          console.error('No audio chunks recorded!');
          toast.error('No audio recorded. Please try again.');
          setPhase('idle');
          return;
        }

        console.log(`Uploading ${audioChunksRef.current.length} chunks`);
        setPhase('uploading');
        const audioBlob = new Blob(audioChunksRef.current, { type: 'audio/webm' });
        console.log(`Blob created: ${audioBlob.size} bytes`);
        // Create a File with .webm extension so Neo API recognizes it
        const audioFile = new File([audioBlob], `coaching-recording-${Date.now()}.webm`, { type: 'audio/webm' });
        uploadAudio(audioFile, 'audio/webm');
      }, 200);
    }
  };

  const handleFileUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    const mimeType = file.type || 'audio/webm';
    setPhase('uploading');
    uploadAudio(file, mimeType);
  };

  const uploadAudio = async (blob: Blob, mimeType: string) => {
    try {
      console.log('uploadAudio called with blob size:', blob.size, 'mimeType:', mimeType);
      console.log('observation.id:', observation.id);

      const formData = new FormData();
      formData.append('file', blob);
      formData.append('observation_id', observation.id);

      console.log('FormData created. Checking token...');
      const token = (await supabase.auth.getSession()).data.session?.access_token;
      if (!token) {
        toast.error('Not authenticated');
        setPhase('idle');
        return;
      }

      const uploadUrl = `${import.meta.env.VITE_SUPABASE_URL}/functions/v1/neo-start`;
      console.log('Sending POST to:', uploadUrl);
      console.log('Authorization header present:', !!token);

      const response = await fetch(uploadUrl, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${token}`,
        },
        body: formData,
      });

      console.log('Upload response received');
      console.log('Response status:', response.status, response.statusText);

      if (!response.ok) {
        console.error('Upload response NOT OK');
        console.error('Blob size:', blob.size);
        const err = await response.json().catch(() => ({}));
        console.error('Error from server:', err);
        throw new Error(err.error || `Upload failed: ${response.status}`);
      }

      const data = await response.json();
      setPhase('processing');
      setPollProgress(0);
      setError(null);

      // Start polling
      pollNeoStatus();
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Upload failed';
      toast.error(message);
      setError(message);
      setPhase('idle');
    }
  };

  const pollNeoStatus = async () => {
    const token = (await supabase.auth.getSession()).data.session?.access_token;
    if (!token) return;

    let pollCount = 0;
    const maxPolls = 15; // ~120 seconds

    pollIntervalRef.current = window.setInterval(async () => {
      pollCount++;
      setPollProgress(Math.min((pollCount / maxPolls) * 100, 90));

      try {
        const response = await fetch(
          `${import.meta.env.VITE_SUPABASE_URL}/functions/v1/neo-status`,
          {
            method: 'POST',
            headers: {
              Authorization: `Bearer ${token}`,
              'Content-Type': 'application/json',
            },
            body: JSON.stringify({ observation_id: observation.id }),
          }
        );

        if (!response.ok) {
          const err = await response.json();
          throw new Error(err.error || 'Status check failed');
        }

        const data = await response.json();
        console.log(`Poll #${pollCount}: status=${data.status}`, data);

        if (data.status === 'completed') {
          console.log('Neo processing completed!');
          if (pollIntervalRef.current) {
            clearInterval(pollIntervalRef.current);
          }
          setPollProgress(100);
          setPhase('completed');
          toast.success('Debrief analysis complete!');
          // Refresh observation data
          // eslint-disable-next-line @typescript-eslint/no-explicit-any
          const { data: updated } = await (supabase as any)
            .from('cot_observations')
            .select('*')
            .eq('id', observation.id)
            .single();
          if (updated) {
            onSaved(updated as CotObservation);
          }
        } else if (data.status === 'failed') {
          console.error('Neo processing FAILED:', data.error);
          if (pollIntervalRef.current) {
            clearInterval(pollIntervalRef.current);
          }
          setError(data.error || 'Neo processing failed');
          setPhase('failed');
          toast.error('Debrief analysis failed');
        }
      } catch (err) {
        console.error('Poll error:', err);
        if (pollCount >= maxPolls) {
          if (pollIntervalRef.current) {
            clearInterval(pollIntervalRef.current);
          }
          setError('Polling timeout');
          setPhase('failed');
        }
      }
    }, 8000);
  };

  const retry = () => {
    setPhase('idle');
    setError(null);
    setRecordingTime(0);
    setUploadProgress(0);
    setPollProgress(0);
    audioChunksRef.current = [];
  };

  // Idle phase
  if (phase === 'idle') {
    return (
      <div className="space-y-3">
        <div className="flex items-start justify-between">
          <div className="flex-1">
            <h3 className="font-semibold text-foreground flex items-center gap-2">
              <Brain className="w-4 h-4" /> {t('Coach Debrief')}
            </h3>
            <p className="text-xs text-muted-foreground mt-1">
              {t('Record your verbal feedback')}
            </p>
          </div>
          <div className="flex gap-1 shrink-0">
            <Button
              variant={language === 'en' ? 'default' : 'outline'}
              size="sm"
              className="text-xs h-7 px-2"
              onClick={() => setLanguage('en')}
            >
              EN
            </Button>
            <Button
              variant={language === 'ur' ? 'default' : 'outline'}
              size="sm"
              className="text-xs h-7 px-2"
              onClick={() => setLanguage('ur')}
            >
              اردو
            </Button>
          </div>
        </div>
        <div className="flex gap-2">
          <Button onClick={startRecording} className="gap-2">
            <Mic className="w-4 h-4" /> {t('Record')}
          </Button>
          <Button variant="outline" onClick={() => fileInputRef.current?.click()} className="gap-2">
            <Upload className="w-4 h-4" /> {t('Upload Audio')}
          </Button>
        </div>
        <input
          ref={fileInputRef}
          type="file"
          accept="audio/*"
          className="hidden"
          onChange={handleFileUpload}
        />
      </div>
    );
  }

  // Recording phase
  if (phase === 'recording') {
    const mins = Math.floor(recordingTime / 60);
    const secs = recordingTime % 60;
    return (
      <div className="space-y-3">
        <div className="flex items-center gap-2 text-sm text-foreground">
          <div className="w-2 h-2 bg-red-500 rounded-full animate-pulse" />
          {t('Recording')} — {mins}:{secs.toString().padStart(2, '0')}
        </div>
        <Button onClick={stopRecording} variant="destructive" className="w-full gap-2">
          <Square className="w-4 h-4" /> {t('Stop & Upload')}
        </Button>
      </div>
    );
  }

  // Uploading phase
  if (phase === 'uploading') {
    return (
      <div className="space-y-2">
        <p className="text-xs text-muted-foreground">{t('Uploading audio')}</p>
        <Progress value={uploadProgress} className="h-2" />
      </div>
    );
  }

  // Processing phase
  if (phase === 'processing') {
    return (
      <div className="space-y-2">
        <p className="text-xs text-muted-foreground">{t('Neo is analyzing')}</p>
        <Progress value={pollProgress} className="h-2" />
      </div>
    );
  }

  // Completed phase
  if (phase === 'completed' && observation.neo_results) {
    const results = observation.neo_results as NeoResults;
    const gradeColor = {
      A: 'text-emerald-700 bg-emerald-50 border-emerald-200',
      B: 'text-blue-700 bg-blue-50 border-blue-200',
      C: 'text-amber-700 bg-amber-50 border-amber-200',
      D: 'text-orange-700 bg-orange-50 border-orange-200',
      F: 'text-red-700 bg-red-50 border-red-200',
    };

    const color = gradeColor[results.grade] || gradeColor.C;

    return (
      <div className="space-y-3">
        <div>
          <h3 className="font-semibold text-foreground flex items-center gap-2">
            <CheckCircle2 className="w-4 h-4 text-green-600" /> {t('Debrief Analysis Complete')}
          </h3>
          <p className="text-xs text-muted-foreground mt-1 line-clamp-2">{results.readiness_level}</p>
        </div>

        <Card className="bg-muted/40 border-0">
          <CardContent className="p-3">
            <div className="grid grid-cols-2 gap-3">
              <div>
                <p className="text-xs text-muted-foreground">{t('Overall Score')}</p>
                <p className="text-2xl font-bold text-foreground">{results.overall_score}</p>
              </div>
              <div className="flex items-end justify-end">
                <Badge className={`text-lg font-bold py-1 px-3 border ${color}`}>
                  {results.grade}
                </Badge>
              </div>
            </div>
          </CardContent>
        </Card>

        {Object.values(results.section_scores).some(s => s !== 0) && (
          <div className="space-y-2">
            <p className="text-xs font-semibold text-foreground">{t('Section Scores')}</p>
            <div className="grid grid-cols-5 gap-2">
              {['A', 'B', 'C', 'D', 'E'].map((section) => (
                <div key={section} className="text-center">
                  <div className="text-xs text-muted-foreground mb-1">{t('Section')} {section}</div>
                  <div className="bg-muted rounded px-2 py-1 text-sm font-semibold text-foreground">
                    {results.section_scores[section as keyof typeof results.section_scores] || 0}
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {results.observer_feedback && (
          <div className="space-y-3">
            <p className="text-xs font-semibold text-foreground">{t('Detailed Feedback')}</p>

            {typeof results.observer_feedback === 'object' && results.observer_feedback !== null && (
              <>
                {(results.observer_feedback as any).strengths && (
                  <div className="space-y-1">
                    <p className="text-xs font-medium text-green-700 text-opacity-80">{t('Strengths')}</p>
                    <div className="space-y-1 text-xs text-foreground">
                      {((results.observer_feedback as any).strengths || []).map((strength: string, idx: number) => (
                        <div key={idx} className="bg-green-50 border border-green-200 rounded p-2 text-green-900">
                          {strength}
                        </div>
                      ))}
                    </div>
                  </div>
                )}

                {(results.observer_feedback as any).next_steps && (
                  <div className="space-y-2">
                    <p className="text-xs font-medium text-blue-700">{t('Next Steps for Growth')}</p>
                    <div className="space-y-1 text-xs text-foreground">
                      {((results.observer_feedback as any).next_steps || []).map((step: any, idx: number) => (
                        <div key={idx} className="bg-blue-50 border border-blue-200 rounded p-2 text-blue-900">
                          <p className="font-medium">{step.growth_area}</p>
                          <p className="text-xs mt-1">{step.specific_behavior}</p>
                        </div>
                      ))}
                    </div>
                  </div>
                )}
              </>
            )}

            {typeof results.observer_feedback === 'string' && (
              <div className="bg-muted/30 rounded p-3 text-xs text-foreground">
                {results.observer_feedback}
              </div>
            )}
          </div>
        )}
      </div>
    );
  }

  // Failed phase
  if (phase === 'failed') {
    return (
      <div className="space-y-3">
        <div className="flex items-start gap-2">
          <AlertCircle className="w-5 h-5 text-red-600 shrink-0 mt-0.5" />
          <div>
            <p className="font-semibold text-red-700">{t('Analysis Failed')}</p>
            <p className="text-xs text-red-600 mt-1">{error}</p>
          </div>
        </div>
        <Button onClick={retry} variant="outline" className="w-full">
          {t('Try Again')}
        </Button>
      </div>
    );
  }

  return null;
}
