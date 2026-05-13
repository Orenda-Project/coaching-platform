/**
 * Training domain rules for practice section access control.
 * Ensures users complete slides before attempting practice scenarios.
 */

/**
 * Determines if a user can access the practice section based on content completion.
 * @param contentCompleted - Whether the user has completed viewing all training content
 * @returns true if practice section should be accessible, false if locked
 */
export function canAccessPracticeSection(contentCompleted: boolean): boolean {
  return contentCompleted;
}

/**
 * Gets the appropriate message for locked practice section.
 * @returns User-friendly message explaining why practice is locked
 */
export function getPracticeLockMessage(): string {
  return "Please complete all training slides before attempting the practice section.";
}
