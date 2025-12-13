/**
 * BudgetsTable - Wrapper que usa DataTable con configuración específica de presupuestos
 */
'use client'

import Link from 'next/link'
import { Badge } from '@/components/ui/badge'
import { Calculator, Calendar, FolderKanban, Eye, Pencil } from 'lucide-react'
import { DataTable, type DataTableColumn } from '@/components/shared'
import { formatDate, formatCurrency } from '@/lib/utils/format'
import type { Budget } from '@/types'

interface BudgetsTableProps {
  budgets: Budget[]
  isLoading?: boolean
  onEdit: (budget: Budget) => void
  onDelete: (budget: Budget) => void
}

export function BudgetsTable({ budgets, isLoading, onEdit, onDelete }: BudgetsTableProps) {
  // Definición de columnas específicas para presupuestos
  const columns: DataTableColumn<Budget>[] = [
    {
      key: 'name',
      header: 'Presupuesto',
      skeleton: { width: 'w-36', hasSubtext: true },
      render: (budget) => (
        <div>
          <Link 
            href={`/budgets/${budget.budYea}-${budget.budCod}`}
            className="font-medium hover:text-primary transition-colors"
          >
            {budget.budNam || 'Sin nombre'}
          </Link>
          <p className="text-xs text-muted-foreground mt-0.5">
            {budget.budYea}-{budget.budCod}
          </p>
        </div>
      ),
    },
    {
      key: 'project',
      header: 'Proyecto',
      hideOn: 'md',
      skeleton: { width: 'w-28' },
      render: (budget) => (
        budget.proNam ? (
          <div className="flex items-center gap-2 text-foreground/80">
            <FolderKanban className="h-4 w-4 text-muted-foreground" />
            {budget.proNam}
          </div>
        ) : (
          <span className="text-muted-foreground">-</span>
        )
      ),
    },
    {
      key: 'status',
      header: 'Estado',
      skeleton: { width: 'w-20', isBadge: true },
      render: (budget) => (
        <Badge
          variant="outline"
          className="border-0"
          style={{
            backgroundColor: `${budget.budStaCol}20` || '#6b728020',
            color: budget.budStaCol || '#6b7280',
          }}
        >
          {budget.budStaNam || 'Sin estado'}
        </Badge>
      ),
    },
    {
      key: 'total',
      header: 'Total',
      skeleton: { width: 'w-20' },
      render: (budget) => (
        <span className="font-semibold">{formatCurrency(budget.budTot)}</span>
      ),
    },
    {
      key: 'date',
      header: 'Fecha',
      hideOn: 'sm',
      skeleton: { width: 'w-24' },
      render: (budget) => (
        <div className="flex items-center gap-1.5 text-muted-foreground text-sm">
          <Calendar className="h-3.5 w-3.5" />
          {formatDate(budget.budDat)}
        </div>
      ),
    },
    {
      key: 'expiry',
      header: 'Vencimiento',
      hideOn: 'lg',
      skeleton: { width: 'w-24' },
      render: (budget) => (
        <span className="text-muted-foreground text-sm">
          {formatDate(budget.budExp)}
        </span>
      ),
    },
  ]

  return (
    <DataTable
      data={budgets}
      columns={columns}
      getRowId={(budget) => `${budget.budYea}-${budget.budCod}`}
      title="Presupuestos"
      isLoading={isLoading}
      emptyIcon={Calculator}
      emptyTitle="Sin presupuestos"
      emptyDescription="Comienza creando tu primer presupuesto"
      searchPlaceholder="Buscar presupuesto..."
      filterFn={(budget, query) =>
        (budget.budNam?.toLowerCase().includes(query.toLowerCase()) ?? false) ||
        (budget.proNam?.toLowerCase().includes(query.toLowerCase()) ?? false)
      }
      actions={[
        {
          label: 'Ver detalles',
          icon: Eye,
          href: (budget) => `/budgets/${budget.budYea}-${budget.budCod}`,
        },
        {
          label: 'Editar',
          icon: Pencil,
          onClick: onEdit,
        },
      ]}
      deleteConfig={{
        title: '¿Eliminar presupuesto?',
        itemType: 'presupuesto',
        getItemName: (budget) => budget.budNam || '',
        onDelete,
      }}
    />
  )
}
