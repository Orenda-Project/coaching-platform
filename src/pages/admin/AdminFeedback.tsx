import { useCallback, useEffect, useState } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { ChevronLeft, ChevronRight, Download, X } from 'lucide-react';
import { toast } from '@/components/ui/sonner';
import {
  fetchAdminFeedback,
  type FeedbackRecord,
  type FeedbackKPIs,
} from '@/lib/apiClients/adminFeedbackApiClient';
import { exportFeedbackToPdf } from '@/domain/feedback-pdf-export';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';

const ITEMS_PER_PAGE = 20;

export default function AdminFeedback() {
  const [feedbackData, setFeedbackData] = useState<FeedbackRecord[]>([]);
  const [kpis, setKpis] = useState<FeedbackKPIs | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [page, setPage] = useState(1);
  const [filters, setFilters] = useState({
    category: '',
    rating: '',
    persona: '',
    startDate: '',
    endDate: '',
  });
  const [selectedFeedback, setSelectedFeedback] = useState<FeedbackRecord | null>(null);
  const [generatingPdf, setGeneratingPdf] = useState(false);

  // Fetch from API whenever filters change
  const loadFeedback = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const result = await fetchAdminFeedback({
        // If date range is set, use it; otherwise default to last 30 days
        days: (!filters.startDate && !filters.endDate) ? 30 : 365,
        category: filters.category || undefined,
        rating: filters.rating ? parseInt(filters.rating) : undefined,
        persona: filters.persona || undefined,
        start_date: filters.startDate || undefined,
        end_date: filters.endDate || undefined,
      });
      setFeedbackData(result.items);
      setKpis(result.kpis);
    } catch (err) {
      const msg = err instanceof Error ? err.message : 'Failed to load feedback';
      setError(msg);
    } finally {
      setLoading(false);
    }
  }, [filters]);

  useEffect(() => {
    loadFeedback();
  }, [loadFeedback]);

  useEffect(() => {
    if (error) {
      toast.error('Failed to load feedback');
    }
  }, [error]);

  // Pagination (data already filtered by API)
  const totalCount = feedbackData.length;
  const totalPages = Math.ceil(totalCount / ITEMS_PER_PAGE);
  const offset = (page - 1) * ITEMS_PER_PAGE;
  const paginatedFeedback = feedbackData
    .sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime())
    .slice(offset, offset + ITEMS_PER_PAGE);

  useEffect(() => {
    setPage(1);
  }, [filters]);

  // Label for the subtitle
  const dateRangeLabel = filters.startDate || filters.endDate
    ? `${filters.startDate || '...'} to ${filters.endDate || 'now'}`
    : 'Last 30 days';

  const handleDownloadReport = async () => {
    setGeneratingPdf(true);
    try {
      await exportFeedbackToPdf(feedbackData, kpis, dateRangeLabel);
      toast.success('Report downloaded');
    } catch (err) {
      console.error('PDF generation failed:', err);
      toast.error('Failed to generate report');
    } finally {
      setGeneratingPdf(false);
    }
  };

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-foreground">Feedback</h1>
        <p className="text-muted-foreground mt-1">Coach feedback and ratings ({dateRangeLabel})</p>
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
            <p className="text-xs text-muted-foreground mt-1">{dateRangeLabel}</p>
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
            <p className="text-xs text-muted-foreground mt-1">Rating &le; 2</p>
          </CardContent>
        </Card>
      </div>

      {/* Filters */}
      <Card>
        <CardHeader>
          <CardTitle className="text-base">Filters</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-2 md:grid-cols-5 gap-3">
            <Select value={filters.category || 'all'} onValueChange={(val) => setFilters({ ...filters, category: val === 'all' ? '' : val })}>
              <SelectTrigger>
                <SelectValue placeholder="Category" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All categories</SelectItem>
                <SelectItem value="module">Module</SelectItem>
                <SelectItem value="platform">Platform</SelectItem>
                <SelectItem value="bug">Bug</SelectItem>
                <SelectItem value="other">Other</SelectItem>
              </SelectContent>
            </Select>

            <Select value={filters.rating || 'all'} onValueChange={(val) => setFilters({ ...filters, rating: val === 'all' ? '' : val })}>
              <SelectTrigger>
                <SelectValue placeholder="Rating" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All ratings</SelectItem>
                <SelectItem value="1">1 star</SelectItem>
                <SelectItem value="2">2 stars</SelectItem>
                <SelectItem value="3">3 stars</SelectItem>
                <SelectItem value="4">4 stars</SelectItem>
                <SelectItem value="5">5 stars</SelectItem>
              </SelectContent>
            </Select>

            <Select value={filters.persona || 'all'} onValueChange={(val) => setFilters({ ...filters, persona: val === 'all' ? '' : val })}>
              <SelectTrigger>
                <SelectValue placeholder="Persona" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All personas</SelectItem>
                <SelectItem value="A">A</SelectItem>
                <SelectItem value="B">B</SelectItem>
                <SelectItem value="C">C</SelectItem>
                <SelectItem value="D">D</SelectItem>
                <SelectItem value="E">E</SelectItem>
              </SelectContent>
            </Select>

            <input
              type="date"
              value={filters.startDate}
              onChange={(e) => setFilters({ ...filters, startDate: e.target.value })}
              className="px-3 py-2 border border-input rounded-md text-sm bg-background"
              placeholder="Start date"
            />

            <input
              type="date"
              value={filters.endDate}
              onChange={(e) => setFilters({ ...filters, endDate: e.target.value })}
              className="px-3 py-2 border border-input rounded-md text-sm bg-background"
              placeholder="End date"
            />
          </div>

          {(filters.category || filters.rating || filters.persona || filters.startDate || filters.endDate) && (
            <Button
              variant="outline"
              size="sm"
              onClick={() =>
                setFilters({ category: '', rating: '', persona: '', startDate: '', endDate: '' })
              }
              className="mt-4"
            >
              <X className="w-4 h-4 mr-2" /> Clear filters
            </Button>
          )}
        </CardContent>
      </Card>

      {/* Feedback Table */}
      <Card>
        <CardHeader className="flex flex-row items-start justify-between">
          <div>
            <CardTitle>Feedback Entries</CardTitle>
            <CardDescription>
              Page {page} of {Math.max(totalPages, 1)} &bull; {totalCount} total
            </CardDescription>
          </div>
          <Button
            variant="outline"
            size="sm"
            onClick={handleDownloadReport}
            disabled={feedbackData.length === 0 || loading || generatingPdf}
          >
            {generatingPdf ? (
              <div className="animate-spin rounded-full h-3.5 w-3.5 border-b-2 border-current mr-2" />
            ) : (
              <Download className="w-3.5 h-3.5 mr-2" />
            )}
            {generatingPdf ? 'Generating...' : 'Download Report'}
          </Button>
        </CardHeader>
        <CardContent>
          {loading ? (
            <div className="flex justify-center py-8">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary" />
            </div>
          ) : paginatedFeedback.length === 0 ? (
            <p className="text-center py-8 text-muted-foreground">No feedback yet</p>
          ) : (
            <>
              <div className="overflow-x-auto">
                <table className="w-full text-sm">
                  <thead>
                    <tr className="border-b border-border">
                      <th className="text-left py-3 px-4 font-medium text-muted-foreground">Coach</th>
                      <th className="text-left py-3 px-4 font-medium text-muted-foreground">Category</th>
                      <th className="text-left py-3 px-4 font-medium text-muted-foreground">Rating</th>
                      <th className="text-left py-3 px-4 font-medium text-muted-foreground">Feedback</th>
                      <th className="text-left py-3 px-4 font-medium text-muted-foreground">Date</th>
                    </tr>
                  </thead>
                  <tbody>
                    {paginatedFeedback.map((item) => {
                      const displayName = item.profiles?.full_name || item.profiles?.phone || 'Unknown';
                      const displaySecondary = item.profiles?.full_name && item.profiles?.phone
                        ? item.profiles.phone
                        : null;

                      return (
                        <tr key={item.id} className="border-b border-border hover:bg-accent/50">
                          <td className="py-3 px-4">
                            <div className="text-sm font-medium text-foreground">{displayName}</div>
                            {displaySecondary && (
                              <div className="text-xs text-muted-foreground">{displaySecondary}</div>
                            )}
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
                              {(item.positive_feedback || item.improvement_feedback) && (
                                <Button
                                  variant="link"
                                  size="sm"
                                  className="text-xs h-auto p-0 mt-1"
                                  onClick={() => setSelectedFeedback(item)}
                                >
                                  View more
                                </Button>
                              )}
                            </div>
                          </td>
                          <td className="py-3 px-4 text-xs text-muted-foreground">
                            {new Date(item.created_at).toLocaleDateString()}
                          </td>
                        </tr>
                      );
                    })}
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

      {/* Feedback Detail Modal */}
      {selectedFeedback && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <Card className="w-full max-w-2xl">
            <CardHeader>
              <div className="flex items-start justify-between">
                <div>
                  <CardTitle>Feedback Details</CardTitle>
                  <CardDescription>
                    {selectedFeedback.profiles?.full_name || 'Unknown'} &bull; {new Date(selectedFeedback.created_at).toLocaleDateString()}
                  </CardDescription>
                </div>
                <Button
                  variant="ghost"
                  size="sm"
                  onClick={() => setSelectedFeedback(null)}
                >
                  <X className="w-4 h-4" />
                </Button>
              </div>
            </CardHeader>
            <CardContent className="space-y-4">
              <div>
                <span className="inline-block px-2 py-1 rounded bg-accent text-accent-foreground text-xs font-medium capitalize mb-2">
                  {selectedFeedback.category}
                </span>
                <div className="text-sm font-medium">
                  Rating: {'★'.repeat(selectedFeedback.rating)}{'☆'.repeat(5 - selectedFeedback.rating)}
                </div>
              </div>

              {selectedFeedback.positive_feedback && (
                <div>
                  <h4 className="font-medium text-green-600 text-sm mb-1">What worked well:</h4>
                  <p className="text-sm text-foreground whitespace-pre-wrap">{selectedFeedback.positive_feedback}</p>
                </div>
              )}

              {selectedFeedback.improvement_feedback && (
                <div>
                  <h4 className="font-medium text-amber-600 text-sm mb-1">What could be improved:</h4>
                  <p className="text-sm text-foreground whitespace-pre-wrap">{selectedFeedback.improvement_feedback}</p>
                </div>
              )}

              <div className="pt-2 border-t border-border text-xs text-muted-foreground space-y-1">
                <div><strong>Page:</strong> {selectedFeedback.context_page}</div>
                <div><strong>Persona:</strong> {selectedFeedback.persona || 'N/A'}</div>
              </div>
            </CardContent>
          </Card>
        </div>
      )}
    </div>
  );
}
