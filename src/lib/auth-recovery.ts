/**
 * Authentication recovery utilities
 * Extracted for testability and reusability
 */

/**
 * Determines if a password recovery session is ready based on auth event and session state
 *
 * A recovery session is ready when:
 * 1. PASSWORD_RECOVERY event fires with a valid session, OR
 * 2. SIGNED_IN event fires with a valid session
 *
 * @param event - The auth state change event type
 * @param session - The session object, may be null or undefined
 * @returns true if the recovery session is ready, false otherwise
 */
export function isRecoverySessionReady(event: string, session: any): boolean {
  // PASSWORD_RECOVERY event indicates Supabase has processed the recovery token
  // SIGNED_IN event indicates a valid authenticated session exists
  const isValidEvent = event === 'PASSWORD_RECOVERY' || event === 'SIGNED_IN';

  // Session must have a user object to be valid
  const hasValidSession = session?.user !== undefined;

  return isValidEvent && hasValidSession;
}

/**
 * Checks if recovery tokens are present in the URL hash
 *
 * Supabase sends password recovery links with tokens in the fragment:
 * #access_token=...&type=recovery
 *
 * @returns true if recovery tokens are detected, false otherwise
 */
export function hasRecoveryTokensInHash(): boolean {
  const hashParams = new URLSearchParams(window.location.hash.replace('#', ''));
  return hashParams.has('access_token') && hashParams.get('type') === 'recovery';
}
