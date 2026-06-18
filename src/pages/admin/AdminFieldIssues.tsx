import { useState, useEffect } from 'react';
import { adminApiClient } from '@/lib/apiClients/adminApiClient';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { AlertCircle, CheckCircle2, Clock } from 'lucide-react';

interface FieldIssue {
  id: string;
  coach_name: string;
  sub_region: string;
  issue_type: string;
  description: string;
  status: 'open' | 'in_progress' | 'resolved';
  created_at: string;
  resolved_at: string | null;
}

export default function AdminFieldIssues() {
  const [issues, setIssues] = useState<FieldIssue[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadIssues();
  }, []);

  const loadIssues = async () => {
    try {
      const result = await adminApiClient.listFieldIssues();
      // The API returns { issues: [...] } or { data: [...] } depending on mapping
      // Handle both shapes for resilience
      const raw = result as unknown as Record<string, unknown>;
      const items = (raw.issues || raw.data || []) as unknown as FieldIssue[];
      setIssues(items);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const updateStatus = async (id: string, newStatus: string) => {
    try {
      await adminApiClient.updateFieldIssue(id, {
        status: newStatus as 'open' | 'in_progress' | 'resolved' | 'closed',
      });
      setIssues(issues.map(issue => issue.id === id ? { ...issue, status: newStatus as FieldIssue['status'] } : issue));
    } catch (err) {
      console.error(err);
    }
  };

  const getIssueTypeLabel = (type: string) => {
    const labels: Record<string, string> = {
      app_bug: 'App Bug',
      data_issue: 'Data Issue',
      connectivity: 'Connectivity',
      other: 'Other',
    };
    return labels[type] || type;
  };

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'open':
        return <AlertCircle className="w-4 h-4 text-red-600" />;
      case 'in_progress':
        return <Clock className="w-4 h-4 text-yellow-600" />;
      case 'resolved':
        return <CheckCircle2 className="w-4 h-4 text-green-600" />;
      default:
        return null;
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'open':
        return 'bg-red-50 border-red-200';
      case 'in_progress':
        return 'bg-yellow-50 border-yellow-200';
      case 'resolved':
        return 'bg-green-50 border-green-200';
      default:
        return 'bg-gray-50 border-gray-200';
    }
  };

  if (loading) {
    return (
      <div className="flex justify-center py-12">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Field Issues</h1>
        <p className="text-muted-foreground mt-1">Real-time issues reported by coaches from the field</p>
      </div>

      {issues.length === 0 ? (
        <Card>
          <CardContent className="flex flex-col items-center justify-center py-12 text-center">
            <CheckCircle2 className="w-10 h-10 text-green-600 mb-3" />
            <h3 className="font-semibold text-foreground mb-1">No issues reported</h3>
            <p className="text-sm text-muted-foreground">All clear! Coaches haven't reported any issues yet.</p>
          </CardContent>
        </Card>
      ) : (
        <div className="space-y-3">
          {issues.map((issue) => (
            <Card key={issue.id} className={`border ${getStatusColor(issue.status)}`}>
              <CardContent className="pt-6">
                <div className="space-y-3">
                  <div className="flex items-start justify-between gap-4">
                    <div className="flex-1">
                      <div className="flex items-center gap-2 mb-2">
                        {getStatusIcon(issue.status)}
                        <h3 className="font-semibold text-foreground">{issue.coach_name}</h3>
                        <Badge variant="outline">{getIssueTypeLabel(issue.issue_type)}</Badge>
                      </div>
                      <p className="text-sm text-muted-foreground mb-2">
                        Sub-region: <span className="font-medium">{issue.sub_region}</span>
                      </p>
                      <p className="text-sm text-foreground">{issue.description}</p>
                      <p className="text-xs text-muted-foreground mt-2">
                        Reported: {new Date(issue.created_at).toLocaleString()}
                      </p>
                    </div>

                    <div className="flex gap-2 shrink-0">
                      {issue.status !== 'in_progress' && (
                        <Button
                          size="sm"
                          variant="outline"
                          onClick={() => updateStatus(issue.id, 'in_progress')}
                        >
                          In Progress
                        </Button>
                      )}
                      {issue.status !== 'resolved' && (
                        <Button
                          size="sm"
                          onClick={() => updateStatus(issue.id, 'resolved')}
                        >
                          Resolve
                        </Button>
                      )}
                    </div>
                  </div>
                  <div className="text-xs text-muted-foreground">
                    Status: <span className="font-medium capitalize">{issue.status}</span>
                  </div>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
