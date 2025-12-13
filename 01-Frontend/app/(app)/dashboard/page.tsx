/**
 * Dashboard Page - Vista general con métricas y resumen
 * Conectado a datos reales de la API
 */
import type { Metadata } from 'next';
import { StatsCards } from './components/stats-cards'
import { RecentProjects } from './components/recent-projects'
import { RecentClients } from './components/recent-clients'
import { AnalyticsCards } from './components/analytics-cards'
import { UpcomingDeadlines } from './components/upcoming-deadlines'

export const metadata: Metadata = {
  title: 'Dashboard | ArchiStudio',
  description: 'Panel de control con métricas y resumen de actividad',
};

export default function DashboardPage() {
  return (
    <div className="space-y-6 min-w-0">
      {/* Header */}
      <div>
        <h1 className="text-2xl lg:text-3xl font-bold">Panel de Control</h1>
        <p className="text-muted-foreground mt-1">Resumen de tu actividad y proyectos</p>
      </div>

      {/* Stats Cards - Datos reales */}
      <StatsCards />

      {/* Analytics Cards */}
      <AnalyticsCards />

      {/* Grid de contenido - 2 columnas */}
      <div className="grid gap-6 lg:grid-cols-2 min-w-0">
        {/* Proyectos Recientes - Datos reales */}
        <RecentProjects />

        {/* Próximas Entregas */}
        <UpcomingDeadlines />

        {/* Clientes Recientes - Datos reales (full width) */}
        <div className="lg:col-span-2">
          <RecentClients />
        </div>
      </div>
    </div>
  )
}
