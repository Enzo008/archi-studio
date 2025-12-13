/**
 * Hook para gestión de roles
 */
'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { roleService } from '@/lib/api/services/role-service';
import { toast } from 'sonner';
import type { Role } from '@/types';

const roleKeys = {
  all: ['roles'] as const,
  list: () => [...roleKeys.all, 'list'] as const,
};

/**
 * Hook para obtener todos los roles
 */
export function useRoles() {
  return useQuery({
    queryKey: roleKeys.list(),
    queryFn: async () => {
      const response = await roleService.getAll();
      return response.data || [];
    },
    staleTime: 5 * 60 * 1000,
  });
}

/**
 * Hook para crear o actualizar un rol
 */
export function useUpsertRole() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (role: Partial<Role>) => roleService.upsert(role),
    onSuccess: (response) => {
      queryClient.invalidateQueries({ queryKey: roleKeys.all });
      toast.success(response.message || 'Rol guardado correctamente');
    },
    onError: (error: Error) => {
      toast.error(error.message || 'Error al guardar rol');
    },
  });
}
