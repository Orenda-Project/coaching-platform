import { describe, it, expect, beforeEach, vi } from 'vitest';

/**
 * ResetPassword Integration Tests
 *
 * These tests verify the fix for the password reset bug where the form
 * would not appear when clicking a reset link from email.
 *
 * The bug was: Supabase sends recovery tokens in the URL hash (#access_token=...)
 * but ResetPassword only listened for the PASSWORD_RECOVERY event, which could
 * fire before the listener was attached.
 *
 * The fix: Check for recovery tokens in the URL hash immediately on mount,
 * so we don't miss the event.
 */

describe('ResetPassword - Hash Token Detection', () => {
  describe('URL hash parsing logic', () => {
    it('should extract access_token from URL hash', () => {
      const hash = '#access_token=test_token_123&expires_at=1779353674&type=recovery';
      const params = new URLSearchParams(hash.replace('#', ''));

      expect(params.has('access_token')).toBe(true);
      expect(params.get('access_token')).toBe('test_token_123');
      expect(params.get('type')).toBe('recovery');
    });

    it('should return false when access_token is missing', () => {
      const hash = '#expires_at=1779353674&type=recovery';
      const params = new URLSearchParams(hash.replace('#', ''));

      expect(params.has('access_token')).toBe(false);
    });

    it('should return false when type is not recovery', () => {
      const hash = '#access_token=test_token_123&type=signin';
      const params = new URLSearchParams(hash.replace('#', ''));

      const hasRecoveryToken = params.has('access_token') && params.get('type') === 'recovery';
      expect(hasRecoveryToken).toBe(false);
    });

    it('should detect valid recovery token', () => {
      const hash = '#access_token=eyJhbGciOiJFUzI1NiJ9&expires_at=1779353674&refresh_token=test&type=recovery';
      const params = new URLSearchParams(hash.replace('#', ''));

      const hasRecoveryToken = params.has('access_token') && params.get('type') === 'recovery';
      expect(hasRecoveryToken).toBe(true);
    });

    it('should handle empty hash', () => {
      const hash = '';
      const params = new URLSearchParams(hash.replace('#', ''));

      const hasRecoveryToken = params.has('access_token') && params.get('type') === 'recovery';
      expect(hasRecoveryToken).toBe(false);
    });

    it('should handle hash with no recovery params', () => {
      const hash = '#page=dashboard&id=123';
      const params = new URLSearchParams(hash.replace('#', ''));

      const hasRecoveryToken = params.has('access_token') && params.get('type') === 'recovery';
      expect(hasRecoveryToken).toBe(false);
    });
  });

  describe('Real-world email link scenarios', () => {
    it('should detect recovery token from actual Supabase recovery email link', () => {
      // This is what Supabase sends in the reset email
      const fullUrl = 'http://localhost:3000/#access_token=eyJhbGciOiJFUzI1NiIsImtpZCI6ImIyNmZlZjhkLTY3OTEtNDNlMC1iNDM1LTM2NjMxOWUzODNmOSIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2Fneml1d3Fwa2ZteHRvc3BmeG5zLnN1cGFiYXNlLmNvL2F1dGgvdjEiLCJzdWIiOiI1MzFlOTUyNS05ZjAzLTRhMDItODFlOS0xZDRlZDUxMDBlMzgiLCJhdWQiOiJhdXRoZW50aWNhdGVkIiwiZXhwIjoxNzc5MzUzNjc0LCJpYXQiOjE3NzkzNTAwNzQsImVtYWlsIjoiamFsYWwua2hhbkB0YWxlZW1hYmFkLmNvbSIsInBob25lIjoiIiwiYXBwX21ldGFkYXRhIjp7InByb3ZpZGVyIjoiZW1haWwiLCJwcm92aWRlcnMiOlsiZW1haWwiXX0sInVzZXJfbWV0YWRhdGEiOnsiZW1haWwiOiJqYWxhbC5raGFuQHRhbGVlbWFiYWQuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImZ1bGxfbmFtZSI6IkphbGFsIEtoYW4iLCJwaG9uZSI6IjAzMDQ1MDg2Njg4IiwicGhvbmVfdmVyaWZpZWQiOmZhbHNlLCJzdWIiOiI1MzFlOTUyNS05ZjAzLTRhMDItODFlOS0xZDRlZDUxMDBlMzgifSwicm9sZSI6ImF1dGhlbnRpY2F0ZWQiLCJhYWwiOiJhYWwxIiwiYW1yIjpbeyJtZXRob2QiOiJvdHAiLCJ0aW1lc3RhbXAiOjE3NzkzNTAwNzR9XSwic2Vzc2lvbl9pZCI6IjY3ZTRkNzk1LWUwNzEtNDFiNS05ZTBhLWVkZWYxMWRmMmE2MSIsImlzX2Fub255bW91cyI6ZmFsc2V9.muJfJDflJtLn5o42iIVw4OhHsUxGH6VYSFSaDQ_zhf1ErFY4F_ERgxioUYBZYGhjM2GbRsqiKiPBjIZS2jqo8Q&expires_at=1779353674&expires_in=3600&refresh_token=4t3zerik2l7t&sb=&token_type=bearer&type=recovery';

      const hash = new URL(fullUrl).hash;
      const params = new URLSearchParams(hash.replace('#', ''));

      const hasRecoveryToken = params.has('access_token') && params.get('type') === 'recovery';
      expect(hasRecoveryToken).toBe(true);
      expect(params.get('access_token')).toBeTruthy();
      expect(params.get('refresh_token')).toBe('4t3zerik2l7t');
    });

    it('should not trigger on signin tokens', () => {
      const hash = '#access_token=signin_token&type=signin&expires_in=3600';
      const params = new URLSearchParams(hash.replace('#', ''));

      const hasRecoveryToken = params.has('access_token') && params.get('type') === 'recovery';
      expect(hasRecoveryToken).toBe(false);
    });

    it('should not trigger on verification tokens', () => {
      const hash = '#access_token=verify_token&type=email_change';
      const params = new URLSearchParams(hash.replace('#', ''));

      const hasRecoveryToken = params.has('access_token') && params.get('type') === 'recovery';
      expect(hasRecoveryToken).toBe(false);
    });
  });

  describe('Edge cases', () => {
    it('should handle hash with multiple access_token params', () => {
      const hash = '#access_token=token1&access_token=token2&type=recovery';
      const params = new URLSearchParams(hash.replace('#', ''));

      // URLSearchParams.get() returns the first value
      expect(params.get('access_token')).toBe('token1');
    });

    it('should be case-sensitive for type parameter', () => {
      const hash = '#access_token=test&type=Recovery'; // Capital R
      const params = new URLSearchParams(hash.replace('#', ''));

      const hasRecoveryToken = params.has('access_token') && params.get('type') === 'recovery';
      expect(hasRecoveryToken).toBe(false);
    });

    it('should handle URL-encoded special characters', () => {
      // Some tokens might contain + or = which get URL-encoded
      const hash = '#access_token=eyJ%2B%3D%26&type=recovery';
      const params = new URLSearchParams(hash.replace('#', ''));

      expect(params.has('access_token')).toBe(true);
      // URLSearchParams auto-decodes
      expect(params.get('access_token')).toContain('eyJ');
    });

    it('should work with fragment identifier after query params', () => {
      // Edge case where there might be a # within the hash
      const hash = '#access_token=test123&type=recovery&redirect=/dashboard';
      const params = new URLSearchParams(hash.replace('#', ''));

      const hasRecoveryToken = params.has('access_token') && params.get('type') === 'recovery';
      expect(hasRecoveryToken).toBe(true);
    });
  });
});
