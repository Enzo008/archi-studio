/**
 * ProjectDetail - Componente de detalle de proyecto usando componentes shared
 */
'use client'

import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { 
  DetailHeader, 
  InfoCard, 
  DetailSkeleton, 
  ErrorState 
} from '@/components/shared'
import { Calendar, MapPin, DollarSign, Users, FolderKanban, Clock } from 'lucide-react'
import { useProject } from '@/hooks/use-projects'
import { formatDateLong, formatCurrency, formatPercent } from '@/lib/utils/format'

interface ProjectDetailProps {
  projectId: string
}

export function ProjectDetail({ projectId }: ProjectDetailProps) {
  const [proYea, proCod] = projectId.split('-')
  const { data: project, isLoading, error } = useProject(proYea, proCod)

  if (isLoading) {
    return <DetailSkeleton infoCards={4} contentCards={2} />
  }

  if (error || !project) {
    return (
      <ErrorState 
        icon={FolderKanban}
        title="Proyecto no encontrado"
        description="No se pudo cargar la información del proyecto"
        backHref="/projects"
        backLabel="Volver a proyectos"
      />
    )
  }

  return (
    <div className="space-y-6">
      <DetailHeader
        title={project.proNam || 'Sin nombre'}
        subtitle={project.cliNam}
        backHref="/projects"
        editHref={`/projects/${project.proYea}-${project.proCod}/edit`}
        status={
          project.proStaNam
            ? { label: project.proStaNam, color: project.proStaCol }
            : undefined
        }
      />

      {/* Info Cards */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <InfoCard
          icon={Calendar}
          label="Fecha Inicio"
          value={formatDateLong(project.proDatIni)}
        />
        <InfoCard
          icon={Clock}
          label="Fecha Fin Estimada"
          value={formatDateLong(project.proDatEnd)}
        />
        <InfoCard
          icon={DollarSign}
          label="Presupuesto"
          value={formatCurrency(project.proBudget)}
        />
        <InfoCard
          icon={Users}
          label="Cliente"
          value={project.cliNam || '-'}
        />
      </div>

      {/* Progress & Details */}
      <div className="grid gap-6 lg:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle>Progreso</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              <div className="flex items-center justify-between">
                <span className="text-muted-foreground">Avance general</span>
                <span className="font-semibold">{formatPercent(project.proPro)}</span>
              </div>
              <div className="h-3 bg-muted rounded-full overflow-hidden">
                <div 
                  className="h-full bg-primary rounded-full transition-all"
                  style={{ width: `${project.proPro || 0}%` }}
                />
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Detalles</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            {project.proAdd && (
              <div className="flex items-start gap-3">
                <MapPin className="h-5 w-5 text-muted-foreground mt-0.5" />
                <div>
                  <p className="text-sm text-muted-foreground">Ubicación</p>
                  <p className="font-medium">{project.proAdd}</p>
                </div>
              </div>
            )}
            {project.proDes && (
              <div>
                <p className="text-sm text-muted-foreground mb-1">Descripción</p>
                <p>{project.proDes}</p>
              </div>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
