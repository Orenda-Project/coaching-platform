// Question/option factories for assessments and module quizzes.

export type QuestionType = 'mcq' | 'open_ended' | 'scenario';

export interface FixtureQuestion {
  id: string;
  text: string;
  question_type: QuestionType;
  order_number: number;
}

export interface FixtureOption {
  id: string;
  question_id: string;
  text: string;
  is_correct: boolean;
  order_number: number;
}

let qCounter = 0;
let oCounter = 0;

export function makeQuestion(overrides: Partial<FixtureQuestion> = {}): FixtureQuestion {
  qCounter += 1;
  return {
    id: `question-${qCounter}`,
    text: `Question ${qCounter}`,
    question_type: 'mcq',
    order_number: qCounter,
    ...overrides,
  };
}

export function makeOption(
  questionId: string,
  overrides: Partial<FixtureOption> = {},
): FixtureOption {
  oCounter += 1;
  return {
    id: `option-${oCounter}`,
    question_id: questionId,
    text: `Option ${oCounter}`,
    is_correct: false,
    order_number: oCounter,
    ...overrides,
  };
}
