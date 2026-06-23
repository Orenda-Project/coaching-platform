/**
 * Admin Content API Client — CRUD for modules, trainings, content, assessments, questions.
 * Replaces direct Supabase calls in admin content pages.
 */

const API_URL = import.meta.env.VITE_API_URL || "http://localhost:8000";

// ===== Helper =====

async function apiFetch<T>(url: string, init?: RequestInit): Promise<T> {
  const res = await fetch(url, {
    headers: { "Content-Type": "application/json", ...init?.headers },
    ...init,
  });
  if (!res.ok) {
    const text = await res.text();
    throw new Error(`API ${res.status}: ${text}`);
  }
  if (res.status === 204) return undefined as unknown as T;
  return res.json();
}

// ===== Modules =====

export async function listModules() {
  return apiFetch<{ modules: Record<string, unknown>[] }>(`${API_URL}/api/admin/modules`);
}

export async function createModule(data: Record<string, unknown>) {
  return apiFetch<Record<string, unknown>>(`${API_URL}/api/admin/modules`, {
    method: "POST",
    body: JSON.stringify(data),
  });
}

export async function updateModule(moduleId: string, data: Record<string, unknown>) {
  return apiFetch<Record<string, unknown>>(`${API_URL}/api/admin/modules/${moduleId}`, {
    method: "PUT",
    body: JSON.stringify(data),
  });
}

export async function deleteModule(moduleId: string) {
  return apiFetch<void>(`${API_URL}/api/admin/modules/${moduleId}`, {
    method: "DELETE",
  });
}

// ===== Trainings =====

export async function listTrainings(moduleId?: string) {
  const qs = moduleId ? `?module_id=${moduleId}` : "";
  return apiFetch<{ trainings: Record<string, unknown>[] }>(`${API_URL}/api/admin/trainings${qs}`);
}

export async function createTraining(data: Record<string, unknown>) {
  return apiFetch<Record<string, unknown>>(`${API_URL}/api/admin/trainings`, {
    method: "POST",
    body: JSON.stringify(data),
  });
}

export async function updateTraining(trainingId: string, data: Record<string, unknown>) {
  return apiFetch<Record<string, unknown>>(`${API_URL}/api/admin/trainings/${trainingId}`, {
    method: "PUT",
    body: JSON.stringify(data),
  });
}

export async function deleteTraining(trainingId: string) {
  return apiFetch<void>(`${API_URL}/api/admin/trainings/${trainingId}`, {
    method: "DELETE",
  });
}

// ===== Training Content =====

export async function listTrainingContent(trainingId: string) {
  return apiFetch<{ content: Record<string, unknown>[] }>(
    `${API_URL}/api/admin/training-content?training_id=${trainingId}`
  );
}

export async function createTrainingContent(data: Record<string, unknown>) {
  return apiFetch<Record<string, unknown>>(`${API_URL}/api/admin/training-content`, {
    method: "POST",
    body: JSON.stringify(data),
  });
}

export async function deleteTrainingContent(contentId: string) {
  return apiFetch<void>(`${API_URL}/api/admin/training-content/${contentId}`, {
    method: "DELETE",
  });
}

// ===== Assessments =====

export async function listAssessments(opts?: { trainingId?: string; type?: string }) {
  const params = new URLSearchParams();
  if (opts?.trainingId) params.append("training_id", opts.trainingId);
  if (opts?.type) params.append("type", opts.type);
  const qs = params.toString();
  return apiFetch<{ assessments: Record<string, unknown>[] }>(
    `${API_URL}/api/admin/assessments${qs ? `?${qs}` : ""}`
  );
}

export async function createAssessment(data: Record<string, unknown>) {
  return apiFetch<Record<string, unknown>>(`${API_URL}/api/admin/assessments`, {
    method: "POST",
    body: JSON.stringify(data),
  });
}

export async function updateAssessment(assessmentId: string, data: Record<string, unknown>) {
  return apiFetch<Record<string, unknown>>(`${API_URL}/api/admin/assessments/${assessmentId}`, {
    method: "PUT",
    body: JSON.stringify(data),
  });
}

// ===== Questions =====

export async function getQuestions(assessmentId: string) {
  return apiFetch<{ questions: Record<string, unknown>[] }>(
    `${API_URL}/api/admin/assessments/${assessmentId}/questions`
  );
}

export async function bulkUpsertQuestions(
  assessmentId: string,
  questions: Record<string, unknown>[],
) {
  return apiFetch<{ questions: Record<string, unknown>[] }>(
    `${API_URL}/api/admin/assessments/${assessmentId}/questions`,
    {
      method: "PUT",
      body: JSON.stringify({ questions }),
    }
  );
}

export async function deleteQuestion(questionId: string) {
  return apiFetch<void>(`${API_URL}/api/admin/questions/${questionId}`, {
    method: "DELETE",
  });
}

// ===== File Upload =====

export async function uploadTrainingVideo(
  file: File,
  unitId: string,
): Promise<{ url: string }> {
  const formData = new FormData();
  formData.append("file", file);

  const res = await fetch(
    `${API_URL}/api/admin/upload?unit_id=${encodeURIComponent(unitId)}`,
    { method: "POST", body: formData },
  );
  if (!res.ok) {
    const text = await res.text();
    throw new Error(`Upload failed ${res.status}: ${text}`);
  }
  return res.json();
}
