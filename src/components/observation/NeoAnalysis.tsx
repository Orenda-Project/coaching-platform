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

export function NeoAnalysis({ observation, onSaved }: Props) {
  const [phase, setPhase] = useState<NeoPhase>('idle');
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
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      const mediaRecorder = new MediaRecorder(stream);
      mediaRecorderRef.current = mediaRecorder;
      audioChunksRef.current = [];

      mediaRecorder.ondataavailable = (event) => {
        if (event.data.size > 0) {
          audioChunksRef.current.push(event.data);
        }
      };

      mediaRecorder.onstart = () => {
        setPhase('recording');
        setRecordingTime(0);
        recordingIntervalRef.current = window.setInterval(() => {
          setRecordingTime((t) => t + 1);
        }, 1000);
      };

      mediaRecorder.onstop = () => {
        if (recordingIntervalRef.current) {
          clearInterval(recordingIntervalRef.current);
        }
      };

      mediaRecorder.start();
    } catch (err) {
      toast.error('Could not access microphone');
      setError('Microphone access denied');
    }
  };

  const stopRecording = () => {
    if (mediaRecorderRef.current && phase === 'recording') {
      mediaRecorderRef.current.stop();
      const stream = mediaRecorderRef.current.stream;
      stream.getTracks().forEach((track) => track.stop());
      setPhase('uploading');
      const audioBlob = new Blob(audioChunksRef.current, { type: 'audio/webm' });
      uploadAudio(audioBlob, 'audio/webm');
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
      const formData = new FormData();
      formData.append('file', blob);
      formData.append('observation_id', observation.id);

      const token = (await supabase.auth.getSession()).data.session?.access_token;
      if (!token) {
        toast.error('Not authenticated');
        setPhase('idle');
        return;
      }

      const response = await fetch(
        `${import.meta.env.VITE_SUPABASE_URL}/functions/v1/neo-start`,
        {
          method: 'POST',
          headers: {
            Authorization: `Bearer ${token}`,
          },
          body: formData,
        }
      );

      if (!response.ok) {
        const err = await response.json();
        throw new Error(err.error || 'Upload failed');
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

        if (data.status === 'completed') {
          if (pollIntervalRef.current) {
            clearInterval(pollIntervalRef.current);
          }
          setPollProgress(100);
          setPhase('completed');
          toast.success('Debrief analysis complete!');
          // Refresh observation data
          const { data: updated } = await supabase
            .from('cot_observations')
            .select('*')
            .eq('id', observation.id)
            .single();
          if (updated) {
            onSaved(updated as CotObservation);
          }
        } else if (data.status === 'failed') {
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
        <div>
          <h3 className="font-semibold text-foreground flex items-center gap-2">
            <Brain className="w-4 h-4" /> Coach Debrief
          </h3>
          <p className="text-xs text-muted-foreground mt-1">
            Record your verbal feedback with the teacher. Neo will analyze your coaching communication quality.
          </p>
        </div>
        <div className="flex gap-2">
          <Button onClick={startRecording} className="gap-2">
            <Mic className="w-4 h-4" /> Record
          </Button>
          <Button variant="outline" onClick={() => fileInputRef.current?.click()} className="gap-2">
            <Upload className="w-4 h-4" /> Upload Audio
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
          Recording — {mins}:{secs.toString().padStart(2, '0')}
        </div>
        <Button onClick={stopRecording} variant="destructive" className="w-full gap-2">
          <Square className="w-4 h-4" /> Stop & Upload
        </Button>
      </div>
    );
  }

  // Uploading phase
  if (phase === 'uploading') {
    return (
      <div className="space-y-2">
        <p className="text-xs text-muted-foreground">Uploading audio...</p>
        <Progress value={uploadProgress} className="h-2" />
      </div>
    );
  }

  // Processing phase
  if (phase === 'processing') {
    return (
      <div className="space-y-2">
        <p className="text-xs text-muted-foreground">Neo is analyzing your debrief (max ~2 minutes)...</p>
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
        <div className="flex items-start justify-between">
          <div>
            <h3 className="font-semibold text-foreground flex items-center gap-2">
              <CheckCircle2 className="w-4 h-4 text-green-600" /> Debrief Analysis Complete
            </h3>
            <p className="text-xs text-muted-foreground mt-1">{results.readiness_level}</p>
          </div>
        </div>

        <Card className="bg-muted/40 border-0">
          <CardContent className="p-3">
            <div className="grid grid-cols-2 gap-3">
              <div>
                <p className="text-xs text-muted-foreground">Overall Score</p>
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

        <div className="space-y-2">
          <p className="text-xs font-semibold text-foreground">Section Scores</p>
          <div className="grid grid-cols-5 gap-2">
            {['A', 'B', 'C', 'D', 'E'].map((section) => (
              <div key={section} className="text-center">
                <div className="text-xs text-muted-foreground mb-1">Section {section}</div>
                <div className="bg-muted rounded px-2 py-1 text-sm font-semibold text-foreground">
                  {results.section_scores[section as keyof typeof results.section_scores] || 0}
                </div>
              </div>
            ))}
          </div>
        </div>

        {results.observer_feedback && (
          <div className="space-y-2">
            <p className="text-xs font-semibold text-foreground">Feedback</p>
            <div className="bg-muted/30 rounded p-2 text-xs text-muted-foreground max-h-32 overflow-y-auto">
              {typeof results.observer_feedback === 'string'
                ? results.observer_feedback
                : JSON.stringify(results.observer_feedback, null, 2)}
            </div>
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
            <p className="font-semibold text-red-700">Analysis Failed</p>
            <p className="text-xs text-red-600 mt-1">{error}</p>
          </div>
        </div>
        <Button onClick={retry} variant="outline" className="w-full">
          Try Again
        </Button>
      </div>
    );
  }

  return null;
}
