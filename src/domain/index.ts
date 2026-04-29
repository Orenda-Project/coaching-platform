// Public surface of the domain layer.
// Pages and hooks should import from `@/domain` — never reach into individual files
// for business rules. Adding a new rule? New file in this folder, re-export here.

export * from './thresholds';
export * from './persona';
