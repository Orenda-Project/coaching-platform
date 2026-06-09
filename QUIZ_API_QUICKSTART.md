# Quiz API Quick Start Guide

## 60-Second Setup

### 1. Backend - Start the API Server
```bash
cd coaching-api
source venv/bin/activate
uvicorn app.main:app --reload
```
Server runs on `http://localhost:8000`

### 2. Backend - Test Endpoints
```bash
# Option A: Run test script
chmod +x test_quiz_endpoints.sh
./test_quiz_endpoints.sh

# Option B: Manual curl
curl http://localhost:8000/api/quiz/modules
curl http://localhost:8000/api/quiz/module/module_1/questions
curl http://localhost:8000/api/quiz/module/module_1/random
```

### 3. Frontend - Use the Hook
```typescript
import { useQuiz } from "@/hooks/useQuiz";

export function QuizPage({ moduleId }: { moduleId: string }) {
  const { questions, loading, error, loadQuiz } = useQuiz();

  useEffect(() => {
    loadQuiz(moduleId);
  }, [moduleId, loadQuiz]);

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;

  return (
    <div>
      {questions.map((q) => (
        <div key={q.id}>
          <h3>{q.question_text}</h3>
          {q.options.map((opt) => (
            <label key={opt.id}>
              <input type="radio" name={q.id} />
              {opt.letter}: {opt.text}
            </label>
          ))}
        </div>
      ))}
    </div>
  );
}
```

## What Was Built

### Backend (3 Files)
- `quiz_controller.py` — 3 REST endpoints
- `quiz_service.py` — Database queries
- `test_quiz_endpoints.sh` — Test script

### Frontend (2 Files)
- `quizApiClient.ts` — API communication
- `useQuiz.ts` — React state management

### Config (4 Files Modified)
- `.env` — Local development
- `.env.local` — Local testing
- `.env.staging` — Staging environment
- `.env.production` — Production environment

### Documentation (3 Files)
- `QUIZ_API_INTEGRATION.md` — Complete reference
- `QUIZ_API_USAGE_EXAMPLE.md` — Code examples
- `QUIZ_API_IMPLEMENTATION_SUMMARY.md` — Full summary

## API Endpoints

### Get All Modules
```bash
GET /api/quiz/modules
```

### Get All Questions for Module
```bash
GET /api/quiz/module/{module_id}/questions
```

### Get Randomized Quiz (16 MCQ + 4 Scenarios)
```bash
GET /api/quiz/module/{module_id}/random
```

## Hook Usage

### Load Randomized Quiz (16 MCQ + 4 scenarios)
```typescript
const { questions, loading, error, loadQuiz } = useQuiz();
await loadQuiz("module_1");
```

### Load All Questions (for admin views)
```typescript
const { questions, loadAllQuestions } = useQuizAllQuestions();
await loadAllQuestions("module_1");
```

### Load All Modules
```typescript
const { modules, loadModules } = useQuiz();
await loadModules();
```

## Environment Variables

### Local Development
```
VITE_QUIZ_API_URL=http://localhost:8000
```

### Production
```
VITE_QUIZ_API_URL=https://coaching-api.railway.app
```

## Typical Component Flow

```typescript
import { useQuiz } from "@/hooks/useQuiz";
import { useState } from "react";

export function AssessmentQuiz({ moduleId }: { moduleId: string }) {
  const [answers, setAnswers] = useState<Record<string, string>>({});
  const { questions, loading, error, loadQuiz } = useQuiz();

  // Load quiz on mount
  useEffect(() => {
    loadQuiz(moduleId);
  }, [moduleId, loadQuiz]);

  // Handle answer selection
  const handleAnswer = (questionId: string, optionId: string) => {
    setAnswers({ ...answers, [questionId]: optionId });
  };

  // Calculate score
  const calculateScore = () => {
    return questions.filter((q) => {
      const selected = answers[q.id];
      return q.options.find((o) => o.id === selected)?.is_correct;
    }).length;
  };

  // Render
  if (loading) return <div className="text-center p-8">Loading quiz...</div>;
  if (error) return <div className="text-red-600 p-4">{error}</div>;

  return (
    <div className="max-w-2xl mx-auto">
      <h1 className="text-2xl font-bold mb-6">Assessment Quiz</h1>

      {questions.map((question) => (
        <div key={question.id} className="mb-8 p-4 border rounded-lg">
          <h3 className="font-semibold mb-4">{question.question_text}</h3>
          <div className="space-y-2">
            {question.options.map((option) => (
              <label key={option.id} className="flex items-center">
                <input
                  type="radio"
                  name={question.id}
                  value={option.id}
                  checked={answers[question.id] === option.id}
                  onChange={() => handleAnswer(question.id, option.id)}
                  className="mr-2"
                />
                <span>{option.letter}: {option.text}</span>
              </label>
            ))}
          </div>
        </div>
      ))}

      <button
        onClick={() => {
          const score = calculateScore();
          alert(`Score: ${score}/${questions.length}`);
        }}
        className="mt-6 px-6 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
      >
        Submit Quiz
      </button>
    </div>
  );
}
```

## Common Tasks

### Fetch Only MCQ Questions
```typescript
const { questions } = await quizApiClient.getModuleQuestions("module_1");
const mcqOnly = questions.mcq;
```

### Get Scenario Questions
```typescript
const { questions } = await quizApiClient.getModuleQuestions("module_1");
const scenariosOnly = questions.scenarios;
```

### Clear Cache
```typescript
quizApiClient.clearCache();
```

### Handle Specific Errors
```typescript
try {
  await loadQuiz("invalid_module");
} catch (err) {
  if (err.message.includes("not found")) {
    // Handle module not found
  } else if (err.message.includes("network")) {
    // Handle network error
  }
}
```

## Debugging

### Check if Backend is Running
```bash
curl http://localhost:8000/health
```

### View API Documentation
```
http://localhost:8000/docs
```

### Enable Console Logging
```typescript
// In quizApiClient.ts, add console.log calls
console.log("[QuizApiClient] Loading questions for module:", moduleId);
```

### Check Network Tab
1. Open Chrome DevTools (F12)
2. Go to Network tab
3. Load quiz page
4. See requests to `/api/quiz/module/{id}/random`

## Troubleshooting

### "Cannot find module" Error
```bash
# Make sure imports are correct
import { useQuiz } from "@/hooks/useQuiz";
import { quizApiClient } from "@/lib/quizApiClient";
```

### API Returns 404
- Check `module_id` is correct
- Verify module exists in database
- Check backend logs for SQL errors

### Loading Never Finishes
- Check network tab for request status
- Verify `VITE_QUIZ_API_URL` is correct
- Check backend is running on port 8000

### Questions Not Randomized
- Randomization happens on backend
- Each call to `/random` endpoint returns different questions
- Frontend receives 20 pre-shuffled questions

## Performance Tips

1. **Cache Modules:** Only load once on app startup
   ```typescript
   useEffect(() => {
     loadModules(); // Once
   }, []);
   ```

2. **Don't Reload Questions:** Reuse loaded questions
   ```typescript
   if (questions.length > 0) return; // Already loaded
   loadQuiz(moduleId);
   ```

3. **Parallel Loading:** Load modules and quiz together
   ```typescript
   Promise.all([loadModules(), loadQuiz(moduleId)]);
   ```

## Production Deployment

1. Update `.env.production`:
   ```
   VITE_QUIZ_API_URL=https://coaching-api.railway.app
   ```

2. Build and deploy:
   ```bash
   npm run build
   # Deploy to hosting
   ```

3. Verify in production:
   ```bash
   curl https://coaching-api.railway.app/api/quiz/modules
   ```

## Files Reference

| File | Purpose |
|------|---------|
| `coaching-api/app/controllers/quiz_controller.py` | API endpoints |
| `coaching-api/app/services/quiz_service.py` | Database queries |
| `src/lib/quizApiClient.ts` | API client |
| `src/hooks/useQuiz.ts` | React hook |
| `docs/QUIZ_API_INTEGRATION.md` | Full documentation |
| `docs/QUIZ_API_USAGE_EXAMPLE.md` | Code examples |

## Next Steps

1. Start backend: `cd coaching-api && uvicorn app.main:app --reload`
2. Test endpoints: `./coaching-api/test_quiz_endpoints.sh`
3. Add hook to component: `const { questions, loadQuiz } = useQuiz()`
4. Render questions: `{questions.map(q => ...)}`
5. Deploy to staging
6. Test in staging environment
7. Deploy to production

## Support

- See `QUIZ_API_INTEGRATION.md` for detailed API documentation
- See `QUIZ_API_USAGE_EXAMPLE.md` for complete code examples
- Check `QUIZ_API_VERIFICATION.md` for implementation details
- FastAPI docs: `http://localhost:8000/docs`

---

**Quick Links:**
- [Full API Documentation](./docs/QUIZ_API_INTEGRATION.md)
- [Code Examples](./docs/QUIZ_API_USAGE_EXAMPLE.md)
- [Implementation Summary](./QUIZ_API_IMPLEMENTATION_SUMMARY.md)
- [Verification Checklist](./QUIZ_API_VERIFICATION.md)
