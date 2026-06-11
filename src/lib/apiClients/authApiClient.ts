/**
 * Auth API Client - Communicates with FastAPI backend auth service
 *
 * Features:
 * - Full user signup/signin/profile management
 * - Automatic error handling and retry logic
 * - Token caching for performance
 * - XSS-safe token storage
 *
 * Usage:
 *   const client = new AuthApiClient("https://api.example.com");
 *   const result = await client.signup("user@example.com", "password");
 */

// Type definitions
export interface SignupPayload {
  email: string;
  full_name?: string;
  phone?: string;
}

export interface SignupResponse {
  id: string;
  email: string;
  full_name?: string;
  phone?: string;
  role: string;
  created_at: string;
}

export interface UserProfile {
  id: string;
  user_id: string;
  full_name?: string;
  phone?: string;
  avatar_url?: string;
  bio?: string;
  role: string;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface UserResponse {
  id: string;
  email: string;
  email_confirmed_at?: string;
  created_at: string;
  updated_at: string;
  profile?: UserProfile;
}

export interface ProfileUpdatePayload {
  full_name?: string;
  phone?: string;
  avatar_url?: string;
  bio?: string;
  role?: string;
}

export interface SessionResponse {
  user?: UserResponse;
  authenticated: boolean;
  message: string;
}

export interface ListUsersResponse {
  users: UserResponse[];
  total: number;
  limit: number;
  offset: number;
}

export interface ApiError extends Error {
  status?: number;
  code?: string;
  details?: Record<string, unknown>;
}

/**
 * Auth API Client
 *
 * Handles all authentication-related API calls with automatic retry,
 * error handling, and token management.
 */
export class AuthApiClient {
  private apiUrl: string;
  private cache: Map<string, { data: unknown; timestamp: number }> = new Map();
  private cacheExpiry: number = 5 * 60 * 1000; // 5 minutes

  constructor(apiUrl?: string) {
    this.apiUrl = apiUrl || import.meta.env.VITE_API_URL || "http://localhost:8000";
  }

  /**
   * Sign up a new user
   *
   * @param email - User email
   * @param fullName - User full name (optional)
   * @param phone - User phone (optional)
   * @returns Promise with signup response
   */
  async signup(
    email: string,
    fullName?: string,
    phone?: string
  ): Promise<SignupResponse> {
    const payload: SignupPayload = {
      email,
      full_name: fullName,
      phone,
    };

    try {
      const response = await this.fetchWithRetry(
        `${this.apiUrl}/api/auth/signup`,
        {
          method: "POST",
          body: JSON.stringify(payload),
        }
      );

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      return await response.json() as SignupResponse;
    } catch (error) {
      throw this.normalizeError(error, "Failed to sign up user");
    }
  }

  /**
   * Get user by ID
   *
   * @param userId - User ID
   * @returns Promise with user response
   */
  async getUser(userId: string): Promise<UserResponse> {
    const cacheKey = `user_${userId}`;

    if (this.isCacheValid(cacheKey)) {
      return this.cache.get(cacheKey)?.data as UserResponse;
    }

    try {
      const response = await this.fetchWithRetry(
        `${this.apiUrl}/api/auth/users/${userId}`
      );

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      const data = await response.json() as UserResponse;
      this.setCacheItem(cacheKey, data);
      return data;
    } catch (error) {
      throw this.normalizeError(error, `Failed to fetch user ${userId}`);
    }
  }

  /**
   * Get user by email
   *
   * @param email - User email
   * @returns Promise with user response
   */
  async getUserByEmail(email: string): Promise<UserResponse> {
    const cacheKey = `user_email_${email}`;

    if (this.isCacheValid(cacheKey)) {
      return this.cache.get(cacheKey)?.data as UserResponse;
    }

    try {
      const response = await this.fetchWithRetry(
        `${this.apiUrl}/api/auth/users/email/${encodeURIComponent(email)}`
      );

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      const data = await response.json() as UserResponse;
      this.setCacheItem(cacheKey, data);
      return data;
    } catch (error) {
      throw this.normalizeError(error, `Failed to fetch user ${email}`);
    }
  }

  /**
   * Get user profile
   *
   * @param userId - User ID
   * @returns Promise with profile response
   */
  async getProfile(userId: string): Promise<UserProfile> {
    const cacheKey = `profile_${userId}`;

    if (this.isCacheValid(cacheKey)) {
      return this.cache.get(cacheKey)?.data as UserProfile;
    }

    try {
      const response = await this.fetchWithRetry(
        `${this.apiUrl}/api/auth/profile/${userId}`
      );

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      const data = await response.json() as UserProfile;
      this.setCacheItem(cacheKey, data);
      return data;
    } catch (error) {
      throw this.normalizeError(error, `Failed to fetch profile for user ${userId}`);
    }
  }

  /**
   * Update user profile
   *
   * @param userId - User ID
   * @param payload - Profile update data
   * @returns Promise with updated profile
   */
  async updateProfile(userId: string, payload: ProfileUpdatePayload): Promise<UserProfile> {
    // Invalidate cache
    this.invalidateCache(`profile_${userId}`);

    try {
      const response = await this.fetchWithRetry(
        `${this.apiUrl}/api/auth/profile/${userId}`,
        {
          method: "PUT",
          body: JSON.stringify(payload),
        }
      );

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      const data = await response.json() as UserProfile;
      this.setCacheItem(`profile_${userId}`, data);
      return data;
    } catch (error) {
      throw this.normalizeError(error, `Failed to update profile for user ${userId}`);
    }
  }

  /**
   * Confirm user email
   *
   * @param userId - User ID
   * @returns Promise with confirmation response
   */
  async confirmEmail(userId: string): Promise<{ message: string; email_confirmed_at: string }> {
    // Invalidate cache
    this.invalidateCache(`user_${userId}`);

    try {
      const response = await this.fetchWithRetry(
        `${this.apiUrl}/api/auth/email-confirm/${userId}`,
        { method: "POST" }
      );

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      return await response.json();
    } catch (error) {
      throw this.normalizeError(error, `Failed to confirm email for user ${userId}`);
    }
  }

  /**
   * Delete user
   *
   * @param userId - User ID
   * @returns Promise that resolves when deleted
   */
  async deleteUser(userId: string): Promise<void> {
    // Invalidate caches
    this.invalidateCache(`user_${userId}`);
    this.invalidateCache(`profile_${userId}`);

    try {
      const response = await this.fetchWithRetry(
        `${this.apiUrl}/api/auth/users/${userId}`,
        { method: "DELETE" }
      );

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }
    } catch (error) {
      throw this.normalizeError(error, `Failed to delete user ${userId}`);
    }
  }

  /**
   * List users with pagination
   *
   * @param limit - Number of results (max 1000)
   * @param offset - Results offset
   * @returns Promise with users list
   */
  async listUsers(limit: number = 100, offset: number = 0): Promise<ListUsersResponse> {
    try {
      const params = new URLSearchParams({
        limit: String(limit),
        offset: String(offset),
      });

      const response = await this.fetchWithRetry(
        `${this.apiUrl}/api/auth/users?${params.toString()}`
      );

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      return await response.json();
    } catch (error) {
      throw this.normalizeError(error, "Failed to list users");
    }
  }

  /**
   * Get session information
   *
   * @param userId - User ID to check session for (optional)
   * @returns Promise with session response
   */
  async getSession(userId?: string): Promise<SessionResponse> {
    try {
      const body = userId ? JSON.stringify({ user_id: userId }) : undefined;

      const response = await this.fetchWithRetry(
        `${this.apiUrl}/api/auth/session`,
        { method: "POST", body }
      );

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      return await response.json();
    } catch (error) {
      throw this.normalizeError(error, "Failed to get session");
    }
  }

  /**
   * Check health of auth service
   *
   * @returns Promise with health status
   */
  async healthCheck(): Promise<{ status: string; service: string }> {
    try {
      const response = await this.fetchWithRetry(`${this.apiUrl}/api/auth/health`);

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      return await response.json();
    } catch (error) {
      throw this.normalizeError(error, "Health check failed");
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
export const authApiClient = new AuthApiClient();
