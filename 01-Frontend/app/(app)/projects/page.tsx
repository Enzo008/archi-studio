/**
 * Página de Proyectos - Lista y gestión de proyectos
 */
'use client';

import { PageHeader } from '@/components/layout/page-header';
import { ExportButtons } from '@/components/shared';
import { ProjectsTable } from './components/projects-table';
import { useProjects, useDeleteProject } from '@/hooks/use-projects';
import { exportProjectsToPDF } from '@/lib/utils/export-pdf';
import { exportToExcel, projectExportColumns } from '@/lib/utils/export-excel';
import type { Project } from '@/types';

export default function ProjectsPage() {
  const { data: projectsData, isLoading } = useProjects({ page: 1, pageSize: 50 });
  const deleteMutation = useDeleteProject();
  const projects = projectsData?.projects || [];

  const handleDelete = (project: Project) => {
    deleteMutation.mutate({ proYea: project.proYea, proCod: project.proCod });
  };

  const handleExportPDF = async () => {
    await exportProjectsToPDF(projects, `proyectos-${new Date().toISOString().split('T')[0]}`);
  };

  const handleExportExcel = () => {
    exportToExcel({
      data: projects,
      columns: projectExportColumns,
      filename: `proyectos-${new Date().toISOString().split('T')[0]}`,
      sheetName: 'Proyectos',
    });
  };

  return (
    <div className="space-y-6">
      <PageHeader
        title="Proyectos"
        description="Gestiona todos tus proyectos de arquitectura"
        action={{
          label: 'Nuevo Proyecto',
          href: '/projects/new',
        }}
      >
        <ExportButtons
          onExportPDF={handleExportPDF}
          onExportExcel={handleExportExcel}
          disabled={projects.length === 0}
        />
      </PageHeader>

      <ProjectsTable
        projects={projectsData?.projects || []}
        isLoading={isLoading}
        onDelete={handleDelete}
      />
    </div>
  );
}
