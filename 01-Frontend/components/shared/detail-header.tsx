/**
 * DetailHeader - Header reutilizable para páginas de detalle
 */
import Link from 'next/link'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { ArrowLeft, Pencil, type LucideIcon } from 'lucide-react'

interface StatusBadge {
  label: string
  color?: string
}

interface DetailHeaderProps {
  title: string
  subtitle?: string
  backHref: string
  editHref?: string
  status?: StatusBadge
  actions?: React.ReactNode
}

export function DetailHeader({
  title,
  subtitle,
  backHref,
  editHref,
  status,
  actions,
}: DetailHeaderProps) {
  return (
    <div className="flex items-start justify-between">
      <div className="flex items-center gap-4">
        <Button variant="ghost" size="icon" asChild>
          <Link href={backHref}>
            <ArrowLeft className="h-5 w-5" />
          </Link>
        </Button>
        <div>
          <h1 className="text-2xl font-bold">{title}</h1>
          {subtitle && (
            <p className="text-muted-foreground">{subtitle}</p>
          )}
        </div>
      </div>
      <div className="flex items-center gap-2">
        {status && (
          <Badge
            variant="outline"
            className="border-0"
            style={{
              backgroundColor: status.color ? `${status.color}20` : '#6b728020',
              color: status.color || '#6b7280',
            }}
          >
            {status.label}
          </Badge>
        )}
        {editHref && (
          <Button variant="outline" size="sm" asChild>
            <Link href={editHref}>
              <Pencil className="mr-2 h-4 w-4" />
              Editar
            </Link>
          </Button>
        )}
        {actions}
      </div>
    </div>
  )
}
