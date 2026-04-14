import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://kddvxrlffafyjvvststh.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtkZHZ4cmxmZmFmeWp2dnN0c3RoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU4MjA0NDQsImV4cCI6MjA5MTM5NjQ0NH0.zJLIoTzQEhoBSlW4nRzKkjue2WR5YAHX8ymtUeJEITY';

const supabase = createClient(supabaseUrl, supabaseKey);

async function queryQuestions() {
  console.log('\n=== QUESTIONS IN MODULE 1 ===\n');
  const { data: questions, error } = await supabase
    .from('questions')
    .select('*')
    .eq('module_id', '6d53f1ed-4487-4267-b54d-8dcfba9e83fc')
    .order('id', { ascending: true });

  if (error) {
    console.error('Error fetching questions:', error);
    return;
  }

  if (questions.length === 0) {
    console.log('No questions found in Module 1');
    return;
  }

  console.log(`Found ${questions.length} questions:\n`);
  questions.forEach(q => {
    console.log(`ID: ${q.id}`);
    console.log(`Question: ${q.question_text || q.text}`);
    console.log(`Type: ${q.type}`);
    if (q.options) {
      console.log(`Options:`, q.options);
    }
    console.log(`---`);
  });
}

async function main() {
  try {
    await queryQuestions();
  } catch (err) {
    console.error('Unexpected error:', err);
  }
}

main();
