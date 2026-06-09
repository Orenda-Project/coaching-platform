/**
 * Coaching API Client - Communicates with FastAPI backend coaching service
 *
 * Features:
 * - Teacher DC scores retrieval
 * - Automatic retry and error handling
 * - Request/response caching
 *
 * Usage:
 *   const client = new CoachingApiClient("https://api.example.com");
 *   const teachers = await client.getTeacherDCScores("sub-region-name");
 */

// Type definitions
export interface TeacherDCScoreRow {
  id: string;
  teacher_name: string;
  school_name: string;
  region: string;
  grade: string;
  subject: string;
  total_score: number;
  scored_at: string;
  raw_results?: Record<string, number | undefined>;
}

export interface GetTeacherScoresResponse {
  teachers: TeacherDCScoreRow[];
  total: number;
  region?: string;
}

export interface ApiError extends Error {
  status?: number;
  code?: string;
  details?: Record<string, unknown>;
}

/**
 * Coaching API Client
 *
 * Handles all coaching-related API calls with automatic retry,
 * error handling, and data caching.
 */
export class CoachingApiClient {
  private apiUrl: string;
  private cache: Map<string, { data: unknown; timestamp: number }> = new Map();
  private cacheExpiry: number = 5 * 60 * 1000; // 5 minutes

  constructor(apiUrl?: string) {
    this.apiUrl = apiUrl || import.meta.env.VITE_API_URL || "http://localhost:8000";
  }

  /**
   * Get teacher DC scores for a region
   *
   * @param region - Region/sub-region name
   * @returns Promise with teachers list
   */
  async getTeacherDCScores(region?: string): Promise<GetTeacherScoresResponse> {
    const cacheKey = `teacher_dc_scores_${region || 'all'}`;

    if (this.isCacheValid(cacheKey)) {
      return this.cache.get(cacheKey)?.data as GetTeacherScoresResponse;
    }

    try {
      const params = new URLSearchParams();
      if (region) {
        params.append('region', region);
      }

      const url = params.toString()
        ? `${this.apiUrl}/api/coaching/teachers/dc-scores?${params.toString()}`
        : `${this.apiUrl}/api/coaching/teachers/dc-scores`;

      const response = await this.fetchWithRetry(url);

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      const data = await response.json() as GetTeacherScoresResponse;
      this.setCacheItem(cacheKey, data);
      return data;
    } catch (error) {
      throw this.normalizeError(error, "Failed to fetch teacher DC scores");
    }
  }

  /**
   * Clear all cache
   */
  clearCache(): void {
    this.cache.clear();
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
   *
   * Retries on network errors and 5xx server errors.
   * Does NOT retry on 4xx client errors.
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
export const coachingApiClient = new CoachingApiClient();
