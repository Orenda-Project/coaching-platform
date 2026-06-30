import jsPDF from 'jspdf';
import type { FeedbackRecord, FeedbackKPIs } from '@/lib/apiClients/adminFeedbackApiClient';

// Colors (RGB tuples)
type RGB = readonly [number, number, number];

const COLORS = {
  primary: [28, 58, 112] as RGB,
  primaryLight: [240, 245, 255] as RGB,
  text: [30, 30, 30] as RGB,
  textMuted: [120, 120, 120] as RGB,
  green: [5, 150, 105] as RGB,
  amber: [217, 119, 6] as RGB,
  red: [220, 38, 38] as RGB,
  border: [210, 215, 225] as RGB,
  cardBg: [248, 250, 252] as RGB,
  white: [255, 255, 255] as RGB,
  starFill: [245, 158, 11] as RGB,
  starEmpty: [200, 200, 200] as RGB,
};

const PAGE = {
  marginLeft: 25,
  marginRight: 25,
  marginTop: 30,
  marginBottom: 35,
  width: 210,
  height: 297,
};

const contentWidth = PAGE.width - PAGE.marginLeft - PAGE.marginRight;

function formatDate(iso: string): string {
  return new Date(iso).toLocaleDateString('en-GB', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
  });
}

function formatDateTime(date: Date): string {
  return date.toLocaleDateString('en-GB', {
    day: '2-digit',
    month: 'long',
    year: 'numeric',
  }) + ' at ' + date.toLocaleTimeString('en-GB', {
    hour: '2-digit',
    minute: '2-digit',
  });
}

function addPageFooter(doc: jsPDF, pageNum: number, totalPages: number) {
  const y = PAGE.height - 15;
  doc.setFontSize(8);
  doc.setTextColor(...COLORS.textMuted);
  doc.text(`Page ${pageNum} of ${totalPages}`, PAGE.width / 2, y, { align: 'center' });
  doc.text('Taleemabad Coaching Platform', PAGE.marginLeft, y);
}

function ensureSpace(doc: jsPDF, y: number, needed: number): number {
  if (y + needed > PAGE.height - PAGE.marginBottom) {
    doc.addPage();
    return PAGE.marginTop;
  }
  return y;
}

function drawRoundedRect(
  doc: jsPDF,
  x: number, y: number, w: number, h: number, r: number,
  fillColor: RGB,
  borderColor?: RGB,
) {
  doc.setFillColor(...fillColor);
  if (borderColor) {
    doc.setDrawColor(...borderColor);
    doc.setLineWidth(0.3);
    doc.roundedRect(x, y, w, h, r, r, 'FD');
  } else {
    doc.roundedRect(x, y, w, h, r, r, 'F');
  }
}

function drawStars(doc: jsPDF, x: number, y: number, rating: number) {
  const radius = 1.4;
  const gap = 4;
  for (let i = 0; i < 5; i++) {
    const cx = x + i * gap;
    const cy = y - 1.2;
    if (i < rating) {
      doc.setFillColor(...COLORS.starFill);
      doc.circle(cx, cy, radius, 'F');
    } else {
      doc.setDrawColor(...COLORS.starEmpty);
      doc.setLineWidth(0.3);
      doc.circle(cx, cy, radius, 'S');
    }
  }
  // Show rating as text next to dots
  doc.setFontSize(7);
  doc.setTextColor(...COLORS.textMuted);
  doc.text(`${rating}/5`, x + 5 * gap + 1, y);
}

function drawKpiCard(
  doc: jsPDF,
  x: number, y: number, w: number,
  label: string,
  value: string,
  valueColor: RGB = COLORS.primary,
) {
  drawRoundedRect(doc, x, y, w, 22, 2, COLORS.cardBg, COLORS.border);
  doc.setFontSize(8);
  doc.setTextColor(...COLORS.textMuted);
  doc.text(label, x + w / 2, y + 8, { align: 'center' });
  doc.setFontSize(16);
  doc.setFont('helvetica', 'bold');
  doc.setTextColor(...valueColor);
  doc.text(value, x + w / 2, y + 18, { align: 'center' });
  doc.setFont('helvetica', 'normal');
}

/** Wraps text and draws it, returning the new y position after all lines. */
function drawWrappedText(
  doc: jsPDF,
  text: string,
  x: number, y: number,
  maxWidth: number,
  fontSize: number,
  color: RGB,
  lineHeight: number = 4.2,
): number {
  doc.setFontSize(fontSize);
  doc.setTextColor(...color);
  const lines: string[] = doc.splitTextToSize(text, maxWidth);

  for (const line of lines) {
    y = ensureSpace(doc, y, lineHeight);
    doc.text(line, x, y);
    y += lineHeight;
  }
  return y;
}

function drawSeparator(doc: jsPDF, y: number): number {
  doc.setDrawColor(...COLORS.border);
  doc.setLineWidth(0.3);
  doc.line(PAGE.marginLeft + 4, y, PAGE.width - PAGE.marginRight - 4, y);
  return y + 5;
}

export async function exportFeedbackToPdf(
  feedback: FeedbackRecord[],
  kpis: FeedbackKPIs | null,
  dateRangeLabel: string,
): Promise<void> {
  const doc = new jsPDF('p', 'mm', 'a4');
  const sorted = [...feedback].sort(
    (a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime(),
  );

  let y = PAGE.marginTop;

  // --- Header ---
  drawRoundedRect(doc, PAGE.marginLeft, y, contentWidth, 18, 2, COLORS.primary);
  doc.setFontSize(18);
  doc.setFont('helvetica', 'bold');
  doc.setTextColor(...COLORS.white);
  doc.text('Feedback Report', PAGE.width / 2, y + 12, { align: 'center' });
  doc.setFont('helvetica', 'normal');
  y += 24;

  // Generated / Period
  doc.setFontSize(9);
  doc.setTextColor(...COLORS.textMuted);
  doc.text(`Generated: ${formatDateTime(new Date())}`, PAGE.marginLeft, y);
  doc.text(`Period: ${dateRangeLabel}`, PAGE.width - PAGE.marginRight, y, { align: 'right' });
  y += 8;

  // --- KPI Summary ---
  if (kpis) {
    const cardW = (contentWidth - 8) / 3;
    const gap = 4;
    drawKpiCard(doc, PAGE.marginLeft, y, cardW, 'Total Feedback', String(kpis.totalFeedback));
    drawKpiCard(doc, PAGE.marginLeft + cardW + gap, y, cardW, 'Avg Rating', kpis.avgRating.toFixed(1) + ' / 5');
    drawKpiCard(
      doc,
      PAGE.marginLeft + 2 * (cardW + gap), y, cardW,
      'Low Ratings (<= 2)',
      String(kpis.lowRatingCount),
      COLORS.red,
    );
    y += 30;
  }

  // Divider
  doc.setDrawColor(...COLORS.border);
  doc.setLineWidth(0.4);
  doc.line(PAGE.marginLeft, y, PAGE.width - PAGE.marginRight, y);
  y += 6;

  // Section heading
  doc.setFontSize(12);
  doc.setFont('helvetica', 'bold');
  doc.setTextColor(...COLORS.primary);
  doc.text(`Feedback Entries (${sorted.length})`, PAGE.marginLeft, y);
  doc.setFont('helvetica', 'normal');
  y += 8;

  // --- Entries ---
  const catColors: Record<string, RGB> = {
    module: [37, 99, 235],
    platform: [5, 150, 105],
    bug: [220, 38, 38],
    other: [120, 120, 120],
  };

  for (let i = 0; i < sorted.length; i++) {
    const item = sorted[i];
    const coachName = item.profiles?.full_name || item.profiles?.phone || 'Unknown';
    const coachContact = item.profiles?.email || item.profiles?.phone || '';

    // Ensure at least 30mm for the entry header before starting
    y = ensureSpace(doc, y, 30);

    // Coach name + index
    doc.setFontSize(10);
    doc.setFont('helvetica', 'bold');
    doc.setTextColor(...COLORS.text);
    doc.text(`${i + 1}. ${coachName}`, PAGE.marginLeft + 2, y);

    // Date right-aligned
    doc.setFontSize(8);
    doc.setFont('helvetica', 'normal');
    doc.setTextColor(...COLORS.textMuted);
    doc.text(formatDate(item.created_at), PAGE.width - PAGE.marginRight - 2, y, { align: 'right' });
    y += 5;

    // Contact info
    if (coachContact && coachContact !== coachName) {
      doc.setFontSize(8);
      doc.setTextColor(...COLORS.textMuted);
      doc.text(coachContact, PAGE.marginLeft + 6, y);
    }

    // Category badge
    const badgeX = PAGE.marginLeft + 70;
    const catColor = catColors[item.category] || COLORS.textMuted;
    doc.setFontSize(7);
    const catLabel = item.category.charAt(0).toUpperCase() + item.category.slice(1);
    const badgeW = doc.getTextWidth(catLabel) + 6;
    drawRoundedRect(doc, badgeX, y - 3.5, badgeW, 5, 1, COLORS.primaryLight, catColor);
    doc.setTextColor(...catColor);
    doc.text(catLabel, badgeX + 3, y);

    // Stars
    drawStars(doc, badgeX + badgeW + 5, y, item.rating);

    // Persona
    if (item.persona) {
      doc.setFontSize(7);
      doc.setTextColor(...COLORS.textMuted);
      doc.text(`Persona ${item.persona}`, PAGE.width - PAGE.marginRight - 2, y, { align: 'right' });
    }
    y += 7;

    // Positive feedback
    if (item.positive_feedback) {
      y = ensureSpace(doc, y, 10);
      doc.setFontSize(8);
      doc.setFont('helvetica', 'bold');
      doc.setTextColor(...COLORS.green);
      doc.text('What worked well:', PAGE.marginLeft + 6, y);
      doc.setFont('helvetica', 'normal');
      y += 4;
      y = drawWrappedText(doc, item.positive_feedback, PAGE.marginLeft + 6, y, contentWidth - 12, 9, COLORS.text);
      y += 2;
    }

    // Improvement feedback
    if (item.improvement_feedback) {
      y = ensureSpace(doc, y, 10);
      doc.setFontSize(8);
      doc.setFont('helvetica', 'bold');
      doc.setTextColor(...COLORS.amber);
      doc.text('What could be improved:', PAGE.marginLeft + 6, y);
      doc.setFont('helvetica', 'normal');
      y += 4;
      y = drawWrappedText(doc, item.improvement_feedback, PAGE.marginLeft + 6, y, contentWidth - 12, 9, COLORS.text);
      y += 2;
    }

    // No text
    if (!item.positive_feedback && !item.improvement_feedback) {
      doc.setFontSize(8);
      doc.setTextColor(...COLORS.textMuted);
      doc.text('(No text feedback)', PAGE.marginLeft + 6, y);
      y += 5;
    }

    // Context page
    doc.setFontSize(7);
    doc.setTextColor(...COLORS.textMuted);
    doc.text(`Context: ${item.context_page}`, PAGE.marginLeft + 6, y);
    y += 5;

    // Separator between entries
    if (i < sorted.length - 1) {
      y = drawSeparator(doc, y);
    }
  }

  // --- Page numbers ---
  const totalPages = doc.getNumberOfPages();
  for (let p = 1; p <= totalPages; p++) {
    doc.setPage(p);
    addPageFooter(doc, p, totalPages);
  }

  // --- Download ---
  const dateStr = new Date().toISOString().split('T')[0];
  doc.save(`feedback-report-${dateStr}.pdf`);
}
