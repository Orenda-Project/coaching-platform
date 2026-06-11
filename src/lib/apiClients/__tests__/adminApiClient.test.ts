/**
 * Admin API Client Tests
 *
 * Comprehensive test coverage for:
 * - Admin User Management (create, list, retrieve, update, delete)
 * - Field Issue Tracking (create, list, retrieve, update, delete, filter by status)
 * - Region Hierarchy (create, list, retrieve, update, delete, filter by active)
 * - Error handling (409 Conflict, 404 Not Found, 422 Validation, 400 Bad Request)
 * - Cache management and pagination
 * - Health check endpoint
 */

import { describe, it, expect, beforeEach, vi, afterEach } from "vitest";
import {
  AdminApiClient,
  type AdminUser,
  type FieldIssue,
  type Region,
  type AdminUserRequest,
  type FieldIssueRequest,
  type RegionRequest,
  type ListResponse,
  type ApiError,
} from "../adminApiClient";

describe("AdminApiClient", () => {
  let client: AdminApiClient;
  let fetchMock: ReturnType<typeof vi.fn>;

  beforeEach(() => {
    client = new AdminApiClient("http://localhost:8000");
    fetchMock = vi.fn();
    global.fetch = fetchMock;
  });

  afterEach(() => {
    vi.clearAllMocks();
    client.clearCache();
  });

  // ===== Admin User Management Tests =====
  describe("Admin User Management", () => {
    describe("createAdminUser", () => {
      it("should create a super_admin user", async () => {
        const request: AdminUserRequest = {
          user_id: "user-123",
          role: "super_admin",
        };

        const mockResponse: AdminUser = {
          id: "admin-1",
          user_id: "user-123",
          role: "super_admin",
          created_at: "2026-06-09T10:00:00Z",
          updated_at: "2026-06-09T10:00:00Z",
        };

        fetchMock.mockResolvedValueOnce({
          ok: true,
          status: 201,
          json: async () => mockResponse,
        });

        const result = await client.createAdminUser(request);

        expect(result.id).toBe("admin-1");
        expect(result.role).toBe("super_admin");
        expect(fetchMock).toHaveBeenCalledWith(
          "http://localhost:8000/api/admin/users",
          expect.objectContaining({
            method: "POST",
            body: JSON.stringify(request),
          })
        );
      });

      it("should create a regional_admin user", async () => {
        const request: AdminUserRequest = {
          user_id: "user-456",
          role: "regional_admin",
        };

        const mockResponse: AdminUser = {
          id: "admin-2",
          user_id: "user-456",
          role: "regional_admin",
          created_at: "2026-06-09T10:00:00Z",
          updated_at: "2026-06-09T10:00:00Z",
        };

        fetchMock.mockResolvedValueOnce({
          ok: true,
          status: 201,
          json: async () => mockResponse,
        });

        const result = await client.createAdminUser(request);

        expect(result.role).toBe("regional_admin");
      });

      it("should handle duplicate admin conflict", async () => {
        const request: AdminUserRequest = {
          user_id: "user-123",
          role: "super_admin",
        };

        fetchMock.mockResolvedValueOnce({
          ok: false,
          status: 409,
          text: async () =>
            JSON.stringify({ detail: "Admin user already exists" }),
        });

        await expect(client.createAdminUser(request)).rejects.toThrow(
          "Admin user already exists"
        );
      });

      it("should handle invalid role", async () => {
        const request = {
          user_id: "user-123",
          role: "invalid_role",
        } as unknown as AdminUserRequest;

        fetchMock.mockResolvedValueOnce({
          ok: false,
          status: 400,
          text: async () => JSON.stringify({ detail: "Invalid role" }),
        });

        await expect(client.createAdminUser(request)).rejects.toThrow(
          "Invalid role"
        );
      });
    });

    describe("getAdminUser", () => {
      it("should retrieve admin user by ID", async () => {
        const adminId = "admin-1";
        const mockResponse: AdminUser = {
          id: adminId,
          user_id: "user-123",
          role: "super_admin",
          created_at: "2026-06-09T10:00:00Z",
          updated_at: "2026-06-09T10:00:00Z",
        };

        fetchMock.mockResolvedValueOnce({
          ok: true,
          json: async () => mockResponse,
        });

        const result = await client.getAdminUser(adminId);

        expect(result.id).toBe(adminId);
        expect(result.role).toBe("super_admin");
        expect(fetchMock).toHaveBeenCalledWith(
          `http://localhost:8000/api/admin/users/${adminId}`,
          expect.any(Object)
        );
      });

      it("should cache admin user", async () => {
        const adminId = "admin-1";
        const mockResponse: AdminUser = {
          id: adminId,
          user_id: "user-123",
          role: "super_admin",
          created_at: "2026-06-09T10:00:00Z",
          updated_at: "2026-06-09T10:00:00Z",
        };

        fetchMock.mockResolvedValueOnce({
          ok: true,
          json: async () => mockResponse,
        });

        await client.getAdminUser(adminId);
        expect(fetchMock).toHaveBeenCalledTimes(1);

        await client.getAdminUser(adminId);
        expect(fetchMock).toHaveBeenCalledTimes(1); // Still 1, cached
      });

      it("should handle admin not found", async () => {
        const adminId = "nonexistent";

        fetchMock.mockResolvedValueOnce({
          ok: false,
          status: 404,
          text: async () => JSON.stringify({ detail: "Admin user not found" }),
        });

        await expect(client.getAdminUser(adminId)).rejects.toThrow(
          "Admin user not found"
        );
      });
    });

    describe("listAdminUsers", () => {
      it("should list all admin users with pagination", async () => {
        const mockResponse: ListResponse<AdminUser> = {
          data: [
            {
              id: "admin-1",
              user_id: "user-123",
              role: "super_admin",
              created_at: "2026-06-09T10:00:00Z",
              updated_at: "2026-06-09T10:00:00Z",
            },
            {
              id: "admin-2",
              user_id: "user-456",
              role: "regional_admin",
              created_at: "2026-06-09T11:00:00Z",
              updated_at: "2026-06-09T11:00:00Z",
            },
          ],
          total: 2,
          limit: 10,
          offset: 0,
        };

        fetchMock.mockResolvedValueOnce({
          ok: true,
          json: async () => mockResponse,
        });

        const result = await client.listAdminUsers({ limit: 10, offset: 0 });

        expect(result.data).toHaveLength(2);
        expect(result.total).toBe(2);
        expect(result.data[0].role).toBe("super_admin");
        expect(result.data[1].role).toBe("regional_admin");
      });

      it("should handle pagination parameters", async () => {
        const mockResponse: ListResponse<AdminUser> = {
          data: [],
          total: 10,
          limit: 5,
          offset: 5,
        };

        fetchMock.mockResolvedValueOnce({
          ok: true,
          json: async () => mockResponse,
        });

        await client.listAdminUsers({ limit: 5, offset: 5 });

        expect(fetchMock).toHaveBeenCalledWith(
          expect.stringContaining("limit=5"),
          expect.any(Object)
        );
        expect(fetchMock).toHaveBeenCalledWith(
          expect.stringContaining("offset=5"),
          expect.any(Object)
        );
      });

      it("should cache admin users list", async () => {
        const mockResponse: ListResponse<AdminUser> = {
          data: [],
          total: 0,
          limit: 10,
          offset: 0,
        };

        fetchMock.mockResolvedValueOnce({
          ok: true,
          json: async () => mockResponse,
        });

        await client.listAdminUsers({ limit: 10, offset: 0 });
        expect(fetchMock).toHaveBeenCalledTimes(1);

        await client.listAdminUsers({ limit: 10, offset: 0 });
        expect(fetchMock).toHaveBeenCalledTimes(1); // Cached
      });
    });

    describe("updateAdminUserRole", () => {
      it("should update admin user role", async () => {
        const adminId = "admin-1";
        const mockResponse: AdminUser = {
          id: adminId,
          user_id: "user-123",
          role: "regional_admin",
          created_at: "2026-06-09T10:00:00Z",
          updated_at: "2026-06-09T12:00:00Z",
        };

        fetchMock.mockResolvedValueOnce({
          ok: true,
          json: async () => mockResponse,
        });

        const result = await client.updateAdminUserRole(adminId, "regional_admin");

        expect(result.role).toBe("regional_admin");
        expect(fetchMock).toHaveBeenCalledWith(
          `http://localhost:8000/api/admin/users/${adminId}/role`,
          expect.objectContaining({
            method: "PUT",
            body: JSON.stringify({ role: "regional_admin" }),
          })
        );
      });

      it("should invalidate cache after update", async () => {
        const adminId = "admin-1";

        // First get to populate cache
        fetchMock.mockResolvedValueOnce({
          ok: true,
          json: async () => ({
            id: adminId,
            user_id: "user-123",
            role: "super_admin",
            created_at: "2026-06-09T10:00:00Z",
            updated_at: "2026-06-09T10:00:00Z",
          }),
        });

        await client.getAdminUser(adminId);
        expect(fetchMock).toHaveBeenCalledTimes(1);

        // Now update
        fetchMock.mockResolvedValueOnce({
          ok: true,
          json: async () => ({
            id: adminId,
            user_id: "user-123",
            role: "regional_admin",
            created_at: "2026-06-09T10:00:00Z",
            updated_at: "2026-06-09T12:00:00Z",
          }),
        });

        await client.updateAdminUserRole(adminId, "regional_admin");
        expect(fetchMock).toHaveBeenCalledTimes(2);

        // Fetch again should hit API, not cache
        fetchMock.mockResolvedValueOnce({
          ok: true,
          json: async () => ({
            id: adminId,
            user_id: "user-123",
            role: "regional_admin",
            created_at: "2026-06-09T10:00:00Z",
            updated_at: "2026-06-09T12:00:00Z",
          }),
        });

        await client.getAdminUser(adminId);
        expect(fetchMock).toHaveBeenCalledTimes(3); // Cache was invalidated
      });
    });

    describe("deleteAdminUser", () => {
      it("should delete admin user", async () => {
        const adminId = "admin-1";

        fetchMock.mockResolvedValueOnce({
          ok: true,
          status: 204,
        });

        await client.deleteAdminUser(adminId);

        expect(fetchMock).toHaveBeenCalledWith(
          `http://localhost:8000/api/admin/users/${adminId}`,
          expect.objectContaining({
            method: "DELETE",
          })
        );
      });

      it("should handle admin not found on delete", async () => {
        const adminId = "nonexistent";

        fetchMock.mockResolvedValueOnce({
          ok: false,
          status: 404,
          text: async () => JSON.stringify({ detail: "Admin user not found" }),
        });

        await expect(client.deleteAdminUser(adminId)).rejects.toThrow(
          "Admin user not found"
        );
      });
    });
  });

  // ===== Field Issue Management Tests =====
  describe("Field Issue Management", () => {
    describe("createFieldIssue", () => {
      it("should create field issue without assignee", async () => {
        const request: FieldIssueRequest = {
          description: "Teachers unable to access materials in Lahore",
          reported_by: "coach-123",
        };

        const mockResponse: FieldIssue = {
          id: "issue-1",
          description: request.description,
          status: "open",
          reported_by: "coach-123",
          assigned_to: null,
          created_at: "2026-06-09T10:00:00Z",
          updated_at: "2026-06-09T10:00:00Z",
          resolved_at: null,
        };

        fetchMock.mockResolvedValueOnce({
          ok: true,
          status: 201,
          json: async () => mockResponse,
        });

        const result = await client.createFieldIssue(request);

        expect(result.id).toBe("issue-1");
        expect(result.status).toBe("open");
        expect(result.assigned_to).toBeNull();
      });

      it("should create field issue with assignee", async () => {
        const request: FieldIssueRequest = {
          description: "Teachers unable to access materials in Lahore",
          reported_by: "coach-123",
          assigned_to: "admin-456",
        };

        const mockResponse: FieldIssue = {
          id: "issue-1",
          description: request.description,
          status: "open",
          reported_by: "coach-123",
          assigned_to: "admin-456",
          created_at: "2026-06-09T10:00:00Z",
          updated_at: "2026-06-09T10:00:00Z",
          resolved_at: null,
        };

        fetchMock.mockResolvedValueOnce({
          ok: true,
          status: 201,
          json: async () => mockResponse,
        });

        const result = await client.createFieldIssue(request);

        expect(result.assigned_to).toBe("admin-456");
      });

      it("should handle short description validation error", async () => {
        const request: FieldIssueRequest = {
          description: "Too short",
          reported_by: "coach-123",
        };

        fetchMock.mockResolvedValueOnce({
          ok: false,
          status: 422,
          text: async () =>
            JSON.stringify({
              detail: "Description must be at least 10 characters",
            }),
        });

        await expect(client.createFieldIssue(request)).rejects.toThrow(
          "Description must be at least 10 characters"
        );
      });
    });

    describe("getFieldIssue", () => {
      it("should retrieve field issue by ID", async () => {
        const issueId = "issue-1";
        const mockResponse: FieldIssue = {
          id: issueId,
          description: "Teachers unable to access materials in Lahore",
          status: "open",
          reported_by: "coach-123",
          assigned_to: "admin-456",
          created_at: "2026-06-09T10:00:00Z",
          updated_at: "2026-06-09T10:00:00Z",
          resolved_at: null,
        };

        fetchMock.mockResolvedValueOnce({
          ok: true,
          json: async () => mockResponse,
        });

        const result = await client.getFieldIssue(issueId);

        expect(result.id).toBe(issueId);
        expect(result.status).toBe("open");
      });

      it("should cache field issue", async () => {
        const issueId = "issue-1";
        const mockResponse: FieldIssue = {
          id: issueId,
          description: "Test issue",
          status: "open",
          reported_by: "coach-123",
          assigned_to: null,
          created_at: "2026-06-09T10:00:00Z",
          updated_at: "2026-06-09T10:00:00Z",
          resolved_at: null,
        };

        fetchMock.mockResolvedValueOnce({
          ok: true,
          json: async () => mockResponse,
        });

        await client.getFieldIssue(issueId);
        expect(fetchMock).toHaveBeenCalledTimes(1);

        await client.getFieldIssue(issueId);
        expect(fetchMock).toHaveBeenCalledTimes(1); // Cached
      });

      it("should handle issue not found", async () => {
        const issueId = "nonexistent";

        fetchMock.mockResolvedValueOnce({
          ok: false,
          status: 404,
          text: async () => JSON.stringify({ detail: "Field issue not found" }),
        });

        await expect(client.getFieldIssue(issueId)).rejects.toThrow(
          "Field issue not found"
        );
      });
    });

    describe("listFieldIssues", () => {
      it("should list all field issues", async () => {
        const mockResponse: ListResponse<FieldIssue> = {
          data: [
            {
              id: "issue-1",
              description: "Issue 1",
              status: "open",
              reported_by: "coach-123",
              assigned_to: null,
              created_at: "2026-06-09T10:00:00Z",
              updated_at: "2026-06-09T10:00:00Z",
              resolved_at: null,
            },
            {
              id: "issue-2",
              description: "Issue 2",
              status: "in_progress",
              reported_by: "coach-456",
              assigned_to: "admin-789",
              created_at: "2026-06-09T11:00:00Z",
              updated_at: "2026-06-09T11:00:00Z",
              resolved_at: null,
            },
          ],
          total: 2,
          limit: 10,
          offset: 0,
        };

        fetchMock.mockResolvedValueOnce({
          ok: true,
          json: async () => mockResponse,
        });

        const result = await client.listFieldIssues({ limit: 10, offset: 0 });

        expect(result.data).toHaveLength(2);
        expect(result.total).toBe(2);
      });

      it("should filter field issues by status", async () => {
        const mockResponse: ListResponse<FieldIssue> = {
          data: [
            {
              id: "issue-1",
              description: "Issue 1",
              status: "open",
              reported_by: "coach-123",
              assigned_to: null,
              created_at: "2026-06-09T10:00:00Z",
              updated_at: "2026-06-09T10:00:00Z",
              resolved_at: null,
            },
          ],
          total: 1,
          limit: 10,
          offset: 0,
        };

        fetchMock.mockResolvedValueOnce({
          ok: true,
          json: async () => mockResponse,
        });

        const result = await client.listFieldIssues(
          { limit: 10, offset: 0 },
          "open"
        );

        expect(result.data).toHaveLength(1);
        expect(result.data[0].status).toBe("open");
        expect(fetchMock).toHaveBeenCalledWith(
          expect.stringContaining("status=open"),
          expect.any(Object)
        );
      });

      it("should support all status filters", async () => {
        const statuses: Array<"open" | "in_progress" | "resolved" | "closed"> = [
          "open",
          "in_progress",
          "resolved",
          "closed",
        ];

        for (const status of statuses) {
          fetchMock.mockResolvedValueOnce({
            ok: true,
            json: async () => ({ data: [], total: 0, limit: 10, offset: 0 }),
          });

          await client.listFieldIssues({ limit: 10, offset: 0 }, status);

          expect(fetchMock).toHaveBeenCalledWith(
            expect.stringContaining(`status=${status}`),
            expect.any(Object)
          );
        }
      });
    });

    describe("updateFieldIssue", () => {
      it("should update field issue description", async () => {
        const issueId = "issue-1";
        const mockResponse: FieldIssue = {
          id: issueId,
          description: "Updated description",
          status: "open",
          reported_by: "coach-123",
          assigned_to: null,
          created_at: "2026-06-09T10:00:00Z",
          updated_at: "2026-06-09T12:00:00Z",
          resolved_at: null,
        };

        fetchMock.mockResolvedValueOnce({
          ok: true,
          json: async () => mockResponse,
        });

        const result = await client.updateFieldIssue(issueId, {
          description: "Updated description",
        });

        expect(result.description).toBe("Updated description");
      });

      it("should update field issue status to resolved and set resolved_at", async () => {
        const issueId = "issue-1";
        const mockResponse: FieldIssue = {
          id: issueId,
          description: "Issue resolved",
          status: "resolved",
          reported_by: "coach-123",
          assigned_to: "admin-456",
          created_at: "2026-06-09T10:00:00Z",
          updated_at: "2026-06-09T13:00:00Z",
          resolved_at: "2026-06-09T13:00:00Z", // Auto-set
        };

        fetchMock.mockResolvedValueOnce({
          ok: true,
          json: async () => mockResponse,
        });

        const result = await client.updateFieldIssue(issueId, {
          status: "resolved",
        });

        expect(result.status).toBe("resolved");
        expect(result.resolved_at).not.toBeNull();
      });

      it("should update field issue assignee", async () => {
        const issueId = "issue-1";
        const mockResponse: FieldIssue = {
          id: issueId,
          description: "Issue 1",
          status: "in_progress",
          reported_by: "coach-123",
          assigned_to: "admin-789",
          created_at: "2026-06-09T10:00:00Z",
          updated_at: "2026-06-09T12:00:00Z",
          resolved_at: null,
        };

        fetchMock.mockResolvedValueOnce({
          ok: true,
          json: async () => mockResponse,
        });

        const result = await client.updateFieldIssue(issueId, {
          assigned_to: "admin-789",
        });

        expect(result.assigned_to).toBe("admin-789");
      });

      it("should invalidate cache after update", async () => {
        const issueId = "issue-1";

        // Get to cache
        fetchMock.mockResolvedValueOnce({
          ok: true,
          json: async () => ({
            id: issueId,
            description: "Original",
            status: "open",
            reported_by: "coach-123",
            assigned_to: null,
            created_at: "2026-06-09T10:00:00Z",
            updated_at: "2026-06-09T10:00:00Z",
            resolved_at: null,
          }),
        });

        await client.getFieldIssue(issueId);
        expect(fetchMock).toHaveBeenCalledTimes(1);

        // Update
        fetchMock.mockResolvedValueOnce({
          ok: true,
          json: async () => ({
            id: issueId,
            description: "Updated",
            status: "open",
            reported_by: "coach-123",
            assigned_to: null,
            created_at: "2026-06-09T10:00:00Z",
            updated_at: "2026-06-09T12:00:00Z",
            resolved_at: null,
          }),
        });

        await client.updateFieldIssue(issueId, {
          description: "Updated",
        });
        expect(fetchMock).toHaveBeenCalledTimes(2);

        // Get again - should fetch, not cache
        fetchMock.mockResolvedValueOnce({
          ok: true,
          json: async () => ({
            id: issueId,
            description: "Updated",
            status: "open",
            reported_by: "coach-123",
            assigned_to: null,
            created_at: "2026-06-09T10:00:00Z",
            updated_at: "2026-06-09T12:00:00Z",
            resolved_at: null,
          }),
        });

        await client.getFieldIssue(issueId);
        expect(fetchMock).toHaveBeenCalledTimes(3); // Cache invalidated
      });
    });

    describe("deleteFieldIssue", () => {
      it("should delete field issue", async () => {
        const issueId = "issue-1";

        fetchMock.mockResolvedValueOnce({
          ok: true,
          status: 204,
        });

        await client.deleteFieldIssue(issueId);

        expect(fetchMock).toHaveBeenCalledWith(
          `http://localhost:8000/api/admin/issues/${issueId}`,
          expect.objectContaining({
            method: "DELETE",
          })
        );
      });

      it("should handle issue not found on delete", async () => {
        const issueId = "nonexistent";

        fetchMock.mockResolvedValueOnce({
          ok: false,
          status: 404,
          text: async () => JSON.stringify({ detail: "Field issue not found" }),
        });

        await expect(client.deleteFieldIssue(issueId)).rejects.toThrow(
          "Field issue not found"
        );
      });
    });
  });

  // ===== Region Management Tests =====
  describe("Region Management", () => {
    describe("createRegion", () => {
      it("should create region without parent", async () => {
        const request: RegionRequest = {
          name: "Pakistan",
        };

        const mockResponse: Region = {
          id: "region-1",
          name: "Pakistan",
          parent_id: null,
          is_active: true,
          created_at: "2026-06-09T10:00:00Z",
          updated_at: "2026-06-09T10:00:00Z",
        };

        fetchMock.mockResolvedValueOnce({
          ok: true,
          status: 201,
          json: async () => mockResponse,
        });

        const result = await client.createRegion(request);

        expect(result.id).toBe("region-1");
        expect(result.name).toBe("Pakistan");
        expect(result.parent_id).toBeNull();
      });

      it("should create region with parent", async () => {
        const request: RegionRequest = {
          name: "Punjab",
          parent_id: "region-1",
        };

        const mockResponse: Region = {
          id: "region-2",
          name: "Punjab",
          parent_id: "region-1",
          is_active: true,
          created_at: "2026-06-09T10:00:00Z",
          updated_at: "2026-06-09T10:00:00Z",
        };

        fetchMock.mockResolvedValueOnce({
          ok: true,
          status: 201,
          json: async () => mockResponse,
        });

        const result = await client.createRegion(request);

        expect(result.parent_id).toBe("region-1");
      });

      it("should handle duplicate region name", async () => {
        const request: RegionRequest = {
          name: "Pakistan",
        };

        fetchMock.mockResolvedValueOnce({
          ok: false,
          status: 409,
          text: async () =>
            JSON.stringify({ detail: "Region name already exists" }),
        });

        await expect(client.createRegion(request)).rejects.toThrow(
          "Region name already exists"
        );
      });
    });

    describe("getRegion", () => {
      it("should retrieve region by ID", async () => {
        const regionId = "region-1";
        const mockResponse: Region = {
          id: regionId,
          name: "Pakistan",
          parent_id: null,
          is_active: true,
          created_at: "2026-06-09T10:00:00Z",
          updated_at: "2026-06-09T10:00:00Z",
        };

        fetchMock.mockResolvedValueOnce({
          ok: true,
          json: async () => mockResponse,
        });

        const result = await client.getRegion(regionId);

        expect(result.id).toBe(regionId);
        expect(result.name).toBe("Pakistan");
      });

      it("should cache region", async () => {
        const regionId = "region-1";
        const mockResponse: Region = {
          id: regionId,
          name: "Pakistan",
          parent_id: null,
          is_active: true,
          created_at: "2026-06-09T10:00:00Z",
          updated_at: "2026-06-09T10:00:00Z",
        };

        fetchMock.mockResolvedValueOnce({
          ok: true,
          json: async () => mockResponse,
        });

        await client.getRegion(regionId);
        expect(fetchMock).toHaveBeenCalledTimes(1);

        await client.getRegion(regionId);
        expect(fetchMock).toHaveBeenCalledTimes(1); // Cached
      });

      it("should handle region not found", async () => {
        const regionId = "nonexistent";

        fetchMock.mockResolvedValueOnce({
          ok: false,
          status: 404,
          text: async () => JSON.stringify({ detail: "Region not found" }),
        });

        await expect(client.getRegion(regionId)).rejects.toThrow(
          "Region not found"
        );
      });
    });

    describe("listRegions", () => {
      it("should list all regions", async () => {
        const mockResponse: ListResponse<Region> = {
          data: [
            {
              id: "region-1",
              name: "Pakistan",
              parent_id: null,
              is_active: true,
              created_at: "2026-06-09T10:00:00Z",
              updated_at: "2026-06-09T10:00:00Z",
            },
            {
              id: "region-2",
              name: "Punjab",
              parent_id: "region-1",
              is_active: true,
              created_at: "2026-06-09T10:00:00Z",
              updated_at: "2026-06-09T10:00:00Z",
            },
          ],
          total: 2,
          limit: 10,
          offset: 0,
        };

        fetchMock.mockResolvedValueOnce({
          ok: true,
          json: async () => mockResponse,
        });

        const result = await client.listRegions({ limit: 10, offset: 0 });

        expect(result.data).toHaveLength(2);
        expect(result.total).toBe(2);
      });

      it("should filter regions by active status", async () => {
        const mockResponse: ListResponse<Region> = {
          data: [
            {
              id: "region-1",
              name: "Pakistan",
              parent_id: null,
              is_active: true,
              created_at: "2026-06-09T10:00:00Z",
              updated_at: "2026-06-09T10:00:00Z",
            },
          ],
          total: 1,
          limit: 10,
          offset: 0,
        };

        fetchMock.mockResolvedValueOnce({
          ok: true,
          json: async () => mockResponse,
        });

        const result = await client.listRegions(
          { limit: 10, offset: 0 },
          true
        );

        expect(result.data).toHaveLength(1);
        expect(result.data[0].is_active).toBe(true);
        expect(fetchMock).toHaveBeenCalledWith(
          expect.stringContaining("active_only=true"),
          expect.any(Object)
        );
      });

      it("should cache regions list", async () => {
        const mockResponse: ListResponse<Region> = {
          data: [],
          total: 0,
          limit: 10,
          offset: 0,
        };

        fetchMock.mockResolvedValueOnce({
          ok: true,
          json: async () => mockResponse,
        });

        await client.listRegions({ limit: 10, offset: 0 });
        expect(fetchMock).toHaveBeenCalledTimes(1);

        await client.listRegions({ limit: 10, offset: 0 });
        expect(fetchMock).toHaveBeenCalledTimes(1); // Cached
      });
    });

    describe("updateRegion", () => {
      it("should update region name", async () => {
        const regionId = "region-1";
        const mockResponse: Region = {
          id: regionId,
          name: "Islamic Republic of Pakistan",
          parent_id: null,
          is_active: true,
          created_at: "2026-06-09T10:00:00Z",
          updated_at: "2026-06-09T12:00:00Z",
        };

        fetchMock.mockResolvedValueOnce({
          ok: true,
          json: async () => mockResponse,
        });

        const result = await client.updateRegion(regionId, {
          name: "Islamic Republic of Pakistan",
        });

        expect(result.name).toBe("Islamic Republic of Pakistan");
      });

      it("should update region active status", async () => {
        const regionId = "region-1";
        const mockResponse: Region = {
          id: regionId,
          name: "Pakistan",
          parent_id: null,
          is_active: false,
          created_at: "2026-06-09T10:00:00Z",
          updated_at: "2026-06-09T12:00:00Z",
        };

        fetchMock.mockResolvedValueOnce({
          ok: true,
          json: async () => mockResponse,
        });

        const result = await client.updateRegion(regionId, {
          is_active: false,
        });

        expect(result.is_active).toBe(false);
      });

      it("should invalidate cache after update", async () => {
        const regionId = "region-1";

        // Get to cache
        fetchMock.mockResolvedValueOnce({
          ok: true,
          json: async () => ({
            id: regionId,
            name: "Pakistan",
            parent_id: null,
            is_active: true,
            created_at: "2026-06-09T10:00:00Z",
            updated_at: "2026-06-09T10:00:00Z",
          }),
        });

        await client.getRegion(regionId);
        expect(fetchMock).toHaveBeenCalledTimes(1);

        // Update
        fetchMock.mockResolvedValueOnce({
          ok: true,
          json: async () => ({
            id: regionId,
            name: "Pakistan Updated",
            parent_id: null,
            is_active: true,
            created_at: "2026-06-09T10:00:00Z",
            updated_at: "2026-06-09T12:00:00Z",
          }),
        });

        await client.updateRegion(regionId, {
          name: "Pakistan Updated",
        });
        expect(fetchMock).toHaveBeenCalledTimes(2);

        // Get again - should fetch, not cache
        fetchMock.mockResolvedValueOnce({
          ok: true,
          json: async () => ({
            id: regionId,
            name: "Pakistan Updated",
            parent_id: null,
            is_active: true,
            created_at: "2026-06-09T10:00:00Z",
            updated_at: "2026-06-09T12:00:00Z",
          }),
        });

        await client.getRegion(regionId);
        expect(fetchMock).toHaveBeenCalledTimes(3); // Cache invalidated
      });
    });

    describe("deleteRegion", () => {
      it("should delete region", async () => {
        const regionId = "region-1";

        fetchMock.mockResolvedValueOnce({
          ok: true,
          status: 204,
        });

        await client.deleteRegion(regionId);

        expect(fetchMock).toHaveBeenCalledWith(
          `http://localhost:8000/api/admin/regions/${regionId}`,
          expect.objectContaining({
            method: "DELETE",
          })
        );
      });

      it("should handle region not found on delete", async () => {
        const regionId = "nonexistent";

        fetchMock.mockResolvedValueOnce({
          ok: false,
          status: 404,
          text: async () => JSON.stringify({ detail: "Region not found" }),
        });

        await expect(client.deleteRegion(regionId)).rejects.toThrow(
          "Region not found"
        );
      });
    });
  });

  // ===== Health Check Tests =====
  describe("Health Check", () => {
    it("should check admin service health", async () => {
      const mockResponse = {
        status: "healthy",
        service: "admin",
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await client.healthCheck();

      expect(result.status).toBe("healthy");
      expect(result.service).toBe("admin");
      expect(fetchMock).toHaveBeenCalledWith(
        "http://localhost:8000/api/admin/health",
        expect.any(Object)
      );
    });
  });

  // ===== Error Handling Tests =====
  describe("Error Handling", () => {
    it("should handle 400 Bad Request", async () => {
      fetchMock.mockResolvedValueOnce({
        ok: false,
        status: 400,
        text: async () => JSON.stringify({ detail: "Invalid request" }),
      });

      await expect(client.healthCheck()).rejects.toThrow("Invalid request");
    });

    it("should handle network errors with retry", async () => {
      let attempts = 0;
      fetchMock.mockImplementation(() => {
        attempts++;
        if (attempts < 3) {
          throw new Error("Network error");
        }
        return Promise.resolve({
          ok: true,
          json: async () => ({ status: "healthy", service: "admin" }),
        });
      });

      const result = await client.healthCheck();
      expect(result.status).toBe("healthy");
    });

    it("should normalize error objects", async () => {
      // Mock all 3 retry attempts to return 500
      fetchMock.mockResolvedValue({
        ok: false,
        status: 500,
        text: async () => JSON.stringify({ detail: "Server error" }),
      });

      try {
        await client.healthCheck();
        expect.fail("Should have thrown an error");
      } catch (error) {
        expect(error).toBeInstanceOf(Error);
        const apiError = error as ApiError;
        expect(apiError.message).toContain("Server error");
        expect(apiError.code).toBe("HTTP_500");
      }
    });
  });

  // ===== Cache Management Tests =====
  describe("Cache Management", () => {
    it("should clear all cache", async () => {
      const mockResponse = { id: "admin-1", user_id: "user-123", role: "super_admin", created_at: "2026-06-09T10:00:00Z", updated_at: "2026-06-09T10:00:00Z" };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      await client.getAdminUser("admin-1");
      expect(fetchMock).toHaveBeenCalledTimes(1);

      client.clearCache();

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      await client.getAdminUser("admin-1");
      expect(fetchMock).toHaveBeenCalledTimes(2); // Cache was cleared
    });
  });
});
