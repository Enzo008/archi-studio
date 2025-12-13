/**
 * Servicio de roles - CRUD de roles del sistema
 */

import { api } from '../client';
import type { Role, ApiResponse } from '@/types';

export const roleService = {
  /**
   * Obtiene todos los roles
   */
  getAll: async (): Promise<ApiResponse<Role[]>> => {
    return api.get<Role[]>('/api/role');
  },

  /**
   * Crea o actualiza un rol
   */
  upsert: async (role: Partial<Role>): Promise<ApiResponse<Role>> => {
    return api.post<Role>('/api/role', role);
  },
};
