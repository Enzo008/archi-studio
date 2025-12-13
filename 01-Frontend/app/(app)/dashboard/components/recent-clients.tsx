/**
 * RecentClients - Muestra los clientes recientes
 * Usa el hook centralizado useDashboardData (DRY principle)
 */
'use client'

import Link from 'next/link'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Skeleton } from '@/components/ui/skeleton'
import { ArrowRight, Users, Building2, User } from 'lucide-react'
import { useDashboardData } from '@/hooks/use-dashboard-data'

export function RecentClients() {
  const { recentClients: clients, isLoading } = useDashboardData()

  if (isLoading) {
    return (
      <Card>
        <CardHeader className="flex flex-row items-center justify-between">
          <div>
            <Skeleton className="h-5 w-36 mb-2" />
            <Skeleton className="h-4 w-44" />
          </div>
          <Skeleton className="h-9 w-24" />
        </CardHeader>
        <CardContent className="space-y-4">
          {Array.from({ length: 4 }).map((_, i) => (
            <div key={i} className="flex items-center gap-3">
              <Skeleton className="h-10 w-10 rounded-full" />
              <div className="flex-1 space-y-1">
                <Skeleton className="h-4 w-32" />
                <Skeleton className="h-3 w-24" />
              </div>
              <Skeleton className="h-5 w-14 rounded-full" />
            </div>
          ))}
        </CardContent>
      </Card>
    )
  }

  if (clients.length === 0) {
    return (
      <Card>
        <CardHeader className="flex flex-row items-center justify-between">
          <div>
            <CardTitle>Clientes Recientes</CardTitle>
            <CardDescription>Últimos clientes agregados</CardDescription>
          </div>
        </CardHeader>
        <CardContent>
          <div className="flex flex-col items-center justify-center py-8 text-center">
            <Users className="h-12 w-12 text-muted-foreground mb-4" />
            <p className="text-muted-foreground">Sin clientes aún</p>
            <Button variant="outline" size="sm" className="mt-4" asChild>
              <Link href="/clients">Agregar cliente</Link>
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
          <CardTitle className="text-sm sm:text-lg">Clientes Recientes</CardTitle>
          <CardDescription className="text-[10px] sm:text-sm">Últimos clientes</CardDescription>
        </div>
        <Button variant="ghost" size="sm" className="shrink-0 h-8 px-2 sm:px-3" asChild>
          <Link href="/clients" className="gap-1">
            <span className="hidden sm:inline text-sm">Ver todos</span>
            <ArrowRight className="h-4 w-4" />
          </Link>
        </Button>
      </CardHeader>
      <CardContent className="space-y-1 sm:space-y-2 p-3 sm:p-6 pt-0">
        {clients.map((client) => (
          <div
            key={`${client.cliYea}-${client.cliCod}`}
            className="flex items-center gap-2 p-2 rounded-lg hover:bg-muted/50 transition-colors"
          >
            <div className="h-7 w-7 sm:h-9 sm:w-9 rounded-full bg-muted flex items-center justify-center shrink-0">
              {client.cliTyp === '02' ? (
                <Building2 className="h-3.5 w-3.5 sm:h-4 sm:w-4 text-muted-foreground" />
              ) : (
                <User className="h-3.5 w-3.5 sm:h-4 sm:w-4 text-muted-foreground" />
              )}
            </div>
            <div className="flex-1 min-w-0 max-w-[70%] sm:max-w-none">
              <p className="font-medium truncate text-sm">{client.cliNam}</p>
              <p className="text-[10px] text-muted-foreground truncate">
                {client.cliEma || client.cliPho || 'Sin contacto'}
              </p>
            </div>
            <div
              className={`w-2 h-2 rounded-full shrink-0 sm:hidden ${client.cliSta === 'A' ? 'bg-emerald-500' : 'bg-red-500'
                }`}
            />
            <Badge
              variant="outline"
              className={`hidden sm:inline-flex ${client.cliSta === 'A'
                  ? 'bg-emerald-500/10 text-emerald-500 border-emerald-500/20 text-xs'
                  : 'bg-red-500/10 text-red-500 border-red-500/20 text-xs'
                }`}
            >
              {client.cliSta === 'A' ? 'Activo' : 'Inactivo'}
            </Badge>
          </div>
        ))}
      </CardContent>
    </Card>
  )
}
