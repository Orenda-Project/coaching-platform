import { scheduleVisit } from '@/data/observations';
import type { ScheduleVisitPayload } from '@/data/observations';
import type { CotObservation } from '@/types/observation';

export interface PendingVisit {
  localId: string;
  payload: ScheduleVisitPayload;
  queuedAt: string;
}

const QUEUE_KEY = (userId: string) => `punjab_offline_queue_${userId}`;

function readQueue(userId: string): PendingVisit[] {
  try {
    const raw = localStorage.getItem(QUEUE_KEY(userId));
    return raw ? (JSON.parse(raw) as PendingVisit[]) : [];
  } catch {
    return [];
  }
}

function writeQueue(userId: string, queue: PendingVisit[]): void {
  try {
    localStorage.setItem(QUEUE_KEY(userId), JSON.stringify(queue));
  } catch {
    // localStorage full — can't queue
  }
}

export function queueVisit(userId: string, payload: ScheduleVisitPayload): PendingVisit {
  const pending: PendingVisit = {
    localId: `local_${Date.now()}_${Math.random().toString(36).slice(2, 7)}`,
    payload,
    queuedAt: new Date().toISOString(),
  };
  const queue = readQueue(userId);
  queue.push(pending);
  writeQueue(userId, queue);
  return pending;
}

export function getPendingVisits(userId: string): PendingVisit[] {
  return readQueue(userId);
}

export function markSynced(userId: string, localId: string): void {
  const queue = readQueue(userId).filter(v => v.localId !== localId);
  writeQueue(userId, queue);
}

export async function syncPendingVisits(userId: string): Promise<{ synced: number; failed: number }> {
  const queue = readQueue(userId);
  if (queue.length === 0) return { synced: 0, failed: 0 };

  let synced = 0;
  let failed = 0;

  for (const pending of queue) {
    try {
      await scheduleVisit(pending.payload);
      markSynced(userId, pending.localId);
      synced++;
    } catch {
      failed++;
    }
  }

  return { synced, failed };
}

// Creates a minimal CotObservation from a pending visit so the UI can show it immediately
export function makePseudoObservation(pending: PendingVisit): CotObservation {
  const p = pending.payload;
  return {
    id: pending.localId,
    observer_id: p.observer_id,
    school_name: p.school_name,
    teacher_name: p.teacher_name,
    region: p.region,
    subject: p.subject ?? '',
    grade: p.grade ?? '',
    topic: p.topic ?? null,
    date: p.date,
    total_score: 0,
    hots_rubric: {},
    status: 'Scheduled',
    visit_type: p.visit_type ?? null,
    planned_date: p.planned_date ?? null,
    arrival_time: p.arrival_time ?? null,
    departure_time: p.departure_time ?? null,
    week: p.week ?? null,
    created_at: pending.queuedAt,
    updated_at: pending.queuedAt,
  };
}
