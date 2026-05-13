import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import {
  lockForUpload,
  unlockUpload,
} from './audioQueue';

// TODO: Use fake-indexeddb package to test IndexedDB operations
// See: https://github.com/dumbmatter/fakeIndexedDB
// This would require installing the package and setting up the test environment

describe('audioQueue', () => {
  const testObservationId = 'test-obs-123';

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

});
