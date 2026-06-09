/**
 * Training API Client - Communicates with backend training service
 *
 * Features:
 * - Full training management (get, content, progress tracking)
 * - Automatic retry logic (3 attempts, exponential backoff)
 * - Response caching (5-minute TTL)
 * - Full TypeScript typing
 *
 * Usage:
 *   const client = new TrainingApiClient("https://api.example.com");
 *   const trainings = await client.getTrainings();
 *   const progress = await client.getUserProgress("user-123", "training-1");
 */

// Type definitions
export interface Training {
  id: string;
  title: string;
  description: string;
  order_number: number;
  is_common: boolean;
  persona_required: string | null;
  created_at: string;
  updated_at: string;
}

export interface TrainingContent {
  training_id: string;
  slides: Array<{
    id: string;
    order: number;
    title: string;
    content: string;
  }>;
  videos: Array<{
    id: string;
    order: number;
    url: string;
    duration: number;
  }>;
  materials: Array<{
    id: string;
    order: number;
    title: string;
    url: string;
  }>;
}

export interface UserProgress {
  user_id: string;
  training_id: string;
  started: boolean;
  completed: boolean;
  progress_percentage: number;
  last_accessed: string;
  started_at: string;
  completed_at: string | null;
}

export interface ApiError extends Error {
  status?: number;
  code?: string;
  details?: Record<string, unknown>;
}

/**
 * Training API Client
 *
 * Handles all training-related API calls with automatic retry,
 * error handling, and response caching.
 */
export class TrainingApiClient {
  private apiUrl: string;
  private cache: Map<string, { data: unknown; timestamp: number }> = new Map();
  private cacheExpiry: number = 5 * 60 * 1000; // 5 minutes

  constructor(apiUrl?: string) {
    this.apiUrl = apiUrl || import.meta.env.VITE_API_URL || "http://localhost:8000";
  }

  /**
   * Get all trainings
   *
   * @returns Promise with trainings list
   */
  async getTrainings(): Promise<Training[]> {
    const cacheKey = "trainings_all";

    if (this.isCacheValid(cacheKey)) {
      return this.cache.get(cacheKey)?.data as Training[];
    }

    try {
      const response = await this.fetchWithRetry(`${this.apiUrl}/api/trainings`);

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      const data = await response.json() as Training[];
      this.setCacheItem(cacheKey, data);
      return data;
    } catch (error) {
      throw this.normalizeError(error, "Failed to fetch trainings");
    }
  }

  /**
   * Get training by ID
   *
   * @param trainingId - Training ID
   * @returns Promise with training
   */
  async getTraining(trainingId: string): Promise<Training> {
    const cacheKey = `training_${trainingId}`;

    if (this.isCacheValid(cacheKey)) {
      return this.cache.get(cacheKey)?.data as Training;
    }

    try {
      const response = await this.fetchWithRetry(`${this.apiUrl}/api/trainings/${trainingId}`);

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      const data = await response.json() as Training;
      this.setCacheItem(cacheKey, data);
      return data;
    } catch (error) {
      throw this.normalizeError(error, `Failed to fetch training ${trainingId}`);
    }
  }

  /**
   * Get training content
   *
   * @param trainingId - Training ID
   * @returns Promise with training content
   */
  async getTrainingContent(trainingId: string): Promise<TrainingContent> {
    const cacheKey = `training_content_${trainingId}`;

    if (this.isCacheValid(cacheKey)) {
      return this.cache.get(cacheKey)?.data as TrainingContent;
    }

    try {
      const response = await this.fetchWithRetry(
        `${this.apiUrl}/api/trainings/${trainingId}/content`
      );

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      const data = await response.json() as TrainingContent;
      this.setCacheItem(cacheKey, data);
      return data;
    } catch (error) {
      throw this.normalizeError(error, `Failed to fetch content for training ${trainingId}`);
    }
  }

  /**
   * Get user progress for a training
   *
   * @param userId - User ID
   * @param trainingId - Training ID
   * @returns Promise with user progress
   */
  async getUserProgress(userId: string, trainingId: string): Promise<UserProgress> {
    const cacheKey = `progress_${userId}_${trainingId}`;

    if (this.isCacheValid(cacheKey)) {
      return this.cache.get(cacheKey)?.data as UserProgress;
    }

    try {
      const response = await this.fetchWithRetry(
        `${this.apiUrl}/api/trainings/${trainingId}/progress/${userId}`
      );

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      const data = await response.json() as UserProgress;
      this.setCacheItem(cacheKey, data);
      return data;
    } catch (error) {
      throw this.normalizeError(
        error,
        `Failed to fetch progress for user ${userId} on training ${trainingId}`
      );
    }
  }

  /**
   * Update user progress
   *
   * @param userId - User ID
   * @param trainingId - Training ID
   * @param progress - Progress data to update
   * @returns Promise with updated progress
   */
  async updateProgress(
    userId: string,
    trainingId: string,
    progress: Partial<UserProgress>
  ): Promise<UserProgress> {
    // Invalidate cache
    this.invalidateCache(`progress_${userId}_${trainingId}`);

    try {
      const response = await this.fetchWithRetry(
        `${this.apiUrl}/api/trainings/${trainingId}/progress/${userId}`,
        {
          method: "PUT",
          body: JSON.stringify(progress),
        }
      );

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      const updated = await response.json() as UserProgress;
      this.setCacheItem(`progress_${userId}_${trainingId}`, updated);
      return updated;
    } catch (error) {
      throw this.normalizeError(
        error,
        `Failed to update progress for user ${userId} on training ${trainingId}`
      );
    }
  }

  /**
   * Mark training as complete for user
   *
   * @param userId - User ID
   * @param trainingId - Training ID
   * @returns Promise with updated progress
   */
  async markComplete(userId: string, trainingId: string): Promise<UserProgress> {
    // Invalidate cache
    this.invalidateCache(`progress_${userId}_${trainingId}`);

    try {
      const response = await this.fetchWithRetry(
        `${this.apiUrl}/api/trainings/${trainingId}/progress/${userId}/complete`,
        { method: "POST" }
      );

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      const updated = await response.json() as UserProgress;
      this.setCacheItem(`progress_${userId}_${trainingId}`, updated);
      return updated;
    } catch (error) {
      throw this.normalizeError(
        error,
        `Failed to mark training ${trainingId} as complete for user ${userId}`
      );
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
export const trainingApiClient = new TrainingApiClient();
