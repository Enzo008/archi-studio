/**
 * Settings Layout - Layout con navegación lateral para configuración
 */
'use client';

import { usePathname } from 'next/navigation';
import Link from 'next/link';
import { cn } from '@/lib/utils';
import { useRolCod } from '@/store';
import { User, Users, Shield, Settings } from 'lucide-react';

interface NavItem {
  label: string;
  href: string;
  icon: React.ComponentType<{ className?: string }>;
  adminOnly?: boolean;
}

const navItems: NavItem[] = [
  { label: 'Perfil', href: '/settings/profile', icon: User },
  { label: 'Usuarios', href: '/settings/users', icon: Users, adminOnly: true },
  { label: 'Roles', href: '/settings/roles', icon: Shield, adminOnly: true },
];

export default function SettingsLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const pathname = usePathname();
  const rolCod = useRolCod();
  
  // Verificar si es admin (rolCod = '01' es Admin típicamente)
  const isAdmin = rolCod === '01';

  // Filtrar items según rol
  const visibleItems = navItems.filter(item => !item.adminOnly || isAdmin);

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl lg:text-3xl font-bold flex items-center gap-2">
          <Settings className="h-7 w-7" />
          Configuración
        </h1>
        <p className="text-muted-foreground mt-1">
          Gestiona tu cuenta y preferencias del sistema
        </p>
      </div>

      <div className="flex flex-col lg:flex-row gap-6">
        {/* Sidebar de navegación */}
        <nav className="lg:w-56 shrink-0">
          <div className="flex lg:flex-col gap-1 overflow-x-auto lg:overflow-x-visible pb-2 lg:pb-0">
            {visibleItems.map((item) => {
              const isActive = pathname === item.href;
              const Icon = item.icon;
              
              return (
                <Link
                  key={item.href}
                  href={item.href}
                  className={cn(
                    "flex items-center gap-2 px-3 py-2 rounded-lg text-sm font-medium transition-colors whitespace-nowrap",
                    isActive
                      ? "bg-primary/10 text-primary"
                      : "text-muted-foreground hover:bg-muted hover:text-foreground"
                  )}
                >
                  <Icon className="h-4 w-4" />
                  {item.label}
                </Link>
              );
            })}
          </div>
        </nav>

        {/* Contenido */}
        <div className="flex-1 min-w-0">
          {children}
        </div>
      </div>
    </div>
  );
}
