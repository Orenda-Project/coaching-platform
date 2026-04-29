// Auth context mock helper. Use when a hook/component depends on `useAuth()`.
//
// Usage:
//   import { mockUseAuth } from '@/test/mocks/auth-context';
//   mockUseAuth({ user: { id: 'u-1' }, profile: { persona: 'B' } });
//
// Pair with: vi.mock('@/contexts/AuthContext', ...) — see helpers/render.tsx
// for the canonical wrapper that uses this for renderWithProviders().

import { vi } from 'vitest';

export type AuthMockState = {
  user: { id: string; email?: string } | null;
  profile: { persona?: string | null; full_name?: string | null } | null;
  loading?: boolean;
};

const defaultState: AuthMockState = {
  user: null,
  profile: null,
  loading: false,
};

let currentState: AuthMockState = { ...defaultState };

export function mockUseAuth(state: Partial<AuthMockState>) {
  currentState = { ...defaultState, ...state };
}

export function resetAuthMock() {
  currentState = { ...defaultState };
}

export function getAuthMockState(): AuthMockState {
  return currentState;
}

// Convenience factory for `vi.mock('@/contexts/AuthContext', () => buildAuthModuleMock())`
export function buildAuthModuleMock() {
  return {
    useAuth: () => ({
      ...currentState,
      signUp: vi.fn(),
      signIn: vi.fn(),
      signOut: vi.fn(),
      refreshProfile: vi.fn(),
      session: null,
    }),
    AuthProvider: ({ children }: { children: React.ReactNode }) => children,
  };
}
