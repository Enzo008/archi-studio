/**
 * ProjectsTable - Wrapper que usa DataTable con configuración específica de proyectos
 */
'use client'

import Link from 'next/link'
import { Badge } from '@/components/ui/badge'
import { FolderKanban, Calendar, Building2, Eye, Pencil } from 'lucide-react'
import { DataTable, type DataTableColumn } from '@/components/shared'
import { formatDate, formatCurrency } from '@/lib/utils/format'
import type { Project } from '@/types'

interface ProjectsTableProps {
  projects: Project[]
  isLoading?: boolean
  onDelete: (project: Project) => void
}

export function ProjectsTable({ projects, isLoading, onDelete }: ProjectsTableProps) {
  // Definición de columnas específicas para proyectos
  const columns: DataTableColumn<Project>[] = [
    {
      key: 'name',
      header: 'Proyecto',
      skeleton: { width: 'w-40', hasSubtext: true },
      render: (project) => (
        <div>
          <Link 
            href={`/projects/${project.proYea}-${project.proCod}`}
            className="font-medium hover:text-primary transition-colors"
          >
            {project.proNam || 'Sin nombre'}
          </Link>
          <p className="text-xs text-muted-foreground mt-0.5">
            {project.proYea}-{project.proCod}
          </p>
        </div>
      ),
    },
    {
      key: 'client',
      header: 'Cliente',
      hideOn: 'md',
      skeleton: { width: 'w-28' },
      render: (project) => (
        <div className="flex items-center gap-2 text-foreground/80">
          <Building2 className="h-4 w-4 text-muted-foreground" />
          {project.cliNam || '-'}
        </div>
      ),
    },
    {
      key: 'status',
      header: 'Estado',
      skeleton: { width: 'w-20', isBadge: true },
      render: (project) => (
        <Badge
          variant="outline"
          className="border-0"
          style={{
            backgroundColor: `${project.proStaCol}20` || '#6b728020',
            color: project.proStaCol || '#6b7280',
          }}
        >
          {project.proStaNam || 'Sin estado'}
        </Badge>
      ),
    },
    {
      key: 'progress',
      header: 'Avance',
      hideOn: 'lg',
      skeleton: { width: 'w-24' },
      render: (project) => (
        <div className="flex items-center gap-2">
          <div className="w-20 h-2 bg-muted rounded-full overflow-hidden">
            <div
              className="h-full bg-primary rounded-full transition-all"
              style={{ width: `${project.proPro || 0}%` }}
            />
          </div>
          <span className="text-xs text-muted-foreground w-8">
            {project.proPro || 0}%
          </span>
        </div>
      ),
    },
    {
      key: 'budget',
      header: 'Presupuesto',
      hideOn: 'sm',
      skeleton: { width: 'w-20' },
      render: (project) => (
        <span className="font-medium">{formatCurrency(project.proBudget)}</span>
      ),
    },
    {
      key: 'startDate',
      header: 'Fecha Inicio',
      hideOn: 'xl',
      skeleton: { width: 'w-24' },
      render: (project) => (
        <div className="flex items-center gap-1.5 text-muted-foreground text-sm">
          <Calendar className="h-3.5 w-3.5" />
          {formatDate(project.proDatIni)}
        </div>
      ),
    },
  ]

  return (
    <DataTable
      data={projects}
      columns={columns}
      getRowId={(project) => `${project.proYea}-${project.proCod}`}
      title="Proyectos"
      isLoading={isLoading}
      emptyIcon={FolderKanban}
      emptyTitle="Sin proyectos"
      emptyDescription="Comienza creando tu primer proyecto"
      searchPlaceholder="Buscar proyecto..."
      filterFn={(project, query) =>
        (project.proNam?.toLowerCase().includes(query.toLowerCase()) ?? false) ||
        (project.cliNam?.toLowerCase().includes(query.toLowerCase()) ?? false)
      }
      actions={[
        {
          label: 'Ver detalles',
          icon: Eye,
          href: (project) => `/projects/${project.proYea}-${project.proCod}`,
        },
        {
          label: 'Editar',
          icon: Pencil,
          href: (project) => `/projects/${project.proYea}-${project.proCod}/edit`,
        },
      ]}
      deleteConfig={{
        title: '¿Eliminar proyecto?',
        itemType: 'proyecto',
        getItemName: (project) => project.proNam || '',
        onDelete,
      }}
    />
  )
}
