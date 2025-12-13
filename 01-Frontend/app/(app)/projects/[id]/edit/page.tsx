/**
 * Página para editar proyecto existente
 */
'use client';

import { useRouter, useParams } from 'next/navigation';
import { ProjectForm } from '../../components/project-form';
import { useProject, useProjectStatuses, useUpdateProject } from '@/hooks/use-projects';
import { useClients } from '@/hooks/use-clients';
import { Skeleton } from '@/components/ui/skeleton';
import { Button } from '@/components/ui/button';
import { ArrowLeft, FolderKanban } from 'lucide-react';
import Link from 'next/link';
import type { Project } from '@/types';

export default function EditProjectPage() {
  const router = useRouter();
  const params = useParams();
  const projectId = params.id as string;
  const [proYea, proCod] = projectId.split('-');

  // Queries
  const { data: project, isLoading: projectLoading, error } = useProject(proYea, proCod);
  const { data: statusesData } = useProjectStatuses();
  const { data: clientsData } = useClients({ page: 1, pageSize: 100 });
  const updateMutation = useUpdateProject();

  const handleSubmit = (data: Partial<Project>) => {
    updateMutation.mutate(data, {
      onSuccess: () => {
        // Volver al detalle del proyecto
        router.push(`/projects/${projectId}`);
      },
    });
  };

  // Loading state
  if (projectLoading) {
    return (
      <div className="space-y-6">
        <div className="flex items-center gap-4">
          <Skeleton className="h-10 w-10" />
          <div className="space-y-2">
            <Skeleton className="h-6 w-48" />
            <Skeleton className="h-4 w-64" />
          </div>
        </div>
        <div className="grid gap-6 lg:grid-cols-2">
          <Skeleton className="h-72" />
          <Skeleton className="h-72" />
          <Skeleton className="h-40" />
          <Skeleton className="h-40" />
        </div>
      </div>
    );
  }

  // Error state
  if (error || !project) {
    return (
      <div className="flex flex-col items-center justify-center py-12 space-y-4">
        <FolderKanban className="h-12 w-12 text-muted-foreground" />
        <h2 className="text-xl font-semibold">Proyecto no encontrado</h2>
        <p className="text-muted-foreground">
          No se pudo cargar el proyecto para editar
        </p>
        <Button variant="outline" asChild>
          <Link href="/projects">
            <ArrowLeft className="mr-2 h-4 w-4" />
            Volver a proyectos
          </Link>
        </Button>
      </div>
    );
  }

  return (
    <ProjectForm
      project={project}
      onSubmit={handleSubmit}
      isLoading={updateMutation.isPending}
      statuses={statusesData || []}
      clients={clientsData?.clients || []}
    />
  );
}
