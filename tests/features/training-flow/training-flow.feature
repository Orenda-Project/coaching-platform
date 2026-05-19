Feature: Training Flow
  As a learner
  I want to progress through training content in a structured way
  So that I can complete all required phases before certification

  Background:
    Given I am logged in as a learner
    And I am viewing a training module with slides and practice scenarios
    And the slides are not yet completed
    And the practice scenarios are not yet completed

  # ── POSITIVE SCENARIOS ───────────────────────────────────────────────────────

  @chunk @positive
  Scenario: User views all slides and completes training without scenarios
    Given the training module has only slides, no practice scenarios
    When I view all slides in the training
    And I mark all slides as viewed
    Then the training is marked as complete
    And I can proceed to the next module

  @chunk @positive
  Scenario: User completes slides, auto-navigates to practice, and completes scenario
    Given the training module has slides followed by a practice scenario
    When I view and complete all training slides
    Then I am automatically navigated to the practice scenario section
    And the practice section is now accessible
    When I complete the practice scenario
    Then the entire training is marked as complete

  @chunk @positive
  Scenario: User views slides, completes scenarios, and returns to slides
    When I view and complete all training slides
    And I navigate to the practice scenario section
    And I choose to return to the slides to review content
    Then I can view the slides again
    And my slide completion status is preserved

  @chunk @positive
  Scenario: User completes training with multiple practice scenarios in sequence
    Given the training has three practice scenarios to complete
    When I complete all training slides
    And I complete the first practice scenario
    And I proceed to the second practice scenario
    And I complete the second practice scenario
    And I proceed to the third practice scenario
    And I complete the third practice scenario
    Then the training is fully marked as complete

  @chunk @positive
  Scenario: User completes training and progress persists on return
    When I view and complete all training slides
    And I complete the practice scenario
    And I close the browser and return later
    Then my slide completion status is retained
    And my practice completion status is retained
    And the training remains marked as complete

  # ── NEGATIVE SCENARIOS ───────────────────────────────────────────────────────

  @chunk @negative
  Scenario: User cannot access practice section before completing slides
    When I attempt to navigate directly to the practice section without completing slides
    Then I am prevented from accessing the practice section
    And I see a message "Please complete all training slides before attempting the practice section."

  @chunk @negative
  Scenario: User sees locked practice section when slides are incomplete
    Given I have viewed only half of the training slides
    When I look for the practice section
    Then the practice section is displayed as locked
    And I cannot click to enter the practice section

  @chunk @negative
  Scenario: User cannot mark training complete with only slides done when scenarios exist
    Given the training has required practice scenarios
    When I complete all training slides
    And I do not complete any practice scenarios
    Then the training is not marked as complete
    And the module cannot be submitted for progression

  @chunk @negative
  Scenario: User navigates away from training and returns to incomplete scenario
    When I complete all training slides
    And I start but do not complete the practice scenario
    And I navigate away from the training
    And I return to the training module
    Then I am at the practice scenario section
    And my partial progress in the scenario is preserved

  @chunk @negative
  Scenario: User cannot access subsequent modules if training is incomplete
    Given this is a module that must be completed before the next module
    When I only complete the training slides but not the practice scenarios
    Then the next module remains locked
    And I see a message indicating the current module must be fully completed

  @chunk @negative
  Scenario: Training state degrades if user attempts to access practice after logout
    Given I completed all training slides
    And I was navigated to the practice section
    When my session expires or I log out
    And I log back in and return to the training
    Then I am still in the practice section
    And my slides are still marked as complete

  # ── EDGE SCENARIOS ──────────────────────────────────────────────────────────

  @chunk @positive
  Scenario: User completes training with only slides and no scenarios
    Given a training module exists with only slides and zero scenarios
    When I complete viewing all the slides
    Then the training is immediately marked as complete
    And I can proceed to the next module

  @chunk @positive
  Scenario: User rapidly navigates between slides and practice section
    When I quickly switch between viewing slides and attempting to access practice
    And I complete slides during this switching
    Then the practice section becomes accessible after slide completion
    And the rapid navigation does not cause state corruption

  @chunk @positive
  Scenario: User completes scenarios in different order than presented
    Given the practice has multiple independent scenarios
    When I complete the scenarios in a different order than the UI sequence
    Then all completed scenarios are recorded as done
    And the training completion accounts for all scenarios regardless of order

  @chunk @positive
  Scenario: User revisits completed training to review content
    Given I have already completed the training with all slides and scenarios done
    When I return to view the training again
    Then I can view all slides without restriction
    And I can revisit any completed scenario
    And the original completion dates are preserved

  # ── ERROR SCENARIOS ────────────────────────────────────────────────────────────

  @chunk @negative
  Scenario: Server fails to save slide completion status
    When I complete viewing all slides
    And the server fails to save the completion status
    Then I see an error message "Unable to save your progress. Please try again."
    And the training remains in an incomplete state
    And I can retry the action

  @chunk @negative
  Scenario: Practice section unlocks inconsistently due to sync delay
    Given I completed all slides
    And the auto-navigation to practice has not yet processed
    When I manually refresh the page before auto-navigation completes
    Then the practice section is either locked or accessible based on server state
    And subsequent actions work with the correct server state

  @chunk @negative
  Scenario: User encounters missing scenario content that should exist
    Given the training is configured to have practice scenarios
    When I complete all slides and navigate to practice
    But the scenario content fails to load
    Then I see an error message "Practice content is unavailable. Please contact support."
    And the training can be retried later

  @chunk @negative
  Scenario: Training state becomes inconsistent if client and server disagree
    Given the server marks training as complete
    When the client still shows incomplete status
    And I refresh the page
    Then the page displays the authoritative server state
    And the training shows as complete
