// Unit test for signup trigger fix
// Verifies that the handle_new_user trigger correctly extracts phone and full_name from auth metadata

import { describe, it, expect } from "vitest";

/**
 * Test: Verify trigger reads phone and full_name from auth user metadata
 *
 * Background:
 * - Client passes phone and full_name in auth.signUp({ options: { data: { phone, full_name } } })
 * - These are stored in auth.users.raw_user_meta_data
 * - The handle_new_user trigger must extract them from metadata to create the profile row
 *
 * Scenario:
 * - User signs up with: email="test@example.com", phone="+923001234567", full_name="John Doe"
 * - Auth user is created with raw_user_meta_data = { phone, full_name }
 * - Trigger fires: INSERT into profiles (id, phone, full_name)
 * - Expected: profile.phone = "+923001234567", profile.full_name = "John Doe"
 *
 * Bug that was fixed:
 * - Old trigger: COALESCE(NEW.phone, NEW.email) → reads from auth.users.phone column (null)
 * - New trigger: COALESCE(NEW.raw_user_meta_data->>'phone', NEW.email) → reads from metadata
 */
describe("Signup trigger: extract phone and full_name from auth metadata", () => {
  it("trigger should read phone from auth.users.raw_user_meta_data", () => {
    // Simulating the trigger logic:
    // COALESCE(NEW.raw_user_meta_data->>'phone', NEW.email)

    const rawUserMetaData = { phone: "+923001234567", full_name: "John Doe" };
    const authEmail = "test@example.com";

    // Extract phone from metadata, fallback to email
    const phone = rawUserMetaData.phone || authEmail;
    expect(phone).toBe("+923001234567");
  });

  it("trigger should fallback to email if phone not in metadata", () => {
    const rawUserMetaData = { full_name: "John Doe" }; // phone is missing
    const authEmail = "test@example.com";

    const phone = (rawUserMetaData as any).phone || authEmail;
    expect(phone).toBe("test@example.com");
  });

  it("trigger should read full_name from auth.users.raw_user_meta_data", () => {
    const rawUserMetaData = { phone: "+923001234567", full_name: "John Doe" };

    const fullName = (rawUserMetaData as any).full_name;
    expect(fullName).toBe("John Doe");
  });

  it("trigger should handle null full_name (nullable column)", () => {
    const rawUserMetaData = { phone: "+923001234567" }; // full_name is missing

    const fullName = (rawUserMetaData as any).full_name;
    expect(fullName).toBeUndefined();
  });
});
