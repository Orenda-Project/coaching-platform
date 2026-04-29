// Canonical Supabase mock for unit/hook tests.
// Pattern: every chainable method returns `this`; terminal methods return a
// thennable resolving to { data, error }. Configure per-test via the queue API.
//
// Usage in a test file:
//
//   import { vi } from 'vitest';
//   import { createSupabaseMock } from '@/test/mocks/supabase';
//
//   const mock = createSupabaseMock();
//   vi.mock('@/integrations/supabase/client', () => ({ supabase: mock.client }));
//
//   beforeEach(() => mock.reset());
//
//   it('happy path', async () => {
//     mock.queueResult({ data: [{ id: 1 }], error: null });
//     // ... call code under test, then assert on mock.calls
//   });
//
// Design notes:
//   - One mock shape, repo-wide. Do not invent local mocks per file.
//   - If a chain method is missing, ADD it here rather than working around it.
//   - The mock records every call for assertions: `mock.calls.from`, `mock.calls.insert`, etc.

import { vi } from 'vitest';

export type SupabaseResult<T = unknown> = { data: T | null; error: { message: string } | null };

type Call = { method: string; args: unknown[] };

export interface SupabaseMock {
  client: {
    from: (table: string) => ChainableMock;
    auth: {
      getSession: ReturnType<typeof vi.fn>;
      getUser: ReturnType<typeof vi.fn>;
      signInWithPassword: ReturnType<typeof vi.fn>;
      signUp: ReturnType<typeof vi.fn>;
      signOut: ReturnType<typeof vi.fn>;
      onAuthStateChange: ReturnType<typeof vi.fn>;
    };
  };
  queueResult: <T>(result: SupabaseResult<T>) => void;
  queueError: (message: string) => void;
  reset: () => void;
  calls: Call[];
  callsByMethod: (method: string) => Call[];
}

interface ChainableMock {
  select: (...args: unknown[]) => ChainableMock;
  insert: (...args: unknown[]) => ChainableMock;
  update: (...args: unknown[]) => ChainableMock;
  upsert: (...args: unknown[]) => ChainableMock;
  delete: (...args: unknown[]) => ChainableMock;
  eq: (...args: unknown[]) => ChainableMock;
  neq: (...args: unknown[]) => ChainableMock;
  in: (...args: unknown[]) => ChainableMock;
  is: (...args: unknown[]) => ChainableMock;
  order: (...args: unknown[]) => ChainableMock;
  limit: (...args: unknown[]) => ChainableMock;
  range: (...args: unknown[]) => ChainableMock;
  single: () => Promise<SupabaseResult>;
  maybeSingle: () => Promise<SupabaseResult>;
  then: <T>(onFulfilled: (value: SupabaseResult) => T) => Promise<T>;
}

export function createSupabaseMock(): SupabaseMock {
  const calls: Call[] = [];
  const resultQueue: SupabaseResult[] = [];

  const record = (method: string, args: unknown[]) => {
    calls.push({ method, args });
  };

  const nextResult = (): SupabaseResult => {
    return resultQueue.shift() ?? { data: null, error: null };
  };

  const buildChain = (): ChainableMock => {
    const chain: ChainableMock = {
      select: (...args) => { record('select', args); return chain; },
      insert: (...args) => { record('insert', args); return chain; },
      update: (...args) => { record('update', args); return chain; },
      upsert: (...args) => { record('upsert', args); return chain; },
      delete: (...args) => { record('delete', args); return chain; },
      eq: (...args) => { record('eq', args); return chain; },
      neq: (...args) => { record('neq', args); return chain; },
      in: (...args) => { record('in', args); return chain; },
      is: (...args) => { record('is', args); return chain; },
      order: (...args) => { record('order', args); return chain; },
      limit: (...args) => { record('limit', args); return chain; },
      range: (...args) => { record('range', args); return chain; },
      single: () => { record('single', []); return Promise.resolve(nextResult()); },
      maybeSingle: () => { record('maybeSingle', []); return Promise.resolve(nextResult()); },
      then: (onFulfilled) => Promise.resolve(nextResult()).then(onFulfilled),
    };
    return chain;
  };

  const client = {
    from: (table: string) => {
      record('from', [table]);
      return buildChain();
    },
    auth: {
      getSession: vi.fn().mockResolvedValue({ data: { session: null }, error: null }),
      getUser: vi.fn().mockResolvedValue({ data: { user: null }, error: null }),
      signInWithPassword: vi.fn().mockResolvedValue({ data: null, error: null }),
      signUp: vi.fn().mockResolvedValue({ data: null, error: null }),
      signOut: vi.fn().mockResolvedValue({ error: null }),
      onAuthStateChange: vi.fn().mockReturnValue({
        data: { subscription: { unsubscribe: vi.fn() } },
      }),
    },
  };

  return {
    client,
    queueResult: <T>(result: SupabaseResult<T>) => {
      resultQueue.push(result as SupabaseResult);
    },
    queueError: (message: string) => {
      resultQueue.push({ data: null, error: { message } });
    },
    reset: () => {
      calls.length = 0;
      resultQueue.length = 0;
    },
    calls,
    callsByMethod: (method: string) => calls.filter((c) => c.method === method),
  };
}
