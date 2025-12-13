/**
 * TanStack Query Configuration Constants
 * Centralized cache settings for consistent behavior across all hooks
 * 
 * This applies DRY principle - single source of truth for cache config
 */

// Data that changes frequently (lists of entities)
export const QUERY_CACHE_LISTS = {
    staleTime: 2 * 60 * 1000,     // 2 minutes - data stays fresh
    gcTime: 10 * 60 * 1000,       // 10 minutes in garbage collection
} as const

// Data that changes rarely (catalogs, statuses)
export const QUERY_CACHE_CATALOGS = {
    staleTime: 60 * 60 * 1000,    // 1 hour - catalogs rarely change
    gcTime: 2 * 60 * 60 * 1000,   // 2 hours in garbage collection
} as const

// Single entity detail views
export const QUERY_CACHE_DETAILS = {
    staleTime: 1 * 60 * 1000,     // 1 minute
    gcTime: 5 * 60 * 1000,        // 5 minutes
} as const

// Dashboard aggregated data
export const QUERY_CACHE_DASHBOARD = {
    staleTime: 5 * 60 * 1000,     // 5 minutes
    gcTime: 30 * 60 * 1000,       // 30 minutes
} as const
