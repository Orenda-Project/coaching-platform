Feature: AEO Baseline Assessment
  As an Assistant Education Officer (AEO)
  I want to complete the baseline assessment
  So that I am assigned a coaching persona and my personalized training modules are unlocked

  Background:
    Given I am signed in as an AEO
    And I have completed onboarding
    And I have not yet completed the baseline assessment

  # ── POSITIVE SCENARIOS ───────────────────────────────────────────────────────

  @positive
  Scenario: View the baseline intro screen before starting
    When I navigate to "/assessment/baseline"
    Then I see the "Baseline Assessment" intro card
    And I see what the baseline is and why it matters
    And I see the estimated time to complete
    And I see the total number of questions
    And I see a notice that I can resume if interrupted
    And I see a "Start Assessment" button

  @positive
  Scenario: Start the baseline assessment from the intro screen
    Given I am on the baseline assessment intro screen
    When I click the "Start Assessment" button
    Then I am taken to the first question
    And I see a "Question 1 of N" indicator
    And I see four multiple-choice options (A, B, C, D)
    And I see a "Next" button
    And the "Previous" button is disabled

  @positive
  Scenario: Answer a question and advance to the next
    Given I am on question 1 of the baseline
    When I select option "B"
    And I click the "Next" button
    Then I am taken to question 2
    And I see a "Question 2 of N" indicator
    And my answer for question 1 is saved
    And the progress indicator updates

  @positive
  Scenario: Submit button is enabled only when all questions are answered
    Given I have answered every question except the last one
    Then I see a "Next" button rather than a "Submit" button
    When I answer the final question
    Then I see a "Submit" button
    And the "Submit" button is enabled

  @positive
  Scenario: Pass the baseline and be assigned persona A
    Given I have answered all questions with 80% correct
    When I click the "Submit" button
    Then I see a success message
    And my persona is assigned as "A"
    And my baseline score is saved as 80
    And baseline_completed is set to true
    And I am redirected to the dashboard
    And my training modules are unlocked

  @positive
  Scenario: Pass the baseline and be assigned persona B
    Given I have answered all questions with 72% correct
    When I click the "Submit" button
    Then my persona is assigned as "B"
    And my baseline score is saved as 72
    And baseline_completed is set to true
    And I am redirected to the dashboard

  @positive
  Scenario: Dashboard shows the baseline CTA before completion
    Given I have not completed the baseline assessment
    When I view the dashboard
    Then I see a "Baseline Assessment Required" card
    And I see an "Attempt Baseline Assessment" button
    When I click the button
    Then I am navigated to "/assessment/baseline"

  @positive
  Scenario: Dashboard shows the coaching profile after completion
    Given I have completed the baseline with score 72% and persona B
    When I view the dashboard
    Then I see my coaching profile card
    And I see my persona badge "B"
    And I see my baseline score "72%"
    And I see my next step guidance

  # ── NEGATIVE SCENARIOS ───────────────────────────────────────────────────────

  @negative
  Scenario: Score below 60% fails the baseline and prompts a retry
    Given I have answered all questions with 45% correct
    When I click the "Submit" button
    Then I see a message that I did not pass the baseline
    And no persona is assigned
    And baseline_completed remains false
    And I see an option to retry the baseline assessment

  @negative
  Scenario: Cannot access the baseline once it has been completed
    Given I have already completed the baseline assessment
    When I navigate to "/assessment/baseline"
    Then I am immediately redirected to the dashboard
    And I do not see the baseline questions

  @negative
  Scenario: Training modules stay locked until the baseline is completed
    Given I have not completed the baseline assessment
    When I view the dashboard
    Then all training modules are locked
    And I see lock icons on the modules

  @negative
  Scenario: Cannot submit while questions remain unanswered
    Given I have answered 15 out of 18 questions
    Then I do not see a "Submit" button
    And I see a "Next" button instead
    And the "Next" button jumps to the first unanswered question

  @negative
  Scenario: Submit button is disabled while a submission is in progress
    Given I have answered all questions
    And I am on the last question
    When I click the "Submit" button
    Then the button text changes to "Submitting..."
    And the button is disabled
    And I cannot submit again until the request completes

  # ── EDGE SCENARIOS ──────────────────────────────────────────────────────────

  @edge
  Scenario: Score of exactly 60% passes and assigns persona D
    Given I have answered exactly 60% of the questions correctly
    When I click the "Submit" button
    Then I pass the baseline
    And my persona is assigned as "D"
    And my baseline score is saved as 60

  @edge
  Scenario: Score of exactly 65% assigns persona C
    Given I have answered exactly 65% of the questions correctly
    When I click the "Submit" button
    Then my persona is assigned as "C"
    And my baseline score is saved as 65

  @edge
  Scenario: Score of exactly 70% assigns persona B
    Given I have answered exactly 70% of the questions correctly
    When I click the "Submit" button
    Then my persona is assigned as "B"
    And my baseline score is saved as 70

  @edge
  Scenario: Score of exactly 75% assigns persona A
    Given I have answered exactly 75% of the questions correctly
    When I click the "Submit" button
    Then my persona is assigned as "A"
    And my baseline score is saved as 75

  @edge
  Scenario: Score of exactly 59% fails the baseline
    Given I have answered exactly 59% of the questions correctly
    When I click the "Submit" button
    Then I do not pass the baseline
    And no persona is assigned
    And I am prompted to retry

  @edge
  Scenario: Resume the baseline from auto-saved progress
    Given I previously started the baseline and answered questions 1 through 3
    And my progress was auto-saved
    When I return to "/assessment/baseline"
    Then I see a message that I am resuming where I left off
    And I am taken to question 4
    And my previous answers for questions 1 through 3 are still selected

  # ── ERROR SCENARIOS ──────────────────────────────────────────────────────────

  @error
  Scenario: No baseline questions exist in the database
    Given the baseline assessment has no questions configured
    When I navigate to "/assessment/baseline"
    Then I see an error message "No questions found for this assessment."
    And I am redirected to the dashboard

  @error
  Scenario: Saving results fails during submission
    Given I have answered all baseline questions
    And the results update will fail
    When I click the "Submit" button
    Then I see an error message "Failed to save your results. Please try again."
    And I remain on the assessment page
    And I can retry the submission

  @error
  Scenario: Network disconnects during final submission
    Given I have answered all questions
    And the network will disconnect during submission
    When I click the "Submit" button
    Then I see an error message "An error occurred. Please try again."
    And my saved progress is preserved
    And I can retry the submission

  @error
  Scenario: Session is invalid when submitting the baseline
    Given I have answered all baseline questions
    And my session has expired
    When I click the "Submit" button
    Then the submission fails due to a missing session
    And I see an error message
    And I am prompted to sign in again
