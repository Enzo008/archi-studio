/**
 * Página de Calendario - Vista de entregas y fechas de proyectos
 */
'use client';

import { useMemo } from 'react';
import { useRouter } from 'next/navigation';
import FullCalendar from '@fullcalendar/react';
import dayGridPlugin from '@fullcalendar/daygrid';
import interactionPlugin from '@fullcalendar/interaction';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Skeleton } from '@/components/ui/skeleton';
import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from '@/components/ui/tooltip';
import { PageHeader } from '@/components/layout/page-header';
import { useProjects, useProjectStatuses } from '@/hooks/use-projects';
import { Calendar, FolderKanban, Clock, User } from 'lucide-react';
import type { EventClickArg, EventContentArg } from '@fullcalendar/core';

export default function CalendarPage() {
  const router = useRouter();
  const { data: projectsData, isLoading } = useProjects({ page: 1, pageSize: 100 });
  const { data: statuses = [] } = useProjectStatuses();

  // Convertir proyectos a eventos del calendario
  const events = useMemo(() => {
    if (!projectsData?.projects) return [];

    const projectEvents: Array<{
      id: string;
      title: string;
      start: string;
      end?: string;
      backgroundColor: string;
      borderColor: string;
      classNames?: string[];
      extendedProps: {
        type: 'start' | 'end' | 'range';
        projectId: string;
        status: string;
        progress: number;
      };
    }> = [];

    projectsData.projects.forEach((project) => {
      const color = project.proStaCol || '#6b7280';
      const projectId = `${project.proYea}-${project.proCod}`;

      // Si tiene ambas fechas, crear un rango
      if (project.proDatIni && project.proDatEnd) {
        projectEvents.push({
          id: `${projectId}-range`,
          title: project.proNam || 'Sin nombre',
          start: project.proDatIni.split('T')[0],
          end: project.proDatEnd.split('T')[0],
          backgroundColor: `${color}40`,  // Mayor opacidad para mejor contraste
          borderColor: color,
          classNames: ['event-range'],
          extendedProps: {
            type: 'range',
            projectId,
            status: project.proStaNam || '',
            progress: project.proPro || 0,
          },
        });
      } else {
        // Solo fecha de inicio
        if (project.proDatIni) {
          projectEvents.push({
            id: `${projectId}-start`,
            title: `🚀 ${project.proNam || 'Sin nombre'}`,
            start: project.proDatIni.split('T')[0],
            backgroundColor: color,
            borderColor: color,
            classNames: ['event-point'],
            extendedProps: {
              type: 'start',
              projectId,
              status: project.proStaNam || '',
              progress: project.proPro || 0,
            },
          });
        }
        // Solo fecha de fin
        if (project.proDatEnd) {
          projectEvents.push({
            id: `${projectId}-end`,
            title: `🏁 ${project.proNam || 'Sin nombre'}`,
            start: project.proDatEnd.split('T')[0],
            backgroundColor: color,
            borderColor: color,
            classNames: ['event-point'],
            extendedProps: {
              type: 'end',
              projectId,
              status: project.proStaNam || '',
              progress: project.proPro || 0,
            },
          });
        }
      }
    });

    return projectEvents;
  }, [projectsData?.projects]);

  const handleEventClick = (info: EventClickArg) => {
    const projectId = info.event.extendedProps.projectId;
    if (projectId) {
      router.push(`/projects/${projectId}`);
    }
  };

  // Próximas entregas (proyectos con fecha de fin en los próximos 30 días)
  const upcomingDeadlines = useMemo(() => {
    if (!projectsData?.projects) return [];

    const today = new Date();
    const thirtyDaysFromNow = new Date(today.getTime() + 30 * 24 * 60 * 60 * 1000);

    return projectsData.projects
      .filter((p) => {
        if (!p.proDatEnd) return false;
        const endDate = new Date(p.proDatEnd);
        return endDate >= today && endDate <= thirtyDaysFromNow;
      })
      .sort((a, b) => new Date(a.proDatEnd!).getTime() - new Date(b.proDatEnd!).getTime())
      .slice(0, 5);
  }, [projectsData?.projects]);

  if (isLoading) {
    return (
      <div className="space-y-6">
        <Skeleton className="h-10 w-64" />
        <div className="grid gap-6 lg:grid-cols-4">
          <Skeleton className="h-[600px] lg:col-span-3" />
          <Skeleton className="h-[400px]" />
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <PageHeader
        title="Calendario"
        description="Vista de fechas y entregas de proyectos"
      />

      <div className="grid gap-6 lg:grid-cols-4">
        {/* Calendario principal */}
        <Card className="lg:col-span-3">
          <CardContent className="p-4">
            <div className="calendar-wrapper">
              <FullCalendar
                plugins={[dayGridPlugin, interactionPlugin]}
                initialView="dayGridMonth"
                events={events}
                eventClick={handleEventClick}
                locale="es"
                headerToolbar={{
                  left: 'prev,next today',
                  center: 'title',
                  right: 'dayGridMonth,dayGridWeek',
                }}
                buttonText={{
                  today: 'Hoy',
                  month: 'Mes',
                  week: 'Semana',
                }}
                height="auto"
                eventDisplay="block"
                dayMaxEvents={3}
                moreLinkText={(n) => `+${n} más`}
              />
            </div>
          </CardContent>
        </Card>

        {/* Panel lateral - Próximas entregas */}
        <div className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-base">
                <Calendar className="h-4 w-4" />
                Próximas Entregas
              </CardTitle>
            </CardHeader>
            <CardContent>
              {upcomingDeadlines.length === 0 ? (
                <div className="text-center py-4 text-muted-foreground">
                  <FolderKanban className="h-8 w-8 mx-auto mb-2 opacity-50" />
                  <p className="text-sm">No hay entregas próximas</p>
                </div>
              ) : (
                <div className="space-y-3">
                  {upcomingDeadlines.map((project) => {
                    const daysLeft = Math.ceil(
                      (new Date(project.proDatEnd!).getTime() - new Date().getTime()) /
                      (1000 * 60 * 60 * 24)
                    );
                    return (
                      <div
                        key={`${project.proYea}-${project.proCod}`}
                        className="p-3 rounded-lg bg-muted/50 hover:bg-muted cursor-pointer transition-colors"
                        onClick={() =>
                          router.push(`/projects/${project.proYea}-${project.proCod}`)
                        }
                      >
                        <div className="flex items-start justify-between gap-2">
                          <p className="font-medium text-sm line-clamp-1">
                            {project.proNam}
                          </p>
                          <Badge
                            variant={daysLeft <= 7 ? 'destructive' : 'secondary'}
                            className="shrink-0 text-xs"
                          >
                            {daysLeft === 0
                              ? 'Hoy'
                              : daysLeft === 1
                                ? 'Mañana'
                                : `${daysLeft} días`}
                          </Badge>
                        </div>
                        <div className="flex items-center gap-2 mt-2">
                          <div className="flex-1 h-1.5 bg-muted rounded-full overflow-hidden">
                            <div
                              className="h-full bg-primary rounded-full"
                              style={{ width: `${project.proPro || 0}%` }}
                            />
                          </div>
                          <span className="text-xs text-muted-foreground">
                            {project.proPro || 0}%
                          </span>
                        </div>
                      </div>
                    );
                  })}
                </div>
              )}
            </CardContent>
          </Card>

          {/* Leyenda - Estados del proyecto */}
          <Card>
            <CardHeader>
              <CardTitle className="text-base">Estados del Proyecto</CardTitle>
            </CardHeader>
            <CardContent className="space-y-2">
              {statuses.length > 0 ? (
                statuses.map((status) => (
                  <div key={status.proSta} className="flex items-center gap-2 text-sm">
                    <div
                      className="w-3 h-3 rounded-full border"
                      style={{ backgroundColor: status.proStaCol || '#6b7280' }}
                    />
                    <span className="text-muted-foreground">{status.proStaNam}</span>
                  </div>
                ))
              ) : (
                <div className="text-xs text-muted-foreground">
                  Cargando estados...
                </div>
              )}
              <p className="text-xs text-muted-foreground pt-2 border-t mt-3">
                Haz clic en un proyecto para ver detalles
              </p>
            </CardContent>
          </Card>
        </div>
      </div>

      {/* Estilos del calendario usando CSS Variables oficiales de FullCalendar */}
      <style jsx global>{`
        /* === TEMA CLARO (por defecto) === */
        .calendar-wrapper .fc {
          --fc-page-bg-color: transparent;
          --fc-neutral-bg-color: #f3f4f6;
          --fc-neutral-text-color: #6b7280;
          --fc-border-color: #e5e7eb;
          
          --fc-button-text-color: #374151;
          --fc-button-bg-color: transparent;
          --fc-button-border-color: #d1d5db;
          --fc-button-hover-bg-color: #f3f4f6;
          --fc-button-hover-border-color: #d1d5db;
          --fc-button-active-bg-color: #b45309;
          --fc-button-active-border-color: #b45309;
          
          --fc-event-text-color: #1f2937;
          --fc-today-bg-color: rgba(180, 83, 9, 0.1);
          
          --fc-more-link-bg-color: #f3f4f6;
          --fc-more-link-text-color: #b45309;
        }
        
        /* === TEMA OSCURO === */
        .dark .calendar-wrapper .fc {
          --fc-page-bg-color: transparent;
          --fc-neutral-bg-color: #334155;
          --fc-neutral-text-color: #94a3b8;
          --fc-border-color: #475569;
          
          --fc-button-text-color: #f1f5f9;
          --fc-button-bg-color: transparent;
          --fc-button-border-color: #475569;
          --fc-button-hover-bg-color: #334155;
          --fc-button-hover-border-color: #475569;
          --fc-button-active-bg-color: #b45309;
          --fc-button-active-border-color: #b45309;
          
          --fc-event-text-color: #f9fafb;
          --fc-today-bg-color: rgba(180, 83, 9, 0.15);
          
          --fc-more-link-bg-color: #334155;
          --fc-more-link-text-color: #fb923c;
        }
        
        /* Header de días */
        .calendar-wrapper .fc-col-header-cell-cushion {
          font-weight: 500;
          text-transform: uppercase;
          font-size: 0.75rem;
        }
        
        /* Números de día */
        .calendar-wrapper .fc-daygrid-day-number {
          padding: 8px;
        }
        .calendar-wrapper .fc-day-today .fc-daygrid-day-number {
          background: #b45309;
          color: white;
          border-radius: 50%;
          width: 28px;
          height: 28px;
          display: flex;
          align-items: center;
          justify-content: center;
        }
        
        /* Título */
        .calendar-wrapper .fc-toolbar-title {
          font-size: 1.25rem;
        }
        
        /* Botones - Mejoras */
        .calendar-wrapper .fc-button {
          font-size: 0.875rem;
          padding: 6px 12px;
          transition: all 0.15s;
        }
        .calendar-wrapper .fc-button-primary:not(:disabled).fc-button-active {
          font-weight: 600;
        }
        
        /* Eventos */
        .calendar-wrapper .fc-event {
          cursor: pointer;
          font-size: 0.75rem;
          padding: 3px 6px;
          border-radius: 4px;
          font-weight: 500;
          border-left-width: 3px !important;
        }
        
        /* Link "+1 más" */
        .calendar-wrapper .fc-daygrid-more-link {
          font-weight: 600;
          font-size: 0.75rem;
          padding: 2px 6px;
          border-radius: 4px;
        }
        
        /* Popover - Tema claro */
        .calendar-wrapper .fc-popover {
          background: #ffffff;
          border: 1px solid #e5e7eb;
          border-radius: 8px;
          box-shadow: 0 10px 40px rgba(0,0,0,0.2);
          z-index: 9999;
        }
        .calendar-wrapper .fc-popover-header {
          background: #f3f4f6;
          color: #111827;
          padding: 10px 14px;
          border-bottom: 1px solid #e5e7eb;
          border-radius: 8px 8px 0 0;
          font-weight: 600;
        }
        .calendar-wrapper .fc-popover-body {
          padding: 10px;
          background: #ffffff;
          border-radius: 0 0 8px 8px;
        }
        .calendar-wrapper .fc-popover-body .fc-event {
          margin-bottom: 6px;
          background: #f9fafb !important;
        }
        
        /* Popover - Tema oscuro */
        .dark .calendar-wrapper .fc-popover {
          background: #1e293b;
          border-color: #475569;
        }
        .dark .calendar-wrapper .fc-popover-header {
          background: #334155;
          color: #f1f5f9;
          border-color: #475569;
        }
        .dark .calendar-wrapper .fc-popover-body {
          background: #1e293b;
        }
        .dark .calendar-wrapper .fc-popover-body .fc-event {
          background: #334155 !important;
        }
      `}</style>
    </div>
  );
}
