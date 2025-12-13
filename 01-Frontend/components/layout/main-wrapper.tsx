'use client'

import { useIsCollapsed } from '@/store'
import { cn } from '@/lib/utils'

/**
 * MainWrapper - Wrapper del contenido principal que ajusta el padding según el sidebar
 */
export function MainWrapper({ children }: { children: React.ReactNode }) {
  const isCollapsed = useIsCollapsed()

  return (
    <div 
      className={cn(
        "min-h-screen transition-all duration-300",
        isCollapsed ? "lg:pl-16" : "lg:pl-64"
      )}
    >
      {children}
    </div>
  )
}
