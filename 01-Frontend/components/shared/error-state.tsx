/**
 * ErrorState - Estado de error reutilizable para páginas de detalle
 */
'use client'

import { useRouter } from 'next/navigation'
import { Button } from '@/components/ui/button'
import { ArrowLeft, type LucideIcon } from 'lucide-react'

interface ErrorStateProps {
  icon: LucideIcon
  title: string
  description?: string
  backHref?: string
  backLabel?: string
}

export function ErrorState({ 
  icon: Icon, 
  title, 
  description,
  backHref,
  backLabel = 'Volver',
}: ErrorStateProps) {
  const router = useRouter()
  
  const handleBack = () => {
    if (backHref) {
      router.push(backHref)
    } else {
      router.back()
    }
  }
  
  return (
    <div className="flex flex-col items-center justify-center py-12 space-y-4">
      <Icon className="h-12 w-12 text-muted-foreground" />
      <h2 className="text-xl font-semibold">{title}</h2>
      {description && (
        <p className="text-muted-foreground text-center max-w-md">{description}</p>
      )}
      <Button variant="outline" onClick={handleBack}>
        <ArrowLeft className="mr-2 h-4 w-4" />
        {backLabel}
      </Button>
    </div>
  )
}
