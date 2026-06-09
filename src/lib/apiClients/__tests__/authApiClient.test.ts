/**
 * Auth API Client Tests
 *
 * Comprehensive test coverage for:
 * - All API methods (signup, getUser, updateProfile, etc.)
 * - Error handling and retry logic
 * - Cache management
 * - Request/response validation
 */

import { describe, it, expect, beforeEach, vi, afterEach } from "vitest";
import { AuthApiClient, type SignupResponse, type UserResponse } from "../authApiClient";

describe("AuthApiClient", () => {
  let client: AuthApiClient;
  let fetchMock: ReturnType<typeof vi.fn>;

  beforeEach(() => {
    client = new AuthApiClient("http://localhost:8000");
    fetchMock = vi.fn();
    global.fetch = fetchMock;
  });

  afterEach(() => {
    vi.clearAllMocks();
    client.clearCache();
  });

  describe("signup", () => {
    it("should successfully sign up a new user", async () => {
      const mockResponse: SignupResponse = {
        id: "user-123",
        email: "test@example.com",
        full_name: "John Doe",
        phone: "+1234567890",
        role: "learner",
        created_at: "2026-01-01T00:00:00Z",
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await client.signup("test@example.com", "John Doe", "+1234567890");

      expect(result.id).toBe("user-123");
      expect(result.email).toBe("test@example.com");
      expect(fetchMock).toHaveBeenCalledWith(
        "http://localhost:8000/api/auth/signup",
        expect.objectContaining({
          method: "POST",
          body: JSON.stringify({
            email: "test@example.com",
            full_name: "John Doe",
            phone: "+1234567890",
          }),
        })
      );
    });

    it("should handle duplicate email error", async () => {
      fetchMock.mockResolvedValueOnce({
        ok: false,
        status: 409,
        text: async () => JSON.stringify({
          detail: "User with this email already exists",
        }),
      });

      await expect(client.signup("test@example.com")).rejects.toThrow(
        "User with this email already exists"
      );
    });

    it("should handle server errors with retry", async () => {
      // First two calls return 500, third succeeds
      const mockResponse: SignupResponse = {
        id: "user-123",
        email: "test@example.com",
        role: "learner",
        created_at: "2026-01-01T00:00:00Z",
      };

      fetchMock
        .mockResolvedValueOnce({ ok: false, status: 500, text: async () => "" })
        .mockResolvedValueOnce({ ok: false, status: 500, text: async () => "" })
        .mockResolvedValueOnce({
          ok: true,
          json: async () => mockResponse,
        });

      const result = await client.signup("test@example.com");

      expect(result.id).toBe("user-123");
      expect(fetchMock).toHaveBeenCalledTimes(3);
    });

    it("should fail after max retries", async () => {
      fetchMock.mockResolvedValue({
        ok: false,
        status: 500,
        text: async () => "",
      });

      await expect(client.signup("test@example.com")).rejects.toThrow();
      // 3 retries + initial
      expect(fetchMock.mock.calls.length).toBeGreaterThanOrEqual(3);
    });
  });

  describe("getUser", () => {
    it("should fetch user by ID", async () => {
      const mockResponse: UserResponse = {
        id: "user-123",
        email: "test@example.com",
        created_at: "2026-01-01T00:00:00Z",
        updated_at: "2026-01-01T00:00:00Z",
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await client.getUser("user-123");

      expect(result.id).toBe("user-123");
      expect(result.email).toBe("test@example.com");
      expect(fetchMock).toHaveBeenCalledWith(
        "http://localhost:8000/api/auth/users/user-123",
        expect.objectContaining({
          headers: { "Content-Type": "application/json" },
        })
      );
    });

    it("should return cached user on second call", async () => {
      const mockResponse: UserResponse = {
        id: "user-123",
        email: "test@example.com",
        created_at: "2026-01-01T00:00:00Z",
        updated_at: "2026-01-01T00:00:00Z",
      };

      fetchMock.mockResolvedValue({
        ok: true,
        json: async () => mockResponse,
      });

      await client.getUser("user-123");
      await client.getUser("user-123");

      // Should only fetch once (second call from cache)
      expect(fetchMock).toHaveBeenCalledTimes(1);
    });

    it("should handle user not found", async () => {
      fetchMock.mockResolvedValueOnce({
        ok: false,
        status: 404,
        text: async () => JSON.stringify({ detail: "User not found" }),
      });

      await expect(client.getUser("nonexistent")).rejects.toThrow("User not found");
    });
  });

  describe("getUserByEmail", () => {
    it("should fetch user by email", async () => {
      const mockResponse: UserResponse = {
        id: "user-123",
        email: "test@example.com",
        created_at: "2026-01-01T00:00:00Z",
        updated_at: "2026-01-01T00:00:00Z",
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await client.getUserByEmail("test@example.com");

      expect(result.email).toBe("test@example.com");
      expect(fetchMock).toHaveBeenCalledWith(
        "http://localhost:8000/api/auth/users/email/test%40example.com",
        expect.any(Object)
      );
    });

    it("should properly URL-encode email", async () => {
      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ id: "user-123", email: "test+tag@example.com" }),
      });

      await client.getUserByEmail("test+tag@example.com");

      expect(fetchMock).toHaveBeenCalledWith(
        expect.stringContaining("test%2Btag%40example.com"),
        expect.any(Object)
      );
    });
  });

  describe("getProfile", () => {
    it("should fetch user profile", async () => {
      const mockResponse = {
        id: "user-123",
        user_id: "user-123",
        full_name: "John Doe",
        role: "learner",
        is_active: true,
        created_at: "2026-01-01T00:00:00Z",
        updated_at: "2026-01-01T00:00:00Z",
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await client.getProfile("user-123");

      expect(result.full_name).toBe("John Doe");
      expect(result.role).toBe("learner");
    });

    it("should cache profile response", async () => {
      const mockResponse = {
        id: "user-123",
        user_id: "user-123",
        role: "learner",
        is_active: true,
        created_at: "2026-01-01T00:00:00Z",
        updated_at: "2026-01-01T00:00:00Z",
      };

      fetchMock.mockResolvedValue({
        ok: true,
        json: async () => mockResponse,
      });

      await client.getProfile("user-123");
      await client.getProfile("user-123");

      expect(fetchMock).toHaveBeenCalledTimes(1);
    });
  });

  describe("updateProfile", () => {
    it("should update profile successfully", async () => {
      const mockResponse = {
        id: "user-123",
        user_id: "user-123",
        full_name: "John Updated",
        bio: "New bio",
        role: "coach",
        is_active: true,
        created_at: "2026-01-01T00:00:00Z",
        updated_at: "2026-01-02T00:00:00Z",
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await client.updateProfile("user-123", {
        full_name: "John Updated",
        bio: "New bio",
        role: "coach",
      });

      expect(result.full_name).toBe("John Updated");
      expect(result.role).toBe("coach");
      expect(fetchMock).toHaveBeenCalledWith(
        "http://localhost:8000/api/auth/profile/user-123",
        expect.objectContaining({
          method: "PUT",
          body: JSON.stringify({
            full_name: "John Updated",
            bio: "New bio",
            role: "coach",
          }),
        })
      );
    });

    it("should handle duplicate phone error", async () => {
      fetchMock.mockResolvedValueOnce({
        ok: false,
        status: 400,
        text: async () => JSON.stringify({
          detail: "Failed to update profile (duplicate phone?)",
        }),
      });

      await expect(
        client.updateProfile("user-123", { phone: "+existing" })
      ).rejects.toThrow();
    });
  });

  describe("confirmEmail", () => {
    it("should confirm email successfully", async () => {
      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => ({
          message: "Email confirmed",
          email_confirmed_at: "2026-01-02T00:00:00Z",
        }),
      });

      const result = await client.confirmEmail("user-123");

      expect(result.message).toBe("Email confirmed");
      expect(result.email_confirmed_at).toBeDefined();
    });
  });

  describe("deleteUser", () => {
    it("should delete user successfully", async () => {
      fetchMock.mockResolvedValueOnce({
        ok: true,
      });

      await client.deleteUser("user-123");

      expect(fetchMock).toHaveBeenCalledWith(
        "http://localhost:8000/api/auth/users/user-123",
        expect.objectContaining({ method: "DELETE" })
      );
    });

    it("should handle user not found", async () => {
      fetchMock.mockResolvedValueOnce({
        ok: false,
        status: 404,
        text: async () => JSON.stringify({ detail: "User not found" }),
      });

      await expect(client.deleteUser("nonexistent")).rejects.toThrow();
    });
  });

  describe("listUsers", () => {
    it("should list users with pagination", async () => {
      const mockResponse = {
        users: [
          {
            id: "user-1",
            email: "user1@example.com",
            created_at: "2026-01-01T00:00:00Z",
            updated_at: "2026-01-01T00:00:00Z",
          },
          {
            id: "user-2",
            email: "user2@example.com",
            created_at: "2026-01-01T00:00:00Z",
            updated_at: "2026-01-01T00:00:00Z",
          },
        ],
        total: 100,
        limit: 2,
        offset: 0,
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await client.listUsers(2, 0);

      expect(result.users).toHaveLength(2);
      expect(result.total).toBe(100);
      expect(fetchMock).toHaveBeenCalledWith(
        expect.stringContaining("limit=2&offset=0"),
        expect.any(Object)
      );
    });

    it("should use default pagination values", async () => {
      const mockResponse = {
        users: [],
        total: 0,
        limit: 100,
        offset: 0,
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      await client.listUsers();

      expect(fetchMock).toHaveBeenCalledWith(
        expect.stringContaining("limit=100&offset=0"),
        expect.any(Object)
      );
    });
  });

  describe("getSession", () => {
    it("should get session for authenticated user", async () => {
      const mockResponse = {
        user: {
          id: "user-123",
          email: "test@example.com",
          created_at: "2026-01-01T00:00:00Z",
          updated_at: "2026-01-01T00:00:00Z",
        },
        authenticated: true,
        message: "User authenticated",
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await client.getSession("user-123");

      expect(result.authenticated).toBe(true);
      expect(result.user?.id).toBe("user-123");
    });

    it("should get unauthenticated session", async () => {
      const mockResponse = {
        user: null,
        authenticated: false,
        message: "Not authenticated",
      };

      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      });

      const result = await client.getSession();

      expect(result.authenticated).toBe(false);
      expect(result.user).toBeNull();
    });
  });

  describe("healthCheck", () => {
    it("should check auth service health", async () => {
      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ status: "healthy", service: "auth" }),
      });

      const result = await client.healthCheck();

      expect(result.status).toBe("healthy");
      expect(result.service).toBe("auth");
    });

    it("should handle health check failure", async () => {
      fetchMock.mockResolvedValueOnce({
        ok: false,
        status: 500,
        text: async () => "",
      });

      await expect(client.healthCheck()).rejects.toThrow();
    });
  });

  describe("Cache Management", () => {
    it("should clear all cache", async () => {
      const mockResponse: UserResponse = {
        id: "user-123",
        email: "test@example.com",
        created_at: "2026-01-01T00:00:00Z",
        updated_at: "2026-01-01T00:00:00Z",
      };

      fetchMock
        .mockResolvedValueOnce({
          ok: true,
          json: async () => mockResponse,
        })
        .mockResolvedValueOnce({
          ok: true,
          json: async () => mockResponse,
        });

      await client.getUser("user-123");
      client.clearCache();
      await client.getUser("user-123");

      // Should fetch twice (cache was cleared)
      expect(fetchMock).toHaveBeenCalledTimes(2);
    });
  });

  describe("Error Handling", () => {
    it("should normalize API errors", async () => {
      fetchMock.mockResolvedValueOnce({
        ok: false,
        status: 400,
        text: async () =>
          JSON.stringify({
            detail: "Invalid request",
            code: "INVALID_INPUT",
          }),
      });

      try {
        await client.signup("invalid");
        expect.fail("Should have thrown");
      } catch (error: unknown) {
        const apiError = error as Record<string, unknown>;
        expect(apiError.message).toBe("Invalid request");
        expect(apiError.status).toBe(400);
      }
    });

    it("should handle network errors", async () => {
      fetchMock.mockRejectedValue(new Error("Network error"));

      await expect(client.signup("test@example.com")).rejects.toThrow();
    });

    it("should handle malformed JSON responses", async () => {
      fetchMock.mockResolvedValueOnce({
        ok: false,
        status: 500,
        text: async () => "Invalid JSON {{{",
      });

      await expect(client.signup("test@example.com")).rejects.toThrow();
    });
  });
});
