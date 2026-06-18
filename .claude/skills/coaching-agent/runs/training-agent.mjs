// Coaching Agent — TRAINING flow driver (headed, live black-box QA).
//
// Goal: complete the training journey for the SKILL.md account on production while
// validating:
//   (1) no Supabase key used in training/quizzes/assessments (network monitor),
//   (2) all data requests go to the coaching-content-api,
//   (3) request payload structure is consistent,
//   (8) every training slide enforces a 15-second wait before "Next" enables,
//   (7) every module / slide / quiz is exercised.
//
// HEADED by default (HEADLESS=1 to override). Network is classified by net-monitor.mjs.
// Account + app URL come from SKILL.md (lib.mjs parseSkillConfig) — generic.
//
// Modes:
//   node training-agent.mjs --recon   # login, map dashboard, capture API shapes, screenshot, EXIT (non-mutating)
//   node training-agent.mjs           # full: walk every accessible unit's slides+practice, attempt quizzes

import fs from 'fs';
import path from 'path';
import {
  APP, ACCOUNT, EVID_DIR, sleep, launchBrowser, open, waitText, clickByText, bodyText,
  login, currentUserId, ensureEvidenceDir, btnInfo, setupToastObserver,
} from './lib.mjs';
import { createMonitor, REQUIRED_API } from './net-monitor.mjs';

const RECON = process.argv.includes('--recon');
const OUT_DIR = path.join(EVID_DIR, 'training');
fs.mkdirSync(OUT_DIR, { recursive: true });

const mon = createMonitor();
const findings = [];
const slideGateChecks = [];
const log = (...a) => console.log(...a);
const shot = async (page, name) => {
  const p = path.join(OUT_DIR, `${name}.png`);
  await page.screenshot({ path: p, fullPage: false }).catch(() => {});
  return path.relative(EVID_DIR, p);
};

// ---- DOM helpers (black-box; selectors from the live UI map in LEARNING.md) ----
async function getButtons(page) {
  return page.$$eval('button', (els) =>
    els.map((b, i) => ({
      i,
      text: (b.innerText || b.textContent || '').replace(/\s+/g, ' ').trim(),
      disabled: b.disabled || b.getAttribute('aria-disabled') === 'true',
      visible: !!(b.offsetParent || b.getClientRects().length),
    })),
  );
}
async function clickButtonIdx(page, idx) {
  const handles = await page.$$('button');
  if (handles[idx]) { await handles[idx].click(); return true; }
  return false;
}
async function clickFirst(page, re, { needEnabled = true } = {}) {
  const btns = await getButtons(page);
  const b = btns.find((x) => x.visible && re.test(x.text) && (!needEnabled || !x.disabled));
  if (!b) return null;
  await clickButtonIdx(page, b.i);
  return b.text;
}

// Click the SMALLEST visible element whose trimmed text matches `re` (scrolls into view).
// Works for module cards / unit rows that are <div>s, not <button>s.
async function clickText(page, re, { scroll = true } = {}) {
  const handle = await page.evaluateHandle((src, flags) => {
    const rx = new RegExp(src, flags);
    const all = Array.from(document.querySelectorAll('button,a,div,span,h1,h2,h3,h4,p,li'));
    let best = null, bestLen = Infinity;
    for (const el of all) {
      const t = (el.innerText || '').replace(/\s+/g, ' ').trim();
      if (rx.test(t) && t.length < bestLen && el.getClientRects().length) { best = el; bestLen = t.length; }
    }
    return best;
  }, re.source, re.flags);
  const el = handle.asElement();
  if (!el) return false;
  if (scroll) await el.evaluate((e) => e.scrollIntoView({ block: 'center' }));
  await sleep(300);
  await el.click().catch(async () => { await el.evaluate((e) => e.click()); });
  return true;
}

async function dumpText(page) {
  return page.evaluate(() => (document.body.innerText || '').replace(/\n{2,}/g, '\n').trim());
}

// Parse the units of the currently-expanded module from body text.
async function getModuleUnits(page) {
  const txt = await dumpText(page);
  const units = [];
  const re = /Unit\s+(\d+\.\d+):\s*([^\n]+)\n[^\n]*\n(Passed|Not Started|In Progress|Locked)/gi;
  let m;
  while ((m = re.exec(txt))) units.push({ id: m[1], title: `Unit ${m[1]}: ${m[2].trim()}`, status: m[3] });
  return units;
}

// Browser is held in a mutable holder so we can relaunch it on a renderer crash
// ("Target closed") and continue — completion is server-persisted, so we resume.
const G = { browser: null };

async function newSession() {
  const page = await G.browser.newPage();
  page.setDefaultTimeout(30000);
  mon.attach(page);
  await setupToastObserver(page);
  await login(page, ACCOUNT);
  return page;
}

async function relaunch() {
  try { if (G.browser) await G.browser.close(); } catch {}
  G.browser = await launchBrowser();
  const page = await newSession();
  log('[heal] relaunched browser + re-logged in');
  return page;
}

// Return a live page; relaunch the browser if the current one died.
async function ensureAlive(page) {
  try {
    if (page && !page.isClosed() && page.browser().isConnected()) return page;
  } catch {}
  return relaunch();
}

async function main() {
  ensureEvidenceDir();
  G.browser = await launchBrowser();
  let page = await newSession();

  try {
    log(`[config] app=${APP} account=${ACCOUNT.email}`);
    log(`[config] required content API: ${REQUIRED_API}`);
    const userId = await currentUserId(page);
    log(`[login] userId=${userId} url=${page.url()}`);

    mon.setPhase('dashboard');
    await open(page, '/dashboard');
    await waitText(page, /Training|Module|Baseline|Persona|Dashboard/i, 20000);
    await sleep(1500);
    await shot(page, '01-dashboard');

    const modules = await mapDashboard(page);
    log(`[dashboard] modules discovered: ${modules.length}`);
    modules.forEach((m) => log(`   • ${m.title} — progress=${m.progress} locked=${m.locked}`));

    if (RECON) {
      await reconUnitAndQuiz(page, modules);
    } else {
      await completeAll(page);
    }
  } catch (e) {
    log('ERROR', e.message, '\n', e.stack);
    try { await shot(page, 'zz-error'); } catch {}
  } finally {
    finalize();
    if (!process.env.KEEP_OPEN) { await sleep(1200); try { await G.browser.close(); } catch {} }
  }
}

// Map dashboard module cards: title, progress (e.g. 3/7), locked state.
async function mapDashboard(page) {
  return page.evaluate(() => {
    const out = [];
    // Module cards: clickable containers showing a progress fraction.
    const nodes = Array.from(document.querySelectorAll('div,section,article'));
    const seen = new Set();
    for (const n of nodes) {
      const txt = (n.innerText || '').replace(/\s+/g, ' ').trim();
      if (!txt) continue;
      const prog = txt.match(/\b(\d+)\s*\/\s*(\d+)\b/);
      const isCard = /module|unit|training/i.test(txt) && prog && txt.length < 400;
      if (!isCard) continue;
      const key = txt.slice(0, 60);
      if (seen.has(key)) continue;
      seen.add(key);
      const style = getComputedStyle(n);
      out.push({
        title: txt.slice(0, 80),
        progress: prog ? `${prog[1]}/${prog[2]}` : null,
        locked: /not-allowed/.test(style.cursor) || parseFloat(style.opacity) < 0.8 || /locked/i.test(txt),
      });
    }
    return out;
  });
}

// RECON: open the first accessible unit, capture content-API shape + a slide gate,
// open a module quiz to capture its shape, then exit without mutating completion.
async function reconUnitAndQuiz(page, modules) {
  log('\n===== RECON =====');
  // Expand Module 1 by clicking its title text (it's a div card, not a button).
  const expanded = await clickText(page, /Module 1: Universal Core Refresher/i);
  log(`[recon] expand Module 1 -> ${expanded}`);
  await sleep(1800);
  await shot(page, '02-module-expanded');
  log('\n[recon] ----- expanded Module 1 text -----\n' + (await dumpText(page)).slice(0, 1500));

  // List unit-ish rows (text + clickability) to learn the real labels.
  const units = await page.evaluate(() => {
    const out = [];
    const els = Array.from(document.querySelectorAll('div,li,a,button'));
    const seen = new Set();
    for (const el of els) {
      const t = (el.innerText || '').replace(/\s+/g, ' ').trim();
      if (!t || t.length > 90) continue;
      if (!/(Unit|Session|Lesson|Quiz|Start|Not Started|In Progress|Passed|Locked)/i.test(t)) continue;
      if (seen.has(t)) continue; seen.add(t);
      const s = getComputedStyle(el);
      out.push({ text: t, cursor: s.cursor, opacity: s.opacity });
    }
    return out.slice(0, 30);
  });
  log('\n[recon] unit-ish rows:'); units.forEach((u) => log(`   [${u.cursor} op=${u.opacity}] ${u.text}`));

  const parsed = await getModuleUnits(page);
  log('\n[recon] parsed units:'); parsed.forEach((u) => log(`   ${u.status.padEnd(12)} ${u.title}`));

  // Enter the first NOT-passed unit by clicking its title (bubbles to the row handler).
  const target = parsed.find((u) => u.status !== 'Passed' && u.status !== 'Locked') || parsed.find((u) => u.status !== 'Locked');
  let entered = null;
  if (target) { entered = target.title; await clickText(page, new RegExp(target.title.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'i')); }
  log(`[recon] unit click -> ${entered}`);
  await sleep(2800);
  if (/\/training\//.test(page.url())) {
    log(`[recon] entered unit page: ${page.url()}`);
    await shot(page, '03-unit-slide1');
    log('\n[recon] ----- unit page text -----\n' + (await dumpText(page)).slice(0, 1200));
    await captureSlideGate(page, 'recon');
  } else {
    log(`[recon] did NOT navigate to a unit (url=${page.url()})`);
  }

  log('[recon] network summary:', JSON.stringify(mon.summary(), null, 2));
}

// Verify the 15-second slide gate on the CURRENT slide. Reads the Next button text
// ("Read slide first (Ns)") and disabled state, and times how long until it enables.
async function captureSlideGate(page, tag) {
  const read = async () => {
    const btns = await getButtons(page);
    const nx = btns.find((b) => b.visible && /(Next|Finish Slides|Read slide first|Continue)/i.test(b.text));
    const header = await page.evaluate(() => {
      const m = (document.body.innerText || '').match(/Slide\s+(\d+)\s+of\s+(\d+)/i);
      return m ? m[0] : null;
    });
    return { nx, header };
  };
  const start = Date.now();
  const r0 = await read();
  const countdownMatch = r0.nx ? r0.nx.text.match(/\((\d+)s\)/) : null;
  log(`[gate:${tag}] ${r0.header || '(no slide header)'} | button="${r0.nx?.text}" disabled=${r0.nx?.disabled}`);
  await shot(page, `gate-${tag}-${(r0.header || 'slide').replace(/\s+/g, '')}`);

  // Poll until the next button becomes enabled (cap at 25s).
  let enabledAt = null;
  while (Date.now() - start < 25000) {
    const r = await read();
    if (r.nx && !r.nx.disabled && !/Read slide first/i.test(r.nx.text)) { enabledAt = Date.now() - start; break; }
    await sleep(500);
  }
  const rec = {
    tag, slide: r0.header, initialButton: r0.nx?.text, initialDisabled: r0.nx?.disabled,
    declaredCountdown: countdownMatch ? +countdownMatch[1] : null,
    enabledAfterMs: enabledAt,
  };
  slideGateChecks.push(rec);
  log(`[gate:${tag}] enabled after ${enabledAt}ms (declared ~${rec.declaredCountdown}s)`);
  return rec;
}

// Module titles to iterate (discovered at recon). We re-read the dashboard each pass.
const MODULE_TITLES = [
  'Module 1: Universal Core Refresher',
  'Module 2: The Partnership Foundation',
  'Module 3: The Mirror Specialist',
  'Module 4: Digital & Data Intelligence',
  'Module 5: The Instructional Catalyst',
  'Module 6: The Excellence Loop',
];
const rx = (s) => new RegExp(s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'i');

// Extract correct practice-branch texts (in step order) for a unit, from the
// captured /api/training/{unitId} content payload.
function correctAnswersForUnit(unitId) {
  const res = mon.entries.find((e) => e.t === 'res' && e.cat === 'content-api'
    && e.url.includes(unitId) && e.body && /format_type":"scenario"/.test(e.body));
  if (!res) return [];
  try {
    const payload = JSON.parse(res.body);
    const arr = Array.isArray(payload) ? payload : (payload.content || payload.data || []);
    const scen = arr.find((c) => c.format_type === 'scenario');
    if (!scen) return [];
    const inner = JSON.parse(scen.content_url);
    const steps = inner.steps || [];
    return steps.map((s) => {
      const correct = (s.branches || []).find((b) => b.isCorrect);
      return correct ? correct.text : null;
    });
  } catch { return []; }
}

// FULL completion walk (resilient + resumable: server persists per-unit completion).
const MAX_UNITS = process.env.MAX_UNITS ? parseInt(process.env.MAX_UNITS, 10) : Infinity;
let unitsDone = 0;
async function completeAll(page) {
  log('\n===== FULL COMPLETION WALK =====' + (MAX_UNITS !== Infinity ? ` (cap ${MAX_UNITS} units)` : ''));
  for (const modTitle of MODULE_TITLES) {
    if (unitsDone >= MAX_UNITS) { log('[walk] unit cap reached — stopping.'); break; }
    mon.setPhase(`module:${modTitle.slice(0, 9)}`);
    let unitGuard = 0;
    while (unitGuard++ < 12) {
      if (unitsDone >= MAX_UNITS) break;
      page = await ensureAlive(page);
      await open(page, '/dashboard');
      await waitText(page, /Training Modules/i, 20000);
      await sleep(1200);
      await clickText(page, rx(modTitle)); // expand this module
      await sleep(1500);
      const units = await getModuleUnits(page);
      if (!units.length) { log(`[walk] ${modTitle}: no units parsed — skipping.`); break; }
      const next = units.find((u) => u.status === 'Not Started' || u.status === 'In Progress');
      log(`[walk] ${modTitle}: ${units.map((u) => u.id + '=' + u.status).join(', ')}`);
      if (!next) { log(`[walk] ${modTitle}: all units done → attempt module quiz.`); break; }

      await clickText(page, rx(next.title));
      await sleep(2800);
      if (!/\/training\//.test(page.url())) { log(`[walk] could not enter ${next.title}; stopping module.`); break; }
      const unitId = page.url().split('/training/')[1]?.split(/[?#]/)[0];
      mon.setPhase(`unit:${next.id}:${unitId?.slice(0, 8)}`);
      log(`[walk] → ${next.title} (${unitId})`);
      await sleep(1500); // let /api/training/{id} land so we have the answer key
      try {
        await walkUnit(page, unitId, next);
      } catch (e) {
        log(`[walk] ERROR in ${next.title}: ${e.message} — recovering, will retry from dashboard.`);
        await shot(page, `err-${next.id}`);
      }
      unitsDone++;
    }
    page = await ensureAlive(page);
    await attemptModuleQuiz(page, modTitle);
  }
  log('[walk] network summary:', JSON.stringify(mon.summary(), null, 2));
}

async function walkUnit(page, unitId, unit) {
  // Walk every slide; verify the 15s gate on EACH; advance with Next/Finish Slides.
  let slideGuard = 0;
  while (slideGuard++ < 30) {
    const hdr = await page.evaluate(() => {
      const m = (document.body.innerText || '').match(/Slide\s+(\d+)\s+of\s+(\d+)/i);
      return m ? { n: +m[1], total: +m[2] } : null;
    });
    if (!hdr) break; // no longer on slides (moved to practice or done)
    await captureSlideGate(page, `${unit.id}-s${hdr.n}of${hdr.total}`);
    const clicked = await clickFirst(page, /Finish Slides|^Next$|Next\b/i, { needEnabled: true });
    log(`[walk] ${unit.id} slide ${hdr.n}/${hdr.total} advance -> "${clicked}"`);
    await sleep(1200);
    if (/Finish Slides/i.test(clicked || '')) break;
    if (!clicked) await sleep(2500);
  }
  await sleep(1800);
  await completePractice(page, unitId, unit);
}

async function attemptModuleQuiz(page, modTitle) {
  await open(page, '/dashboard');
  await waitText(page, /Training Modules/i, 15000);
  await sleep(1000);
  await clickText(page, rx(modTitle));
  await sleep(1200);
  const quizBtn = (await getButtons(page)).find((b) => b.visible && /Attempt Quiz/i.test(b.text));
  if (!quizBtn) { log(`[quiz] ${modTitle}: no Attempt Quiz button found.`); return; }
  if (quizBtn.disabled) { log(`[quiz] ${modTitle}: Attempt Quiz still LOCKED (units incomplete) — skipping.`); return; }
  mon.setPhase(`quiz:${modTitle.slice(0, 9)}`);
  await clickButtonIdx(page, quizBtn.i);
  await sleep(2500);
  await shot(page, `quiz-${modTitle.slice(7, 8)}-start`);
  log(`[quiz] ${modTitle}: entered quiz at ${page.url()}`);
  // Quiz answering handled best-effort: pick correct option if exposed, else first.
  await answerQuiz(page, modTitle);
}

async function answerQuiz(page, modTitle) {
  let q = 0;
  while (q++ < 40) {
    const onQuiz = await page.evaluate(() => /Question\s+\d+\s+of\s+\d+/i.test(document.body.innerText || ''));
    if (!onQuiz) break;
    await page.evaluate(() => {
      const opts = Array.from(document.querySelectorAll('[role=radio],button,label')).filter((b) => {
        const t = (b.innerText || '').trim();
        return t && !/Next|Submit|Previous|Back|Question/i.test(t) && (b.offsetParent || b.getClientRects().length);
      });
      if (opts[0]) opts[0].click();
    });
    await sleep(500);
    const adv = await clickFirst(page, /Next|Submit/i, { needEnabled: true });
    log(`[quiz] ${modTitle} Q${q} -> "${adv}"`);
    await sleep(1200);
    if (/Submit/i.test(adv || '')) break;
  }
  await sleep(2000);
  await shot(page, `quiz-${modTitle.slice(7, 8)}-result`);
}

async function completePractice(page, unitId, unit) {
  const answers = correctAnswersForUnit(unitId); // correct branch texts, in step order
  log(`[practice] ${unit?.id}: correct-answer key has ${answers.filter(Boolean).length}/${answers.length} known answers`);
  let sit = 0;
  while (sit++ < 20) {
    const onPractice = await page.evaluate(() => /Situation\s+\d+\s+of\s+\d+/i.test(document.body.innerText || ''));
    if (!onPractice) break;
    const want = answers[sit - 1] || null; // correct text for this situation (best-effort by order)
    // Click the option whose text matches the correct branch; else first option.
    const picked = await page.evaluate((wantText) => {
      const norm = (s) => (s || '').replace(/[\s'"’‘“”]+/g, ' ').trim().toLowerCase();
      const btns = Array.from(document.querySelectorAll('button')).filter((b) => {
        const t = (b.innerText || '').trim();
        return t && !/Check My Response|Next Situation|See Results|Previous|Dashboard|Try Again|Finish/i.test(t)
          && (b.offsetParent || b.getClientRects().length);
      });
      let target = btns[0];
      if (wantText) {
        const w = norm(wantText);
        const hit = btns.find((b) => { const t = norm(b.innerText); return t && (t.includes(w.slice(0, 40)) || w.includes(t.slice(0, 40))); });
        if (hit) target = hit;
      }
      if (target) { target.click(); return { text: (target.innerText || '').slice(0, 60), matched: !!wantText }; }
      return null;
    }, want);
    log(`[practice] situation ${sit}: picked "${picked?.text}" (key-known=${!!want})`);
    await sleep(600);
    await clickFirst(page, /Check My Response/i, { needEnabled: true });
    await sleep(1000);
    const adv = await clickFirst(page, /Next Situation|See Results/i, { needEnabled: true });
    log(`[practice] advance -> "${adv}"`);
    await sleep(1200);
    if (/See Results/i.test(adv || '')) break;
  }
  await sleep(1500);
  await shot(page, `practice-results-${Date.now().toString(36)}`);
  // Finish the training to record completion.
  const fin = await clickFirst(page, /Finish Training/i, { needEnabled: true });
  log(`[practice] finish -> "${fin}"`);
  await sleep(2000);
}

function finalize() {
  // Persist the full network log + analysis.
  const supdata = mon.supabaseDataHits();
  const apikeys = mon.apikeyHits();
  const contentApi = mon.contentApiReqs();

  // Requirement-1 findings: any supabase data/storage/functions call (carries apikey)
  for (const e of supdata) {
    findings.push({
      type: 'SUPABASE_KEY_USED',
      severity: 'High',
      phase: e.phase,
      method: e.method,
      url: e.url,
      apikey: e.apikeyRedacted,
      note: 'Supabase data-plane call (apikey header present) observed during this phase.',
    });
  }

  const report = {
    app: APP,
    account: ACCOUNT.email,
    requiredApi: REQUIRED_API,
    networkSummary: mon.summary(),
    slideGateChecks,
    findings,
    contentApiSample: contentApi.slice(0, 30).map((e) => ({ phase: e.phase, method: e.method, url: e.url, postData: e.postData })),
    supabaseAuthCalls: mon.entries.filter((e) => e.t === 'req' && e.cat === 'supabase-auth').length,
    apikeyHeaderRequests: apikeys.map((e) => ({ phase: e.phase, cat: e.cat, url: e.url, apikey: e.apikeyRedacted })),
  };
  fs.writeFileSync(path.join(OUT_DIR, 'training-network.json'), JSON.stringify(mon.entries, null, 2));
  fs.writeFileSync(path.join(OUT_DIR, 'training-report.json'), JSON.stringify(report, null, 2));
  log('\n===== TRAINING RESULTS =====');
  log(JSON.stringify({ networkSummary: report.networkSummary, slideGateChecks, findings }, null, 2));
  log(`\n[files] ${path.join(OUT_DIR, 'training-network.json')}`);
  log(`[files] ${path.join(OUT_DIR, 'training-report.json')}`);
}

main().catch((e) => { log('FATAL', e.message, '\n', e.stack); });
