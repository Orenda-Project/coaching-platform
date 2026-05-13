import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import {
  saveAudioToQueue,
  getPendingAudios,
  getPendingAudio,
  removeFromQueue,
  lockForUpload,
  unlockUpload,
  saveSavedAudio,
  getSavedAudio,
  deleteSavedAudio,
} from './audioQueue';

describe('audioQueue', () => {
  const testObservationId = 'test-obs-123';
  const testObserverId = 'test-user-456';
  const testAudioBlob = new Blob(['fake audio data'], { type: 'audio/webm' });

  beforeEach(() => {
    // Clear IndexedDB before each test
    indexedDB.deleteDatabase('coaching_audio_queue');
  });

  describe('pending uploads', () => {
    it('should save audio to pending queue', async () => {
      const record = {
        observation_id: testObservationId,
        blob: testAudioBlob,
        mime_type: 'audio/webm',
        queued_at: new Date().toISOString(),
        observer_id: testObserverId,
      };

      await saveAudioToQueue(record);
      const pending = await getPendingAudios();

      expect(pending).toHaveLength(1);
      expect(pending[0].observation_id).toBe(testObservationId);
    });

    it('should retrieve specific pending audio', async () => {
      const record = {
        observation_id: testObservationId,
        blob: testAudioBlob,
        mime_type: 'audio/webm',
        queued_at: new Date().toISOString(),
        observer_id: testObserverId,
      };

      await saveAudioToQueue(record);
      const retrieved = await getPendingAudio(testObservationId);

      expect(retrieved).toBeDefined();
      expect(retrieved?.observation_id).toBe(testObservationId);
    });

    it('should remove audio from queue', async () => {
      const record = {
        observation_id: testObservationId,
        blob: testAudioBlob,
        mime_type: 'audio/webm',
        queued_at: new Date().toISOString(),
        observer_id: testObserverId,
      };

      await saveAudioToQueue(record);
      await removeFromQueue(testObservationId);

      const pending = await getPendingAudios();
      expect(pending).toHaveLength(0);
    });
  });

  describe('saved audio', () => {
    it('should save audio locally', async () => {
      await saveSavedAudio(testObservationId, testAudioBlob, 'audio/webm');
      const saved = await getSavedAudio(testObservationId);

      expect(saved).toBeDefined();
      expect(saved?.mime_type).toBe('audio/webm');
    });

    it('should retrieve saved audio', async () => {
      await saveSavedAudio(testObservationId, testAudioBlob, 'audio/webm');
      const saved = await getSavedAudio(testObservationId);

      expect(saved?.blob).toBeDefined();
      expect(saved?.blob instanceof Blob).toBe(true);
    });

    it('should delete saved audio', async () => {
      await saveSavedAudio(testObservationId, testAudioBlob, 'audio/webm');
      await deleteSavedAudio(testObservationId);

      const saved = await getSavedAudio(testObservationId);
      expect(saved).toBeUndefined();
    });

    it('should return undefined for non-existent audio', async () => {
      const saved = await getSavedAudio('non-existent');
      expect(saved).toBeUndefined();
    });
  });

  describe('locks', () => {
    it('should acquire lock on first call', () => {
      const acquired = lockForUpload(testObservationId);
      expect(acquired).toBe(true);
      unlockUpload(testObservationId);
    });

    it('should return false if lock already held', () => {
      lockForUpload(testObservationId);
      const acquired = lockForUpload(testObservationId);
      expect(acquired).toBe(false);
      unlockUpload(testObservationId);
    });

    it('should release lock after unlock', () => {
      lockForUpload(testObservationId);
      unlockUpload(testObservationId);

      const acquired = lockForUpload(testObservationId);
      expect(acquired).toBe(true);
      unlockUpload(testObservationId);
    });

    it('should allow multiple different locks', () => {
      const obs1 = 'obs-1';
      const obs2 = 'obs-2';

      const acquired1 = lockForUpload(obs1);
      const acquired2 = lockForUpload(obs2);

      expect(acquired1).toBe(true);
      expect(acquired2).toBe(true);

      unlockUpload(obs1);
      unlockUpload(obs2);
    });
  });

  describe('concurrent operations', () => {
    it('should handle multiple pending audios', async () => {
      const records = [
        {
          observation_id: 'obs-1',
          blob: testAudioBlob,
          mime_type: 'audio/webm',
          queued_at: new Date().toISOString(),
          observer_id: testObserverId,
        },
        {
          observation_id: 'obs-2',
          blob: testAudioBlob,
          mime_type: 'audio/webm',
          queued_at: new Date().toISOString(),
          observer_id: testObserverId,
        },
      ];

      await Promise.all(records.map(r => saveAudioToQueue(r)));
      const pending = await getPendingAudios();

      expect(pending).toHaveLength(2);
    });

    it('should keep saved and pending stores separate', async () => {
      await saveAudioToQueue({
        observation_id: 'obs-pending',
        blob: testAudioBlob,
        mime_type: 'audio/webm',
        queued_at: new Date().toISOString(),
        observer_id: testObserverId,
      });

      await saveSavedAudio('obs-saved', testAudioBlob, 'audio/webm');

      const pending = await getPendingAudios();
      const saved = await getSavedAudio('obs-saved');

      expect(pending).toHaveLength(1);
      expect(pending[0].observation_id).toBe('obs-pending');
      expect(saved).toBeDefined();
    });
  });
});
