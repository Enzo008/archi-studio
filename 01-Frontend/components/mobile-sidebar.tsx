"use client"

/**
 * MobileSidebar - Versión del sidebar para móvil (sin fixed)
 */
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
  Building2,
  UserCog,
  type LucideIcon,
} from "lucide-react"
import { useMenus } from "@/store"

const iconMap: Record<string, LucideIcon> = {
  LayoutDashboard,
  FolderKanban,
  Calculator,
  Users,
  FileText,
  Settings,
  UserCog,
}

const defaultNavItems = [
  { icon: "LayoutDashboard", label: "Dashboard", href: "/dashboard" },
  { icon: "FolderKanban", label: "Proyectos", href: "/projects" },
  { icon: "Calculator", label: "Presupuestos", href: "/budgets" },
  { icon: "Users", label: "Clientes", href: "/clients" },
  { icon: "FileText", label: "Documentos", href: "/documents" },
  { icon: "Settings", label: "Configuración", href: "/settings" },
]

interface MobileSidebarProps {
  onNavigate?: () => void
}

export function MobileSidebar({ onNavigate }: MobileSidebarProps) {
  const pathname = usePathname()
  const menus = useMenus()

  const navItems = menus.length > 0
    ? menus.map(menu => ({
        icon: menu.menIco || "FileText",
        label: menu.menNam,
        href: menu.menRef || "#",
      }))
    : defaultNavItems

  const handleClick = () => {
    onNavigate?.()
  }

  return (
    <aside className="flex flex-col bg-sidebar h-full">
      <div className="flex items-center gap-3 p-4 border-b border-sidebar-border">
        <Link href="/dashboard" onClick={handleClick} className="flex items-center gap-3">
          <div className="flex items-center justify-center w-10 h-10 rounded-lg bg-primary/20">
            <Building2 className="w-5 h-5 text-primary" />
          </div>
          <span className="font-semibold text-lg text-sidebar-foreground">ArchiStudio</span>
        </Link>
      </div>

      <nav className="flex-1 p-3 space-y-1">
        {navItems.map((item) => {
          const isActive = pathname === item.href || pathname.startsWith(item.href + '/')
          const Icon = iconMap[item.icon] || FileText
          
          return (
            <Link
              key={item.href}
              href={item.href}
              onClick={handleClick}
              className={cn(
                "flex items-center gap-3 w-full px-3 py-2.5 rounded-lg text-sm font-medium transition-all",
                isActive
                  ? "bg-primary/20 text-primary"
                  : "text-muted-foreground hover:bg-sidebar-accent hover:text-sidebar-foreground",
              )}
            >
              <Icon className="w-5 h-5 shrink-0" />
              <span>{item.label}</span>
            </Link>
          )
        })}
      </nav>
    </aside>
  )
}
