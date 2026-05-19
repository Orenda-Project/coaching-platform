#!/usr/bin/env node
/**
 * Automated Coach Feature Verification Script
 *
 * Purpose: Test if coaches can see all modules after deployment
 * Usage: node scripts/verify-coach-feature.js [email] [environment]
 * Example: node scripts/verify-coach-feature.js jalal.khan125@gmail.com production
 */

const fs = require('fs');
const path = require('path');

// Load environment variables
const envFile = process.argv[3] === 'production' ? '.env' : '.env.local';
const envPath = path.join(__dirname, '..', envFile);

if (fs.existsSync(envPath)) {
  require('dotenv').config({ path: envPath });
}

const { createClient } = require('@supabase/supabase-js');

const email = process.argv[2] || 'jalal.khan125@gmail.com';
const environment = process.argv[3] || 'production';

const supabaseUrl = process.env.VITE_SUPABASE_URL;
const supabaseKey = process.env.VITE_SUPABASE_PUBLISHABLE_KEY;

if (!supabaseUrl || !supabaseKey) {
  console.error('❌ Error: VITE_SUPABASE_URL or VITE_SUPABASE_PUBLISHABLE_KEY not set');
  console.error('Make sure to run from project root with .env files configured');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);

async function verify() {
  console.log('🔍 Verifying Coach Feature Deployment');
  console.log('━'.repeat(60));
  console.log(`Email: ${email}`);
  console.log(`Environment: ${environment}`);
  console.log(`Supabase URL: ${supabaseUrl}`);
  console.log('');

  try {
    // Step 1: Find user
    console.log('📋 STEP 1: Looking for user by email');
    console.log('─'.repeat(60));
    const { data: users } = await supabase
      .from('profiles')
      .select('id, full_name, persona, weak_modules')
      .eq('email', email);

    if (!users || users.length === 0) {
      console.error(`❌ User ${email} not found`);
      return false;
    }

    const user = users[0];
    const userId = user.id;
    console.log(`✓ Found user: ${user.full_name}`);
    console.log(`  Persona: ${user.persona}`);
    console.log(`  Weak Modules: ${JSON.stringify(user.weak_modules)}`);
    console.log('');

    // Step 2: Check if user has coach role
    console.log('📋 STEP 2: Checking if user has coach role');
    console.log('─'.repeat(60));
    const { data: roles } = await supabase
      .from('user_roles')
      .select('role')
      .eq('user_id', userId);

    const hasCoachRole = roles && roles.some(r => r.role === 'coach');
    if (hasCoachRole) {
      console.log('✓ User HAS coach role');
    } else {
      console.log('✗ User DOES NOT have coach role');
    }
    console.log('');

    // Step 3: Get all modules
    console.log('📋 STEP 3: Fetching all modules');
    console.log('─'.repeat(60));
    const { data: modules } = await supabase
      .from('modules')
      .select('id, title, order_number, is_mandatory')
      .order('order_number');

    if (!modules || modules.length === 0) {
      console.error('❌ No modules found in database');
      return false;
    }

    console.log(`✓ Found ${modules.length} total modules:`);
    modules.forEach(m => {
      console.log(`  [${m.order_number}] ${m.title}${m.is_mandatory ? ' (mandatory)' : ''}`);
    });
    console.log('');

    // Step 4: Calculate what modules user should see
    console.log('📋 STEP 4: Calculating expected visible modules');
    console.log('─'.repeat(60));

    let visibleModules;
    if (hasCoachRole || user.persona === 'E') {
      visibleModules = modules;
      console.log('✓ User should see ALL modules (coach or Persona E)');
    } else {
      const weakModules = user.weak_modules || [];
      visibleModules = modules.filter(m =>
        m.is_mandatory || weakModules.some(wm => m.title.startsWith(wm))
      );
      console.log(`✓ User should see: Module 1 (mandatory) + weak_modules`);
    }

    console.log(`  Visible modules: ${visibleModules.map(m => m.order_number).join(', ')}`);
    console.log('');

    // Step 5: Check trainings
    console.log('📋 STEP 5: Checking trainings availability');
    console.log('─'.repeat(60));
    const { data: trainings } = await supabase
      .from('trainings')
      .select('id, title, module_id');

    const trainingsCount = trainings ? trainings.length : 0;
    console.log(`✓ Total trainings in database: ${trainingsCount}`);
    console.log('');

    // Step 6: Summary
    console.log('📊 VERIFICATION SUMMARY');
    console.log('═'.repeat(60));
    console.log(`User: ${user.full_name} (${email})`);
    console.log(`Persona: ${user.persona}`);
    console.log(`Coach Role: ${hasCoachRole ? '✓ YES' : '✗ NO'}`);
    console.log(`Expected Visible Modules: ${visibleModules.length} of ${modules.length}`);
    console.log(`Module List: ${visibleModules.map(m => m.order_number).join(', ')}`);
    console.log('');

    // Status
    const shouldSeeAll = hasCoachRole || user.persona === 'E';
    const status = shouldSeeAll && visibleModules.length === modules.length ? '✅ PASS' : '⚠️ CHECK';
    console.log(`Status: ${status}`);
    console.log('═'.repeat(60));

    return shouldSeeAll && visibleModules.length === modules.length;
  } catch (error) {
    console.error('❌ Error during verification:', error.message);
    return false;
  }
}

// Run verification
verify().then(success => {
  process.exit(success ? 0 : 1);
});
