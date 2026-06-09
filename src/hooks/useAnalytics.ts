/**
 * useAnalytics Hook
 *
 * React hook for managing analytics data and events
 *
 * Features:
 * - Log user events
 * - Fetch and update metrics
 * - Get module-level analytics
 * - Retrieve dashboard data
 * - Error handling
 *
 * Usage:
 *   const { logEvent, getMetrics, getDashboard } = useAnalytics(userId);
 *   await logEvent({ event_type: "quiz_completed", event_data: {...} });
 *   const metrics = await getMetrics();
 *   const dashboard = await getDashboard();
 */

import { useCallback } from "react";
import { analyticsApiClient } from "@/lib/apiClients/analyticsApiClient";
import type {
  AnalyticsEvent,
  UserMetrics,
  DashboardData,
  EventLogRequest,
  MetricsUpdate,
  ModuleAnalytics,
  PaginationOptions,
  EventsResponse,
  AllAnalyticsResponse,
} from "@/lib/apiClients/analyticsApiClient";

interface UseAnalyticsReturn {
  logEvent: (eventData: EventLogRequest) => Promise<AnalyticsEvent>;
  getEvents: (options?: PaginationOptions) => Promise<EventsResponse>;
  getEventsByType: (
    eventType: string,
    options?: PaginationOptions
  ) => Promise<EventsResponse>;
  getMetrics: () => Promise<UserMetrics>;
  updateMetrics: (updates: MetricsUpdate) => Promise<UserMetrics>;
  incrementMetric: (
    metricName: keyof UserMetrics,
    increment: number
  ) => Promise<UserMetrics>;
  getModuleAnalytics: (moduleId: string) => Promise<ModuleAnalytics>;
  getDashboard: () => Promise<DashboardData>;
  getAllAnalytics: (options?: PaginationOptions) => Promise<AllAnalyticsResponse>;
}

/**
 * Hook for analytics operations
 */
export function useAnalytics(userId: string): UseAnalyticsReturn {
  /**
   * Log an event for the user
   */
  const logEvent = useCallback(
    async (eventData: EventLogRequest): Promise<AnalyticsEvent> => {
      return analyticsApiClient.logEvent(userId, eventData);
    },
    [userId]
  );

  /**
   * Get user events
   */
  const getEvents = useCallback(
    async (options?: PaginationOptions): Promise<EventsResponse> => {
      return analyticsApiClient.getEvents(userId, options);
    },
    [userId]
  );

  /**
   * Get events filtered by type
   */
  const getEventsByType = useCallback(
    async (
      eventType: string,
      options?: PaginationOptions
    ): Promise<EventsResponse> => {
      return analyticsApiClient.getEventsByType(userId, eventType, options);
    },
    [userId]
  );

  /**
   * Get user metrics
   */
  const getMetrics = useCallback(async (): Promise<UserMetrics> => {
    return analyticsApiClient.getMetrics(userId);
  }, [userId]);

  /**
   * Update user metrics
   */
  const updateMetrics = useCallback(
    async (updates: MetricsUpdate): Promise<UserMetrics> => {
      return analyticsApiClient.updateMetrics(userId, updates);
    },
    [userId]
  );

  /**
   * Increment a metric
   */
  const incrementMetric = useCallback(
    async (
      metricName: keyof UserMetrics,
      increment: number
    ): Promise<UserMetrics> => {
      return analyticsApiClient.incrementMetric(userId, metricName, increment);
    },
    [userId]
  );

  /**
   * Get module-level analytics
   */
  const getModuleAnalytics = useCallback(
    async (moduleId: string): Promise<ModuleAnalytics> => {
      return analyticsApiClient.getModuleAnalytics(moduleId);
    },
    []
  );

  /**
   * Get user dashboard data
   */
  const getDashboard = useCallback(async (): Promise<DashboardData> => {
    return analyticsApiClient.getDashboard(userId);
  }, [userId]);

  /**
   * Get all analytics (admin only)
   */
  const getAllAnalytics = useCallback(
    async (options?: PaginationOptions): Promise<AllAnalyticsResponse> => {
      return analyticsApiClient.getAllAnalytics(options);
    },
    []
  );

  return {
    logEvent,
    getEvents,
    getEventsByType,
    getMetrics,
    updateMetrics,
    incrementMetric,
    getModuleAnalytics,
    getDashboard,
    getAllAnalytics,
  };
}
