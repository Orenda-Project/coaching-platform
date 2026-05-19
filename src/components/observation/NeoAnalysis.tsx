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
  WifiOff,
  Pause,
  Play,
  RotateCcw,
  Trash2,
} from 'lucide-react';
import { toast } from 'sonner';
import type { CotObservation, NeoResults } from '@/types/observation';
import { saveAudioToQueue, getPendingAudio, removeFromQueue, lockForUpload, unlockUpload, saveSavedAudio, getSavedAudio, deleteSavedAudio } from '@/lib/audioQueue';
import { markObservationDraft } from '@/data/observations';

interface Props {
  observation: CotObservation;
  onSaved: (obs: CotObservation) => void;
}

type NeoPhase = 'idle' | 'recording' | 'saved' | 'uploading' | 'queued' | 'processing' | 'completed' | 'failed';
type Language = 'en' | 'ur';

// Detect actual audio format from file signature
async function detectAudioFormat(blob: Blob): Promise<string> {
  const headerBuffer = await blob.slice(0, 12).arrayBuffer();
  const view = new Uint8Array(headerBuffer);

  // WebM: 1A 45 DF A3
  if (view[0] === 0x1a && view[1] === 0x45 && view[2] === 0xdf && view[3] === 0xa3) {
    return 'audio/webm';
  }

  // OGG: 4F 67 67 53
  if (view[0] === 0x4f && view[1] === 0x67 && view[2] === 0x67 && view[3] === 0x53) {
    return 'audio/ogg';
  }

  // WAV: 52 49 46 46 (RIFF)
  if (view[0] === 0x52 && view[1] === 0x49 && view[2] === 0x46 && view[3] === 0x46) {
    return 'audio/wav';
  }

  // MP3: FF FB or FF FA
  if ((view[0] === 0xff && (view[1] === 0xfb || view[1] === 0xfa)) ||
      (view[0] === 0x49 && view[1] === 0x44 && view[2] === 0x33)) {
    return 'audio/mpeg';
  }

  // M4A/AAC: ftyp at offset 4
  if (view[4] === 0x66 && view[5] === 0x74 && view[6] === 0x79 && view[7] === 0x70) {
    return 'audio/mp4';
  }

  // Default fallback
  return 'audio/webm';
}

const translations: Record<Language, Record<string, string>> = {
  en: {
    'Coach Debrief': 'Coach Debrief',
    'Record your verbal feedback': 'Record your verbal feedback with the teacher. Neo will analyze your coaching communication quality.',
    'Record': 'Record',
    'Upload Audio': 'Upload Audio',
    'Recording': 'Recording',
    'Stop & Upload': 'Stop & Upload',
    'Uploading audio': 'Uploading audio...',
    'Neo is analyzing': 'Neo is analyzing your debrief (min 2 minutes)...',
    'Audio Saved Offline': 'Audio saved — waiting for connection',
    'Offline Sync Message': 'Neo analysis will start automatically when you\'re back online',
    'Debrief Analysis Complete': 'Debrief Analysis Complete',
    'Overall Score': 'Overall Score',
    'Section Scores': 'Section Scores',
    'Section': 'Section',
    'Detailed Feedback': 'Detailed Feedback',
    'Strengths': '✓ Strengths',
    'Next Steps for Growth': '→ Next Steps for Growth',
    'Analysis Failed': 'Analysis Failed',
    'Try Again': 'Try Again',
    'Pause': 'Pause',
    'Resume': 'Resume',
    'Save as Draft': 'Save as Draft',
  },
  ur: {
    'Coach Debrief': 'کوچ کا جائزہ',
    'Record your verbal feedback': 'اپنی شفاہی تنقید ریکارڈ کریں۔ Neo آپ کی کوچنگ کی معیار کا تجزیہ کرے گا۔',
    'Record': 'ریکارڈ کریں',
    'Upload Audio': 'آڈیو اپ لوڈ کریں',
    'Recording': 'ریکارڈنگ',
    'Stop & Upload': 'روکیں اور اپ لوڈ کریں',
    'Uploading audio': 'آڈیو اپ لوڈ کیا جا رہا ہے...',
    'Neo is analyzing': 'Neo آپ کے جائزے کا تجزیہ کر رہا ہے (کم از کم 2 منٹ)...',
    'Audio Saved Offline': 'آڈیو محفوظ ہوگیا — انتظار میں کنکشن کے لیے',
    'Offline Sync Message': 'Neo تجزیہ خودکار طور پر شروع ہوگا جب آپ آن لائن واپس آجائیں',
    'Debrief Analysis Complete': 'جائزہ کا تجزیہ مکمل ہو گیا',
    'Overall Score': 'کل اسکور',
    'Section Scores': 'سیکشن کے اسکور',
    'Section': 'سیکشن',
    'Detailed Feedback': 'تفصیلی تنقید',
    'Strengths': '✓ طاقتیں',
    'Next Steps for Growth': '→ ترقی کے اگلے قدم',
    'Analysis Failed': 'تجزیہ ناکام',
    'Try Again': 'دوبارہ کوشش کریں',
    'Pause': 'توقف',
    'Resume': 'جاری رکھیں',
    'Save as Draft': 'ڈرافٹ کے طور پر محفوظ کریں',
  },
};

export function NeoAnalysis({ observation, onSaved }: Props) {
  const [phase, setPhase] = useState<NeoPhase>('idle');
  const [language, setLanguage] = useState<Language>('en');
  const t = (key: string) => translations[language][key] || key;
  const [recordingTime, setRecordingTime] = useState(0);
  const [uploadProgress, setUploadProgress] = useState(0);
  const [pollProgress, setPollProgress] = useState(0);
  const [isUploading, setIsUploading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [translatedFeedback, setTranslatedFeedback] = useState<any>(null);
  const [translating, setTranslating] = useState(false);
  const [isPaused, setIsPaused] = useState(false);
  const [savedAudio, setSavedAudio] = useState<Blob | null>(null);
  const mediaRecorderRef = useRef<MediaRecorder | null>(null);
  const audioChunksRef = useRef<Blob[]>([]);
  const recordingIntervalRef = useRef<number | null>(null);
  const pollIntervalRef = useRef<number | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);
  const audioPlayerRef = useRef<HTMLAudioElement>(null);

  // Translation function
  const translateText = async (text: string): Promise<string> => {
    try {
      const response = await fetch(
        `https://api.mymemory.translated.net/get?q=${encodeURIComponent(text)}&langpair=en|ur`
      );
      const data = await response.json();
      return data.responseData?.translatedText || text;
    } catch (err) {
      console.error('Translation error:', err);
      return text;
    }
  };

  const translateFeedback = async (feedback: any) => {
    setTranslating(true);
    try {
      const translated = { ...feedback };

      if (feedback.strengths && Array.isArray(feedback.strengths)) {
        translated.strengths = await Promise.all(
          feedback.strengths.map((s: string) => translateText(s))
        );
      }

      if (feedback.next_steps && Array.isArray(feedback.next_steps)) {
        translated.next_steps = await Promise.all(
          feedback.next_steps.map(async (step: any) => ({
            growth_area: await translateText(step.growth_area),
            specific_behavior: await translateText(step.specific_behavior),
          }))
        );
      }

      setTranslatedFeedback(translated);
    } catch (err) {
      console.error('Feedback translation error:', err);
    } finally {
      setTranslating(false);
    }
  };

  // Check for pending audio on mount
  useEffect(() => {
    getPendingAudio(observation.id).then(record => {
      if (record) setPhase('queued');
    });
  }, [observation.id]);

  // Load saved audio on mount
  useEffect(() => {
    getSavedAudio(observation.id).then(result => {
      if (result) {
        setSavedAudio(result.blob);
        setPhase('saved');
      }
    });
  }, [observation.id]);

  // Update from observation real-time
  useEffect(() => {
    if (observation.neo_status === 'completed') {
      setPhase('completed');
      setTranslatedFeedback(null);
    } else if (observation.neo_status === 'failed') {
      setPhase('failed');
      setError(observation.neo_error || 'Neo processing failed');
    } else if (observation.neo_status === 'processing') {
      setPhase('processing');
    }
  }, [observation.neo_status, observation.neo_error]);

  const startRecording = async () => {
    try {
      // Check if browser supports getUserMedia
      if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
        throw new Error('Microphone recording not supported on this browser. Please use Chrome, Firefox, or Safari.');
      }

      console.log('Starting recording - requesting microphone access...');
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      console.log('Microphone access granted. Stream:', stream);

      // Let browser choose the format - it will pick the best supported one
      const mediaRecorder = new MediaRecorder(stream);
      mediaRecorderRef.current = mediaRecorder;
      audioChunksRef.current = [];
      console.log('MediaRecorder created');
      console.log('MediaRecorder.mimeType:', mediaRecorder.mimeType);

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
        // Stop tracks immediately - don't wait
        stream.getTracks().forEach((track) => {
          console.log(`Stopping audio track: ${track.kind}`);
          track.stop();
        });
      };

      console.log('Calling mediaRecorder.start()...');
      mediaRecorder.start(); // No timeslice = one complete audio blob on stop()
    } catch (err) {
      console.error('Microphone error:', err);

      let errorMsg = 'Could not access microphone';

      // Provide specific error messages based on error type
      if (err instanceof DOMException) {
        if (err.name === 'NotAllowedError') {
          errorMsg = 'Microphone permission denied. Please allow microphone access in browser settings and try again.';
        } else if (err.name === 'NotFoundError') {
          errorMsg = 'No microphone found. Please connect a microphone and try again.';
        } else if (err.name === 'NotReadableError') {
          errorMsg = 'Microphone is in use by another application. Please close other apps using the microphone.';
        }
      } else if (err instanceof Error) {
        errorMsg = err.message;
      }

      toast.error(errorMsg);
      setError(errorMsg);
    }
  };

  const togglePause = () => {
    if (!mediaRecorderRef.current || phase !== 'recording') return;

    if (isPaused) {
      mediaRecorderRef.current.resume();
      setIsPaused(false);
      if (recordingIntervalRef.current === null) {
        recordingIntervalRef.current = window.setInterval(() => {
          setRecordingTime((t) => t + 1);
        }, 1000);
      }
    } else {
      mediaRecorderRef.current.pause();
      setIsPaused(true);
      if (recordingIntervalRef.current !== null) {
        clearInterval(recordingIntervalRef.current);
        recordingIntervalRef.current = null;
      }
    }
  };

  const saveAudioLocally = async () => {
    if (!mediaRecorderRef.current || phase !== 'recording') {
      toast.error('No recording in progress');
      return;
    }

    // Stop the recording and wait for data
    return new Promise<void>((resolve) => {
      const handleStop = async () => {
        if (audioChunksRef.current.length === 0) {
          toast.error('No audio recorded');
          resolve();
          return;
        }

        const rawMimeType = mediaRecorderRef.current?.mimeType || 'audio/webm';
        const mimeType = rawMimeType.split(';')[0]; // Remove codec metadata (e.g. "audio/webm;codecs=opus" -> "audio/webm")
        console.log('saveAudioLocally - mediaRecorder.mimeType:', mediaRecorderRef.current?.mimeType);
        console.log('saveAudioLocally - cleaned mimeType:', mimeType);
        const audioBlob = new Blob(audioChunksRef.current, { type: mimeType });
        await saveSavedAudio(observation.id, audioBlob, mimeType);
        setSavedAudio(audioBlob);
        setPhase('saved');
        toast.success('Audio saved — review and submit with observation');
        resolve();
      };

      // Stop recording timer
      if (recordingIntervalRef.current) {
        clearInterval(recordingIntervalRef.current);
        recordingIntervalRef.current = null;
      }

      // Set up one-time stop listener
      mediaRecorderRef.current!.addEventListener('stop', handleStop, { once: true });

      // Stop the recorder
      mediaRecorderRef.current!.stop();
    });
  };

  const deleteRecording = async () => {
    await deleteSavedAudio(observation.id);
    setSavedAudio(null);
    setRecordingTime(0);
    audioChunksRef.current = [];
    setPhase('idle');
    toast.info('Recording deleted');
  };

  const reRecordAudio = () => {
    setSavedAudio(null);
    setRecordingTime(0);
    audioChunksRef.current = [];
    setPhase('idle');
  };

  const stopRecording = async () => {
    if (!mediaRecorderRef.current || phase !== 'recording') {
      return;
    }

    // Stop recording timer
    if (recordingIntervalRef.current) {
      clearInterval(recordingIntervalRef.current);
      recordingIntervalRef.current = null;
    }

    setIsPaused(false);

    return new Promise<void>((resolve) => {
      const handleStop = async () => {
        try {
          if (audioChunksRef.current.length === 0) {
            toast.error('No audio recorded');
            setPhase('idle');
            resolve();
            return;
          }

          const rawMimeType = mediaRecorderRef.current?.mimeType || 'audio/webm';
          const mimeType = rawMimeType.split(';')[0]; // Remove codec metadata (e.g. "audio/webm;codecs=opus" -> "audio/webm")
          console.log('stopRecording - mediaRecorder.mimeType:', mediaRecorderRef.current?.mimeType);
          console.log('stopRecording - cleaned mimeType:', mimeType);
          const audioBlob = new Blob(audioChunksRef.current, { type: mimeType });
          console.log('Created blob:', audioBlob.size, 'bytes, MIME:', mimeType);

          await saveSavedAudio(observation.id, audioBlob, mimeType);
          setSavedAudio(audioBlob);
          setPhase('saved');
          toast.success('Recording stopped — ready to upload');
        } catch (err) {
          console.error('Error saving recording:', err);
          toast.error('Error saving recording');
        }
        resolve();
      };

      mediaRecorderRef.current!.addEventListener('stop', handleStop, { once: true });
      mediaRecorderRef.current!.stop();
    });
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
      // Acquire upload lock to prevent concurrent uploads
      if (!lockForUpload(observation.id)) {
        toast.error('Upload already in progress');
        return;
      }

      setIsUploading(true);
      console.log('========== UPLOAD DEBUG START ==========');
      console.log('uploadAudio called with blob size:', blob.size);
      console.log('observation.id:', observation.id);
      console.log('blob.type:', blob.type);

      // Strip codec info from MIME type (e.g. "audio/webm;codecs=opus" -> "audio/webm")
      let cleanMimeType = blob.type.split(';')[0] || 'audio/webm';
      console.log('Cleaned MIME type:', cleanMimeType);

      const formData = new FormData();
      formData.append('file', blob);
      formData.append('observation_id', observation.id);

      console.log('FormData created:');
      console.log('  - file: size=' + blob.size + ' bytes');
      console.log('  - observation_id:', observation.id);
      console.log('  - sending with MIME type:', cleanMimeType);
      console.log('Checking token...');
      const token = (await supabase.auth.getSession()).data.session?.access_token;
      if (!token) {
        unlockUpload(observation.id);
        toast.error('Not authenticated');
        setPhase('idle');
        setIsUploading(false);
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
      console.log('Response headers:', {
        'content-type': response.headers.get('content-type'),
        'content-length': response.headers.get('content-length'),
      });

      if (!response.ok) {
        console.error('❌ Upload response NOT OK');
        console.error('Status:', response.status, response.statusText);
        console.error('Blob size:', blob.size, 'bytes');
        console.error('Blob type:', blob.type);
        console.error('Cleaned MIME type sent:', cleanMimeType);
        let err;
        try {
          const text = await response.text();
          console.error('Response body raw:', text);
          console.error('Response body length:', text.length);
          err = JSON.parse(text);
        } catch (e) {
          console.error('Could not parse response:', response.statusText);
          console.error('Parse error:', e);
          err = {};
        }
        console.error('Parsed error object:', err);
        console.log('========== UPLOAD DEBUG END (FAILED) ==========');

        // Handle specific error codes
        let errorMsg = err.error || `Upload failed: ${response.status}`;
        if (response.status === 404 && blob.size > 10 * 1024 * 1024) {
          // 404 + large file = likely audio limit exceeded
          errorMsg = 'Audio file too large. Please record a shorter debrief (under 5 minutes recommended).';
        } else if (response.status === 413 || response.status === 429) {
          errorMsg = 'Audio limit exceeded. Please record a shorter debrief (under 5 minutes recommended).';
        } else if (response.status === 404) {
          errorMsg = 'Upload service unavailable. Please try again in a moment, or record a shorter debrief.';
        }

        throw new Error(errorMsg);
      }

      const data = await response.json();
      console.log('✅ Upload successful');
      console.log('Response data:', data);
      console.log('========== UPLOAD DEBUG END (SUCCESS) ==========');

      // Clean up from queue if this was a queued upload
      await removeFromQueue(observation.id);
      unlockUpload(observation.id);

      // Clean up saved audio if this was uploaded from saved phase
      await deleteSavedAudio(observation.id);

      setIsUploading(false);
      setSavedAudio(null);
      setPhase('processing');
      setPollProgress(0);
      setError(null);

      // Start polling
      pollNeoStatus();
    } catch (err) {
      setIsUploading(false);
      unlockUpload(observation.id);
      const isNetworkError = !navigator.onLine || err instanceof TypeError;

      if (isNetworkError) {
        // Save to offline queue
        await saveAudioToQueue({
          observation_id: observation.id,
          blob,
          mime_type: mimeType,
          queued_at: new Date().toISOString(),
          observer_id: observation.observer_id,
        });

        // Save audio locally and mark observation as Draft
        await saveSavedAudio(observation.id, blob, mimeType);
        await markObservationDraft(observation.id);

        onSaved({ ...observation, status: 'Draft' });
        setPhase('queued');
        setError(null);
        toast.info('Audio saved offline — will upload when connection returns');
      } else {
        const message = err instanceof Error ? err.message : 'Upload failed';
        toast.error(message);
        setError(message);
        setPhase('saved');
      }
    }
  };

  const pollNeoStatus = async () => {
    console.log('pollNeoStatus called');
    const token = (await supabase.auth.getSession()).data.session?.access_token;
    if (!token) {
      console.error('No token for polling');
      return;
    }

    console.log('Starting Neo status polling with observation_id:', observation.id);
    let pollCount = 0;
    const maxPolls = 100; // ~800 seconds for longer audio processing

    pollIntervalRef.current = window.setInterval(async () => {
      pollCount++;
      console.log(`Poll interval tick #${pollCount}`);
      setPollProgress(Math.min((pollCount / maxPolls) * 100, 90));

      try {
        console.log(`Poll #${pollCount}: fetching neo-status...`);
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

        console.log(`Poll #${pollCount}: response status=${response.status}`);

        if (!response.ok) {
          const err = await response.json();
          console.error(`Poll #${pollCount}: error response`, err);
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

  const attemptQueuedUpload = useCallback(async () => {
    const record = await getPendingAudio(observation.id);
    if (!record) return;
    if (!lockForUpload(observation.id)) return; // Already uploading

    setPhase('uploading');
    // Re-fetch token to ensure it's fresh
    const token = (await supabase.auth.getSession()).data.session?.access_token;
    if (!token) {
      unlockUpload(observation.id);
      toast.error('Not authenticated');
      return;
    }
    const mimeType = record.mime_type;

    try {
      const formData = new FormData();
      formData.append('file', record.blob);
      formData.append('observation_id', observation.id);

      const response = await fetch(
        `${import.meta.env.VITE_SUPABASE_URL}/functions/v1/neo-start`,
        { method: 'POST', headers: { Authorization: `Bearer ${token}` }, body: formData }
      );

      if (!response.ok) {
        const err = await response.json().catch(() => ({}));
        throw new Error(err.error || `Upload failed: ${response.status}`);
      }

      await removeFromQueue(observation.id);
      unlockUpload(observation.id);
      setPhase('processing');
      setPollProgress(0);
      setError(null);
      pollNeoStatus();
    } catch (err) {
      unlockUpload(observation.id);
      const message = err instanceof Error ? err.message : 'Upload failed';
      toast.error(message);
      setError(message);
      setPhase('queued');
    }
  }, [observation.id, pollNeoStatus]);

  // Listen for online event when queued
  useEffect(() => {
    if (phase !== 'queued') return;
    const handleOnline = () => {
      attemptQueuedUpload();
    };
    window.addEventListener('online', handleOnline);
    return () => window.removeEventListener('online', handleOnline);
  }, [phase, attemptQueuedUpload]);

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
    const isLong = recordingTime > 300; // 5 min warning
    return (
      <Card className={`${isLong ? 'bg-amber-50 border-amber-200' : 'bg-slate-50 border-slate-200'}`}>
        <CardContent className="pt-5 pb-5 px-5">
          <div className="flex flex-col items-center space-y-5">
            {/* Status with indicator */}
            <div className="flex items-center gap-2">
              <div className={`w-2.5 h-2.5 rounded-full ${isPaused ? '' : 'animate-pulse'}`} style={{ backgroundColor: isLong ? '#f59e0b' : isPaused ? '#f59e0b' : '#dc2626' }} />
              <span className={`text-sm font-medium ${isLong ? 'text-amber-700' : 'text-foreground'}`}>
                {isPaused ? 'Paused' : 'Recording'} — {mins}:{secs.toString().padStart(2, '0')}
              </span>
            </div>
            {isLong && (
              <p className="text-xs text-amber-700 text-center">
                ⚠️ Long recording (5+ min). Consider stopping and uploading to avoid upload issues.
              </p>
            )}

            {/* Icon buttons */}
            <div className="flex items-center justify-center gap-6">
              <button
                onClick={togglePause}
                className="p-2 rounded-full hover:bg-slate-200 transition-colors"
                title={isPaused ? 'Resume' : 'Pause'}
              >
                {isPaused ? (
                  <Play className="w-5 h-5 text-slate-700" fill="currentColor" />
                ) : (
                  <Pause className="w-5 h-5 text-slate-700" fill="currentColor" />
                )}
              </button>

              <button
                onClick={stopRecording}
                className="p-2.5 rounded-full bg-slate-400 hover:bg-slate-500 transition-colors"
                title="Stop"
              >
                <Square className="w-5 h-5 text-white" fill="currentColor" />
              </button>
            </div>
          </div>
        </CardContent>
      </Card>
    );
  }

  // Saved phase (audio saved locally, waiting to submit)
  if (phase === 'saved' && savedAudio) {
    const audioUrl = URL.createObjectURL(savedAudio);
    return (
      <div className="space-y-4">
        <div className="bg-blue-50 border border-blue-200 rounded-lg p-3">
          <p className="text-sm font-medium text-blue-900">Audio saved</p>
          <p className="text-xs text-blue-700 mt-1">Review and upload for Neo debrief analysis</p>
        </div>

        {/* Audio player */}
        <audio
          ref={audioPlayerRef}
          controls
          className="w-full"
          src={audioUrl}
          onLoadedMetadata={() => {
            if (audioPlayerRef.current) {
              const mins = Math.floor(audioPlayerRef.current.duration / 60);
              const secs = Math.floor(audioPlayerRef.current.duration % 60);
              console.log(`Audio duration: ${mins}:${secs.toString().padStart(2, '0')}`);
            }
          }}
        />

        {/* Upload button */}
        <Button onClick={() => uploadAudio(savedAudio, (mediaRecorderRef.current as any)?._mimeType || 'audio/webm')} disabled={isUploading} className="w-full py-6">
          {isUploading ? 'Uploading...' : 'Upload for Debrief'}
        </Button>

        {/* Icon buttons */}
        <div className="flex items-center justify-center gap-6">
          <button
            onClick={reRecordAudio}
            className="p-3 rounded-full hover:bg-muted transition-colors"
            title="Re-record"
          >
            <RotateCcw className="w-6 h-6 text-foreground" />
          </button>
          <button
            onClick={deleteRecording}
            className="p-3 rounded-full hover:bg-red-50 transition-colors"
            title="Delete"
          >
            <Trash2 className="w-6 h-6 text-destructive" />
          </button>
        </div>
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

  // Queued phase (offline)
  if (phase === 'queued') {
    return (
      <div className="space-y-3">
        <div className="flex items-start gap-3 bg-amber-50 border border-amber-200 rounded-lg p-3">
          <WifiOff className="w-5 h-5 text-amber-700 shrink-0 mt-0.5" />
          <div>
            <p className="font-medium text-amber-900">{t('Audio Saved Offline')}</p>
            <p className="text-xs text-amber-700 mt-1">{t('Offline Sync Message')}</p>
          </div>
        </div>
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
        <div className="flex items-start justify-between">
          <div className="flex-1">
            <h3 className="font-semibold text-foreground flex items-center gap-2">
              <CheckCircle2 className="w-4 h-4 text-green-600" /> {t('Debrief Analysis Complete')}
            </h3>
            <p className="text-xs text-muted-foreground mt-1 line-clamp-2">
              {language === 'ur' && translatedFeedback ? translatedFeedback.readiness_level || results.readiness_level : results.readiness_level}
            </p>
          </div>
          <div className="flex gap-1 shrink-0">
            <Button
              variant={language === 'en' ? 'default' : 'outline'}
              size="sm"
              className="text-xs h-7 px-2"
              onClick={() => {
                setLanguage('en');
                setTranslatedFeedback(null);
              }}
            >
              EN
            </Button>
            <Button
              variant={language === 'ur' ? 'default' : 'outline'}
              size="sm"
              className="text-xs h-7 px-2"
              onClick={() => {
                setLanguage('ur');
                if (!translatedFeedback) {
                  translateFeedback(results.observer_feedback);
                }
              }}
              disabled={translating}
            >
              {translating ? '...' : 'اردو'}
            </Button>
          </div>
        </div>

        <Card className="bg-muted/40 border-0">
          <CardContent className="p-3">
            <div className="grid grid-cols-2 gap-3">
              <div>
                <p className="text-[10px] text-muted-foreground uppercase tracking-wide">{t('Overall Score')}</p>
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
                {((language === 'ur' && translatedFeedback) ? translatedFeedback : results.observer_feedback).strengths && (
                  <div className="space-y-1">
                    <p className="text-xs font-medium text-green-700 text-opacity-80">{t('Strengths')}</p>
                    <div className="space-y-1 text-xs text-foreground">
                      {(((language === 'ur' && translatedFeedback) ? translatedFeedback : results.observer_feedback).strengths || []).map((strength: string, idx: number) => (
                        <div key={idx} className="bg-green-50 border border-green-200 rounded p-2 text-green-900">
                          {strength}
                        </div>
                      ))}
                    </div>
                  </div>
                )}

                {((language === 'ur' && translatedFeedback) ? translatedFeedback : results.observer_feedback).next_steps && (
                  <div className="space-y-2">
                    <p className="text-xs font-medium text-blue-700">{t('Next Steps for Growth')}</p>
                    <div className="space-y-1 text-xs text-foreground">
                      {(((language === 'ur' && translatedFeedback) ? translatedFeedback : results.observer_feedback).next_steps || []).map((step: any, idx: number) => (
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
