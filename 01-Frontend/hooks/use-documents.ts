/**
 * Hooks de TanStack Query para documentos
 */
'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { documentService, type DocumentFilters } from '@/lib/api/services';
import type { Document } from '@/types';
import { toast } from 'sonner';
import { useAuthReady } from './use-auth-ready';
import { dashboardKeys } from './use-dashboard-data';

// Query Keys
export const documentKeys = {
  all: ['documents'] as const,
  lists: () => [...documentKeys.all, 'list'] as const,
  list: (filters: DocumentFilters) => [...documentKeys.lists(), filters] as const,
  details: () => [...documentKeys.all, 'detail'] as const,
  detail: (docYea: string, docCod: string) => [...documentKeys.details(), docYea, docCod] as const,
  types: () => [...documentKeys.all, 'types'] as const,
};

/**
 * Hook para obtener lista de documentos
 */
export function useDocuments(filters: DocumentFilters = {}) {
  const { isReady } = useAuthReady();

  return useQuery({
    queryKey: documentKeys.list(filters),
    queryFn: () => documentService.getAll(filters),
    enabled: isReady,
    select: (response) => ({
      documents: response.data,
      success: response.success,
      message: response.message,
    }),
  });
}

/**
 * Hook para obtener un documento por ID
 */
export function useDocument(docYea: string, docCod: string) {
  const { isReady } = useAuthReady();

  return useQuery({
    queryKey: documentKeys.detail(docYea, docCod),
    queryFn: () => documentService.getById(docYea, docCod),
    enabled: isReady && !!docYea && !!docCod,
    select: (response) => response.data,
  });
}

/**
 * Hook para obtener catálogo de tipos de documento
 */
export function useDocumentTypes() {
  const { isReady } = useAuthReady();

  return useQuery({
    queryKey: documentKeys.types(),
    queryFn: () => documentService.getTypes(),
    enabled: isReady,
    select: (response) => response.data,
    staleTime: 1000 * 60 * 60, // 1 hora
  });
}

/**
 * Hook para crear documento
 */
export function useCreateDocument() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: Partial<Document>) => documentService.create(data),
    onSuccess: (response) => {
      queryClient.invalidateQueries({ queryKey: documentKeys.lists() });
      queryClient.invalidateQueries({ queryKey: dashboardKeys.all });
      toast.success(response.message || 'Documento creado correctamente');
    },
    onError: (error: Error) => {
      toast.error(error.message || 'Error al crear documento');
    },
  });
}

/**
 * Hook para actualizar documento
 */
export function useUpdateDocument() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: Partial<Document>) => documentService.update(data),
    onSuccess: (response, variables) => {
      queryClient.invalidateQueries({ queryKey: documentKeys.lists() });
      queryClient.invalidateQueries({ queryKey: dashboardKeys.all });
      if (variables.docYea && variables.docCod) {
        queryClient.invalidateQueries({
          queryKey: documentKeys.detail(variables.docYea, variables.docCod),
        });
      }
      toast.success(response.message || 'Documento actualizado correctamente');
    },
    onError: (error: Error) => {
      toast.error(error.message || 'Error al actualizar documento');
    },
  });
}

/**
 * Hook para eliminar documento
 */
export function useDeleteDocument() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ docYea, docCod }: { docYea: string; docCod: string }) =>
      documentService.delete(docYea, docCod),
    onSuccess: (response) => {
      queryClient.invalidateQueries({ queryKey: documentKeys.lists() });
      queryClient.invalidateQueries({ queryKey: dashboardKeys.all });
      toast.success(response.message || 'Documento eliminado correctamente');
    },
    onError: (error: Error) => {
      toast.error(error.message || 'Error al eliminar documento');
    },
  });
}

/**
 * Hook para subir documento con archivo
 */
export function useUploadDocument() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({
      file,
      data,
    }: {
      file: File;
      data: {
        docNam?: string;
        docDes?: string;
        docTyp: string;
        proYea?: string;
        proCod?: string;
      };
    }) => documentService.upload(file, data),
    onSuccess: (response) => {
      queryClient.invalidateQueries({ queryKey: documentKeys.lists() });
      queryClient.invalidateQueries({ queryKey: dashboardKeys.all });
      toast.success(response.message || 'Documento subido correctamente');
    },
    onError: (error: Error) => {
      toast.error(error.message || 'Error al subir documento');
    },
  });
}
