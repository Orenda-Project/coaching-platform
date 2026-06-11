/**
 * Admin API Client - Communicates with FastAPI backend admin service
 *
 * Features:
 * - Admin User Management (create, list, retrieve, update, delete)
 * - Field Issue Tracking (create, list, retrieve, update, delete, filter)
 * - Region Hierarchy (create, list, retrieve, update, delete, active filter)
 * - Request caching with expiry
 * - Automatic retry on network errors
 * - Comprehensive error handling
 *
 * Usage:
 *   const client = new AdminApiClient("https://api.example.com");
 *   const admin = await client.createAdminUser({ user_id: "123", role: "super_admin" });
 *   const issue = await client.createFieldIssue({ description: "...", reported_by: "123" });
 *   const region = await client.createRegion({ name: "Punjab" });
 */

// ===== Type Definitions =====

export interface AdminUser {
  id: string;
  user_id: string;
  role: "super_admin" | "regional_admin";
  created_at: string;
  updated_at: string;
}

export interface AdminUserRequest {
  user_id: string;
  role: "super_admin" | "regional_admin";
}

export interface FieldIssue {
  id: string;
  description: string;
  status: "open" | "in_progress" | "resolved" | "closed";
  reported_by: string;
  assigned_to: string | null;
  created_at: string;
  updated_at: string;
  resolved_at: string | null;
}

export interface FieldIssueRequest {
  description: string;
  reported_by: string;
  assigned_to?: string;
}

export interface FieldIssueUpdate {
  description?: string;
  status?: "open" | "in_progress" | "resolved" | "closed";
  assigned_to?: string | null;
}

export interface Region {
  id: string;
  name: string;
  parent_id: string | null;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface RegionRequest {
  name: string;
  parent_id?: string;
}

export interface RegionUpdate {
  name?: string;
  parent_id?: string | null;
  is_active?: boolean;
}

export interface PaginationOptions {
  limit?: number;
  offset?: number;
}

export interface ListResponse<T> {
  data: T[];
  total: number;
  limit: number;
  offset: number;
}

export interface HealthResponse {
  status: "healthy" | "unhealthy";
  service: "admin";
}

export interface ApiError extends Error {
  status?: number;
  code?: string;
  details?: Record<string, unknown>;
}

/**
 * Admin API Client
 *
 * Handles all admin-related API calls with automatic retry,
 * error handling, and data caching.
 */
export class AdminApiClient {
  private apiUrl: string;
  private cache: Map<string, { data: unknown; timestamp: number }> = new Map();
  private cacheExpiry: number = 5 * 60 * 1000; // 5 minutes

  constructor(apiUrl?: string) {
    this.apiUrl = apiUrl || import.meta.env.VITE_API_URL || "http://localhost:8000";
  }

  // ===== Admin User Management =====

  /**
   * Create a new admin user
   *
   * @param request - Admin user request with user_id and role
   * @returns Promise with created admin user
   */
  async createAdminUser(request: AdminUserRequest): Promise<AdminUser> {
    try {
      this.invalidateListCaches("admin_users");

      const response = await this.fetchWithRetry(`${this.apiUrl}/api/admin/users`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(request),
      });

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      return await response.json();
    } catch (error) {
      throw this.normalizeError(error, "Failed to create admin user");
    }
  }

  /**
   * Get admin user by ID
   *
   * @param adminId - Admin user ID
   * @returns Promise with admin user
   */
  async getAdminUser(adminId: string): Promise<AdminUser> {
    const cacheKey = `admin_user_${adminId}`;

    if (this.isCacheValid(cacheKey)) {
      return this.cache.get(cacheKey)?.data as AdminUser;
    }

    try {
      const response = await this.fetchWithRetry(
        `${this.apiUrl}/api/admin/users/${adminId}`
      );

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      const data = await response.json();
      this.setCacheItem(cacheKey, data);
      return data;
    } catch (error) {
      throw this.normalizeError(error, "Failed to fetch admin user");
    }
  }

  /**
   * List all admin users with pagination
   *
   * @param options - Pagination options
   * @returns Promise with list of admin users
   */
  async listAdminUsers(options?: PaginationOptions): Promise<ListResponse<AdminUser>> {
    const cacheKey = `admin_users_list_${JSON.stringify(options || {})}`;

    if (this.isCacheValid(cacheKey)) {
      return this.cache.get(cacheKey)?.data as ListResponse<AdminUser>;
    }

    try {
      const params = this.buildQueryString(options);
      const url =
        params.length > 0
          ? `${this.apiUrl}/api/admin/users?${params}`
          : `${this.apiUrl}/api/admin/users`;

      const response = await this.fetchWithRetry(url);

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      const data = await response.json();
      this.setCacheItem(cacheKey, data);
      return data;
    } catch (error) {
      throw this.normalizeError(error, "Failed to fetch admin users");
    }
  }

  /**
   * Update admin user role
   *
   * @param adminId - Admin user ID
   * @param role - New role
   * @returns Promise with updated admin user
   */
  async updateAdminUserRole(
    adminId: string,
    role: "super_admin" | "regional_admin"
  ): Promise<AdminUser> {
    try {
      this.invalidateCache(`admin_user_${adminId}`);
      this.invalidateListCaches("admin_users");

      const response = await this.fetchWithRetry(
        `${this.apiUrl}/api/admin/users/${adminId}/role`,
        {
          method: "PUT",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({ role }),
        }
      );

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      return await response.json();
    } catch (error) {
      throw this.normalizeError(error, "Failed to update admin user role");
    }
  }

  /**
   * Delete admin user
   *
   * @param adminId - Admin user ID
   * @returns Promise that resolves when deleted
   */
  async deleteAdminUser(adminId: string): Promise<void> {
    try {
      this.invalidateCache(`admin_user_${adminId}`);
      this.invalidateListCaches("admin_users");

      const response = await this.fetchWithRetry(
        `${this.apiUrl}/api/admin/users/${adminId}`,
        {
          method: "DELETE",
        }
      );

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }
    } catch (error) {
      throw this.normalizeError(error, "Failed to delete admin user");
    }
  }

  // ===== Field Issue Management =====

  /**
   * Create a new field issue
   *
   * @param request - Field issue request
   * @returns Promise with created field issue
   */
  async createFieldIssue(request: FieldIssueRequest): Promise<FieldIssue> {
    try {
      this.invalidateListCaches("field_issues");

      const response = await this.fetchWithRetry(`${this.apiUrl}/api/admin/issues`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(request),
      });

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      return await response.json();
    } catch (error) {
      throw this.normalizeError(error, "Failed to create field issue");
    }
  }

  /**
   * Get field issue by ID
   *
   * @param issueId - Field issue ID
   * @returns Promise with field issue
   */
  async getFieldIssue(issueId: string): Promise<FieldIssue> {
    const cacheKey = `field_issue_${issueId}`;

    if (this.isCacheValid(cacheKey)) {
      return this.cache.get(cacheKey)?.data as FieldIssue;
    }

    try {
      const response = await this.fetchWithRetry(
        `${this.apiUrl}/api/admin/issues/${issueId}`
      );

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      const data = await response.json();
      this.setCacheItem(cacheKey, data);
      return data;
    } catch (error) {
      throw this.normalizeError(error, "Failed to fetch field issue");
    }
  }

  /**
   * List field issues with optional status filter
   *
   * @param options - Pagination options
   * @param status - Optional status filter
   * @returns Promise with list of field issues
   */
  async listFieldIssues(
    options?: PaginationOptions,
    status?: "open" | "in_progress" | "resolved" | "closed"
  ): Promise<ListResponse<FieldIssue>> {
    const cacheKey = `field_issues_list_${JSON.stringify(options || {})}_${status || "all"}`;

    if (this.isCacheValid(cacheKey)) {
      return this.cache.get(cacheKey)?.data as ListResponse<FieldIssue>;
    }

    try {
      const params = this.buildQueryString(options);
      const statusParam = status ? `status=${status}` : "";
      const separator =
        params.length > 0 && statusParam.length > 0 ? "&" : "";

      const queryString = [params, statusParam].filter((s) => s).join(separator);
      const url =
        queryString.length > 0
          ? `${this.apiUrl}/api/admin/issues?${queryString}`
          : `${this.apiUrl}/api/admin/issues`;

      const response = await this.fetchWithRetry(url);

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      const data = await response.json();
      this.setCacheItem(cacheKey, data);
      return data;
    } catch (error) {
      throw this.normalizeError(error, "Failed to fetch field issues");
    }
  }

  /**
   * Update field issue
   *
   * @param issueId - Field issue ID
   * @param updates - Partial field issue updates
   * @returns Promise with updated field issue
   */
  async updateFieldIssue(
    issueId: string,
    updates: FieldIssueUpdate
  ): Promise<FieldIssue> {
    try {
      this.invalidateCache(`field_issue_${issueId}`);
      this.invalidateListCaches("field_issues");

      const response = await this.fetchWithRetry(
        `${this.apiUrl}/api/admin/issues/${issueId}`,
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
      throw this.normalizeError(error, "Failed to update field issue");
    }
  }

  /**
   * Delete field issue
   *
   * @param issueId - Field issue ID
   * @returns Promise that resolves when deleted
   */
  async deleteFieldIssue(issueId: string): Promise<void> {
    try {
      this.invalidateCache(`field_issue_${issueId}`);
      this.invalidateListCaches("field_issues");

      const response = await this.fetchWithRetry(
        `${this.apiUrl}/api/admin/issues/${issueId}`,
        {
          method: "DELETE",
        }
      );

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }
    } catch (error) {
      throw this.normalizeError(error, "Failed to delete field issue");
    }
  }

  // ===== Region Management =====

  /**
   * Create a new region
   *
   * @param request - Region request
   * @returns Promise with created region
   */
  async createRegion(request: RegionRequest): Promise<Region> {
    try {
      this.invalidateListCaches("regions");

      const response = await this.fetchWithRetry(`${this.apiUrl}/api/admin/regions`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(request),
      });

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      return await response.json();
    } catch (error) {
      throw this.normalizeError(error, "Failed to create region");
    }
  }

  /**
   * Get region by ID
   *
   * @param regionId - Region ID
   * @returns Promise with region
   */
  async getRegion(regionId: string): Promise<Region> {
    const cacheKey = `region_${regionId}`;

    if (this.isCacheValid(cacheKey)) {
      return this.cache.get(cacheKey)?.data as Region;
    }

    try {
      const response = await this.fetchWithRetry(
        `${this.apiUrl}/api/admin/regions/${regionId}`
      );

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      const data = await response.json();
      this.setCacheItem(cacheKey, data);
      return data;
    } catch (error) {
      throw this.normalizeError(error, "Failed to fetch region");
    }
  }

  /**
   * List regions with optional active filter
   *
   * @param options - Pagination options
   * @param activeOnly - Filter by active status
   * @returns Promise with list of regions
   */
  async listRegions(
    options?: PaginationOptions,
    activeOnly?: boolean
  ): Promise<ListResponse<Region>> {
    const cacheKey = `regions_list_${JSON.stringify(options || {})}_${activeOnly ? "active" : "all"}`;

    if (this.isCacheValid(cacheKey)) {
      return this.cache.get(cacheKey)?.data as ListResponse<Region>;
    }

    try {
      const params = this.buildQueryString(options);
      const activeParam = activeOnly ? "active_only=true" : "";
      const separator =
        params.length > 0 && activeParam.length > 0 ? "&" : "";

      const queryString = [params, activeParam].filter((s) => s).join(separator);
      const url =
        queryString.length > 0
          ? `${this.apiUrl}/api/admin/regions?${queryString}`
          : `${this.apiUrl}/api/admin/regions`;

      const response = await this.fetchWithRetry(url);

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      const data = await response.json();
      this.setCacheItem(cacheKey, data);
      return data;
    } catch (error) {
      throw this.normalizeError(error, "Failed to fetch regions");
    }
  }

  /**
   * Update region
   *
   * @param regionId - Region ID
   * @param updates - Partial region updates
   * @returns Promise with updated region
   */
  async updateRegion(regionId: string, updates: RegionUpdate): Promise<Region> {
    try {
      this.invalidateCache(`region_${regionId}`);
      this.invalidateListCaches("regions");

      const response = await this.fetchWithRetry(
        `${this.apiUrl}/api/admin/regions/${regionId}`,
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
      throw this.normalizeError(error, "Failed to update region");
    }
  }

  /**
   * Delete region
   *
   * @param regionId - Region ID
   * @returns Promise that resolves when deleted
   */
  async deleteRegion(regionId: string): Promise<void> {
    try {
      this.invalidateCache(`region_${regionId}`);
      this.invalidateListCaches("regions");

      const response = await this.fetchWithRetry(
        `${this.apiUrl}/api/admin/regions/${regionId}`,
        {
          method: "DELETE",
        }
      );

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }
    } catch (error) {
      throw this.normalizeError(error, "Failed to delete region");
    }
  }

  // ===== Health Check =====

  /**
   * Check admin service health
   *
   * @returns Promise with health status
   */
  async healthCheck(): Promise<HealthResponse> {
    try {
      const response = await this.fetchWithRetry(
        `${this.apiUrl}/api/admin/health`
      );

      if (!response.ok) {
        throw await this.handleErrorResponse(response);
      }

      return await response.json();
    } catch (error) {
      throw this.normalizeError(error, "Failed to check health");
    }
  }

  // ===== Cache Management =====

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
   * Invalidate list cache by prefix
   */
  private invalidateListCaches(prefix: string): void {
    for (const key of Array.from(this.cache.keys())) {
      if (key.startsWith(`${prefix}_list_`)) {
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
export const adminApiClient = new AdminApiClient();
