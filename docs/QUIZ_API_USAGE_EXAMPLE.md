# Quiz API Usage Examples

## Complete Quiz Page Implementation

### Basic Quiz Component

```typescript
import { useEffect } from "react";
import { useQuiz } from "@/hooks/useQuiz";
import { QuizQuestion } from "@/lib/quizApiClient";

interface QuizPageProps {
  moduleId: string;
}

export function QuizPage({ moduleId }: QuizPageProps) {
  const { questions, loading, error, loadQuiz } = useQuiz();

  useEffect(() => {
    loadQuiz(moduleId);
  }, [moduleId, loadQuiz]);

  if (loading) {
    return (
      <div className="flex items-center justify-center p-8">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary"></div>
        <span className="ml-4">Loading quiz...</span>
      </div>
    );
  }

  if (error) {
    return (
      <div className="bg-red-50 border border-red-200 rounded-lg p-6">
        <h3 className="text-red-800 font-semibold">Failed to Load Quiz</h3>
        <p className="text-red-600 mt-2">{error}</p>
        <button
          onClick={() => loadQuiz(moduleId)}
          className="mt-4 px-4 py-2 bg-red-600 text-white rounded hover:bg-red-700"
        >
          Retry
        </button>
      </div>
    );
  }

  if (questions.length === 0) {
    return (
      <div className="text-center p-8">
        <p className="text-gray-500">No questions available for this module.</p>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h2 className="text-2xl font-bold">Quiz - {moduleId}</h2>
        <span className="text-sm text-gray-600">
          {questions.length} questions
        </span>
      </div>

      <QuizForm questions={questions} />
    </div>
  );
}
```

### Quiz Form with MCQ and Scenario Rendering

```typescript
import { useState } from "react";
import { QuizQuestion } from "@/lib/quizApiClient";

interface QuizFormProps {
  questions: QuizQuestion[];
}

export function QuizForm({ questions }: QuizFormProps) {
  const [answers, setAnswers] = useState<Record<string, string>>({});
  const [currentIndex, setCurrentIndex] = useState(0);

  const currentQuestion = questions[currentIndex];
  const isLastQuestion = currentIndex === questions.length - 1;

  const handleAnswer = (optionId: string) => {
    setAnswers({
      ...answers,
      [currentQuestion.id]: optionId,
    });
  };

  const handleNext = () => {
    if (!isLastQuestion) {
      setCurrentIndex(currentIndex + 1);
    } else {
      submitQuiz();
    }
  };

  const handlePrev = () => {
    if (currentIndex > 0) {
      setCurrentIndex(currentIndex - 1);
    }
  };

  const submitQuiz = () => {
    const score = calculateScore();
    console.log(`Quiz submitted. Score: ${score}/${questions.length}`);
    // Handle submission (save to database, show results, etc.)
  };

  const calculateScore = () => {
    return questions.filter((q) => {
      const selectedOptionId = answers[q.id];
      const selectedOption = q.options.find((o) => o.id === selectedOptionId);
      return selectedOption?.is_correct;
    }).length;
  };

  return (
    <div className="space-y-8">
      {/* Question Counter */}
      <div className="flex items-center justify-between">
        <span className="text-sm font-medium text-gray-600">
          Question {currentIndex + 1} of {questions.length}
        </span>
        <div className="w-32 h-2 bg-gray-200 rounded-full">
          <div
            className="h-full bg-primary rounded-full transition-all duration-300"
            style={{
              width: `${((currentIndex + 1) / questions.length) * 100}%`,
            }}
          ></div>
        </div>
      </div>

      {/* Question Content */}
      <div className="bg-white rounded-lg border border-gray-200 p-6">
        {currentQuestion.question_type === "mcq" ? (
          <MCQQuestion
            question={currentQuestion}
            selected={answers[currentQuestion.id]}
            onSelect={handleAnswer}
          />
        ) : (
          <ScenarioQuestion
            question={currentQuestion}
            selected={answers[currentQuestion.id]}
            onSelect={handleAnswer}
          />
        )}
      </div>

      {/* Navigation Buttons */}
      <div className="flex items-center justify-between">
        <button
          onClick={handlePrev}
          disabled={currentIndex === 0}
          className="px-6 py-2 bg-gray-200 text-gray-800 rounded hover:bg-gray-300 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          Previous
        </button>

        <button
          onClick={handleNext}
          disabled={!answers[currentQuestion.id]}
          className="px-6 py-2 bg-primary text-white rounded hover:bg-primary-600 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {isLastQuestion ? "Submit" : "Next"}
        </button>
      </div>

      {/* Question Navigator - Optional */}
      <QuestionNavigator
        total={questions.length}
        answered={Object.keys(answers).length}
        current={currentIndex}
        onSelect={setCurrentIndex}
      />
    </div>
  );
}
```

### MCQ Question Component

```typescript
import { QuizQuestion } from "@/lib/quizApiClient";

interface MCQQuestionProps {
  question: QuizQuestion;
  selected: string | undefined;
  onSelect: (optionId: string) => void;
}

export function MCQQuestion({
  question,
  selected,
  onSelect,
}: MCQQuestionProps) {
  return (
    <div className="space-y-4">
      <h3 className="text-lg font-semibold text-gray-900">
        {question.question_text}
      </h3>

      <div className="space-y-3">
        {question.options.map((option) => (
          <label
            key={option.id}
            className="flex items-center p-4 border-2 border-gray-200 rounded-lg cursor-pointer hover:border-primary hover:bg-primary-50 transition-colors"
            style={{
              borderColor: selected === option.id ? "#3b82f6" : undefined,
              backgroundColor: selected === option.id ? "#eff6ff" : undefined,
            }}
          >
            <input
              type="radio"
              name={question.id}
              value={option.id}
              checked={selected === option.id}
              onChange={() => onSelect(option.id)}
              className="w-4 h-4 text-primary"
            />
            <span className="ml-4">
              <strong>{option.letter}:</strong> {option.text}
            </span>
          </label>
        ))}
      </div>
    </div>
  );
}
```

### Scenario Question Component

```typescript
import { QuizQuestion } from "@/lib/quizApiClient";

interface ScenarioQuestionProps {
  question: QuizQuestion;
  selected: string | undefined;
  onSelect: (optionId: string) => void;
}

export function ScenarioQuestion({
  question,
  selected,
  onSelect,
}: ScenarioQuestionProps) {
  return (
    <div className="space-y-6">
      {/* Scenario Background */}
      <div className="bg-blue-50 border-l-4 border-blue-400 p-4 rounded">
        <p className="text-gray-800 leading-relaxed">{question.situation}</p>
        {question.difficulty && (
          <span className="inline-block mt-2 px-3 py-1 bg-blue-200 text-blue-800 text-xs font-semibold rounded-full">
            {question.difficulty.charAt(0).toUpperCase() +
              question.difficulty.slice(1)}
          </span>
        )}
      </div>

      {/* Question */}
      <h3 className="text-lg font-semibold text-gray-900">
        {question.question_text}
      </h3>

      {/* Options with Rationale */}
      <div className="space-y-3">
        {question.options.map((option) => (
          <div
            key={option.id}
            className={`border-2 rounded-lg p-4 cursor-pointer transition-colors ${
              selected === option.id
                ? "border-primary bg-primary-50"
                : "border-gray-200 hover:border-primary-200"
            }`}
            onClick={() => onSelect(option.id)}
          >
            <label className="flex items-start cursor-pointer">
              <input
                type="radio"
                name={question.id}
                value={option.id}
                checked={selected === option.id}
                onChange={() => onSelect(option.id)}
                className="mt-1 w-4 h-4 text-primary"
              />
              <div className="ml-4 flex-1">
                <div className="font-semibold text-gray-900">
                  {option.letter}: {option.text}
                </div>
                {selected === option.id && option.rationale && (
                  <div className="mt-2 p-2 bg-blue-100 rounded text-sm text-gray-700">
                    <strong>Why:</strong> {option.rationale}
                  </div>
                )}
              </div>
            </label>
          </div>
        ))}
      </div>
    </div>
  );
}
```

### Question Navigator Component

```typescript
interface QuestionNavigatorProps {
  total: number;
  answered: number;
  current: number;
  onSelect: (index: number) => void;
}

export function QuestionNavigator({
  total,
  answered,
  current,
  onSelect,
}: QuestionNavigatorProps) {
  return (
    <div className="border-t pt-6">
      <div className="flex items-center justify-between mb-4">
        <h4 className="font-semibold">Question Overview</h4>
        <span className="text-sm text-gray-600">
          {answered} of {total} answered
        </span>
      </div>

      <div className="grid grid-cols-10 gap-2">
        {Array.from({ length: total }).map((_, index) => (
          <button
            key={index}
            onClick={() => onSelect(index)}
            className={`aspect-square rounded font-semibold text-sm transition-colors ${
              index === current
                ? "bg-primary text-white"
                : "bg-gray-100 text-gray-700 hover:bg-gray-200"
            }`}
          >
            {index + 1}
          </button>
        ))}
      </div>
    </div>
  );
}
```

## Loading Modules List

```typescript
import { useEffect } from "react";
import { useQuiz } from "@/hooks/useQuiz";

export function ModuleSelector() {
  const { modules, loading, error, loadModules } = useQuiz();

  useEffect(() => {
    loadModules();
  }, [loadModules]);

  if (loading) return <div>Loading modules...</div>;
  if (error) return <div>Error: {error}</div>;

  return (
    <div className="grid grid-cols-1 gap-4">
      {modules.map((module) => (
        <div
          key={module.id}
          className="border rounded-lg p-4 hover:shadow-lg transition-shadow cursor-pointer"
        >
          <h3 className="font-bold">{module.title}</h3>
          <p className="text-sm text-gray-600">{module.description}</p>
          <div className="mt-2 flex gap-4 text-xs text-gray-500">
            <span>{module.mcq_count} MCQ</span>
            <span>{module.scenario_count} Scenarios</span>
          </div>
        </div>
      ))}
    </div>
  );
}
```

## Quiz Results Page

```typescript
interface QuizResultsProps {
  questions: QuizQuestion[];
  answers: Record<string, string>;
}

export function QuizResults({ questions, answers }: QuizResultsProps) {
  const score = calculateScore(questions, answers);
  const passed = score >= 16; // 80% of 20 questions

  return (
    <div className="space-y-6">
      <div className="text-center">
        <h2 className="text-3xl font-bold">Quiz Complete</h2>
        <p className="text-4xl font-bold text-primary mt-4">
          {score}/20
        </p>
        <p className="text-lg text-gray-600 mt-2">
          {passed ? "Congratulations! You passed!" : "Please review and retry."}
        </p>
      </div>

      {/* Review Answers */}
      <div className="space-y-4">
        <h3 className="font-bold text-lg">Review Your Answers</h3>
        {questions.map((question, index) => {
          const selectedOptionId = answers[question.id];
          const selectedOption = question.options.find(
            (o) => o.id === selectedOptionId
          );
          const isCorrect = selectedOption?.is_correct;

          return (
            <div
              key={question.id}
              className={`p-4 rounded-lg border-l-4 ${
                isCorrect
                  ? "bg-green-50 border-green-400"
                  : "bg-red-50 border-red-400"
              }`}
            >
              <div className="flex items-start">
                {isCorrect ? (
                  <span className="text-green-600 font-bold">✓</span>
                ) : (
                  <span className="text-red-600 font-bold">✗</span>
                )}
                <div className="ml-4 flex-1">
                  <p className="font-semibold">{question.question_text}</p>
                  <p className="text-sm text-gray-600 mt-1">
                    Your answer: <strong>{selectedOption?.text}</strong>
                  </p>
                  {!isCorrect && (
                    <p className="text-sm text-gray-600">
                      Correct answer:{" "}
                      <strong>
                        {
                          question.options.find((o) => o.is_correct)
                            ?.text
                        }
                      </strong>
                    </p>
                  )}
                </div>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}

function calculateScore(
  questions: QuizQuestion[],
  answers: Record<string, string>
) {
  return questions.filter((q) => {
    const selectedOptionId = answers[q.id];
    const selectedOption = q.options.find((o) => o.id === selectedOptionId);
    return selectedOption?.is_correct;
  }).length;
}
```

## Integration with Existing Quiz Page

If you have an existing Assessment or Quiz component, integrate like this:

```typescript
import { useQuiz } from "@/hooks/useQuiz";

export function AssessmentPage({ trainingId }: { trainingId: string }) {
  const [showQuiz, setShowQuiz] = useState(false);
  const { questions, loading, error, loadQuiz } = useQuiz();

  const handleStartQuiz = async () => {
    try {
      await loadQuiz(trainingId);
      setShowQuiz(true);
    } catch (err) {
      toast.error("Failed to load quiz");
    }
  };

  if (!showQuiz) {
    return (
      <button
        onClick={handleStartQuiz}
        className="px-6 py-3 bg-primary text-white rounded-lg hover:bg-primary-600"
      >
        Start Assessment Quiz
      </button>
    );
  }

  return <QuizForm questions={questions} />;
}
```

## Notes

1. All examples use the `useQuiz` hook for state management
2. Questions are already randomized by the backend (16 MCQ + 4 scenarios)
3. Error handling is built-in with retry logic
4. Optional: Add analytics tracking to question selection and submission
5. Optional: Implement caching for frequently accessed modules
