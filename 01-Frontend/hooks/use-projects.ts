/**
 * Hooks de TanStack Query para proyectos
 * Uses centralized cache config (DRY principle)
 */
'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { projectService, type ProjectFilters } from '@/lib/api/services';
import type { Project } from '@/types';
import { toast } from 'sonner';
import { useAuthReady } from './use-auth-ready';
import { QUERY_CACHE_LISTS, QUERY_CACHE_CATALOGS, QUERY_CACHE_DETAILS } from '@/lib/config/query-cache';
import { dashboardKeys } from './use-dashboard-data';

// Query Keys Factory
export const projectKeys = {
  all: ['projects'] as const,
  lists: () => [...projectKeys.all, 'list'] as const,
  list: (filters: ProjectFilters) => [...projectKeys.lists(), filters] as const,
  details: () => [...projectKeys.all, 'detail'] as const,
  detail: (proYea: string, proCod: string) => [...projectKeys.details(), proYea, proCod] as const,
  statuses: () => [...projectKeys.all, 'statuses'] as const,
};

/**
 * Hook para obtener lista de proyectos
 */
export function useProjects(filters: ProjectFilters = {}) {
  const { isReady } = useAuthReady();

  return useQuery({
    queryKey: projectKeys.list(filters),
    queryFn: () => projectService.getAll(filters),
    enabled: isReady,
    ...QUERY_CACHE_LISTS,
    select: (response) => ({
      projects: response.data,
      success: response.success,
      message: response.message,
    }),
  });
}

/**
 * Hook para obtener un proyecto por ID
 */
export function useProject(proYea: string, proCod: string) {
  const { isReady } = useAuthReady();

  return useQuery({
    queryKey: projectKeys.detail(proYea, proCod),
    queryFn: () => projectService.getById(proYea, proCod),
    enabled: isReady && !!proYea && !!proCod,
    ...QUERY_CACHE_DETAILS,
    select: (response) => response.data,
  });
}

/**
 * Hook para obtener catálogo de estados
 */
export function useProjectStatuses() {
  const { isReady } = useAuthReady();

  return useQuery({
    queryKey: projectKeys.statuses(),
    queryFn: () => projectService.getStatuses(),
    enabled: isReady,
    ...QUERY_CACHE_CATALOGS,
    select: (response) => response.data,
  });
}

/**
 * Hook para crear proyecto
 */
export function useCreateProject() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: Partial<Project>) => projectService.create(data),
    onSuccess: (response) => {
      queryClient.invalidateQueries({ queryKey: projectKeys.lists() });
      queryClient.invalidateQueries({ queryKey: dashboardKeys.all });
      toast.success(response.message || 'Proyecto creado correctamente');
    },
    onError: (error: Error) => {
      toast.error(error.message || 'Error al crear proyecto');
    },
  });
}

/**
 * Hook para actualizar proyecto
 */
export function useUpdateProject() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: Partial<Project>) => projectService.update(data),
    onSuccess: (response, variables) => {
      queryClient.invalidateQueries({ queryKey: projectKeys.lists() });
      queryClient.invalidateQueries({ queryKey: dashboardKeys.all });
      if (variables.proYea && variables.proCod) {
        queryClient.invalidateQueries({
          queryKey: projectKeys.detail(variables.proYea, variables.proCod),
        });
      }
      toast.success(response.message || 'Proyecto actualizado correctamente');
    },
    onError: (error: Error) => {
      toast.error(error.message || 'Error al actualizar proyecto');
    },
  });
}

/**
 * Hook para eliminar proyecto
 */
export function useDeleteProject() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ proYea, proCod }: { proYea: string; proCod: string }) =>
      projectService.delete(proYea, proCod),
    onSuccess: (response) => {
      queryClient.invalidateQueries({ queryKey: projectKeys.lists() });
      queryClient.invalidateQueries({ queryKey: dashboardKeys.all });
      toast.success(response.message || 'Proyecto eliminado correctamente');
    },
    onError: (error: Error) => {
      toast.error(error.message || 'Error al eliminar proyecto');
    },
  });
}
