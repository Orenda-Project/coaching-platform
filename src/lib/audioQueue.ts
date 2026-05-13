interface PendingAudioRecord {
  observation_id: string;
  blob: Blob;
  mime_type: string;
  queued_at: string;
  observer_id: string;
}

const DB_NAME = 'coaching_audio_queue';
const STORE_NAME = 'pending_uploads';
const uploadingNow = new Set<string>();

function openDB(): Promise<IDBDatabase> {
  return new Promise((resolve, reject) => {
    const request = indexedDB.open(DB_NAME, 1);

    request.onerror = () => reject(request.error);
    request.onsuccess = () => resolve(request.result);

    request.onupgradeneeded = (event) => {
      const db = (event.target as IDBOpenDBRequest).result;
      if (!db.objectStoreNames.contains(STORE_NAME)) {
        db.createObjectStore(STORE_NAME, { keyPath: 'observation_id' });
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
  } catch {
    console.error('Failed to save audio to queue:', Error);
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
  } catch {
    console.error('Failed to get pending audios:', Error);
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
  } catch {
    console.error('Failed to get pending audio:', Error);
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
  } catch {
    console.error('Failed to remove from queue:', Error);
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
