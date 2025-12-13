/**
 * StatsCards - Tarjetas de estadísticas del dashboard
 * Usa el hook centralizado useDashboardData (DRY principle)
 */
'use client'

import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Skeleton } from '@/components/ui/skeleton'
import { FolderKanban, Users, Calculator, FileText, type LucideIcon } from 'lucide-react'
import { useDashboardData } from '@/hooks/use-dashboard-data'

interface StatConfig {
  title: string
  icon: LucideIcon
  color: string
  bg: string
}

const statsConfig: StatConfig[] = [
  { title: 'Proyectos', icon: FolderKanban, color: 'text-primary', bg: 'bg-primary/10' },
  { title: 'Clientes', icon: Users, color: 'text-blue-500', bg: 'bg-blue-500/10' },
  { title: 'Presupuestos', icon: Calculator, color: 'text-amber-500', bg: 'bg-amber-500/10' },
  { title: 'Documentos', icon: FileText, color: 'text-emerald-500', bg: 'bg-emerald-500/10' },
]

export function StatsCards() {
  const { stats, isLoading } = useDashboardData()

  const statsData = [
    { value: stats.totalProjects, label: `${stats.activeProjects} activos` },
    { value: stats.totalClients, label: `${stats.activeClients} activos` },
    { value: stats.totalBudgets, label: `${stats.pendingBudgets} pendientes` },
    { value: stats.totalDocuments, label: 'archivos subidos' },
  ]

  if (isLoading) {
    return (
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        {statsConfig.map((config) => (
          <Card key={config.title}>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <Skeleton className="h-4 w-24" />
              <Skeleton className="h-8 w-8 rounded-lg" />
            </CardHeader>
            <CardContent>
              <Skeleton className="h-8 w-16 mb-1" />
              <Skeleton className="h-3 w-20" />
            </CardContent>
          </Card>
        ))}
      </div>
    )
  }

  return (
    <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
      {statsConfig.map((config, index) => (
        <Card key={config.title}>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              {config.title}
            </CardTitle>
            <div className={`p-2 rounded-lg ${config.bg}`}>
              <config.icon className={`h-4 w-4 ${config.color}`} />
            </div>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{statsData[index]?.value ?? 0}</div>
            <p className="text-xs text-muted-foreground mt-1">{statsData[index]?.label ?? '-'}</p>
          </CardContent>
        </Card>
      ))}
    </div>
  )
}
