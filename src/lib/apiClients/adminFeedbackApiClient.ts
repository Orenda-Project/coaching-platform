/**
 * Admin Feedback API Client — calls FastAPI backend for feedback data.
 * Replaces direct Supabase queries in useFeedback.ts (admin path).
 */

const API_URL = import.meta.env.VITE_API_URL || "http://localhost:8000";

export interface FeedbackProfile {
  id: string | null;
  full_name: string | null;
  email: string | null;
  phone: string | null;
}

export interface FeedbackRecord {
  id: string;
  user_id: string;
  category: "module" | "platform" | "bug" | "other";
  rating: number;
  positive_feedback?: string;
  improvement_feedback?: string;
  context_page: string;
  persona?: string;
  created_at: string;
  profiles: FeedbackProfile | null;
}

export interface FeedbackKPIs {
  totalFeedback: number;
  avgRating: number;
  lowRatingCount: number;
}

export interface AdminFeedbackResponse {
  items: FeedbackRecord[];
  total: number;
  kpis: FeedbackKPIs;
  limit: number;
  offset: number;
}

export interface FeedbackFilters {
  days?: number;
  category?: string;
  rating?: number;
  persona?: string;
  start_date?: string;
  end_date?: string;
  limit?: number;
  offset?: number;
}

export async function fetchAdminFeedback(
  filters: FeedbackFilters = {},
): Promise<AdminFeedbackResponse> {
  const params = new URLSearchParams();
  if (filters.days) params.append("days", String(filters.days));
  if (filters.category) params.append("category", filters.category);
  if (filters.rating) params.append("rating", String(filters.rating));
  if (filters.persona) params.append("persona", filters.persona);
  if (filters.start_date) params.append("start_date", filters.start_date);
  if (filters.end_date) params.append("end_date", filters.end_date);
  if (filters.limit) params.append("limit", String(filters.limit));
  if (filters.offset) params.append("offset", String(filters.offset));

  const qs = params.toString();
  const url = `${API_URL}/api/admin/feedback${qs ? `?${qs}` : ""}`;

  const res = await fetch(url, {
    headers: { "Content-Type": "application/json" },
  });

  if (!res.ok) {
    const err = await res.text();
    throw new Error(`Feedback API error: ${res.status} ${err}`);
  }

  return res.json();
}
