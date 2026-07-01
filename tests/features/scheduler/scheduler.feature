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

  # ══════════════════════════════════════════════════════════════════════════════
  # ADDED — scenarios written to match the ACTUAL implementation (2026-07-01)
  # Verified against: src/lib/scheduler-utils.ts, src/components/observation/*,
  # src/data/observations.ts, src/types/observation.ts. In this codebase a visit is a
  # cot_observations row; statuses are Scheduled | Draft | Submitted | Approved
  # (the "Completed" tab = Submitted + Approved). Neo scoring runs in the debrief
  # flow, decoupled from marking a visit done.
  # ══════════════════════════════════════════════════════════════════════════════

  # ── PRIORITIZATION (scheduler-utils.ts) ───────────────────────────────────────

  @chunk
  @positive
  Scenario: Never-observed teachers are ranked as top priority
    Given a teacher "Zainab Bibi" has never been observed
    And a teacher "Ahmed Ali" has an observation score of 82%
    When the roster is ranked by urgency
    Then "Zainab Bibi" is assigned the CRITICAL tier
    And "Zainab Bibi" is given an urgency value of 9999
    And "Zainab Bibi" appears above "Ahmed Ali" in the ranked list

  @chunk
  @positive
  Scenario Outline: Priority tier and visit interval are derived from the latest score
    Given a teacher has a latest score of <score>%
    And the teacher has been observed before
    When the priority tier is assigned
    Then the tier is "<tier>"
    And the recommended visit interval is <interval> days

    Examples:
      | score | tier     | interval |
      | 30    | CRITICAL | 7        |
      | 55    | HIGH     | 14       |
      | 70    | MEDIUM   | 21       |
      | 90    | LOW      | 30       |

  @chunk
  @positive
  Scenario: A falling score trend increases a teacher's urgency
    Given a teacher has three observations scored 80%, then 72%, then 63%
    When the score trend is calculated
    Then the trend is "falling"
    And the urgency for that teacher is increased by 10

  @chunk
  @edge
  Scenario: A single dip across three observations is treated as flat, not falling
    Given a teacher has three observations scored 80%, then 70%, then 78%
    When the score trend is calculated
    Then the trend is "flat"
    And no falling-trend urgency bonus is applied

  # ── WEEKLY PLAN GENERATION (scheduler-utils.ts) ───────────────────────────────

  @chunk
  @positive
  Scenario: Weekly schedule fills at most 10 slots across Monday to Friday
    Given a ranked roster of 14 teachers
    When the weekly schedule is generated with 2 visits per day over 5 working days
    Then exactly 10 visits are scheduled
    And no day is assigned more than 2 visits
    And no visit is placed on Saturday or Sunday
    And the remaining 4 teachers are returned as overflow

  @chunk
  @positive
  Scenario: Visits are clustered by school to reduce travel
    Given the ranked roster contains multiple teachers at "Al-Noor School"
    When the weekly schedule is generated
    Then teachers at "Al-Noor School" are scheduled together before moving to another school

  @chunk
  @edge
  Scenario: The four-week plan rolls overflow forward into later weeks
    Given a ranked roster larger than 10 teachers
    When the four-week plan is generated
    Then week 1 schedules the highest-urgency teachers first
    And teachers not scheduled in week 1 are carried into subsequent weeks

  # ── MULTI-REGION ROUTING (ObservationScheduler.tsx) ───────────────────────────

  @chunk
  @positive
  Scenario Outline: The scheduler renders the tab matching the coach's assigned region
    Given I am logged in as a coach assigned to "<assignment>"
    When I open the Observation Scheduler
    Then the "<tab>" smart-schedule view is displayed

    Examples:
      | assignment       | tab             |
      | ICT sub-region   | ICT Smart Plan  |
      | Punjab cluster   | Punjab Smart Plan |
      | Rawalpindi cluster | Rawalpindi Smart Plan |

  @chunk
  @negative
  Scenario: ICT coach without a sub-region cannot use the smart schedule
    Given I am an ICT coach with no sub-region assigned
    When I open the ICT smart-schedule view
    Then I see the message "No region assigned"
    And I am advised to contact admin

  # ── VISIT STATE TRANSITIONS (VisitsDashboardTab.tsx) ──────────────────────────

  @chunk
  @positive
  Scenario: Marking a scheduled visit done moves it to the Completed tab as Submitted
    Given I have a scheduled visit for "Ahmed Ali"
    When I click the "Done" action on the visit
    Then the visit status becomes "Submitted"
    And the visit appears in the "Completed" tab
    And I see the message "Visit marked complete"

  @chunk
  @positive
  Scenario: Saving a scheduled visit as draft moves it to the Draft tab
    Given I have a scheduled visit for "Ahmed Ali"
    When I click the "Draft" action on the visit
    Then the visit status becomes "Draft"
    And the visit appears in the "Draft" tab
    And I see the message "Visit saved to draft"

  @chunk
  @positive
  Scenario: Deleting a visit requires confirmation before removal
    Given I have a scheduled visit
    When I click the "Delete" action
    Then a confirmation dialog "Delete this visit?" is shown
    And the visit is only removed after I confirm
    And I see the message "Visit deleted"

  @chunk
  @edge
  Scenario: A draft visit with saved audio shows an "Audio saved" badge
    Given I have a draft visit with locally saved debrief audio
    When I view the draft visit card
    Then an "Audio saved" badge is displayed on the card

  # ── NEO DEBRIEF IS DECOUPLED FROM COMPLETION (VisitsDashboardTab.tsx) ─────────

  @chunk
  @positive
  Scenario Outline: The debrief button label reflects the Neo analysis status
    Given a visit has a Neo status of "<neo_status>"
    When I view the visit card
    Then the debrief button shows "<label>"

    Examples:
      | neo_status | label      |
      | none       | Debrief    |
      | processing | Analyzing… |
      | completed  | Debriefed  |

  @chunk
  @negative
  Scenario: The Done action is disabled while Neo analysis is processing
    Given a visit has a Neo status of "processing"
    When I view the visit card
    Then the "Done" action is disabled
    And the "Debrief" action is disabled

  # ── NOTIFY TEACHER (VisitsDashboardTab.tsx) ───────────────────────────────────

  @chunk
  @positive
  Scenario: Notify opens WhatsApp with a pre-filled visit message
    Given I have a scheduled visit for "Ahmed Ali" at "Al-Noor School"
    When I click the "Notify" action
    Then a WhatsApp share link opens in a new tab
    And the message includes the teacher name, school, visit date, and arrival time

  # ── OFFLINE SUPPORT (punjabOfflineQueue.ts / rawalpindiOfflineQueue.ts) ───────

  @chunk
  @edge
  Scenario: Scheduling a Punjab visit while offline queues it locally
    Given I am a Punjab coach and my device is offline
    When I schedule a visit
    Then the visit is stored in the local offline queue
    And a pseudo visit is shown in the dashboard immediately
    And I see a message that the visit will sync when back online

  @chunk
  @positive
  Scenario: Queued offline visits sync automatically when the connection returns
    Given I have visits stored in the Punjab offline queue
    When the device reconnects to the internet
    Then the queued visits are uploaded to the backend
    And each successfully uploaded visit is removed from the queue
    And the teacher list is refreshed

  @chunk
  @error
  Scenario: Scheduling an ICT visit with no connection shows a reconnect prompt
    Given I am an ICT coach and the network request fails to fetch
    When I click the "Schedule Visit" button
    Then I see the message "No connection — reconnect and try again"
    And the visit is not added to any offline queue

  # ── DATA-LAYER CONTRACT (observations.ts) ─────────────────────────────────────

  @chunk
  @positive
  Scenario: A scheduled visit is created via the coaching observations API
    Given I confirm a valid visit for "Ahmed Ali"
    When the visit is submitted
    Then a POST request is sent to "/api/coaching/observations"
    And the payload status is "Scheduled"
    And the payload region is set to the coach's active region

  @chunk
  @positive
  Scenario: Observations are listed for the current observer and region
    Given I am viewing the Visits dashboard
    When the observations are loaded
    Then a GET request is sent to "/api/coaching/observations" with my observer id
    And only observations belonging to my observer id are returned
