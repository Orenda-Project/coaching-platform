/**
 * Tests for data layer: getObservation() and patchObservation()
 */

import { describe, it, expect, beforeEach, vi, afterEach } from 'vitest';
import { getObservation, patchObservation } from '../observations';

const API_URL = 'http://localhost:8000';

describe('observations data layer', () => {
  let fetchMock: ReturnType<typeof vi.fn>;

  beforeEach(() => {
    fetchMock = vi.fn();
    global.fetch = fetchMock;
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  const mockObservation = {
    id: 'obs-123',
    observer_id: 'observer-1',
    teacher_name: 'Test Teacher',
    school_name: 'Test School',
    subject: 'Math',
    grade: 'Grade 3',
    framework: 'FICO',
    date: '2026-06-15',
    visit_purpose: 'Routine',
    status: 'Scheduled',
    region: 'Lahore',
    total_score: 0,
    hots_rubric: {},
    created_at: '2026-06-15T10:00:00Z',
    updated_at: '2026-06-15T10:00:00Z',
  };

  describe('getObservation', () => {
    it('returns a CotObservation on success', async () => {
      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => mockObservation,
        text: async () => JSON.stringify(mockObservation),
      });

      const result = await getObservation('obs-123');

      expect(result.id).toBe('obs-123');
      expect(result.teacher_name).toBe('Test Teacher');
      expect(fetchMock).toHaveBeenCalledWith(
        `${API_URL}/api/coaching/observations/obs-123`,
        expect.objectContaining({
          headers: expect.objectContaining({
            'Content-Type': 'application/json',
          }),
        }),
      );
    });

    it('throws on 404', async () => {
      fetchMock.mockResolvedValueOnce({
        ok: false,
        status: 404,
        statusText: 'Not Found',
        text: async () => 'Observation not found',
      });

      await expect(getObservation('nonexistent')).rejects.toThrow('API error 404');
    });
  });

  describe('patchObservation', () => {
    it('sends correct URL, method, and body', async () => {
      const updated = { ...mockObservation, notes_for_teacher: 'Great lesson' };
      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => updated,
        text: async () => JSON.stringify(updated),
      });

      const result = await patchObservation('obs-123', {
        notes_for_teacher: 'Great lesson',
      });

      expect(result.notes_for_teacher).toBe('Great lesson');
      expect(fetchMock).toHaveBeenCalledWith(
        `${API_URL}/api/coaching/observations/obs-123`,
        expect.objectContaining({
          method: 'PATCH',
          body: JSON.stringify({ notes_for_teacher: 'Great lesson' }),
          headers: expect.objectContaining({
            'Content-Type': 'application/json',
          }),
        }),
      );
    });

    it('returns updated CotObservation', async () => {
      const updated = {
        ...mockObservation,
        status: 'Draft',
        hots_rubric: { criticalThinking: 8 },
        total_score: 55,
        proficiency_level: 'Proficient',
      };
      fetchMock.mockResolvedValueOnce({
        ok: true,
        json: async () => updated,
        text: async () => JSON.stringify(updated),
      });

      const result = await patchObservation('obs-123', {
        status: 'Draft',
        hots_rubric: { criticalThinking: 8 },
        total_score: 55,
        proficiency_level: 'Proficient',
      });

      expect(result.status).toBe('Draft');
      expect(result.total_score).toBe(55);
      expect(result.proficiency_level).toBe('Proficient');
    });

    it('throws on 404', async () => {
      fetchMock.mockResolvedValueOnce({
        ok: false,
        status: 404,
        statusText: 'Not Found',
        text: async () => 'Observation not found',
      });

      await expect(
        patchObservation('nonexistent', { status: 'Draft' }),
      ).rejects.toThrow('API error 404');
    });
  });
});
