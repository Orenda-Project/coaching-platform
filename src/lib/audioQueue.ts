interface PendingAudioRecord {
  observation_id: string;
  blob: Blob;
  mime_type: string;
  queued_at: string;
  observer_id: string;
}

interface SavedAudioRecord {
  observation_id: string;
  blob: Blob;
  mime_type: string;
  saved_at: string;
}

const DB_NAME = 'coaching_audio_queue';
const STORE_NAME = 'pending_uploads';
const SAVED_AUDIO_STORE = 'saved_audio';

// In-memory lock set to prevent concurrent uploads of the same observation within this tab.
// NOTE: This is per-tab only and does not prevent duplicates across multiple browser tabs.
// For cross-tab safety, consider using Web Locks API or an IndexedDB-backed sentinel.
const uploadingNow = new Set<string>();

function openDB(): Promise<IDBDatabase> {
  return new Promise((resolve, reject) => {
    const request = indexedDB.open(DB_NAME, 2);

    request.onerror = () => reject(request.error);
    request.onsuccess = () => resolve(request.result);

    request.onupgradeneeded = (event) => {
      const db = (event.target as IDBOpenDBRequest).result;
      if (!db.objectStoreNames.contains(STORE_NAME)) {
        db.createObjectStore(STORE_NAME, { keyPath: 'observation_id' });
      }
      if (!db.objectStoreNames.contains(SAVED_AUDIO_STORE)) {
        db.createObjectStore(SAVED_AUDIO_STORE, { keyPath: 'observation_id' });
      }
    };
  });
}

export async function saveAudioToQueue(record: PendingAudioRecord): Promise<void> {
  try {
    const db = await openDB();
    const store = db.transaction(STORE_NAME, 'readwrite').objectStore(STORE_NAME);
    return new Promise((resolve, reject) => {
      const request = store.put(record);
      request.onerror = () => reject(request.error);
      request.onsuccess = () => resolve();
    });
  } catch (e) {
    console.error('Failed to save audio to queue:', e);
  }
}

export async function getPendingAudios(): Promise<PendingAudioRecord[]> {
  try {
    const db = await openDB();
    const store = db.transaction(STORE_NAME, 'readonly').objectStore(STORE_NAME);
    return new Promise((resolve, reject) => {
      const request = store.getAll();
      request.onerror = () => reject(request.error);
      request.onsuccess = () => resolve((request.result as PendingAudioRecord[]) || []);
    });
  } catch (e) {
    console.error('Failed to get pending audios:', e);
    return [];
  }
}

export async function getPendingAudio(observation_id: string): Promise<PendingAudioRecord | undefined> {
  try {
    const db = await openDB();
    const store = db.transaction(STORE_NAME, 'readonly').objectStore(STORE_NAME);
    return new Promise((resolve, reject) => {
      const request = store.get(observation_id);
      request.onerror = () => reject(request.error);
      request.onsuccess = () => resolve(request.result as PendingAudioRecord | undefined);
    });
  } catch (e) {
    console.error('Failed to get pending audio:', e);
    return undefined;
  }
}

export async function removeFromQueue(observation_id: string): Promise<void> {
  try {
    const db = await openDB();
    const store = db.transaction(STORE_NAME, 'readwrite').objectStore(STORE_NAME);
    return new Promise((resolve, reject) => {
      const request = store.delete(observation_id);
      request.onerror = () => reject(request.error);
      request.onsuccess = () => resolve();
    });
  } catch (e) {
    console.error('Failed to remove from queue:', e);
  }
}

export function lockForUpload(obs_id: string): boolean {
  if (uploadingNow.has(obs_id)) return false;
  uploadingNow.add(obs_id);
  return true;
}

export function unlockUpload(obs_id: string): void {
  uploadingNow.delete(obs_id);
}

export async function saveSavedAudio(observation_id: string, blob: Blob, mime_type: string = 'audio/webm'): Promise<void> {
  try {
    const db = await openDB();
    const store = db.transaction(SAVED_AUDIO_STORE, 'readwrite').objectStore(SAVED_AUDIO_STORE);
    return new Promise((resolve, reject) => {
      const request = store.put({
        observation_id,
        blob,
        mime_type,
        saved_at: new Date().toISOString(),
      });
      request.onerror = () => reject(request.error);
      request.onsuccess = () => resolve();
    });
  } catch (e) {
    console.error('Failed to save audio:', e);
  }
}

export async function getSavedAudio(observation_id: string): Promise<{ blob: Blob; mime_type: string } | undefined> {
  try {
    const db = await openDB();
    const store = db.transaction(SAVED_AUDIO_STORE, 'readonly').objectStore(SAVED_AUDIO_STORE);
    return new Promise((resolve, reject) => {
      const request = store.get(observation_id);
      request.onerror = () => reject(request.error);
      request.onsuccess = () => {
        const result = request.result as SavedAudioRecord | undefined;
        resolve(result ? { blob: result.blob, mime_type: result.mime_type } : undefined);
      };
    });
  } catch (e) {
    console.error('Failed to get saved audio:', e);
    return undefined;
  }
}

export async function deleteSavedAudio(observation_id: string): Promise<void> {
  try {
    const db = await openDB();
    const store = db.transaction(SAVED_AUDIO_STORE, 'readwrite').objectStore(SAVED_AUDIO_STORE);
    return new Promise((resolve, reject) => {
      const request = store.delete(observation_id);
      request.onerror = () => reject(request.error);
      request.onsuccess = () => resolve();
    });
  } catch (e) {
    console.error('Failed to delete saved audio:', e);
  }
}
