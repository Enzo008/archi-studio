"use client"

import { usePathname } from "next/navigation"
import Link from "next/link"
import { cn } from "@/lib/utils"
import {
  LayoutDashboard,
  FolderKanban,
  Calculator,
  Users,
  FileText,
  Settings,
  ChevronLeft,
  Building2,
  UserCog,
  Calendar,
  type LucideIcon,
} from "lucide-react"
import { Button } from "@/components/ui/button"
import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from "@/components/ui/tooltip"
import { useMenus, useIsSynced } from "@/store"
import { useIsCollapsed, useSidebarActions } from "@/store"

// Mapeo de iconos por nombre
const iconMap: Record<string, LucideIcon> = {
  LayoutDashboard,
  FolderKanban,
  Calculator,
  Users,
  FileText,
  Settings,
  UserCog,
  Calendar,
}

// Menús por defecto (fallback solo si no ha sincronizado nunca)
const defaultNavItems = [
  { icon: "LayoutDashboard", label: "Dashboard", href: "/dashboard" },
  { icon: "FolderKanban", label: "Proyectos", href: "/projects" },
  { icon: "Calculator", label: "Presupuestos", href: "/budgets" },
  { icon: "Users", label: "Clientes", href: "/clients" },
  { icon: "FileText", label: "Documentos", href: "/documents" },
  { icon: "Settings", label: "Configuración", href: "/settings" },
]

export function Sidebar({ className }: { className?: string }) {
  const pathname = usePathname()
  const menus = useMenus()
  const isSynced = useIsSynced()
  const isCollapsed = useIsCollapsed()
  const { toggle } = useSidebarActions()

  // Usar menús del backend si existen, sino usar defaults solo si nunca se ha sincronizado
  const navItems = menus.length > 0
    ? menus.map(menu => ({
      icon: menu.menIco || "FileText",
      label: menu.menNam,
      href: menu.menRef || "#",
    }))
    : isSynced
      ? [] // Usuario sincronizado pero sin menús asignados
      : defaultNavItems // Primera carga antes de sincronizar

  return (
    <aside
      className={cn(
        "fixed top-0 left-0 z-50 hidden lg:flex flex-col bg-sidebar border-r border-sidebar-border transition-all duration-300 h-screen",
        isCollapsed ? "w-16" : "w-64",
        className,
      )}
    >
      <div className="flex items-center gap-3 p-4 border-b border-sidebar-border">
        <Link href="/dashboard" className="flex items-center gap-3">
          <div className="flex items-center justify-center w-10 h-10 rounded-lg bg-primary/20 neon-glow">
            <Building2 className="w-5 h-5 text-primary" />
          </div>
          {!isCollapsed && <span className="font-semibold text-lg text-sidebar-foreground neon-text">ArchiStudio</span>}
        </Link>
      </div>

      <TooltipProvider delayDuration={0}>
        <nav className="flex-1 p-3 space-y-1">
          {navItems.map((item) => {
            const isActive = pathname === item.href || pathname.startsWith(item.href + '/')
            const Icon = iconMap[item.icon] || FileText

            const linkContent = (
              <Link
                href={item.href}
                className={cn(
                  "flex items-center gap-3 w-full px-3 py-2.5 rounded-lg text-sm font-medium transition-all",
                  isCollapsed && "justify-center px-2",
                  isActive
                    ? "bg-primary/20 text-primary neon-glow"
                    : "text-muted-foreground hover:bg-sidebar-accent hover:text-sidebar-foreground",
                )}
              >
                <Icon className="w-5 h-5 shrink-0" />
                {!isCollapsed && <span>{item.label}</span>}
              </Link>
            )

            // Mostrar tooltip solo cuando está colapsado
            if (isCollapsed) {
              return (
                <Tooltip key={item.href}>
                  <TooltipTrigger asChild>
                    {linkContent}
                  </TooltipTrigger>
                  <TooltipContent side="right" className="font-medium">
                    {item.label}
                  </TooltipContent>
                </Tooltip>
              )
            }

            return <div key={item.href}>{linkContent}</div>
          })}
        </nav>
      </TooltipProvider>

      <div className="p-3 border-t border-sidebar-border">
        <Button variant="ghost" size="sm" className="w-full justify-center" onClick={toggle}>
          <ChevronLeft className={cn("w-4 h-4 transition-transform", isCollapsed && "rotate-180")} />
        </Button>
      </div>
    </aside>
  )
}
