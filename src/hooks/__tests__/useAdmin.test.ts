/**
 * useAdmin Hook Tests
 *
 * Comprehensive test coverage for:
 * - Admin User state management
 * - Field Issue state management
 * - Region state management
 * - Error handling
 * - Loading states
 * - Cache management
 */

import { describe, it, expect, beforeEach, vi, afterEach } from "vitest";
import { renderHook, act, waitFor } from "@testing-library/react";
import { useAdmin } from "../useAdmin";
import type { AdminUser, FieldIssue, Region } from "@/lib/apiClients/adminApiClient";

// Mock the admin API client
vi.mock("@/lib/apiClients/adminApiClient", () => ({
  adminApiClient: {
    createAdminUser: vi.fn(),
    getAdminUser: vi.fn(),
    listAdminUsers: vi.fn(),
    updateAdminUserRole: vi.fn(),
    deleteAdminUser: vi.fn(),
    createFieldIssue: vi.fn(),
    getFieldIssue: vi.fn(),
    listFieldIssues: vi.fn(),
    updateFieldIssue: vi.fn(),
    deleteFieldIssue: vi.fn(),
    createRegion: vi.fn(),
    getRegion: vi.fn(),
    listRegions: vi.fn(),
    updateRegion: vi.fn(),
    deleteRegion: vi.fn(),
    healthCheck: vi.fn(),
    clearCache: vi.fn(),
  },
}));

import { adminApiClient } from "@/lib/apiClients/adminApiClient";

describe("useAdmin Hook", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  afterEach(() => {
    vi.clearAllMocks();
  });

  // ===== Initial State Tests =====
  describe("Initial State", () => {
    it("should initialize with empty state", () => {
      const { result } = renderHook(() => useAdmin());

      expect(result.current.admins).toEqual([]);
      expect(result.current.selectedAdmin).toBeNull();
      expect(result.current.adminLoading).toBe(false);
      expect(result.current.adminError).toBeNull();

      expect(result.current.issues).toEqual([]);
      expect(result.current.selectedIssue).toBeNull();
      expect(result.current.issueLoading).toBe(false);
      expect(result.current.issueError).toBeNull();

      expect(result.current.regions).toEqual([]);
      expect(result.current.selectedRegion).toBeNull();
      expect(result.current.regionLoading).toBe(false);
      expect(result.current.regionError).toBeNull();
    });
  });

  // ===== Admin User Management Tests =====
  describe("Admin User Management", () => {
    describe("loadAdmins", () => {
      it("should load list of admin users", async () => {
        const mockAdmins: AdminUser[] = [
          {
            id: "admin-1",
            user_id: "user-123",
            role: "super_admin",
            created_at: "2026-06-09T10:00:00Z",
            updated_at: "2026-06-09T10:00:00Z",
          },
        ];

        vi.mocked(adminApiClient.listAdminUsers).mockResolvedValueOnce({
          data: mockAdmins,
          total: 1,
          limit: 10,
          offset: 0,
        });

        const { result } = renderHook(() => useAdmin());

        act(() => {
          result.current.loadAdmins({ limit: 10, offset: 0 });
        });

        await waitFor(() => {
          expect(result.current.adminLoading).toBe(false);
        });

        expect(result.current.admins).toHaveLength(1);
        expect(result.current.admins[0].id).toBe("admin-1");
        expect(result.current.adminError).toBeNull();
      });

      it("should handle loading error", async () => {
        const error = new Error("Failed to fetch admins");

        vi.mocked(adminApiClient.listAdminUsers).mockRejectedValueOnce(error);

        const { result } = renderHook(() => useAdmin());

        await act(async () => {
          try {
            await result.current.loadAdmins({ limit: 10, offset: 0 });
          } catch {
            // Error is expected and stored in state
          }
        });

        expect(result.current.adminLoading).toBe(false);
        expect(result.current.adminError).not.toBeNull();
        expect(result.current.admins).toEqual([]);
      });

      it("should set loading state during fetch", async () => {
        vi.mocked(adminApiClient.listAdminUsers).mockImplementation(
          () =>
            new Promise((resolve) =>
              setTimeout(
                () =>
                  resolve({
                    data: [],
                    total: 0,
                    limit: 10,
                    offset: 0,
                  }),
                100
              )
            )
        );

        const { result } = renderHook(() => useAdmin());

        act(() => {
          result.current.loadAdmins({ limit: 10, offset: 0 });
        });

        expect(result.current.adminLoading).toBe(true);

        await waitFor(() => {
          expect(result.current.adminLoading).toBe(false);
        });
      });
    });

    describe("selectAdmin", () => {
      it("should select an admin user", async () => {
        const mockAdmin: AdminUser = {
          id: "admin-1",
          user_id: "user-123",
          role: "super_admin",
          created_at: "2026-06-09T10:00:00Z",
          updated_at: "2026-06-09T10:00:00Z",
        };

        vi.mocked(adminApiClient.getAdminUser).mockResolvedValueOnce(mockAdmin);

        const { result } = renderHook(() => useAdmin());

        act(() => {
          result.current.selectAdmin("admin-1");
        });

        await waitFor(() => {
          expect(result.current.adminLoading).toBe(false);
        });

        expect(result.current.selectedAdmin).toEqual(mockAdmin);
        expect(result.current.adminError).toBeNull();
      });

      it("should handle select error", async () => {
        const error = new Error("Admin not found");

        vi.mocked(adminApiClient.getAdminUser).mockRejectedValueOnce(error);

        const { result } = renderHook(() => useAdmin());

        await act(async () => {
          try {
            await result.current.selectAdmin("nonexistent");
          } catch {
            // Expected error
          }
        });

        expect(result.current.adminLoading).toBe(false);
        expect(result.current.adminError).not.toBeNull();
        expect(result.current.selectedAdmin).toBeNull();
      });
    });

    describe("createAdmin", () => {
      it("should create a new admin user", async () => {
        const newAdmin: AdminUser = {
          id: "admin-2",
          user_id: "user-456",
          role: "regional_admin",
          created_at: "2026-06-09T10:00:00Z",
          updated_at: "2026-06-09T10:00:00Z",
        };

        vi.mocked(adminApiClient.createAdminUser).mockResolvedValueOnce(newAdmin);

        const { result } = renderHook(() => useAdmin());

        act(() => {
          result.current.createAdmin({
            user_id: "user-456",
            role: "regional_admin",
          });
        });

        await waitFor(() => {
          expect(result.current.adminLoading).toBe(false);
        });

        expect(result.current.selectedAdmin).toEqual(newAdmin);
        expect(result.current.adminError).toBeNull();
      });

      it("should handle creation error", async () => {
        const error = new Error("User already admin");

        vi.mocked(adminApiClient.createAdminUser).mockRejectedValueOnce(error);

        const { result } = renderHook(() => useAdmin());

        await act(async () => {
          try {
            await result.current.createAdmin({
              user_id: "user-456",
              role: "regional_admin",
            });
          } catch {
            // Error is expected and stored in state
          }
        });

        expect(result.current.adminLoading).toBe(false);
        expect(result.current.adminError).not.toBeNull();
      });
    });

    describe("updateAdminRole", () => {
      it("should update admin role", async () => {
        const updatedAdmin: AdminUser = {
          id: "admin-1",
          user_id: "user-123",
          role: "regional_admin",
          created_at: "2026-06-09T10:00:00Z",
          updated_at: "2026-06-09T12:00:00Z",
        };

        vi.mocked(adminApiClient.updateAdminUserRole).mockResolvedValueOnce(
          updatedAdmin
        );

        const { result } = renderHook(() => useAdmin());

        act(() => {
          result.current.updateAdminRole("admin-1", "regional_admin");
        });

        await waitFor(() => {
          expect(result.current.adminLoading).toBe(false);
        });

        expect(result.current.selectedAdmin).toEqual(updatedAdmin);
      });
    });

    describe("deleteAdmin", () => {
      it("should delete admin user", async () => {
        vi.mocked(adminApiClient.deleteAdminUser).mockResolvedValueOnce();

        const { result } = renderHook(() => useAdmin());

        act(() => {
          result.current.deleteAdmin("admin-1");
        });

        await waitFor(() => {
          expect(result.current.adminLoading).toBe(false);
        });

        expect(vi.mocked(adminApiClient.deleteAdminUser)).toHaveBeenCalledWith(
          "admin-1"
        );
      });
    });
  });

  // ===== Field Issue Management Tests =====
  describe("Field Issue Management", () => {
    describe("loadIssues", () => {
      it("should load field issues", async () => {
        const mockIssues: FieldIssue[] = [
          {
            id: "issue-1",
            description: "Test issue",
            status: "open",
            reported_by: "coach-123",
            assigned_to: null,
            created_at: "2026-06-09T10:00:00Z",
            updated_at: "2026-06-09T10:00:00Z",
            resolved_at: null,
          },
        ];

        vi.mocked(adminApiClient.listFieldIssues).mockResolvedValueOnce({
          data: mockIssues,
          total: 1,
          limit: 10,
          offset: 0,
        });

        const { result } = renderHook(() => useAdmin());

        act(() => {
          result.current.loadIssues({ limit: 10, offset: 0 });
        });

        await waitFor(() => {
          expect(result.current.issueLoading).toBe(false);
        });

        expect(result.current.issues).toHaveLength(1);
        expect(result.current.issues[0].id).toBe("issue-1");
      });

      it("should filter issues by status", async () => {
        vi.mocked(adminApiClient.listFieldIssues).mockResolvedValueOnce({
          data: [],
          total: 0,
          limit: 10,
          offset: 0,
        });

        const { result } = renderHook(() => useAdmin());

        act(() => {
          result.current.loadIssues({ limit: 10, offset: 0 }, "open");
        });

        await waitFor(() => {
          expect(result.current.issueLoading).toBe(false);
        });

        expect(vi.mocked(adminApiClient.listFieldIssues)).toHaveBeenCalledWith(
          { limit: 10, offset: 0 },
          "open"
        );
      });
    });

    describe("selectIssue", () => {
      it("should select a field issue", async () => {
        const mockIssue: FieldIssue = {
          id: "issue-1",
          description: "Test issue",
          status: "open",
          reported_by: "coach-123",
          assigned_to: null,
          created_at: "2026-06-09T10:00:00Z",
          updated_at: "2026-06-09T10:00:00Z",
          resolved_at: null,
        };

        vi.mocked(adminApiClient.getFieldIssue).mockResolvedValueOnce(mockIssue);

        const { result } = renderHook(() => useAdmin());

        act(() => {
          result.current.selectIssue("issue-1");
        });

        await waitFor(() => {
          expect(result.current.issueLoading).toBe(false);
        });

        expect(result.current.selectedIssue).toEqual(mockIssue);
      });
    });

    describe("createIssue", () => {
      it("should create a field issue", async () => {
        const newIssue: FieldIssue = {
          id: "issue-2",
          description: "New issue description",
          status: "open",
          reported_by: "coach-123",
          assigned_to: null,
          created_at: "2026-06-09T10:00:00Z",
          updated_at: "2026-06-09T10:00:00Z",
          resolved_at: null,
        };

        vi.mocked(adminApiClient.createFieldIssue).mockResolvedValueOnce(newIssue);

        const { result } = renderHook(() => useAdmin());

        act(() => {
          result.current.createIssue({
            description: "New issue description",
            reported_by: "coach-123",
          });
        });

        await waitFor(() => {
          expect(result.current.issueLoading).toBe(false);
        });

        expect(result.current.selectedIssue).toEqual(newIssue);
      });
    });

    describe("updateIssue", () => {
      it("should update issue status", async () => {
        const updatedIssue: FieldIssue = {
          id: "issue-1",
          description: "Test issue",
          status: "resolved",
          reported_by: "coach-123",
          assigned_to: "admin-456",
          created_at: "2026-06-09T10:00:00Z",
          updated_at: "2026-06-09T12:00:00Z",
          resolved_at: "2026-06-09T12:00:00Z",
        };

        vi.mocked(adminApiClient.updateFieldIssue).mockResolvedValueOnce(
          updatedIssue
        );

        const { result } = renderHook(() => useAdmin());

        act(() => {
          result.current.updateIssue("issue-1", { status: "resolved" });
        });

        await waitFor(() => {
          expect(result.current.issueLoading).toBe(false);
        });

        expect(result.current.selectedIssue?.status).toBe("resolved");
        expect(result.current.selectedIssue?.resolved_at).not.toBeNull();
      });
    });

    describe("deleteIssue", () => {
      it("should delete field issue", async () => {
        vi.mocked(adminApiClient.deleteFieldIssue).mockResolvedValueOnce();

        const { result } = renderHook(() => useAdmin());

        act(() => {
          result.current.deleteIssue("issue-1");
        });

        await waitFor(() => {
          expect(result.current.issueLoading).toBe(false);
        });

        expect(vi.mocked(adminApiClient.deleteFieldIssue)).toHaveBeenCalledWith(
          "issue-1"
        );
      });
    });
  });

  // ===== Region Management Tests =====
  describe("Region Management", () => {
    describe("loadRegions", () => {
      it("should load regions", async () => {
        const mockRegions: Region[] = [
          {
            id: "region-1",
            name: "Pakistan",
            parent_id: null,
            is_active: true,
            created_at: "2026-06-09T10:00:00Z",
            updated_at: "2026-06-09T10:00:00Z",
          },
        ];

        vi.mocked(adminApiClient.listRegions).mockResolvedValueOnce({
          data: mockRegions,
          total: 1,
          limit: 10,
          offset: 0,
        });

        const { result } = renderHook(() => useAdmin());

        act(() => {
          result.current.loadRegions({ limit: 10, offset: 0 });
        });

        await waitFor(() => {
          expect(result.current.regionLoading).toBe(false);
        });

        expect(result.current.regions).toHaveLength(1);
        expect(result.current.regions[0].id).toBe("region-1");
      });

      it("should filter active regions only", async () => {
        vi.mocked(adminApiClient.listRegions).mockResolvedValueOnce({
          data: [],
          total: 0,
          limit: 10,
          offset: 0,
        });

        const { result } = renderHook(() => useAdmin());

        act(() => {
          result.current.loadRegions({ limit: 10, offset: 0 }, true);
        });

        await waitFor(() => {
          expect(result.current.regionLoading).toBe(false);
        });

        expect(vi.mocked(adminApiClient.listRegions)).toHaveBeenCalledWith(
          { limit: 10, offset: 0 },
          true
        );
      });
    });

    describe("selectRegion", () => {
      it("should select a region", async () => {
        const mockRegion: Region = {
          id: "region-1",
          name: "Pakistan",
          parent_id: null,
          is_active: true,
          created_at: "2026-06-09T10:00:00Z",
          updated_at: "2026-06-09T10:00:00Z",
        };

        vi.mocked(adminApiClient.getRegion).mockResolvedValueOnce(mockRegion);

        const { result } = renderHook(() => useAdmin());

        act(() => {
          result.current.selectRegion("region-1");
        });

        await waitFor(() => {
          expect(result.current.regionLoading).toBe(false);
        });

        expect(result.current.selectedRegion).toEqual(mockRegion);
      });
    });

    describe("createRegion", () => {
      it("should create a region", async () => {
        const newRegion: Region = {
          id: "region-2",
          name: "Punjab",
          parent_id: "region-1",
          is_active: true,
          created_at: "2026-06-09T10:00:00Z",
          updated_at: "2026-06-09T10:00:00Z",
        };

        vi.mocked(adminApiClient.createRegion).mockResolvedValueOnce(newRegion);

        const { result } = renderHook(() => useAdmin());

        act(() => {
          result.current.createRegion({
            name: "Punjab",
            parent_id: "region-1",
          });
        });

        await waitFor(() => {
          expect(result.current.regionLoading).toBe(false);
        });

        expect(result.current.selectedRegion).toEqual(newRegion);
      });
    });

    describe("updateRegion", () => {
      it("should update region", async () => {
        const updatedRegion: Region = {
          id: "region-1",
          name: "Islamic Republic of Pakistan",
          parent_id: null,
          is_active: true,
          created_at: "2026-06-09T10:00:00Z",
          updated_at: "2026-06-09T12:00:00Z",
        };

        vi.mocked(adminApiClient.updateRegion).mockResolvedValueOnce(
          updatedRegion
        );

        const { result } = renderHook(() => useAdmin());

        act(() => {
          result.current.updateRegion("region-1", {
            name: "Islamic Republic of Pakistan",
          });
        });

        await waitFor(() => {
          expect(result.current.regionLoading).toBe(false);
        });

        expect(result.current.selectedRegion?.name).toBe(
          "Islamic Republic of Pakistan"
        );
      });
    });

    describe("deleteRegion", () => {
      it("should delete region", async () => {
        vi.mocked(adminApiClient.deleteRegion).mockResolvedValueOnce();

        const { result } = renderHook(() => useAdmin());

        act(() => {
          result.current.deleteRegion("region-1");
        });

        await waitFor(() => {
          expect(result.current.regionLoading).toBe(false);
        });

        expect(vi.mocked(adminApiClient.deleteRegion)).toHaveBeenCalledWith(
          "region-1"
        );
      });
    });
  });

  // ===== Error Clearing Tests =====
  describe("Error Management", () => {
    it("should clear admin error", async () => {
      const { result } = renderHook(() => useAdmin());

      // Simulate error state by attempting an operation that fails
      const error = new Error("Test error");
      vi.mocked(adminApiClient.listAdminUsers).mockRejectedValueOnce(error);

      // Try to load admins (will fail and set error)
      let caughtError = false;
      await act(async () => {
        try {
          await result.current.loadAdmins();
        } catch (e) {
          caughtError = true;
        }
      });

      expect(caughtError).toBe(true);

      // Error should be set now
      expect(result.current.adminError).not.toBeNull();

      // Now clear the error
      act(() => {
        result.current.clearAdminError();
      });

      expect(result.current.adminError).toBeNull();
    });

    it("should clear issue error", async () => {
      const { result } = renderHook(() => useAdmin());

      // Simulate error state by attempting an operation that fails
      const error = new Error("Test error");
      vi.mocked(adminApiClient.listFieldIssues).mockRejectedValueOnce(error);

      // Try to load issues (will fail and set error)
      let caughtError = false;
      await act(async () => {
        try {
          await result.current.loadIssues();
        } catch (e) {
          caughtError = true;
        }
      });

      expect(caughtError).toBe(true);

      // Error should be set now
      expect(result.current.issueError).not.toBeNull();

      // Now clear the error
      act(() => {
        result.current.clearIssueError();
      });

      expect(result.current.issueError).toBeNull();
    });

    it("should clear region error", async () => {
      const { result } = renderHook(() => useAdmin());

      // Simulate error state by attempting an operation that fails
      const error = new Error("Test error");
      vi.mocked(adminApiClient.listRegions).mockRejectedValueOnce(error);

      // Try to load regions (will fail and set error)
      let caughtError = false;
      await act(async () => {
        try {
          await result.current.loadRegions();
        } catch (e) {
          caughtError = true;
        }
      });

      expect(caughtError).toBe(true);

      // Error should be set now
      expect(result.current.regionError).not.toBeNull();

      // Now clear the error
      act(() => {
        result.current.clearRegionError();
      });

      expect(result.current.regionError).toBeNull();
    });
  });

  // ===== Cache Management Tests =====
  describe("Cache Management", () => {
    it("should clear all caches", () => {
      const { result } = renderHook(() => useAdmin());

      act(() => {
        result.current.clearAllCaches();
      });

      expect(vi.mocked(adminApiClient.clearCache)).toHaveBeenCalled();
    });
  });
});
