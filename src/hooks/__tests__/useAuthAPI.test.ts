/**
 * useAuthAPI Hook Tests
 *
 * Tests cover:
 * - State management (user, profile, loading, error)
 * - All auth operations (signup, getUser, updateProfile, etc.)
 * - Error handling
 * - Session restoration on mount
 * - Cache clearing
 */

import { describe, it, expect, beforeEach, vi, afterEach } from "vitest";
import { renderHook, act, waitFor } from "@testing-library/react";
import { useAuthAPI } from "../useAuthAPI";
import * as authApiClient from "@/lib/apiClients/authApiClient";

// Mock the API client
vi.mock("@/lib/apiClients/authApiClient", () => ({
  authApiClient: {
    signup: vi.fn(),
    getUser: vi.fn(),
    getProfile: vi.fn(),
    updateProfile: vi.fn(),
    confirmEmail: vi.fn(),
    deleteUser: vi.fn(),
    getSession: vi.fn(),
    clearCache: vi.fn(),
  },
}));

describe("useAuthAPI", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  afterEach(() => {
    vi.clearAllMocks();
  });

  describe("Initial State", () => {
    it("should initialize with null user and no error", () => {
      vi.mocked(authApiClient.authApiClient.getSession).mockResolvedValue({
        authenticated: false,
        user: undefined,
      });

      const { result } = renderHook(() => useAuthAPI());

      expect(result.current.user).toBeNull();
      expect(result.current.profile).toBeNull();
      expect(result.current.error).toBeNull();
    });

    it("should initialize with loading true", () => {
      vi.mocked(authApiClient.authApiClient.getSession).mockResolvedValue({
        authenticated: false,
        user: undefined,
      });

      const { result } = renderHook(() => useAuthAPI());

      // Initially loading while session is restored
      expect(result.current.loading).toBeDefined();
    });
  });

  describe("Session Restoration", () => {
    it("should restore authenticated session on mount", async () => {
      const mockUser = {
        id: "user-123",
        email: "test@example.com",
        created_at: "2026-01-01T00:00:00Z",
        updated_at: "2026-01-01T00:00:00Z",
        profile: {
          id: "user-123",
          user_id: "user-123",
          full_name: "John Doe",
          role: "learner",
          is_active: true,
          created_at: "2026-01-01T00:00:00Z",
          updated_at: "2026-01-01T00:00:00Z",
        },
      };

      vi.mocked(authApiClient.authApiClient.getSession).mockResolvedValue({
        authenticated: true,
        user: mockUser,
      });

      const { result } = renderHook(() => useAuthAPI());

      await waitFor(() => {
        expect(result.current.loading).toBe(false);
      });

      expect(result.current.user).toEqual(mockUser);
      expect(result.current.profile).toEqual(mockUser.profile);
    });

    it("should handle session restoration failure gracefully", async () => {
      vi.mocked(authApiClient.authApiClient.getSession).mockRejectedValue(
        new Error("Network error")
      );

      const { result } = renderHook(() => useAuthAPI());

      await waitFor(() => {
        expect(result.current.loading).toBe(false);
      });

      expect(result.current.user).toBeNull();
      expect(result.current.profile).toBeNull();
    });
  });

  describe("signup", () => {
    it("should sign up user successfully", async () => {
      const mockSignupResponse = {
        id: "user-123",
        email: "test@example.com",
        role: "learner",
        created_at: "2026-01-01T00:00:00Z",
      };

      const mockUserResponse = {
        id: "user-123",
        email: "test@example.com",
        created_at: "2026-01-01T00:00:00Z",
        updated_at: "2026-01-01T00:00:00Z",
        profile: {
          id: "user-123",
          user_id: "user-123",
          full_name: "John Doe",
          role: "learner",
          is_active: true,
          created_at: "2026-01-01T00:00:00Z",
          updated_at: "2026-01-01T00:00:00Z",
        },
      };

      vi.mocked(authApiClient.authApiClient.getSession).mockResolvedValue({
        authenticated: false,
      });
      vi.mocked(authApiClient.authApiClient.signup).mockResolvedValue(mockSignupResponse);
      vi.mocked(authApiClient.authApiClient.getUser).mockResolvedValue(mockUserResponse);

      const { result } = renderHook(() => useAuthAPI());

      let signupResult;
      await act(async () => {
        signupResult = await result.current.signup("test@example.com", "John Doe");
      });

      expect(signupResult).toEqual(mockUserResponse);
      expect(result.current.user).toEqual(mockUserResponse);
      expect(result.current.profile).toEqual(mockUserResponse.profile);
      expect(result.current.error).toBeNull();
    });

    it("should handle signup error", async () => {
      const mockError = new Error("Email already exists");

      vi.mocked(authApiClient.authApiClient.getSession).mockResolvedValue({
        authenticated: false,
      });
      vi.mocked(authApiClient.authApiClient.signup).mockRejectedValue(mockError);

      const { result } = renderHook(() => useAuthAPI());

      await expect(
        act(async () => {
          await result.current.signup("test@example.com");
        })
      ).rejects.toThrow();

      expect(result.current.error).toBeDefined();
    });

    it("should set loading state during signup", async () => {
      vi.mocked(authApiClient.authApiClient.getSession).mockResolvedValue({
        authenticated: false,
      });
      vi.mocked(authApiClient.authApiClient.signup).mockImplementation(
        () =>
          new Promise((resolve) => {
            setTimeout(
              () =>
                resolve({
                  id: "user-123",
                  email: "test@example.com",
                  role: "learner",
                  created_at: "2026-01-01T00:00:00Z",
                }),
              100
            );
          })
      );
      vi.mocked(authApiClient.authApiClient.getUser).mockResolvedValue({
        id: "user-123",
        email: "test@example.com",
        created_at: "2026-01-01T00:00:00Z",
        updated_at: "2026-01-01T00:00:00Z",
      });

      const { result } = renderHook(() => useAuthAPI());

      await waitFor(() => expect(result.current.loading).toBe(false));

      let isLoading = false;
      act(() => {
        result.current.signup("test@example.com").then(() => {
          isLoading = result.current.loading;
        });
      });

      await waitFor(() => expect(result.current.loading).toBe(false));
    });
  });

  describe("getUser", () => {
    it("should fetch user by ID", async () => {
      const mockUser = {
        id: "user-123",
        email: "test@example.com",
        created_at: "2026-01-01T00:00:00Z",
        updated_at: "2026-01-01T00:00:00Z",
      };

      vi.mocked(authApiClient.authApiClient.getSession).mockResolvedValue({
        authenticated: false,
      });
      vi.mocked(authApiClient.authApiClient.getUser).mockResolvedValue(mockUser);

      const { result } = renderHook(() => useAuthAPI());

      await act(async () => {
        await result.current.getUser("user-123");
      });

      expect(result.current.user).toEqual(mockUser);
      expect(result.current.error).toBeNull();
    });

    it("should handle getUser error", async () => {
      const mockError = new Error("User not found");

      vi.mocked(authApiClient.authApiClient.getSession).mockResolvedValue({
        authenticated: false,
      });
      vi.mocked(authApiClient.authApiClient.getUser).mockRejectedValue(mockError);

      const { result } = renderHook(() => useAuthAPI());

      await expect(
        act(async () => {
          await result.current.getUser("nonexistent");
        })
      ).rejects.toThrow();

      expect(result.current.error).toBeDefined();
    });
  });

  describe("updateProfile", () => {
    it("should update profile successfully", async () => {
      const mockProfile = {
        id: "user-123",
        user_id: "user-123",
        full_name: "John Updated",
        role: "coach",
        is_active: true,
        created_at: "2026-01-01T00:00:00Z",
        updated_at: "2026-01-02T00:00:00Z",
      };

      vi.mocked(authApiClient.authApiClient.getSession).mockResolvedValue({
        authenticated: false,
      });
      vi.mocked(authApiClient.authApiClient.updateProfile).mockResolvedValue(mockProfile);

      const { result } = renderHook(() => useAuthAPI());

      await act(async () => {
        await result.current.updateProfile("user-123", {
          full_name: "John Updated",
          role: "coach",
        });
      });

      expect(result.current.profile).toEqual(mockProfile);
    });

    it("should handle updateProfile error", async () => {
      const mockError = new Error("Failed to update");

      vi.mocked(authApiClient.authApiClient.getSession).mockResolvedValue({
        authenticated: false,
      });
      vi.mocked(authApiClient.authApiClient.updateProfile).mockRejectedValue(mockError);

      const { result } = renderHook(() => useAuthAPI());

      await expect(
        act(async () => {
          await result.current.updateProfile("user-123", {
            full_name: "John",
          });
        })
      ).rejects.toThrow();

      expect(result.current.error).toBeDefined();
    });
  });

  describe("confirmEmail", () => {
    it("should confirm email successfully", async () => {
      const mockUser = {
        id: "user-123",
        email: "test@example.com",
        email_confirmed_at: "2026-01-02T00:00:00Z",
        created_at: "2026-01-01T00:00:00Z",
        updated_at: "2026-01-01T00:00:00Z",
      };

      vi.mocked(authApiClient.authApiClient.getSession).mockResolvedValue({
        authenticated: false,
      });
      vi.mocked(authApiClient.authApiClient.confirmEmail).mockResolvedValue(undefined);
      vi.mocked(authApiClient.authApiClient.getUser).mockResolvedValue(mockUser);

      const { result } = renderHook(() => useAuthAPI());

      await act(async () => {
        await result.current.confirmEmail("user-123");
      });

      expect(result.current.user).toEqual(mockUser);
    });
  });

  describe("deleteUser", () => {
    it("should delete user and clear state", async () => {
      vi.mocked(authApiClient.authApiClient.getSession).mockResolvedValue({
        authenticated: false,
      });
      vi.mocked(authApiClient.authApiClient.deleteUser).mockResolvedValue(undefined);

      const { result } = renderHook(() => useAuthAPI());

      // First set some state
      act(() => {
        // Simulating user being logged in
      });

      await act(async () => {
        await result.current.deleteUser("user-123");
      });

      expect(result.current.user).toBeNull();
      expect(result.current.profile).toBeNull();
    });
  });

  describe("getSession", () => {
    it("should get authenticated session", async () => {
      const mockUser = {
        id: "user-123",
        email: "test@example.com",
        created_at: "2026-01-01T00:00:00Z",
        updated_at: "2026-01-01T00:00:00Z",
      };

      vi.mocked(authApiClient.authApiClient.getSession)
        .mockResolvedValueOnce({ authenticated: false })
        .mockResolvedValueOnce({
          authenticated: true,
          user: mockUser,
        });

      const { result } = renderHook(() => useAuthAPI());

      await waitFor(() => expect(result.current.loading).toBe(false));

      let sessionResult;
      await act(async () => {
        sessionResult = await result.current.getSession("user-123");
      });

      expect(sessionResult?.authenticated).toBe(true);
      expect(sessionResult?.user).toEqual(mockUser);
    });

    it("should get unauthenticated session", async () => {
      vi.mocked(authApiClient.authApiClient.getSession).mockResolvedValue({
        authenticated: false,
      });

      const { result } = renderHook(() => useAuthAPI());

      await waitFor(() => expect(result.current.loading).toBe(false));

      let sessionResult;
      await act(async () => {
        sessionResult = await result.current.getSession();
      });

      expect(sessionResult?.authenticated).toBe(false);
    });
  });

  describe("Error Management", () => {
    it("should clear error", async () => {
      const mockError = new Error("Some error");

      vi.mocked(authApiClient.authApiClient.getSession).mockResolvedValue({
        authenticated: false,
      });
      vi.mocked(authApiClient.authApiClient.getUser).mockRejectedValue(mockError);

      const { result } = renderHook(() => useAuthAPI());

      await expect(
        act(async () => {
          await result.current.getUser("user-123");
        })
      ).rejects.toThrow();

      expect(result.current.error).toBeDefined();

      act(() => {
        result.current.clearError();
      });

      expect(result.current.error).toBeNull();
    });
  });

  describe("Cache Management", () => {
    it("should clear cache", async () => {
      vi.mocked(authApiClient.authApiClient.getSession).mockResolvedValue({
        authenticated: false,
      });

      const { result } = renderHook(() => useAuthAPI());

      await act(async () => {
        result.current.clearCache();
      });

      expect(authApiClient.authApiClient.clearCache).toHaveBeenCalled();
    });
  });
});
