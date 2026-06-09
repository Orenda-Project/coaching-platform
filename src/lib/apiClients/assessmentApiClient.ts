/**
 * Assessment API Client - Communicates with backend assessment service
 *
 * Features:
 * - Full assessment lifecycle management (create, submit, results)
 * - Automatic retry logic (3 attempts, exponential backoff)
 * - Response caching (5-minute TTL)
 * - Full TypeScript typing
 *
 * Usage:
 *   const client = new AssessmentApiClient("https://api.example.com");
 *   const assessment = await client.createAssessment("user-123", "module-456");
 *   const submitted = await client.submitAssessment(assessment.id, responses);
 */

// Type definitions
export interface Assessment {
  id: string;
  user_id: string;
  module_id: string;
  type: "baseline" | "module" | "endline";
  status: "in_progress" | "completed" | "abandoned";
  attempts: number;
  score: number | null;
  passed: boolean | null;
  started_at: string;
  completed_at: string | null;
  created_at: string;
}

export interface AssessmentResponse {
  assessments: Assessment[];
  total: number;
}

export interface AssessmentResults {
  assessment_id: string;
  score: number;
  passed: boolean;
  results: Array<{
    question_id: string;
    correct: boolean;
    user_answer: string;
    correct_answer: string;
  }>;
}

export interface ApiError extends Error {
  status?: number;
  code?: string;
  details?: Record<string, unknown>;
}

/**
 * Assessment API Client
 *
 * Handles all assessment-related API calls with automatic retry,
 * error handling, and response caching.
 */
export class AssessmentApiClient {
  private apiUrl: string;
  private cache: Map<string, { data: unknown; timestamp: number }> = new Map();
  private cacheExpiry: number = 5 * 60 * 1000; // 5 minutes

  constructor(apiUrl?: string) {
    this.apiUrl = apiUrl || import.meta.env.VITE_API_URL || "http://localhost:8000";
  }

  /**
   * Create a new assessment
   *
   * @param userId - User ID
   * @param moduleId - Module ID
   * @returns Promise with new assessment
   */
  async createAssessment(userId: string, moduleId: string): Promise<Assessment> {
    const payload = {
      user_id: userId,
      module_id: moduleId,
    };

    try {
      const response = await this.fetchWithRetry(
        `${this.apiUrl}/api/assessments`,
        {
          method: "POST",
          body: JSON.stringify(payload),
        }
      );

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      return await response.json() as Assessment;
    } catch (error) {
      throw this.normalizeError(error, `Failed to create assessment for user ${userId}`);
    }
  }

  /**
   * Get assessment by ID
   *
   * @param assessmentId - Assessment ID
   * @returns Promise with assessment
   */
  async getAssessment(assessmentId: string): Promise<Assessment> {
    const cacheKey = `assessment_${assessmentId}`;

    if (this.isCacheValid(cacheKey)) {
      return this.cache.get(cacheKey)?.data as Assessment;
    }

    try {
      const response = await this.fetchWithRetry(
        `${this.apiUrl}/api/assessments/${assessmentId}`
      );

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      const data = await response.json() as Assessment;
      this.setCacheItem(cacheKey, data);
      return data;
    } catch (error) {
      throw this.normalizeError(error, `Failed to fetch assessment ${assessmentId}`);
    }
  }

  /**
   * Get all assessments for a user
   *
   * @param userId - User ID
   * @returns Promise with assessments list
   */
  async getUserAssessments(userId: string): Promise<AssessmentResponse> {
    const cacheKey = `user_assessments_${userId}`;

    if (this.isCacheValid(cacheKey)) {
      return this.cache.get(cacheKey)?.data as AssessmentResponse;
    }

    try {
      const response = await this.fetchWithRetry(
        `${this.apiUrl}/api/assessments/user/${userId}`
      );

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      const data = await response.json() as AssessmentResponse;
      this.setCacheItem(cacheKey, data);
      return data;
    } catch (error) {
      throw this.normalizeError(error, `Failed to fetch assessments for user ${userId}`);
    }
  }

  /**
   * Submit assessment responses
   *
   * @param assessmentId - Assessment ID
   * @param responses - Map of question ID to answer
   * @returns Promise with updated assessment
   */
  async submitAssessment(
    assessmentId: string,
    responses: Record<string, string>
  ): Promise<Assessment> {
    // Invalidate cache
    this.invalidateCache(`assessment_${assessmentId}`);

    const payload = { responses };

    try {
      const response = await this.fetchWithRetry(
        `${this.apiUrl}/api/assessments/${assessmentId}/submit`,
        {
          method: "POST",
          body: JSON.stringify(payload),
        }
      );

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      const data = await response.json() as Assessment;
      this.setCacheItem(`assessment_${assessmentId}`, data);
      return data;
    } catch (error) {
      throw this.normalizeError(error, `Failed to submit assessment ${assessmentId}`);
    }
  }

  /**
   * Get assessment results
   *
   * @param assessmentId - Assessment ID
   * @returns Promise with assessment results
   */
  async getAssessmentResults(assessmentId: string): Promise<AssessmentResults> {
    const cacheKey = `assessment_results_${assessmentId}`;

    if (this.isCacheValid(cacheKey)) {
      return this.cache.get(cacheKey)?.data as AssessmentResults;
    }

    try {
      const response = await this.fetchWithRetry(
        `${this.apiUrl}/api/assessments/${assessmentId}/results`
      );

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      const data = await response.json() as AssessmentResults;
      this.setCacheItem(cacheKey, data);
      return data;
    } catch (error) {
      throw this.normalizeError(error, `Failed to fetch results for assessment ${assessmentId}`);
    }
  }

  /**
   * Get assessment history for a user
   *
   * @param userId - User ID
   * @param limit - Maximum number of records (default: 50)
   * @returns Promise with assessment history
   */
  async getAssessmentHistory(userId: string, limit: number = 50): Promise<AssessmentResponse> {
    const cacheKey = `assessment_history_${userId}_${limit}`;

    if (this.isCacheValid(cacheKey)) {
      return this.cache.get(cacheKey)?.data as AssessmentResponse;
    }

    try {
      const params = new URLSearchParams({ limit: String(limit) });

      const response = await this.fetchWithRetry(
        `${this.apiUrl}/api/assessments/user/${userId}/history?${params.toString()}`
      );

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      const data = await response.json() as AssessmentResponse;
      this.setCacheItem(cacheKey, data);
      return data;
    } catch (error) {
      throw this.normalizeError(error, `Failed to fetch assessment history for user ${userId}`);
    }
  }

  /**
   * Update assessment
   *
   * @param assessmentId - Assessment ID
   * @param data - Fields to update
   * @returns Promise with updated assessment
   */
  async updateAssessment(
    assessmentId: string,
    data: Partial<Assessment>
  ): Promise<Assessment> {
    // Invalidate cache
    this.invalidateCache(`assessment_${assessmentId}`);

    try {
      const response = await this.fetchWithRetry(
        `${this.apiUrl}/api/assessments/${assessmentId}`,
        {
          method: "PUT",
          body: JSON.stringify(data),
        }
      );

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      const updated = await response.json() as Assessment;
      this.setCacheItem(`assessment_${assessmentId}`, updated);
      return updated;
    } catch (error) {
      throw this.normalizeError(error, `Failed to update assessment ${assessmentId}`);
    }
  }

  /**
   * Delete assessment
   *
   * @param assessmentId - Assessment ID
   * @returns Promise that resolves when deleted
   */
  async deleteAssessment(assessmentId: string): Promise<void> {
    // Invalidate cache
    this.invalidateCache(`assessment_${assessmentId}`);

    try {
      const response = await this.fetchWithRetry(
        `${this.apiUrl}/api/assessments/${assessmentId}`,
        { method: "DELETE" }
      );

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }
    } catch (error) {
      throw this.normalizeError(error, `Failed to delete assessment ${assessmentId}`);
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
export const assessmentApiClient = new AssessmentApiClient();
