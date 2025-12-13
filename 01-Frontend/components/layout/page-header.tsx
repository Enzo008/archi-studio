/**
 * PageHeader - Encabezado reutilizable para páginas
 */
'use client';

import Link from 'next/link'
import { Button } from '@/components/ui/button'
import { Plus } from 'lucide-react'

interface PageHeaderProps {
  title: string
  description?: string
  action?: {
    label: string
    href?: string
    onClick?: () => void
  }
  children?: React.ReactNode
}

export function PageHeader({ title, description, action, children }: PageHeaderProps) {
  return (
    <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
      <div>
        <h1 className="text-2xl lg:text-3xl font-bold text-foreground">{title}</h1>
        {description && (
          <p className="text-muted-foreground mt-1">{description}</p>
        )}
      </div>
      
      <div className="flex items-center gap-2">
        {children}
        {action && action.href && (
          <Button asChild className="bg-primary hover:bg-primary/90">
            <Link href={action.href}>
              <Plus className="w-4 h-4 mr-2" />
              {action.label}
            </Link>
          </Button>
        )}
        {action && action.onClick && !action.href && (
          <Button onClick={action.onClick} className="bg-primary hover:bg-primary/90">
            <Plus className="w-4 h-4 mr-2" />
            {action.label}
          </Button>
        )}
      </div>
    </div>
  )
}
