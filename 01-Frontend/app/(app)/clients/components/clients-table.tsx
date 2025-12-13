/**
 * ClientsTable - Wrapper que usa DataTable con configuración específica de clientes
 */
'use client'

import { Badge } from '@/components/ui/badge'
import { Building2, User, Pencil } from 'lucide-react'
import { DataTable, type DataTableColumn } from '@/components/shared'
import type { Client } from '@/types'
import { CLIENT_TYPES } from '@/types'

interface ClientsTableProps {
  clients: Client[]
  isLoading?: boolean
  onEdit: (client: Client) => void
  onDelete: (client: Client) => void
}

export function ClientsTable({ clients, isLoading, onEdit, onDelete }: ClientsTableProps) {
  // Definición de columnas específicas para clientes
  const columns: DataTableColumn<Client>[] = [
    {
      key: 'name',
      header: 'Nombre',
      skeleton: { width: 'w-32' },
      render: (client) => (
        <div className="flex items-center gap-2 font-medium">
          {client.cliTyp === '02' ? (
            <Building2 className="h-4 w-4 text-muted-foreground" />
          ) : (
            <User className="h-4 w-4 text-muted-foreground" />
          )}
          {client.cliNam || '-'}
        </div>
      ),
    },
    {
      key: 'type',
      header: 'Tipo',
      skeleton: { width: 'w-20' },
      render: (client) => (
        <span className="text-foreground/80">
          {client.cliTyp ? CLIENT_TYPES[client.cliTyp] : '-'}
        </span>
      ),
    },
    {
      key: 'email',
      header: 'Email',
      skeleton: { width: 'w-40' },
      render: (client) => (
        <span className="text-foreground/80">{client.cliEma || '-'}</span>
      ),
    },
    {
      key: 'phone',
      header: 'Teléfono',
      skeleton: { width: 'w-24' },
      render: (client) => (
        <span className="text-foreground/80">{client.cliPho || '-'}</span>
      ),
    },
    {
      key: 'status',
      header: 'Estado',
      skeleton: { width: 'w-16', isBadge: true },
      render: (client) => (
        <Badge
          variant="outline"
          className={
            client.cliSta === 'A'
              ? 'bg-emerald-500/10 text-emerald-500 border-emerald-500/20'
              : 'bg-red-500/10 text-red-500 border-red-500/20'
          }
        >
          {client.cliSta === 'A' ? 'Activo' : 'Inactivo'}
        </Badge>
      ),
    },
  ]

  return (
    <DataTable
      data={clients}
      columns={columns}
      getRowId={(client) => `${client.cliYea}-${client.cliCod}`}
      isLoading={isLoading}
      emptyIcon={Building2}
      emptyTitle="Sin clientes"
      emptyDescription="Comienza agregando tu primer cliente"
      searchPlaceholder="Buscar cliente..."
      filterFn={(client, query) =>
        (client.cliNam?.toLowerCase().includes(query.toLowerCase()) ?? false) ||
        (client.cliEma?.toLowerCase().includes(query.toLowerCase()) ?? false)
      }
      withCard={false}
      actions={[
        {
          label: 'Editar',
          icon: Pencil,
          onClick: onEdit,
        },
      ]}
      deleteConfig={{
        title: '¿Eliminar cliente?',
        itemType: 'cliente',
        getItemName: (client) => client.cliNam || '',
        onDelete,
      }}
    />
  )
}
