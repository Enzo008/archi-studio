/**
 * Servicio de usuarios - sincronización con Clerk y CRUD
 */

import { api } from '../client';
import type { User, SyncUserRequest, SyncUserResponse, ApiResponse } from '@/types';

export const userService = {
  /**
   * Sincroniza usuario desde Clerk al backend
   */
  sync: async (data: SyncUserRequest): Promise<ApiResponse<SyncUserResponse>> => {
    return api.post<SyncUserResponse>('/api/user/sync', data);
  },

  /**
   * Obtiene todos los usuarios (paginado)
   */
  getAll: async (page = 1, pageSize = 10): Promise<ApiResponse<User[]>> => {
    return api.get<User[]>(`/api/user?page=${page}&pageSize=${pageSize}`);
  },

  /**
   * Obtiene un usuario por ID
   */
  getById: async (useYea: string, useCod: string): Promise<ApiResponse<User>> => {
    return api.get<User>(`/api/user/${useYea}/${useCod}`);
  },

  /**
   * Actualiza un usuario
   */
  update: async (user: Partial<User>): Promise<ApiResponse<User>> => {
    return api.put<User>('/api/user', user);
  },
};
