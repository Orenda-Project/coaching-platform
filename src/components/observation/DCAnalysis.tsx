/* eslint-disable @typescript-eslint/no-explicit-any */
import { useState, useEffect, useRef, useCallback } from 'react';
import { supabase } from '@/integrations/supabase/client';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Card, CardContent } from '@/components/ui/card';
import { toast } from 'sonner';
import {
  Mic, MicOff, Upload, Cpu, CheckCircle, XCircle,
  RefreshCw, ChevronDown, ChevronRight, Loader2,
} from 'lucide-react';
import { scoreBadgeClass, scoreLabel, dcResultsSections } from '@/lib/dc-utils';
import type { CotObservation, DcResults } from '@/types/observation';

interface Props {
  observation: CotObservation;
  onSaved: (updated: CotObservation) => void;
}

type Phase = 'idle' | 'recording' | 'uploading' | 'dispatching' | 'processing' | 'completed' | 'failed';

interface DcAnalysisRow {
  id: string;
  observation_id: string;
  task_id: string;
  status: 'processing' | 'completed' | 'failed';
  progress: number;
  current_step: string | null;
  message: string | null;
  error: string | null;
  results: DcResults | null;
}

const BAR_HEIGHTS = [28, 36, 22, 40, 26];

function RecordingWaveform() {
  return (
    <div className="flex items-end gap-1 h-10">
      {BAR_HEIGHTS.map((h, i) => (
        <div
          key={i}
          className="w-1.5 bg-primary rounded-full animate-bounce"
          style={{ height: h, animationDelay: `${i * 0.1}s` }}
        />
      ))}
    </div>
  );
}

function formatTime(s: number) {
  return `${Math.floor(s / 60).toString().padStart(2, '0')}:${(s % 60).toString().padStart(2, '0')}`;
}

// ── Results display ───────────────────────────────────────────────────────────

function ResultsView({ results }: { results: DcResults }) {
  const sections = dcResultsSections(results);
  const [openSections, setOpenSections] = useState<Set<string>>(new Set(sections.map(s => s.key)));

  const toggle = (key: string) => {
    setOpenSections(prev => {
      const next = new Set(prev);
      if (next.has(key)) { next.delete(key); } else { next.add(key); }
      return next;
    });
  };

  if (sections.length === 0) {
    return <p className="text-sm text-muted-foreground">No results data available.</p>;
  }

  return (
    <div className="space-y-3">
      {sections.map(({ key, label, section }) => {
        const isOpen = openSections.has(key);
        const indicatorCodes = Object.keys(section.scores ?? {});

        return (
          <Card key={key} className="glass-card overflow-hidden">
            <button
              type="button"
              className="w-full text-left"
              onClick={() => toggle(key)}
            >
              <CardContent className="p-3 flex items-center justify-between gap-2">
                <p className="text-sm font-semibold text-foreground">{label}</p>
                {isOpen
                  ? <ChevronDown className="w-4 h-4 text-muted-foreground shrink-0" />
                  : <ChevronRight className="w-4 h-4 text-muted-foreground shrink-0" />
                }
              </CardContent>
            </button>

            {isOpen && (
              <div className="border-t border-border px-3 pb-3">
                {/* Indicator scores */}
                <div className="space-y-2 mt-3">
                  {indicatorCodes.map(code => {
                    const score = section.scores[code];
                    const detail = section.indicator_details?.[code];
                    return (
                      <div key={code} className="flex items-start gap-2">
                        <span className="font-mono text-xs text-muted-foreground mt-0.5 shrink-0 w-10">{code}</span>
                        <p className="flex-1 text-xs text-foreground leading-relaxed">
                          {detail?.full_statement || code}
                        </p>
                        <span className={`text-xs px-2 py-0.5 rounded border font-medium shrink-0 ${scoreBadgeClass(score)}`}>
                          {scoreLabel(score)}
                        </span>
                      </div>
                    );
                  })}
                </div>

                {/* Feedback */}
                {section.feedback?.english && (
                  <div className="mt-3 pt-3 border-t border-border">
                    <p className="text-xs font-medium text-foreground mb-1">DC Feedback</p>
                    <p className="text-xs text-muted-foreground leading-relaxed">{section.feedback.english}</p>
                  </div>
                )}
              </div>
            )}
          </Card>
        );
      })}
    </div>
  );
}

// ── Main component ────────────────────────────────────────────────────────────

export function DCAnalysis({ observation, onSaved }: Props) {
  // Initialise phase from existing dc_status
  const initPhase = (): Phase => {
    if (observation.dc_status === 'completed') return 'completed';
    if (observation.dc_status === 'failed') return 'failed';
    if (observation.dc_status === 'processing') return 'processing';
    return 'idle';
  };

  const [phase, setPhase] = useState<Phase>(initPhase);
  const [elapsed, setElapsed] = useState(0);
  const [uploadPct, setUploadPct] = useState(0);
  const [progress, setProgress] = useState(0);
  const [currentStep, setCurrentStep] = useState('');
  const [results, setResults] = useState<DcResults | null>(observation.dc_results ?? null);
  const [errorMsg, setErrorMsg] = useState(observation.dc_error ?? '');
  const [taskId, setTaskId] = useState(observation.dc_task_id ?? '');

  const mediaRecorderRef = useRef<MediaRecorder | null>(null);
  const chunksRef = useRef<Blob[]>([]);
  const audioBlobRef = useRef<Blob | null>(null);
  const s3KeyRef = useRef('');
  const presignedGetRef = useRef('');
  const fileInputRef = useRef<HTMLInputElement>(null);

  // ── Elapsed timer during recording ────────────────────────────────────────
  useEffect(() => {
    if (phase !== 'recording') return;
    setElapsed(0);
    const iv = setInterval(() => setElapsed(e => e + 1), 1000);
    return () => clearInterval(iv);
  }, [phase]);

  // ── Realtime subscription ─────────────────────────────────────────────────
  useEffect(() => {
    if (phase !== 'processing' || !observation.id) return;

    const channel = supabase
      .channel(`dc-${observation.id}`)
      .on(
        'postgres_changes' as any,
        {
          event: 'UPDATE',
          schema: 'public',
          table: 'dc_analyses',
          filter: `observation_id=eq.${observation.id}`,
        },
        (payload: any) => {
          const row = payload.new as DcAnalysisRow;
          setProgress(row.progress ?? 0);
          setCurrentStep(row.current_step ?? '');
          if (row.status === 'completed') {
            setResults(row.results);
            setPhase('completed');
            // Refresh parent observation
            supabase.from('cot_observations' as any)
              .select('*')
              .eq('id', observation.id)
              .single()
              .then(({ data }) => { if (data) onSaved(data as CotObservation); });
          } else if (row.status === 'failed') {
            setErrorMsg(row.error ?? 'Analysis failed');
            setPhase('failed');
          }
        },
      )
      .subscribe();

    // Polling fallback — fires every 8s in case Realtime misses an update
    const poll = setInterval(async () => {
      const { data } = await (supabase as any)
        .from('dc_analyses')
        .select('*')
        .eq('observation_id', observation.id)
        .single();
      if (!data) return;
      setProgress(data.progress ?? 0);
      setCurrentStep(data.current_step ?? '');
      if (data.status === 'completed') {
        setResults(data.results);
        setPhase('completed');
        clearInterval(poll);
        const { data: obs } = await (supabase as any)
          .from('cot_observations')
          .select('*')
          .eq('id', observation.id)
          .single();
        if (obs) onSaved(obs as CotObservation);
      } else if (data.status === 'failed') {
        setErrorMsg(data.error ?? 'Analysis failed');
        setPhase('failed');
        clearInterval(poll);
      }
    }, 8000);

    return () => {
      supabase.removeChannel(channel);
      clearInterval(poll);
    };
  }, [phase, observation.id]);

  // ── Recording ─────────────────────────────────────────────────────────────
  const startRecording = useCallback(async () => {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      const mimeType = MediaRecorder.isTypeSupported('audio/webm;codecs=opus')
        ? 'audio/webm;codecs=opus'
        : 'audio/mp4';

      const recorder = new MediaRecorder(stream, { mimeType });
      chunksRef.current = [];
      recorder.ondataavailable = e => { if (e.data.size > 0) chunksRef.current.push(e.data); };
      recorder.onstop = () => {
        audioBlobRef.current = new Blob(chunksRef.current, { type: mimeType });
        stream.getTracks().forEach(t => t.stop());
        uploadAudio(mimeType);
      };
      recorder.start();
      mediaRecorderRef.current = recorder;
      setPhase('recording');
    } catch (err: any) {
      toast.error('Microphone access denied. Please allow microphone access and try again.');
    }
  }, [observation.id]);

  const stopRecording = useCallback(() => {
    mediaRecorderRef.current?.stop();
  }, []);

  // ── Upload to S3 ──────────────────────────────────────────────────────────
  const uploadAudio = useCallback(async (mimeType: string) => {
    setPhase('uploading');
    setUploadPct(0);

    try {
      // Get pre-signed URLs from edge function
      const { data: presignData, error: presignErr } = await supabase.functions.invoke('dc-presign', {
        body: { observation_id: observation.id, mime_type: mimeType },
      });
      if (presignErr || !presignData?.presigned_put_url) {
        throw new Error(presignErr?.message || 'Failed to get upload URL');
      }

      s3KeyRef.current = presignData.s3_key;
      presignedGetRef.current = presignData.presigned_get_url;

      // Upload directly to S3 — no edge function in the middle
      setUploadPct(20);
      const uploadResp = await fetch(presignData.presigned_put_url, {
        method: 'PUT',
        body: audioBlobRef.current,
        headers: { 'Content-Type': mimeType },
      });

      if (!uploadResp.ok) {
        throw new Error(`S3 upload failed: ${uploadResp.status}`);
      }

      setUploadPct(100);
      dispatchToDC();
    } catch (err: any) {
      console.error('Upload error:', err);
      setErrorMsg(err.message || 'Upload failed');
      setPhase('failed');
    }
  }, [observation.id]);

  // ── Dispatch to DC ────────────────────────────────────────────────────────
  const dispatchToDC = useCallback(async () => {
    setPhase('dispatching');

    try {
      const { data, error } = await supabase.functions.invoke('dc-start', {
        body: {
          observation_id: observation.id,
          s3_key: s3KeyRef.current,
          presigned_get_url: presignedGetRef.current,
          lesson_plan_text: observation.topic || '',
        },
      });

      if (error || !data?.ok) {
        throw new Error(error?.message || data?.error || 'DC dispatch failed');
      }

      setTaskId(data.dc_task_id);
      setProgress(0);
      setCurrentStep('');
      setPhase('processing');
    } catch (err: any) {
      console.error('DC dispatch error:', err);
      setErrorMsg(err.message || 'Failed to start DC analysis');
      setPhase('failed');
    }
  }, [observation.id, observation.topic]);

  // ── File upload (alternative to recording) ────────────────────────────────
  const handleFileUpload = useCallback((e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    const mimeType = file.type || 'audio/webm';
    audioBlobRef.current = file;
    uploadAudio(mimeType);
    e.target.value = '';
  }, [uploadAudio]);

  const retry = () => {
    setErrorMsg('');
    setPhase('idle');
  };

  // ── Idle ──────────────────────────────────────────────────────────────────
  if (phase === 'idle') {
    return (
      <div className="flex flex-col items-center justify-center py-10 text-center gap-4">
        <input
          ref={fileInputRef}
          type="file"
          accept="audio/*"
          className="hidden"
          onChange={handleFileUpload}
        />
        <div className="w-14 h-14 rounded-full bg-primary/10 flex items-center justify-center">
          <Mic className="w-7 h-7 text-primary" />
        </div>
        <div>
          <p className="text-sm font-semibold text-foreground">Analyze with Digital Coach</p>
          <p className="text-xs text-muted-foreground mt-1 max-w-xs">
            Record the classroom session live, or upload a pre-recorded audio file. DC will evaluate it and provide indicator scores.
          </p>
        </div>
        <div className="flex gap-3">
          <Button onClick={startRecording} className="gap-2">
            <Mic className="w-4 h-4" /> Record
          </Button>
          <Button variant="outline" onClick={() => fileInputRef.current?.click()} className="gap-2">
            <Upload className="w-4 h-4" /> Upload Audio
          </Button>
        </div>
      </div>
    );
  }

  // ── Recording ─────────────────────────────────────────────────────────────
  if (phase === 'recording') {
    return (
      <div className="flex flex-col items-center justify-center py-10 text-center gap-5">
        <RecordingWaveform />
        <div>
          <div className="text-2xl font-bold font-mono text-foreground">{formatTime(elapsed)}</div>
          <p className="text-xs text-muted-foreground mt-1">Recording in progress…</p>
        </div>
        <Button variant="destructive" onClick={stopRecording} className="gap-2">
          <MicOff className="w-4 h-4" /> Stop & Analyze
        </Button>
      </div>
    );
  }

  // ── Uploading ─────────────────────────────────────────────────────────────
  if (phase === 'uploading') {
    return (
      <div className="flex flex-col items-center justify-center py-10 text-center gap-4">
        <Upload className="w-8 h-8 text-primary animate-pulse" />
        <div>
          <p className="text-sm font-semibold text-foreground">Uploading audio…</p>
          <p className="text-xs text-muted-foreground mt-1">{uploadPct}% complete</p>
        </div>
        <div className="w-48 h-1.5 bg-muted rounded-full overflow-hidden">
          <div className="h-full bg-primary rounded-full transition-all" style={{ width: `${uploadPct}%` }} />
        </div>
      </div>
    );
  }

  // ── Dispatching ───────────────────────────────────────────────────────────
  if (phase === 'dispatching') {
    return (
      <div className="flex flex-col items-center justify-center py-10 text-center gap-4">
        <Loader2 className="w-8 h-8 text-primary animate-spin" />
        <p className="text-sm font-semibold text-foreground">Sending to Digital Coach…</p>
      </div>
    );
  }

  // ── Processing ────────────────────────────────────────────────────────────
  if (phase === 'processing') {
    return (
      <div className="flex flex-col items-center justify-center py-10 text-center gap-4">
        <div className="w-14 h-14 rounded-full bg-primary/10 flex items-center justify-center">
          <Cpu className="w-7 h-7 text-primary animate-pulse" />
        </div>
        <div>
          <p className="text-sm font-semibold text-foreground">DC is analysing the session…</p>
          <p className="text-xs text-muted-foreground mt-1">
            {currentStep || 'Processing audio against FICO framework'}
          </p>
        </div>
        <div className="w-56 space-y-1">
          <div className="h-1.5 bg-muted rounded-full overflow-hidden">
            <div
              className="h-full bg-primary rounded-full transition-all duration-500"
              style={{ width: `${progress}%` }}
            />
          </div>
          <p className="text-xs text-muted-foreground text-right">{progress}%</p>
        </div>
        <p className="text-xs text-muted-foreground">You can close this tab — results will appear when ready.</p>
      </div>
    );
  }

  // ── Failed ────────────────────────────────────────────────────────────────
  if (phase === 'failed') {
    return (
      <div className="flex flex-col items-center justify-center py-10 text-center gap-4">
        <XCircle className="w-10 h-10 text-red-500" />
        <div>
          <p className="text-sm font-semibold text-foreground">Analysis failed</p>
          <p className="text-xs text-muted-foreground mt-1 max-w-xs">{errorMsg || 'Something went wrong.'}</p>
        </div>
        <Button variant="outline" onClick={retry} className="gap-2">
          <RefreshCw className="w-4 h-4" /> Try Again
        </Button>
      </div>
    );
  }

  // ── Completed ─────────────────────────────────────────────────────────────
  return (
    <div className="space-y-4">
      <div className="flex items-center gap-2">
        <CheckCircle className="w-5 h-5 text-green-600 shrink-0" />
        <div>
          <p className="text-sm font-semibold text-foreground">DC Analysis Complete</p>
          <p className="text-xs text-muted-foreground">FICO framework evaluation by Digital Coach</p>
        </div>
        <Badge variant="outline" className="ml-auto text-xs text-green-700 border-green-300 bg-green-50">
          Completed
        </Badge>
      </div>

      {results ? (
        <ResultsView results={results} />
      ) : (
        <p className="text-sm text-muted-foreground">Results not available.</p>
      )}
    </div>
  );
}
