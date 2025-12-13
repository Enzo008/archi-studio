import Link from 'next/link'
import { Building2, FolderKanban, Users, Calculator, Shield } from 'lucide-react'

const features = [
  { icon: FolderKanban, text: 'Gestión integral de proyectos' },
  { icon: Users, text: 'CRM de clientes integrado' },
  { icon: Calculator, text: 'Presupuestos automatizados' },
  { icon: Shield, text: 'Datos seguros y encriptados' },
]

/**
 * Auth Layout - Diseño split premium para autenticación
 */
export default function AuthLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <div className="min-h-screen flex">
      {/* Left Panel - Branding (hidden on mobile) */}
      <div className="hidden lg:flex lg:w-1/2 xl:w-[55%] relative bg-card overflow-hidden">
        {/* Background Effects */}
        <div className="absolute inset-0">
          <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-primary/10 rounded-full blur-3xl" />
          <div className="absolute bottom-1/4 right-1/4 w-80 h-80 bg-accent/10 rounded-full blur-3xl" />
          <div className="absolute inset-0 bg-[linear-gradient(to_right,hsl(var(--border))_1px,transparent_1px),linear-gradient(to_bottom,hsl(var(--border))_1px,transparent_1px)] bg-size-[48px_48px] opacity-30" />
        </div>

        {/* Content */}
        <div className="relative flex flex-col justify-between p-12 xl:p-16 w-full">
          {/* Logo */}
          <Link href="/" className="flex items-center gap-3 group">
            <div className="p-2.5 rounded-xl bg-primary/10 group-hover:bg-primary/20 transition-colors">
              <Building2 className="h-7 w-7 text-primary" />
            </div>
            <span className="text-2xl font-bold tracking-tight">ArchiStudio</span>
          </Link>

          {/* Main Content */}
          <div className="space-y-8">
            <div>
              <h1 className="text-4xl xl:text-5xl font-bold tracking-tight leading-tight">
                La plataforma que tu
                <br />
                <span className="text-primary">estudio necesita</span>
              </h1>
              <p className="mt-4 text-lg text-muted-foreground max-w-md">
                Únete a cientos de arquitectos que ya optimizaron su gestión de proyectos con ArchiStudio.
              </p>
            </div>

            {/* Features */}
            <div className="grid grid-cols-2 gap-4">
              {features.map((feature) => (
                <div 
                  key={feature.text}
                  className="flex items-center gap-3 p-3 rounded-lg bg-background/50 backdrop-blur border border-border/50"
                >
                  <feature.icon className="h-5 w-5 text-primary shrink-0" />
                  <span className="text-sm font-medium">{feature.text}</span>
                </div>
              ))}
            </div>
          </div>

          {/* Footer */}
          <div className="space-y-4">
            {/* Testimonial */}
            <blockquote className="p-4 rounded-xl bg-background/50 backdrop-blur border border-border/50">
              <p className="text-sm italic text-muted-foreground">
                &ldquo;ArchiStudio transformó la forma en que gestionamos nuestros proyectos. 
                Ahora todo está centralizado y accesible.&rdquo;
              </p>
              <footer className="mt-3 flex items-center gap-3">
                <div className="w-8 h-8 rounded-full bg-primary/20 flex items-center justify-center">
                  <span className="text-xs font-bold text-primary">MG</span>
                </div>
                <div>
                  <p className="text-sm font-medium">María González</p>
                  <p className="text-xs text-muted-foreground">Arquitecta, Studio MG</p>
                </div>
              </footer>
            </blockquote>

            <p className="text-xs text-muted-foreground">
              © {new Date().getFullYear()} ArchiStudio. Todos los derechos reservados.
            </p>
          </div>
        </div>
      </div>

      {/* Right Panel - Auth Form */}
      <div className="flex-1 flex flex-col min-h-screen bg-background">
        {/* Mobile Logo */}
        <div className="lg:hidden p-6">
          <Link href="/" className="flex items-center gap-2">
            <div className="p-2 rounded-lg bg-primary/10">
              <Building2 className="h-5 w-5 text-primary" />
            </div>
            <span className="text-xl font-bold">ArchiStudio</span>
          </Link>
        </div>

        {/* Form Container */}
        <div className="flex-1 flex items-center justify-center p-6">
          <div className="w-full max-w-[400px]">
            {children}
          </div>
        </div>

        {/* Mobile Footer */}
        <div className="lg:hidden p-6 text-center">
          <p className="text-xs text-muted-foreground">
            © {new Date().getFullYear()} ArchiStudio. Plataforma para arquitectos.
          </p>
        </div>
      </div>
    </div>
  )
}
