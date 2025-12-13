/**
 * useExport Hook - Generic hook for export functionality
 * Applies DRY principle by centralizing export logic
 */
'use client';

import { useCallback, useState } from 'react';
import { toast } from 'sonner';

interface UseExportOptions<T> {
    data: T[];
    entityName: string;
    exportPdf: (data: T[], filename: string) => Promise<void>;
    exportExcel: (data: T[], filename: string) => void;
}

interface UseExportReturn {
    isExporting: boolean;
    handleExportPDF: () => Promise<void>;
    handleExportExcel: () => void;
    canExport: boolean;
}

/**
 * Generic hook for export functionality (PDF/Excel)
 * Reduces boilerplate across pages and provides consistent UX
 */
export function useExport<T>({
    data,
    entityName,
    exportPdf,
    exportExcel,
}: UseExportOptions<T>): UseExportReturn {
    const [isExporting, setIsExporting] = useState(false);

    const getFilename = useCallback(() => {
        const date = new Date().toISOString().split('T')[0];
        return `${entityName.toLowerCase()}-${date}`;
    }, [entityName]);

    const handleExportPDF = useCallback(async () => {
        if (data.length === 0) {
            toast.warning(`No hay ${entityName.toLowerCase()} para exportar`);
            return;
        }

        setIsExporting(true);
        try {
            await exportPdf(data, getFilename());
            toast.success(`${entityName} exportados a PDF correctamente`);
        } catch (error) {
            console.error('Error exporting PDF:', error);
            toast.error(`Error al exportar ${entityName.toLowerCase()} a PDF`);
        } finally {
            setIsExporting(false);
        }
    }, [data, entityName, exportPdf, getFilename]);

    const handleExportExcel = useCallback(() => {
        if (data.length === 0) {
            toast.warning(`No hay ${entityName.toLowerCase()} para exportar`);
            return;
        }

        try {
            exportExcel(data, getFilename());
            toast.success(`${entityName} exportados a Excel correctamente`);
        } catch (error) {
            console.error('Error exporting Excel:', error);
            toast.error(`Error al exportar ${entityName.toLowerCase()} a Excel`);
        }
    }, [data, entityName, exportExcel, getFilename]);

    return {
        isExporting,
        handleExportPDF,
        handleExportExcel,
        canExport: data.length > 0,
    };
}
