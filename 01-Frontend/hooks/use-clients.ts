/**
 * Hooks de TanStack Query para clientes
 * Uses centralized cache config (DRY principle)
 */
'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { clientService, type ClientFilters } from '@/lib/api/services';
import type { Client } from '@/types';
import { toast } from 'sonner';
import { useAuthReady } from './use-auth-ready';
import { QUERY_CACHE_LISTS, QUERY_CACHE_DETAILS } from '@/lib/config/query-cache';
import { dashboardKeys } from './use-dashboard-data';

// Query Keys Factory
export const clientKeys = {
  all: ['clients'] as const,
  lists: () => [...clientKeys.all, 'list'] as const,
  list: (filters: ClientFilters) => [...clientKeys.lists(), filters] as const,
  details: () => [...clientKeys.all, 'detail'] as const,
  detail: (cliYea: string, cliCod: string) => [...clientKeys.details(), cliYea, cliCod] as const,
};

/**
 * Hook para obtener lista de clientes
 */
export function useClients(filters: ClientFilters = {}) {
  const { isReady } = useAuthReady();

  return useQuery({
    queryKey: clientKeys.list(filters),
    queryFn: () => clientService.getAll(filters),
    enabled: isReady,
    ...QUERY_CACHE_LISTS,
    select: (response) => ({
      clients: response.data,
      success: response.success,
      message: response.message,
    }),
  });
}

/**
 * Hook para obtener un cliente por ID
 */
export function useClient(cliYea: string, cliCod: string) {
  const { isReady } = useAuthReady();

  return useQuery({
    queryKey: clientKeys.detail(cliYea, cliCod),
    queryFn: () => clientService.getById(cliYea, cliCod),
    enabled: isReady && !!cliYea && !!cliCod,
    ...QUERY_CACHE_DETAILS,
    select: (response) => response.data,
  });
}

/**
 * Hook para crear cliente
 */
export function useCreateClient() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: Partial<Client>) => clientService.create(data),
    onSuccess: (response) => {
      queryClient.invalidateQueries({ queryKey: clientKeys.lists() });
      queryClient.invalidateQueries({ queryKey: dashboardKeys.all });
      toast.success(response.message || 'Cliente creado correctamente');
    },
    onError: (error: Error) => {
      toast.error(error.message || 'Error al crear cliente');
    },
  });
}

/**
 * Hook para actualizar cliente
 */
export function useUpdateClient() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: Partial<Client>) => clientService.update(data),
    onSuccess: (response, variables) => {
      queryClient.invalidateQueries({ queryKey: clientKeys.lists() });
      queryClient.invalidateQueries({ queryKey: dashboardKeys.all });
      if (variables.cliYea && variables.cliCod) {
        queryClient.invalidateQueries({
          queryKey: clientKeys.detail(variables.cliYea, variables.cliCod),
        });
      }
      toast.success(response.message || 'Cliente actualizado correctamente');
    },
    onError: (error: Error) => {
      toast.error(error.message || 'Error al actualizar cliente');
    },
  });
}

/**
 * Hook para eliminar cliente
 */
export function useDeleteClient() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ cliYea, cliCod }: { cliYea: string; cliCod: string }) =>
      clientService.delete(cliYea, cliCod),
    onSuccess: (response) => {
      queryClient.invalidateQueries({ queryKey: clientKeys.lists() });
      queryClient.invalidateQueries({ queryKey: dashboardKeys.all });
      toast.success(response.message || 'Cliente eliminado correctamente');
    },
    onError: (error: Error) => {
      toast.error(error.message || 'Error al eliminar cliente');
    },
  });
}
