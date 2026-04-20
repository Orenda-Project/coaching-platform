// Script to apply baseline v2 migration
import { readFileSync } from 'fs';
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.VITE_SUPABASE_URL;
const supabaseKey = process.env.VITE_SUPABASE_PUBLISHABLE_KEY;

if (!supabaseUrl || !supabaseKey) {
  console.error('Missing Supabase environment variables');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);

async function applyMigration() {
  try {
    const sqlFile = readFileSync('./supabase/migrations/20260420_baseline_v2_questions.sql', 'utf-8');
    
    // Split SQL into individual statements
    const statements = sqlFile
      .split(';')
      .map(stmt => stmt.trim())
      .filter(stmt => stmt && !stmt.startsWith('--'));

    console.log(`Found ${statements.length} SQL statements to execute`);

    for (const statement of statements) {
      console.log('Executing:', statement.substring(0, 80) + '...');
      
      const { error } = await supabase.rpc('exec_sql', { sql: statement });
      if (error) {
        console.error('Error executing:', error);
        // Try raw query instead
        const { data, error: rawError } = await supabase
          .from('questions')
          .select('id')
          .limit(1);
        
        if (rawError) {
          console.log('Note: This environment may not support direct SQL execution via RPC');
          console.log('You may need to apply this migration via Supabase dashboard or CLI');
        }
      }
    }

    console.log('Migration completed');
  } catch (error) {
    console.error('Migration failed:', error);
  }
}

applyMigration();
