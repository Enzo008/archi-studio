'use client'

/**
 * DeleteDialog - Componente reutilizable para confirmación de eliminación
 */
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from '@/components/ui/alert-dialog'

interface DeleteDialogProps {
  /** Si el dialog está abierto */
  open: boolean
  /** Callback cuando cambia el estado */
  onOpenChange: (open: boolean) => void
  /** Callback cuando se confirma eliminación */
  onConfirm: () => void
  /** Título del dialog */
  title?: string
  /** Nombre del item a eliminar */
  itemName?: string
  /** Tipo de item (proyecto, cliente, etc.) */
  itemType?: string
}

export function DeleteDialog({
  open,
  onOpenChange,
  onConfirm,
  title = '¿Confirmar eliminación?',
  itemName,
  itemType = 'elemento',
}: DeleteDialogProps) {
  return (
    <AlertDialog open={open} onOpenChange={onOpenChange}>
      <AlertDialogContent>
        <AlertDialogHeader>
          <AlertDialogTitle>{title}</AlertDialogTitle>
          <AlertDialogDescription>
            Esta acción no se puede deshacer. 
            {itemName ? (
              <>
                {' '}El {itemType}{' '}
                <span className="font-medium text-foreground">{itemName}</span>{' '}
                será eliminado permanentemente.
              </>
            ) : (
              ` Este ${itemType} será eliminado permanentemente.`
            )}
          </AlertDialogDescription>
        </AlertDialogHeader>
        <AlertDialogFooter>
          <AlertDialogCancel>Cancelar</AlertDialogCancel>
          <AlertDialogAction
            onClick={onConfirm}
            className="bg-destructive hover:bg-destructive/90 text-destructive-foreground"
          >
            Eliminar
          </AlertDialogAction>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  )
}
