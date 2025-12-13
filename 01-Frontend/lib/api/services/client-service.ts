/**
 * Servicio de clientes - operaciones CRUD
 */

import { api } from '../client';
import type { Client, ApiResponse, PaginationParams } from '@/types';

export interface ClientFilters extends PaginationParams {
  cliNam?: string;
  cliTyp?: string;
  cliSta?: string;
}

export const clientService = {
  /**
   * Obtiene todos los clientes (paginado)
   */
  getAll: async (filters: ClientFilters = {}): Promise<ApiResponse<Client[]>> => {
    const params = new URLSearchParams();
    if (filters.page) params.append('page', String(filters.page));
    if (filters.pageSize) params.append('pageSize', String(filters.pageSize));
    if (filters.cliNam) params.append('cliNam', filters.cliNam);
    if (filters.cliTyp) params.append('cliTyp', filters.cliTyp);
    if (filters.cliSta) params.append('cliSta', filters.cliSta);
    
    const query = params.toString();
    return api.get<Client[]>(`/api/client${query ? `?${query}` : ''}`);
  },

  /**
   * Obtiene un cliente por ID (año + código)
   */
  getById: async (cliYea: string, cliCod: string): Promise<ApiResponse<Client>> => {
    return api.get<Client>(`/api/client/${cliYea}/${cliCod}`);
  },

  /**
   * Crea un nuevo cliente
   */
  create: async (client: Partial<Client>): Promise<ApiResponse<Client>> => {
    return api.post<Client>('/api/client', client);
  },

  /**
   * Actualiza un cliente existente
   */
  update: async (client: Partial<Client>): Promise<ApiResponse<Client>> => {
    return api.put<Client>('/api/client', client);
  },

  /**
   * Elimina un cliente (soft delete)
   */
  delete: async (cliYea: string, cliCod: string): Promise<ApiResponse<void>> => {
    return api.delete<void>(`/api/client/${cliYea}/${cliCod}`);
  },
};
