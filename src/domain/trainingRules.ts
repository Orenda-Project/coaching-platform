/**
 * Training domain rules for practice section access control and training completion.
 * Flow: Slides → Practice Scenario → Training Complete
 */

/**
 * Determines if a user can access the practice section based on slide completion.
 * @param slidesCompleted - Whether the user has completed viewing all slides
 * @returns true if practice section should be accessible, false if locked
 */
export function canAccessPracticeSection(slidesCompleted: boolean): boolean {
  return slidesCompleted;
}

/**
 * Gets the appropriate message for locked practice section.
 * @returns User-friendly message explaining why practice is locked
 */
export function getPracticeLockMessage(): string {
  return "Please complete all training slides before attempting the practice section.";
}

/**
 * Determines if training is fully complete.
 * Training requires BOTH slides AND scenarios to be completed.
 * If no scenario exists, slides alone are sufficient.
 * @param slidesCompleted - Whether slides have been completed
 * @param scenarioCompleted - Whether all scenario steps have been answered
 * @param hasScenario - Whether the training has scenario content
 * @returns true if training is fully complete
 */
export function isTrainingComplete(
  slidesCompleted: boolean,
  scenarioCompleted: boolean,
  hasScenario: boolean
): boolean {
  if (!slidesCompleted) return false;
  if (hasScenario && !scenarioCompleted) return false;
  return true;
}

/**
 * Determines which phase the user should be viewing.
 * After slides are done, auto-navigate to scenario (if available).
 * @param slidesCompleted - Whether slides have been completed
 * @param hasScenario - Whether the training has scenario content
 * @returns "slides" | "scenario"
 */
export function getActivePhase(
  slidesCompleted: boolean,
  hasScenario: boolean
): "slides" | "scenario" {
  if (slidesCompleted && hasScenario) return "scenario";
  return "slides";
}
