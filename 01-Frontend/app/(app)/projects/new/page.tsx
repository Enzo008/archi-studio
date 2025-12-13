/**
 * Página para crear nuevo proyecto
 */
'use client';

import { useRouter } from 'next/navigation';
import { ProjectForm } from '../components/project-form';
import { useProjectStatuses, useCreateProject } from '@/hooks/use-projects';
import { useClients } from '@/hooks/use-clients';
import type { Project } from '@/types';

export default function NewProjectPage() {
  const router = useRouter();
  const { data: statusesData } = useProjectStatuses();
  const { data: clientsData } = useClients({ page: 1, pageSize: 100 });
  const createMutation = useCreateProject();

  const handleSubmit = (data: Partial<Project>) => {
    createMutation.mutate(data, {
      onSuccess: (response) => {
        // Navegar al detalle del proyecto creado
        if (response.data) {
          router.push(`/projects/${response.data.proYea}-${response.data.proCod}`);
        } else {
          router.push('/projects');
        }
      },
    });
  };

  return (
    <ProjectForm
      onSubmit={handleSubmit}
      isLoading={createMutation.isPending}
      statuses={statusesData || []}
      clients={clientsData?.clients || []}
    />
  );
}
