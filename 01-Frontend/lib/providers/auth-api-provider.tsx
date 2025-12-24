/**
 * Provider que configura el token de Clerk para el cliente API
 * Se asegura de que el token getter esté disponible antes de cualquier petición
 */
'use client';

import { useEffect, useCallback, useRef, type ReactNode } from 'react';
import { useAuth } from '@clerk/nextjs';
import { setApiTokenGetter, isAuthReady } from '@/lib/api/client';

export function AuthApiProvider({ children }: { children: ReactNode }) {
  const { getToken, isLoaded, isSignedIn } = useAuth();
  const configuredRef = useRef(false);

  // Función estable para obtener el token
  // IMPORTANTE: getToken() sin template retorna el session token
  // Para incluir el user.id (sub), se debe usar un JWT Template en Clerk Dashboard
  const getAuthToken = useCallback(async () => {
    try {
      // Si no hay sesión, retornar null
      if (!isSignedIn) return null;
      // Usar el template 'archi-studio' configurado en Clerk Dashboard
      // Si no tienes template, cambia a: return await getToken();
      return await getToken({ template: 'archi-studio' });
    } catch {
      return null;
    }
  }, [getToken, isSignedIn]);

  // Configurar el getter del token en el cliente API cuando Clerk está listo
  // Usar useLayoutEffect-like behavior para configurar lo más pronto posible
  useEffect(() => {
    if (isLoaded && !configuredRef.current) {
      configuredRef.current = true;
      setApiTokenGetter(getAuthToken);
      
      if (process.env.NODE_ENV === 'development') {
        console.log('🔐 Auth API configurado:', isSignedIn ? 'con sesión' : 'sin sesión');
      }
    }
  }, [isLoaded, getAuthToken, isSignedIn]);

  // Reconfigurar si cambia el estado de autenticación
  useEffect(() => {
    if (isLoaded && isAuthReady()) {
      setApiTokenGetter(getAuthToken);
    }
  }, [isSignedIn, getAuthToken, isLoaded]);

  return <>{children}</>;
}
