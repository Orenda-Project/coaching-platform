/**
 * useAuthAPI - React hook for authentication state management
 *
 * Manages:
 * - User authentication state (user, profile, session)
 * - Loading and error states
 * - Sign up, sign in, sign out operations
 * - Profile management
 * - Automatic session recovery on mount
 *
 * Usage:
 *   const { user, loading, signup, updateProfile } = useAuthAPI();
 *   const result = await signup("user@example.com", "John", "+1234567890");
 */

import { useState, useEffect, useCallback } from "react";
import { authApiClient, type UserResponse, type UserProfile, type ApiError } from "@/lib/apiClients/authApiClient";

export interface UseAuthAPIState {
  user: UserResponse | null;
  profile: UserProfile | null;
  loading: boolean;
  error: ApiError | null;
}

export interface UseAuthAPIActions {
  signup: (email: string, fullName?: string, phone?: string) => Promise<UserResponse>;
  getUser: (userId: string) => Promise<UserResponse>;
  getProfile: (userId: string) => Promise<UserProfile>;
  updateProfile: (userId: string, data: Record<string, unknown>) => Promise<UserProfile>;
  confirmEmail: (userId: string) => Promise<void>;
  deleteUser: (userId: string) => Promise<void>;
  getSession: (userId?: string) => Promise<{ authenticated: boolean; user?: UserResponse }>;
  clearError: () => void;
  clearCache: () => void;
}

/**
 * Hook for authentication API interactions
 *
 * Provides state management for user data, loading, and errors,
 * along with methods to perform auth operations.
 */
export function useAuthAPI(): UseAuthAPIState & UseAuthAPIActions {
  const [user, setUser] = useState<UserResponse | null>(null);
  const [profile, setProfile] = useState<UserProfile | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<ApiError | null>(null);

  /**
   * Attempt to restore session on component mount
   */
  useEffect(() => {
    const restoreSession = async () => {
      try {
        setLoading(true);
        const sessionResponse = await authApiClient.getSession();

        if (sessionResponse.authenticated && sessionResponse.user) {
          setUser(sessionResponse.user);
          if (sessionResponse.user.profile) {
            setProfile(sessionResponse.user.profile);
          }
        }
      } catch (err) {
        // Silently fail - user is not authenticated
        setUser(null);
        setProfile(null);
      } finally {
        setLoading(false);
      }
    };

    restoreSession();
  }, []);

  /**
   * Sign up a new user
   */
  const signup = useCallback(
    async (email: string, fullName?: string, phone?: string): Promise<UserResponse> => {
      try {
        setLoading(true);
        setError(null);

        const response = await authApiClient.signup(email, fullName, phone);

        // Fetch full user data
        const userData = await authApiClient.getUser(response.id);
        setUser(userData);

        if (userData.profile) {
          setProfile(userData.profile);
        }

        return userData;
      } catch (err) {
        const apiError = err instanceof Error ? (err as ApiError) : new Error(String(err));
        setError(apiError as ApiError);
        throw err;
      } finally {
        setLoading(false);
      }
    },
    []
  );

  /**
   * Fetch user by ID
   */
  const getUser = useCallback(async (userId: string): Promise<UserResponse> => {
    try {
      setLoading(true);
      setError(null);

      const userData = await authApiClient.getUser(userId);
      setUser(userData);

      if (userData.profile) {
        setProfile(userData.profile);
      }

      return userData;
    } catch (err) {
      const apiError = err instanceof Error ? (err as ApiError) : new Error(String(err));
      setError(apiError as ApiError);
      throw err;
    } finally {
      setLoading(false);
    }
  }, []);

  /**
   * Fetch user profile
   */
  const getProfile = useCallback(async (userId: string): Promise<UserProfile> => {
    try {
      setLoading(true);
      setError(null);

      const profileData = await authApiClient.getProfile(userId);
      setProfile(profileData);

      return profileData;
    } catch (err) {
      const apiError = err instanceof Error ? (err as ApiError) : new Error(String(err));
      setError(apiError as ApiError);
      throw err;
    } finally {
      setLoading(false);
    }
  }, []);

  /**
   * Update user profile
   */
  const updateProfile = useCallback(
    async (userId: string, data: Record<string, unknown>): Promise<UserProfile> => {
      try {
        setLoading(true);
        setError(null);

        const updated = await authApiClient.updateProfile(userId, data as Parameters<typeof authApiClient.updateProfile>[1]);
        setProfile(updated);

        // Update user object with new profile
        if (user) {
          setUser({ ...user, profile: updated });
        }

        return updated;
      } catch (err) {
        const apiError = err instanceof Error ? (err as ApiError) : new Error(String(err));
        setError(apiError as ApiError);
        throw err;
      } finally {
        setLoading(false);
      }
    },
    [user]
  );

  /**
   * Confirm user email
   */
  const confirmEmail = useCallback(async (userId: string): Promise<void> => {
    try {
      setLoading(true);
      setError(null);

      await authApiClient.confirmEmail(userId);

      // Refresh user data
      const userData = await authApiClient.getUser(userId);
      setUser(userData);
    } catch (err) {
      const apiError = err instanceof Error ? (err as ApiError) : new Error(String(err));
      setError(apiError as ApiError);
      throw err;
    } finally {
      setLoading(false);
    }
  }, []);

  /**
   * Delete user account
   */
  const deleteUser = useCallback(async (userId: string): Promise<void> => {
    try {
      setLoading(true);
      setError(null);

      await authApiClient.deleteUser(userId);

      // Clear state
      setUser(null);
      setProfile(null);
    } catch (err) {
      const apiError = err instanceof Error ? (err as ApiError) : new Error(String(err));
      setError(apiError as ApiError);
      throw err;
    } finally {
      setLoading(false);
    }
  }, []);

  /**
   * Get session information
   */
  const getSession = useCallback(
    async (userId?: string): Promise<{ authenticated: boolean; user?: UserResponse }> => {
      try {
        setLoading(true);
        setError(null);

        const sessionResponse = await authApiClient.getSession(userId);

        if (sessionResponse.authenticated && sessionResponse.user) {
          setUser(sessionResponse.user);
          if (sessionResponse.user.profile) {
            setProfile(sessionResponse.user.profile);
          }
        } else {
          setUser(null);
          setProfile(null);
        }

        return {
          authenticated: sessionResponse.authenticated,
          user: sessionResponse.user,
        };
      } catch (err) {
        const apiError = err instanceof Error ? (err as ApiError) : new Error(String(err));
        setError(apiError as ApiError);
        throw err;
      } finally {
        setLoading(false);
      }
    },
    []
  );

  /**
   * Clear error state
   */
  const clearError = useCallback(() => {
    setError(null);
  }, []);

  /**
   * Clear API cache
   */
  const clearCache = useCallback(() => {
    authApiClient.clearCache();
  }, []);

  return {
    user,
    profile,
    loading,
    error,
    signup,
    getUser,
    getProfile,
    updateProfile,
    confirmEmail,
    deleteUser,
    getSession,
    clearError,
    clearCache,
  };
}
