import Link from 'next/link'
import { Button } from '@/components/ui/button'
import { 
  Building2, ArrowRight, Sparkles, FolderKanban, 
  Calculator, Users, FileText, Zap, Shield, BarChart3
} from 'lucide-react'

/**
 * Landing Page - Página principal pública con diseño premium
 */
export default function LandingPage() {
  return (
    <div className="flex flex-col min-h-screen bg-background overflow-hidden">
      {/* Header */}
      <header className="fixed top-0 left-0 right-0 z-50 border-b border-border/40 bg-background/80 backdrop-blur-xl">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 flex h-16 items-center justify-between">
          <Link href="/" className="flex items-center gap-2 group">
            <div className="p-2 rounded-lg bg-primary/10 group-hover:bg-primary/20 transition-colors">
              <Building2 className="h-5 w-5 text-primary" />
            </div>
            <span className="text-xl font-bold tracking-tight">ArchiStudio</span>
          </Link>
          <nav className="flex items-center gap-2">
            <Link href="/sign-in">
              <Button variant="ghost" size="sm">Iniciar Sesión</Button>
            </Link>
            <Link href="/sign-up">
              <Button size="sm">Comenzar Gratis</Button>
            </Link>
          </nav>
        </div>
      </header>

      <main className="flex-1 pt-16">
        {/* Hero Section */}
        <section className="relative min-h-[90vh] flex items-center justify-center overflow-hidden">
          {/* Background Effects */}
          <div className="absolute inset-0 -z-10">
            <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-primary/20 rounded-full blur-3xl animate-pulse" />
            <div className="absolute bottom-1/4 right-1/4 w-96 h-96 bg-accent/20 rounded-full blur-3xl animate-pulse delay-1000" />
            <div className="absolute inset-0 bg-[linear-gradient(to_right,hsl(var(--border))_1px,transparent_1px),linear-gradient(to_bottom,hsl(var(--border))_1px,transparent_1px)] bg-size-[64px_64px] opacity-20" />
          </div>

          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-24 text-center">
            {/* Badge */}
            <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full border bg-card/50 backdrop-blur mb-8">
              <Sparkles className="h-4 w-4 text-primary" />
              <span className="text-sm font-medium">La nueva era del diseño arquitectónico</span>
            </div>

            {/* Title */}
            <h1 className="text-4xl sm:text-5xl md:text-6xl lg:text-7xl font-bold tracking-tight mb-6 leading-tight">
              Transforma tu estudio de
              <br />
              <span className="relative">
                <span className="bg-linear-to-r from-primary via-accent to-primary bg-clip-text text-transparent bg-size-[200%] animate-gradient">
                  arquitectura
                </span>
              </span>
            </h1>

            {/* Subtitle */}
            <p className="text-lg sm:text-xl text-muted-foreground max-w-2xl mx-auto mb-10 leading-relaxed">
              Centraliza proyectos, clientes y presupuestos en una plataforma 
              diseñada exclusivamente para arquitectos y diseñadores de interiores.
            </p>

            {/* CTA Buttons */}
            <div className="flex flex-col sm:flex-row gap-4 justify-center mb-16">
              <Link href="/sign-up">
                <Button size="lg" className="gap-2 px-8 h-12 text-base shadow-lg shadow-primary/25 hover:shadow-primary/40 transition-shadow">
                  Comenzar Gratis
                  <ArrowRight className="h-4 w-4" />
                </Button>
              </Link>
              <Link href="/sign-in">
                <Button size="lg" variant="outline" className="h-12 text-base">
                  Ya tengo cuenta
                </Button>
              </Link>
            </div>

            {/* Stats */}
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4 max-w-3xl mx-auto">
              {[
                { value: '500+', label: 'Estudios activos' },
                { value: '10k+', label: 'Proyectos gestionados' },
                { value: '99.9%', label: 'Uptime garantizado' },
                { value: '24/7', label: 'Soporte técnico' },
              ].map((stat) => (
                <div key={stat.label} className="p-4 rounded-xl border bg-card/50 backdrop-blur">
                  <div className="text-2xl font-bold text-primary">{stat.value}</div>
                  <div className="text-xs text-muted-foreground">{stat.label}</div>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* Features Section */}
        <section className="py-24 border-t bg-muted/30">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="text-center mb-16">
              <h2 className="text-3xl sm:text-4xl font-bold mb-4">
                Todo lo que necesitas en un solo lugar
              </h2>
              <p className="text-lg text-muted-foreground max-w-2xl mx-auto">
                Herramientas profesionales diseñadas para optimizar cada aspecto de tu estudio
              </p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {[
                { 
                  icon: FolderKanban, 
                  title: 'Gestión de Proyectos', 
                  description: 'Organiza proyectos con estados, hitos y seguimiento de progreso en tiempo real.',
                  color: 'text-blue-500',
                  bg: 'bg-blue-500/10'
                },
                { 
                  icon: Users, 
                  title: 'CRM de Clientes', 
                  description: 'Gestiona relaciones con clientes, historial de proyectos y comunicaciones.',
                  color: 'text-green-500',
                  bg: 'bg-green-500/10'
                },
                { 
                  icon: Calculator, 
                  title: 'Presupuestos', 
                  description: 'Crea cotizaciones detalladas con cálculos automáticos y seguimiento.',
                  color: 'text-orange-500',
                  bg: 'bg-orange-500/10'
                },
                { 
                  icon: FileText, 
                  title: 'Documentos', 
                  description: 'Almacena planos, renders, contratos y toda tu documentación en la nube.',
                  color: 'text-purple-500',
                  bg: 'bg-purple-500/10'
                },
                { 
                  icon: BarChart3, 
                  title: 'Analíticas', 
                  description: 'Métricas y reportes para tomar decisiones basadas en datos.',
                  color: 'text-pink-500',
                  bg: 'bg-pink-500/10'
                },
                { 
                  icon: Shield, 
                  title: 'Seguridad', 
                  description: 'Encriptación de datos y backups automáticos para tu tranquilidad.',
                  color: 'text-cyan-500',
                  bg: 'bg-cyan-500/10'
                },
              ].map((feature) => (
                <div 
                  key={feature.title} 
                  className="group p-6 rounded-2xl border bg-card hover:border-primary/50 transition-all duration-300 hover:shadow-lg"
                >
                  <div className={`inline-flex p-3 rounded-xl ${feature.bg} mb-4`}>
                    <feature.icon className={`h-6 w-6 ${feature.color}`} />
                  </div>
                  <h3 className="text-lg font-semibold mb-2">{feature.title}</h3>
                  <p className="text-muted-foreground text-sm leading-relaxed">
                    {feature.description}
                  </p>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* CTA Section */}
        <section className="py-24 border-t">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="relative overflow-hidden rounded-3xl bg-linear-to-br from-primary/10 via-accent/10 to-primary/10 p-12 md:p-16">
              <div className="absolute inset-0 bg-[linear-gradient(to_right,hsl(var(--border))_1px,transparent_1px),linear-gradient(to_bottom,hsl(var(--border))_1px,transparent_1px)] bg-size-[32px_32px] opacity-20" />
              
              <div className="relative text-center">
                <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full border bg-background/50 backdrop-blur mb-6">
                  <Zap className="h-4 w-4 text-primary" />
                  <span className="text-sm font-medium">Empieza gratis, sin tarjeta de crédito</span>
                </div>
                
                <h2 className="text-3xl sm:text-4xl font-bold mb-4">
                  ¿Listo para transformar tu estudio?
                </h2>
                <p className="text-lg text-muted-foreground max-w-xl mx-auto mb-8">
                  Únete a cientos de estudios de arquitectura que ya optimizaron su gestión con ArchiStudio.
                </p>
                
                <Link href="/sign-up">
                  <Button size="lg" className="gap-2 px-8 h-12 text-base">
                    Crear cuenta gratis
                    <ArrowRight className="h-4 w-4" />
                  </Button>
                </Link>
              </div>
            </div>
          </div>
        </section>
      </main>

      {/* Footer */}
      <footer className="border-t py-12 bg-muted/30">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex flex-col md:flex-row items-center justify-between gap-4">
            <div className="flex items-center gap-2">
              <div className="p-1.5 rounded-lg bg-primary/10">
                <Building2 className="h-4 w-4 text-primary" />
              </div>
              <span className="font-semibold">ArchiStudio</span>
            </div>
            <div className="text-sm text-muted-foreground">
              © {new Date().getFullYear()} ArchiStudio. Diseñado para arquitectos.
            </div>
          </div>
        </div>
      </footer>
    </div>
  )
}
