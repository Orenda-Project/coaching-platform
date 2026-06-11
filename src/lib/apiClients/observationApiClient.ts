/**
 * Observation API Client - Communicates with FastAPI backend observations service
 *
 * Features:
 * - Full observation CRUD operations
 * - COT (Classroom Observation Tool) response management
 * - Bulk operations support
 * - Automatic retry and error handling
 * - Request/response caching
 *
 * Usage:
 *   const client = new ObservationApiClient("https://api.example.com");
 *   const obs = await client.createObservation("user-123", "2026-06-09", "Notes");
 *   const cot = await client.createCOTObservation(obs.id, "engagement", "Response", 4);
 */

// Type definitions
export interface CreateObservationPayload {
  user_id: string;
  date: string; // YYYY-MM-DD format
  notes: string;
}

export interface Observation {
  id: string;
  user_id: string;
  date: string;
  notes: string;
  created_at: string;
  updated_at: string;
}

export interface UpdateObservationPayload {
  date?: string;
  notes?: string;
}

export interface COTResponse {
  id: string;
  observation_id: string;
  category: string; // e.g., "engagement", "behavior", "participation"
  response: string;
  rating: number; // 1-5 scale
  created_at: string;
  updated_at: string;
}

export interface CreateCOTPayload {
  category: string;
  response: string;
  rating: number;
}

export interface BulkObservationPayload {
  user_id: string;
  date: string;
  notes: string;
}

export interface BulkSaveResponse {
  created: number;
  updated: number;
  failed: number;
  observations: Observation[];
}

export interface GetObservationsResponse {
  observations: Observation[];
  total: number;
  limit: number;
  offset: number;
}

export interface GetCOTResponsesResponse {
  cot_responses: COTResponse[];
  total: number;
}

export interface ApiError extends Error {
  status?: number;
  code?: string;
  details?: Record<string, unknown>;
}

/**
 * Observation API Client
 *
 * Handles all observation-related API calls with automatic retry,
 * error handling, and data caching.
 */
export class ObservationApiClient {
  private apiUrl: string;
  private cache: Map<string, { data: unknown; timestamp: number }> = new Map();
  private cacheExpiry: number = 5 * 60 * 1000; // 5 minutes

  constructor(apiUrl?: string) {
    this.apiUrl = apiUrl || import.meta.env.VITE_API_URL || "http://localhost:8000";
  }

  /**
   * Create a new observation
   *
   * @param userId - User ID
   * @param date - Observation date (YYYY-MM-DD)
   * @param notes - Observation notes
   * @returns Promise with created observation
   */
  async createObservation(
    userId: string,
    date: string,
    notes: string
  ): Promise<Observation> {
    const payload: CreateObservationPayload = {
      user_id: userId,
      date,
      notes,
    };

    try {
      const response = await this.fetchWithRetry(
        `${this.apiUrl}/api/observations`,
        {
          method: "POST",
          body: JSON.stringify(payload),
        }
      );

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      return await response.json() as Observation;
    } catch (error) {
      throw this.normalizeError(error, "Failed to create observation");
    }
  }

  /**
   * Get an observation by ID
   *
   * @param observationId - Observation ID
   * @returns Promise with observation
   */
  async getObservation(observationId: string): Promise<Observation> {
    const cacheKey = `observation_${observationId}`;

    if (this.isCacheValid(cacheKey)) {
      return this.cache.get(cacheKey)?.data as Observation;
    }

    try {
      const response = await this.fetchWithRetry(
        `${this.apiUrl}/api/observations/${observationId}`
      );

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      const data = await response.json() as Observation;
      this.setCacheItem(cacheKey, data);
      return data;
    } catch (error) {
      throw this.normalizeError(error, `Failed to fetch observation ${observationId}`);
    }
  }

  /**
   * Get all observations for a user with pagination
   *
   * @param userId - User ID
   * @param limit - Number of results (default 100)
   * @param offset - Results offset (default 0)
   * @returns Promise with observations list
   */
  async getUserObservations(
    userId: string,
    limit: number = 100,
    offset: number = 0
  ): Promise<GetObservationsResponse> {
    const cacheKey = `user_observations_${userId}_${limit}_${offset}`;

    if (this.isCacheValid(cacheKey)) {
      return this.cache.get(cacheKey)?.data as GetObservationsResponse;
    }

    try {
      const params = new URLSearchParams({
        limit: String(limit),
        offset: String(offset),
      });

      const response = await this.fetchWithRetry(
        `${this.apiUrl}/api/observations/user/${userId}?${params.toString()}`
      );

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      const data = await response.json() as GetObservationsResponse;
      this.setCacheItem(cacheKey, data);
      return data;
    } catch (error) {
      throw this.normalizeError(error, `Failed to fetch observations for user ${userId}`);
    }
  }

  /**
   * Update an observation
   *
   * @param observationId - Observation ID
   * @param payload - Update data
   * @returns Promise with updated observation
   */
  async updateObservation(
    observationId: string,
    payload: UpdateObservationPayload
  ): Promise<Observation> {
    // Invalidate cache
    this.invalidateCache(`observation_${observationId}`);

    try {
      const response = await this.fetchWithRetry(
        `${this.apiUrl}/api/observations/${observationId}`,
        {
          method: "PUT",
          body: JSON.stringify(payload),
        }
      );

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      const data = await response.json() as Observation;
      this.setCacheItem(`observation_${observationId}`, data);
      return data;
    } catch (error) {
      throw this.normalizeError(error, `Failed to update observation ${observationId}`);
    }
  }

  /**
   * Delete an observation
   *
   * @param observationId - Observation ID
   * @returns Promise that resolves when deleted
   */
  async deleteObservation(observationId: string): Promise<void> {
    // Invalidate cache
    this.invalidateCache(`observation_${observationId}`);

    try {
      const response = await this.fetchWithRetry(
        `${this.apiUrl}/api/observations/${observationId}`,
        { method: "DELETE" }
      );

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }
    } catch (error) {
      throw this.normalizeError(error, `Failed to delete observation ${observationId}`);
    }
  }

  /**
   * Create a COT (Classroom Observation Tool) response
   *
   * @param observationId - Observation ID
   * @param category - COT category
   * @param response - Response text
   * @param rating - Rating (1-5)
   * @returns Promise with created COT response
   */
  async createCOTObservation(
    observationId: string,
    category: string,
    response: string,
    rating: number
  ): Promise<COTResponse> {
    const payload: CreateCOTPayload = {
      category,
      response,
      rating,
    };

    try {
      const res = await this.fetchWithRetry(
        `${this.apiUrl}/api/observations/${observationId}/cot`,
        {
          method: "POST",
          body: JSON.stringify(payload),
        }
      );

      if (!res.ok) {
        throw await this.handleErrorResponse(res);
      }

      return await res.json() as COTResponse;
    } catch (error) {
      throw this.normalizeError(error, `Failed to create COT observation`);
    }
  }

  /**
   * Get all COT responses for an observation
   *
   * @param observationId - Observation ID
   * @returns Promise with COT responses
   */
  async getCOTResponses(observationId: string): Promise<GetCOTResponsesResponse> {
    const cacheKey = `cot_responses_${observationId}`;

    if (this.isCacheValid(cacheKey)) {
      return this.cache.get(cacheKey)?.data as GetCOTResponsesResponse;
    }

    try {
      const response = await this.fetchWithRetry(
        `${this.apiUrl}/api/observations/${observationId}/cot`
      );

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      const data = await response.json() as GetCOTResponsesResponse;
      this.setCacheItem(cacheKey, data);
      return data;
    } catch (error) {
      throw this.normalizeError(error, `Failed to fetch COT responses for observation ${observationId}`);
    }
  }

  /**
   * Bulk save multiple observations
   *
   * @param observations - Array of observation payloads
   * @returns Promise with bulk save response
   */
  async bulkSaveObservations(
    observations: BulkObservationPayload[]
  ): Promise<BulkSaveResponse> {
    try {
      const response = await this.fetchWithRetry(
        `${this.apiUrl}/api/observations/bulk`,
        {
          method: "POST",
          body: JSON.stringify({ observations }),
        }
      );

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      return await response.json() as BulkSaveResponse;
    } catch (error) {
      throw this.normalizeError(error, "Failed to bulk save observations");
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
export const observationApiClient = new ObservationApiClient();
