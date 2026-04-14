const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = 'https://kddvxrlffafyjvvststh.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtkZHZ4cmxmZmFmeWp2dnN0c3RoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU4MjA0NDQsImV4cCI6MjA5MTM5NjQ0NH0.zJLIoTzQEhoBSlW4nRzKkjue2WR5YAHX8ymtUeJEITY';

const supabase = createClient(supabaseUrl, supabaseKey);

async function queryModules() {
  console.log('\n=== MODULES IN STAGING DB ===\n');
  const { data: modules, error } = await supabase
    .from('modules')
    .select('*')
    .order('order_number', { ascending: true });

  if (error) {
    console.error('Error fetching modules:', error);
    return;
  }

  modules.forEach(m => {
    console.log(`Module ${m.id}: ${m.title} (order: ${m.order_number})`);
  });
}

async function queryQuizQuestions() {
  console.log('\n=== QUIZ QUESTIONS IN MODULE 1 ===\n');
  const { data: questions, error } = await supabase
    .from('quiz_questions')
    .select('*')
    .eq('module_id', 1)
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
    console.log(`Question: ${q.question_text}`);
    console.log(`Type: ${q.question_type}`);
    if (q.question_type === 'mcq' && q.options) {
      console.log(`Options: ${JSON.stringify(q.options)}`);
      console.log(`Correct Answer: ${q.correct_answer}`);
    }
    console.log('---');
  });
}

async function main() {
  try {
    await queryModules();
    await queryQuizQuestions();
  } catch (err) {
    console.error('Unexpected error:', err);
  }
}

main();
