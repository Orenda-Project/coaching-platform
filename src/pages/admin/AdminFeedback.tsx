import { useEffect, useState } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { ChevronLeft, ChevronRight } from 'lucide-react';
import { toast } from '@/components/ui/sonner';
import { createClient } from '@supabase/supabase-js';

interface FeedbackRecord {
  id: string;
  user_id: string;
  category: 'module' | 'platform' | 'bug' | 'other';
  rating: number;
  positive_feedback?: string;
  improvement_feedback?: string;
  context_page: string;
  persona?: string;
  created_at: string;
  profiles?: {
    full_name?: string;
    email?: string;
  };
}

interface KPIData {
  totalFeedback: number;
  avgRating: number;
  lowRatingCount: number;
}

const ITEMS_PER_PAGE = 20;

export default function AdminFeedback() {
  const [kpis, setKpis] = useState<KPIData | null>(null);
  const [feedback, setFeedback] = useState<FeedbackRecord[]>([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [totalCount, setTotalCount] = useState(0);

  const supabase = createClient(
    import.meta.env.VITE_SUPABASE_URL || '',
    import.meta.env.VITE_SUPABASE_PUBLISHABLE_KEY || ''
  );

  useEffect(() => {
    fetchData();
  }, [page]);

  const fetchData = async () => {
    try {
      setLoading(true);

      // Fetch all feedback for KPIs (30 days)
      const thirtyDaysAgo = new Date();
      thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

      const { data: allFeedback, error: allError } = await supabase
        .from('feedback')
        .select('rating', { count: 'exact' })
        .gte('created_at', thirtyDaysAgo.toISOString());

      if (allError) throw allError;

      // Calculate KPIs
      const totalFeedback = allFeedback?.length || 0;
      const avgRating =
        totalFeedback > 0
          ? (allFeedback!.reduce((sum, f) => sum + f.rating, 0) / totalFeedback)
          : 0;
      const lowRatingCount = allFeedback?.filter((f) => f.rating <= 2).length || 0;

      setKpis({
        totalFeedback,
        avgRating: Math.round(avgRating * 10) / 10,
        lowRatingCount,
      });

      // Fetch paginated feedback with user profiles
      const offset = (page - 1) * ITEMS_PER_PAGE;
      const { data: paginatedFeedback, count, error } = await supabase
        .from('feedback')
        .select('*, profiles(full_name, email)', { count: 'exact' })
        .order('created_at', { ascending: false })
        .range(offset, offset + ITEMS_PER_PAGE - 1);

      if (error) throw error;

      setFeedback(paginatedFeedback || []);
      setTotalCount(count || 0);
    } catch (err) {
      console.error('Error fetching feedback:', err);
      toast.error('Failed to load feedback');
    } finally {
      setLoading(false);
    }
  };

  const totalPages = Math.ceil(totalCount / ITEMS_PER_PAGE);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-foreground">Feedback</h1>
        <p className="text-muted-foreground mt-1">Coach feedback and ratings (30 days)</p>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <Card>
          <CardHeader>
            <CardTitle className="text-sm font-medium text-muted-foreground">Total Feedback</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold text-foreground">
              {kpis?.totalFeedback ?? '-'}
            </div>
            <p className="text-xs text-muted-foreground mt-1">Last 30 days</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="text-sm font-medium text-muted-foreground">Avg Rating</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold text-foreground">
              {kpis?.avgRating ?? '-'}
            </div>
            <p className="text-xs text-muted-foreground mt-1">Out of 5</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="text-sm font-medium text-muted-foreground">Low Ratings</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold text-destructive">
              {kpis?.lowRatingCount ?? '-'}
            </div>
            <p className="text-xs text-muted-foreground mt-1">Rating ≤ 2</p>
          </CardContent>
        </Card>
      </div>

      {/* Feedback Table */}
      <Card>
        <CardHeader>
          <CardTitle>Feedback Entries</CardTitle>
          <CardDescription>
            Page {page} of {totalPages} • {totalCount} total
          </CardDescription>
        </CardHeader>
        <CardContent>
          {loading ? (
            <div className="flex justify-center py-8">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary" />
            </div>
          ) : feedback.length === 0 ? (
            <p className="text-center py-8 text-muted-foreground">No feedback yet</p>
          ) : (
            <>
              <div className="overflow-x-auto">
                <table className="w-full text-sm">
                  <thead>
                    <tr className="border-b border-border">
                      <th className="text-left py-3 px-4 font-medium text-muted-foreground">
                        Coach
                      </th>
                      <th className="text-left py-3 px-4 font-medium text-muted-foreground">
                        Category
                      </th>
                      <th className="text-left py-3 px-4 font-medium text-muted-foreground">
                        Rating
                      </th>
                      <th className="text-left py-3 px-4 font-medium text-muted-foreground">
                        Feedback
                      </th>
                      <th className="text-left py-3 px-4 font-medium text-muted-foreground">
                        Date
                      </th>
                    </tr>
                  </thead>
                  <tbody>
                    {feedback.map((item) => (
                      <tr key={item.id} className="border-b border-border hover:bg-accent/50">
                        <td className="py-3 px-4">
                          <div className="text-sm font-medium">
                            {item.profiles?.full_name || 'Unknown'}
                          </div>
                          <div className="text-xs text-muted-foreground">
                            {item.profiles?.email || item.user_id.slice(0, 8)}
                          </div>
                        </td>
                        <td className="py-3 px-4">
                          <span className="inline-block px-2 py-1 rounded bg-accent text-accent-foreground text-xs font-medium capitalize">
                            {item.category}
                          </span>
                        </td>
                        <td className="py-3 px-4">
                          <span className="font-medium">{'★'.repeat(item.rating)}{'☆'.repeat(5 - item.rating)}</span>
                        </td>
                        <td className="py-3 px-4">
                          <div className="text-xs space-y-1">
                            {item.positive_feedback && (
                              <div>
                                <span className="font-medium text-green-600">Positive:</span>{' '}
                                {item.positive_feedback.slice(0, 50)}
                                {item.positive_feedback.length > 50 ? '...' : ''}
                              </div>
                            )}
                            {item.improvement_feedback && (
                              <div>
                                <span className="font-medium text-amber-600">Improvement:</span>{' '}
                                {item.improvement_feedback.slice(0, 50)}
                                {item.improvement_feedback.length > 50 ? '...' : ''}
                              </div>
                            )}
                            {!item.positive_feedback && !item.improvement_feedback && (
                              <span className="text-muted-foreground">(No text feedback)</span>
                            )}
                          </div>
                        </td>
                        <td className="py-3 px-4 text-xs text-muted-foreground">
                          {new Date(item.created_at).toLocaleDateString()}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>

              {/* Pagination */}
              {totalPages > 1 && (
                <div className="flex items-center justify-between mt-6">
                  <p className="text-xs text-muted-foreground">
                    Showing {(page - 1) * ITEMS_PER_PAGE + 1} to{' '}
                    {Math.min(page * ITEMS_PER_PAGE, totalCount)} of {totalCount}
                  </p>
                  <div className="flex gap-2">
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => setPage(Math.max(1, page - 1))}
                      disabled={page === 1}
                    >
                      <ChevronLeft className="w-4 h-4" />
                    </Button>
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => setPage(Math.min(totalPages, page + 1))}
                      disabled={page === totalPages}
                    >
                      <ChevronRight className="w-4 h-4" />
                    </Button>
                  </div>
                </div>
              )}
            </>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
