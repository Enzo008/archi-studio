/**
 * AnalyticsCards - Tarjetas de análisis y métricas del dashboard
 * Usa el hook centralizado useDashboardData (DRY principle)
 */
'use client'

import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Progress } from '@/components/ui/progress'
import { useDashboardData } from '@/hooks/use-dashboard-data'
import { formatCurrency } from '@/lib/utils/format'
import {
  TrendingUp, Target, DollarSign,
  CheckCircle, AlertTriangle, XCircle, Clock
} from 'lucide-react'

export function AnalyticsCards() {
  const { stats, budgets, clients } = useDashboardData()

  return (
    <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
      {/* Progreso General */}
      <Card>
        <CardHeader className="flex flex-row items-center justify-between pb-2">
          <CardTitle className="text-sm font-medium">Progreso Promedio</CardTitle>
          <TrendingUp className="h-4 w-4 text-muted-foreground" />
        </CardHeader>
        <CardContent>
          <div className="text-2xl font-bold">{stats.avgProgress}%</div>
          <Progress value={stats.avgProgress} className="mt-2" />
          <p className="text-xs text-muted-foreground mt-2">
            De {stats.totalProjects} proyectos activos
          </p>
        </CardContent>
      </Card>

      {/* Estado de Proyectos */}
      <Card>
        <CardHeader className="flex flex-row items-center justify-between pb-2">
          <CardTitle className="text-sm font-medium">Estado Proyectos</CardTitle>
          <Target className="h-4 w-4 text-muted-foreground" />
        </CardHeader>
        <CardContent>
          <div className="space-y-2">
            <div className="flex items-center justify-between text-sm">
              <div className="flex items-center gap-2">
                <CheckCircle className="h-3 w-3 text-emerald-500" />
                <span>Completados</span>
              </div>
              <span className="font-medium">{stats.completedProjects}</span>
            </div>
            <div className="flex items-center justify-between text-sm">
              <div className="flex items-center gap-2">
                <Clock className="h-3 w-3 text-blue-500" />
                <span>En progreso</span>
              </div>
              <span className="font-medium">{stats.inProgressProjects}</span>
            </div>
            <div className="flex items-center justify-between text-sm">
              <div className="flex items-center gap-2">
                <AlertTriangle className="h-3 w-3 text-amber-500" />
                <span>Sin iniciar</span>
              </div>
              <span className="font-medium">{stats.notStartedProjects}</span>
            </div>
            {stats.overdueProjects > 0 && (
              <div className="flex items-center justify-between text-sm">
                <div className="flex items-center gap-2">
                  <XCircle className="h-3 w-3 text-red-500" />
                  <span>Vencidos</span>
                </div>
                <span className="font-medium text-red-500">{stats.overdueProjects}</span>
              </div>
            )}
          </div>
        </CardContent>
      </Card>

      {/* Total Presupuestos */}
      <Card>
        <CardHeader className="flex flex-row items-center justify-between pb-2">
          <CardTitle className="text-sm font-medium">Total Presupuestado</CardTitle>
          <DollarSign className="h-4 w-4 text-muted-foreground" />
        </CardHeader>
        <CardContent>
          <div className="text-2xl font-bold">{formatCurrency(stats.totalBudgetAmount)}</div>
          <p className="text-xs text-muted-foreground mt-2">
            En {budgets.length} presupuestos
          </p>
        </CardContent>
      </Card>

      {/* Clientes Activos */}
      <Card>
        <CardHeader className="flex flex-row items-center justify-between pb-2">
          <CardTitle className="text-sm font-medium">Clientes Activos</CardTitle>
          <Target className="h-4 w-4 text-muted-foreground" />
        </CardHeader>
        <CardContent>
          <div className="text-2xl font-bold">{stats.activeClients}</div>
          <p className="text-xs text-muted-foreground mt-2">
            De {clients.length} clientes totales
          </p>
        </CardContent>
      </Card>
    </div>
  )
}
