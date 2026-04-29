// User factory. Default = an authenticated coach with persona 'B' (median real user).
// Override only what your test cares about.

export interface FixtureUser {
  id: string;
  email: string;
}

let counter = 0;

export function makeUser(overrides: Partial<FixtureUser> = {}): FixtureUser {
  counter += 1;
  return {
    id: `user-${counter}`,
    email: `coach${counter}@test.local`,
    ...overrides,
  };
}
