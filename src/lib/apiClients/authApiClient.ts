/**
 * Auth API Client - Communicates with FastAPI backend auth service
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
  full_name?: string | null;
  phone?: string | null;
  avatar_url?: string | null;
  bio?: string | null;
  role: string;
  is_active: boolean;
  persona?: string | null;
  baseline_completed: boolean;
  baseline_score?: number | null;
  endline_completed: boolean;
  endline_score?: number | null;
  weak_modules?: string[] | null;
  baseline_attempt_count: number;
  endline_attempt_count: number;
  region?: string | null;
  sub_region?: string | null;
  punjab_cluster?: string | null;
  rawalpindi_cluster?: string | null;
  school_id?: string | null;
  teacher_ids?: string[] | null;
  qualifications?: unknown[] | null;
  experiences?: unknown[] | null;
  created_at: string;
  updated_at: string;
}

export interface ProfileUpdatePayload {
  full_name?: string;
  phone?: string;
  avatar_url?: string;
  bio?: string;
  role?: string;
  persona?: string;
  baseline_completed?: boolean;
  baseline_score?: number;
  endline_completed?: boolean;
  endline_score?: number;
  weak_modules?: string[];
  baseline_attempt_count?: number;
  endline_attempt_count?: number;
  region?: string;
  sub_region?: string;
  punjab_cluster?: string;
  rawalpindi_cluster?: string;
  school_id?: string;
  teacher_ids?: string[];
  qualifications?: unknown[];
  experiences?: unknown[];
}

export interface UserResponse {
  id: string;
  email: string;
  email_confirmed_at?: string;
  created_at: string;
  updated_at: string;
  profile?: UserProfile;
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

export interface CertificateData {
  id: string;
  user_id: string;
  certificate_id: string;
  persona?: string | null;
  issued_at?: string | null;
}

export interface ApiError extends Error {
  status?: number;
  code?: string;
  details?: Record<string, unknown>;
}

export class AuthApiClient {
  private apiUrl: string;
  private cache: Map<string, { data: unknown; timestamp: number }> = new Map();
  private cacheExpiry: number = 5 * 60 * 1000;

  constructor(apiUrl?: string) {
    this.apiUrl = apiUrl || import.meta.env.VITE_API_URL || "http://localhost:8000";
  }

  async signup(email: string, fullName?: string, phone?: string): Promise<SignupResponse> {
    const payload: SignupPayload = { email, full_name: fullName, phone };
    try {
      const response = await this.fetchWithRetry(`${this.apiUrl}/api/auth/signup`, {
        method: "POST",
        body: JSON.stringify(payload),
      });
      if (!response.ok) throw await this.handleErrorResponse(response);
      return await response.json() as SignupResponse;
    } catch (error) {
      throw this.normalizeError(error, "Failed to sign up user");
    }
  }

  async getUser(userId: string): Promise<UserResponse> {
    const cacheKey = `user_${userId}`;
    if (this.isCacheValid(cacheKey)) return this.cache.get(cacheKey)?.data as UserResponse;
    try {
      const response = await this.fetchWithRetry(`${this.apiUrl}/api/auth/users/${userId}`);
      if (!response.ok) throw await this.handleErrorResponse(response);
      const data = await response.json() as UserResponse;
      this.setCacheItem(cacheKey, data);
      return data;
    } catch (error) {
      throw this.normalizeError(error, `Failed to fetch user ${userId}`);
    }
  }

  async getUserByEmail(email: string): Promise<UserResponse> {
    const cacheKey = `user_email_${email}`;
    if (this.isCacheValid(cacheKey)) return this.cache.get(cacheKey)?.data as UserResponse;
    try {
      const response = await this.fetchWithRetry(`${this.apiUrl}/api/auth/users/email/${encodeURIComponent(email)}`);
      if (!response.ok) throw await this.handleErrorResponse(response);
      const data = await response.json() as UserResponse;
      this.setCacheItem(cacheKey, data);
      return data;
    } catch (error) {
      throw this.normalizeError(error, `Failed to fetch user ${email}`);
    }
  }

  async getProfile(userId: string): Promise<UserProfile> {
    const cacheKey = `profile_${userId}`;
    if (this.isCacheValid(cacheKey)) return this.cache.get(cacheKey)?.data as UserProfile;
    try {
      const response = await this.fetchWithRetry(`${this.apiUrl}/api/auth/profile/${userId}`);
      if (!response.ok) throw await this.handleErrorResponse(response);
      const data = await response.json() as UserProfile;
      this.setCacheItem(cacheKey, data);
      return data;
    } catch (error) {
      throw this.normalizeError(error, `Failed to fetch profile for user ${userId}`);
    }
  }

  async updateProfile(userId: string, payload: ProfileUpdatePayload): Promise<UserProfile> {
    this.invalidateCache(`profile_${userId}`);
    try {
      const response = await this.fetchWithRetry(`${this.apiUrl}/api/auth/profile/${userId}`, {
        method: "PUT",
        body: JSON.stringify(payload),
      });
      if (!response.ok) throw await this.handleErrorResponse(response);
      const data = await response.json() as UserProfile;
      this.setCacheItem(`profile_${userId}`, data);
      return data;
    } catch (error) {
      throw this.normalizeError(error, `Failed to update profile for user ${userId}`);
    }
  }

  async getRoles(userId: string): Promise<string[]> {
    try {
      const response = await this.fetchWithRetry(`${this.apiUrl}/api/auth/roles/${userId}`);
      if (!response.ok) throw await this.handleErrorResponse(response);
      const data = await response.json();
      return data.roles || [];
    } catch (error) {
      throw this.normalizeError(error, `Failed to fetch roles for user ${userId}`);
    }
  }

  async getCertificate(userId: string): Promise<CertificateData | null> {
    try {
      const response = await this.fetchWithRetry(`${this.apiUrl}/api/auth/certificate/${userId}`);
      if (response.status === 404) return null;
      if (!response.ok) throw await this.handleErrorResponse(response);
      return await response.json() as CertificateData;
    } catch (error) {
      if ((error as ApiError).status === 404) return null;
      throw this.normalizeError(error, `Failed to fetch certificate for user ${userId}`);
    }
  }

  async upsertCertificate(userId: string, certificateId: string, persona?: string): Promise<CertificateData> {
    try {
      const response = await this.fetchWithRetry(`${this.apiUrl}/api/auth/certificate`, {
        method: "POST",
        body: JSON.stringify({ user_id: userId, certificate_id: certificateId, persona }),
      });
      if (!response.ok) throw await this.handleErrorResponse(response);
      return await response.json() as CertificateData;
    } catch (error) {
      throw this.normalizeError(error, "Failed to upsert certificate");
    }
  }

  async confirmEmail(userId: string): Promise<{ message: string; email_confirmed_at: string }> {
    this.invalidateCache(`user_${userId}`);
    try {
      const response = await this.fetchWithRetry(`${this.apiUrl}/api/auth/email-confirm/${userId}`, { method: "POST" });
      if (!response.ok) throw await this.handleErrorResponse(response);
      return await response.json();
    } catch (error) {
      throw this.normalizeError(error, `Failed to confirm email for user ${userId}`);
    }
  }

  async deleteUser(userId: string): Promise<void> {
    this.invalidateCache(`user_${userId}`);
    this.invalidateCache(`profile_${userId}`);
    try {
      const response = await this.fetchWithRetry(`${this.apiUrl}/api/auth/users/${userId}`, { method: "DELETE" });
      if (!response.ok) throw await this.handleErrorResponse(response);
    } catch (error) {
      throw this.normalizeError(error, `Failed to delete user ${userId}`);
    }
  }

  async listUsers(limit: number = 100, offset: number = 0): Promise<ListUsersResponse> {
    try {
      const params = new URLSearchParams({ limit: String(limit), offset: String(offset) });
      const response = await this.fetchWithRetry(`${this.apiUrl}/api/auth/users?${params.toString()}`);
      if (!response.ok) throw await this.handleErrorResponse(response);
      return await response.json();
    } catch (error) {
      throw this.normalizeError(error, "Failed to list users");
    }
  }

  async getSession(userId?: string): Promise<SessionResponse> {
    try {
      const body = userId ? JSON.stringify({ user_id: userId }) : undefined;
      const response = await this.fetchWithRetry(`${this.apiUrl}/api/auth/session`, { method: "POST", body });
      if (!response.ok) throw await this.handleErrorResponse(response);
      return await response.json();
    } catch (error) {
      throw this.normalizeError(error, "Failed to get session");
    }
  }

  async healthCheck(): Promise<{ status: string; service: string }> {
    try {
      const response = await this.fetchWithRetry(`${this.apiUrl}/api/auth/health`);
      if (!response.ok) throw await this.handleErrorResponse(response);
      return await response.json();
    } catch (error) {
      throw this.normalizeError(error, "Health check failed");
    }
  }

  clearCache(): void {
    this.cache.clear();
  }

  private invalidateCache(key: string): void {
    this.cache.delete(key);
  }

  private isCacheValid(key: string): boolean {
    const item = this.cache.get(key);
    if (!item) return false;
    return Date.now() - item.timestamp < this.cacheExpiry;
  }

  private setCacheItem(key: string, data: unknown): void {
    this.cache.set(key, { data, timestamp: Date.now() });
  }

  private async fetchWithRetry(url: string, options?: RequestInit, maxRetries: number = 3, baseDelay: number = 1000): Promise<Response> {
    let lastError: Error | null = null;
    for (let attempt = 0; attempt < maxRetries; attempt++) {
      try {
        const response = await fetch(url, {
          ...options,
          headers: { "Content-Type": "application/json", ...options?.headers },
        });
        if (response.status >= 400 && response.status < 500) return response;
        if (response.status >= 500 && attempt < maxRetries - 1) {
          await this.sleep(baseDelay * Math.pow(2, attempt));
          continue;
        }
        return response;
      } catch (error) {
        lastError = error instanceof Error ? error : new Error(String(error));
        if (attempt < maxRetries - 1) {
          await this.sleep(baseDelay * Math.pow(2, attempt));
          continue;
        }
      }
    }
    throw lastError || new Error("Failed to fetch after maximum retries");
  }

  private async handleErrorResponse(response: Response): Promise<ApiError> {
    let errorData: Record<string, unknown> = {};
    try {
      const text = await response.text();
      if (text) errorData = JSON.parse(text);
    } catch { /* ignore */ }
    const error = new Error((errorData.detail as string) || `HTTP ${response.status}`) as ApiError;
    error.status = response.status;
    error.code = (errorData.code as string) || `HTTP_${response.status}`;
    error.details = errorData;
    return error;
  }

  private normalizeError(error: unknown, defaultMessage: string): ApiError {
    if (error instanceof Error && "status" in error) return error as ApiError;
    const apiError = new Error(error instanceof Error ? error.message : defaultMessage) as ApiError;
    apiError.code = "UNKNOWN_ERROR";
    return apiError;
  }

  private sleep(ms: number): Promise<void> {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }
}

// Export singleton instance
export const authApiClient = new AuthApiClient();
