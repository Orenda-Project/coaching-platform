/**
 * useAdmin - React hook for admin management state
 *
 * Manages:
 * - Admin user state (create, list, retrieve, update, delete)
 * - Field issue state (create, list, retrieve, update, delete, filter)
 * - Region state (create, list, retrieve, update, delete, active filter)
 * - Loading states for each resource type
 * - Error handling with recovery
 * - Cache management
 *
 * Usage:
 *   const {
 *     admins, selectedAdmin, adminLoading, adminError,
 *     loadAdmins, selectAdmin, createAdmin, updateAdminRole, deleteAdmin,
 *     issues, selectedIssue, issueLoading, issueError,
 *     loadIssues, selectIssue, createIssue, updateIssue, deleteIssue,
 *     regions, selectedRegion, regionLoading, regionError,
 *     loadRegions, selectRegion, createRegion, updateRegion, deleteRegion,
 *     clearAdminError, clearIssueError, clearRegionError, clearAllCaches
 *   } = useAdmin();
 */

import { useState, useCallback } from "react";
import {
  adminApiClient,
  type AdminUser,
  type AdminUserRequest,
  type FieldIssue,
  type FieldIssueRequest,
  type FieldIssueUpdate,
  type Region,
  type RegionRequest,
  type RegionUpdate,
  type PaginationOptions,
  type ApiError,
} from "@/lib/apiClients/adminApiClient";

/**
 * Admin User State
 */
export interface UseAdminUserState {
  admins: AdminUser[];
  selectedAdmin: AdminUser | null;
  adminLoading: boolean;
  adminError: ApiError | null;
}

/**
 * Admin User Actions
 */
export interface UseAdminUserActions {
  loadAdmins: (options?: PaginationOptions) => Promise<void>;
  selectAdmin: (adminId: string) => Promise<void>;
  createAdmin: (request: AdminUserRequest) => Promise<void>;
  updateAdminRole: (adminId: string, role: "super_admin" | "regional_admin") => Promise<void>;
  deleteAdmin: (adminId: string) => Promise<void>;
  clearAdminError: () => void;
}

/**
 * Field Issue State
 */
export interface UseFieldIssueState {
  issues: FieldIssue[];
  selectedIssue: FieldIssue | null;
  issueLoading: boolean;
  issueError: ApiError | null;
}

/**
 * Field Issue Actions
 */
export interface UseFieldIssueActions {
  loadIssues: (
    options?: PaginationOptions,
    status?: "open" | "in_progress" | "resolved" | "closed"
  ) => Promise<void>;
  selectIssue: (issueId: string) => Promise<void>;
  createIssue: (request: FieldIssueRequest) => Promise<void>;
  updateIssue: (issueId: string, updates: FieldIssueUpdate) => Promise<void>;
  deleteIssue: (issueId: string) => Promise<void>;
  clearIssueError: () => void;
}

/**
 * Region State
 */
export interface UseRegionState {
  regions: Region[];
  selectedRegion: Region | null;
  regionLoading: boolean;
  regionError: ApiError | null;
}

/**
 * Region Actions
 */
export interface UseRegionActions {
  loadRegions: (options?: PaginationOptions, activeOnly?: boolean) => Promise<void>;
  selectRegion: (regionId: string) => Promise<void>;
  createRegion: (request: RegionRequest) => Promise<void>;
  updateRegion: (regionId: string, updates: RegionUpdate) => Promise<void>;
  deleteRegion: (regionId: string) => Promise<void>;
  clearRegionError: () => void;
}

/**
 * Cache Management Actions
 */
export interface UseCacheActions {
  clearAllCaches: () => void;
}

/**
 * Combined hook state and actions
 */
export type UseAdminReturn = UseAdminUserState &
  UseAdminUserActions &
  UseFieldIssueState &
  UseFieldIssueActions &
  UseRegionState &
  UseRegionActions &
  UseCacheActions;

/**
 * Hook for admin management state and API interactions
 *
 * Provides unified state management for admin users, field issues, and regions,
 * along with methods to perform CRUD operations on each resource type.
 */
export function useAdmin(): UseAdminReturn {
  // Admin User State
  const [admins, setAdmins] = useState<AdminUser[]>([]);
  const [selectedAdmin, setSelectedAdmin] = useState<AdminUser | null>(null);
  const [adminLoading, setAdminLoading] = useState(false);
  const [adminError, setAdminError] = useState<ApiError | null>(null);

  // Field Issue State
  const [issues, setIssues] = useState<FieldIssue[]>([]);
  const [selectedIssue, setSelectedIssue] = useState<FieldIssue | null>(null);
  const [issueLoading, setIssueLoading] = useState(false);
  const [issueError, setIssueError] = useState<ApiError | null>(null);

  // Region State
  const [regions, setRegions] = useState<Region[]>([]);
  const [selectedRegion, setSelectedRegion] = useState<Region | null>(null);
  const [regionLoading, setRegionLoading] = useState(false);
  const [regionError, setRegionError] = useState<ApiError | null>(null);

  // ===== Admin User Actions =====

  /**
   * Load list of admin users
   */
  const loadAdmins = useCallback(
    async (options?: PaginationOptions): Promise<void> => {
      try {
        setAdminLoading(true);
        setAdminError(null);

        const response = await adminApiClient.listAdminUsers(options);
        setAdmins(response.data);
      } catch (err) {
        const apiError = err instanceof Error ? (err as ApiError) : new Error(String(err));
        setAdminError(apiError as ApiError);
        throw err;
      } finally {
        setAdminLoading(false);
      }
    },
    []
  );

  /**
   * Select admin user by ID
   */
  const selectAdmin = useCallback(async (adminId: string): Promise<void> => {
    try {
      setAdminLoading(true);
      setAdminError(null);

      const admin = await adminApiClient.getAdminUser(adminId);
      setSelectedAdmin(admin);
    } catch (err) {
      const apiError = err instanceof Error ? (err as ApiError) : new Error(String(err));
      setAdminError(apiError as ApiError);
      throw err;
    } finally {
      setAdminLoading(false);
    }
  }, []);

  /**
   * Create new admin user
   */
  const createAdmin = useCallback(async (request: AdminUserRequest): Promise<void> => {
    try {
      setAdminLoading(true);
      setAdminError(null);

      const admin = await adminApiClient.createAdminUser(request);
      setSelectedAdmin(admin);
    } catch (err) {
      const apiError = err instanceof Error ? (err as ApiError) : new Error(String(err));
      setAdminError(apiError as ApiError);
      throw err;
    } finally {
      setAdminLoading(false);
    }
  }, []);

  /**
   * Update admin user role
   */
  const updateAdminRole = useCallback(
    async (adminId: string, role: "super_admin" | "regional_admin"): Promise<void> => {
      try {
        setAdminLoading(true);
        setAdminError(null);

        const updated = await adminApiClient.updateAdminUserRole(adminId, role);
        setSelectedAdmin(updated);
      } catch (err) {
        const apiError = err instanceof Error ? (err as ApiError) : new Error(String(err));
        setAdminError(apiError as ApiError);
        throw err;
      } finally {
        setAdminLoading(false);
      }
    },
    []
  );

  /**
   * Delete admin user
   */
  const deleteAdmin = useCallback(async (adminId: string): Promise<void> => {
    try {
      setAdminLoading(true);
      setAdminError(null);

      await adminApiClient.deleteAdminUser(adminId);
      if (selectedAdmin?.id === adminId) {
        setSelectedAdmin(null);
      }
    } catch (err) {
      const apiError = err instanceof Error ? (err as ApiError) : new Error(String(err));
      setAdminError(apiError as ApiError);
      throw err;
    } finally {
      setAdminLoading(false);
    }
  }, [selectedAdmin]);

  /**
   * Clear admin error
   */
  const clearAdminError = useCallback(() => {
    setAdminError(null);
  }, []);

  // ===== Field Issue Actions =====

  /**
   * Load list of field issues
   */
  const loadIssues = useCallback(
    async (
      options?: PaginationOptions,
      status?: "open" | "in_progress" | "resolved" | "closed"
    ): Promise<void> => {
      try {
        setIssueLoading(true);
        setIssueError(null);

        const response = await adminApiClient.listFieldIssues(options, status);
        setIssues(response.data);
      } catch (err) {
        const apiError = err instanceof Error ? (err as ApiError) : new Error(String(err));
        setIssueError(apiError as ApiError);
        throw err;
      } finally {
        setIssueLoading(false);
      }
    },
    []
  );

  /**
   * Select field issue by ID
   */
  const selectIssue = useCallback(async (issueId: string): Promise<void> => {
    try {
      setIssueLoading(true);
      setIssueError(null);

      const issue = await adminApiClient.getFieldIssue(issueId);
      setSelectedIssue(issue);
    } catch (err) {
      const apiError = err instanceof Error ? (err as ApiError) : new Error(String(err));
      setIssueError(apiError as ApiError);
      throw err;
    } finally {
      setIssueLoading(false);
    }
  }, []);

  /**
   * Create new field issue
   */
  const createIssue = useCallback(async (request: FieldIssueRequest): Promise<void> => {
    try {
      setIssueLoading(true);
      setIssueError(null);

      const issue = await adminApiClient.createFieldIssue(request);
      setSelectedIssue(issue);
    } catch (err) {
      const apiError = err instanceof Error ? (err as ApiError) : new Error(String(err));
      setIssueError(apiError as ApiError);
      throw err;
    } finally {
      setIssueLoading(false);
    }
  }, []);

  /**
   * Update field issue
   */
  const updateIssue = useCallback(
    async (issueId: string, updates: FieldIssueUpdate): Promise<void> => {
      try {
        setIssueLoading(true);
        setIssueError(null);

        const updated = await adminApiClient.updateFieldIssue(issueId, updates);
        setSelectedIssue(updated);
      } catch (err) {
        const apiError = err instanceof Error ? (err as ApiError) : new Error(String(err));
        setIssueError(apiError as ApiError);
        throw err;
      } finally {
        setIssueLoading(false);
      }
    },
    []
  );

  /**
   * Delete field issue
   */
  const deleteIssue = useCallback(async (issueId: string): Promise<void> => {
    try {
      setIssueLoading(true);
      setIssueError(null);

      await adminApiClient.deleteFieldIssue(issueId);
      if (selectedIssue?.id === issueId) {
        setSelectedIssue(null);
      }
    } catch (err) {
      const apiError = err instanceof Error ? (err as ApiError) : new Error(String(err));
      setIssueError(apiError as ApiError);
      throw err;
    } finally {
      setIssueLoading(false);
    }
  }, [selectedIssue]);

  /**
   * Clear issue error
   */
  const clearIssueError = useCallback(() => {
    setIssueError(null);
  }, []);

  // ===== Region Actions =====

  /**
   * Load list of regions
   */
  const loadRegions = useCallback(
    async (options?: PaginationOptions, activeOnly?: boolean): Promise<void> => {
      try {
        setRegionLoading(true);
        setRegionError(null);

        const response = await adminApiClient.listRegions(options, activeOnly);
        setRegions(response.data);
      } catch (err) {
        const apiError = err instanceof Error ? (err as ApiError) : new Error(String(err));
        setRegionError(apiError as ApiError);
        throw err;
      } finally {
        setRegionLoading(false);
      }
    },
    []
  );

  /**
   * Select region by ID
   */
  const selectRegion = useCallback(async (regionId: string): Promise<void> => {
    try {
      setRegionLoading(true);
      setRegionError(null);

      const region = await adminApiClient.getRegion(regionId);
      setSelectedRegion(region);
    } catch (err) {
      const apiError = err instanceof Error ? (err as ApiError) : new Error(String(err));
      setRegionError(apiError as ApiError);
      throw err;
    } finally {
      setRegionLoading(false);
    }
  }, []);

  /**
   * Create new region
   */
  const createRegion = useCallback(async (request: RegionRequest): Promise<void> => {
    try {
      setRegionLoading(true);
      setRegionError(null);

      const region = await adminApiClient.createRegion(request);
      setSelectedRegion(region);
    } catch (err) {
      const apiError = err instanceof Error ? (err as ApiError) : new Error(String(err));
      setRegionError(apiError as ApiError);
      throw err;
    } finally {
      setRegionLoading(false);
    }
  }, []);

  /**
   * Update region
   */
  const updateRegion = useCallback(
    async (regionId: string, updates: RegionUpdate): Promise<void> => {
      try {
        setRegionLoading(true);
        setRegionError(null);

        const updated = await adminApiClient.updateRegion(regionId, updates);
        setSelectedRegion(updated);
      } catch (err) {
        const apiError = err instanceof Error ? (err as ApiError) : new Error(String(err));
        setRegionError(apiError as ApiError);
        throw err;
      } finally {
        setRegionLoading(false);
      }
    },
    []
  );

  /**
   * Delete region
   */
  const deleteRegion = useCallback(async (regionId: string): Promise<void> => {
    try {
      setRegionLoading(true);
      setRegionError(null);

      await adminApiClient.deleteRegion(regionId);
      if (selectedRegion?.id === regionId) {
        setSelectedRegion(null);
      }
    } catch (err) {
      const apiError = err instanceof Error ? (err as ApiError) : new Error(String(err));
      setRegionError(apiError as ApiError);
      throw err;
    } finally {
      setRegionLoading(false);
    }
  }, [selectedRegion]);

  /**
   * Clear region error
   */
  const clearRegionError = useCallback(() => {
    setRegionError(null);
  }, []);

  // ===== Cache Management =====

  /**
   * Clear all caches
   */
  const clearAllCaches = useCallback(() => {
    adminApiClient.clearCache();
  }, []);

  return {
    // Admin User State & Actions
    admins,
    selectedAdmin,
    adminLoading,
    adminError,
    loadAdmins,
    selectAdmin,
    createAdmin,
    updateAdminRole,
    deleteAdmin,
    clearAdminError,

    // Field Issue State & Actions
    issues,
    selectedIssue,
    issueLoading,
    issueError,
    loadIssues,
    selectIssue,
    createIssue,
    updateIssue,
    deleteIssue,
    clearIssueError,

    // Region State & Actions
    regions,
    selectedRegion,
    regionLoading,
    regionError,
    loadRegions,
    selectRegion,
    createRegion,
    updateRegion,
    deleteRegion,
    clearRegionError,

    // Cache Management
    clearAllCaches,
  };
}
