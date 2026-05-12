Feature: User Onboarding
  As a newly registered user
  I want to complete my profile setup
  So that I can access my personalized coaching modules

  Background:
    Given I am logged in
    And I am on the Onboarding page

  # ── POSITIVE SCENARIOS ───────────────────────────────────────────────────────

  @chunk @positive
  Scenario: Complete onboarding with all fields filled
    Given I select "North" from the Region dropdown
    And I enter "Government School #1" in the School Name field
    And I enter "Ahmad Hassan, Fatima Khan" in the Teachers coached field
    When I click the "Complete Profile" button
    Then my profile is updated successfully
    And I am redirected to the dashboard

  @chunk @positive
  Scenario: Complete onboarding without optional Teachers coached field
    Given I select "Central" from the Region dropdown
    And I enter "Private Academy" in the School Name field
    And I leave the Teachers coached field empty
    When I click the "Complete Profile" button
    Then my profile is updated successfully
    And I am redirected to the dashboard

  @chunk @positive
  Scenario: All required form fields are visible on the page
    Then I can see the Region dropdown marked as required
    And I can see the School Name field marked as required
    And I can see the Teachers coached field
    And I can see the "Complete Profile" button

  @chunk @positive
  Scenario: Region dropdown shows all available options
    When I click on the Region dropdown
    Then I can see the following options:
      | North   |
      | Central |
      | South   |
      | East    |
      | West    |

  @chunk @positive
  Scenario: Loading state is shown while the request is processing
    Given I select "East" from the Region dropdown
    And I enter "Test School" in the School Name field
    When I click the "Complete Profile" button
    Then the button text changes to "Completing profile..."
    And the button is disabled until the request completes

  @chunk @positive
  Scenario: Auto-redirect to dashboard if user already has school assigned
    Given my profile already has a school assigned
    When I navigate to the Onboarding page
    Then I am automatically redirected to the dashboard
    And I do not see the Onboarding form

  # ── NEGATIVE SCENARIOS ───────────────────────────────────────────────────────

  @chunk @negative
  Scenario: Submit form without selecting Region
    Given I leave the Region dropdown empty
    And I enter "Test School" in the School Name field
    When I click the "Complete Profile" button
    Then I see an error message "Please select a region"
    And I am not redirected away from the Onboarding page

  @chunk @negative
  Scenario: Submit form without entering School Name
    Given I select "South" from the Region dropdown
    And I leave the School Name field empty
    When I click the "Complete Profile" button
    Then I see an error message "Please enter your school name"
    And I am not redirected away from the Onboarding page

  @chunk @negative
  Scenario: School Name field containing only whitespace is treated as empty
    Given I select "West" from the Region dropdown
    And I enter "   " in the School Name field
    When I click the "Complete Profile" button
    Then I see an error message "Please enter your school name"
    And I am not redirected away from the Onboarding page

  @negative
  Scenario: Server returns an error during profile update
    Given I select "North" from the Region dropdown
    And I enter "Test School" in the School Name field
    And the server is experiencing an error
    When I click the "Complete Profile" button
    Then I see an error message "Something went wrong. Please try again."
    And I am not redirected away from the Onboarding page
