/* eslint-disable @typescript-eslint/no-explicit-any */
import { useState, useRef, useCallback, useEffect } from 'react';
import { supabase } from '@/integrations/supabase/client';
import { getObservation, patchObservation } from '@/data/observations';
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
  Pause,
  Play,
  RotateCcw,
  Trash2,
  Loader2,
} from 'lucide-react';
import { toast } from 'sonner';
import type { CotObservation, NeoResults, NeoObserverFeedback } from '@/types/observation';
import { saveSavedAudio, getSavedAudio, deleteSavedAudio } from '@/lib/audioQueue';
import { markObservationDraft } from '@/data/observations';

interface Props {
  observation: CotObservation;
  onSaved: (obs: CotObservation) => void;
}

type NeoPhase = 'idle' | 'recording' | 'saved' | 'uploading' | 'processing' | 'completed' | 'failed';
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

// Convert AudioBuffer to WAV Blob for Neo compatibility
function audioBufferToWav(audioBuffer: AudioBuffer): Blob {
  const numberOfChannels = audioBuffer.numberOfChannels;
  const sampleRate = audioBuffer.sampleRate;
  const format = 1; // PCM
  const bitDepth = 16;

  const bytesPerSample = bitDepth / 8;
  const blockAlign = numberOfChannels * bytesPerSample;

  const channelData = [];
  for (let i = 0; i < numberOfChannels; i++) {
    channelData.push(audioBuffer.getChannelData(i));
  }

  const length = audioBuffer.length * numberOfChannels * bytesPerSample + 36;
  const arrayBuffer = new ArrayBuffer(44 + length);
  const view = new DataView(arrayBuffer);

  const writeString = (offset: number, string: string) => {
    for (let i = 0; i < string.length; i++) {
      view.setUint8(offset + i, string.charCodeAt(i));
    }
  };

  writeString(0, 'RIFF');
  view.setUint32(4, 36 + length, true);
  writeString(8, 'WAVE');
  writeString(12, 'fmt ');
  view.setUint32(16, 16, true);
  view.setUint16(20, format, true);
  view.setUint16(22, numberOfChannels, true);
  view.setUint32(24, sampleRate, true);
  view.setUint32(28, sampleRate * blockAlign, true);
  view.setUint16(32, blockAlign, true);
  view.setUint16(34, bitDepth, true);
  writeString(36, 'data');
  view.setUint32(40, length, true);

  let offset = 44;
  const volume = 1;
  for (let i = 0; i < audioBuffer.length; i++) {
    for (let channel = 0; channel < numberOfChannels; channel++) {
      const sample = Math.max(-1, Math.min(1, channelData[channel][i])) * 0x7fff;
      view.setInt16(offset, sample < 0 ? sample * 0x8000 : sample * 0x7fff, true);
      offset += 2;
    }
  }

  return new Blob([arrayBuffer], { type: 'audio/wav' });
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
  const [savedAudioMimeType, setSavedAudioMimeType] = useState<string>('audio/webm');
  const [savedAudioUrl, setSavedAudioUrl] = useState<string | null>(null);
  const [neoTaskId, setNeoTaskId] = useState<string | null>(null);
  const mediaRecorderRef = useRef<MediaRecorder | null>(null);
  const audioChunksRef = useRef<Blob[]>([]);
  const recordingIntervalRef = useRef<number | null>(null);
  const pollIntervalRef = useRef<number | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);
  const audioPlayerRef = useRef<HTMLAudioElement>(null);
  const autoResumedRef = useRef(false);

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

  const translateFeedback = async (feedback: any, readinessLevel?: string) => {
    setTranslating(true);
    try {
      const translated: any = { ...feedback };

      // Translate readiness_level (lives on results, not observer_feedback)
      if (readinessLevel) {
        translated.readiness_level = await translateText(readinessLevel);
      }

      if (feedback.overall_summary) {
        translated.overall_summary = await translateText(feedback.overall_summary);
      }

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
            self_reflection_question: step.self_reflection_question
              ? await translateText(step.self_reflection_question)
              : undefined,
          }))
        );
      }

      if (feedback.priority_growth_areas && Array.isArray(feedback.priority_growth_areas)) {
        translated.priority_growth_areas = await Promise.all(
          feedback.priority_growth_areas.map((area: string) => translateText(area))
        );
      }

      if (feedback.closing_encouragement) {
        translated.closing_encouragement = await translateText(feedback.closing_encouragement);
      }

      setTranslatedFeedback(translated);
    } catch (err) {
      console.error('Feedback translation error:', err);
    } finally {
      setTranslating(false);
    }
  };

  // Load saved audio on mount
  useEffect(() => {
    getSavedAudio(observation.id).then(result => {
      if (result) {
        const typedBlob = new Blob([result.blob], { type: result.mime_type });
        setSavedAudio(typedBlob);
        setSavedAudioMimeType(result.mime_type);
        setPhase('saved');
      }
    });
  }, [observation.id]);

  // Create/revoke object URL for audio playback — avoids memory leak from inline createObjectURL
  useEffect(() => {
    if (savedAudio) {
      const url = URL.createObjectURL(savedAudio);
      setSavedAudioUrl(url);
      return () => URL.revokeObjectURL(url);
    }
    setSavedAudioUrl(null);
  }, [savedAudio]);

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

  // Auto-resume polling if panel was closed while analysis was in progress
  useEffect(() => {
    if (!autoResumedRef.current && observation.neo_task_id && observation.neo_status === 'processing') {
      autoResumedRef.current = true;
      setPhase('processing');
      setNeoTaskId(observation.neo_task_id);
      pollNeoStatus(observation.neo_task_id);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // Cleanup intervals on unmount
  useEffect(() => {
    return () => {
      if (pollIntervalRef.current) clearInterval(pollIntervalRef.current);
      if (recordingIntervalRef.current) clearInterval(recordingIntervalRef.current);
    };
  }, []);

  // Silent auto-retry when results haven't propagated yet after completion
  useEffect(() => {
    if (phase === 'completed' && !observation.neo_results) {
      const timer = setTimeout(async () => {
        try {
          const refreshed = await getObservation(observation.id);
          if (refreshed.neo_results) onSaved(refreshed);
        } catch (_) { /* silent retry */ }
      }, 2000);
      return () => clearTimeout(timer);
    }
  }, [phase, observation.neo_results, observation.id, onSaved]);

  const startRecording = async () => {
    try {
      // Check if browser supports getUserMedia
      if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
        throw new Error('Microphone recording not supported on this browser. Please use Chrome, Firefox, or Safari.');
      }

      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });

      // Let browser choose the format - it will pick the best supported one
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
        // Stop tracks immediately - don't wait
        stream.getTracks().forEach((track) => {
          track.stop();
        });
      };
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
          const audioBlob = new Blob(audioChunksRef.current, { type: mimeType });

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

  const handleFileUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    const mimeType = file.type || 'audio/webm';
    await saveSavedAudio(observation.id, file, mimeType);
    setSavedAudio(file);
    setSavedAudioMimeType(mimeType);
    setPhase('saved');
    toast.success('Audio file saved — tap "Analyze Debrief" when ready');
    if (fileInputRef.current) fileInputRef.current.value = '';
  };

  const uploadAudio = async (blob: Blob, mimeType: string) => {
    let progressInterval: number | undefined;
    try {
      if (!observation?.id) {
        toast.error('No observation selected. Please schedule a visit first.');
        setPhase('idle');
        return;
      }

      setPhase('uploading');
      setUploadProgress(0);
      setIsUploading(true);

      // Simulate upload progress since fetch doesn't expose upload progress events
      let simulated = 0;
      progressInterval = window.setInterval(() => {
        simulated = Math.min(simulated + Math.random() * 8, 85);
        setUploadProgress(simulated);
      }, 400);

      // Convert WebM to WAV to ensure compatibility with Neo
      let uploadBlob = blob;
      let uploadMimeType = mimeType || blob.type || 'audio/webm';

      // Detect actual audio format from file signature
      const detectedFormat = await detectAudioFormat(blob);
      console.log('[NeoAnalysis] Starting upload:', {
        blobType: blob.type,
        passedMimeType: mimeType,
        detectedFormat: detectedFormat,
        size: blob.size,
      });

      // Always convert to WAV unless already WAV (ensures Neo compatibility)
      if (detectedFormat !== 'audio/wav') {
        try {
          console.log('[NeoAnalysis] Converting', detectedFormat, 'to WAV');
          const audioContext = new (window.AudioContext || (window as any).webkitAudioContext)();
          const arrayBuffer = await blob.arrayBuffer();
          const audioBuffer = await audioContext.decodeAudioData(arrayBuffer);

          // Convert to WAV
          const wavBlob = audioBufferToWav(audioBuffer);
          uploadBlob = wavBlob;
          uploadMimeType = 'audio/wav';
          console.log('[NeoAnalysis] Conversion successful', {
            from: detectedFormat,
            originalSize: blob.size,
            wavSize: wavBlob.size,
            wavType: wavBlob.type,
          });
        } catch (conversionError) {
          console.error('[NeoAnalysis] Conversion failed:', conversionError);
          uploadMimeType = detectedFormat;
        }
      } else {
        console.log('[NeoAnalysis] Already WAV, no conversion needed');
        uploadMimeType = 'audio/wav';
      }

      const formData = new FormData();

      // Create blob with explicit mime type if not already set
      let finalBlob = uploadBlob;
      if (!finalBlob.type || finalBlob.type === 'application/octet-stream') {
        finalBlob = new Blob([uploadBlob], { type: uploadMimeType });
      }

      // Use appropriate filename extension
      const filename = uploadMimeType === 'audio/wav' ? 'recording.wav' : 'recording.webm';
      formData.append('file', finalBlob, filename);
      formData.append('observation_id', observation.id);
      if (observation.region) {
        formData.append('region', observation.region);
      }

      console.log('[NeoAnalysis] Uploading audio for observation:', {
        id: observation.id,
        status: observation.status,
        originalSize: blob.size,
        uploadSize: finalBlob.size,
        mimeType: uploadMimeType,
        blobType: finalBlob.type,
        filename: filename,
      });

      const token = (await supabase.auth.getSession()).data.session?.access_token;
      if (!token) {
        toast.error('Not authenticated');
        setPhase('idle');
        setIsUploading(false);
        return;
      }

      const uploadUrl = `${import.meta.env.VITE_SUPABASE_URL}/functions/v1/neo-start`;

      const response = await fetch(uploadUrl, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${token}`,
        },
        body: formData,
      });

      if (!response.ok) {
        let err: any = {};
        try {
          const text = await response.text();
          err = JSON.parse(text);
        } catch (e) {
          err = {};
        }

        console.error('[NeoAnalysis] Upload failed:', {
          status: response.status,
          error: err.error,
          errorCode: err.errorCode,
          details: err.details,
        });

        // Handle specific error codes
        let errorMsg = err.error || `Upload failed: ${response.status}`;
        if (response.status === 404 && err.errorCode === 'OBS_NOT_FOUND') {
          errorMsg = 'Visit record not found. Please try scheduling the visit again.';
        } else if (response.status === 404 && blob.size > 10 * 1024 * 1024) {
          // 404 + large file = likely audio limit exceeded
          errorMsg = 'Audio file too large. Please record a shorter debrief (under 5 minutes recommended).';
        } else if (response.status === 413 || response.status === 429) {
          errorMsg = 'Audio limit exceeded. Please record a shorter debrief (under 5 minutes recommended).';
        } else if (response.status === 404) {
          errorMsg = 'Upload service unavailable. Please try again in a moment.';
        }

        throw new Error(errorMsg);
      }

      const data = await response.json();
      const taskId = data.task_id as string | undefined;

      // Clean up saved audio if this was uploaded from saved phase
      await deleteSavedAudio(observation.id);

      if (progressInterval) clearInterval(progressInterval);
      setUploadProgress(100);
      setIsUploading(false);
      setSavedAudio(null);
      if (taskId) {
        setNeoTaskId(taskId);
        // Persist neo_task_id + neo_status to Railway Postgres so polling resumes if panel is closed
        patchObservation(observation.id, { neo_task_id: taskId, neo_status: 'processing' }).catch(() => {});
      }
      setPhase('processing');
      setPollProgress(0);
      setError(null);

      // Start polling — pass task_id directly so neo-status doesn't need a Supabase lookup
      pollNeoStatus(taskId);
    } catch (err) {
      if (progressInterval) clearInterval(progressInterval);
      setUploadProgress(0);
      setIsUploading(false);
      const message = err instanceof Error ? err.message : 'Upload failed';
      toast.error(message);
      setError(message);
      setPhase(savedAudio ? 'saved' : 'idle');
    }
  };

  const pollNeoStatus = useCallback(async (taskId?: string) => {
    const token = (await supabase.auth.getSession()).data.session?.access_token;
    if (!token) {
      return;
    }

    let pollCount = 0;
    const maxPolls = 100; // ~800 seconds for longer audio processing

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
            body: JSON.stringify({
              observation_id: observation.id,
              task_id: taskId || neoTaskId || undefined,
              region: observation.region || undefined,
            }),
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

          const neoResults = data.results || observation.neo_results;

          // Show results immediately from the API response — don't wait for DB round-trip
          if (neoResults) {
            onSaved({ ...observation, neo_status: 'completed' as const, neo_results: neoResults });
          }

          // Persist to DB in the background
          patchObservation(observation.id, {
            neo_status: 'completed',
            neo_results: neoResults || undefined,
          }).then(async updated => {
            if (updated.neo_results) {
              onSaved(updated);
            } else if (!neoResults) {
              // No results from API or patch — try fetching directly
              try {
                const refreshed = await getObservation(observation.id);
                if (refreshed.neo_results) onSaved(refreshed);
              } catch (_) { /* silent fallback */ }
            }
          }).catch(async () => {
            if (!neoResults) {
              try {
                const refreshed = await getObservation(observation.id);
                if (refreshed.neo_results) onSaved(refreshed);
              } catch (_) { /* silent fallback */ }
            }
          });
        } else if (data.status === 'failed') {
          if (pollIntervalRef.current) {
            clearInterval(pollIntervalRef.current);
          }
          setError(data.error || 'Neo processing failed');
          setPhase('failed');
          toast.error('Debrief analysis failed');
        }
      } catch (err) {
        if (pollCount >= maxPolls) {
          if (pollIntervalRef.current) {
            clearInterval(pollIntervalRef.current);
          }
          setError('Polling timeout');
          setPhase('failed');
        }
      }
    }, 8000);
  }, [observation, onSaved, neoTaskId]);


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

  // Saved phase (audio saved locally, ready to analyze)
  if (phase === 'saved' && savedAudio) {
    return (
      <div className="space-y-4">
        <div className="bg-blue-50 border border-blue-200 rounded-lg p-3 flex items-center gap-2">
          <CheckCircle2 className="w-4 h-4 text-blue-700 shrink-0" />
          <div>
            <p className="text-sm font-medium text-blue-900">Audio saved</p>
            <p className="text-xs text-blue-700 mt-0.5">Review below, then analyze when ready</p>
          </div>
        </div>

        {savedAudioUrl && (
          <audio controls className="w-full" src={savedAudioUrl} />
        )}

        <Button
          onClick={() => uploadAudio(savedAudio, savedAudioMimeType)}
          disabled={isUploading}
          className="w-full py-6"
        >
          {isUploading ? 'Uploading...' : 'Analyze Debrief →'}
        </Button>

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
      <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 space-y-3">
        <div className="flex items-center gap-2">
          <Upload className="w-4 h-4 text-blue-700" />
          <p className="text-sm font-medium text-blue-900">Uploading audio…</p>
          <span className="ml-auto text-xs text-blue-700 tabular-nums">{Math.round(uploadProgress)}%</span>
        </div>
        <Progress value={uploadProgress} className="h-2.5" />
        <p className="text-xs text-blue-600">Please keep this page open while the audio uploads.</p>
      </div>
    );
  }

  // Processing phase — staged progress card
  if (phase === 'processing') {
    const stage = pollProgress < 30 ? 0 : pollProgress < 70 ? 1 : 2;
    const stages = [
      'Transcribing audio',
      'Analyzing coaching quality',
      'Generating feedback',
    ];
    return (
      <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 space-y-4">
        <div className="flex items-center gap-2">
          <Brain className="w-4 h-4 text-blue-700 animate-pulse" />
          <p className="text-sm font-medium text-blue-900">Neo is analyzing your debrief</p>
        </div>

        <div className="space-y-2.5">
          {stages.map((label, i) => (
            <div key={i} className="flex items-center gap-2.5 text-xs">
              {i < stage ? (
                <CheckCircle2 className="w-3.5 h-3.5 text-green-600 shrink-0" />
              ) : i === stage ? (
                <div className="w-3.5 h-3.5 border-2 border-blue-600 border-t-transparent rounded-full animate-spin shrink-0" />
              ) : (
                <div className="w-3.5 h-3.5 rounded-full border border-slate-300 shrink-0" />
              )}
              <span className={
                i < stage
                  ? 'text-green-700'
                  : i === stage
                  ? 'text-blue-800 font-medium'
                  : 'text-muted-foreground'
              }>
                {label}
              </span>
            </div>
          ))}
        </div>

        <Progress value={pollProgress} className="h-2.5" />
        <p className="text-xs text-blue-600">This usually takes 2–5 minutes. You can close this panel — Neo will keep running.</p>
      </div>
    );
  }

  // Completed phase — results still propagating
  if (phase === 'completed' && !observation.neo_results) {
    return (
      <div className="flex items-center justify-center gap-2 py-10 text-sm text-muted-foreground">
        <Loader2 className="w-4 h-4 animate-spin" />
        Loading results…
      </div>
    );
  }

  if (phase === 'completed' && observation.neo_results) {
    const results = observation.neo_results as NeoResults;

    const getGradeColor = (grade: string) => {
      const lower = grade.toLowerCase();
      if (lower.includes('emerging') || lower.includes('critical')) return 'text-red-700 bg-red-50 border-red-200';
      if (lower.includes('developing')) return 'text-orange-700 bg-orange-50 border-orange-200';
      if (lower.includes('proficient')) return 'text-blue-700 bg-blue-50 border-blue-200';
      if (lower.includes('accomplished') || lower.includes('exemplary')) return 'text-emerald-700 bg-emerald-50 border-emerald-200';
      return 'text-amber-700 bg-amber-50 border-amber-200';
    };
    const color = getGradeColor(results.grade || '');

    return (
      <div className="space-y-3">
        <div className="flex items-start justify-between">
          <div className="flex-1">
            <div className="flex items-center gap-2 text-sm">
              <CheckCircle2 className="w-4 h-4 text-green-600" />
              <p className="text-xs text-muted-foreground">{t('Debrief Analysis Complete')}</p>
            </div>
            <p className="text-sm text-foreground font-medium mt-2 line-clamp-2">
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
                  translateFeedback(results.observer_feedback, results.readiness_level);
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

        {results.section_scores && Object.keys(results.section_scores).length > 0 && (
          <div className="space-y-2">
            <p className="text-xs font-semibold text-foreground">{t('Section Scores')}</p>
            <div className="space-y-2">
              {['S1','S2','S3','S4','S5','S6']
                .filter(k => k in results.section_scores)
                .map(k => {
                  const score = results.section_scores[k] ?? 0;
                  const meta = results.section_metadata?.[k];
                  const maxScore = meta?.max_score ?? 20;
                  const pct = Math.round((score / maxScore) * 100);
                  return (
                    <div key={k}>
                      <div className="flex justify-between items-center mb-0.5">
                        <span className="text-xs text-foreground">
                          <span className="font-medium">{k}</span>
                          {meta?.name && <span className="text-muted-foreground"> · {meta.name}</span>}
                        </span>
                        <span className="text-xs font-semibold text-foreground tabular-nums">{score}/{maxScore}</span>
                      </div>
                      <Progress value={pct} className="h-1.5" />
                    </div>
                  );
                })
              }
            </div>
          </div>
        )}

        {results.observer_feedback && typeof results.observer_feedback === 'object' && (() => {
          const fb = ((language === 'ur' && translatedFeedback) ? translatedFeedback : results.observer_feedback) as NeoObserverFeedback;
          return (
            <div className="space-y-3">
              <p className="text-xs font-semibold text-foreground">{t('Detailed Feedback')}</p>

              {/* Overall summary */}
              {fb.overall_summary && (
                <div className="bg-muted/40 rounded p-3 text-xs text-foreground leading-relaxed">
                  {fb.overall_summary}
                </div>
              )}

              {/* Strengths */}
              {fb.strengths && fb.strengths.length > 0 && (
                <div className="space-y-1">
                  <p className="text-xs font-medium text-green-700">{t('Strengths')}</p>
                  <div className="space-y-1">
                    {fb.strengths.map((s, idx) => (
                      <div key={idx} className="bg-green-50 border border-green-200 rounded p-2 text-xs text-green-900">{s}</div>
                    ))}
                  </div>
                </div>
              )}

              {/* Next Steps */}
              {fb.next_steps && fb.next_steps.length > 0 && (
                <div className="space-y-2">
                  <p className="text-xs font-medium text-blue-700">{t('Next Steps for Growth')}</p>
                  <div className="space-y-2">
                    {fb.next_steps.map((step, idx) => (
                      <div key={idx} className="bg-blue-50 border border-blue-200 rounded p-2 text-xs text-blue-900">
                        <p className="font-medium">{step.growth_area}</p>
                        <p className="mt-1">{step.specific_behavior}</p>
                        {step.self_reflection_question && (
                          <p className="mt-1.5 italic opacity-80">🤔 {step.self_reflection_question}</p>
                        )}
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {/* Priority growth areas */}
              {fb.priority_growth_areas && fb.priority_growth_areas.length > 0 && (
                <div className="space-y-1">
                  <p className="text-xs font-medium text-orange-700">Priority Areas</p>
                  <div className="space-y-1">
                    {fb.priority_growth_areas.map((area, idx) => (
                      <div key={idx} className="bg-orange-50 border border-orange-200 rounded p-2 text-xs text-orange-900">{area}</div>
                    ))}
                  </div>
                </div>
              )}

              {/* Closing encouragement */}
              {fb.closing_encouragement && (
                <div className="bg-purple-50 border border-purple-200 rounded p-2 text-xs text-purple-900">
                  <p className="font-medium mb-1">💪 Forward Momentum</p>
                  <p>{fb.closing_encouragement}</p>
                </div>
              )}
            </div>
          );
        })()}

        {results.observer_feedback && typeof results.observer_feedback === 'string' && (
          <div className="bg-muted/30 rounded p-3 text-xs text-foreground">
            {results.observer_feedback}
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
