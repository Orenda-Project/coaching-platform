// Coaching Agent — shared driver library
// Reusable, HEADED-by-default, fast-startup browser driver + learning store.
//
// Design goals (per agent spec):
//   1. HEADED by default — a visible Chrome window opens immediately so the run
//      can be watched. Set HEADLESS=1 to opt into headless (only when requested).
//   2. Fast startup — no networkidle waits, no blanket sleeps; we launch the
//      browser first, navigate with `domcontentloaded`, then wait for the exact
//      element/condition we need. Lean Chrome launch flags trim init overhead.
//   3. Persistent learning — baseline completion is cached in baseline-completion.json
//      so future runs can skip the full baseline flow for already-completed users.

import puppeteer from 'puppeteer';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
export const SKILL_DIR = path.resolve(__dirname, '..');
export const EVID_DIR = path.join(__dirname, 'evidence');
export const COMPLETION_STORE = path.join(SKILL_DIR, 'baseline-completion.json');

export const APP = 'https://coaching-platform-staging.up.railway.app';
export const HEADLESS = process.env.HEADLESS === '1' || process.env.HEADLESS === 'true';

export const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

// ---------------------------------------------------------------------------
// Browser — headed by default, launched immediately with lean flags.
// ---------------------------------------------------------------------------
export async function launchBrowser() {
  const t0 = Date.now();
  const browser = await puppeteer.launch({
    headless: HEADLESS ? 'new' : false, // HEADED unless HEADLESS=1
    defaultViewport: null, // use the real OS window — no extra emulation overhead
    args: [
      '--no-sandbox',
      '--disable-setuid-sandbox',
      '--no-first-run',
      '--no-default-browser-check',
      '--disable-extensions',
      '--disable-sync',
      '--disable-background-networking',
      '--disable-background-timer-throttling',
      '--disable-default-apps',
      '--disable-component-update',
      '--metrics-recording-only',
      '--mute-audio',
      '--start-maximized',
    ],
  });
  console.log(`[startup] browser ready in ${Date.now() - t0}ms (${HEADLESS ? 'headless' : 'HEADED'})`);
  return browser;
}

// Fast navigation: domcontentloaded only (no networkidle). Caller waits for the
// concrete element it needs via waitText / waitForSelector.
export async function open(page, urlPath) {
  await page.goto(APP + urlPath, { waitUntil: 'domcontentloaded' });
}

// Wait for a body-text condition (replaces arbitrary sleeps).
export async function waitText(page, re, timeout = 15000) {
  const src = re.source;
  const flags = re.flags;
  await page
    .waitForFunction((s, f) => new RegExp(s, f).test(document.body.innerText), { timeout }, src, flags)
    .catch(() => {});
}

export async function clickByText(page, sel, re) {
  for (const el of await page.$$(sel)) {
    const t = (await page.evaluate((e) => e.textContent, el) || '').trim();
    if (re.test(t)) {
      await el.click();
      return t;
    }
  }
  return null;
}

export async function bodyText(page) {
  return page.evaluate(() => document.body.innerText);
}

// Inspect a button by its visible text: { exists, text, disabled, handle }.
export async function btnInfo(page, re) {
  for (const el of await page.$$('button')) {
    const t = (await page.evaluate((e) => e.textContent, el) || '').trim();
    if (re.test(t)) {
      const disabled = await page.evaluate(
        (e) => e.disabled || e.getAttribute('aria-disabled') === 'true', el);
      return { exists: true, text: t, disabled, handle: el };
    }
  }
  return { exists: false, text: '', disabled: false, handle: null };
}

// Capture transient toast messages into window.__toasts (set BEFORE navigation).
export async function setupToastObserver(page) {
  await page.evaluateOnNewDocument(() => {
    window.__toasts = [];
    const start = () => {
      try {
        const obs = new MutationObserver((muts) => {
          for (const m of muts)
            for (const n of m.addedNodes)
              if (n.nodeType === 1) {
                const t = (n.innerText || n.textContent || '').trim();
                if (t && t.length < 400) window.__toasts.push(t);
              }
        });
        obs.observe(document.body, { childList: true, subtree: true });
      } catch {}
    };
    if (document.body) start();
    else document.addEventListener('DOMContentLoaded', start);
  });
}

// Poll captured toasts for one matching `re` within `ms`. Returns the text or null.
export async function waitToast(page, re, ms = 6000) {
  const end = Date.now() + ms;
  while (Date.now() < end) {
    const hit = (await page.evaluate(() => window.__toasts || [])).find((t) => re.test(t));
    if (hit) return hit;
    await sleep(250);
  }
  return null;
}

// Create a fresh account. Returns the new user's id (from the auth token) or null.
export async function signup(page, creds) {
  const t0 = Date.now();
  await open(page, '/signup');
  await page.waitForSelector('#fullName', { visible: true, timeout: 15000 });
  await page.type('#fullName', creds.name);
  await page.type('#email', creds.email);
  await page.type('#phone', creds.phone);
  await page.type('#password', creds.pass);
  await clickByText(page, 'button', /create account/i);
  // Wait until the auth token appears (session established) — no fixed sleep.
  await page
    .waitForFunction(() => Object.keys(localStorage).some((k) => /sb-.*-auth-token/.test(k)), { timeout: 20000 })
    .catch(() => {});
  const id = await currentUserId(page);
  console.log(`[startup] signup complete in ${Date.now() - t0}ms (userId=${id})`);
  return id;
}

// ---------------------------------------------------------------------------
// Login — fast: domcontentloaded, no fixed sleeps, waits on the URL change.
// ---------------------------------------------------------------------------
export async function login(page, creds) {
  const t0 = Date.now();
  await open(page, '/login');
  await page.waitForSelector('input[type=email]', { visible: true, timeout: 15000 });
  await page.type('input[type=email]', creds.email);
  await page.type('input[type=password]', creds.pass);
  await clickByText(page, 'button', /sign in/i);
  // Wait until we leave /login (authenticated) rather than sleeping a fixed time.
  await page
    .waitForFunction(() => !/\/login$/.test(location.pathname), { timeout: 20000 })
    .catch(() => {});
  console.log(`[startup] login complete in ${Date.now() - t0}ms -> ${page.url()}`);
  return page.url();
}

export async function currentUserId(page) {
  return page.evaluate(() => {
    for (const k of Object.keys(localStorage)) {
      if (/sb-.*-auth-token/.test(k)) {
        try {
          return JSON.parse(localStorage.getItem(k)).user?.id ?? null;
        } catch {}
      }
    }
    return null;
  });
}

// ---------------------------------------------------------------------------
// Learning store — baseline completion cache.
// ---------------------------------------------------------------------------
export function loadCompletion() {
  try {
    const raw = fs.readFileSync(COMPLETION_STORE, 'utf8');
    const data = JSON.parse(raw);
    return Array.isArray(data.users) ? data : { users: [] };
  } catch {
    return { users: [] };
  }
}

export function getBaselineRecord(email) {
  const { users } = loadCompletion();
  return users.find((u) => u.email?.toLowerCase() === email.toLowerCase()) || null;
}

export function isBaselineCompleted(email) {
  const rec = getBaselineRecord(email);
  return !!(rec && rec.baselineCompleted);
}

export function recordBaselineCompletion({ email, userId, persona, score, source }) {
  const store = loadCompletion();
  const today = new Date().toISOString().slice(0, 10);
  const existing = store.users.find((u) => u.email?.toLowerCase() === email.toLowerCase());
  const patch = {
    email,
    userId: userId ?? existing?.userId ?? null,
    baselineCompleted: true,
    persona: persona ?? existing?.persona ?? null,
    score: score ?? existing?.score ?? null,
    recordedAt: today,
    source: source ?? 'observed (live run)',
  };
  if (existing) Object.assign(existing, patch);
  else store.users.push(patch);
  fs.mkdirSync(path.dirname(COMPLETION_STORE), { recursive: true });
  fs.writeFileSync(COMPLETION_STORE, JSON.stringify(store, null, 2));
  return patch;
}

export function ensureEvidenceDir() {
  fs.mkdirSync(EVID_DIR, { recursive: true });
  return EVID_DIR;
}
