import { Sidebar } from '@/components/sidebar'
import { AppHeader } from '@/components/layout/app-header'
import { MainWrapper } from '@/components/layout/main-wrapper'

/**
 * App Layout - Layout protegido para la aplicación
 * Sidebar fixed + header sticky + contenido scrolleable
 */
export default function AppLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <div className="min-h-screen bg-background">
      {/* Sidebar fixed - visible solo en desktop */}
      <Sidebar />
      
      {/* Main wrapper con padding dinámico según sidebar */}
      <MainWrapper>
        <AppHeader />
        
        {/* Main Content */}
        <main className="p-4 lg:p-6">
          {children}
        </main>
      </MainWrapper>
    </div>
  )
}
