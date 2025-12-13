'use client'

/**
 * DataTable - Componente de tabla genérico y reutilizable
 * Implementa principios SOLID: configuración vía props, no lógica de negocio
 */
import { useState, ReactNode } from 'react'
import Link from 'next/link'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import { MoreHorizontal, Pencil, Trash2, Eye, Search } from 'lucide-react'
import { TableSkeleton, EmptyState, DeleteDialog, type TableSkeletonColumn } from '@/components/shared'
import type { LucideIcon } from 'lucide-react'

// Tipos genéricos para la tabla
export interface DataTableColumn<T> {
  /** Key única para la columna */
  key: string
  /** Header de la columna */
  header: string
  /** Función para renderizar la celda */
  render: (item: T) => ReactNode
  /** Clase responsive para ocultar */
  hideOn?: 'sm' | 'md' | 'lg' | 'xl'
  /** Configuración del skeleton */
  skeleton?: {
    width?: string
    hasSubtext?: boolean
    isBadge?: boolean
  }
}

export interface DataTableAction<T> {
  /** Label de la acción */
  label: string
  /** Icono de la acción */
  icon: LucideIcon
  /** Callback al hacer click */
  onClick?: (item: T) => void
  /** Link para navegación */
  href?: (item: T) => string
  /** Variante destructiva (rojo) */
  destructive?: boolean
}

export interface DataTableProps<T> {
  /** Datos a mostrar */
  data: T[]
  /** Columnas de la tabla */
  columns: DataTableColumn<T>[]
  /** Función para obtener el ID único de cada item */
  getRowId: (item: T) => string
  /** Título de la tabla */
  title?: string
  /** Icono para estado vacío */
  emptyIcon: LucideIcon
  /** Título para estado vacío */
  emptyTitle: string
  /** Descripción para estado vacío */
  emptyDescription: string
  /** Estado de carga */
  isLoading?: boolean
  /** Placeholder de búsqueda */
  searchPlaceholder?: string
  /** Función de filtrado */
  filterFn?: (item: T, query: string) => boolean
  /** Acciones del dropdown */
  actions?: DataTableAction<T>[]
  /** Configuración de eliminación */
  deleteConfig?: {
    title: string
    itemType: string
    getItemName: (item: T) => string
    onDelete: (item: T) => void
  }
  /** Mostrar buscador */
  showSearch?: boolean
  /** Mostrar en Card */
  withCard?: boolean
}

export function DataTable<T>({
  data,
  columns,
  getRowId,
  title,
  emptyIcon,
  emptyTitle,
  emptyDescription,
  isLoading,
  searchPlaceholder = 'Buscar...',
  filterFn,
  actions = [],
  deleteConfig,
  showSearch = true,
  withCard = true,
}: DataTableProps<T>) {
  const [searchQuery, setSearchQuery] = useState('')
  const [deleteItem, setDeleteItem] = useState<T | null>(null)

  // Filtrado de datos
  const filteredData = filterFn && searchQuery
    ? data.filter((item) => filterFn(item, searchQuery))
    : data

  // Generar columnas del skeleton
  const skeletonColumns: TableSkeletonColumn[] = columns.map((col) => ({
    header: col.header,
    width: col.skeleton?.width || 'w-24',
    hasSubtext: col.skeleton?.hasSubtext,
    isBadge: col.skeleton?.isBadge,
    hideOn: col.hideOn,
  }))

  // Añadir columna de acciones al skeleton si hay acciones
  if (actions.length > 0 || deleteConfig) {
    skeletonColumns.push({ header: 'Acciones', width: 'w-8' })
  }

  // Helper para clase responsive
  const getHideClass = (hideOn?: string) => {
    switch (hideOn) {
      case 'sm': return 'hidden sm:table-cell'
      case 'md': return 'hidden md:table-cell'
      case 'lg': return 'hidden lg:table-cell'
      case 'xl': return 'hidden xl:table-cell'
      default: return ''
    }
  }

  // Loading state
  if (isLoading) {
    return <TableSkeleton columns={skeletonColumns} title={title} showSearch={showSearch} withCard={withCard} />
  }

  // Empty state
  if (!data || data.length === 0) {
    return (
      <EmptyState
        icon={emptyIcon}
        title={emptyTitle}
        description={emptyDescription}
      />
    )
  }

  const hasActions = actions.length > 0 || deleteConfig

  // Contenido de la tabla
  const tableContent = (
    <>
      {showSearch && (
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-4">
          {title && (
            <h3 className="text-xl font-semibold">
              {title} ({data.length})
            </h3>
          )}
          {filterFn && (
            <div className="relative">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
              <Input
                placeholder={searchPlaceholder}
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="pl-9 w-48 lg:w-64"
              />
            </div>
          )}
        </div>
      )}

      <div className="rounded-lg border overflow-hidden">
        <Table>
          <TableHeader>
            <TableRow className="hover:bg-transparent bg-muted/50">
              {columns.map((col) => (
                <TableHead
                  key={col.key}
                  className={`text-xs uppercase text-muted-foreground ${getHideClass(col.hideOn)}`}
                >
                  {col.header}
                </TableHead>
              ))}
              {hasActions && (
                <TableHead className="text-xs uppercase text-muted-foreground text-right">
                  Acciones
                </TableHead>
              )}
            </TableRow>
          </TableHeader>
          <TableBody>
            {filteredData.map((item) => (
              <TableRow
                key={getRowId(item)}
                className="hover:bg-muted/50 transition-colors"
              >
                {columns.map((col) => (
                  <TableCell key={col.key} className={getHideClass(col.hideOn)}>
                    {col.render(item)}
                  </TableCell>
                ))}
                {hasActions && (
                  <TableCell className="text-right">
                    <DropdownMenu>
                      <DropdownMenuTrigger asChild>
                        <Button variant="ghost" size="icon" className="h-8 w-8">
                          <MoreHorizontal className="h-4 w-4" />
                        </Button>
                      </DropdownMenuTrigger>
                      <DropdownMenuContent align="end">
                        {actions.map((action) => (
                          action.href ? (
                            <DropdownMenuItem key={action.label} asChild className="cursor-pointer">
                              <Link href={action.href(item)}>
                                <action.icon className="mr-2 h-4 w-4" />
                                {action.label}
                              </Link>
                            </DropdownMenuItem>
                          ) : (
                            <DropdownMenuItem
                              key={action.label}
                              onClick={() => action.onClick?.(item)}
                              className={`cursor-pointer ${action.destructive ? 'text-red-500 focus:text-red-500' : ''}`}
                            >
                              <action.icon className="mr-2 h-4 w-4" />
                              {action.label}
                            </DropdownMenuItem>
                          )
                        ))}
                        {deleteConfig && (
                          <DropdownMenuItem
                            onClick={() => setDeleteItem(item)}
                            className="cursor-pointer text-red-500 focus:text-red-500"
                          >
                            <Trash2 className="mr-2 h-4 w-4" />
                            Eliminar
                          </DropdownMenuItem>
                        )}
                      </DropdownMenuContent>
                    </DropdownMenu>
                  </TableCell>
                )}
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>

      {filteredData.length === 0 && searchQuery && (
        <div className="text-center py-8 text-muted-foreground">
          No se encontraron resultados para &quot;{searchQuery}&quot;
        </div>
      )}

      {deleteConfig && (
        <DeleteDialog
          open={!!deleteItem}
          onOpenChange={() => setDeleteItem(null)}
          onConfirm={() => {
            if (deleteItem) {
              deleteConfig.onDelete(deleteItem)
              setDeleteItem(null)
            }
          }}
          title={deleteConfig.title}
          itemName={deleteItem ? deleteConfig.getItemName(deleteItem) : undefined}
          itemType={deleteConfig.itemType}
        />
      )}
    </>
  )

  // Renderizar con o sin Card
  if (withCard) {
    return (
      <Card>
        {title && showSearch ? (
          <CardHeader className="pb-4">
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
              <CardTitle className="text-xl font-semibold">
                {title} ({data.length})
              </CardTitle>
              {filterFn && (
                <div className="relative">
                  <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
                  <Input
                    placeholder={searchPlaceholder}
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                    className="pl-9 w-48 lg:w-64"
                  />
                </div>
              )}
            </div>
          </CardHeader>
        ) : null}
        <CardContent className={title && showSearch ? '' : 'pt-6'}>
          <div className="rounded-lg border overflow-hidden">
            <Table>
              <TableHeader>
                <TableRow className="hover:bg-transparent bg-muted/50">
                  {columns.map((col) => (
                    <TableHead
                      key={col.key}
                      className={`text-xs uppercase text-muted-foreground ${getHideClass(col.hideOn)}`}
                    >
                      {col.header}
                    </TableHead>
                  ))}
                  {hasActions && (
                    <TableHead className="text-xs uppercase text-muted-foreground text-right">
                      Acciones
                    </TableHead>
                  )}
                </TableRow>
              </TableHeader>
              <TableBody>
                {filteredData.map((item) => (
                  <TableRow
                    key={getRowId(item)}
                    className="hover:bg-muted/50 transition-colors"
                  >
                    {columns.map((col) => (
                      <TableCell key={col.key} className={getHideClass(col.hideOn)}>
                        {col.render(item)}
                      </TableCell>
                    ))}
                    {hasActions && (
                      <TableCell className="text-right">
                        <DropdownMenu>
                          <DropdownMenuTrigger asChild>
                            <Button variant="ghost" size="icon" className="h-8 w-8">
                              <MoreHorizontal className="h-4 w-4" />
                            </Button>
                          </DropdownMenuTrigger>
                          <DropdownMenuContent align="end">
                            {actions.map((action) => (
                              action.href ? (
                                <DropdownMenuItem key={action.label} asChild className="cursor-pointer">
                                  <Link href={action.href(item)}>
                                    <action.icon className="mr-2 h-4 w-4" />
                                    {action.label}
                                  </Link>
                                </DropdownMenuItem>
                              ) : (
                                <DropdownMenuItem
                                  key={action.label}
                                  onClick={() => action.onClick?.(item)}
                                  className={`cursor-pointer ${action.destructive ? 'text-red-500 focus:text-red-500' : ''}`}
                                >
                                  <action.icon className="mr-2 h-4 w-4" />
                                  {action.label}
                                </DropdownMenuItem>
                              )
                            ))}
                            {deleteConfig && (
                              <DropdownMenuItem
                                onClick={() => setDeleteItem(item)}
                                className="cursor-pointer text-red-500 focus:text-red-500"
                              >
                                <Trash2 className="mr-2 h-4 w-4" />
                                Eliminar
                              </DropdownMenuItem>
                            )}
                          </DropdownMenuContent>
                        </DropdownMenu>
                      </TableCell>
                    )}
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </div>

          {filteredData.length === 0 && searchQuery && (
            <div className="text-center py-8 text-muted-foreground">
              No se encontraron resultados para &quot;{searchQuery}&quot;
            </div>
          )}

          {deleteConfig && (
            <DeleteDialog
              open={!!deleteItem}
              onOpenChange={() => setDeleteItem(null)}
              onConfirm={() => {
                if (deleteItem) {
                  deleteConfig.onDelete(deleteItem)
                  setDeleteItem(null)
                }
              }}
              title={deleteConfig.title}
              itemName={deleteItem ? deleteConfig.getItemName(deleteItem) : undefined}
              itemType={deleteConfig.itemType}
            />
          )}
        </CardContent>
      </Card>
    )
  }

  return <>{tableContent}</>
}
