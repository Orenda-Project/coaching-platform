import ExcelJS from 'exceljs';

interface CoachExportData {
  full_name: string | null;
  phone: string;
  region: string | null;
  school_id: string | null;
  persona: string | null;
  baseline_score: number | null;
  endline_score: number | null;
}

const REGION_LABELS: Record<string, string> = {
  "islamabad": "Islamabad (ICT)",
  "balochistan": "Balochistan",
  "punjab": "Punjab",
  "rawalpindi": "Rawalpindi (Rwp)",
};

// Header colors - vibrant and professional
const HEADER_COLORS: Record<number, string> = {
  0: "1C3A70", // Coach Name - Dark Blue
  1: "2E5090", // Region - Medium Blue
  2: "3A6BB5", // School - Light Blue
  3: "0D5D3F", // Persona - Dark Green
  4: "D97706", // Baseline Score - Amber
  5: "059669", // Endline Score - Emerald
};

// Persona colors - vibrant with better contrast
const PERSONA_COLORS: Record<string, string> = {
  "A": "34D399", // Emerald Green
  "B": "60A5FA", // Blue
  "C": "FBBF24", // Amber
  "D": "F97316", // Orange
};

const PERSONA_TEXT_COLORS: Record<string, string> = {
  "A": "065F46",
  "B": "1E3A8A",
  "C": "78350F",
  "D": "7C2D12",
};

// Helper function to get coach identifier (name or phone fallback)
const getCoachIdentifier = (coach: CoachExportData): string => {
  if (coach.full_name && coach.full_name.trim()) {
    return coach.full_name;
  }
  if (coach.phone && coach.phone.trim()) {
    return coach.phone;
  }
  return "NULL";
};

// Helper function to format cell values
const formatCellValue = (value: any): string => {
  if (value === null || value === undefined) {
    return "NULL";
  }
  if (typeof value === "string" && !value.trim()) {
    return "NULL";
  }
  return String(value);
};

export async function exportCoachDataToExcel(coaches: CoachExportData[], filename: string = "coaching-analytics") {
  const workbook = new ExcelJS.Workbook();
  const worksheet = workbook.addWorksheet("Analytics");

  const headers = ["Coach Name", "Region", "School", "Persona", "Baseline Score", "Endline Score"];

  // Add headers
  const headerRow = worksheet.addRow(headers);

  // Set column widths
  worksheet.columns = [
    { width: 28 }, // Coach Name
    { width: 22 }, // Region
    { width: 28 }, // School
    { width: 14 }, // Persona
    { width: 18 }, // Baseline Score
    { width: 18 }, // Endline Score
  ];

  // Style header row with individual colors
  headerRow.height = 32;
  headerRow.eachCell((cell, colNumber) => {
    cell.fill = {
      type: "pattern",
      pattern: "solid",
      fgColor: { argb: "FF" + HEADER_COLORS[colNumber - 1] },
    };
    cell.font = {
      bold: true,
      color: { argb: "FFFFFFFF" },
      size: 13,
      name: "Calibri",
    };
    cell.alignment = {
      horizontal: "center",
      vertical: "middle",
      wrapText: true,
    };
    cell.border = {
      top: { style: "medium", color: { argb: "FF000000" } },
      bottom: { style: "thick", color: { argb: "FF000000" } },
      left: { style: "thin", color: { argb: "FF000000" } },
      right: { style: "thin", color: { argb: "FF000000" } },
    };
  });

  // Add data rows
  coaches.forEach((coach, rowIdx) => {
    const rowData = [
      getCoachIdentifier(coach),
      formatCellValue(REGION_LABELS[coach.region || ""] || coach.region),
      formatCellValue(coach.school_id),
      formatCellValue(coach.persona),
      coach.baseline_score !== null ? coach.baseline_score : "NULL",
      coach.endline_score !== null ? coach.endline_score : "NULL",
    ];

    const row = worksheet.addRow(rowData);
    const isEvenRow = rowIdx % 2 === 0;
    const rowColor = isEvenRow ? "FFFFFFFF" : "FFF0F9FF"; // Alternate white and light blue

    row.eachCell((cell, colNumber) => {
      const cellValue = String(rowData[colNumber - 1]);

      // Base styling for all cells
      cell.fill = {
        type: "pattern",
        pattern: "solid",
        fgColor: { argb: rowColor },
      };
      cell.border = {
        top: { style: "thin", color: { argb: "FFD1D5DB" } },
        bottom: { style: "thin", color: { argb: "FFD1D5DB" } },
        left: { style: "thin", color: { argb: "FFD1D5DB" } },
        right: { style: "thin", color: { argb: "FFD1D5DB" } },
      };
      cell.alignment = {
        vertical: "middle",
        horizontal: colNumber === 1 ? "left" : "center",
      };
      cell.font = {
        size: 11,
        name: "Calibri",
        color: { argb: cellValue === "NULL" ? "FF9CA3AF" : "FF000000" },
      };

      // Persona column - apply vibrant persona colors
      if (colNumber === 4) {
        if (cellValue !== "NULL" && PERSONA_COLORS[cellValue]) {
          cell.fill = {
            type: "pattern",
            pattern: "solid",
            fgColor: { argb: "FF" + PERSONA_COLORS[cellValue] },
          };
          cell.font = {
            bold: true,
            size: 11,
            name: "Calibri",
            color: { argb: "FF" + PERSONA_TEXT_COLORS[cellValue] },
          };
        }
      }
      // Score columns - bold
      else if (colNumber === 5 || colNumber === 6) {
        cell.font = {
          bold: true,
          size: 11,
          name: "Calibri",
          color: { argb: cellValue === "NULL" ? "FF9CA3AF" : "FF000000" },
        };
      }
    });
  });

  // Freeze header row
  worksheet.views = [{ state: "frozen", ySplit: 1 }];

  // Generate filename with date
  const dateStr = new Date().toISOString().split("T")[0];
  const finalFilename = `${filename}-${dateStr}.xlsx`;

  // Write file
  const buffer = await workbook.xlsx.writeBuffer();
  const blob = new Blob([buffer], {
    type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
  });
  const url = URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.href = url;
  link.download = finalFilename;
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
  URL.revokeObjectURL(url);
}
