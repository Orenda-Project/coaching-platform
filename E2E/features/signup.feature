Feature: User Sign Up
  As a new user
  I want to create an account on CoachCert
  So that I can start my coaching certification journey

  Background:
    Given I am on the Sign Up page

  # ── POSITIVE SCENARIOS ───────────────────────────────────────────────────────

  Scenario: Successful registration with all fields filled
    Given I enter "Ali Hassan" in the Full Name field
    And I enter "ali@example.com" in the Email field
    And I enter "+923001234567" in the Phone Number field
    And I enter "SecurePass1" in the Password field
    When I click the "Create Account" button
    Then my account is created successfully
    And I see a success message "Account created successfully!"
    And I am redirected to the onboarding page

  Scenario: Successful registration without optional Full Name
    Given I leave the Full Name field empty
    And I enter "teacher@school.edu" in the Email field
    And I enter "+923009876543" in the Phone Number field
    And I enter "Password123" in the Password field
    When I click the "Create Account" button
    Then my account is created successfully
    And I see a success message "Account created successfully!"
    And I am redirected to the onboarding page

  Scenario: All required form fields are visible on the page
    Then I can see the Full Name field
    And I can see the Email field marked as required
    And I can see the Phone Number field marked as required
    And I can see the Password field marked as required
    And I can see the "Create Account" button

  Scenario: Loading state is shown while the request is processing
    Given I enter "user@test.com" in the Email field
    And I enter "+920000000001" in the Phone Number field
    And I enter "Password1!" in the Password field
    When I click the "Create Account" button
    Then the button text changes to "Creating account..."
    And the button is disabled until the request completes

  Scenario: Navigate to Sign In page from Sign Up page
    Then I can see a "Sign in" link
    And the link navigates me to the login page

  # ── NEGATIVE SCENARIOS ───────────────────────────────────────────────────────

  Scenario: Submit form with all fields empty
    Given I have not entered any data in the form
    When I click the "Create Account" button
    Then I see an error message "Please fill in all required fields"
    And my account is not created

  Scenario: Submit form with Email field missing
    Given I leave the Email field empty
    And I enter "+923001234567" in the Phone Number field
    And I enter "Password123" in the Password field
    When I click the "Create Account" button
    Then I see an error message "Please fill in all required fields"
    And my account is not created

  Scenario: Submit form with Phone Number field missing
    Given I enter "user@test.com" in the Email field
    And I leave the Phone Number field empty
    And I enter "Password123" in the Password field
    When I click the "Create Account" button
    Then I see an error message "Please fill in all required fields"
    And my account is not created

  Scenario: Submit form with Password field missing
    Given I enter "user@test.com" in the Email field
    And I enter "+923001234567" in the Phone Number field
    And I leave the Password field empty
    When I click the "Create Account" button
    Then I see an error message "Please fill in all required fields"
    And my account is not created

  Scenario: Password is shorter than 8 characters
    Given I enter "user@test.com" in the Email field
    And I enter "+923001234567" in the Phone Number field
    And I enter "abc12" in the Password field
    When I click the "Create Account" button
    Then I see an error message "Password must be at least 8 characters"
    And my account is not created

  Scenario: Password is exactly 7 characters — boundary below minimum
    Given I enter "user@test.com" in the Email field
    And I enter "+923001234567" in the Phone Number field
    And I enter "abc1234" in the Password field
    When I click the "Create Account" button
    Then I see an error message "Password must be at least 8 characters"
    And my account is not created

  Scenario: Register with an email that already exists
    Given I enter "existing@example.com" in the Email field
    And I enter "+923001234567" in the Phone Number field
    And I enter "ValidPass1" in the Password field
    And the email "existing@example.com" is already registered
    When I click the "Create Account" button
    Then I see an error message "User already registered"
    And I am not redirected away from the Sign Up page

  Scenario: Server returns an unexpected error during registration
    Given I enter "user@test.com" in the Email field
    And I enter "+923001234567" in the Phone Number field
    And I enter "ValidPass1" in the Password field
    And the server is experiencing an error
    When I click the "Create Account" button
    Then I see an error message "Something went wrong. Please try again."
    And I am not redirected away from the Sign Up page

  Scenario: Fields containing only whitespace are treated as empty
    Given I enter "   " in the Email field
    And I enter "   " in the Phone Number field
    And I enter "   " in the Password field
    When I click the "Create Account" button
    Then I see an error message "Please fill in all required fields"
    And my account is not created
