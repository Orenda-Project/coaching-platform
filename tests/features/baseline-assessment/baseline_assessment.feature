Feature: Baseline Assessment (18 MCQ)
  As a newly registered user
  I want to complete the baseline assessment
  So that I can begin my coaching certification training

  Background:
    Given I am logged in
    And I have completed the onboarding
    And I am on the Baseline Assessment page

  # ── POSITIVE SCENARIOS ───────────────────────────────────────────────────────

  @chunk @positive
  Scenario: Successfully view all 18 baseline questions 
    Then I can see the Baseline Assessment heading
    And I can see "Question 1 of 18" at the top
    And I can see the first baseline question about SCARF model
    And I can see 4 multiple choice options (A, B, C, D)
    And I can see the "Next" button
    And I can see a progress bar showing 0% completion

  @@chunk positive
  Scenario: Navigate through all 18 questions sequentially
    When I select option "B" for question 1
    And I click the "Next" button
    Then I see "Question 2 of 18" at the top
    And the previous answer is saved
    And I can see the second baseline question
    And the progress bar updates to show 5% completion

  @chunk @positive
  Scenario: Go back to previous question and view previous answer (read-only before submission)
    Given I have answered questions 1 through 3
    When I click the "Previous" button
    Then I see "Question 2 of 18" at the top
    And my previous answer for question 2 is still selected
    And I can proceed forward to question 3 again

  @chubk @positive
  Scenario: Successfully submit baseline with all 18 questions answered (all correct)
    Given I answer all 18 questions correctly
    When I click the "Submit" button on question 18
    Then I see a success message "Baseline assessment submitted successfully!"
    And I can see my score "100% (18/18)"
    And I am redirected to the training dashboard
    And Module 1 is now unlocked

 @chunk  @positive
  Scenario: Successfully submit baseline with all 18 questions answered (mixed correct/incorrect)
    Given I answer 16 questions correctly and 2 questions incorrectly
    When I click the "Submit" button on question 18
    Then I see a success message "Baseline assessment submitted successfully!"
    And I can see my score "88.9% (16/18)"
    And I am redirected to the training dashboard
    And Module 1 is now unlocked

  @chunl @positive
  Scenario: Successfully submit baseline with all 18 questions answered (all incorrect)
    Given I select all incorrect answers for all 18 questions
    When I click the "Submit" button on question 18
    Then I see a success message "Baseline assessment submitted successfully!"
    And I can see my score "0% (0/18)"
    And I am redirected to the training dashboard
    And Module 1 is now unlocked (regardless of score)

  @chunk @positive
  Scenario: Baseline assessment form shows all required fields
    Then I can see the Baseline Assessment heading
    And I can see the question text
    And I can see 4 radio buttons (options A, B, C, D)
    And I can see the "Next" button
    And I can see the "Previous" button (disabled on question 1)
    And I can see the progress bar
    And I can see "Question X of 18" indicator

  @chunk @positive
  Scenario: Loading state is shown while questions are loading
    When I first navigate to the Baseline Assessment
    Then I see a loading spinner
    And the heading shows "Loading assessment..."
    And after questions load, the spinner disappears
    And I can see the first baseline question

  @chunk @positive
  Scenario: Loading state is shown while answer is being saved
    Given I am on any baseline question
    When I click the "Next" button
    Then the button text temporarily changes to "Saving..."
    And the button is disabled until the save completes
    And then I proceed to the next question

  @chunk @positive
  Scenario: Display timer showing estimated time (15-20 minutes)
    Then I can see a timer showing estimated time to complete
    And the timer is visible at the top of the page
    And it provides a helpful reference for completion

  @positive
  Scenario: Save and return later to resume baseline
    Given I am on question 5 of 18
    When I close the browser or navigate away
    Then my answers for questions 1-5 are automatically saved
    And when I return to the baseline later
    And I click "Resume Baseline Assessment" on the dashboard
    Then I am taken to question 6
    And my previous answers (1-5) are preserved
    And I can continue from where I left off

  @positive
  Scenario: Dashboard shows baseline as completed after submission
    Given I have submitted all 18 baseline answers
    When I view the dashboard
    Then I can see "Baseline Assessment" marked as "Completed ✓"
    And I can see my final score (e.g., "88.9% (16/18)")
    And Module 1 is now unlocked and available for training
    And all other modules are available for training

  @positive
  Scenario: All 18 questions are from the coaching modules curriculum
    When I navigate through all baseline questions
    Then I see questions about SCARF model (Partnership)
    And I see questions about Data at the Edge (Mirror Specialist)
    And I see questions about WRER and Heatmap (Analytics)
    And I see questions about Training Loops (Catalyst)
    And I see questions about Praxis and Reciprocity (Excellence)

  # ── NEGATIVE SCENARIOS ───────────────────────────────────────────────────────

  @negative
  Scenario: Cannot proceed to next question without selecting an answer
    Given I am on question 1
    When I click the "Next" button without selecting any option
    Then I see an error message "Please select an answer before proceeding"
    And I am not taken to the next question

  @negative
  Scenario: Cannot submit baseline if any questions remain unanswered
    Given I have answered only 16 out of 18 questions
    And I leave questions 5 and 12 unanswered
    When I click the "Submit" button on question 18
    Then I see an error message "Please answer all 18 questions before submitting"
    And I can see which questions are incomplete (e.g., "Questions 5, 12 require answers")
    And I can click to jump to those questions

  @negative
  Scenario: Cannot change or correct answer after submission
    Given I have submitted all 18 baseline answers
    When I try to navigate back to question 5
    Then I see a message "Baseline assessment has been submitted. Answers cannot be modified."
    And the baseline assessment is locked for editing
    And I am redirected to the dashboard

  @negative
  Scenario: Submitted baseline shows in read-only mode if user navigates back
    Given I have submitted the baseline assessment
    When I click on "View Baseline Assessment" from the dashboard
    Then the questions are displayed in read-only mode
    And my submitted answers are shown but cannot be changed
    And there is no "Next" or "Previous" button for navigation
    And I can see my final score

  @negative
  Scenario: Cannot access baseline if already completed and submitted
    Given I have submitted the baseline assessment
    When I try to navigate directly to the baseline assessment page
    Then I am automatically redirected to the training dashboard
    And I see a message "You have already completed the baseline assessment"

  @negative
  Scenario: Cannot access training modules without completing baseline first
    Given I have not yet submitted the baseline assessment
    When I navigate to the training section
    Then I see a message "Complete the baseline assessment to start training"
    And all training modules are locked
    And I see a "Go to Baseline Assessment" button

  @negative
  Scenario: Server returns an error while saving answer
    Given I am on question 5
    And the server is experiencing an error
    When I click the "Next" button
    Then I see an error message "Unable to save your answer. Please try again."
    And I am not taken to the next question
    And my answer is not lost

  @negative
  Scenario: Connection is lost during baseline assessment
    Given I am on question 7
    And the internet connection is lost
    When I try to click "Next"
    Then I see an error message "No internet connection. Please check your network."
    And I can click "Retry" to continue when connection is restored

  @negative
  Scenario: Session timeout during baseline assessment
    Given I have been on the baseline page for an extended period without submitting
    When the session times out
    Then I see a message "Your session has expired. Your progress has been saved."
    And I am redirected to login
    And I can resume the baseline later with my answers preserved

  @negative
  Scenario: Cannot submit baseline with network error mid-submission
    Given I am on question 18 (last question)
    And I have answered all 18 questions
    When the network disconnects as I click "Submit"
    Then I see an error "Could not submit baseline. Please try again."
    And my answers are still saved
    And I can click "Submit" again to complete

  @negative
  Scenario: Back button on first question is disabled
    Given I am on question 1 of 18
    When I look at the "Previous" button
    Then the button appears disabled/grayed out
    And I cannot click it to go backward

  @negative
  Scenario: Whitespace-only selection is treated as no selection
    Given I am on a baseline question
    When I accidentally select only whitespace/blank option
    Then it is treated as no answer selected
    And I cannot proceed to the next question without selecting a valid option

  # ── EDGE CASE SCENARIOS ──────────────────────────────────────────────────────

  @negative
  Scenario: User identity changes between page loads during baseline
    Given I am on question 5 of the baseline
    When another user logs in on the same device
    Then the previous user's session is terminated
    And when the previous user logs back in, they can resume from question 6
    And the new user must start from question 1

  @negative
  Scenario: Rapid clicking of Next button doesn't create duplicate submissions
    Given I am on question 2
    When I rapidly click the "Next" button multiple times
    Then only one navigation to question 3 occurs
    And no duplicate answers are recorded

  @negative
  Scenario: Baseline questions are always shown in the same order (1-18)
    Given I submit the baseline assessment once
    When I view the submitted baseline in read-only mode
    Then the questions are displayed in the same consistent order (Q1, Q2, ..., Q18)

  @negative
  Scenario: After submission, viewing dashboard shows baseline status immediately
    Given I just submitted the baseline
    When I view the dashboard page
    Then the baseline status is shown as "Completed ✓"
    And my score is displayed (e.g., "88.9% (16/18)")
    And Module 1 is unlocked for training

  @negative
  Scenario: Cannot re-submit baseline once already submitted
    Given I have already submitted the baseline assessment
    When I try to navigate to "Submit Baseline" again
    Then I am redirected to the training dashboard
    And I see "Baseline assessment already completed"

