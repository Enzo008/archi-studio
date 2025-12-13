/**
 * InfoCard - Card de información reutilizable para páginas de detalle
 */
import { Card, CardContent, CardDescription, CardHeader } from '@/components/ui/card'
import type { LucideIcon } from 'lucide-react'

interface InfoCardProps {
  icon: LucideIcon
  label: string
  value: React.ReactNode
  className?: string
}

export function InfoCard({ icon: Icon, label, value, className }: InfoCardProps) {
  return (
    <Card className={className}>
      <CardHeader className="pb-2">
        <CardDescription className="flex items-center gap-2">
          <Icon className="h-4 w-4" />
          {label}
        </CardDescription>
      </CardHeader>
      <CardContent>
        <p className="text-lg font-semibold">{value}</p>
      </CardContent>
    </Card>
  )
}
