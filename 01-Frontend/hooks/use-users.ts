/**
 * Hook para CRUD de usuarios con TanStack Query
 */
'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { userService } from '@/lib/api/services/user-service';
import { toast } from 'sonner';
import type { User } from '@/types';

interface UseUsersParams {
  page?: number;
  pageSize?: number;
}

// Query keys factory
export const userKeys = {
  all: ['users'] as const,
  lists: () => [...userKeys.all, 'list'] as const,
  list: (params: UseUsersParams) => [...userKeys.lists(), params] as const,
  details: () => [...userKeys.all, 'detail'] as const,
  detail: (useYea: string, useCod: string) => [...userKeys.details(), useYea, useCod] as const,
};

/**
 * Hook para obtener lista de usuarios paginada
 */
export function useUsers(params: UseUsersParams = {}) {
  const { page = 1, pageSize = 20 } = params;

  return useQuery({
    queryKey: userKeys.list({ page, pageSize }),
    queryFn: async () => {
      const response = await userService.getAll(page, pageSize);
      if (!response.success) {
        throw new Error(response.message || 'Error al cargar usuarios');
      }
      return {
        users: response.data || [],
        total: response.data?.length || 0,
      };
    },
  });
}

/**
 * Hook para obtener un usuario por ID
 */
export function useUser(useYea: string, useCod: string) {
  return useQuery({
    queryKey: userKeys.detail(useYea, useCod),
    queryFn: async () => {
      const response = await userService.getById(useYea, useCod);
      if (!response.success) {
        throw new Error(response.message || 'Error al cargar usuario');
      }
      return response.data;
    },
    enabled: !!useYea && !!useCod,
  });
}

/**
 * Hook para actualizar un usuario
 */
export function useUpdateUser() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (user: Partial<User>) => {
      const response = await userService.update(user);
      if (!response.success) {
        throw new Error(response.message || 'Error al actualizar usuario');
      }
      return response.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: userKeys.all });
      toast.success('Usuario actualizado correctamente');
    },
    onError: (error: Error) => {
      toast.error(error.message);
    },
  });
}
