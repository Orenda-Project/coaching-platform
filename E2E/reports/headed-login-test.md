# Headed Browser Login Test Report

**Date:** 2026-05-06T10:05:03.272Z
**Feature:** login.feature
**Environment:** https://coaching-platform-staging.up.railway.app
**Test Type:** Real Headed Browser (Playwright)
**User:** taleem@yopmail.com
**Scenarios:** 2/2 passed
**Steps:** 11/11 passed

## ✅ Successful login with valid credentials

| Step | Status | Details |
|------|--------|----------|
| Given I am on the Login page | PASS |  |
| When I enter "taleem@yopmail.com" in the Email field | PASS | taleem@yopmail.com |
| And I enter "Umar@123!@#" in the Password field | PASS | 11 characters |
| When I click the "Sign In" button | PASS |  |
| Then I am logged in successfully | PASS | https://coaching-platform-staging.up.railway.app/dashboard |
| And I am redirected to the dashboard | PASS | Welcome, taleem |

## ✅ Login page shows all required fields and controls

| Step | Status | Details |
|------|--------|----------|
| Then I can see the Email field | PASS |  |
| And I can see the Password field | PASS |  |
| And I can see the "Sign In" button | PASS |  |
| And I can see a "Forgot password?" link | PASS |  |
| And I can see a "Sign up" link | PASS |  |

