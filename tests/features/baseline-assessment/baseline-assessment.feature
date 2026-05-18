Feature: Baseline Assessment
  As a newly registered user
  I want to complete the baseline assessment
  So that I can determine my coaching persona and begin personalized training

  Background:
    Given I am logged in
    And I have completed the onboarding
    And I have not yet completed the baseline assessment

  # ── POSITIVE SCENARIOS ───────────────────────────────────────────────────────

  @chunk @positive
  Scenario: View intro screen before starting assessment
    Given I navigate to "/assessment/baseline"
    Then I see the "Baseline Assessment" intro card
    And I see "Welcome to Your Assessment" heading
    And I see "What is the baseline?" section
    And I see "Why does it matter?" section
    And I see "Time needed: ~10 minutes" estimate
    And I see the total number of questions displayed
    And I see "Pass threshold: 0%" displayed
    And I see "Can resume if interrupted" notice
    And I see a "Start Assessment" button

  @chunk @positive
  Scenario: Start baseline assessment from intro screen
    Given I am on the baseline assessment intro screen
    When I click the "Start Assessment" button
    Then I am taken to the first question
    And I see "Question 1 of N" indicator
    And I see the question text
    And I see 4 multiple choice options (A, B, C, D)
    And I see a "Next" button
    And I see a "Previous" button (disabled)
    And I see a progress bar showing 0% completion

  @chunk @positive
  Scenario: Answer a question and navigate to next question
    Given I am on question 1 of the baseline
    When I select option "B"
    And I click the "Next" button
    Then I am taken to question 2
    And I see "Question 2 of N" indicator
    And my answer for question 1 is saved in local state
    And the progress bar updates based on answered questions

  @chunk @positive
  Scenario: Next button jumps to first unanswered question
    Given I have answered questions 1, 2, and 4
    And I am on question 4
    When I click the "Next" button
    Then I am taken to question 3 (the first unanswered)
    And I see "Question 3 of N" indicator

  @chunk @positive
  Scenario: Navigate back to previous question and see saved answer
    Given I have answered questions 1 through 3
    And I am on question 3
    When I click the "Previous" button
    Then I am taken to question 2
    And my previously selected answer for question 2 is still selected
    And I can modify my answer if needed

  @chunk @positive
  Scenario: Previous button is disabled on first question
    Given I am on question 1 of the baseline
    Then the "Previous" button is disabled
    And I cannot navigate backward

  @chunk @positive
  Scenario: Progress bar and counter update as questions are answered
    Given I am on the baseline assessment
    When I answer 5 out of N total questions
    Then the progress bar shows 5/N completion percentage
    And I see "5 of N answered" below the navigation buttons

  @chunk @positive
  Scenario: Submit button appears only when all questions are answered
    Given I have answered all except 2 questions
    Then I see a "Next" button (not Submit)
    When I answer the remaining 2 questions
    And I am on the last question
    Then I see a "Submit" button (not Next)
    And the Submit button is enabled

  @chunk @positive
  Scenario: Successfully submit baseline and calculate persona A (≥75%)
    Given I have answered all questions with 80% correct
    When I click the "Submit" button
    Then I see a success toast notification
    And my persona is assigned as "A"
    And my baseline_score is saved as 80
    And baseline_completed is set to true
    And baseline_attempt_count is incremented
    And weak_modules are identified based on module scores <70%
    And I am redirected to the dashboard
    And the baseline results card shows my persona "A" and score "80%"

  @chunk @positive
  Scenario: Successfully submit baseline and calculate persona B (≥70%, <75%)
    Given I have answered all questions with 72% correct
    When I click the "Submit" button
    Then my persona is assigned as "B"
    And my baseline_score is saved as 72
    And I am redirected to the dashboard

  @chunk @positive
  Scenario: Successfully submit baseline and calculate persona C (≥65%, <70%)
    Given I have answered all questions with 67% correct
    When I click the "Submit" button
    Then my persona is assigned as "C"
    And my baseline_score is saved as 67
    And I am redirected to the dashboard

  @chunk @positive
  Scenario: Successfully submit baseline and calculate persona D (≥60%, <65%)
    Given I have answered all questions with 62% correct
    When I click the "Submit" button
    Then my persona is assigned as "D"
    And my baseline_score is saved as 62
    And I am redirected to the dashboard

  @chunk @positive
  Scenario: Successfully submit baseline and calculate persona E (<60%)
    Given I have answered all questions with 45% correct
    When I click the "Submit" button
    Then my persona is assigned as "E"
    And my baseline_score is saved as 45
    And I am redirected to the dashboard
    And persona E sees all training modules (not persona-filtered)

  @chunk @positive
  Scenario: Weak modules are identified based on per-module scores
    Given I answer Module 2 questions (order 1-6) with 50% correct
    And I answer Module 3 questions (order 7-12) with 60% correct
    And I answer Module 4 questions (order 13-18) with 90% correct
    When I submit the baseline
    Then "Module 2" is added to weak_modules (score <70%)
    And "Module 3" is added to weak_modules (score <70%)
    And "Module 4" is NOT added to weak_modules (score ≥70%)
    And my profile.weak_modules is updated

  @chunk @positive
  Scenario: Auto-save progress to localStorage every 5 seconds
    Given I have started the baseline assessment
    And I have answered 3 questions
    When 5 seconds pass
    Then my answers are saved to localStorage
    And the save includes currentIndex, answers, and timestamp
    And the localStorage key is "assessment_baseline_{user_id}"

  @chunk @positive
  Scenario: Resume baseline from saved localStorage progress
    Given I previously started the baseline and answered questions 1-3
    And my progress was auto-saved to localStorage
    And I closed the browser
    When I return to "/assessment/baseline"
    Then I see a toast "Resuming where you left off..."
    And I am taken to question 4 (next unanswered)
    And my previous answers for questions 1-3 are still selected

  @chunk @positive
  Scenario: Tab switch detection triggers first warning
    Given I have started the baseline assessment
    When I switch to another browser tab
    Then the tab switch count increments to 1
    And I see a warning toast "Warning: Switching tabs is recorded during assessment."

  @chunk @positive
  Scenario: Tab switch detection triggers second warning
    Given I have already switched tabs once
    When I switch to another browser tab again
    Then the tab switch count increments to 2
    And I see a toast "Warning: Tab switching detected (2). This is recorded."

  @chunk @positive
  Scenario: Tab switch detection flags user at 3+ switches
    Given I have already switched tabs twice
    When I switch to another browser tab a third time
    Then the tab switch count increments to 3
    And I see an error toast "Multiple tab switches detected. Please avoid switch tabs during the assessment."
    And when I submit, flagged_for_review is set to true

  @chunk @positive
  Scenario: training_progress record is created with tab switch count
    Given I completed the baseline with 2 tab switches
    When I submit the baseline
    Then a training_progress record is created for "Coach Baseline Assessment"
    And the record includes tab_switch_count = 2
    And flagged_for_review is false (since < 3)
    And passed is set to true
    And content_completed is set to true

  @chunk @positive
  Scenario: training_progress record flags user when tab switches ≥3
    Given I completed the baseline with 5 tab switches
    When I submit the baseline
    Then the training_progress record has tab_switch_count = 5
    And flagged_for_review is set to true

  @chunk @positive
  Scenario: Dashboard shows baseline CTA when not completed
    Given I have not completed the baseline assessment
    When I view the dashboard
    Then I see a "Baseline Assessment Required" card
    And I see "Complete the baseline assessment to unlock your personalized training path."
    And I see an "Attempt Baseline Assessment" button
    When I click the button
    Then I am navigated to "/assessment/baseline"

  @chunk @positive
  Scenario: Dashboard shows baseline results after completion
    Given I have completed the baseline with score 72% and persona B
    When I view the dashboard
    Then I see the "Your Coaching Profile" card
    And I see my persona badge "B"
    And I see "Based on your baseline score of 72%"
    And I see my strengths listed
    And I see my areas for growth listed
    And I see a "Next Step" section with personalized guidance

  @chunk @positive
  Scenario: Dashboard shows baseline score in stats section
    Given I have completed the baseline with score 85%
    When I view the dashboard
    Then I see the stats section
    And I see "Baseline" with value "85%"

  @chunk @positive
  Scenario: Loading state is shown while questions are fetched
    Given I navigate to "/assessment/baseline" for the first time
    Then I see a loading spinner with text "Loading assessment..."
    When the questions finish loading
    Then the spinner disappears
    And I see the intro screen

  # ── NEGATIVE SCENARIOS ───────────────────────────────────────────────────────

  @chunk @negative
  Scenario: Cannot access baseline assessment if already completed
    Given I have already completed the baseline assessment
    When I navigate to "/assessment/baseline"
    Then I am immediately redirected to "/dashboard"
    And I do not see the baseline questions

  @chunk @negative
  Scenario: Cannot submit baseline when questions are not all answered
    Given I have answered 15 out of 18 questions
    Then I do not see a "Submit" button
    And I see a "Next" button instead
    And the "Next" button jumps to the first unanswered question

  @chunk @negative
  Scenario: Submit button is disabled while submitting
    Given I have answered all questions
    And I am on the last question
    When I click the "Submit" button
    Then the button text changes to "Submitting..."
    And the button is disabled
    And I cannot click it again until submission completes

  @chunk @negative
  Scenario: Cannot navigate to training modules without completing baseline
    Given I have not completed the baseline assessment
    When I view the dashboard
    Then all training module units are locked
    And I see lock icons on units

  @chunk @negative
  Scenario: Profile update fails during submission
    Given I have answered all baseline questions
    And the database update will fail
    When I click "Submit"
    Then I see an error toast "Failed to save your results. Please try again."
    And submitting is set to false
    And I remain on the assessment page
    And I can retry submission

  @chunk @negative
  Scenario: Assessment questions are not found in database
    Given the baseline assessment has no questions in the database
    When I navigate to "/assessment/baseline"
    Then I see an error toast "No questions found for this assessment."
    And I am redirected to the dashboard

  @chunk @negative
  Scenario: Network error during final submission
    Given I have answered all questions
    And the network will disconnect during submission
    When I click "Submit"
    Then I see an error toast "An error occurred. Please try again."
    And submitting is set to false
    And my localStorage progress is still saved
    And I can retry submission

  # ── EDGE CASE SCENARIOS ──────────────────────────────────────────────────────

  @chunk @edge
  Scenario: Baseline with 0% score still completes successfully
    Given I select all incorrect answers
    When I submit the baseline
    Then my persona is assigned as "E" (< 60%)
    And my baseline_score is 0
    And baseline_completed is set to true
    And I am redirected to the dashboard
    And training modules are unlocked

  @chunk @edge
  Scenario: Baseline with exactly 60% score assigns persona D
    Given I answer exactly 60% of questions correctly
    When I submit the baseline
    Then my persona is assigned as "D"
    And my baseline_score is 60

  @chunk @edge
  Scenario: Baseline with exactly 65% score assigns persona C
    Given I answer exactly 65% of questions correctly
    When I submit the baseline
    Then my persona is assigned as "C"
    And my baseline_score is 65

  @chunk @edge
  Scenario: Baseline with exactly 70% score assigns persona B
    Given I answer exactly 70% of questions correctly
    When I submit the baseline
    Then my persona is assigned as "B"
    And my baseline_score is 70

  @chunk @edge
  Scenario: Baseline with exactly 75% score assigns persona A
    Given I answer exactly 75% of questions correctly
    When I submit the baseline
    Then my persona is assigned as "A"
    And my baseline_score is 75

  @chunk @edge
  Scenario: localStorage is cleared after successful submission
    Given I have saved progress in localStorage
    When I successfully submit the baseline
    Then the localStorage key "assessment_baseline_{user_id}" is removed
    And cached progress is cleared

  @chunk @edge
  Scenario: Corrupted localStorage data is ignored gracefully
    Given I have corrupted JSON data in localStorage for the baseline
    When I navigate to "/assessment/baseline"
    Then the corrupted data is ignored (parse error caught)
    And I start from question 1
    And no error is shown to the user

  @chunk @edge
  Scenario: Baseline attempt count increments on each submission
    Given my baseline_attempt_count is currently 2
    When I submit the baseline again
    Then baseline_attempt_count is updated to 3

  @chunk @edge
  Scenario: Navigating away from assessment preserves progress via auto-save
    Given I have answered 7 questions
    And 5 seconds have passed (auto-save triggered)
    When I navigate to "/dashboard"
    And then return to "/assessment/baseline"
    Then I resume from question 8
    And my 7 previous answers are preserved

  @chunk @edge
  Scenario: Weak modules calculation handles modules with no questions
    Given Module 5 has 0 questions in the baseline
    When I submit the baseline
    Then Module 5 is not included in weak_modules calculation
    And the score percentage for Module 5 is 0%

  # ── ERROR SCENARIOS ──────────────────────────────────────────────────────────

  @chunk @error
  Scenario: Assessment ID is not found in database
    Given the baseline assessment does not exist in the assessments table
    When I navigate to "/assessment/baseline"
    Then I see an error toast "Assessment not found. Please contact your administrator."
    And I am redirected to the dashboard

  @chunk @error
  Scenario: Certificate creation fails during endline submission
    Given I am completing the endline assessment (not baseline)
    And the certificate insert will fail
    When I submit the endline
    Then I see an error toast "Failed to issue certificate. Please try again."
    And submitting is set to false

  @chunk @error
  Scenario: User session is invalid when submitting
    Given I have answered all baseline questions
    And my user session has been invalidated
    When I click "Submit"
    Then the submission fails due to missing user context
    And I see an error toast
