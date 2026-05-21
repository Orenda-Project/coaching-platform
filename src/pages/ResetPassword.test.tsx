import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { isRecoverySessionReady, hasRecoveryTokensInHash } from '@/lib/auth-recovery';

/**
 * ResetPassword Recovery Logic Tests
 *
 * Tests the extracted auth-recovery functions that power the password reset flow.
 * These tests validate the actual production code (not copies), ensuring:
 * - The PASSWORD_RECOVERY event correctly triggers ready state
 * - Other events do not trigger ready state
 * - Session validation works correctly
 * - URL hash detection works for recovery tokens
 */

describe('isRecoverySessionReady - Core recovery logic', () => {
  describe('PASSWORD_RECOVERY event', () => {
    it('should return true when PASSWORD_RECOVERY event fires with valid session', () => {
      const event = 'PASSWORD_RECOVERY';
      const session = { user: { id: 'user-123', email: 'test@example.com' } };

      expect(isRecoverySessionReady(event, session)).toBe(true);
    });

    it('should return false when PASSWORD_RECOVERY event fires with null session', () => {
      const event = 'PASSWORD_RECOVERY';
      const session = null;

      expect(isRecoverySessionReady(event, session)).toBe(false);
    });

    it('should return false when PASSWORD_RECOVERY event fires with session but no user', () => {
      const event = 'PASSWORD_RECOVERY';
      const session = { user: undefined };

      expect(isRecoverySessionReady(event, session)).toBe(false);
    });
  });

  describe('SIGNED_IN event', () => {
    it('should return true when SIGNED_IN event fires with valid session', () => {
      const event = 'SIGNED_IN';
      const session = { user: { id: 'user-456' } };

      expect(isRecoverySessionReady(event, session)).toBe(true);
    });

    it('should return false when SIGNED_IN event fires with no session', () => {
      const event = 'SIGNED_IN';
      const session = null;

      expect(isRecoverySessionReady(event, session)).toBe(false);
    });
  });

  describe('Other auth events', () => {
    it('should return false for SIGNED_OUT event', () => {
      const event = 'SIGNED_OUT';
      const session = { user: { id: 'user-789' } };

      expect(isRecoverySessionReady(event, session)).toBe(false);
    });

    it('should return false for USER_UPDATED event', () => {
      const event = 'USER_UPDATED';
      const session = { user: { id: 'user-789' } };

      expect(isRecoverySessionReady(event, session)).toBe(false);
    });

    it('should return false for MFA_CHALLENGE_VERIFIED event', () => {
      const event = 'MFA_CHALLENGE_VERIFIED';
      const session = { user: { id: 'user-789' } };

      expect(isRecoverySessionReady(event, session)).toBe(false);
    });

    it('should return false for unknown event', () => {
      const event = 'UNKNOWN_EVENT';
      const session = { user: { id: 'user-789' } };

      expect(isRecoverySessionReady(event, session)).toBe(false);
    });
  });

  describe('Session validation', () => {
    it('should require session.user to be defined', () => {
      const event = 'PASSWORD_RECOVERY';
      const session = {}; // No user property

      expect(isRecoverySessionReady(event, session)).toBe(false);
    });

    it('should handle undefined session gracefully', () => {
      const event = 'PASSWORD_RECOVERY';
      const session = undefined;

      expect(isRecoverySessionReady(event, session)).toBe(false);
    });

    it('should accept session with minimal user object', () => {
      const event = 'PASSWORD_RECOVERY';
      const session = { user: {} }; // Empty user object is sufficient

      expect(isRecoverySessionReady(event, session)).toBe(true);
    });

    it('should accept session with complete user object', () => {
      const event = 'PASSWORD_RECOVERY';
      const session = {
        user: {
          id: 'user-123',
          email: 'test@example.com',
          created_at: '2026-05-21T00:00:00Z',
        },
      };

      expect(isRecoverySessionReady(event, session)).toBe(true);
    });
  });
});

describe('hasRecoveryTokensInHash - URL hash detection', () => {
  beforeEach(() => {
    // Save original location
    delete (window as any).location;
    (window as any).location = { hash: '' };
  });

  afterEach(() => {
    // Restore location
    (window as any).location = window.location;
  });

  it('should detect recovery token from Supabase recovery link', () => {
    const recoveryHash =
      '#access_token=eyJhbGciOiJFUzI1NiJ9&expires_at=1779353674&type=recovery';
    (window as any).location.hash = recoveryHash;

    expect(hasRecoveryTokensInHash()).toBe(true);
  });

  it('should not detect signin token as recovery token', () => {
    const signinHash = '#access_token=test_token&type=signin';
    (window as any).location.hash = signinHash;

    expect(hasRecoveryTokensInHash()).toBe(false);
  });

  it('should not detect missing access_token', () => {
    const hash = '#type=recovery';
    (window as any).location.hash = hash;

    expect(hasRecoveryTokensInHash()).toBe(false);
  });

  it('should handle empty hash', () => {
    (window as any).location.hash = '';

    expect(hasRecoveryTokensInHash()).toBe(false);
  });

  it('should handle hash with non-recovery params', () => {
    (window as any).location.hash = '#page=dashboard&id=123';

    expect(hasRecoveryTokensInHash()).toBe(false);
  });

  it('should be case-sensitive for type=recovery', () => {
    const hash = '#access_token=test&type=Recovery'; // Capital R
    (window as any).location.hash = hash;

    expect(hasRecoveryTokensInHash()).toBe(false);
  });

  it('should handle actual Supabase recovery email link with JWT token', () => {
    const longJWT =
      'eyJhbGciOiJFUzI1NiIsImtpZCI6ImIyNmZlZjhkLTY3OTEtNDNlMC1iNDM1LTM2NjMxOWUzODNmOSIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2Fneml1d3Fwa2ZteHRvc3BmeG5zLnN1cGFiYXNlLmNvL2F1dGgvdjEiLCJzdWIiOiI1MzFlOTUyNS05ZjAzLTRhMDItODFlOS0xZDRlZDUxMDBlMzgiLCJhdWQiOiJhdXRoZW50aWNhdGVkIiwiZXhwIjoxNzc5MzUzNjc0LCJpYXQiOjE3NzkzNTAwNzQsImVtYWlsIjoiamFsYWwua2hhbkB0YWxlZW1hYmFkLmNvbSIsInBob25lIjoiIiwiYXBwX21ldGFkYXRhIjp7InByb3ZpZGVyIjoiZW1haWwiLCJwcm92aWRlcnMiOlsiZW1haWwiXX0sInVzZXJfbWV0YWRhdGEiOnsiZW1haWwiOiJqYWxhbC5raGFuQHRhbGVlbWFiYWQuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImZ1bGxfbmFtZSI6IkphbGFsIEtoYW4iLCJwaG9uZSI6IjAzMDQ1MDg2Njg4IiwicGhvbmVfdmVyaWZpZWQiOmZhbHNlLCJzdWIiOiI1MzFlOTUyNS05ZjAzLTRhMDItODFlOS0xZDRlZDUxMDBlMzgifSwicm9sZSI6ImF1dGhlbnRpY2F0ZWQiLCJhYWwiOiJhYWwxIiwiYW1yIjpbeyJtZXRob2QiOiJvdHAiLCJ0aW1lc3RhbXAiOjE3NzkzNTAwNzR9XSwic2Vzc2lvbl9pZCI6IjY3ZTRkNzk1LWUwNzEtNDFiNS05ZTBhLWVkZWYxMWRmMmE2MSIsImlzX2Fub255bW91cyI6ZmFsc2V9.muJfJDflJtLn5o42iIVw4OhHsUxGH6VYSFSaDQ_zhf1ErFY4F_ERgxioUYBZYGhjM2GbRsqiKiPBjIZS2jqo8Q';
    const hash =
      `#access_token=${longJWT}&expires_at=1779353674&refresh_token=4t3zerik2l7t&type=recovery`;
    (window as any).location.hash = hash;

    expect(hasRecoveryTokensInHash()).toBe(true);
  });

  it('should handle URL-encoded token characters', () => {
    const hash = '#access_token=eyJ%2B%3D%26&type=recovery';
    (window as any).location.hash = hash;

    expect(hasRecoveryTokensInHash()).toBe(true);
  });

  it('should handle multiple parameters in hash', () => {
    const hash =
      '#access_token=test&expires_at=1234&refresh_token=abc&type=recovery&other=param';
    (window as any).location.hash = hash;

    expect(hasRecoveryTokensInHash()).toBe(true);
  });
});

describe('Race condition fix validation', () => {
  it('should only set ready when BOTH event and session are valid', () => {
    // This is the core race condition fix: we don't show the form just because
    // we detected a recovery token in the hash. We wait for the auth event.

    // Scenario 1: Recovery token in hash, but no auth event yet
    // → should NOT be ready
    expect(isRecoverySessionReady('INITIAL', null)).toBe(false);

    // Scenario 2: Recovery token in hash, PASSWORD_RECOVERY event fires
    // → should be ready
    expect(isRecoverySessionReady('PASSWORD_RECOVERY', { user: { id: '1' } })).toBe(true);

    // Scenario 3: Recovery token in hash, wrong event fires (e.g., USER_UPDATED)
    // → should NOT be ready
    expect(isRecoverySessionReady('USER_UPDATED', { user: { id: '1' } })).toBe(false);
  });
});
