/**
 * UpcomingDeadlines - Tarjeta con próximas entregas de proyectos
 * Usa el hook centralizado useDashboardData (DRY principle)
 */
'use client'

import { useRouter } from 'next/navigation'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Skeleton } from '@/components/ui/skeleton'
import { Calendar, ChevronRight, Clock } from 'lucide-react'
import { useDashboardData } from '@/hooks/use-dashboard-data'
import { formatDate } from '@/lib/utils/format'

export function UpcomingDeadlines() {
  const router = useRouter()
  const { upcomingDeadlines, isLoading } = useDashboardData()

  if (isLoading) {
    return (
      <Card>
        <CardHeader>
          <Skeleton className="h-6 w-40" />
        </CardHeader>
        <CardContent className="space-y-3">
          {[1, 2, 3].map((i) => (
            <Skeleton key={i} className="h-16 w-full" />
          ))}
        </CardContent>
      </Card>
    )
  }

  return (
    <Card className="overflow-hidden">
      <CardHeader className="flex flex-row items-center justify-between gap-1 p-3 sm:p-6 pb-2 sm:pb-3">
        <CardTitle className="flex items-center gap-1.5 sm:gap-2 min-w-0 text-sm sm:text-lg">
          <Calendar className="h-4 w-4 shrink-0" />
          <span className="truncate">Próximas Entregas</span>
        </CardTitle>
        <Button
          variant="ghost"
          size="sm"
          className="shrink-0 h-8 px-2 sm:px-3 gap-1"
          onClick={() => router.push('/calendar')}
        >
          <span className="hidden sm:inline text-sm">Ver calendario</span>
          <ChevronRight className="h-4 w-4" />
        </Button>
      </CardHeader>
      <CardContent className="p-3 sm:p-6 pt-0">
        {upcomingDeadlines.length === 0 ? (
          <div className="text-center py-8 text-muted-foreground">
            <Clock className="h-8 w-8 mx-auto mb-2 opacity-50" />
            <p className="text-sm">No hay entregas próximas</p>
          </div>
        ) : (
          <div className="space-y-3">
            {upcomingDeadlines.map((project) => {
              const daysLeft = Math.ceil(
                (new Date(project.proDatEnd!).getTime() - new Date().getTime()) /
                (1000 * 60 * 60 * 24)
              )

              return (
                <div
                  key={`${project.proYea}-${project.proCod}`}
                  className="flex items-center justify-between gap-2 sm:gap-4 p-2 sm:p-3 rounded-lg bg-muted/50 hover:bg-muted cursor-pointer transition-colors"
                  onClick={() => router.push(`/projects/${project.proYea}-${project.proCod}`)}
                >
                  <div className="flex items-center gap-2 sm:gap-3 min-w-0 flex-1">
                    <div
                      className="w-1 h-8 sm:h-12 rounded-full shrink-0"
                      style={{ backgroundColor: project.proStaCol || '#6b7280' }}
                    />
                    <div className="min-w-0 flex-1">
                      <p className="font-medium truncate text-sm sm:text-base">{project.proNam}</p>
                      <div className="flex items-center gap-2 mt-0.5">
                        <span className="text-[10px] sm:text-xs text-muted-foreground">{project.proPro || 0}%</span>
                        <span className="hidden sm:inline text-xs text-muted-foreground">•</span>
                        <span className="hidden sm:inline text-xs text-muted-foreground">{formatDate(project.proDatEnd)}</span>
                      </div>
                    </div>
                  </div>
                  <Badge
                    variant={daysLeft <= 3 ? 'destructive' : daysLeft <= 7 ? 'secondary' : 'outline'}
                    className="text-[10px] sm:text-xs shrink-0"
                  >
                    {daysLeft === 0 ? 'Hoy' : daysLeft === 1 ? 'Mañana' : `${daysLeft} días`}
                  </Badge>
                </div>
              )
            })}
          </div>
        )}
      </CardContent>
    </Card>
  )
}
