---
inclusion: fileMatch
fileMatchPattern: "**/hooks/**"
---

# TanStack Query Patterns

## Cuándo Usar

- **Server Components**: fetch directo (NO TanStack Query)
- **Client Components**: TanStack Query para server state

## Query Básico

```typescript
// hooks/use-projects.ts
'use client';

import { useQuery } from '@tanstack/react-query';
import { projectService } from '@/lib/api/services/project-service';

export function useProjects(params?: PaginationParams) {
  return useQuery({
    queryKey: ['projects', params],
    queryFn: () => projectService.getAll(params),
    staleTime: 5 * 60 * 1000, // 5 minutos
  });
}

export function useProject(id: string) {
  return useQuery({
    queryKey: ['projects', id],
    queryFn: () => projectService.getById(id),
    enabled: !!id,
  });
}
```

## Mutations con Invalidación

```typescript
import { useMutation, useQueryClient } from '@tanstack/react-query';

export function useCreateProject() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: projectService.create,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['projects'] });
    },
  });
}

export function useUpdateProject() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: ({ id, data }) => projectService.update(id, data),
    onSuccess: (_, { id }) => {
      queryClient.invalidateQueries({ queryKey: ['projects'] });
      queryClient.invalidateQueries({ queryKey: ['projects', id] });
    },
  });
}

export function useDeleteProject() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: projectService.delete,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['projects'] });
    },
  });
}
```

## Optimistic Updates

```typescript
export function useOptimisticUpdate<T extends { id: string }>() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: (data: T) => service.update(data.id, data),
    onMutate: async (newData) => {
      // Cancelar queries en vuelo
      await queryClient.cancelQueries({ queryKey: ['entity', newData.id] });
      
      // Snapshot del valor anterior
      const previousData = queryClient.getQueryData(['entity', newData.id]);
      
      // Actualizar optimistamente
      queryClient.setQueryData(['entity', newData.id], newData);
      
      return { previousData };
    },
    onError: (err, newData, context) => {
      // Rollback en caso de error
      queryClient.setQueryData(['entity', newData.id], context?.previousData);
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ['entity'] });
    },
  });
}
```

## Paginación

```typescript
export function usePaginatedProjects(page: number, pageSize: number) {
  return useQuery({
    queryKey: ['projects', 'list', { page, pageSize }],
    queryFn: () => projectService.getPaginated({ page, pageSize }),
    placeholderData: keepPreviousData, // Mantiene datos mientras carga
  });
}
```

## Query Keys Convention

```typescript
// Estructura jerárquica
['projects']                    // Lista
['projects', id]                // Detalle
['projects', 'list', params]    // Lista paginada
['projects', id, 'documents']   // Relación

// Factory pattern
export const projectKeys = {
  all: ['projects'] as const,
  lists: () => [...projectKeys.all, 'list'] as const,
  list: (params: Params) => [...projectKeys.lists(), params] as const,
  details: () => [...projectKeys.all, 'detail'] as const,
  detail: (id: string) => [...projectKeys.details(), id] as const,
};
```

## Integración con Formularios

```typescript
// En componente con React Hook Form
const { mutate, isPending } = useCreateProject();

const onSubmit = (data: ProjectFormData) => {
  mutate(data, {
    onSuccess: () => {
      toast.success('Proyecto creado');
      form.reset();
      onClose();
    },
    onError: (error) => {
      toast.error(error.message);
    },
  });
};
```

## Anti-Patterns

- ❌ Usar TanStack Query en Server Components
- ❌ Guardar datos de Query en Zustand
- ❌ Olvidar invalidar queries después de mutations
- ❌ Query keys inconsistentes
- ❌ Fetch en useEffect (usar useQuery)
