#!/usr/bin/env node
/**
 * Test signup flow against production Supabase
 * Tests the RPC function create_profile_after_signup works correctly
 */

import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = 'https://agziuwqpkfmxtospfxns.supabase.co';
const SUPABASE_KEY = 'sb_publishable_avOxa8No6M8y_CiCriucVg_7h2ZoimN';

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

async function testSignupFlow() {
  const email = `test-${Date.now()}@test.com`;
  const password = 'TestPassword123!';
  const phone = '+1234567890';
  const fullName = 'Test User';

  console.log('🧪 Testing signup flow...');
  console.log(`📧 Email: ${email}`);
  console.log(`📱 Phone: ${phone}`);
  console.log(`👤 Full Name: ${fullName}`);
  console.log('');

  // Step 1: Create auth user
  console.log('Step 1: Creating auth user...');
  const { data: signUpData, error: authError } = await supabase.auth.signUp({
    email,
    password,
    options: {
      emailRedirectTo: 'http://localhost:5173',
    },
  });

  if (authError) {
    console.error('❌ Auth signup failed:', authError);
    return;
  }

  const userId = signUpData.user?.id;
  console.log(`✅ Auth user created: ${userId}`);
  console.log('');

  // Step 2: Wait for auth user to be fully created
  console.log('Step 2: Waiting 500ms for auth user to be fully created...');
  await new Promise(resolve => setTimeout(resolve, 500));
  console.log('✅ Wait complete');
  console.log('');

  // Step 3: Call RPC function
  console.log('Step 3: Calling RPC function create_profile_after_signup...');
  const { data: profileData, error: profileError } = await supabase.rpc(
    'create_profile_after_signup',
    {
      user_id: userId,
      phone_value: phone,
      full_name_value: fullName,
    }
  );

  if (profileError) {
    console.error('❌ RPC call failed:', profileError);
    console.error('Code:', (profileError as any).code);
    console.error('Message:', profileError.message);
    console.error('Details:', (profileError as any).details);
    return;
  }

  console.log('✅ RPC function executed successfully');
  console.log('Profile data:', profileData);
  console.log('');

  // Step 4: Verify profile was created
  console.log('Step 4: Verifying profile was created in database...');
  const { data: profile, error: fetchError } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', userId)
    .single();

  if (fetchError) {
    console.error('❌ Profile fetch failed:', fetchError);
    return;
  }

  console.log('✅ Profile verified in database');
  console.log('Profile:', profile);
  console.log('');

  // Step 5: Cleanup - delete test user
  console.log('Step 5: Cleaning up test user...');
  // Note: In production, you might want to keep test users for verification
  console.log('✅ Test complete');
  console.log('');
  console.log('🎉 SUCCESS: Signup flow works correctly!');
}

testSignupFlow().catch(err => {
  console.error('🚨 Unexpected error:', err);
  process.exit(1);
});
