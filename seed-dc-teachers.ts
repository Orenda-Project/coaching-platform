#!/usr/bin/env npx ts-node
import { createClient } from '@supabase/supabase-js';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

// Use environment variables from .env.local
const supabaseUrl = process.env.VITE_SUPABASE_URL || 'https://kddvxrlffafyjvvststh.supabase.co';
const supabaseAnonKey = process.env.VITE_SUPABASE_PUBLISHABLE_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  console.error('Missing Supabase credentials');
  process.exit(1);
}

const client = createClient(supabaseUrl, supabaseAnonKey);

interface DCTeacher {
  user_id: string;
  teacher_name: string;
  School: string;
  Sector: string;
  subject: string;
  grade: string;
  overall_percentage: number;
  total_score: number;
  created_date: string;
  [key: string]: unknown;
}

async function seedDcTeachers() {
  try {
    // Read the BigQuery result file
    const dataFile = path.join(
      __dirname,
      '.claude/projects/c--Users-Taleemabad-LT-070-Desktop-coaching-platform-coaching-platform/2bd9d148-b719-4f2e-8296-5d2651ddde13/tool-results/mcp-plugin_taleemabad-data_taleemabad-data-execute_query-1778100985232.txt'
    );

    if (!fs.existsSync(dataFile)) {
      console.error('Data file not found. Run the BigQuery query first to generate dc-data.json');
      process.exit(1);
    }

    const fileContent = fs.readFileSync(dataFile, 'utf-8');
    const wrapped = JSON.parse(fileContent);
    const queryResult = JSON.parse(wrapped.result);
    const teachers: DCTeacher[] = queryResult.rows;

    console.log(`📊 Loading ${teachers.length} DC teachers from BigQuery...`);

    // Get current user
    const { data: { user }, error: userError } = await client.auth.getUser();
    if (userError || !user) {
      console.error('❌ Not authenticated. Please log in first.');
      process.exit(1);
    }

    console.log(`👤 Using user: ${user.email}`);

    // Prepare insert data
    const inserts = teachers.map(teacher => ({
      observer_id: user.id,
      teacher_name: teacher.teacher_name,
      school_name: teacher.School,
      region: teacher.Sector || 'Unknown',
      subject: teacher.subject,
      grade: teacher.grade,
      framework: 'FICO',
      total_score: Math.round(teacher.total_score),
      proficiency_level:
        teacher.overall_percentage >= 85 ? 'Advanced' :
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

    // Insert in batches of 50
    const batchSize = 50;
    let successCount = 0;
    let errorCount = 0;

    for (let i = 0; i < inserts.length; i += batchSize) {
      const batch = inserts.slice(i, i + batchSize);
      const batchNum = Math.floor(i / batchSize) + 1;

      const { error } = await client
        .from('teacher_dc_scores')
        .upsert(batch, { onConflict: 'observer_id,teacher_name,school_name,scored_at' });

      if (error) {
        console.error(`❌ Batch ${batchNum} failed:`, error.message);
        errorCount += batch.length;
      } else {
        console.log(`✅ Batch ${batchNum}: ${batch.length} teachers`);
        successCount += batch.length;
      }
    }

    console.log(`\n✨ Seeding complete!`);
    console.log(`   ✅ ${successCount} teachers inserted`);
    if (errorCount > 0) {
      console.log(`   ❌ ${errorCount} errors`);
    }
  } catch (err) {
    console.error('❌ Seeding error:', err);
    process.exit(1);
  }
}

seedDcTeachers();
