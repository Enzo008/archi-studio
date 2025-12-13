'use client'

/**
 * TableSkeleton - Componente reutilizable para loading de tablas
 * Soporta modo con/sin Card para coherencia visual
 */
import { Skeleton } from '@/components/ui/skeleton'
import { Card, CardContent, CardHeader } from '@/components/ui/card'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'

export interface TableSkeletonColumn {
  /** Título del header */
  header: string
  /** Ancho del skeleton (e.g., 'w-32', 'w-20') */
  width?: string
  /** Si es un badge (rounded-full) */
  isBadge?: boolean
  /** Si tiene dos líneas */
  hasSubtext?: boolean
  /** Clase responsive para ocultar */
  hideOn?: 'sm' | 'md' | 'lg' | 'xl'
}

interface TableSkeletonProps {
  /** Configuración de columnas */
  columns: TableSkeletonColumn[]
  /** Número de filas a mostrar */
  rows?: number
  /** Título del header (opcional) */
  title?: string
  /** Mostrar buscador skeleton */
  showSearch?: boolean
  /** Envolver en Card (coherencia con DataTable) */
  withCard?: boolean
}

export function TableSkeleton({ 
  columns, 
  rows = 5, 
  title,
  showSearch = true,
  withCard = true
}: TableSkeletonProps) {
  const getHideClass = (hideOn?: string) => {
    switch (hideOn) {
      case 'sm': return 'hidden sm:table-cell'
      case 'md': return 'hidden md:table-cell'
      case 'lg': return 'hidden lg:table-cell'
      case 'xl': return 'hidden xl:table-cell'
      default: return ''
    }
  }

  const tableContent = (
    <div className="rounded-lg border overflow-hidden">
      <Table>
        <TableHeader>
          <TableRow className="hover:bg-transparent bg-muted/50">
            {columns.map((col, idx) => (
              <TableHead 
                key={idx} 
                className={`text-xs uppercase text-muted-foreground ${getHideClass(col.hideOn)} ${idx === columns.length - 1 ? 'text-right' : ''}`}
              >
                {col.header}
              </TableHead>
            ))}
          </TableRow>
        </TableHeader>
        <TableBody>
          {Array.from({ length: rows }).map((_, rowIdx) => (
            <TableRow key={rowIdx}>
              {columns.map((col, colIdx) => (
                <TableCell 
                  key={colIdx}
                  className={`${getHideClass(col.hideOn)} ${colIdx === columns.length - 1 ? 'text-right' : ''}`}
                >
                  {col.hasSubtext ? (
                    <div className="space-y-1">
                      <Skeleton className={`h-4 ${col.width || 'w-32'}`} />
                      <Skeleton className="h-3 w-16" />
                    </div>
                  ) : (
                    <Skeleton 
                      className={`h-4 ${col.width || 'w-24'} ${col.isBadge ? 'rounded-full h-5' : ''} ${colIdx === columns.length - 1 ? 'ml-auto' : ''}`}
                    />
                  )}
                </TableCell>
              ))}
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </div>
  )

  // Sin Card - renderizar tabla directamente
  if (!withCard) {
    return tableContent
  }

  // Con Card
  return (
    <Card>
      {(title || showSearch) && (
        <CardHeader className="pb-4">
          <div className="flex items-center justify-between">
            {title ? (
              <Skeleton className="h-6 w-36" />
            ) : (
              <div />
            )}
            {showSearch && <Skeleton className="h-9 w-48" />}
          </div>
        </CardHeader>
      )}
      <CardContent className={!title && !showSearch ? 'pt-6' : ''}>
        {tableContent}
      </CardContent>
    </Card>
  )
}
