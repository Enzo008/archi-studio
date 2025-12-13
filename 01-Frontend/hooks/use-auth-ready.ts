/**
 * Hook para verificar si la autenticación está lista para hacer peticiones API
 */
'use client';

import { useState, useEffect } from 'react';
import { useAuth } from '@clerk/nextjs';
import { isAuthReady, waitForAuth } from '@/lib/api/client';

/**
 * Hook que indica si el sistema de autenticación está listo para hacer peticiones
 * Útil para condicionar el fetch de datos a que Clerk esté cargado
 */
export function useAuthReady() {
  const { isLoaded, isSignedIn } = useAuth();
  const [ready, setReady] = useState(false);

  useEffect(() => {
    // Si Clerk no ha cargado, no hacer nada
    if (!isLoaded) return;

    // Si ya está ready en el cliente API, marcar como ready
    if (isAuthReady()) {
      setReady(true);
      return;
    }

    // Esperar a que el auth esté configurado
    let mounted = true;
    waitForAuth().then((success) => {
      if (mounted) {
        setReady(success || !isSignedIn); // Ready si auth OK o si no hay sesión
      }
    });

    return () => { mounted = false; };
  }, [isLoaded, isSignedIn]);

  return { isReady: ready, isLoaded, isSignedIn };
}
