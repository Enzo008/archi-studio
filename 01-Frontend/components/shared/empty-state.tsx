/**
 * EmptyState - Componente reutilizable para estados vacíos
 */
import { Card, CardContent } from '@/components/ui/card'
import { type LucideIcon } from 'lucide-react'

interface EmptyStateProps {
  /** Icono a mostrar */
  icon: LucideIcon
  /** Título del estado vacío */
  title: string
  /** Descripción o mensaje */
  description: string
  /** Acción opcional (botón, link, etc.) */
  action?: React.ReactNode
}

export function EmptyState({ icon: Icon, title, description, action }: EmptyStateProps) {
  return (
    <Card>
      <CardContent className="p-8 text-center">
        <Icon className="mx-auto h-12 w-12 text-muted-foreground/50" />
        <h3 className="mt-4 text-lg font-medium">{title}</h3>
        <p className="mt-2 text-sm text-muted-foreground">{description}</p>
        {action && <div className="mt-4">{action}</div>}
      </CardContent>
    </Card>
  )
}
