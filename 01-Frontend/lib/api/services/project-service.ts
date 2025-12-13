/**
 * Servicio de proyectos - operaciones CRUD y catálogos
 */

import { api } from '../client';
import type { Project, ProjectStatus, ApiResponse, PaginationParams } from '@/types';

export interface ProjectFilters extends PaginationParams {
  proNam?: string;
  proSta?: string;
  cliYea?: string;
  cliCod?: string;
}

export const projectService = {
  /**
   * Obtiene todos los proyectos (paginado)
   */
  getAll: async (filters: ProjectFilters = {}): Promise<ApiResponse<Project[]>> => {
    const params = new URLSearchParams();
    if (filters.page) params.append('page', String(filters.page));
    if (filters.pageSize) params.append('pageSize', String(filters.pageSize));
    if (filters.proNam) params.append('proNam', filters.proNam);
    if (filters.proSta) params.append('proSta', filters.proSta);
    if (filters.cliYea) params.append('cliYea', filters.cliYea);
    if (filters.cliCod) params.append('cliCod', filters.cliCod);
    
    const query = params.toString();
    return api.get<Project[]>(`/api/project${query ? `?${query}` : ''}`);
  },

  /**
   * Obtiene un proyecto por ID (año + código)
   */
  getById: async (proYea: string, proCod: string): Promise<ApiResponse<Project>> => {
    return api.get<Project>(`/api/project/${proYea}/${proCod}`);
  },

  /**
   * Crea un nuevo proyecto
   */
  create: async (project: Partial<Project>): Promise<ApiResponse<Project>> => {
    return api.post<Project>('/api/project', project);
  },

  /**
   * Actualiza un proyecto existente
   */
  update: async (project: Partial<Project>): Promise<ApiResponse<Project>> => {
    return api.put<Project>('/api/project', project);
  },

  /**
   * Elimina un proyecto (soft delete)
   */
  delete: async (proYea: string, proCod: string): Promise<ApiResponse<void>> => {
    return api.delete<void>(`/api/project/${proYea}/${proCod}`);
  },

  /**
   * Obtiene el catálogo de estados de proyecto
   */
  getStatuses: async (): Promise<ApiResponse<ProjectStatus[]>> => {
    return api.get<ProjectStatus[]>('/api/project/statuses');
  },
};
