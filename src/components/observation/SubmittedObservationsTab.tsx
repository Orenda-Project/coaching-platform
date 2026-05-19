import { useState } from 'react';
import { Card, CardContent } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import {
  User,
  MapPin,
  BookOpen,
  Calendar,
  CheckCircle2,
  Award,
  Eye,
  X,
} from 'lucide-react';
import { getProficiencyLevel } from '@/lib/observation-utils';
import { getFicoProficiency } from '@/lib/fico-utils';
import type { CotObservation } from '@/types/observation';

interface Props {
  observations: CotObservation[];
}

const STATUS_COLORS: Record<string, string> = {
  Submitted: 'text-green-700 border-green-200 bg-green-50',
  Approved: 'text-emerald-700 border-emerald-200 bg-emerald-50',
};

export function SubmittedObservationsTab({ observations }: Props) {
  const [selectedObs, setSelectedObs] = useState<CotObservation | null>(null);
  const submitted = observations.filter(o => o.status === 'Submitted' || o.status === 'Approved');

  if (submitted.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center py-14 text-center">
        <Award className="w-10 h-10 text-muted-foreground mb-3" />
        <h3 className="font-semibold text-foreground mb-1">No submitted observations yet</h3>
        <p className="text-sm text-muted-foreground">
          Complete observations appear here after submission
        </p>
      </div>
    );
  }

  return (
    <div className="space-y-5">
      <div>
        <h2 className="font-display text-lg font-semibold text-foreground">Submitted Observations</h2>
        <p className="text-sm text-muted-foreground">
          {submitted.length} observation{submitted.length !== 1 ? 's' : ''} completed
        </p>
      </div>

      <div className="space-y-3">
        {submitted.map(obs => {
          const isFico = obs.framework === 'FICO';
          const proficiency = obs.total_score > 0
            ? isFico
              ? getFicoProficiency(obs.total_score)
              : getProficiencyLevel(obs.total_score)
            : null;

          return (
            <Card key={obs.id} className="glass-card">
              <CardContent className="p-4">
                <div className="flex items-start justify-between gap-4">
                  <div className="flex-1 space-y-2">
                    {/* Status + date row */}
                    <div className="flex items-center gap-2 flex-wrap">
                      <Badge
                        variant="outline"
                        className={`text-xs ${STATUS_COLORS[obs.status]}`}
                      >
                        <CheckCircle2 className="w-3 h-3 mr-1" /> {obs.status}
                      </Badge>
                      <span className="text-xs text-muted-foreground">
                        {new Date(obs.submitted_at || obs.created_at).toLocaleDateString('en-US', {
                          month: 'short',
                          day: 'numeric',
                          year: 'numeric',
                        })}
                      </span>
                    </div>

                    {/* Details grid */}
                    <div className="grid grid-cols-2 gap-x-4 gap-y-1 text-sm">
                      <div className="flex items-center gap-1.5">
                        <User className="w-3.5 h-3.5 text-muted-foreground shrink-0" />
                        <span className="font-medium text-foreground truncate">
                          {obs.teacher_name}
                        </span>
                      </div>
                      <div className="flex items-center gap-1.5 text-muted-foreground">
                        <MapPin className="w-3.5 h-3.5 shrink-0" />
                        <span className="truncate">{obs.school_name}</span>
                      </div>
                      <div className="flex items-center gap-1.5 text-muted-foreground">
                        <BookOpen className="w-3.5 h-3.5 shrink-0" />
                        <span>
                          {obs.subject} · {obs.grade}
                        </span>
                      </div>
                      {obs.topic && (
                        <div className="text-xs text-muted-foreground col-span-2">
                          Topic: {obs.topic}
                        </div>
                      )}
                    </div>
                  </div>

                  <div className="flex flex-col items-end gap-3 shrink-0">
                    {/* Score badge */}
                    {proficiency && (
                      <div className="text-right">
                        <div className={`text-2xl font-bold ${proficiency.color}`}>
                          {obs.total_score}/{isFico ? '100' : '80'}
                        </div>
                        <div className={`text-xs font-medium ${proficiency.color}`}>
                          {proficiency.level}
                        </div>
                      </div>
                    )}
                    {/* Review button */}
                    <Button
                      size="sm"
                      variant="outline"
                      onClick={() => setSelectedObs(obs)}
                      className="gap-1.5"
                    >
                      <Eye className="w-3.5 h-3.5" />
                      Review
                    </Button>
                  </div>
                </div>
              </CardContent>
            </Card>
          );
        })}
      </div>

      {/* Review Modal */}
      {selectedObs && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-end sm:items-center justify-center p-4">
          <Card className="w-full max-w-2xl max-h-[90vh] overflow-y-auto">
            <CardContent className="p-6">
              {/* Header */}
              <div className="flex items-start justify-between mb-6">
                <div>
                  <h2 className="text-lg font-semibold text-foreground">Observation Details</h2>
                  <p className="text-sm text-muted-foreground mt-1">
                    {new Date(selectedObs.submitted_at || selectedObs.created_at).toLocaleDateString('en-US', {
                      month: 'long',
                      day: 'numeric',
                      year: 'numeric',
                    })}
                  </p>
                </div>
                <button
                  onClick={() => setSelectedObs(null)}
                  className="p-1 hover:bg-muted rounded-md transition-colors"
                >
                  <X className="w-5 h-5 text-muted-foreground" />
                </button>
              </div>

              {/* Content */}
              <div className="space-y-6">
                {/* Teacher & School */}
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  <div>
                    <p className="text-xs font-medium text-muted-foreground mb-1">Teacher</p>
                    <p className="text-sm font-medium text-foreground">{selectedObs.teacher_name}</p>
                  </div>
                  <div>
                    <p className="text-xs font-medium text-muted-foreground mb-1">School</p>
                    <p className="text-sm font-medium text-foreground">{selectedObs.school_name}</p>
                  </div>
                  <div>
                    <p className="text-xs font-medium text-muted-foreground mb-1">Subject</p>
                    <p className="text-sm text-foreground">{selectedObs.subject}</p>
                  </div>
                  <div>
                    <p className="text-xs font-medium text-muted-foreground mb-1">Grade</p>
                    <p className="text-sm text-foreground">{selectedObs.grade}</p>
                  </div>
                  {selectedObs.topic && (
                    <div className="sm:col-span-2">
                      <p className="text-xs font-medium text-muted-foreground mb-1">Topic</p>
                      <p className="text-sm text-foreground">{selectedObs.topic}</p>
                    </div>
                  )}
                </div>

                {/* Framework & Score */}
                <div className="border-t pt-4 space-y-3">
                  <div className="flex items-start justify-between">
                    <div>
                      <p className="text-xs font-medium text-muted-foreground mb-1">Framework</p>
                      <p className="text-sm font-medium text-foreground">{selectedObs.framework}</p>
                    </div>
                    <div className="text-right">
                      <p className="text-xs font-medium text-muted-foreground mb-1">Total Score</p>
                      <p className="text-2xl font-bold text-foreground">
                        {selectedObs.neo_results?.overall_score ?? selectedObs.total_score}
                      </p>
                    </div>
                  </div>
                </div>

                {/* Status */}
                <div className="border-t pt-4">
                  <Badge
                    variant="outline"
                    className={`text-xs ${STATUS_COLORS[selectedObs.status]}`}
                  >
                    <CheckCircle2 className="w-3 h-3 mr-1" /> {selectedObs.status}
                  </Badge>
                </div>

                {/* Neo Feedback */}
                {selectedObs.neo_results && selectedObs.neo_results.observer_feedback && (
                  <div className="border-t pt-4 space-y-3">
                    <h3 className="text-sm font-semibold text-foreground">Neo Coaching Feedback</h3>

                    {typeof selectedObs.neo_results.observer_feedback === 'object' && selectedObs.neo_results.observer_feedback !== null && (
                      <>
                        {(selectedObs.neo_results.observer_feedback as Record<string, unknown>).strengths && (
                          <div className="space-y-2">
                            <p className="text-xs font-medium text-green-700">Strengths</p>
                            <div className="space-y-1.5">
                              {(((selectedObs.neo_results.observer_feedback as Record<string, unknown>).strengths as string[]) || []).map((strength: string, idx: number) => (
                                <div key={idx} className="bg-green-50 border border-green-200 rounded p-2 text-xs text-green-900">
                                  {strength}
                                </div>
                              ))}
                            </div>
                          </div>
                        )}

                        {(selectedObs.neo_results.observer_feedback as Record<string, unknown>).next_steps && (
                          <div className="space-y-2">
                            <p className="text-xs font-medium text-blue-700">Next Steps for Growth</p>
                            <div className="space-y-1.5">
                              {(((selectedObs.neo_results.observer_feedback as Record<string, unknown>).next_steps as Record<string, unknown>[]) || []).map((step: Record<string, unknown>, idx: number) => (
                                <div key={idx} className="bg-blue-50 border border-blue-200 rounded p-2 text-xs text-blue-900">
                                  <p className="font-medium">{step.growth_area}</p>
                                  <p className="text-xs mt-1">{step.specific_behavior}</p>
                                </div>
                              ))}
                            </div>
                          </div>
                        )}
                      </>
                    )}
                  </div>
                )}

                {/* Close Button */}
                <div className="border-t pt-4">
                  <Button
                    onClick={() => setSelectedObs(null)}
                    variant="outline"
                    className="w-full"
                  >
                    Close
                  </Button>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      )}
    </div>
  );
}
