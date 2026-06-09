/**
 * Scenario API Client - Communicates with FastAPI backend scenario service
 *
 * Features:
 * - Scenario retrieval and management
 * - User response tracking
 * - Scenario analytics
 * - Request caching with expiry
 * - Automatic retry on network errors
 *
 * Usage:
 *   const client = new ScenarioApiClient("https://api.example.com");
 *   const scenario = await client.getScenario(scenarioId);
 *   const response = await client.saveResponse(scenarioId, userId, selectedOptionId);
 *   const stats = await client.getUserStats(unitId, userId);
 */

// Type definitions
export interface ScenarioOption {
  id: string;
  scenario_id: string;
  option_text: string;
  feedback?: string;
  is_optimal: boolean;
  order_number: number;
  created_at: string;
  updated_at: string;
}

export interface Scenario {
  id: string;
  unit_id: string;
  title: string;
  description?: string;
  situation: string;
  order_number: number;
  created_at: string;
  updated_at: string;
  options?: ScenarioOption[];
}

export interface ScenarioResponse {
  id: string;
  user_id: string;
  scenario_id: string;
  selected_option_id: string;
  timestamp: string;
  option?: ScenarioOption;
}

export interface SaveResponseRequest {
  selected_option_id: string;
}

export interface UpdateResponseRequest {
  selected_option_id: string;
}

export interface UserStats {
  user_id: string;
  unit_id: string;
  total_scenarios: number;
  scenarios_attempted: number;
  scenarios_optimal: number;
  success_rate: number;
  last_attempt?: string;
}

export interface ScenariosResponse {
  scenarios: Scenario[];
  total: number;
}

export interface ResponsesResponse {
  responses: ScenarioResponse[];
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
 * Scenario API Client
 *
 * Handles all scenario-related API calls with automatic retry,
 * error handling, and data caching.
 */
export class ScenarioApiClient {
  private apiUrl: string;
  private cache: Map<string, { data: unknown; timestamp: number }> = new Map();
  private cacheExpiry: number = 5 * 60 * 1000; // 5 minutes

  constructor(apiUrl?: string) {
    this.apiUrl = apiUrl || import.meta.env.VITE_API_URL || "http://localhost:8000";
  }

  /**
   * Get a scenario with all its options
   *
   * @param scenarioId - Scenario ID
   * @returns Promise with scenario and options
   */
  async getScenario(scenarioId: string): Promise<Scenario> {
    const cacheKey = `scenario_${scenarioId}`;

    if (this.isCacheValid(cacheKey)) {
      return this.cache.get(cacheKey)?.data as Scenario;
    }

    try {
      const response = await this.fetchWithRetry(
        `${this.apiUrl}/api/scenarios/${scenarioId}`
      );

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      const data = await response.json();
      this.setCacheItem(cacheKey, data);
      return data;
    } catch (error) {
      throw this.normalizeError(error, "Failed to fetch scenario");
    }
  }

  /**
   * Get all scenarios in a unit
   *
   * @param unitId - Unit ID
   * @param options - Pagination options
   * @returns Promise with scenarios list
   */
  async getUnitScenarios(
    unitId: string,
    options?: PaginationOptions
  ): Promise<ScenariosResponse> {
    const cacheKey = `unit_scenarios_${unitId}_${JSON.stringify(options || {})}`;

    if (this.isCacheValid(cacheKey)) {
      return this.cache.get(cacheKey)?.data as ScenariosResponse;
    }

    try {
      const params = this.buildQueryString(options);
      const url =
        params.length > 0
          ? `${this.apiUrl}/api/scenarios/unit/${unitId}?${params}`
          : `${this.apiUrl}/api/scenarios/unit/${unitId}`;

      const response = await this.fetchWithRetry(url);

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      const data = await response.json();
      this.setCacheItem(cacheKey, data);
      return data;
    } catch (error) {
      throw this.normalizeError(error, "Failed to fetch unit scenarios");
    }
  }

  /**
   * Save a user response to a scenario
   *
   * @param scenarioId - Scenario ID
   * @param userId - User ID
   * @param selectedOptionId - Selected option ID
   * @returns Promise with saved response
   */
  async saveResponse(
    scenarioId: string,
    userId: string,
    selectedOptionId: string
  ): Promise<ScenarioResponse> {
    try {
      this.invalidateCache(`user_responses_${userId}`);
      this.invalidateCache(`scenario_responses_${scenarioId}`);

      const response = await this.fetchWithRetry(
        `${this.apiUrl}/api/scenarios/${scenarioId}/respond/${userId}`,
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({ selected_option_id: selectedOptionId }),
        }
      );

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      return await response.json();
    } catch (error) {
      throw this.normalizeError(error, "Failed to save response");
    }
  }

  /**
   * Get user's response to a scenario
   *
   * @param scenarioId - Scenario ID
   * @param userId - User ID
   * @returns Promise with user's response
   */
  async getResponse(scenarioId: string, userId: string): Promise<ScenarioResponse> {
    const cacheKey = `response_${scenarioId}_${userId}`;

    if (this.isCacheValid(cacheKey)) {
      return this.cache.get(cacheKey)?.data as ScenarioResponse;
    }

    try {
      const response = await this.fetchWithRetry(
        `${this.apiUrl}/api/scenarios/${scenarioId}/user/${userId}`
      );

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      const data = await response.json();
      this.setCacheItem(cacheKey, data);
      return data;
    } catch (error) {
      throw this.normalizeError(error, "Failed to fetch response");
    }
  }

  /**
   * Update a user response
   *
   * @param scenarioId - Scenario ID
   * @param responseId - Response ID
   * @param newOptionId - New selected option ID
   * @returns Promise with updated response
   */
  async updateResponse(
    scenarioId: string,
    responseId: string,
    newOptionId: string
  ): Promise<ScenarioResponse> {
    try {
      // Invalidate relevant caches
      this.invalidateResponseCaches();

      const response = await this.fetchWithRetry(
        `${this.apiUrl}/api/scenarios/${scenarioId}/respond/${responseId}`,
        {
          method: "PUT",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({ selected_option_id: newOptionId }),
        }
      );

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      return await response.json();
    } catch (error) {
      throw this.normalizeError(error, "Failed to update response");
    }
  }

  /**
   * Get all responses from a user with pagination
   *
   * @param userId - User ID
   * @param options - Pagination options
   * @returns Promise with user's responses
   */
  async getUserResponses(
    userId: string,
    options?: PaginationOptions
  ): Promise<ResponsesResponse> {
    try {
      const params = this.buildQueryString(options);
      const url =
        params.length > 0
          ? `${this.apiUrl}/api/scenarios/user/${userId}/responses?${params}`
          : `${this.apiUrl}/api/scenarios/user/${userId}/responses`;

      const response = await this.fetchWithRetry(url);

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      return await response.json();
    } catch (error) {
      throw this.normalizeError(error, "Failed to fetch user responses");
    }
  }

  /**
   * Get all responses to a scenario
   *
   * @param scenarioId - Scenario ID
   * @param options - Pagination options
   * @returns Promise with all responses to scenario
   */
  async getScenarioResponses(
    scenarioId: string,
    options?: PaginationOptions
  ): Promise<ResponsesResponse> {
    try {
      const params = this.buildQueryString(options);
      const url =
        params.length > 0
          ? `${this.apiUrl}/api/scenarios/${scenarioId}/responses?${params}`
          : `${this.apiUrl}/api/scenarios/${scenarioId}/responses`;

      const response = await this.fetchWithRetry(url);

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      return await response.json();
    } catch (error) {
      throw this.normalizeError(error, "Failed to fetch scenario responses");
    }
  }

  /**
   * Get optimal response for a scenario
   *
   * @param scenarioId - Scenario ID
   * @returns Promise with optimal option
   */
  async getOptimalResponse(scenarioId: string): Promise<ScenarioOption> {
    const cacheKey = `optimal_response_${scenarioId}`;

    if (this.isCacheValid(cacheKey)) {
      return this.cache.get(cacheKey)?.data as ScenarioOption;
    }

    try {
      const response = await this.fetchWithRetry(
        `${this.apiUrl}/api/scenarios/${scenarioId}/optimal`
      );

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      const data = await response.json();
      this.setCacheItem(cacheKey, data);
      return data;
    } catch (error) {
      throw this.normalizeError(error, "Failed to fetch optimal response");
    }
  }

  /**
   * Get user stats in a unit
   *
   * @param unitId - Unit ID
   * @param userId - User ID
   * @returns Promise with user stats
   */
  async getUserStats(unitId: string, userId: string): Promise<UserStats> {
    try {
      const response = await this.fetchWithRetry(
        `${this.apiUrl}/api/scenarios/unit/${unitId}/stats/${userId}`
      );

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      return await response.json();
    } catch (error) {
      throw this.normalizeError(error, "Failed to fetch user stats");
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
   * Invalidate response-related caches
   */
  private invalidateResponseCaches(): void {
    // Clear all response caches
    for (const key of Array.from(this.cache.keys())) {
      if (
        key.startsWith("response_") ||
        key.startsWith("user_responses_") ||
        key.startsWith("scenario_responses_")
      ) {
        this.cache.delete(key);
      }
    }
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
export const scenarioApiClient = new ScenarioApiClient();
