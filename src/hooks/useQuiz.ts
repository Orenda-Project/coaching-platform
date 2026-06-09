import { useState, useCallback } from "react";
import { quizApiClient, QuizQuestion, QuizModule } from "@/lib/quizApiClient";

export interface UseQuizReturn {
  questions: QuizQuestion[];
  modules: QuizModule[];
  loading: boolean;
  error: string | null;
  loadQuiz: (moduleId: string) => Promise<void>;
  loadModules: () => Promise<void>;
  clearError: () => void;
}

/**
 * Custom hook to manage quiz data fetching and state
 * Handles loading, error, and caching
 */
export function useQuiz(): UseQuizReturn {
  const [questions, setQuestions] = useState<QuizQuestion[]>([]);
  const [modules, setModules] = useState<QuizModule[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  /**
   * Load modules with question counts
   */
  const loadModules = useCallback(async () => {
    setLoading(true);
    setError(null);

    try {
      const modulesData = await quizApiClient.getModules();
      setModules(modulesData);
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : "Failed to load modules";
      setError(errorMessage);
      console.error("[useQuiz] Error loading modules:", err);
    } finally {
      setLoading(false);
    }
  }, []);

  /**
   * Load randomized quiz for a specific module (16 MCQ + 4 scenarios)
   */
  const loadQuiz = useCallback(async (moduleId: string) => {
    if (!moduleId) {
      setError("Module ID is required");
      return;
    }

    setLoading(true);
    setError(null);

    try {
      const questionsData = await quizApiClient.getRandomizedQuiz(moduleId);
      setQuestions(questionsData);
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : "Failed to load quiz";
      setError(errorMessage);
      console.error(`[useQuiz] Error loading quiz for module ${moduleId}:`, err);
    } finally {
      setLoading(false);
    }
  }, []);

  /**
   * Clear error state
   */
  const clearError = useCallback(() => {
    setError(null);
  }, []);

  return {
    questions,
    modules,
    loading,
    error,
    loadQuiz,
    loadModules,
    clearError,
  };
}

/**
 * Custom hook specifically for loading all questions for a module (not randomized)
 * Useful for debugging or admin views
 */
export function useQuizAllQuestions(moduleId?: string) {
  const [questions, setQuestions] = useState<QuizQuestion[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const loadAllQuestions = useCallback(
    async (id?: string) => {
      const targetId = id || moduleId;
      if (!targetId) {
        setError("Module ID is required");
        return;
      }

      setLoading(true);
      setError(null);

      try {
        const data = await quizApiClient.getModuleQuestions(targetId);
        // Combine MCQ and scenarios
        const allQuestions = [...data.mcq, ...data.scenarios];
        setQuestions(allQuestions);
      } catch (err) {
        const errorMessage = err instanceof Error ? err.message : "Failed to load questions";
        setError(errorMessage);
        console.error("[useQuizAllQuestions] Error loading questions:", err);
      } finally {
        setLoading(false);
      }
    },
    [moduleId]
  );

  const clearError = useCallback(() => {
    setError(null);
  }, []);

  return {
    questions,
    loading,
    error,
    loadAllQuestions,
    clearError,
  };
}
