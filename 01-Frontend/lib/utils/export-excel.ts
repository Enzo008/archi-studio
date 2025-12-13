/**
 * Utilidad para exportar datos a Excel usando SheetJS
 * Soporta múltiples formatos y estilos básicos
 */

import * as XLSX from 'xlsx';
import { saveAs } from 'file-saver';

interface ExportColumn<T> {
  header: string;
  key: keyof T & string;
  width?: number;
  format?: (value: unknown, item: T) => string | number;
}

interface ExportOptions<T> {
  data: T[];
  columns: ExportColumn<T>[];
  filename: string;
  sheetName?: string;
}

/**
 * Exporta datos a un archivo Excel (.xlsx)
 */
export function exportToExcel<T>({
  data,
  columns,
  filename,
  sheetName = 'Datos',
}: ExportOptions<T>): void {
  // Crear headers
  const headers = columns.map((col) => col.header);

  // Crear filas de datos
  const rows = data.map((item) =>
    columns.map((col) => {
      const value = (item as Record<string, unknown>)[col.key];
      if (col.format) {
        return col.format(value, item);
      }
      if (value === null || value === undefined) {
        return '';
      }
      return String(value);
    })
  );

  // Crear worksheet
  const worksheet = XLSX.utils.aoa_to_sheet([headers, ...rows]);

  // Configurar anchos de columna
  worksheet['!cols'] = columns.map((col) => ({
    wch: col.width || 15,
  }));

  // Crear workbook
  const workbook = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(workbook, worksheet, sheetName);

  // Generar archivo y descargar
  const excelBuffer = XLSX.write(workbook, {
    bookType: 'xlsx',
    type: 'array',
  });

  const blob = new Blob([excelBuffer], {
    type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  });

  saveAs(blob, `${filename}.xlsx`);
}

/**
 * Configuraciones predefinidas para exportar proyectos
 */
export const projectExportColumns = [
  { header: 'Código', key: 'proCod' as const, width: 12 },
  { header: 'Nombre', key: 'proNam' as const, width: 30 },
  { header: 'Cliente', key: 'cliNam' as const, width: 25 },
  { header: 'Estado', key: 'proStaNam' as const, width: 15 },
  { header: 'Avance %', key: 'proPro' as const, width: 10 },
  { header: 'Presupuesto', key: 'proBudget' as const, width: 15 },
  { header: 'Fecha Inicio', key: 'proDatIni' as const, width: 12 },
  { header: 'Fecha Fin', key: 'proDatEnd' as const, width: 12 },
];

/**
 * Configuraciones predefinidas para exportar presupuestos
 */
export const budgetExportColumns = [
  { header: 'Código', key: 'budCod' as const, width: 12 },
  { header: 'Nombre', key: 'budNam' as const, width: 30 },
  { header: 'Proyecto', key: 'proNam' as const, width: 25 },
  { header: 'Estado', key: 'budStaNam' as const, width: 15 },
  { header: 'Total', key: 'budTot' as const, width: 15 },
  { header: 'Fecha', key: 'budDat' as const, width: 12 },
  { header: 'Vencimiento', key: 'budExp' as const, width: 12 },
];

/**
 * Configuraciones predefinidas para exportar clientes
 */
export const clientExportColumns = [
  { header: 'Código', key: 'cliCod' as const, width: 12 },
  { header: 'Nombre', key: 'cliNam' as const, width: 30 },
  { header: 'Tipo', key: 'cliTyp' as const, width: 12 },
  { header: 'Email', key: 'cliEma' as const, width: 30 },
  { header: 'Teléfono', key: 'cliPho' as const, width: 15 },
  { header: 'Dirección', key: 'cliAdd' as const, width: 35 },
  { header: 'Estado', key: 'cliSta' as const, width: 10 },
];
