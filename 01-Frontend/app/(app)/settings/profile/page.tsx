'use client'

/**
 * Profile Settings Page - Configuración del perfil del usuario
 */
import { useUser } from '@clerk/nextjs'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Badge } from '@/components/ui/badge'
import { Separator } from '@/components/ui/separator'
import { Mail, Calendar, Shield, ExternalLink } from 'lucide-react'

export default function ProfilePage() {
  const { user, isLoaded } = useUser()

  if (!isLoaded) {
    return (
      <div className="space-y-6">
        <div className="h-8 w-48 bg-muted animate-pulse rounded" />
        <div className="h-64 bg-muted animate-pulse rounded-lg" />
      </div>
    )
  }

  const initials = user?.firstName && user?.lastName 
    ? `${user.firstName[0]}${user.lastName[0]}`
    : user?.primaryEmailAddress?.emailAddress?.[0]?.toUpperCase() || 'U'

  return (
    <div className="space-y-6 max-w-4xl">
      <div>
        <h1 className="text-2xl font-bold">Perfil</h1>
        <p className="text-muted-foreground">Gestiona tu información personal y preferencias</p>
      </div>

      {/* Información del perfil */}
      <Card>
        <CardHeader>
          <CardTitle>Información Personal</CardTitle>
          <CardDescription>Tu información de perfil sincronizada con Clerk</CardDescription>
        </CardHeader>
        <CardContent className="space-y-6">
          {/* Avatar y nombre */}
          <div className="flex items-center gap-6">
            <Avatar className="h-20 w-20 ring-2 ring-primary/20">
              <AvatarImage src={user?.imageUrl} alt={user?.fullName || 'Avatar'} />
              <AvatarFallback className="text-lg bg-primary/10 text-primary">
                {initials}
              </AvatarFallback>
            </Avatar>
            <div className="space-y-1">
              <h3 className="text-xl font-semibold">{user?.fullName || 'Usuario'}</h3>
              <div className="flex items-center gap-2 text-muted-foreground">
                <Mail className="h-4 w-4" />
                <span>{user?.primaryEmailAddress?.emailAddress}</span>
              </div>
              <Badge variant="secondary" className="mt-2">
                <Shield className="h-3 w-3 mr-1" />
                Usuario
              </Badge>
            </div>
          </div>

          <Separator />

          {/* Detalles */}
          <div className="grid gap-4 md:grid-cols-2">
            <div className="space-y-2">
              <Label>Nombre</Label>
              <Input value={user?.firstName || ''} disabled className="bg-muted" />
            </div>
            <div className="space-y-2">
              <Label>Apellido</Label>
              <Input value={user?.lastName || ''} disabled className="bg-muted" />
            </div>
            <div className="space-y-2">
              <Label>Email</Label>
              <Input value={user?.primaryEmailAddress?.emailAddress || ''} disabled className="bg-muted" />
            </div>
            <div className="space-y-2">
              <Label>Miembro desde</Label>
              <div className="flex items-center gap-2 h-10 px-3 rounded-md border bg-muted text-sm">
                <Calendar className="h-4 w-4 text-muted-foreground" />
                {user?.createdAt ? new Date(user.createdAt).toLocaleDateString('es-ES', {
                  year: 'numeric',
                  month: 'long',
                  day: 'numeric'
                }) : '-'}
              </div>
            </div>
          </div>

          <Separator />

          {/* Acciones */}
          <div className="flex items-center justify-between">
            <p className="text-sm text-muted-foreground">
              Para editar tu perfil, gestionar sesiones o cambiar tu contraseña, usa el panel de Clerk.
            </p>
            <Button
              variant="outline"
              asChild
              className="gap-2"
            >
              <a href="https://accounts.clerk.dev/user" target="_blank" rel="noopener noreferrer">
                <ExternalLink className="h-4 w-4" />
                Gestionar cuenta
              </a>
            </Button>
          </div>
        </CardContent>
      </Card>

      {/* Sesiones activas */}
      <Card>
        <CardHeader>
          <CardTitle>Seguridad</CardTitle>
          <CardDescription>Gestiona la seguridad de tu cuenta</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="flex items-center justify-between">
            <div>
              <p className="font-medium">Autenticación</p>
              <p className="text-sm text-muted-foreground">
                Tu cuenta está protegida por Clerk con autenticación segura
              </p>
            </div>
            <Badge variant="outline" className="text-emerald-500 border-emerald-500/30">
              Activo
            </Badge>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
