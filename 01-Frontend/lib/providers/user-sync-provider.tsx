/**
 * UserSyncProvider - Sincroniza usuario de Clerk con el backend
 * Se ejecuta automáticamente cuando el usuario inicia sesión
 */
'use client'

import { useEffect, useRef, type ReactNode } from 'react'
import { useAuth, useUser } from '@clerk/nextjs'
import { userService } from '@/lib/api/services/user-service'
import { isAuthReady, waitForAuth } from '@/lib/api/client'
import { useAuthActions } from '@/store/auth-store'

export function UserSyncProvider({ children }: { children: ReactNode }) {
  const { isLoaded, isSignedIn } = useAuth()
  const { user } = useUser()
  const syncAttempted = useRef(false)
  const { setUserData } = useAuthActions()

  useEffect(() => {
    async function syncUser() {
      // Evitar sincronización si ya se intentó o no hay usuario
      if (!isLoaded || !isSignedIn || !user || syncAttempted.current) {
        return
      }

      // Esperar a que el token getter esté configurado
      if (!isAuthReady()) {
        const ready = await waitForAuth()
        if (!ready) {
          console.warn('⚠️ Auth timeout en UserSyncProvider')
          return
        }
      }

      syncAttempted.current = true

      try {
        const response = await userService.sync({
          externalId: user.id,
          email: user.primaryEmailAddress?.emailAddress || '',
          firstName: user.firstName || undefined,
          lastName: user.lastName || undefined,
          imageUrl: user.imageUrl || undefined,
        })

        if (response.success && response.data) {
          // Guardar datos del usuario en el store
          setUserData(response.data)
          if (process.env.NODE_ENV === 'development') {
            console.log('✅ Usuario sincronizado:', response.data.isNewUser ? 'NUEVO' : 'EXISTENTE')
          }
        } else {
          console.warn('⚠️ Error sincronizando usuario:', response.message)
        }
      } catch (error) {
        console.error('❌ Error en sync:', error)
        // Reset para reintentar en próxima carga
        syncAttempted.current = false
      }
    }

    syncUser()
  }, [isLoaded, isSignedIn, user])

  return <>{children}</>
}
