# Quiz API Integration - Railway PostgreSQL

## Overview

The Quiz API integrates the coaching platform frontend with Railway PostgreSQL through a FastAPI backend. It fetches 173 questions (162 MCQ + 11 scenario) and provides randomized quiz generation (16 MCQ + 4 scenarios per session).

## Architecture

```
Frontend (React/TypeScript)
  ↓ HTTP Requests
FastAPI Backend (coaching-api)
  ↓ SQL Queries
Railway PostgreSQL
  ↓ 173 questions (export_questions, export_options, export_scenarios)
```

## Backend Implementation

### New Files

- **`coaching-api/app/controllers/quiz_controller.py`** — FastAPI endpoints
- **`coaching-api/app/services/quiz_service.py`** — Quiz business logic
- **`coaching-api/test_quiz_endpoints.sh`** — Endpoint testing script

### API Endpoints

#### 1. Get All Quiz Modules
```
GET /api/quiz/modules
```

**Response:**
```json
{
  "modules": [
    {
      "id": "module_1",
      "title": "The Coaching Catalyst",
      "description": "...",
      "order_number": 1,
      "mcq_count": 44,
      "scenario_count": 0,
      "total_questions": 44
    },
    ...
  ],
  "total_modules": 6,
  "export_metadata": {
    "version": "1.0.0",
    "exported_at": "2026-06-09T15:30:00.000Z"
  }
}
```

#### 2. Get All Questions for Module
```
GET /api/quiz/module/{module_id}/questions
```

**Response:**
```json
{
  "module_id": "module_1",
  "mcq_count": 44,
  "scenario_count": 0,
  "total_questions": 44,
  "mcq": [
    {
      "id": "q_1",
      "question_type": "mcq",
      "question_text": "What is coaching?",
      "order_number": 1,
      "options": [
        {
          "id": "opt_1",
          "letter": "A",
          "text": "Option A",
          "is_correct": false
        },
        ...
      ]
    },
    ...
  ],
  "scenarios": [
    {
      "id": "s_1",
      "question_type": "scenario",
      "situation": "A coach is...",
      "question_text": "What should the coach do?",
      "difficulty": "medium",
      "options": [
        {
          "id": "opt_1",
          "letter": "A",
          "text": "Option A",
          "is_correct": false,
          "rationale": "This doesn't work because..."
        },
        ...
      ]
    },
    ...
  ]
}
```

#### 3. Get Randomized Quiz (16 MCQ + 4 Scenarios)
```
GET /api/quiz/module/{module_id}/random
```

**Response:**
```json
{
  "module_id": "module_1",
  "total_questions": 20,
  "mcq_selected": 16,
  "scenarios_selected": 4,
  "questions": [
    ... 20 randomly shuffled questions (16 MCQ + 4 scenarios) ...
  ],
  "export_metadata": {
    "version": "1.0.0",
    "exported_at": "2026-06-09T15:30:00.000Z"
  }
}
```

## Frontend Implementation

### New Files

- **`src/lib/quizApiClient.ts`** — API client service
- **`src/hooks/useQuiz.ts`** — React hook for quiz data

### API Client

The `QuizApiClient` class handles communication with the FastAPI backend:

```typescript
import { quizApiClient } from "@/lib/quizApiClient";

// Get modules
const modules = await quizApiClient.getModules();

// Get all questions for a module
const questions = await quizApiClient.getModuleQuestions("module_1");

// Get randomized quiz (16 MCQ + 4 scenarios)
const randomQuiz = await quizApiClient.getRandomizedQuiz("module_1");
```

**Features:**
- Automatic retry logic with exponential backoff (3 attempts)
- In-memory caching for modules and question lists
- Error handling for network and server errors
- Configurable API URL via `VITE_QUIZ_API_URL`

### React Hook

The `useQuiz` hook provides state management for quiz data:

```typescript
import { useQuiz } from "@/hooks/useQuiz";

export function QuizPage() {
  const { questions, loading, error, loadQuiz } = useQuiz();

  useEffect(() => {
    loadQuiz("module_1");
  }, [loadQuiz]);

  if (loading) return <div>Loading quiz...</div>;
  if (error) return <div>Error: {error}</div>;

  return (
    <div>
      {questions.map((q) => (
        <QuestionCard key={q.id} question={q} />
      ))}
    </div>
  );
}
```

**Hook Functions:**
- `loadQuiz(moduleId)` — Load randomized quiz for a module
- `loadModules()` — Load all modules with question counts
- `clearError()` — Clear error state

### Alternative Hook for All Questions

For admin views or debugging, use `useQuizAllQuestions`:

```typescript
import { useQuizAllQuestions } from "@/hooks/useQuiz";

const { questions, loading, error, loadAllQuestions } = useQuizAllQuestions("module_1");
```

## Environment Setup

### Configuration Files

Environment variables are set in three files:

#### `.env` (Production Default)
```
VITE_QUIZ_API_URL=http://localhost:8000
```

#### `.env.local` (Local Development)
```
VITE_QUIZ_API_URL=http://localhost:8000
```

#### `.env.staging` (Staging Environment)
```
VITE_QUIZ_API_URL=https://coaching-api-staging.railway.app
```

#### `.env.production` (Production)
```
VITE_QUIZ_API_URL=https://coaching-api.railway.app
```

### Backend Configuration

The FastAPI backend needs the following:

1. **Railway PostgreSQL Connection** — Database URL configured in `coaching-api/app/config.py`
2. **CORS Settings** — Already enabled in `coaching-api/app/main.py` (allows all origins)
3. **Port** — Runs on `8000` by default

## Testing

### Test the Backend Endpoints

1. Start the FastAPI server:
```bash
cd coaching-api
source venv/bin/activate
uvicorn app.main:app --reload
```

2. Run the test script:
```bash
chmod +x test_quiz_endpoints.sh
./test_quiz_endpoints.sh
```

Or test manually with curl:
```bash
# Get modules
curl http://localhost:8000/api/quiz/modules

# Get questions for a module
curl http://localhost:8000/api/quiz/module/module_1/questions

# Get randomized quiz
curl http://localhost:8000/api/quiz/module/module_1/random
```

### Test the Frontend Integration

1. Import the hook in your component:
```typescript
import { useQuiz } from "@/hooks/useQuiz";
```

2. Load quiz data:
```typescript
const { questions, loading, error, loadQuiz } = useQuiz();

useEffect(() => {
  loadQuiz("module_1");
}, [loadQuiz]);
```

3. Display questions:
```typescript
{questions.map((q) => (
  <div key={q.id}>
    <h3>{q.question_text}</h3>
    {q.options.map((opt) => (
      <div key={opt.id}>
        <input type="radio" name={q.id} value={opt.id} />
        <label>{opt.letter}: {opt.text}</label>
      </div>
    ))}
  </div>
))}
```

## Data Schema

### Question Types

**MCQ (Multiple Choice):**
```typescript
{
  id: string;
  question_type: "mcq";
  question_text: string;
  order_number?: number;
  options: [
    { id, letter, text, is_correct },
    ...
  ];
}
```

**Scenario:**
```typescript
{
  id: string;
  question_type: "scenario";
  situation: string;
  question_text: string;
  difficulty: "easy" | "medium" | "hard";
  options: [
    { id, letter, text, is_correct, rationale },
    ...
  ];
}
```

## Error Handling

The API client handles these error scenarios:

1. **Network Errors** — Retries with exponential backoff (1s, 2s, 4s)
2. **4xx Client Errors** — Returns error immediately (no retry)
3. **5xx Server Errors** — Retries with exponential backoff
4. **Module Not Found (404)** — Throws error with module ID

Example error handling in component:
```typescript
const { error, clearError } = useQuiz();

if (error) {
  return (
    <div className="error">
      <p>{error}</p>
      <button onClick={clearError}>Dismiss</button>
    </div>
  );
}
```

## Performance Considerations

1. **Caching** — Module lists and question lists are cached in memory
2. **Random Selection** — Backend performs 16 MCQ + 4 scenario selection
3. **Shuffling** — Questions are shuffled by backend before sending
4. **No Awaits** — Error handling doesn't block question loading

For high-traffic scenarios, consider:
- Adding response compression (gzip)
- Caching at CDN level
- Pagination for large result sets
- Database query optimization with indexes

## Rollback

If the API needs to be rolled back:

1. Delete the new files:
   - `coaching-api/app/controllers/quiz_controller.py`
   - `coaching-api/app/services/quiz_service.py`

2. Revert `coaching-api/app/main.py` (remove quiz router import/include)

3. Delete frontend files:
   - `src/lib/quizApiClient.ts`
   - `src/hooks/useQuiz.ts`

4. Remove `VITE_QUIZ_API_URL` from `.env` files

## Future Enhancements

1. **Authentication** — Add JWT validation to endpoints
2. **Analytics** — Track which questions are most commonly missed
3. **Difficulty Filtering** — Allow filtering by difficulty level
4. **Question Banking** — Support multiple question banks per module
5. **Performance Analytics** — Track user quiz performance
6. **Caching Strategy** — Implement Redis caching for high-traffic scenarios

## Support

For issues or questions:
1. Check FastAPI docs: `http://localhost:8000/docs`
2. Enable debug logging in `quizApiClient.ts`
3. Verify Railway PostgreSQL connection in backend
4. Ensure environment variables are set correctly
