// Coaching Agent — network monitor + classifier.
// Attaches to a puppeteer page and records EVERY request/response, classifying
// each as content-api / supabase-auth / supabase-data / supabase-realtime /
// supabase-storage / other. Supabase *data* (rest/storage/functions) calls carry
// the Supabase anon "apikey" header — those are the requirement-1 violations to flag.
//
// Each captured entry is tagged with the active "phase" (set by the driver) so a
// finding can be attributed to the exact training action that triggered it.

export const REQUIRED_API = 'https://coaching-content-api-production.up.railway.app/api/coaching/teachers';
export const CONTENT_API_HOST = 'coaching-content-api-production.up.railway.app';

export function classify(url) {
  let host = '';
  try { host = new URL(url).host; } catch { return 'other'; }
  if (host === CONTENT_API_HOST) return 'content-api';
  if (/\.supabase\.co$/.test(host) || /supabase/.test(host)) {
    if (/\/auth\/v1\//.test(url)) return 'supabase-auth';
    if (/\/realtime\/v1\//.test(url)) return 'supabase-realtime';
    if (/\/rest\/v1\//.test(url)) return 'supabase-data';
    if (/\/storage\/v1\//.test(url)) return 'supabase-storage';
    if (/\/functions\/v1\//.test(url)) return 'supabase-functions';
    return 'supabase-other';
  }
  return 'other';
}

const redactKey = (k) => (k ? `${k.slice(0, 8)}…${k.slice(-6)} (len ${k.length})` : null);

export function createMonitor() {
  const entries = [];
  let phase = 'init';
  const setPhase = (p) => { phase = p; };

  function attach(page) {
    page.on('request', (req) => {
      const url = req.url();
      const cat = classify(url);
      // Ignore static asset noise from the app's own origin / CDNs.
      if (cat === 'other') {
        const rt = req.resourceType();
        if (['image', 'stylesheet', 'font', 'media', 'script', 'other', 'manifest'].includes(rt)) return;
      }
      const headers = req.headers();
      const apikey = headers['apikey'] || headers['x-api-key'] || null;
      const auth = headers['authorization'] || null;
      let post = req.postData() || null;
      if (post && post.length > 2000) post = post.slice(0, 2000) + `…[+${post.length - 2000}b]`;
      entries.push({
        t: 'req',
        phase,
        cat,
        method: req.method(),
        url,
        resourceType: req.resourceType(),
        hasApikey: !!apikey,
        apikeyRedacted: redactKey(apikey),
        hasAuthHeader: !!auth,
        authKind: auth ? (/^Bearer /.test(auth) ? 'Bearer-JWT' : auth.split(' ')[0]) : null,
        postData: post,
      });
    });

    page.on('response', async (res) => {
      const url = res.url();
      const cat = classify(url);
      if (cat === 'other') return; // only keep API/supabase response bodies
      let body = null;
      const ct = (res.headers()['content-type'] || '');
      if (/json/.test(ct)) {
        try {
          const txt = await res.text();
          body = txt.length > 6000 ? txt.slice(0, 6000) + `…[+${txt.length - 6000}b]` : txt;
        } catch { body = '<unreadable>'; }
      }
      entries.push({ t: 'res', phase, cat, status: res.status(), url, contentType: ct, body });
    });
  }

  const supabaseDataHits = () =>
    entries.filter((e) => e.t === 'req' && /^supabase-(data|storage|functions)$/.test(e.cat));
  const apikeyHits = () =>
    entries.filter((e) => e.t === 'req' && e.hasApikey);
  const contentApiReqs = () =>
    entries.filter((e) => e.t === 'req' && e.cat === 'content-api');

  function summary() {
    const byCat = {};
    for (const e of entries) if (e.t === 'req') byCat[e.cat] = (byCat[e.cat] || 0) + 1;
    return {
      totalRequests: entries.filter((e) => e.t === 'req').length,
      byCategory: byCat,
      supabaseDataCalls: supabaseDataHits().length,
      contentApiCalls: contentApiReqs().length,
    };
  }

  return { attach, setPhase, entries, summary, supabaseDataHits, apikeyHits, contentApiReqs };
}
