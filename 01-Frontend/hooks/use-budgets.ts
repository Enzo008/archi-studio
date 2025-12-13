/**
 * Hooks de TanStack Query para presupuestos
 * Uses centralized cache config (DRY principle)
 */
'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { budgetService, type BudgetFilters } from '@/lib/api/services';
import type { Budget, BudgetItem } from '@/types';
import { toast } from 'sonner';
import { useAuthReady } from './use-auth-ready';
import { QUERY_CACHE_LISTS, QUERY_CACHE_CATALOGS, QUERY_CACHE_DETAILS } from '@/lib/config/query-cache';
import { dashboardKeys } from './use-dashboard-data';

// Query Keys Factory
export const budgetKeys = {
  all: ['budgets'] as const,
  lists: () => [...budgetKeys.all, 'list'] as const,
  list: (filters: BudgetFilters) => [...budgetKeys.lists(), filters] as const,
  details: () => [...budgetKeys.all, 'detail'] as const,
  detail: (budYea: string, budCod: string) => [...budgetKeys.details(), budYea, budCod] as const,
  statuses: () => [...budgetKeys.all, 'statuses'] as const,
};

/**
 * Hook para obtener lista de presupuestos
 */
export function useBudgets(filters: BudgetFilters = {}) {
  const { isReady } = useAuthReady();

  return useQuery({
    queryKey: budgetKeys.list(filters),
    queryFn: () => budgetService.getAll(filters),
    enabled: isReady,
    ...QUERY_CACHE_LISTS,
    select: (response) => ({
      budgets: response.data,
      success: response.success,
      message: response.message,
    }),
  });
}

/**
 * Hook para obtener un presupuesto por ID (con items)
 */
export function useBudget(budYea: string, budCod: string) {
  const { isReady } = useAuthReady();

  return useQuery({
    queryKey: budgetKeys.detail(budYea, budCod),
    queryFn: () => budgetService.getById(budYea, budCod),
    enabled: isReady && !!budYea && !!budCod,
    ...QUERY_CACHE_DETAILS,
    select: (response) => response.data,
  });
}

/**
 * Hook para obtener catálogo de estados
 */
export function useBudgetStatuses() {
  const { isReady } = useAuthReady();

  return useQuery({
    queryKey: budgetKeys.statuses(),
    queryFn: () => budgetService.getStatuses(),
    enabled: isReady,
    ...QUERY_CACHE_CATALOGS,
    select: (response) => response.data,
  });
}

/**
 * Hook para crear presupuesto
 */
export function useCreateBudget() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: Partial<Budget>) => budgetService.create(data),
    onSuccess: (response) => {
      queryClient.invalidateQueries({ queryKey: budgetKeys.lists() });
      queryClient.invalidateQueries({ queryKey: dashboardKeys.all }); // Refresh dashboard
      toast.success(response.message || 'Presupuesto creado correctamente');
    },
    onError: (error: Error) => {
      toast.error(error.message || 'Error al crear presupuesto');
    },
  });
}

/**
 * Hook para actualizar presupuesto
 */
export function useUpdateBudget() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: Partial<Budget>) => budgetService.update(data),
    onSuccess: (response, variables) => {
      queryClient.invalidateQueries({ queryKey: budgetKeys.lists() });
      queryClient.invalidateQueries({ queryKey: dashboardKeys.all }); // Refresh dashboard
      if (variables.budYea && variables.budCod) {
        queryClient.invalidateQueries({
          queryKey: budgetKeys.detail(variables.budYea, variables.budCod),
        });
      }
      toast.success(response.message || 'Presupuesto actualizado correctamente');
    },
    onError: (error: Error) => {
      toast.error(error.message || 'Error al actualizar presupuesto');
    },
  });
}

/**
 * Hook para eliminar presupuesto
 */
export function useDeleteBudget() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ budYea, budCod }: { budYea: string; budCod: string }) =>
      budgetService.delete(budYea, budCod),
    onSuccess: (response) => {
      queryClient.invalidateQueries({ queryKey: budgetKeys.lists() });
      queryClient.invalidateQueries({ queryKey: dashboardKeys.all }); // Refresh dashboard
      toast.success(response.message || 'Presupuesto eliminado correctamente');
    },
    onError: (error: Error) => {
      toast.error(error.message || 'Error al eliminar presupuesto');
    },
  });
}

// =============================================
// Budget Items Hooks
// =============================================

/**
 * Hook para guardar item de presupuesto
 */
export function useSaveBudgetItem() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({
      budYea,
      budCod,
      item,
    }: {
      budYea: string;
      budCod: string;
      item: Partial<BudgetItem>;
    }) => budgetService.saveItem(budYea, budCod, item),
    onSuccess: (response, variables) => {
      queryClient.invalidateQueries({
        queryKey: budgetKeys.detail(variables.budYea, variables.budCod),
      });
      queryClient.invalidateQueries({ queryKey: budgetKeys.lists() });
      queryClient.invalidateQueries({ queryKey: dashboardKeys.all }); // Refresh dashboard
      toast.success(response.message || 'Item guardado correctamente');
    },
    onError: (error: Error) => {
      toast.error(error.message || 'Error al guardar item');
    },
  });
}

/**
 * Hook para eliminar item de presupuesto
 */
export function useDeleteBudgetItem() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({
      budYea,
      budCod,
      budIteNum,
    }: {
      budYea: string;
      budCod: string;
      budIteNum: number;
    }) => budgetService.deleteItem(budYea, budCod, budIteNum),
    onSuccess: (response, variables) => {
      queryClient.invalidateQueries({
        queryKey: budgetKeys.detail(variables.budYea, variables.budCod),
      });
      queryClient.invalidateQueries({ queryKey: budgetKeys.lists() });
      queryClient.invalidateQueries({ queryKey: dashboardKeys.all }); // Refresh dashboard
      toast.success(response.message || 'Item eliminado correctamente');
    },
    onError: (error: Error) => {
      toast.error(error.message || 'Error al eliminar item');
    },
  });
}

/**
 * Hook para subir imagen de item de presupuesto
 */
export function useUploadBudgetItemImage() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({
      budYea,
      budCod,
      budIteNum,
      file,
    }: {
      budYea: string;
      budCod: string;
      budIteNum: number;
      file: File;
    }) => budgetService.uploadItemImage(budYea, budCod, budIteNum, file),
    onSuccess: (response, variables) => {
      queryClient.invalidateQueries({
        queryKey: budgetKeys.detail(variables.budYea, variables.budCod),
      });
      toast.success(response.message || 'Imagen subida correctamente');
    },
    onError: (error: Error) => {
      toast.error(error.message || 'Error al subir imagen');
    },
  });
}
