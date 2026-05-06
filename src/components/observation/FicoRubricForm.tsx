/* eslint-disable @typescript-eslint/no-explicit-any, react-hooks/exhaustive-deps */
import { useState, useEffect } from 'react';
import { supabase } from '@/integrations/supabase/client';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { toast } from 'sonner';
import { Save, TrendingUp, FlaskConical, BookOpen, Calculator, Users, Info, Cpu } from 'lucide-react';
import {
  SECTION_B,
  MATH_C,
  MATH_PA,
  SCIENCE_C,
  LITERACY_C,
  SECTION_D,
  DEFAULT_FICO_RUBRIC,
  calculateFicoScore,
  getFicoProficiency,
  getSubjectCategory,
  isFicoSectionBComplete,
  type FicoScore,
  type FicoRubric,
  type FicoStudentSample,
  type MathType,
} from '@/lib/fico-utils';
import type { CotObservation } from '@/types/observation';

interface Props {
  observation: CotObservation;
  onSaved: (updated: CotObservation) => void;
}

// ── Score button group ────────────────────────────────────────────────────────
function ScoreSelector({
  value,
  onChange,
  includeNA,
}: {
  value: FicoScore | undefined;
  onChange: (v: FicoScore) => void;
  includeNA?: boolean;
}) {
  const opts: { v: FicoScore; label: string; sel: string; unsel: string }[] = [
    { v: 'yes', label: 'Yes (1)', sel: 'bg-green-600 text-white border-green-600', unsel: 'border-green-300 text-green-700 hover:bg-green-50' },
    { v: 'partial', label: 'Partial (½)', sel: 'bg-yellow-500 text-white border-yellow-500', unsel: 'border-yellow-300 text-yellow-700 hover:bg-yellow-50' },
    { v: 'no', label: 'No (0)', sel: 'bg-red-500 text-white border-red-500', unsel: 'border-red-300 text-red-700 hover:bg-red-50' },
  ];
  if (includeNA) {
    opts.push({ v: 'na', label: 'N/A', sel: 'bg-gray-500 text-white border-gray-500', unsel: 'border-gray-200 text-gray-400 hover:bg-gray-50' });
  }
  return (
    <div className="flex gap-1.5 flex-wrap mt-1.5">
      {opts.map(o => (
        <button
          key={o.v}
          type="button"
          onClick={() => onChange(o.v)}
          className={`px-2.5 py-1 text-xs rounded-md border font-medium transition-colors ${value === o.v ? o.sel : o.unsel}`}
        >
          {o.label}
        </button>
      ))}
    </div>
  );
}

// ── Single indicator row ──────────────────────────────────────────────────────
function IndicatorRow({
  code,
  label,
  desc,
  value,
  onChange,
  includeNA,
}: {
  code: string;
  label: string;
  desc: string;
  value: FicoScore | undefined;
  onChange: (v: FicoScore) => void;
  includeNA?: boolean;
}) {
  const dot =
    value === 'yes' ? 'bg-green-500' :
    value === 'partial' ? 'bg-yellow-500' :
    value === 'no' ? 'bg-red-500' :
    value === 'na' ? 'bg-gray-400' :
    'bg-muted-foreground/30';

  return (
    <div className="py-3 border-b border-border last:border-0">
      <div className="flex items-start gap-2 mb-1">
        <span className={`mt-1.5 w-2 h-2 rounded-full shrink-0 ${dot}`} />
        <div className="flex-1">
          <p className="text-sm font-medium text-foreground">
            <span className="text-xs font-mono text-muted-foreground mr-1">{code}</span>
            {label}
          </p>
          <p className="text-xs text-muted-foreground mt-0.5 leading-relaxed">{desc}</p>
        </div>
        {value && value !== 'na' && (
          <span className={`text-sm font-bold shrink-0 ${value === 'yes' ? 'text-green-600' : value === 'partial' ? 'text-yellow-600' : 'text-red-500'}`}>
            {value === 'yes' ? '1' : value === 'partial' ? '½' : '0'}
          </span>
        )}
      </div>
      <ScoreSelector value={value} onChange={onChange} includeNA={includeNA} />
    </div>
  );
}

// ── Main component ────────────────────────────────────────────────────────────
export function FicoRubricForm({ observation, onSaved }: Props) {
  const rawRubric = observation.fico_rubric && Object.keys(observation.fico_rubric).length > 0
    ? (observation.fico_rubric as FicoRubric)
    : DEFAULT_FICO_RUBRIC;

  const [rubric, setRubric] = useState<FicoRubric>({
    section_b: rawRubric.section_b ?? {},
    section_c: rawRubric.section_c ?? {},
    section_d: rawRubric.section_d ?? {},
    section_e: rawRubric.section_e ?? DEFAULT_FICO_RUBRIC.section_e,
  });
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    const r = observation.fico_rubric && Object.keys(observation.fico_rubric).length > 0
      ? (observation.fico_rubric as FicoRubric)
      : DEFAULT_FICO_RUBRIC;
    setRubric({
      section_b: r.section_b ?? {},
      section_c: r.section_c ?? {},
      section_d: r.section_d ?? {},
      section_e: r.section_e ?? DEFAULT_FICO_RUBRIC.section_e,
    });
  }, [observation.id]);

  const setB = (code: string, val: FicoScore) =>
    setRubric(prev => ({ ...prev, section_b: { ...prev.section_b, [code]: val } }));

  const setC = (code: string, val: FicoScore | MathType) =>
    setRubric(prev => ({ ...prev, section_c: { ...prev.section_c, [code]: val } }));

  const setMathType = (t: MathType) =>
    setRubric(prev => ({ ...prev, section_c: { math_type: t } }));

  const setD = (code: string, val: FicoScore) =>
    setRubric(prev => ({ ...prev, section_d: { ...prev.section_d, [code]: val } }));

  const toggleE = (studentIdx: number, q: keyof FicoStudentSample) => {
    setRubric(prev => {
      const students = prev.section_e.map((s, i) => {
        if (i !== studentIdx) return s;
        const curr = s[q];
        const next = curr === null ? true : curr === true ? false : null;
        return { ...s, [q]: next };
      });
      return { ...prev, section_e: students };
    });
  };

  const score = calculateFicoScore(rubric, observation.subject);
  const proficiency = score.totalMax > 0 ? getFicoProficiency(score.percentage) : null;
  const subjectCat = getSubjectCategory(observation.subject);

  const eAnswered = rubric.section_e.filter(s => s.q1 !== null || s.q2 !== null || s.q3 !== null).length;
  const eCorrect = rubric.section_e.reduce((sum, s) => sum + (s.q1 ? 1 : 0) + (s.q2 ? 1 : 0) + (s.q3 ? 1 : 0), 0);
  const eTotal = rubric.section_e.reduce((sum, s) => sum + (s.q1 !== null ? 1 : 0) + (s.q2 !== null ? 1 : 0) + (s.q3 !== null ? 1 : 0), 0);

  const handleSave = async () => {
    setSaving(true);
    const { data, error } = await (supabase as any)
      .from('cot_observations')
      .update({
        fico_rubric: rubric,
        total_score: score.percentage,
        proficiency_level: proficiency?.level ?? null,
        updated_at: new Date().toISOString(),
      })
      .eq('id', observation.id)
      .select()
      .single();

    setSaving(false);

    if (error) {
      toast.error('Failed to save FICO scores');
      return;
    }

    toast.success('FICO scores saved!');
    onSaved(data as CotObservation);
  };

  return (
    <div className="space-y-6">

      {/* DC Auto-score banner */}
      {observation.dc_status === 'completed' && (
        <div className="flex items-center gap-2 px-3 py-2 rounded-lg bg-blue-50 border border-blue-200 text-xs text-blue-700">
          <Cpu className="w-3.5 h-3.5 shrink-0" />
          Auto-scored by Digital Coach — review and adjust if needed
        </div>
      )}

      {/* Score Summary Banner */}
      <div className={`rounded-lg border p-4 ${proficiency ? `${proficiency.bgColor} ${proficiency.borderColor}` : 'bg-muted/30 border-border'}`}>
        <div className="flex items-center justify-between mb-2">
          <div className="flex items-center gap-2">
            <TrendingUp className={`w-4 h-4 ${proficiency?.color ?? 'text-muted-foreground'}`} />
            <span className="text-sm font-semibold text-foreground">FICO Score</span>
            <Badge variant="outline" className="text-xs">ICT Framework</Badge>
          </div>
          <div className="text-right">
            <span className={`text-2xl font-bold ${proficiency?.color ?? 'text-muted-foreground'}`}>
              {score.percentage}%
            </span>
            <div className="text-xs text-muted-foreground">
              {score.totalEarned.toFixed(1)} / {score.totalMax} pts
            </div>
            {proficiency && (
              <div className={`text-xs font-medium ${proficiency.color}`}>{proficiency.level}</div>
            )}
          </div>
        </div>
        {score.totalMax > 0 && (
          <div className="h-1.5 bg-white/60 rounded-full overflow-hidden">
            <div
              className={`h-full rounded-full transition-all duration-300 ${proficiency?.barColor ?? 'bg-muted'}`}
              style={{ width: `${score.percentage}%` }}
            />
          </div>
        )}
        <div className="flex gap-4 mt-2 text-xs text-muted-foreground">
          <span>Section B: {score.sectionBEarned.toFixed(1)}/{score.sectionBMax}</span>
          {score.sectionCMax > 0 && <span>Section C: {score.sectionCEarned.toFixed(1)}/{score.sectionCMax}</span>}
        </div>
      </div>

      {/* ── Section B ─────────────────────────────────────────────────────── */}
      <div>
        <div className="flex items-center gap-2 mb-3">
          <h3 className="text-sm font-semibold text-foreground">Section B — Structural & Pedagogical</h3>
          <Badge variant="outline" className="text-xs">5 indicators · max 5 pts</Badge>
        </div>
        <div className="rounded-lg border border-border bg-card px-4">
          {SECTION_B.map(ind => (
            <IndicatorRow
              key={ind.code}
              code={ind.code}
              label={ind.label}
              desc={ind.desc}
              value={(rubric.section_b as any)[ind.code]}
              onChange={val => setB(ind.code, val)}
            />
          ))}
        </div>
      </div>

      {/* ── Section C ─────────────────────────────────────────────────────── */}
      <div>
        <div className="flex items-center gap-2 mb-3">
          <h3 className="text-sm font-semibold text-foreground">Section C — Subject Specific</h3>
          <Badge variant="outline" className="text-xs capitalize">
            {subjectCat === 'other' ? 'No indicators for this subject' : observation.subject}
          </Badge>
        </div>

        {subjectCat === 'math' && (
          <div className="space-y-3">
            {/* Math type selector */}
            <div className="rounded-lg border border-border bg-card p-4">
              <div className="flex items-center gap-2 mb-2">
                <Calculator className="w-3.5 h-3.5 text-muted-foreground" />
                <p className="text-sm font-medium text-foreground">Classify Lesson Plan Type</p>
              </div>
              <p className="text-xs text-muted-foreground mb-3">
                Type C — Concrete Phase (concept introduction via physical/tactile experience)<br />
                Type PA — Pictorial-Abstract Phase (builds on introduced concept via visual/symbolic work)
              </p>
              <div className="flex gap-2">
                {(['C', 'PA'] as MathType[]).map(t => (
                  <button
                    key={t}
                    type="button"
                    onClick={() => setMathType(t)}
                    className={`px-4 py-1.5 text-sm rounded-md border font-medium transition-colors ${
                      rubric.section_c.math_type === t
                        ? 'bg-primary text-primary-foreground border-primary'
                        : 'border-border text-foreground hover:bg-muted'
                    }`}
                  >
                    Type {t}
                  </button>
                ))}
              </div>
            </div>

            {rubric.section_c.math_type === 'C' && (
              <div className="rounded-lg border border-border bg-card px-4">
                {MATH_C.map(ind => (
                  <IndicatorRow
                    key={ind.code}
                    code={ind.code}
                    label={ind.label}
                    desc={ind.desc}
                    value={(rubric.section_c as any)[ind.code]}
                    onChange={val => setC(ind.code, val)}
                  />
                ))}
              </div>
            )}

            {rubric.section_c.math_type === 'PA' && (
              <div className="rounded-lg border border-border bg-card px-4">
                {MATH_PA.map(ind => (
                  <IndicatorRow
                    key={ind.code}
                    code={ind.code}
                    label={ind.label}
                    desc={ind.desc}
                    value={(rubric.section_c as any)[ind.code]}
                    onChange={val => setC(ind.code, val)}
                  />
                ))}
              </div>
            )}

            {!rubric.section_c.math_type && (
              <p className="text-xs text-muted-foreground text-center py-3">Select a lesson type above to see indicators</p>
            )}
          </div>
        )}

        {subjectCat === 'science' && (
          <div className="rounded-lg border border-border bg-card px-4">
            {SCIENCE_C.map(ind => (
              <IndicatorRow
                key={ind.code}
                code={ind.code}
                label={ind.label}
                desc={ind.desc}
                value={(rubric.section_c as any)[ind.code]}
                onChange={val => setC(ind.code, val)}
              />
            ))}
          </div>
        )}

        {subjectCat === 'literacy' && (
          <div className="rounded-lg border border-border bg-card px-4">
            {LITERACY_C.map(ind => (
              <IndicatorRow
                key={ind.code}
                code={ind.code}
                label={ind.label}
                desc={ind.desc}
                value={(rubric.section_c as any)[ind.code]}
                onChange={val => setC(ind.code, val)}
              />
            ))}
          </div>
        )}

        {subjectCat === 'other' && (
          <div className="rounded-lg border border-dashed border-border bg-muted/20 p-4 text-center">
            <p className="text-sm text-muted-foreground">
              No subject-specific indicators for <strong>{observation.subject}</strong>.<br />
              Only Section B and Section D will be scored.
            </p>
          </div>
        )}
      </div>

      {/* ── Section D — Evidence Markers ──────────────────────────────────── */}
      <div>
        <div className="flex items-center gap-2 mb-1">
          <h3 className="text-sm font-semibold text-foreground">Section D — Student Engagement</h3>
          <Badge variant="outline" className="text-xs text-muted-foreground">Evidence markers · not scored</Badge>
        </div>
        <div className="flex items-start gap-1.5 mb-3 text-xs text-muted-foreground">
          <Info className="w-3 h-3 shrink-0 mt-0.5" />
          <span>These indicators inform observer judgment but are not added to the score.</span>
        </div>
        <div className="rounded-lg border border-border bg-card px-4">
          {SECTION_D.map(ind => (
            <IndicatorRow
              key={ind.code}
              code={ind.code}
              label={ind.label}
              desc={ind.desc}
              value={(rubric.section_d as any)[ind.code]}
              onChange={val => setD(ind.code, val)}
              includeNA
            />
          ))}
        </div>
      </div>

      {/* ── Section E — Mini Assessment ───────────────────────────────────── */}
      <div>
        <div className="flex items-center gap-2 mb-1">
          <h3 className="text-sm font-semibold text-foreground">Section E — Mini Assessment</h3>
          <Badge variant="outline" className="text-xs">5 students · 3 questions</Badge>
        </div>
        <p className="text-xs text-muted-foreground mb-3">
          Sample 5 students after teaching. Ask 3 end-of-lesson questions. Mark each as correct (✓) or incorrect (✗). Tap again to clear.
        </p>

        {eAnswered > 0 && (
          <div className="mb-3 text-xs font-medium text-muted-foreground">
            {eCorrect} / {eTotal} correct
            {eTotal > 0 && <span className="ml-1 text-foreground font-semibold">({Math.round((eCorrect / eTotal) * 100)}%)</span>}
          </div>
        )}

        <div className="rounded-lg border border-border bg-card overflow-hidden">
          <table className="w-full text-sm">
            <thead className="bg-muted/40 border-b border-border">
              <tr>
                <th className="text-left text-xs font-medium text-muted-foreground px-4 py-2">Student</th>
                {['Q1', 'Q2', 'Q3'].map(q => (
                  <th key={q} className="text-center text-xs font-medium text-muted-foreground px-3 py-2">{q}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {rubric.section_e.map((s, i) => (
                <tr key={i} className="border-t border-border first:border-0">
                  <td className="px-4 py-2.5 text-xs font-medium text-foreground">Student {i + 1}</td>
                  {(['q1', 'q2', 'q3'] as const).map(q => (
                    <td key={q} className="px-3 py-2.5 text-center">
                      <button
                        type="button"
                        onClick={() => toggleE(i, q)}
                        className={`w-8 h-7 rounded text-xs font-bold border transition-colors ${
                          s[q] === null
                            ? 'border-border text-muted-foreground/50 hover:bg-muted'
                            : s[q]
                            ? 'bg-green-100 border-green-300 text-green-700'
                            : 'bg-red-100 border-red-300 text-red-700'
                        }`}
                      >
                        {s[q] === null ? '—' : s[q] ? '✓' : '✗'}
                      </button>
                    </td>
                  ))}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      <Button onClick={handleSave} disabled={saving} className="w-full">
        <Save className="w-4 h-4 mr-2" />
        {saving ? 'Saving...' : 'Save FICO Rubric'}
      </Button>
    </div>
  );
}
