/**
 * DetailSkeleton - Skeleton reutilizable para páginas de detalle
 */
import { Skeleton } from '@/components/ui/skeleton'

interface DetailSkeletonProps {
  /** Número de cards en el grid de información */
  infoCards?: number
  /** Número de cards grandes en la sección de contenido */
  contentCards?: number
}

export function DetailSkeleton({ 
  infoCards = 4, 
  contentCards = 2 
}: DetailSkeletonProps) {
  return (
    <div className="space-y-6">
      {/* Header skeleton */}
      <div className="flex items-center gap-4">
        <Skeleton className="h-10 w-10" />
        <div className="space-y-2">
          <Skeleton className="h-6 w-64" />
          <Skeleton className="h-4 w-32" />
        </div>
      </div>
      
      {/* Info cards skeleton */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        {Array.from({ length: infoCards }).map((_, i) => (
          <Skeleton key={i} className="h-24" />
        ))}
      </div>
      
      {/* Content cards skeleton */}
      <div className="grid gap-6 lg:grid-cols-2">
        {Array.from({ length: contentCards }).map((_, i) => (
          <Skeleton key={i} className="h-40" />
        ))}
      </div>
    </div>
  )
}
