/**
 * GlobalSearch - Búsqueda global con autocompletado inteligente
 * Optimizado: Usa TanStack Query para datos cacheados (no refetcha en cada keystroke)
 */
'use client'

import { useState, useEffect, useRef, useCallback, useMemo } from 'react'
import { useRouter } from 'next/navigation'
import { useQuery } from '@tanstack/react-query'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import {
  Search, FolderKanban, Users, Calculator,
  ArrowRight, Loader2, X
} from 'lucide-react'
import { projectService } from '@/lib/api/services/project-service'
import { clientService } from '@/lib/api/services/client-service'
import { budgetService } from '@/lib/api/services/budget-service'
import { useAuthReady } from '@/hooks/use-auth-ready'
import type { Project, Client, Budget } from '@/types'
import { cn } from '@/lib/utils'

interface SearchResult {
  id: string
  type: 'project' | 'client' | 'budget'
  title: string
  subtitle?: string
  url: string
  status?: { name: string; color?: string }
}

// Query key for search data - separate from main lists
const searchDataKey = ['search', 'data'] as const

export function GlobalSearch() {
  const router = useRouter()
  const inputRef = useRef<HTMLInputElement>(null)
  const containerRef = useRef<HTMLDivElement>(null)
  const { isReady } = useAuthReady()

  const [query, setQuery] = useState('')
  const [isOpen, setIsOpen] = useState(false)
  const [selectedIndex, setSelectedIndex] = useState(0)

  // Fetch all data once and cache it (staleTime: 2 min)
  // Much better than fetching 3 times on every keystroke
  const { data: searchData, isLoading: isLoadingData } = useQuery({
    queryKey: searchDataKey,
    queryFn: async () => {
      const [projectsRes, clientsRes, budgetsRes] = await Promise.all([
        projectService.getAll({ page: 1, pageSize: 200 }),
        clientService.getAll({ page: 1, pageSize: 200 }),
        budgetService.getAll({ page: 1, pageSize: 200 }),
      ])
      return {
        projects: projectsRes.data || [],
        clients: clientsRes.data || [],
        budgets: budgetsRes.data || [],
      }
    },
    enabled: isReady,
    staleTime: 2 * 60 * 1000, // 2 minutes - reasonable for search
    gcTime: 10 * 60 * 1000,   // 10 minutes
  })

  // Filter results locally (instant, no network)
  const results = useMemo((): SearchResult[] => {
    if (!query.trim() || !searchData) return []

    const searchResults: SearchResult[] = []
    const searchTerm = query.toLowerCase()

    // Filter projects
    const projects = searchData.projects.filter(p =>
      p.proNam?.toLowerCase().includes(searchTerm) ||
      p.cliNam?.toLowerCase().includes(searchTerm)
    ).slice(0, 5)

    projects.forEach((p: Project) => {
      searchResults.push({
        id: `project-${p.proYea}-${p.proCod}`,
        type: 'project',
        title: p.proNam || 'Sin nombre',
        subtitle: p.cliNam || 'Sin cliente',
        url: `/projects/${p.proYea}-${p.proCod}`,
        status: p.proStaNam ? { name: p.proStaNam, color: p.proStaCol } : undefined,
      })
    })

    // Filter clients
    const clients = searchData.clients.filter(c =>
      c.cliNam?.toLowerCase().includes(searchTerm) ||
      c.cliEma?.toLowerCase().includes(searchTerm)
    ).slice(0, 3)

    clients.forEach((c: Client) => {
      searchResults.push({
        id: `client-${c.cliYea}-${c.cliCod}`,
        type: 'client',
        title: c.cliNam || 'Sin nombre',
        subtitle: c.cliEma || c.cliPho || 'Sin contacto',
        url: '/clients',
        status: { name: c.cliSta === 'A' ? 'Activo' : 'Inactivo' },
      })
    })

    // Filter budgets
    const budgets = searchData.budgets.filter(b =>
      b.budNam?.toLowerCase().includes(searchTerm) ||
      b.proNam?.toLowerCase().includes(searchTerm)
    ).slice(0, 3)

    budgets.forEach((b: Budget) => {
      searchResults.push({
        id: `budget-${b.budYea}-${b.budCod}`,
        type: 'budget',
        title: b.budNam || 'Sin nombre',
        subtitle: b.proNam || 'Sin proyecto',
        url: '/budgets',
        status: b.budStaNam ? { name: b.budStaNam, color: b.budStaCol } : undefined,
      })
    })

    return searchResults
  }, [query, searchData])

  // Update open state when results change
  useEffect(() => {
    if (query.trim() && results.length > 0) {
      setIsOpen(true)
      setSelectedIndex(0)
    } else if (!query.trim()) {
      setIsOpen(false)
    }
  }, [query, results.length])

  // Keyboard navigation
  const handleKeyDown = useCallback((e: React.KeyboardEvent) => {
    if (!isOpen) return

    switch (e.key) {
      case 'ArrowDown':
        e.preventDefault()
        setSelectedIndex(i => Math.min(i + 1, results.length - 1))
        break
      case 'ArrowUp':
        e.preventDefault()
        setSelectedIndex(i => Math.max(i - 1, 0))
        break
      case 'Enter':
        e.preventDefault()
        if (results[selectedIndex]) {
          navigateToResult(results[selectedIndex])
        }
        break
      case 'Escape':
        setIsOpen(false)
        inputRef.current?.blur()
        break
    }
  }, [isOpen, results, selectedIndex])

  // Navigate to result
  const navigateToResult = (result: SearchResult) => {
    router.push(result.url)
    setQuery('')
    setIsOpen(false)
    inputRef.current?.blur()
  }

  // Click outside to close
  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (containerRef.current && !containerRef.current.contains(event.target as Node)) {
        setIsOpen(false)
      }
    }
    document.addEventListener('mousedown', handleClickOutside)
    return () => document.removeEventListener('mousedown', handleClickOutside)
  }, [])

  // Icon by type
  const getIcon = (type: string) => {
    switch (type) {
      case 'project': return <FolderKanban className="h-4 w-4" />
      case 'client': return <Users className="h-4 w-4" />
      case 'budget': return <Calculator className="h-4 w-4" />
      default: return <Search className="h-4 w-4" />
    }
  }

  // Type label
  const getTypeLabel = (type: string) => {
    switch (type) {
      case 'project': return 'Proyecto'
      case 'client': return 'Cliente'
      case 'budget': return 'Presupuesto'
      default: return type
    }
  }

  const isLoading = isLoadingData && query.trim().length > 0

  return (
    <div ref={containerRef} className="relative hidden md:block">
      <div className="relative">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
        <Input
          ref={inputRef}
          placeholder="Buscar proyectos, clientes..."
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          onKeyDown={handleKeyDown}
          onFocus={() => results.length > 0 && setIsOpen(true)}
          className="pl-9 pr-8 w-48 lg:w-72 bg-secondary border-border focus:ring-primary h-9"
        />
        {query && (
          <button
            onClick={() => {
              setQuery('')
              setIsOpen(false)
            }}
            className="absolute right-3 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground"
          >
            {isLoading ? (
              <Loader2 className="h-4 w-4 animate-spin" />
            ) : (
              <X className="h-4 w-4" />
            )}
          </button>
        )}
      </div>

      {/* Dropdown de resultados */}
      {isOpen && (
        <div className="absolute top-full left-0 right-0 mt-2 bg-popover border rounded-lg shadow-lg overflow-hidden z-50">
          <div className="max-h-80 overflow-y-auto">
            {results.length === 0 && query.trim() && !isLoading ? (
              <div className="px-4 py-6 text-center text-muted-foreground text-sm">
                No se encontraron resultados para "{query}"
              </div>
            ) : (
              results.map((result, index) => (
                <button
                  key={result.id}
                  onClick={() => navigateToResult(result)}
                  className={cn(
                    "w-full flex items-center gap-3 px-4 py-3 text-left transition-colors",
                    index === selectedIndex ? "bg-muted" : "hover:bg-muted/50"
                  )}
                >
                  <div className="p-2 rounded-lg bg-muted shrink-0">
                    {getIcon(result.type)}
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2">
                      <span className="font-medium truncate">{result.title}</span>
                      <span className="text-xs text-muted-foreground shrink-0">
                        {getTypeLabel(result.type)}
                      </span>
                    </div>
                    {result.subtitle && (
                      <p className="text-sm text-muted-foreground truncate">{result.subtitle}</p>
                    )}
                  </div>
                  {result.status && (
                    <Badge
                      variant="outline"
                      className="text-xs shrink-0 border-0"
                      style={result.status.color ? {
                        backgroundColor: `${result.status.color}15`,
                        color: result.status.color,
                      } : undefined}
                    >
                      {result.status.name}
                    </Badge>
                  )}
                  <ArrowRight className="h-4 w-4 text-muted-foreground shrink-0" />
                </button>
              ))
            )}
          </div>

          {/* Footer con tip */}
          {results.length > 0 && (
            <div className="px-4 py-2 border-t bg-muted/30 text-xs text-muted-foreground flex items-center justify-between">
              <span>Usa ↑↓ para navegar, Enter para seleccionar</span>
              <kbd className="px-1.5 py-0.5 rounded bg-muted text-[10px]">ESC</kbd>
            </div>
          )}
        </div>
      )}
    </div>
  )
}
