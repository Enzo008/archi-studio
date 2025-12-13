/**
 * Hook para generar notificaciones basadas en datos del sistema
 */
'use client';

import { useMemo } from 'react';
import { useProjects } from './use-projects';
import { useBudgets } from './use-budgets';

export interface Notification {
  id: string;
  type: 'warning' | 'info' | 'success' | 'error';
  title: string;
  description: string;
  href?: string;
  createdAt: Date;
}

/**
 * Genera notificaciones basadas en el estado actual de los datos
 */
export function useNotifications() {
  const { data: projectsData } = useProjects({ page: 1, pageSize: 100 });
  const { data: budgetsData } = useBudgets({ page: 1, pageSize: 100 });

  const notifications = useMemo(() => {
    const items: Notification[] = [];
    const today = new Date();

    // Proyectos próximos a vencer (7 días)
    projectsData?.projects?.forEach((project) => {
      if (!project.proDatEnd) return;
      
      const endDate = new Date(project.proDatEnd);
      const daysLeft = Math.ceil((endDate.getTime() - today.getTime()) / (1000 * 60 * 60 * 24));
      
      if (daysLeft >= 0 && daysLeft <= 7) {
        items.push({
          id: `project-deadline-${project.proYea}-${project.proCod}`,
          type: daysLeft <= 2 ? 'warning' : 'info',
          title: daysLeft === 0 ? 'Entrega hoy' : `Entrega en ${daysLeft} días`,
          description: project.proNam || 'Proyecto sin nombre',
          href: `/projects/${project.proYea}-${project.proCod}`,
          createdAt: new Date(),
        });
      }

      // Proyectos vencidos
      if (daysLeft < 0 && (project.proPro || 0) < 100) {
        items.push({
          id: `project-overdue-${project.proYea}-${project.proCod}`,
          type: 'error',
          title: 'Proyecto vencido',
          description: `${project.proNam} - ${Math.abs(daysLeft)} días de retraso`,
          href: `/projects/${project.proYea}-${project.proCod}`,
          createdAt: new Date(),
        });
      }
    });

    // Presupuestos próximos a vencer (7 días)
    budgetsData?.budgets?.forEach((budget) => {
      if (!budget.budExp) return;
      
      const expDate = new Date(budget.budExp);
      const daysLeft = Math.ceil((expDate.getTime() - today.getTime()) / (1000 * 60 * 60 * 24));
      
      if (daysLeft >= 0 && daysLeft <= 7) {
        items.push({
          id: `budget-expiry-${budget.budYea}-${budget.budCod}`,
          type: daysLeft <= 2 ? 'warning' : 'info',
          title: daysLeft === 0 ? 'Presupuesto vence hoy' : `Presupuesto vence en ${daysLeft} días`,
          description: budget.budNam || 'Presupuesto sin nombre',
          href: `/budgets/${budget.budYea}-${budget.budCod}`,
          createdAt: new Date(),
        });
      }
    });

    // Proyectos con progreso bajo (menos del 30% con menos de 30 días para la entrega)
    projectsData?.projects?.forEach((project) => {
      if (!project.proDatEnd) return;
      
      const endDate = new Date(project.proDatEnd);
      const daysLeft = Math.ceil((endDate.getTime() - today.getTime()) / (1000 * 60 * 60 * 24));
      const progress = project.proPro || 0;
      
      if (daysLeft > 0 && daysLeft <= 30 && progress < 30) {
        items.push({
          id: `project-lowprogress-${project.proYea}-${project.proCod}`,
          type: 'warning',
          title: 'Progreso bajo',
          description: `${project.proNam} - ${progress}% completado, ${daysLeft} días restantes`,
          href: `/projects/${project.proYea}-${project.proCod}`,
          createdAt: new Date(),
        });
      }
    });

    // Ordenar por tipo de prioridad (error > warning > info > success)
    const priorityOrder = { error: 0, warning: 1, info: 2, success: 3 };
    items.sort((a, b) => priorityOrder[a.type] - priorityOrder[b.type]);

    return items;
  }, [projectsData?.projects, budgetsData?.budgets]);

  const unreadCount = notifications.length;
  const hasNotifications = unreadCount > 0;

  return {
    notifications,
    unreadCount,
    hasNotifications,
  };
}
