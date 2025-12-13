/**
 * useDashboardData - Centralized hook for all dashboard data
 * Applies DRY principle - single source of truth for dashboard queries
 */
'use client'

import { useQuery } from '@tanstack/react-query'
import { projectService } from '@/lib/api/services/project-service'
import { clientService } from '@/lib/api/services/client-service'
import { budgetService } from '@/lib/api/services/budget-service'
import { documentService } from '@/lib/api/services/document-service'
import { useAuthReady } from '@/hooks/use-auth-ready'
import type { Project, Client, Budget, Document } from '@/types'

// Query keys for dashboard - centralized for easy invalidation
export const dashboardKeys = {
  all: ['dashboard'] as const,
  stats: () => [...dashboardKeys.all, 'stats'] as const,
  projects: () => [...dashboardKeys.all, 'projects'] as const,
  clients: () => [...dashboardKeys.all, 'clients'] as const,
  budgets: () => [...dashboardKeys.all, 'budgets'] as const,
  documents: () => [...dashboardKeys.all, 'documents'] as const,
}

// Common cache configuration for dashboard
const DASHBOARD_CACHE_CONFIG = {
  staleTime: 5 * 60 * 1000,  // 5 minutes - data stays fresh
  gcTime: 30 * 60 * 1000,    // 30 minutes in garbage collection
}

interface DashboardData {
  projects: Project[]
  clients: Client[]
  budgets: Budget[]
  documents: Document[]
  isLoading: boolean
  stats: {
    totalProjects: number
    activeProjects: number
    totalClients: number
    activeClients: number
    totalBudgets: number
    pendingBudgets: number
    totalDocuments: number
    avgProgress: number
    totalBudgetAmount: number
    overdueProjects: number
    completedProjects: number
    inProgressProjects: number
    notStartedProjects: number
  }
  recentProjects: Project[]
  recentClients: Client[]
  upcomingDeadlines: Project[]
}

/**
 * Centralized hook for dashboard data
 * Uses a single query that fetches all data needed by dashboard components
 * This reduces code duplication and ensures consistent caching
 */
export function useDashboardData(): DashboardData {
  const { isReady } = useAuthReady()

  const { data, isLoading } = useQuery({
    queryKey: dashboardKeys.all,
    queryFn: async () => {
      // Fetch all data in parallel
      const [projectsRes, clientsRes, budgetsRes, documentsRes] = await Promise.all([
        projectService.getAll({ page: 1, pageSize: 1000 }),
        clientService.getAll({ page: 1, pageSize: 1000 }),
        budgetService.getAll({ page: 1, pageSize: 1000 }),
        documentService.getAll({ page: 1, pageSize: 1000 }),
      ])

      const projects = projectsRes.data || []
      const clients = clientsRes.data || []
      const budgets = budgetsRes.data || []
      const documents = documentsRes.data || []

      return { projects, clients, budgets, documents }
    },
    enabled: isReady,
    ...DASHBOARD_CACHE_CONFIG,
  })

  const projects = data?.projects || []
  const clients = data?.clients || []
  const budgets = data?.budgets || []
  const documents = data?.documents || []

  // Calculate all stats
  const today = new Date()
  const thirtyDaysFromNow = new Date(today.getTime() + 30 * 24 * 60 * 60 * 1000)

  const activeProjects = projects.filter(p => p.proSta !== '04').length
  const activeClients = clients.filter(c => c.cliSta === 'A').length
  const pendingBudgets = budgets.filter(b => b.budSta === '01').length

  const avgProgress = projects.length > 0
    ? Math.round(projects.reduce((sum, p) => sum + (p.proPro || 0), 0) / projects.length)
    : 0

  const completedProjects = projects.filter(p => (p.proPro || 0) >= 100).length
  const inProgressProjects = projects.filter(p => (p.proPro || 0) > 0 && (p.proPro || 0) < 100).length
  const notStartedProjects = projects.filter(p => (p.proPro || 0) === 0).length

  const overdueProjects = projects.filter(p => {
    if (!p.proDatEnd || (p.proPro || 0) >= 100) return false
    return new Date(p.proDatEnd) < today
  }).length

  const totalBudgetAmount = budgets.reduce((sum, b) => sum + (b.budTot || 0), 0)

  // Recent items (last 5)
  const recentProjects = projects.slice(0, 5)
  const recentClients = clients.slice(0, 5)

  // Upcoming deadlines (next 30 days)
  const upcomingDeadlines = projects
    .filter((p) => {
      if (!p.proDatEnd || (p.proPro || 0) >= 100) return false
      const endDate = new Date(p.proDatEnd)
      return endDate >= today && endDate <= thirtyDaysFromNow
    })
    .sort((a, b) => new Date(a.proDatEnd!).getTime() - new Date(b.proDatEnd!).getTime())
    .slice(0, 5)

  return {
    projects,
    clients,
    budgets,
    documents,
    isLoading,
    stats: {
      totalProjects: projects.length,
      activeProjects,
      totalClients: clients.length,
      activeClients,
      totalBudgets: budgets.length,
      pendingBudgets,
      totalDocuments: documents.length,
      avgProgress,
      totalBudgetAmount,
      overdueProjects,
      completedProjects,
      inProgressProjects,
      notStartedProjects,
    },
    recentProjects,
    recentClients,
    upcomingDeadlines,
  }
}
