#!/usr/bin/env node
import { createClient } from '@supabase/supabase-js';
import fs from 'fs';
import path from 'path';

const supabaseUrl = process.env.VITE_SUPABASE_URL || 'http://127.0.0.1:54321';
const supabaseKey = process.env.VITE_SUPABASE_PUBLISHABLE_KEY || process.env.SUPABASE_ANON_KEY;
const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !supabaseKey || !serviceRoleKey) {
  console.error('Missing Supabase credentials. Set VITE_SUPABASE_URL, VITE_SUPABASE_PUBLISHABLE_KEY, and SUPABASE_SERVICE_ROLE_KEY');
  process.exit(1);
}

const adminClient = createClient(supabaseUrl, serviceRoleKey);

async function getUserId(email) {
  const { data: { users }, error } = await adminClient.auth.admin.listUsers();
  if (error) {
    console.error('Error listing users:', error);
    return null;
  }
  const user = users.find(u => u.email === email);
  return user?.id;
}

async function seedDcData() {
  try {
    // Read the saved query result
    const dataPath = path.join(
      process.cwd(),
      '.claude/projects/c--Users-Taleemabad-LT-070-Desktop-coaching-platform-coaching-platform/2bd9d148-b719-4f2e-8296-5d2651ddde13/tool-results/mcp-plugin_taleemabad-data_taleemabad-data-execute_query-1778100985232.txt'
    );

    if (!fs.existsSync(dataPath)) {
      console.error('Data file not found:', dataPath);
      process.exit(1);
    }

    const fileContent = fs.readFileSync(dataPath, 'utf-8');
    const wrapped = JSON.parse(fileContent);
    const data = JSON.parse(wrapped.result);
    const teachers = data.rows;

    console.log(`Loading ${teachers.length} teachers from BigQuery...`);

    // Get user ID
    const userId = await getUserId('afifa.sultana@taleemabad.com');
    if (!userId) {
      console.error('User afifa.sultana@taleemabad.com not found');
      process.exit(1);
    }
    console.log(`Using user ID: ${userId}`);

    // Transform and insert teachers
    const inserts = teachers.map(teacher => ({
      observer_id: userId,
      teacher_name: teacher.teacher_name,
      school_name: teacher.School,
      region: teacher.Sector || 'Unknown',
      subject: teacher.subject,
      grade: teacher.grade,
      framework: 'FICO',
      total_score: Math.round(teacher.total_score),
      proficiency_level: teacher.overall_percentage >= 85 ? 'Advanced' :
                        teacher.overall_percentage >= 70 ? 'Proficient' :
                        teacher.overall_percentage >= 50 ? 'Basic' : 'Below Basic',
      scored_at: new Date(teacher.created_date).toISOString(),
      raw_results: {
        accurate_lesson_planning: teacher.accurate_lesson_planning,
        timely_lesson_delivery: teacher.timely_lesson_delivery,
        subject_command: teacher.subject_command,
        effective_pedagogy: teacher.effective_pedagogy,
        effective_resource_use: teacher.effective_resource_use,
        activity_based_learning: teacher.activity_based_learning,
        student_participation: teacher.student_participation,
        critical_thinking: teacher.critical_thinking,
        inclusive_practices: teacher.inclusive_practices,
        technology_integration: teacher.technology_integration,
        technology_handling: teacher.technology_handling,
        verbal_communication: teacher.verbal_communication,
        non_verbal_communication: teacher.non_verbal_communication,
        overall_percentage: teacher.overall_percentage,
      }
    }));

    // Batch insert in chunks of 100
    const batchSize = 100;
    for (let i = 0; i < inserts.length; i += batchSize) {
      const batch = inserts.slice(i, i + batchSize);
      const { error } = await adminClient
        .from('teacher_dc_scores')
        .upsert(batch, { onConflict: 'observer_id,teacher_name,school_name,scored_at' });

      if (error) {
        console.error(`Error inserting batch ${i / batchSize + 1}:`, error);
      } else {
        console.log(`✓ Inserted batch ${i / batchSize + 1} (${batch.length} teachers)`);
      }
    }

    console.log(`\n✅ Successfully seeded ${inserts.length} DC teachers into teacher_dc_scores table`);
  } catch (err) {
    console.error('Seeding error:', err);
    process.exit(1);
  }
}

seedDcData();
