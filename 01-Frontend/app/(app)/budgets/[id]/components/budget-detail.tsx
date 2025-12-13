/**
 * BudgetDetail - Componente de detalle de presupuesto
 */
'use client'

import { useState } from 'react'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import {
  DetailHeader,
  InfoCard,
  DetailSkeleton,
  ErrorState
} from '@/components/shared'
import {
  Calculator, Calendar, Clock, FolderKanban, FileText,
  Plus, Trash2, GripVertical, ImageIcon, Loader2
} from 'lucide-react'
import { useBudget, useSaveBudgetItem, useDeleteBudgetItem, useUploadBudgetItemImage } from '@/hooks/use-budgets'
import { budgetService } from '@/lib/api/services'
import { formatDateLong, formatCurrency } from '@/lib/utils/format'
import { cn } from '@/lib/utils'
import type { BudgetItem } from '@/types'

interface BudgetDetailProps {
  budgetId: string
}

export function BudgetDetail({ budgetId }: BudgetDetailProps) {
  const [budYea, budCod] = budgetId.split('-')
  const { data: budget, isLoading, error } = useBudget(budYea, budCod)
  const saveMutation = useSaveBudgetItem()
  const deleteMutation = useDeleteBudgetItem()

  const [editingItem, setEditingItem] = useState<number | null>(null)
  const [newItem, setNewItem] = useState<Partial<BudgetItem> | null>(null)

  if (isLoading) {
    return <DetailSkeleton infoCards={4} contentCards={1} />
  }

  if (error || !budget) {
    return (
      <ErrorState
        icon={Calculator}
        title="Presupuesto no encontrado"
        description="No se pudo cargar la información del presupuesto"
        backHref="/budgets"
        backLabel="Volver a presupuestos"
      />
    )
  }

  const handleAddItem = () => {
    setNewItem({
      budIteNam: '',
      budIteQty: 1,
      budItePri: 0,
    })
  }

  const handleSaveItem = (item: Partial<BudgetItem>) => {
    saveMutation.mutate(
      { budYea, budCod, item },
      {
        onSuccess: () => {
          setNewItem(null)
          setEditingItem(null)
        },
      }
    )
  }

  const handleDeleteItem = (budIteNum: number) => {
    deleteMutation.mutate({ budYea, budCod, budIteNum })
  }

  return (
    <div className="space-y-6">
      <DetailHeader
        title={budget.budNam || 'Sin nombre'}
        subtitle={budget.proNam}
        backHref="/budgets"
        status={
          budget.budStaNam
            ? { label: budget.budStaNam, color: budget.budStaCol }
            : undefined
        }
      />

      {/* Info Cards */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <InfoCard
          icon={Calculator}
          label="Total"
          value={formatCurrency(budget.budTot)}
        />
        <InfoCard
          icon={Calendar}
          label="Fecha"
          value={formatDateLong(budget.budDat)}
        />
        <InfoCard
          icon={Clock}
          label="Vencimiento"
          value={formatDateLong(budget.budExp)}
        />
        <InfoCard
          icon={FolderKanban}
          label="Proyecto"
          value={budget.proNam || '-'}
        />
      </div>

      {/* Descripción */}
      {budget.budDes && (
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2 text-base">
              <FileText className="h-4 w-4" />
              Descripción
            </CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-muted-foreground">{budget.budDes}</p>
          </CardContent>
        </Card>
      )}

      {/* Items del presupuesto */}
      <Card>
        <CardHeader className="flex flex-row items-center justify-between">
          <CardTitle>Items del Presupuesto</CardTitle>
          <Button size="sm" onClick={handleAddItem} disabled={!!newItem}>
            <Plus className="mr-2 h-4 w-4" />
            Agregar Item
          </Button>
        </CardHeader>
        <CardContent>
          {(!budget.items || budget.items.length === 0) && !newItem ? (
            <div className="text-center py-8 text-muted-foreground">
              <Calculator className="h-8 w-8 mx-auto mb-2 opacity-50" />
              <p>No hay items en este presupuesto</p>
              <p className="text-sm">Agrega items para calcular el total</p>
            </div>
          ) : (
            <div className="space-y-2">
              {/* Header */}
              <div className="grid grid-cols-13 gap-2 text-xs font-medium text-muted-foreground pb-2 border-b">
                <div className="col-span-1">#</div>
                <div className="col-span-1">Img</div>
                <div className="col-span-5">Descripción</div>
                <div className="col-span-2 text-right">Cantidad</div>
                <div className="col-span-2 text-right">Precio Unit.</div>
                <div className="col-span-2 text-right">Total</div>
              </div>

              {/* Items existentes */}
              {budget.items?.map((item) => (
                <BudgetItemRow
                  key={item.budIteNum}
                  item={item}
                  isEditing={editingItem === item.budIteNum}
                  onEdit={() => setEditingItem(item.budIteNum)}
                  onSave={handleSaveItem}
                  onCancel={() => setEditingItem(null)}
                  onDelete={() => handleDeleteItem(item.budIteNum)}
                  isSaving={saveMutation.isPending}
                  isDeleting={deleteMutation.isPending}
                />
              ))}

              {/* Nuevo item */}
              {newItem && (
                <BudgetItemRow
                  item={newItem as BudgetItem}
                  isEditing={true}
                  isNew
                  onSave={handleSaveItem}
                  onCancel={() => setNewItem(null)}
                  isSaving={saveMutation.isPending}
                />
              )}

              {/* Total */}
              {(budget.items?.length || 0) > 0 && (
                <div className="grid grid-cols-13 gap-2 pt-4 border-t font-semibold">
                  <div className="col-span-11 text-right">Total:</div>
                  <div className="col-span-2 text-right text-primary">
                    {formatCurrency(budget.budTot)}
                  </div>
                </div>
              )}
            </div>
          )}
        </CardContent>
      </Card>

      {/* Notas */}
      {budget.budNot && (
        <Card>
          <CardHeader>
            <CardTitle className="text-base">Notas</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-muted-foreground whitespace-pre-wrap">{budget.budNot}</p>
          </CardContent>
        </Card>
      )}
    </div>
  )
}

// Componente para cada fila de item
interface BudgetItemRowProps {
  item: BudgetItem
  isEditing: boolean
  isNew?: boolean
  onEdit?: () => void
  onSave: (item: Partial<BudgetItem>) => void
  onCancel: () => void
  onDelete?: () => void
  isSaving?: boolean
  isDeleting?: boolean
}

function BudgetItemRow({
  item,
  isEditing,
  isNew,
  onEdit,
  onSave,
  onCancel,
  onDelete,
  isSaving,
  isDeleting,
}: BudgetItemRowProps) {
  const [formData, setFormData] = useState({
    budIteNam: item.budIteNam || '',
    budIteQty: item.budIteQty || 1,
    budItePri: item.budItePri || 0,
  })

  const uploadMutation = useUploadBudgetItemImage()
  const [localImagePat, setLocalImagePat] = useState(item.budIteImgPat || '')
  const [uploadingFile, setUploadingFile] = useState<File | null>(null)

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (file && !isNew && item.budIteNum) {
      setUploadingFile(file)
      uploadMutation.mutate(
        { budYea: item.budYea, budCod: item.budCod, budIteNum: item.budIteNum, file },
        {
          onSuccess: (response) => {
            if (response.data?.budIteImgPat) {
              setLocalImagePat(response.data.budIteImgPat)
            }
            setUploadingFile(null)
          },
          onError: () => setUploadingFile(null)
        }
      )
    }
  }

  const getImageUrl = (path?: string) => {
    if (!path) return ''
    return budgetService.getItemImageUrl(path)
  }

  const total = formData.budIteQty * formData.budItePri
  const imagePath = localImagePat || item.budIteImgPat

  if (isEditing) {
    return (
      <div className="grid grid-cols-13 gap-2 items-center py-2 bg-muted/50 rounded px-2">
        <div className="col-span-1 text-muted-foreground text-center">
          {isNew ? 'N' : item.budIteNum}
        </div>
        <div className="col-span-1 flex justify-center">
          {isNew ? (
            <div className="h-10 w-10 rounded bg-muted flex items-center justify-center">
              <ImageIcon className="h-4 w-4 text-muted-foreground" />
            </div>
          ) : uploadMutation.isPending ? (
            <div className="h-10 w-10 rounded bg-muted flex items-center justify-center">
              <Loader2 className="h-4 w-4 animate-spin" />
            </div>
          ) : (
            <label className="relative h-10 w-10 rounded border-2 border-dashed border-input hover:border-primary/50 flex items-center justify-center cursor-pointer transition-colors group overflow-hidden">
              <input type="file" accept="image/*" className="hidden" onChange={handleFileChange} />
              {imagePath ? (
                <>
                  <img
                    src={getImageUrl(imagePath)}
                    alt=""
                    className="absolute inset-0 h-full w-full object-cover rounded"
                    onError={(e) => (e.currentTarget.style.display = 'none')}
                  />
                  <div className="absolute inset-0 bg-black/50 opacity-0 group-hover:opacity-100 flex items-center justify-center transition-opacity rounded">
                    <ImageIcon className="h-4 w-4 text-white" />
                  </div>
                </>
              ) : (
                <ImageIcon className="h-4 w-4 text-muted-foreground" />
              )}
            </label>
          )}
        </div>
        <div className="col-span-5">
          <Input
            value={formData.budIteNam}
            onChange={(e) => setFormData({ ...formData, budIteNam: e.target.value })}
            placeholder="Descripción del item"
            className="h-8"
          />
        </div>
        <div className="col-span-2">
          <Input
            type="number"
            value={formData.budIteQty}
            onChange={(e) => setFormData({ ...formData, budIteQty: Number(e.target.value) })}
            min={1}
            className="h-8 text-right"
          />
        </div>
        <div className="col-span-2">
          <Input
            type="number"
            value={formData.budItePri}
            onChange={(e) => setFormData({ ...formData, budItePri: Number(e.target.value) })}
            min={0}
            step={0.01}
            className="h-8 text-right"
          />
        </div>
        <div className="col-span-2 flex items-center justify-end gap-1">
          <Button
            size="sm"
            variant="ghost"
            className="h-7 px-2"
            onClick={onCancel}
            disabled={isSaving}
          >
            Cancelar
          </Button>
          <Button
            size="sm"
            className="h-7 px-2"
            onClick={() => onSave({
              ...(!isNew && { budIteNum: item.budIteNum }),
              ...formData
            })}
            disabled={isSaving || !formData.budIteNam}
          >
            {isSaving ? '...' : 'Guardar'}
          </Button>
        </div>
      </div>
    )
  }

  return (
    <div
      className="grid grid-cols-13 gap-2 items-center py-2 hover:bg-muted/30 rounded group cursor-pointer"
      onClick={onEdit}
    >
      <div className="col-span-1 text-muted-foreground flex items-center gap-1">
        <GripVertical className="h-3 w-3 opacity-0 group-hover:opacity-50" />
        {item.budIteNum}
      </div>
      <div className="col-span-1 flex justify-center">
        {imagePath ? (
          <img
            src={getImageUrl(imagePath)}
            alt=""
            className="h-10 w-10 object-cover rounded border"
            onError={(e) => (e.currentTarget.style.display = 'none')}
          />
        ) : (
          <div className="h-10 w-10 rounded bg-muted/50 flex items-center justify-center">
            <ImageIcon className="h-4 w-4 text-muted-foreground/30" />
          </div>
        )}
      </div>
      <div className="col-span-5">{item.budIteNam}</div>
      <div className="col-span-2 text-right">{item.budIteQty}</div>
      <div className="col-span-2 text-right">{formatCurrency(item.budItePri)}</div>
      <div className="col-span-2 text-right flex items-center justify-end gap-2">
        <span>{formatCurrency(item.budIteTot)}</span>
        <Button
          size="icon"
          variant="ghost"
          className="h-6 w-6 opacity-0 group-hover:opacity-100 text-destructive hover:text-destructive"
          onClick={(e) => {
            e.stopPropagation()
            onDelete?.()
          }}
          disabled={isDeleting}
        >
          <Trash2 className="h-3 w-3" />
        </Button>
      </div>
    </div>
  )
}
