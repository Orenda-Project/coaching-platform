Feature: Universal Scheduler — Coach Visit Planning & Management
  As a coach
  I want to plan, track, and manage school visits with smart teacher prioritization and Neo AI feedback
  So that I can efficiently improve teacher performance within my assigned region

  Background:
    Given I am logged in as a coach
    And my assigned region is "North District"
    And the scheduler dashboard is loaded

  # ── POSITIVE SCENARIOS ───────────────────────────────────────────────────────

  @chunk
  @positive
  Scenario: Smart Plan displays teachers prioritized by engagement metrics
    Given I am on the Smart Plan view
    And teachers in my region have engagement scores [95, 78, 65, 52]
    When I view the teacher list
    Then teachers are sorted by engagement score in descending order
    And the highest priority teacher is displayed first
    And all teachers belong to my assigned region "North District"

  @chunk
  @positive
  Scenario: Schedule a visit with all required fields populated
    Given I am on the Scheduler page
    And I select teacher "Ahmed Ali" from the list
    And I select school "Al-Noor School"
    And I enter date "2026-06-15"
    And I enter time "10:00 AM"
    And I enter notes "Focus on classroom management techniques"
    When I click the "Schedule Visit" button
    Then the visit is created with status "Scheduled"
    And the visit appears in the "Scheduled" tab
    And I receive a confirmation message "Visit scheduled successfully"

  @chunk
  @positive
  Scenario: Visit transitions from Draft to Scheduled after confirmation
    Given I have a visit in Draft status
    And the draft visit has all required fields filled
    When I click the "Confirm & Schedule" button
    Then the visit status changes to "Scheduled"
    And the visit is removed from the "Draft" tab
    And the visit appears in the "Scheduled" tab

  @chunk
  @positive
  Scenario: Complete a visit without Neo feedback
    Given I have a scheduled visit for "Ahmed Ali" at "Al-Noor School"
    And the visit date is today
    When I navigate to the visit details
    And I click the "Mark as Complete" button
    And I skip the "Record Feedback" option
    Then the visit status changes to "Completed"
    And the visit appears in the "Completed" tab
    And no Neo feedback record is created

  @chunk
  @positive
  Scenario: Complete visit and record Neo AI feedback
    Given I have a scheduled visit for "Fatima Khan" at "Green Valley School"
    And I am on the visit completion page
    When I click the "Record Feedback" button
    And the microphone permission is granted
    And I record audio feedback for 45 seconds
    And I click the "Stop Recording" button
    Then the audio recording is saved
    And the system displays "Processing audio..."
    And Neo converts the WebM recording to WAV format
    And the audio is uploaded to the Neo API
    And the scoring service analyzes the feedback
    And the visit is marked as "Completed"
    And the feedback score is displayed on the visit card

  @chunk
  @positive
  Scenario: Delete a visit and remove associated feedback
    Given I have a completed visit with Neo feedback
    And the visit is in the "Completed" tab
    When I click the "Delete" button on the visit
    And I confirm the deletion in the modal
    Then the visit is permanently removed
    And the associated Neo feedback record is deleted
    And the dashboard count decreases by 1
    And I see the message "Visit deleted successfully"

  @chunk
  @positive
  Scenario: Dashboard displays accurate teacher, school, date, and time information
    Given I have multiple visits scheduled
    When I view the dashboard
    Then each visit card displays:
      | Field      | Value                |
      | Teacher    | "Ahmed Ali"          |
      | School     | "Al-Noor School"     |
      | Date       | "2026-06-15"         |
      | Time       | "10:00 AM"           |
      | Status     | "Scheduled"          |
      | Notes      | Visible if provided  |

  @chunk
  @positive
  Scenario: Scheduled/Draft/Completed tabs filter visits by state
    Given I have visits in multiple states:
      | State     | Count |
      | Draft     | 3     |
      | Scheduled | 5     |
      | Completed | 7     |
    When I click the "Scheduled" tab
    Then only visits with status "Scheduled" are displayed
    And the tab shows count "5"
    When I click the "Draft" tab
    Then only visits with status "Draft" are displayed
    And the tab shows count "3"

  @chunk
  @positive
  Scenario: Region-level access control — coach sees only assigned region's data
    Given I am assigned to "North District"
    And teachers exist in "North District" and "South District"
    When I view the teacher list
    Then I can only see 8 teachers from "North District"
    And I cannot see any teachers from "South District"
    When I view scheduled visits
    Then all visits are for schools in "North District"
    And no visits from other regions are visible

  # ── NEGATIVE SCENARIOS ───────────────────────────────────────────────────────

  @chunk
  @negative
  Scenario: Schedule Visit button is disabled when required fields are missing
    Given I am on the Scheduler page
    And the teacher field is empty
    When I leave the teacher field blank
    And I enter date "2026-06-15"
    And I enter time "10:00 AM"
    Then the "Schedule Visit" button is disabled
    And the button displays a tooltip "Please select a teacher"

  @chunk
  @negative
  Scenario: Schedule Visit button is disabled when date/time is missing
    Given I am on the Scheduler page
    And I select teacher "Ahmed Ali"
    And I select school "Al-Noor School"
    And the date field is empty
    When I click the "Schedule Visit" button
    Then the button does not activate
    And I see a validation message "Please select a date and time"

  @chunk
  @negative
  Scenario: User cannot schedule a visit with a past date
    Given I am on the Scheduler page
    And today's date is "2026-06-03"
    When I enter date "2026-06-01"
    And I enter time "10:00 AM"
    And I click the "Schedule Visit" button
    Then the visit is not created
    And I see an error message "Visit date cannot be in the past"

  @chunk
  @negative
  Scenario: Recording button is disabled if microphone permission is denied
    Given I have a scheduled visit ready for completion
    And I click the "Record Feedback" button
    And I deny microphone permission in the browser
    When I attempt to click "Start Recording"
    Then the recording button is disabled
    And I see the message "Microphone permission denied. Please enable in browser settings."

  @chunk
  @negative
  Scenario: User cannot view or access visits from other regions
    Given I am assigned to "North District"
    And a visit exists for "South District"
    When I attempt to access the visit via direct URL
    Then the system denies access
    And I see the message "Access Denied — This visit is not in your assigned region"
    And I am redirected to the dashboard

  @chunk
  @negative
  Scenario: Schedule Visit fails when teacher is not in the coach's assigned region
    Given I am assigned to "North District"
    And I attempt to select a teacher from "South District"
    When I click the "Schedule Visit" button
    Then the system rejects the request
    And I see an error message "Teacher not found in your region"
    And the visit is not created

  # ── EDGE SCENARIOS ──────────────────────────────────────────────────────────

  @chunk
  @edge
  Scenario: Schedule a visit for today at the current time
    Given today's date is "2026-06-03"
    And the current time is "09:00 AM"
    When I enter date "2026-06-03"
    And I enter time "09:00 AM"
    And I click the "Schedule Visit" button
    Then the visit is created with status "Scheduled"
    And the visit appears in the "Scheduled" tab

  @chunk
  @edge
  Scenario: Record Neo feedback with maximum audio duration
    Given I am completing a visit and recording feedback
    When I record audio for exactly 600 seconds (10 minutes)
    And I click the "Stop Recording" button
    Then the recording is saved
    And Neo processes the full 10-minute audio
    And the system completes the scoring pipeline
    And the feedback is stored without truncation

  @chunk
  @edge
  Scenario: Switch between tabs while a visit state transition is in progress
    Given I have a visit transitioning from "Draft" to "Scheduled"
    When I navigate to the "Completed" tab during the transition
    And I return to the "Scheduled" tab
    Then the visit appears in the "Scheduled" tab
    And the transition completed successfully
    And no duplicate or orphaned records exist

  @chunk
  @edge
  Scenario: Delete a draft visit and verify it is immediately removed from the tab
    Given I have a draft visit
    When I click the "Delete" button
    And I confirm the deletion
    Then the visit is immediately removed from the "Draft" tab
    And the visit count decreases by 1
    And the dashboard refreshes without requiring a manual reload

  # ── ERROR SCENARIOS ──────────────────────────────────────────────────────────

  @chunk
  @error
  Scenario: Neo API timeout during audio upload
    Given I have recorded Neo feedback audio
    And the Neo API is slow to respond
    When the system attempts to upload the audio
    And the upload times out after 30 seconds
    Then the system displays an error message "Upload failed — Neo service unavailable"
    And the recording is saved locally
    And the user can retry the upload
    And the visit is not marked as complete until upload succeeds

  @chunk
  @error
  Scenario: Audio conversion from WebM to WAV fails
    Given I have recorded Neo feedback in WebM format
    When the system attempts to convert WebM to WAV
    And the conversion process encounters an error
    Then the system displays "Audio processing failed"
    And the recording is retained for retry
    And the user can attempt to re-upload or re-record

  @chunk
  @error
  Scenario: Network error prevents visit from being saved to the database
    Given I have filled all required visit fields
    And the network connection is lost
    When I click the "Schedule Visit" button
    Then the request fails
    And I see the message "Unable to save visit — check your internet connection"
    And the visit data is retained in the form for retry
    And I can resubmit once the network is restored

  @chunk
  @error
  Scenario: Server returns unauthorized error due to missing region validation
    Given I am a coach with an expired region assignment
    When I attempt to schedule a visit
    And the server performs API-level region validation
    And the region validation fails
    Then the system returns HTTP 403 Forbidden
    And I see the message "Your region assignment is invalid. Please contact an administrator."
    And the visit is not created
    And I am prompted to re-authenticate
