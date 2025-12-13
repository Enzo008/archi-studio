'use client'

/**
 * AppHeader - Header principal de la aplicación con breadcrumbs y user menu
 */
import { useState, useEffect } from 'react'
import { usePathname } from 'next/navigation'
import Link from 'next/link'
import { UserButton } from '@clerk/nextjs'
import { Button } from '@/components/ui/button'
import { ThemeToggle } from '@/components/theme-toggle'
import { NotificationsDropdown } from '@/components/notifications-dropdown'
import { ChevronRight, Menu } from 'lucide-react'
import { Sheet, SheetContent, SheetTrigger, SheetTitle } from '@/components/ui/sheet'
import { MobileSidebar } from '@/components/mobile-sidebar'
import { GlobalSearch } from './global-search'

// Mapeo de rutas a nombres legibles
const routeNames: Record<string, string> = {
  dashboard: 'Dashboard',
  projects: 'Proyectos',
  budgets: 'Presupuestos',
  clients: 'Clientes',
  documents: 'Documentos',
  calendar: 'Calendario',
  settings: 'Configuración',
  profile: 'Perfil',
  new: 'Nuevo',
  edit: 'Editar',
}

// Detecta si es un ID dinámico (formato año-código: YYYY-NNNNNN)
const isDynamicId = (segment: string) => /^\d{4}-\d{6}$/.test(segment)

// Obtiene el nombre amigable del segmento
const getSegmentName = (segment: string, segments: string[], index: number): string => {
  // Si es un ID dinámico, mostrar según el contexto
  if (isDynamicId(segment)) {
    // Si el siguiente segmento es 'edit', no mostrar nada aquí
    const nextSegment = segments[index + 1]
    if (nextSegment === 'edit') return ''
    return 'Detalle'
  }

  return routeNames[segment] || segment
}

function Breadcrumbs() {
  const pathname = usePathname()
  const segments = pathname.split('/').filter(Boolean)

  if (segments.length === 0) return null

  // Filtrar segmentos vacíos después de procesar
  const breadcrumbItems = segments
    .map((segment, index) => ({
      segment,
      index,
      name: getSegmentName(segment, segments, index),
      href: '/' + segments.slice(0, index + 1).join('/'),
    }))
    .filter(item => item.name !== '') // Filtrar segmentos sin nombre

  return (
    <nav className="flex items-center gap-1 text-sm">
      {breadcrumbItems.map((item, displayIndex) => {
        const isLast = displayIndex === breadcrumbItems.length - 1

        return (
          <span key={item.segment} className="flex items-center gap-1">
            {displayIndex > 0 && <ChevronRight className="h-4 w-4 text-muted-foreground" />}
            {isLast ? (
              <span className="font-medium text-foreground">{item.name}</span>
            ) : (
              <Link href={item.href} className="text-muted-foreground hover:text-foreground transition-colors">
                {item.name}
              </Link>
            )}
          </span>
        )
      })}
    </nav>
  )
}

export function AppHeader() {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false)
  // Prevent hydration mismatch with Radix UI components
  const [mounted, setMounted] = useState(false)

  useEffect(() => {
    setMounted(true)
  }, [])

  return (
    <header className="h-16 border-b flex items-center justify-between px-4 lg:px-6 bg-background/95 backdrop-blur sticky top-0 z-40">
      {/* Mobile menu + Breadcrumbs */}
      <div className="flex items-center gap-4">
        {/* Only render Sheet after mount to prevent hydration mismatch with Radix IDs */}
        {mounted ? (
          <Sheet open={mobileMenuOpen} onOpenChange={setMobileMenuOpen}>
            <SheetTrigger asChild>
              <Button variant="ghost" size="icon" className="lg:hidden">
                <Menu className="h-5 w-5" />
              </Button>
            </SheetTrigger>
            <SheetContent side="left" className="p-0 w-64">
              <SheetTitle className="sr-only">Menú de navegación</SheetTitle>
              <MobileSidebar onNavigate={() => setMobileMenuOpen(false)} />
            </SheetContent>
          </Sheet>
        ) : (
          <Button variant="ghost" size="icon" className="lg:hidden">
            <Menu className="h-5 w-5" />
          </Button>
        )}

        <Breadcrumbs />
      </div>

      {/* Actions */}
      <div className="flex items-center gap-3">
        <GlobalSearch />

        <ThemeToggle />

        <NotificationsDropdown />

        <UserButton
          afterSignOutUrl="/"
          appearance={{
            elements: {
              avatarBox: 'h-8 w-8',
            }
          }}
        />
      </div>
    </header>
  )
}
