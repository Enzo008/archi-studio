/**
 * RecentProjects - Muestra los proyectos recientes
 * Usa el hook centralizado useDashboardData (DRY principle)
 */
'use client'

import Link from 'next/link'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Skeleton } from '@/components/ui/skeleton'
import { ArrowRight, FolderKanban } from 'lucide-react'
import { useDashboardData } from '@/hooks/use-dashboard-data'
import type { Project } from '@/types'

export function RecentProjects() {
  const { recentProjects: projects, isLoading } = useDashboardData()

  const getProjectUrl = (project: Project) => `/projects/${project.proYea}-${project.proCod}`

  if (isLoading) {
    return (
      <Card>
        <CardHeader className="flex flex-row items-center justify-between">
          <div>
            <Skeleton className="h-5 w-40 mb-2" />
            <Skeleton className="h-4 w-48" />
          </div>
          <Skeleton className="h-9 w-24" />
        </CardHeader>
        <CardContent className="space-y-4">
          {Array.from({ length: 3 }).map((_, i) => (
            <div key={i} className="flex items-center justify-between p-3 rounded-lg border">
              <div className="space-y-2">
                <Skeleton className="h-4 w-48" />
                <Skeleton className="h-3 w-32" />
              </div>
              <div className="space-y-2 text-right">
                <Skeleton className="h-2 w-24" />
                <Skeleton className="h-3 w-16 ml-auto" />
              </div>
            </div>
          ))}
        </CardContent>
      </Card>
    )
  }

  if (projects.length === 0) {
    return (
      <Card>
        <CardHeader className="flex flex-row items-center justify-between">
          <div>
            <CardTitle>Proyectos Recientes</CardTitle>
            <CardDescription>Tus últimos proyectos</CardDescription>
          </div>
        </CardHeader>
        <CardContent>
          <div className="flex flex-col items-center justify-center py-8 text-center">
            <FolderKanban className="h-12 w-12 text-muted-foreground mb-4" />
            <p className="text-muted-foreground">Sin proyectos aún</p>
            <Button variant="outline" size="sm" className="mt-4" asChild>
              <Link href="/projects">Crear proyecto</Link>
            </Button>
          </div>
        </CardContent>
      </Card>
    )
  }

  return (
    <Card className="overflow-hidden">
      <CardHeader className="flex flex-row items-center justify-between gap-1 p-3 sm:p-6 pb-2 sm:pb-3">
        <div className="min-w-0 flex-1">
          <CardTitle className="text-sm sm:text-lg">Proyectos Recientes</CardTitle>
          <CardDescription className="text-[10px] sm:text-sm">Tus proyectos activos</CardDescription>
        </div>
        <Button variant="ghost" size="sm" className="shrink-0 h-8 px-2 sm:px-3" asChild>
          <Link href="/projects" className="gap-1">
            <span className="hidden sm:inline text-sm">Ver todos</span>
            <ArrowRight className="h-4 w-4" />
          </Link>
        </Button>
      </CardHeader>
      <CardContent className="space-y-1 sm:space-y-2 p-3 sm:p-6 pt-0">
        {projects.map((project) => (
          <Link
            key={`${project.proYea}-${project.proCod}`}
            href={getProjectUrl(project)}
            className="flex items-center justify-between p-2 sm:p-3 rounded-lg hover:bg-muted/50 transition-colors"
          >
            <div className="space-y-0.5 min-w-0 flex-1 max-w-[65%] sm:max-w-none">
              <p className="font-medium truncate text-sm sm:text-base">{project.proNam}</p>
              <p className="text-xs sm:text-sm text-muted-foreground truncate">
                {project.cliNam || 'Sin cliente'}
              </p>
            </div>
            <div className="shrink-0 flex items-center gap-3">
              <div className="hidden sm:block w-24 lg:w-32 h-2 bg-muted rounded-full overflow-hidden">
                <div
                  className="h-full bg-primary rounded-full"
                  style={{ width: `${project.proPro || 0}%` }}
                />
              </div>
              <span className="text-sm font-semibold w-10 text-right">{project.proPro || 0}%</span>
            </div>
          </Link>
        ))}
      </CardContent>
    </Card>
  )
}
