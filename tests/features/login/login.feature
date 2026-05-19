Feature: User Login
  As a registered user
  I want to log in to my CoachCert account
  So that I can continue my training and track my progress

  Background:
    Given I am on the Login page

  # ── POSITIVE SCENARIOS ───────────────────────────────────────────────────────

  @chunk @positive
  Scenario: Successful login with valid credentials
    Given I enter "ali@example.com" in the Email field
    And I enter "SecurePass1" in the Password field
    When I click the "Sign In" button
    Then I am logged in successfully
    And I am redirected to the dashboard

  @chunk @positive
  Scenario: Login page shows all required fields and controls
    Then I can see the Email field
    And I can see the Password field
    And I can see the "Sign In" button
    And I can see a "Forgot password?" link
    And I can see a "Sign up" link

  @chunk @positive
  Scenario: Loading state is shown while login is processing
    Given I enter "user@test.com" in the Email field
    And I enter "Password1!" in the Password field
    When I click the "Sign In" button
    Then the button text changes to "Signing in..."
    And the button is disabled until the request completes

  @chunk @positive
  Scenario: Navigate to Sign Up page from Login page
    Then I can see a "Sign up" link
    And the link navigates me to the sign up page

  @chunk @positive
  Scenario: Successful password reset request
    Given I click the "Forgot password?" link
    And I am now on the Reset Password form
    And I enter "ali@example.com" in the Email field
    When I click the "Send Reset Link" button
    Then a reset email is sent to "ali@example.com"
    And I see a confirmation message "Check your inbox for a password reset link"

  @chunk @positive
  Scenario: Return to login form from Forgot Password mode
    Given I click the "Forgot password?" link
    And I am now on the Reset Password form
    When I click the "Back to sign in" link
    Then I am back on the main login form
    And I can see the "Sign In" button

  # ── NEGATIVE SCENARIOS ───────────────────────────────────────────────────────

  @chunk @negative
  Scenario: Submit login form with both fields empty
    Given I have not entered any data in the form
    When I click the "Sign In" button
    Then I see an error message "Please fill in all fields"
    And I am not logged in

  @chunk @negative
  Scenario: Submit login form with Email field missing
    Given I leave the Email field empty
    And I enter "Password123" in the Password field
    When I click the "Sign In" button
    Then I see an error message "Please fill in all fields"
    And I am not logged in

  @chunk @negative
  Scenario: Submit login form with Password field missing
    Given I enter "user@test.com" in the Email field
    And I leave the Password field empty
    When I click the "Sign In" button
    Then I see an error message "Please fill in all fields"
    And I am not logged in

  @chunk @negative
  Scenario: Login with correct email but wrong password
    Given I enter "ali@example.com" in the Email field
    And I enter "WrongPass1" in the Password field
    When I click the "Sign In" button
    Then I see an error message "Invalid login credentials"
    And I am not redirected away from the Login page

  @chunk @negative
  Scenario: Login with an email that does not exist
    Given I enter "ghost@nowhere.com" in the Email field
    And I enter "SomePass1!" in the Password field
    When I click the "Sign In" button
    Then I see an error message "Invalid login credentials"
    And I am not redirected away from the Login page

  @chunk @negative
  Scenario: Fields containing only whitespace are treated as empty
    Given I enter "   " in the Email field
    And I enter "   " in the Password field
    When I click the "Sign In" button
    Then I see an error message "Please fill in all fields"
    And I am not logged in

  @chunk @negative
  Scenario: Server returns a network error during login
    Given I enter "user@test.com" in the Email field
    And I enter "ValidPass1" in the Password field
    And the server is unreachable
    When I click the "Sign In" button
    Then I see an error message "Unable to connect. Please check your internet connection."
    And I am not redirected away from the Login page

  @chunk @negative
  Scenario: Submit Forgot Password form without entering an email
    Given I click the "Forgot password?" link
    And I am now on the Reset Password form
    And I leave the Email field empty
    When I click the "Send Reset Link" button
    Then I see an error message "Please enter your email address"
    And no reset email is sent

  @chunk @negative
  Scenario: Forgot Password API returns an error for unknown email
    Given I click the "Forgot password?" link
    And I am now on the Reset Password form
    And I enter "unknown@example.com" in the Email field
    When I click the "Send Reset Link" button
    Then I see an error message "Email address not found"
    And no reset email is sent
