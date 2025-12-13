/**
 * API Client con interceptores JWT para Clerk
 * Espera automáticamente a que Clerk esté listo antes de hacer peticiones
 */

import type { ApiResponse } from '@/types';

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:5181';
const AUTH_TIMEOUT_MS = 5000; // 5 segundos máximo de espera

interface FetchOptions extends RequestInit {
  skipAuth?: boolean;
}

// Estado de autenticación
let tokenGetterFn: (() => Promise<string | null>) | null = null;
let authReadyResolve: (() => void) | null = null;
let authReadyPromise: Promise<void> = new Promise((resolve) => {
  authReadyResolve = resolve;
});
let _isAuthReady = false;

/**
 * Configura la función para obtener el token (llamado desde AuthApiProvider)
 */
export function setApiTokenGetter(getter: () => Promise<string | null>) {
  tokenGetterFn = getter;
  _isAuthReady = true;
  authReadyResolve?.();
}

/**
 * Verifica si el auth está listo
 */
export function isAuthReady(): boolean {
  return _isAuthReady;
}

/**
 * Espera a que el auth esté listo con timeout
 */
export async function waitForAuth(): Promise<boolean> {
  if (_isAuthReady) return true;

  // Esperar con timeout
  const timeoutPromise = new Promise<boolean>((resolve) =>
    setTimeout(() => resolve(false), AUTH_TIMEOUT_MS)
  );

  const readyPromise = authReadyPromise.then(() => true);

  return Promise.race([readyPromise, timeoutPromise]);
}

/**
 * Obtiene el token JWT de Clerk (espera a que esté listo)
 */
export async function getClerkToken(): Promise<string | null> {
  // Esperar a que auth esté configurado
  if (!_isAuthReady) {
    const isReady = await waitForAuth();
    if (!isReady) {
      console.warn('⚠️ Auth timeout - continuando sin token');
      return null;
    }
  }

  // Obtener token del provider
  if (tokenGetterFn) {
    try {
      return await tokenGetterFn();
    } catch {
      // Silenciar error, intentar fallback
    }
  }

  // Fallback: intentar obtener desde window.Clerk
  if (typeof window !== 'undefined') {
    const clerk = (window as unknown as { Clerk?: { session?: { getToken: () => Promise<string> } } }).Clerk;
    if (clerk?.session) {
      try {
        return await clerk.session.getToken();
      } catch {
        // Silenciar error
      }
    }
  }

  return null;
}

/**
 * Cliente HTTP que agrega automáticamente el token JWT de Clerk
 * Espera a que Clerk esté listo antes de hacer la petición
 */
export async function apiClient<T>(
  endpoint: string,
  options: FetchOptions = {}
): Promise<ApiResponse<T>> {
  const { skipAuth = false, ...fetchOptions } = options;

  const headers = new Headers(fetchOptions.headers);
  headers.set('Content-Type', 'application/json');

  // Agregar token JWT si no se omite auth
  if (!skipAuth && typeof window !== 'undefined') {
    const token = await getClerkToken();
    if (token) {
      headers.set('Authorization', `Bearer ${token}`);
    }
  }

  const response = await fetch(`${API_URL}${endpoint}`, {
    ...fetchOptions,
    headers,
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new ApiError(
      error.message || `HTTP Error: ${response.status}`,
      response.status,
      error
    );
  }

  return response.json();
}

/**
 * Error personalizado para la API
 */
export class ApiError extends Error {
  constructor(
    message: string,
    public status: number,
    public data?: unknown
  ) {
    super(message);
    this.name = 'ApiError';
  }
}

/**
 * Cliente HTTP para uploads (FormData)
 */
export async function apiUpload<T>(
  endpoint: string,
  formData: FormData,
  options: FetchOptions = {}
): Promise<ApiResponse<T>> {
  const { skipAuth = false, ...fetchOptions } = options;

  const headers = new Headers(fetchOptions.headers);
  // NO establecer Content-Type para FormData, el browser lo hace automáticamente

  // Agregar token JWT
  if (!skipAuth && typeof window !== 'undefined') {
    const token = await getClerkToken();
    if (token) {
      headers.set('Authorization', `Bearer ${token}`);
    }
  }

  const response = await fetch(`${API_URL}${endpoint}`, {
    ...fetchOptions,
    method: 'POST',
    headers,
    body: formData,
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new ApiError(
      error.message || `HTTP Error: ${response.status}`,
      response.status,
      error
    );
  }

  return response.json();
}

// Métodos de conveniencia
export const api = {
  get: <T>(endpoint: string, options?: FetchOptions) =>
    apiClient<T>(endpoint, { ...options, method: 'GET' }),

  post: <T>(endpoint: string, data?: unknown, options?: FetchOptions) =>
    apiClient<T>(endpoint, {
      ...options,
      method: 'POST',
      body: data ? JSON.stringify(data) : undefined,
    }),

  put: <T>(endpoint: string, data?: unknown, options?: FetchOptions) =>
    apiClient<T>(endpoint, {
      ...options,
      method: 'PUT',
      body: data ? JSON.stringify(data) : undefined,
    }),

  delete: <T>(endpoint: string, options?: FetchOptions) =>
    apiClient<T>(endpoint, { ...options, method: 'DELETE' }),

  upload: <T>(endpoint: string, formData: FormData, options?: FetchOptions) =>
    apiUpload<T>(endpoint, formData, options),
};
