/**
 * Quiz API Client - Communicates with FastAPI backend
 * Handles question fetching, caching, and error handling
 */

export interface QuizOption {
  id: string;
  letter: string;
  text: string;
  is_correct: boolean;
  rationale?: string;
}

export interface QuizQuestion {
  id: string;
  question_type: "mcq" | "scenario";
  question_text: string;
  situation?: string; // for scenarios
  difficulty?: string; // for scenarios
  order_number?: number;
  options: QuizOption[];
}

export interface QuizModule {
  id: string;
  title: string;
  description?: string;
  order_number: number;
  mcq_count: number;
  scenario_count: number;
  total_questions: number;
}

export interface QuizModulesResponse {
  modules: QuizModule[];
  total_modules: number;
  export_metadata: {
    version: string;
    exported_at: string;
  };
}

export interface ModuleQuestionsResponse {
  module_id: string;
  mcq_count: number;
  scenario_count: number;
  total_questions: number;
  mcq: QuizQuestion[];
  scenarios: QuizQuestion[];
}

export interface RandomizedQuizResponse {
  module_id: string;
  total_questions: number;
  mcq_selected: number;
  scenarios_selected: number;
  questions: QuizQuestion[];
  export_metadata: {
    version: string;
    exported_at: string;
  };
}

export class QuizApiClient {
  private apiUrl: string;
  private cache: Map<string, unknown> = new Map();

  constructor(apiUrl?: string) {
    this.apiUrl = apiUrl || import.meta.env.VITE_QUIZ_API_URL || "http://localhost:8000";
  }

  /**
   * Get all quiz modules with question counts
   */
  async getModules(): Promise<QuizModule[]> {
    const cacheKey = "modules";

    if (this.cache.has(cacheKey)) {
      return this.cache.get(cacheKey) as QuizModule[];
    }

    try {
      const response = await this.fetchWithRetry(`${this.apiUrl}/api/quiz/modules`);
      const data: QuizModulesResponse = await response.json();

      this.cache.set(cacheKey, data.modules);
      return data.modules;
    } catch (error) {
      console.error("[QuizApiClient] Error fetching modules:", error);
      throw new Error(`Failed to fetch quiz modules: ${error instanceof Error ? error.message : "Unknown error"}`);
    }
  }

  /**
   * Get all questions (MCQ and scenarios) for a specific module
   */
  async getModuleQuestions(moduleId: string): Promise<ModuleQuestionsResponse> {
    const cacheKey = `module_questions_${moduleId}`;

    if (this.cache.has(cacheKey)) {
      return this.cache.get(cacheKey) as ModuleQuestionsResponse;
    }

    try {
      const response = await this.fetchWithRetry(`${this.apiUrl}/api/quiz/module/${moduleId}/questions`);

      if (response.status === 404) {
        throw new Error(`Module ${moduleId} not found`);
      }

      const data: ModuleQuestionsResponse = await response.json();

      this.cache.set(cacheKey, data);
      return data;
    } catch (error) {
      console.error(`[QuizApiClient] Error fetching questions for module ${moduleId}:`, error);
      throw new Error(
        `Failed to fetch questions for module ${moduleId}: ${error instanceof Error ? error.message : "Unknown error"}`
      );
    }
  }

  /**
   * Get randomized quiz (16 MCQ + 4 scenarios) for a module
   */
  async getRandomizedQuiz(moduleId: string): Promise<QuizQuestion[]> {
    // Don't cache randomized quiz - always fetch fresh
    try {
      const response = await this.fetchWithRetry(`${this.apiUrl}/api/quiz/module/${moduleId}/random`);

      if (response.status === 404) {
        throw new Error(`Module ${moduleId} not found`);
      }

      const data: RandomizedQuizResponse = await response.json();

      return data.questions;
    } catch (error) {
      console.error(`[QuizApiClient] Error fetching randomized quiz for module ${moduleId}:`, error);
      throw new Error(
        `Failed to fetch randomized quiz for module ${moduleId}: ${error instanceof Error ? error.message : "Unknown error"}`
      );
    }
  }

  /**
   * Clear cache
   */
  clearCache(): void {
    this.cache.clear();
  }

  /**
   * Fetch with exponential backoff retry logic
   * Retries on network errors and 5xx server errors
   */
  private async fetchWithRetry(
    url: string,
    options?: RequestInit,
    maxRetries: number = 3,
    baseDelay: number = 1000
  ): Promise<Response> {
    let lastError: Error | null = null;

    for (let attempt = 0; attempt < maxRetries; attempt++) {
      try {
        const response = await fetch(url, {
          ...options,
          headers: {
            "Content-Type": "application/json",
            ...options?.headers,
          },
        });

        // Don't retry 4xx errors (client errors)
        if (response.status >= 400 && response.status < 500) {
          return response;
        }

        // Retry 5xx errors
        if (response.status >= 500 && attempt < maxRetries - 1) {
          const delay = baseDelay * Math.pow(2, attempt);
          await this.sleep(delay);
          continue;
        }

        return response;
      } catch (error) {
        lastError = error instanceof Error ? error : new Error(String(error));

        // Retry on network errors
        if (attempt < maxRetries - 1) {
          const delay = baseDelay * Math.pow(2, attempt);
          await this.sleep(delay);
          continue;
        }
      }
    }

    throw lastError || new Error("Failed to fetch after maximum retries");
  }

  /**
   * Sleep utility for retry delays
   */
  private sleep(ms: number): Promise<void> {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }
}

// Export singleton instance
export const quizApiClient = new QuizApiClient();
