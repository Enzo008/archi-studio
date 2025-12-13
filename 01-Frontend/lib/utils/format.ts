/**
 * Helpers de formateo reutilizables
 */

/**
 * Formatea una fecha ISO a formato legible
 */
export function formatDate(dateStr?: string | null, options?: Intl.DateTimeFormatOptions) {
  if (!dateStr) return '-'
  
  const defaultOptions: Intl.DateTimeFormatOptions = {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
  }
  
  return new Intl.DateTimeFormat('es-ES', options ?? defaultOptions).format(new Date(dateStr))
}

/**
 * Formatea una fecha a formato largo (ej: "15 de enero de 2025")
 */
export function formatDateLong(dateStr?: string | null) {
  return formatDate(dateStr, {
    day: '2-digit',
    month: 'long',
    year: 'numeric',
  })
}

/**
 * Formatea un número como moneda
 */
export function formatCurrency(amount?: number | null, currency = 'USD') {
  if (amount === undefined || amount === null) return '-'
  
  return new Intl.NumberFormat('es-PE', {
    style: 'currency',
    currency,
  }).format(amount)
}

/**
 * Formatea un porcentaje
 */
export function formatPercent(value?: number | null) {
  if (value === undefined || value === null) return '0%'
  return `${value}%`
}
