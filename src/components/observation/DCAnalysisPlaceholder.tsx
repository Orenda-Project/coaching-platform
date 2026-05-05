import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Cpu, Video, Brain, CheckCircle, Clock } from 'lucide-react';
import type { CotObservation } from '@/types/observation';

interface Props {
  observation: CotObservation;
}

const FRAMEWORKS = [
  {
    name: 'HOTS Framework',
    description: 'Higher Order Thinking Skills — evaluating depth of learning',
    color: 'blue',
    indicators: [
      'Critical Analysis & Synthesis',
      "Bloom's Taxonomy Levels",
      'Open-ended Questioning',
      'Student Reasoning Quality',
    ],
  },
  {
    name: 'FICO Framework',
    description: 'Facilitation & Instructional Coaching Observation',
    color: 'purple',
    indicators: [
      'Instructional Clarity',
      'Feedback Quality',
      'Coaching Interactions',
      'Learning Facilitation',
    ],
  },
];

export function DCAnalysisPlaceholder({ observation }: Props) {
  return (
    <div className="space-y-5">
      {/* DC Header */}
      <div className="flex items-start gap-3 p-4 bg-gradient-to-r from-indigo-50 to-purple-50 rounded-lg border border-indigo-100">
        <div className="w-10 h-10 rounded-full bg-indigo-100 flex items-center justify-center shrink-0 mt-0.5">
          <Cpu className="w-5 h-5 text-indigo-600" />
        </div>
        <div>
          <div className="flex items-center gap-2 flex-wrap">
            <h3 className="font-semibold text-foreground">Digital Coach (DC) Analysis</h3>
            <Badge variant="outline" className="text-xs text-amber-600 border-amber-200 bg-amber-50">
              <Clock className="w-3 h-3 mr-1" /> Coming Next
            </Badge>
          </div>
          <p className="text-sm text-muted-foreground mt-1">
            DC will automatically evaluate your recorded classroom session against HOTS and FICO
            framework indicators — giving you an AI-powered coaching report.
          </p>
        </div>
      </div>

      {/* Record Session Placeholder */}
      <div className="flex flex-col items-center justify-center py-8 border-2 border-dashed border-muted-foreground/20 rounded-lg text-center">
        <div className="w-12 h-12 rounded-full bg-muted flex items-center justify-center mb-3">
          <Video className="w-6 h-6 text-muted-foreground" />
        </div>
        <h4 className="font-medium text-foreground mb-1">Record Classroom Session</h4>
        <p className="text-sm text-muted-foreground mb-4 max-w-xs">
          Record the classroom observation session for AI-powered analysis by Digital Coach
        </p>
        <Button variant="outline" disabled>
          <Video className="w-4 h-4 mr-2" />
          Record &amp; Analyze (DC Integration)
        </Button>
        <p className="text-xs text-muted-foreground mt-2">
          DC integration will be enabled in the next release
        </p>
      </div>

      {/* Framework Indicators Preview */}
      <div className="space-y-3">
        <div className="flex items-center gap-2">
          <Brain className="w-4 h-4 text-muted-foreground" />
          <h4 className="text-sm font-medium text-foreground">
            DC will evaluate against these frameworks:
          </h4>
        </div>

        {FRAMEWORKS.map(fw => (
          <Card key={fw.name} className="glass-card">
            <CardContent className="p-3">
              <div className="flex items-start justify-between mb-2">
                <div>
                  <p className={`text-sm font-semibold text-${fw.color}-700`}>{fw.name}</p>
                  <p className="text-xs text-muted-foreground">{fw.description}</p>
                </div>
                <Badge
                  variant="outline"
                  className={`text-xs shrink-0 ml-2 text-${fw.color}-600 border-${fw.color}-200 bg-${fw.color}-50`}
                >
                  Auto-scored
                </Badge>
              </div>
              <div className="grid grid-cols-2 gap-1">
                {fw.indicators.map(ind => (
                  <div key={ind} className="flex items-center gap-1.5 text-xs text-muted-foreground">
                    <CheckCircle className="w-3 h-3 text-muted-foreground/40 shrink-0" />
                    {ind}
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
}
