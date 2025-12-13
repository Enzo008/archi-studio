/**
 * Servicio de presupuestos - operaciones CRUD, items y catálogos
 */

import { api } from '../client';
import type { Budget, BudgetItem, BudgetStatus, ApiResponse, PaginationParams } from '@/types';

export interface BudgetFilters extends PaginationParams {
  budNam?: string;
  budSta?: string;
  proYea?: string;
  proCod?: string;
}

export const budgetService = {
  /**
   * Obtiene todos los presupuestos (paginado)
   */
  getAll: async (filters: BudgetFilters = {}): Promise<ApiResponse<Budget[]>> => {
    const params = new URLSearchParams();
    if (filters.page) params.append('page', String(filters.page));
    if (filters.pageSize) params.append('pageSize', String(filters.pageSize));
    if (filters.budNam) params.append('budNam', filters.budNam);
    if (filters.budSta) params.append('budSta', filters.budSta);
    if (filters.proYea) params.append('proYea', filters.proYea);
    if (filters.proCod) params.append('proCod', filters.proCod);

    const query = params.toString();
    return api.get<Budget[]>(`/api/budget${query ? `?${query}` : ''}`);
  },

  /**
   * Obtiene un presupuesto por ID (año + código) con sus items
   */
  getById: async (budYea: string, budCod: string): Promise<ApiResponse<Budget>> => {
    return api.get<Budget>(`/api/budget/${budYea}/${budCod}`);
  },

  /**
   * Crea un nuevo presupuesto
   */
  create: async (budget: Partial<Budget>): Promise<ApiResponse<Budget>> => {
    return api.post<Budget>('/api/budget', budget);
  },

  /**
   * Actualiza un presupuesto existente
   */
  update: async (budget: Partial<Budget>): Promise<ApiResponse<Budget>> => {
    return api.put<Budget>('/api/budget', budget);
  },

  /**
   * Elimina un presupuesto (soft delete)
   */
  delete: async (budYea: string, budCod: string): Promise<ApiResponse<void>> => {
    return api.delete<void>(`/api/budget/${budYea}/${budCod}`);
  },

  /**
   * Obtiene el catálogo de estados de presupuesto
   */
  getStatuses: async (): Promise<ApiResponse<BudgetStatus[]>> => {
    return api.get<BudgetStatus[]>('/api/budget/statuses');
  },

  // =============================================
  // Budget Items
  // =============================================

  /**
   * Guarda un item de presupuesto (crea o actualiza)
   */
  saveItem: async (
    budYea: string,
    budCod: string,
    item: Partial<BudgetItem>
  ): Promise<ApiResponse<BudgetItem>> => {
    return api.post<BudgetItem>(`/api/budget/${budYea}/${budCod}/items`, item);
  },

  /**
   * Elimina un item de presupuesto
   */
  deleteItem: async (
    budYea: string,
    budCod: string,
    budIteNum: number
  ): Promise<ApiResponse<void>> => {
    return api.delete<void>(`/api/budget/${budYea}/${budCod}/items/${budIteNum}`);
  },

  /**
   * Sube una imagen para un item de presupuesto
   */
  uploadItemImage: async (
    budYea: string,
    budCod: string,
    budIteNum: number,
    file: File
  ): Promise<ApiResponse<{
    budIteImgPat: string;
    budIteImgFil: string;
    budIteImgSiz: number;
    budIteImgMim: string;
  }>> => {
    const formData = new FormData();
    formData.append('file', file);

    return api.upload(`/api/budget/${budYea}/${budCod}/items/${budIteNum}/image`, formData);
  },

  /**
   * Genera la URL de imagen de un item
   * En local y producción: backend sirve archivos estáticos desde /uploads/
   */
  getItemImageUrl: (budIteImgPat: string): string => {
    if (!budIteImgPat) return '';
    const apiUrl = process.env.NEXT_PUBLIC_API_URL || '';
    return `${apiUrl}/uploads/${budIteImgPat}`;
  },
};
