// Coaching Agent — baseline orchestrator (completion-aware).
//
// Flow (per agent spec):
//   1. Launch HEADED browser immediately, log in.
//   2. Check learning (baseline-completion.json) for the logged-in user.
//   3. If baseline already completed:
//        - verify completion status (dashboard profile),
//        - verify baseline cannot be retaken (/assessment/baseline -> redirect, no questions),
//        - SKIP the full baseline flow, hand off to the training section.
//   4. If not completed (or learning says nothing):
//        - live-check /assessment/baseline. If it redirects -> it IS completed
//          (learning was stale): record completion + run verification-only.
//        - otherwise run the full baseline @regression flow and record completion on submit.
//
// Usage:
//   node baseline-agent.mjs                 # headed, account = noor (config)
//   node baseline-agent.mjs --fresh         # headed, sign up a fresh account, run full flow
//   HEADLESS=1 node baseline-agent.mjs      # headless (only when explicitly requested)

import fs from 'fs';
import path from 'path';
import {
  APP, EVID_DIR, sleep, launchBrowser, open, waitText, clickByText, bodyText,
  login, currentUserId, isBaselineCompleted, getBaselineRecord, recordBaselineCompletion,
  ensureEvidenceDir, btnInfo, setupToastObserver, waitToast, signup,
} from './lib.mjs';

const FRESH = process.argv.includes('--fresh');
const NOOR = { email: 'noor@yopmail.com', pass: 'Umar@123!@#$' };

ensureEvidenceDir();
const results = [];
const rec = (id, name, status, evidence = '—', severity = '—', notes = '') => {
  results.push({ id, name, status, severity, evidence, notes });
  console.log(`[${id}] ${status}${severity !== '—' ? ' (' + severity + ')' : ''} — ${name}`);
  if (evidence && evidence !== '—') console.log('   evidence:', evidence);
  if (notes) console.log('   notes:', notes);
};

// Baseline @regression scenarios that require an UNCOMPLETED baseline (the full flow).
const FLOW_SCENARIOS = [
  ['S1', 'View intro screen before starting assessment'],
  ['S2', 'Start baseline assessment from intro screen'],
  ['S3', 'Answer a question and navigate to next question'],
  ['S4', 'Next button jumps to first unanswered question'],
  ['S5', 'Navigate back to previous question and see saved answer'],
  ['S6', 'Previous button is disabled on first question'],
  ['S7', 'Progress bar and counter update as questions are answered'],
  ['S8', 'Submit button appears only when all questions are answered'],
  ['S13', 'Submit baseline and calculate persona E (<60%)'],
  ['S14', 'Auto-save progress to localStorage every 5 seconds'],
  ['S15', 'Resume baseline from saved localStorage progress'],
  ['S16', 'Tab switch detection triggers first warning'],
  ['S17', 'Tab switch detection triggers second warning'],
  ['S19', 'Cannot submit baseline when questions are not all answered'],
  ['S20', 'Submit button is disabled while submitting'],
];

// ---- assessment-specific DOM helpers (baseline question UI) ----
const SHOT = (page, name) => page.screenshot({ path: path.join(EVID_DIR, name), fullPage: true }).catch(() => {});
async function header(page) { const m = (await bodyText(page)).match(/Question\s+(\d+)\s+of\s+(\d+)/i); return m ? { cur: +m[1], total: +m[2] } : null; }
async function counter(page) { const m = (await bodyText(page)).match(/(\d+)\s+of\s+(\d+)\s+answered/i); return m ? { ans: +m[1], total: +m[2] } : null; }
async function options(page) { return page.$$('[role=radio]'); }
async function selectOpt(page, idx) { const o = await options(page); if (!o[idx]) return false; await o[idx].click(); await sleep(200); return page.evaluate((e) => e.getAttribute('aria-checked') === 'true', o[idx]); }
async function selectedIndex(page) { const o = await options(page); for (let i = 0; i < o.length; i++) if (await page.evaluate((e) => e.getAttribute('aria-checked') === 'true', o[i])) return i; return -1; }
async function progressPct(page) {
  return page.evaluate(() => {
    for (const b of document.querySelectorAll('[role=progressbar],[class*="progress" i]')) {
      const v = b.getAttribute('aria-valuenow'); if (v != null) return +v;
      const fill = b.querySelector('[style*="width"]'); if (fill) { const m = fill.style.width.match(/[\d.]+/); if (m) return +m[0]; }
    }
    return null;
  });
}
async function tabSwitch(page) {
  await page.evaluate(() => {
    try { Object.defineProperty(document, 'visibilityState', { value: 'hidden', configurable: true }); } catch {}
    try { Object.defineProperty(document, 'hidden', { value: true, configurable: true }); } catch {}
    document.dispatchEvent(new Event('visibilitychange')); window.dispatchEvent(new Event('blur'));
  });
  await sleep(350);
  await page.evaluate(() => {
    try { Object.defineProperty(document, 'visibilityState', { value: 'visible', configurable: true }); } catch {}
    try { Object.defineProperty(document, 'hidden', { value: false, configurable: true }); } catch {}
    document.dispatchEvent(new Event('visibilitychange')); window.dispatchEvent(new Event('focus'));
  });
}

// ---- the full new-user baseline flow (runs only when baseline is NOT completed) ----
async function runFullFlow(page, userId) {
  // S21 — dashboard for a no-baseline user: modules locked + baseline CTA
  try {
    await open(page, '/dashboard');
    await waitText(page, /Baseline|Module|Welcome/i, 15000);
    await sleep(1500);
    const dash = await bodyText(page);
    const baselineReq = /Baseline Assessment Required/i.test(dash);
    const attemptBtn = /Attempt Baseline Assessment/i.test(dash);
    const lockCount = await page.evaluate(() => document.querySelectorAll('svg.lucide-lock,.lucide-lock,[class*="lock" i]').length);
    await SHOT(page, 'fresh-dashboard.png');
    if ((lockCount > 0 || /locked/i.test(dash)) || baselineReq || attemptBtn)
      rec('S21', 'Cannot navigate to training modules without completing baseline', '✅ COVERED', `No-baseline dashboard: "Baseline Assessment Required"=${baselineReq}, attempt CTA=${attemptBtn}, lock indicators=${lockCount}. file: fresh-dashboard.png`);
    else rec('S21', 'Cannot navigate to training modules without completing baseline', '⚠️ PARTIAL', `baselineReq=${baselineReq} attemptBtn=${attemptBtn} lockCount=${lockCount}`, 'Medium');
  } catch (e) { rec('S21', 'Modules locked without baseline', '⚠️ PARTIAL', 'error: ' + e.message, 'Medium'); }

  // S1 — intro screen
  let total = 30;
  try {
    await open(page, '/assessment/baseline');
    await waitText(page, /Start Assessment/i, 20000);
    await sleep(400);
    const intro = await bodyText(page); await SHOT(page, 'fresh-intro.png');
    const checks = {
      welcome: /Welcome to Your Assessment/i.test(intro), whatIs: /What is the baseline/i.test(intro),
      whyMatter: /Why does it matter/i.test(intro), time: /~?\s*10\s*minutes/i.test(intro),
      qCount: /\b\d+\s+questions?\b/i.test(intro), passThreshold: /Pass threshold[:\s]*0%/i.test(intro),
      resume: /resume/i.test(intro), startBtn: /Start Assessment/i.test(intro),
    };
    const missing = Object.entries(checks).filter(([, v]) => !v).map(([k]) => k);
    if (!missing.length) rec('S1', 'View intro screen before starting assessment', '✅ COVERED', 'All intro elements present (welcome, what-is, why, ~10 min, question count, pass threshold 0%, resume, Start). file: fresh-intro.png');
    else rec('S1', 'View intro screen before starting assessment', missing.length <= 2 ? '⚠️ PARTIAL' : '❌ MISSING', `Missing: ${missing.join(',')}. file: fresh-intro.png`, missing.length <= 2 ? 'Low' : 'Medium');
  } catch (e) { rec('S1', 'View intro screen', '❌ MISSING', 'error: ' + e.message, 'High'); }

  // S2 + S6 — start; Q1 state; Previous disabled
  try {
    await clickByText(page, 'button', /Start Assessment/i);
    await waitText(page, /Question\s+1\s+of\s+\d+/i, 15000); await sleep(400);
    const h = await header(page); total = h ? h.total : total;
    const opts = await options(page); const next = await btnInfo(page, /^Next$/i); const prev = await btnInfo(page, /^Previous$/i); const prog = await progressPct(page);
    await SHOT(page, 'fresh-q1.png');
    if (h && h.cur === 1 && opts.length === 4 && next.exists && prev.exists && prev.disabled)
      rec('S2', 'Start baseline assessment from intro screen', '✅ COVERED', `Q1 ("Question 1 of ${h.total}"); 4 options; Next present; Previous disabled; progress≈${prog}. file: fresh-q1.png`);
    else rec('S2', 'Start baseline assessment from intro screen', '⚠️ PARTIAL', `header=${JSON.stringify(h)} opts=${opts.length} next=${next.exists} prevDisabled=${prev.disabled}`, 'Medium');
    rec('S6', 'Previous button is disabled on first question', prev.exists && prev.disabled ? '✅ COVERED' : '❌ MISSING', prev.exists && prev.disabled ? 'On Q1 the "Previous" button is disabled. file: fresh-q1.png' : `Previous exists=${prev.exists} disabled=${prev.disabled}`, prev.exists && prev.disabled ? '—' : 'Medium');
  } catch (e) { rec('S2', 'Start from intro', '❌ MISSING', 'error: ' + e.message, 'High'); rec('S6', 'Previous disabled on Q1', '❌ MISSING', 'blocked by S2', 'Medium'); }

  // S3 — answer Q1 (option B) and Next -> Q2
  try {
    await selectOpt(page, 1); const selIdx = await selectedIndex(page);
    await clickByText(page, 'button', /^Next$/i);
    await waitText(page, /Question\s+2\s+of/i, 10000); await sleep(300);
    const h = await header(page); const c = await counter(page); const prog = await progressPct(page);
    if (h && h.cur === 2 && selIdx === 1 && c && c.ans >= 1)
      rec('S3', 'Answer a question and navigate to next question', '✅ COVERED', `Option B selected on Q1 (aria-checked idx=1), Next → Q2; counter "${c.ans} of ${c.total} answered"; progress≈${prog}.`);
    else rec('S3', 'Answer a question and navigate to next question', '⚠️ PARTIAL', `header=${JSON.stringify(h)} selIdx=${selIdx} counter=${JSON.stringify(c)}`, 'Medium');
  } catch (e) { rec('S3', 'Answer & next', '❌ MISSING', 'error: ' + e.message, 'High'); }

  // S5 — answer Q2,Q3 then Previous from Q3 shows saved Q2 answer
  try {
    await selectOpt(page, 2); const q2sel = await selectedIndex(page);
    await clickByText(page, 'button', /^Next$/i); await waitText(page, /Question\s+3\s+of/i, 10000); await sleep(300);
    await clickByText(page, 'button', /^Previous$/i); await waitText(page, /Question\s+2\s+of/i, 10000); await sleep(300);
    const backSel = await selectedIndex(page);
    if (backSel === q2sel && q2sel >= 0) rec('S5', 'Navigate back to previous question and see saved answer', '✅ COVERED', `Selected idx ${q2sel} on Q2; Previous from Q3 → Q2; saved answer still selected (idx=${backSel}).`);
    else rec('S5', 'Navigate back to previous question and see saved answer', '⚠️ PARTIAL', `q2sel=${q2sel} backSel=${backSel}`, 'Medium');
  } catch (e) { rec('S5', 'Previous shows saved answer', '❌ MISSING', 'error: ' + e.message, 'Medium'); }

  // S4 — Next jumps to first unanswered (build {1,2,4} answered, on Q4 -> Next -> Q3)
  try {
    await clickByText(page, 'button', /^Next$/i); await waitText(page, /Question\s+3\s+of/i, 10000); await sleep(250);
    await clickByText(page, 'button', /^Next$/i); await sleep(700); // from unanswered Q3 -> Q4?
    let h = await header(page);
    if (h && h.cur === 4) {
      await selectOpt(page, 0); await sleep(250);
      await clickByText(page, 'button', /^Next$/i); await sleep(800);
      h = await header(page);
      if (h && h.cur === 3) rec('S4', 'Next button jumps to first unanswered question', '✅ COVERED', `With Q1,Q2,Q4 answered and on Q4, Next jumped to Q3 (first unanswered) — "Question 3 of ${h.total}".`);
      else rec('S4', 'Next button jumps to first unanswered question', '⚠️ PARTIAL', `Landed on Q${h ? h.cur : '?'} instead of Q3.`, 'Medium', 'Next-jump differs from spec or setup not reproducible.');
    } else rec('S4', 'Next button jumps to first unanswered question', '⚠️ PARTIAL', `Could not reach Q4 (Next from unanswered Q3 → Q${h ? h.cur : '?'}).`, 'Medium', 'Navigation model prevented exact precondition.');
  } catch (e) { rec('S4', 'Next jumps to first unanswered', '⚠️ PARTIAL', 'error: ' + e.message, 'Medium'); }

  // S14 — auto-save to localStorage every 5s
  try {
    await sleep(6000);
    const lsKey = `assessment_baseline_${userId}`;
    const saved = await page.evaluate((k) => { const v = localStorage.getItem(k); if (!v) return null; try { return JSON.parse(v); } catch { return { raw: true }; } }, lsKey);
    if (saved && saved.answers && 'currentIndex' in saved && saved.timestamp)
      rec('S14', 'Auto-save progress to localStorage every 5 seconds', '✅ COVERED', `Key "${lsKey}" present after 5s with answers(${Object.keys(saved.answers).length}), currentIndex=${saved.currentIndex}, timestamp set.`);
    else if (saved) rec('S14', 'Auto-save progress to localStorage every 5 seconds', '⚠️ PARTIAL', `Key present, fields: ${JSON.stringify(Object.keys(saved))}.`, 'Low');
    else rec('S14', 'Auto-save progress to localStorage every 5 seconds', '❌ MISSING', `No localStorage key "${lsKey}" after 5s.`, 'High');
  } catch (e) { rec('S14', 'Auto-save 5s', '❌ MISSING', 'error: ' + e.message, 'High'); }

  // S16 / S17 — tab-switch warnings
  try {
    await page.evaluate(() => { window.__toasts = []; });
    await tabSwitch(page); const t1 = await waitToast(page, /switch|recorded/i, 5000);
    rec('S16', 'Tab switch detection triggers first warning', t1 ? '✅ COVERED' : '⚠️ PARTIAL', t1 ? `After 1st simulated tab switch: toast "${t1}".` : 'No toast captured (may need real OS visibility change).', t1 ? '—' : 'Medium');
    await page.evaluate(() => { window.__toasts = []; });
    await tabSwitch(page); const t2 = await waitToast(page, /switch|recorded|detected|\(2\)/i, 5000);
    rec('S17', 'Tab switch detection triggers second warning', t2 ? '✅ COVERED' : '⚠️ PARTIAL', t2 ? `After 2nd simulated tab switch: toast "${t2}".` : 'No toast captured.', t2 ? '—' : 'Medium');
  } catch (e) { rec('S16', 'Tab switch #1', '⚠️ PARTIAL', 'error: ' + e.message, 'Medium'); rec('S17', 'Tab switch #2', '⚠️ PARTIAL', 'blocked', 'Medium'); }

  // S15 — resume from localStorage
  try {
    await page.evaluate(() => { window.__toasts = []; });
    await open(page, '/assessment/baseline');
    const resumeToast = await waitToast(page, /Resuming where you left off/i, 8000);
    await waitText(page, /Question\s+\d+\s+of|Start Assessment/i, 15000); await sleep(400);
    const h = await header(page); const c = await counter(page);
    if (resumeToast) rec('S15', 'Resume baseline from saved localStorage progress', '✅ COVERED', `On return a toast "${resumeToast}" appeared; resumed at Q${h ? h.cur : '?'} with ${c ? c.ans : '?'} answers preserved.`);
    else if (h && h.cur > 1) rec('S15', 'Resume baseline from saved localStorage progress', '⚠️ PARTIAL', `Resumed at Q${h.cur} but exact toast not captured.`, 'Low');
    else rec('S15', 'Resume baseline from saved localStorage progress', '❌ MISSING', `No resume toast; landed at Q${h ? h.cur : '?'}.`, 'High');
  } catch (e) { rec('S15', 'Resume from localStorage', '⚠️ PARTIAL', 'error: ' + e.message, 'Medium'); }

  // Fill all questions; capture S7 (5 answered) and S19 (not-all -> no Submit)
  let s7 = false, s19 = false, submitHandle = null;
  try {
    let guard = 0;
    while (guard++ < 80) {
      const h = await header(page); if (!h) break;
      if ((await selectedIndex(page)) < 0) await selectOpt(page, 0);
      const c = await counter(page);
      if (!s7 && c && c.ans === 5) { const prog = await progressPct(page); rec('S7', 'Progress bar and counter update as questions are answered', '✅ COVERED', `Counter "${c.ans} of ${c.total} answered"; progress bar ≈${prog}% after 5 answers.`); s7 = true; }
      const submit = await btnInfo(page, /^Submit$/i); const next = await btnInfo(page, /^Next$/i);
      if (!s19 && c && c.ans < c.total) {
        if (!submit.exists && next.exists) { rec('S19', 'Cannot submit baseline when questions are not all answered', '✅ COVERED', `With ${c.ans}/${c.total} answered: no "Submit", "Next" shown instead.`); s19 = true; }
        else if (submit.exists) { rec('S19', 'Cannot submit baseline when questions are not all answered', '❌ VIOLATION', `Submit present at ${c.ans}/${c.total} answered.`, 'High'); s19 = true; }
      }
      if (submit.exists && c && c.ans === c.total) { submitHandle = submit.handle; break; }
      if (next.exists) { await next.handle.click(); await sleep(450); } else if (submit.exists) { submitHandle = submit.handle; break; } else await sleep(350);
    }
    if (!s7) rec('S7', 'Progress bar and counter update', '⚠️ PARTIAL', 'Did not catch exact "5 of N answered" frame.', 'Low');
    if (!s19) rec('S19', 'Cannot submit when not all answered', '⚠️ PARTIAL', 'Did not catch intermediate state.', 'Low');
  } catch (e) { console.log('fill loop error', e.message); }

  // S8 — Submit appears only when all answered
  try {
    const c = await counter(page); const submit = await btnInfo(page, /^Submit$/i); const next = await btnInfo(page, /^Next$/i);
    await SHOT(page, 'fresh-all-answered.png');
    if (c && c.ans === c.total && submit.exists && !submit.disabled && !next.exists) { rec('S8', 'Submit button appears only when all questions are answered', '✅ COVERED', `${c.ans}/${c.total} answered: "Submit" present & enabled, "Next" gone. file: fresh-all-answered.png`); submitHandle = submit.handle; }
    else if (c && c.ans === c.total && submit.exists) { rec('S8', 'Submit button appears only when all questions are answered', '⚠️ PARTIAL', `Submit present (disabled=${submit.disabled}), Next present=${next.exists}.`, 'Low'); submitHandle = submit.handle; }
    else rec('S8', 'Submit button appears only when all questions are answered', '⚠️ PARTIAL', `counter=${JSON.stringify(c)} submit=${submit.exists}`, 'Medium');
  } catch (e) { rec('S8', 'Submit appears when all answered', '⚠️ PARTIAL', 'error: ' + e.message, 'Medium'); }

  // S20 + S13 — submit (disabled-while-submitting) then persona E on dashboard
  try {
    if (!submitHandle) submitHandle = (await btnInfo(page, /^Submit$/i)).handle;
    if (submitHandle) {
      await submitHandle.click();
      let sawSubmitting = false, sawDisabled = false; const end = Date.now() + 4000;
      while (Date.now() < end) {
        const s = await btnInfo(page, /Submit|Submitting/i);
        if (s.exists && /Submitting/i.test(s.text)) sawSubmitting = true;
        if (s.exists && s.disabled) sawDisabled = true;
        if ((sawSubmitting && sawDisabled) || !s.exists) break;
        await sleep(120);
      }
      rec('S20', 'Submit button is disabled while submitting', (sawSubmitting || sawDisabled) ? '✅ COVERED' : '⚠️ PARTIAL', (sawSubmitting || sawDisabled) ? `On Submit click the button ${sawSubmitting ? 'changed to "Submitting..."' : ''}${sawSubmitting && sawDisabled ? ' and ' : ''}${sawDisabled ? 'became disabled' : ''}.` : 'Transition too fast to capture.', (sawSubmitting || sawDisabled) ? '—' : 'Low');

      await page.waitForFunction(() => /dashboard/i.test(location.pathname) || /Coaching Profile|Persona/i.test(document.body.innerText), { timeout: 20000 }).catch(() => {});
      await sleep(2500);
      const dash = await bodyText(page); await SHOT(page, 'fresh-result-dashboard.png');
      const personaM = dash.match(/Persona\s+([A-E])/i); const scoreM = dash.match(/baseline score of\s+(\d+)%/i) || dash.match(/Baseline[\s\n]*?(\d+)%/i);
      const modules = (dash.match(/Module\s+\d+:/g) || []).length; const onDash = /dashboard/i.test(page.url());
      const persona = personaM ? personaM[1].toUpperCase() : null; const score = scoreM ? +scoreM[1] : null;
      if (persona === 'E' && onDash) rec('S13', 'Submit baseline and calculate persona E (<60%)', '✅ COVERED', `All-first-option submission scored ${score != null ? score + '%' : '<60%'} → Persona E; redirected to dashboard; ${modules} modules shown (not persona-filtered). file: fresh-result-dashboard.png`);
      else if (persona && onDash) rec('S13', 'Submit baseline and calculate persona E (<60%)', '⚠️ PARTIAL', `Submission produced Persona ${persona} (score ${score != null ? score + '%' : '?'}); expected E for <60%.`, 'Medium');
      else rec('S13', 'Submit baseline and calculate persona E (<60%)', '⚠️ PARTIAL', `Post-submit url=${page.url()} persona=${persona || 'n/a'}.`, 'Medium');
      return { persona, score };
    }
    rec('S20', 'Submit disabled while submitting', '⚠️ PARTIAL', 'No submit handle (all-answered not reached).', 'Medium');
    rec('S13', 'Persona E (<60%)', '⚠️ PARTIAL', 'Submit not reached.', 'Medium');
  } catch (e) { rec('S20', 'Submit disabled while submitting', '⚠️ PARTIAL', 'error: ' + e.message, 'Medium'); rec('S13', 'Persona E', '⚠️ PARTIAL', 'error: ' + e.message, 'Medium'); }
  return { persona: null, score: null };
}

async function verifyCannotRetake(page, who) {
  // Verify completion status (dashboard) + cannot re-access baseline.
  await open(page, '/dashboard');
  await waitText(page, /Persona|Coaching Profile|Baseline/i, 15000);
  await sleep(800);
  const dash = await bodyText(page);
  const personaM = dash.match(/Persona\s+([A-E])/i);
  const scoreM = dash.match(/baseline score of\s+(\d+)%/i) || dash.match(/Baseline[\s\n]*?(\d+)%/i);
  const profileShown = /Coaching Profile/i.test(dash) || !!personaM;

  await open(page, '/assessment/baseline');
  await sleep(1500);
  const url = page.url();
  const radios = (await page.$$('[role=radio]')).length;
  const hasQ = await page.evaluate(() => /Start Assessment|Question\s+\d+\s+of/i.test(document.body.innerText));
  await page.screenshot({ path: path.join(EVID_DIR, `${who}-baseline-redirect.png`), fullPage: true }).catch(() => {});

  const redirected = /\/dashboard/.test(url) && radios === 0 && !hasQ;
  if (redirected) {
    rec('S18', 'Cannot access baseline assessment if already completed', '✅ COVERED',
      `Completed user (${who}${personaM ? ', Persona ' + personaM[1] : ''}${scoreM ? ', ' + scoreM[1] + '%' : ''}): /assessment/baseline immediately redirected to ${url}; no questions/intro (role=radio=0). Dashboard profile shown=${profileShown}. file: ${who}-baseline-redirect.png`);
  } else {
    rec('S18', 'Cannot access baseline assessment if already completed', '❌ VIOLATION',
      `Completed user reached ${url} with radios=${radios} hasQuestions=${hasQ} — baseline should be inaccessible.`, 'Critical');
  }
  return { persona: personaM ? personaM[1] : null, score: scoreM ? +scoreM[1] : null, redirected };
}

const browser = await launchBrowser();
try {
  const page = await browser.newPage();
  page.setDefaultTimeout(30000);

  if (!FRESH) {
    // ---- Configured account path (noor) with completion-aware branching ----
    await login(page, NOOR);
    const email = NOOR.email;
    const userId = await currentUserId(page);
    const learned = isBaselineCompleted(email);
    const learnedRec = getBaselineRecord(email);
    console.log(`\n[learning] ${email} baselineCompleted (cached) = ${learned}` + (learnedRec ? ` (persona ${learnedRec.persona}, ${learnedRec.score}%)` : ''));

    if (learned) {
      console.log('[flow] Learning says baseline COMPLETED → verification-only path (skip full flow).');
      const v = await verifyCannotRetake(page, 'noor');
      // refresh learning with anything newly observed
      recordBaselineCompletion({ email, userId, persona: v.persona, score: v.score, source: 'verified (live run ' + new Date().toISOString().slice(0, 10) + ')' });
      for (const [id, name] of FLOW_SCENARIOS) {
        rec(id, name, '⏭️ SKIPPED', '—', '—', 'Baseline already completed for this user (learning cache) — full flow skipped per completion-aware rule. Proceed to training section.');
      }
      console.log('\n[flow] → Baseline verified complete & locked. Hand off to TRAINING section.');
    } else {
      // Live check — learning may be empty/stale.
      await open(page, '/assessment/baseline');
      await sleep(1500);
      const redirected = /\/dashboard/.test(page.url());
      if (redirected) {
        console.log('[flow] Live check: baseline redirects → actually completed (learning stale). Recording + verification-only.');
        const v = await verifyCannotRetake(page, 'noor');
        recordBaselineCompletion({ email, userId, persona: v.persona, score: v.score, source: 'observed (live run, learning was stale)' });
        for (const [id, name] of FLOW_SCENARIOS) rec(id, name, '⏭️ SKIPPED', '—', '—', 'Baseline found completed on live check — full flow skipped.');
      } else {
        console.log('[flow] Baseline NOT completed → full flow would run here.');
        rec('FULL', 'Full baseline flow', 'ℹ️ INFO', '—', '—', 'noor is not completed; run with the full-flow implementation. (Use --fresh to exercise full flow on a throwaway account.)');
      }
    }

    // Non-executable on a live single account (documented limits)
    rec('S9', 'Persona A (≥75%)', '⏭️ SKIPPED', '—', '—', 'Single account / no answer key — cannot target score.');
    rec('S10', 'Persona B (≥70%,<75%)', '⏭️ SKIPPED', '—', '—', 'Single account / no answer key.');
    rec('S11', 'Persona C (≥65%,<70%)', '⏭️ SKIPPED', '—', '—', 'Single account / no answer key.');
    rec('S12', 'Persona D (≥60%,<65%)', '⏭️ SKIPPED', '—', '—', 'Single account / no answer key.');
    rec('S21', 'Cannot navigate to training modules without baseline', '⏭️ SKIPPED', '—', '—', 'Requires a no-baseline account; not testable on completed noor (use --fresh).');
    rec('S22', 'Profile update fails during submission', '⏭️ SKIPPED', '—', '—', 'Needs induced DB write failure — cover at unit/integration tier.');
  } else {
    // ---- --fresh: sign up a throwaway account and run the FULL new-user flow ----
    await setupToastObserver(page); // capture toasts before any navigation
    const stamp = Date.now().toString(36);
    const fresh = {
      email: `qa.baseline.${stamp}@yopmail.com`,
      name: 'QA Baseline Bot',
      phone: '+1202555' + (Date.now() % 10000).toString().padStart(4, '0'),
      pass: 'Umar@123!@#$',
    };
    console.log(`[flow] --fresh: creating throwaway account ${fresh.email}`);
    const userId = await signup(page, fresh);

    const outcome = await runFullFlow(page, userId);

    // After submission the fresh account IS completed → verify S18 on it too.
    const v = await verifyCannotRetake(page, 'fresh');

    // Persist the new account's completion into learning.
    recordBaselineCompletion({
      email: fresh.email, userId,
      persona: outcome.persona ?? v.persona,
      score: outcome.score ?? v.score,
      source: `full --fresh run ${new Date().toISOString().slice(0, 10)}`,
    });

    // Not executable even on a fresh account (one submission, no answer key / no DB-fault injection)
    rec('S9', 'Persona A (≥75%)', '⏭️ SKIPPED', '—', '—', 'No answer key — cannot target a specific score on the single submission.');
    rec('S10', 'Persona B (≥70%,<75%)', '⏭️ SKIPPED', '—', '—', 'No answer key.');
    rec('S11', 'Persona C (≥65%,<70%)', '⏭️ SKIPPED', '—', '—', 'No answer key.');
    rec('S12', 'Persona D (≥60%,<65%)', '⏭️ SKIPPED', '—', '—', 'No answer key.');
    rec('S22', 'Profile update fails during submission', '⏭️ SKIPPED', '—', '—', 'Needs induced DB write failure — cover at unit/integration tier.');
  }

  fs.writeFileSync(path.join(EVID_DIR, '..', 'results.json'), JSON.stringify(results, null, 2));
  console.log('\n===== results.json written =====');
} catch (e) {
  console.log('FATAL:', e.message, '\n', e.stack);
} finally {
  if (!process.env.KEEP_OPEN) await browser.close();
  console.log('DONE');
}
