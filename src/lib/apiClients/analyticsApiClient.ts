/**
 * Analytics API Client - Communicates with FastAPI backend analytics service
 *
 * Features:
 * - Event logging and retrieval
 * - User metrics management
 * - Analytics aggregation
 * - Request caching with expiry
 * - Automatic retry on network errors
 *
 * Usage:
 *   const client = new AnalyticsApiClient("https://api.example.com");
 *   const event = await client.logEvent(userId, { event_type: "quiz_completed", ... });
 *   const metrics = await client.getMetrics(userId);
 *   const dashboard = await client.getDashboard(userId);
 */

// Type definitions
export interface AnalyticsEvent {
  id: string;
  user_id: string;
  event_type: string;
  event_data?: Record<string, unknown>;
  timestamp: string;
}

export interface UserMetrics {
  id: string;
  user_id: string;
  quiz_attempts: number;
  modules_passed: number;
  total_score: number;
  created_at: string;
  updated_at: string;
}

export interface DashboardData {
  user_id: string;
  total_events: number;
  metrics: UserMetrics;
  recent_events: AnalyticsEvent[];
  summary: {
    learning_streak: number;
    average_quiz_score: number;
    modules_in_progress: number;
  };
}

export interface EventLogRequest {
  event_type: string;
  event_data?: Record<string, unknown>;
}

export interface EventsResponse {
  events: AnalyticsEvent[];
  total: number;
}

export interface MetricsUpdate {
  quiz_attempts?: number;
  modules_passed?: number;
  total_score?: number;
}

export interface IncrementRequest {
  metric_name: string;
  increment: number;
}

export interface ModuleAnalytics {
  module_id: string;
  total_views: number;
  quiz_completions: number;
  average_score: number;
  learner_count: number;
}

export interface AllAnalyticsResponse {
  analytics: AnalyticsEvent[];
  total: number;
}

export interface PaginationOptions {
  limit?: number;
  offset?: number;
}

export interface ApiError extends Error {
  status?: number;
  code?: string;
  details?: Record<string, unknown>;
}

/**
 * Analytics API Client
 *
 * Handles all analytics-related API calls with automatic retry,
 * error handling, and data caching.
 */
export class AnalyticsApiClient {
  private apiUrl: string;
  private cache: Map<string, { data: unknown; timestamp: number }> = new Map();
  private cacheExpiry: number = 5 * 60 * 1000; // 5 minutes

  constructor(apiUrl?: string) {
    this.apiUrl = apiUrl || import.meta.env.VITE_API_URL || "http://localhost:8000";
  }

  /**
   * Log an analytics event
   *
   * @param userId - User ID
   * @param eventData - Event data including type and metadata
   * @returns Promise with created event
   */
  async logEvent(
    userId: string,
    eventData: EventLogRequest
  ): Promise<AnalyticsEvent> {
    try {
      const response = await this.fetchWithRetry(
        `${this.apiUrl}/api/analytics/events/${userId}`,
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify(eventData),
        }
      );

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      return await response.json();
    } catch (error) {
      throw this.normalizeError(error, "Failed to log event");
    }
  }

  /**
   * Get user events with pagination
   *
   * @param userId - User ID
   * @param options - Pagination options
   * @returns Promise with events list
   */
  async getEvents(
    userId: string,
    options?: PaginationOptions
  ): Promise<EventsResponse> {
    const cacheKey = `events_${userId}_${JSON.stringify(options || {})}`;

    if (this.isCacheValid(cacheKey)) {
      return this.cache.get(cacheKey)?.data as EventsResponse;
    }

    try {
      const params = this.buildQueryString(options);
      const url =
        params.length > 0
          ? `${this.apiUrl}/api/analytics/events/${userId}?${params}`
          : `${this.apiUrl}/api/analytics/events/${userId}`;

      const response = await this.fetchWithRetry(url);

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      const data = await response.json();
      this.setCacheItem(cacheKey, data);
      return data;
    } catch (error) {
      throw this.normalizeError(error, "Failed to fetch events");
    }
  }

  /**
   * Get events filtered by type
   *
   * @param userId - User ID
   * @param eventType - Event type to filter by
   * @param options - Pagination options
   * @returns Promise with filtered events
   */
  async getEventsByType(
    userId: string,
    eventType: string,
    options?: PaginationOptions
  ): Promise<EventsResponse> {
    try {
      const params = this.buildQueryString(options);
      const url =
        params.length > 0
          ? `${this.apiUrl}/api/analytics/events/${userId}/type/${eventType}?${params}`
          : `${this.apiUrl}/api/analytics/events/${userId}/type/${eventType}`;

      const response = await this.fetchWithRetry(url);

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      return await response.json();
    } catch (error) {
      throw this.normalizeError(error, "Failed to fetch events by type");
    }
  }

  /**
   * Get user metrics
   *
   * @param userId - User ID
   * @returns Promise with user metrics
   */
  async getMetrics(userId: string): Promise<UserMetrics> {
    const cacheKey = `metrics_${userId}`;

    if (this.isCacheValid(cacheKey)) {
      return this.cache.get(cacheKey)?.data as UserMetrics;
    }

    try {
      const response = await this.fetchWithRetry(
        `${this.apiUrl}/api/analytics/metrics/${userId}`
      );

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      const data = await response.json();
      this.setCacheItem(cacheKey, data);
      return data;
    } catch (error) {
      throw this.normalizeError(error, "Failed to fetch metrics");
    }
  }

  /**
   * Update user metrics
   *
   * @param userId - User ID
   * @param updates - Metrics to update
   * @returns Promise with updated metrics
   */
  async updateMetrics(
    userId: string,
    updates: MetricsUpdate
  ): Promise<UserMetrics> {
    try {
      this.invalidateCache(`metrics_${userId}`);

      const response = await this.fetchWithRetry(
        `${this.apiUrl}/api/analytics/metrics/${userId}`,
        {
          method: "PUT",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify(updates),
        }
      );

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      return await response.json();
    } catch (error) {
      throw this.normalizeError(error, "Failed to update metrics");
    }
  }

  /**
   * Increment a metric
   *
   * @param userId - User ID
   * @param metricName - Metric name to increment
   * @param increment - Amount to increment by
   * @returns Promise with updated metrics
   */
  async incrementMetric(
    userId: string,
    metricName: keyof UserMetrics,
    increment: number
  ): Promise<UserMetrics> {
    try {
      this.invalidateCache(`metrics_${userId}`);

      const response = await this.fetchWithRetry(
        `${this.apiUrl}/api/analytics/metrics/${userId}/increment`,
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({ metric_name: metricName, increment }),
        }
      );

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      return await response.json();
    } catch (error) {
      throw this.normalizeError(error, "Failed to increment metric");
    }
  }

  /**
   * Get module-level analytics
   *
   * @param moduleId - Module ID
   * @returns Promise with module analytics
   */
  async getModuleAnalytics(moduleId: string): Promise<ModuleAnalytics> {
    const cacheKey = `module_analytics_${moduleId}`;

    if (this.isCacheValid(cacheKey)) {
      return this.cache.get(cacheKey)?.data as ModuleAnalytics;
    }

    try {
      const response = await this.fetchWithRetry(
        `${this.apiUrl}/api/analytics/modules/${moduleId}`
      );

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      const data = await response.json();
      this.setCacheItem(cacheKey, data);
      return data;
    } catch (error) {
      throw this.normalizeError(error, "Failed to fetch module analytics");
    }
  }

  /**
   * Get user dashboard data
   *
   * @param userId - User ID
   * @returns Promise with dashboard data
   */
  async getDashboard(userId: string): Promise<DashboardData> {
    try {
      const response = await this.fetchWithRetry(
        `${this.apiUrl}/api/analytics/dashboard/${userId}`
      );

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      return await response.json();
    } catch (error) {
      throw this.normalizeError(error, "Failed to fetch dashboard");
    }
  }

  /**
   * Get all analytics (admin only)
   *
   * @param options - Pagination options
   * @returns Promise with all analytics
   */
  async getAllAnalytics(
    options?: PaginationOptions
  ): Promise<AllAnalyticsResponse> {
    try {
      const params = this.buildQueryString(options);
      const url =
        params.length > 0
          ? `${this.apiUrl}/api/analytics/?${params}`
          : `${this.apiUrl}/api/analytics/`;

      const response = await this.fetchWithRetry(url);

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      return await response.json();
    } catch (error) {
      throw this.normalizeError(error, "Failed to fetch all analytics");
    }
  }

  /**
   * Clear all cache
   */
  clearCache(): void {
    this.cache.clear();
  }

  /**
   * Build query string from options
   */
  private buildQueryString(options?: PaginationOptions): string {
    if (!options) return "";

    const params = new URLSearchParams();
    if (options.limit !== undefined) {
      params.append("limit", options.limit.toString());
    }
    if (options.offset !== undefined) {
      params.append("offset", options.offset.toString());
    }

    return params.toString();
  }

  /**
   * Invalidate specific cache entry
   */
  private invalidateCache(key: string): void {
    this.cache.delete(key);
  }

  /**
   * Check if cache is still valid
   */
  private isCacheValid(key: string): boolean {
    const item = this.cache.get(key);
    if (!item) return false;

    const age = Date.now() - item.timestamp;
    return age < this.cacheExpiry;
  }

  /**
   * Set cache item with timestamp
   */
  private setCacheItem(key: string, data: unknown): void {
    this.cache.set(key, { data, timestamp: Date.now() });
  }

  /**
   * Fetch with automatic retry logic
   */
  private async fetchWithRetry(
    url: string,
    options?: RequestInit,
    maxRetries: number = 3,
    baseDelay: number = 1000
  ): Promise<Response> {
    let lastError: Error | null = null;

    for (let attempt = 0; attempt < maxRetries; attempt++) {
      try {
        const response = await fetch(url, {
          ...options,
          headers: {
            "Content-Type": "application/json",
            ...options?.headers,
          },
        });

        // Don't retry 4xx errors (client errors)
        if (response.status >= 400 && response.status < 500) {
          return response;
        }

        // Retry 5xx errors
        if (response.status >= 500 && attempt < maxRetries - 1) {
          const delay = baseDelay * Math.pow(2, attempt);
          await this.sleep(delay);
          continue;
        }

        return response;
      } catch (error) {
        lastError = error instanceof Error ? error : new Error(String(error));

        // Retry on network errors
        if (attempt < maxRetries - 1) {
          const delay = baseDelay * Math.pow(2, attempt);
          await this.sleep(delay);
          continue;
        }
      }
    }

    throw lastError || new Error("Failed to fetch after maximum retries");
  }

  /**
   * Handle error response from API
   */
  private async handleErrorResponse(response: Response): Promise<ApiError> {
    let errorData: Record<string, unknown> = {};

    try {
      const text = await response.text();
      if (text) {
        errorData = JSON.parse(text);
      }
    } catch {
      // Ignore parsing errors
    }

    const error = new Error(
      (errorData.detail as string) || `HTTP ${response.status}`
    ) as ApiError;

    error.status = response.status;
    error.code = (errorData.code as string) || `HTTP_${response.status}`;
    error.details = errorData;

    return error;
  }

  /**
   * Normalize errors for consistent error handling
   */
  private normalizeError(error: unknown, defaultMessage: string): ApiError {
    if (error instanceof Error && "status" in error) {
      return error as ApiError;
    }

    const apiError = new Error(
      error instanceof Error ? error.message : defaultMessage
    ) as ApiError;

    apiError.code = "UNKNOWN_ERROR";
    return apiError;
  }

  /**
   * Sleep utility for retry delays
   */
  private sleep(ms: number): Promise<void> {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }
}

// Export singleton instance
export const analyticsApiClient = new AnalyticsApiClient();
