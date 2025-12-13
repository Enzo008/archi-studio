/**
 * RoleModal - Modal para crear/editar roles
 * Componente presentacional - recibe callbacks del padre
 */
'use client';

import { useEffect } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
} from '@/components/ui/dialog';
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from '@/components/ui/form';
import { Input } from '@/components/ui/input';
import { Textarea } from '@/components/ui/textarea';
import { Button } from '@/components/ui/button';
import { Loader2 } from 'lucide-react';
import type { Role } from '@/types';

const roleSchema = z.object({
  rolCod: z.string().min(1, 'El código es requerido').max(2, 'Máximo 2 caracteres'),
  rolNam: z.string().min(1, 'El nombre es requerido').max(50, 'Máximo 50 caracteres'),
  rolDes: z.string().max(200, 'Máximo 200 caracteres').optional(),
});

type RoleFormData = z.infer<typeof roleSchema>;

interface RoleModalProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  role: Role | null;
  onSubmit: (data: Partial<Role>) => void;
  isLoading?: boolean;
}

export function RoleModal({
  open,
  onOpenChange,
  role,
  onSubmit,
  isLoading = false,
}: RoleModalProps) {
  const isEditing = !!role;

  const form = useForm<RoleFormData>({
    resolver: zodResolver(roleSchema),
    defaultValues: {
      rolCod: '',
      rolNam: '',
      rolDes: '',
    },
  });

  // Reset form when role changes
  useEffect(() => {
    if (role) {
      form.reset({
        rolCod: role.rolCod || '',
        rolNam: role.rolNam || '',
        rolDes: role.rolDes || '',
      });
    } else {
      form.reset({
        rolCod: '',
        rolNam: '',
        rolDes: '',
      });
    }
  }, [role, form]);

  const handleSubmit = (data: RoleFormData) => {
    onSubmit({
      ...data,
    });
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle>{isEditing ? 'Editar Rol' : 'Nuevo Rol'}</DialogTitle>
          <DialogDescription>
            {isEditing
              ? 'Modifica los datos del rol'
              : 'Ingresa los datos del nuevo rol'}
          </DialogDescription>
        </DialogHeader>

        <Form {...form}>
          <form onSubmit={form.handleSubmit(handleSubmit)} className="space-y-4">
            <FormField
              control={form.control}
              name="rolCod"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Código</FormLabel>
                  <FormControl>
                    <Input
                      {...field}
                      placeholder="01"
                      maxLength={2}
                      disabled={isEditing}
                      className="uppercase"
                    />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />

            <FormField
              control={form.control}
              name="rolNam"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Nombre</FormLabel>
                  <FormControl>
                    <Input {...field} placeholder="Administrador" />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />

            <FormField
              control={form.control}
              name="rolDes"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Descripción</FormLabel>
                  <FormControl>
                    <Textarea
                      {...field}
                      placeholder="Descripción del rol y sus permisos..."
                      rows={3}
                    />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />

            <div className="flex justify-end gap-3 pt-4">
              <Button
                type="button"
                variant="outline"
                onClick={() => onOpenChange(false)}
                disabled={isLoading}
              >
                Cancelar
              </Button>
              <Button type="submit" disabled={isLoading}>
                {isLoading && <Loader2 className="h-4 w-4 mr-2 animate-spin" />}
                {isEditing ? 'Guardar' : 'Crear'}
              </Button>
            </div>
          </form>
        </Form>
      </DialogContent>
    </Dialog>
  );
}
