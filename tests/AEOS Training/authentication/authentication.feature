Feature: AEO Authentication
  As an Assistant Education Officer (AEO)
  I want to securely sign in to my coaching training account
  So that I can access my personalized training path and track my certification progress

  Background:
    Given I am on the Login page

  # ── POSITIVE SCENARIOS ───────────────────────────────────────────────────────

  @positive
  Scenario: Successful sign in with valid AEO credentials
    Given I enter "aeo.aisha@taleemabad.com" in the Email field
    And I enter "SecurePass1" in the Password field
    When I click the "Sign In" button
    Then I am logged in successfully
    And I am redirected to the dashboard

  @positive
  Scenario: Login page shows all required fields and controls
    Then I can see the Email field
    And I can see the Password field
    And I can see the "Sign In" button
    And I can see a "Forgot password?" link
    And I can see a "Sign up" link

  @positive
  Scenario: Loading state is shown while sign in is processing
    Given I enter "aeo.aisha@taleemabad.com" in the Email field
    And I enter "SecurePass1" in the Password field
    When I click the "Sign In" button
    Then the button text changes to "Signing in..."
    And the button is disabled until the request completes

  @positive
  Scenario: Navigate to Sign Up page from Login page
    Then I can see a "Sign up" link
    And the link navigates me to the sign up page

  @positive
  Scenario: New AEO signs up with a valid, unused email
    Given I navigate to the sign up page
    And I enter "aeo.bilal@taleemabad.com" in the Email field
    And I enter "StrongPass1" in the Password field
    When I click the "Sign Up" button
    Then my AEO account is created
    And I am taken into the onboarding flow

  @positive
  Scenario: Authenticated AEO session persists across a page reload
    Given I have signed in as "aeo.aisha@taleemabad.com"
    And I am on the dashboard
    When I reload the page
    Then I remain signed in
    And I am still on the dashboard

  @positive
  Scenario: Request a password reset link successfully
    Given I click the "Forgot password?" link
    And I am now on the Reset Password form
    And I enter "aeo.aisha@taleemabad.com" in the Email field
    When I click the "Send Reset Link" button
    Then a reset email is sent to "aeo.aisha@taleemabad.com"
    And I see a confirmation message "Check your inbox for a password reset link"

  @positive
  Scenario: Return to login form from Forgot Password mode
    Given I click the "Forgot password?" link
    And I am now on the Reset Password form
    When I click the "Back to sign in" link
    Then I am back on the main login form
    And I can see the "Sign In" button

  # ── NEGATIVE SCENARIOS ───────────────────────────────────────────────────────

  @negative
  Scenario: Submit sign in form with both fields empty
    Given I have not entered any data in the form
    When I click the "Sign In" button
    Then I see an error message "Please fill in all fields"
    And I am not logged in

  @negative
  Scenario: Submit sign in form with Email field missing
    Given I leave the Email field empty
    And I enter "SecurePass1" in the Password field
    When I click the "Sign In" button
    Then I see an error message "Please fill in all fields"
    And I am not logged in

  @negative
  Scenario: Submit sign in form with Password field missing
    Given I enter "aeo.aisha@taleemabad.com" in the Email field
    And I leave the Password field empty
    When I click the "Sign In" button
    Then I see an error message "Please fill in all fields"
    And I am not logged in

  @negative
  Scenario: Sign in with correct email but wrong password
    Given I enter "aeo.aisha@taleemabad.com" in the Email field
    And I enter "WrongPass1" in the Password field
    When I click the "Sign In" button
    Then I see an error message "Invalid login credentials"
    And I am not redirected away from the Login page

  @negative
  Scenario: Sign in with an email that is not registered
    Given I enter "ghost.officer@nowhere.com" in the Email field
    And I enter "SomePass1!" in the Password field
    When I click the "Sign In" button
    Then I see an error message "Invalid login credentials"
    And I am not redirected away from the Login page

  @negative
  Scenario: Sign up with an email that already has an account
    Given I navigate to the sign up page
    And I enter "aeo.aisha@taleemabad.com" in the Email field
    And I enter "AnotherPass1" in the Password field
    When I click the "Sign Up" button
    Then I see an error message "An account with this email already exists"
    And no new account is created

  @negative
  Scenario: Submit Forgot Password form without entering an email
    Given I click the "Forgot password?" link
    And I am now on the Reset Password form
    And I leave the Email field empty
    When I click the "Send Reset Link" button
    Then I see an error message "Please enter your email address"
    And no reset email is sent

  # ── EDGE SCENARIOS ──────────────────────────────────────────────────────────

  @edge
  Scenario: Fields containing only whitespace are treated as empty
    Given I enter "   " in the Email field
    And I enter "   " in the Password field
    When I click the "Sign In" button
    Then I see an error message "Please fill in all fields"
    And I am not logged in

  @edge
  Scenario: Email with surrounding whitespace is trimmed before sign in
    Given I enter "  aeo.aisha@taleemabad.com  " in the Email field
    And I enter "SecurePass1" in the Password field
    When I click the "Sign In" button
    Then the email is trimmed to "aeo.aisha@taleemabad.com"
    And I am logged in successfully

  @edge
  Scenario: Double-clicking Sign In does not submit twice
    Given I enter "aeo.aisha@taleemabad.com" in the Email field
    And I enter "SecurePass1" in the Password field
    When I click the "Sign In" button twice in quick succession
    Then only one sign in request is sent
    And I am logged in successfully

  @edge
  Scenario: Already-authenticated AEO visiting the Login page is redirected
    Given I am already signed in as "aeo.aisha@taleemabad.com"
    When I navigate to the Login page
    Then I am redirected to the dashboard
    And I do not see the sign in form

  # ── ERROR SCENARIOS ──────────────────────────────────────────────────────────

  @error
  Scenario: Server is unreachable during sign in
    Given I enter "aeo.aisha@taleemabad.com" in the Email field
    And I enter "SecurePass1" in the Password field
    And the server is unreachable
    When I click the "Sign In" button
    Then I see an error message "Unable to connect. Please check your internet connection."
    And I am not redirected away from the Login page

  @error
  Scenario: Authentication service returns an unexpected error
    Given I enter "aeo.aisha@taleemabad.com" in the Email field
    And I enter "SecurePass1" in the Password field
    And the authentication service returns a 500 error
    When I click the "Sign In" button
    Then I see an error message "Something went wrong. Please try again."
    And I am not logged in

  @error
  Scenario: Password reset request fails due to a service error
    Given I click the "Forgot password?" link
    And I am now on the Reset Password form
    And I enter "aeo.aisha@taleemabad.com" in the Email field
    And the reset service is unavailable
    When I click the "Send Reset Link" button
    Then I see an error message "Unable to send reset link. Please try again later."
    And no confirmation message is shown
