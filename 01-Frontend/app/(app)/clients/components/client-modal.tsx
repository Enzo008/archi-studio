/**
 * ClientModal - Modal para crear/editar clientes
 */
'use client';

import { useEffect } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
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
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { Loader2 } from 'lucide-react';
import type { Client } from '@/types';
import { CLIENT_TYPES } from '@/types';

// Schema de validación
const clientSchema = z.object({
  cliNam: z.string().min(1, 'El nombre es requerido').max(100, 'Máximo 100 caracteres'),
  cliTyp: z.enum(['01', '02'], { required_error: 'Seleccione un tipo' }),
  cliEma: z.string().email('Email inválido').optional().or(z.literal('')),
  cliPho: z.string().max(20, 'Máximo 20 caracteres').optional().or(z.literal('')),
  cliAdd: z.string().max(200, 'Máximo 200 caracteres').optional().or(z.literal('')),
  cliSta: z.enum(['A', 'I']).default('A'),
  cliDes: z.string().max(500, 'Máximo 500 caracteres').optional().or(z.literal('')),
});

type ClientFormData = z.infer<typeof clientSchema>;

interface ClientModalProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  client?: Client | null;
  onSubmit: (data: Partial<Client>) => void;
  isLoading?: boolean;
}

export function ClientModal({
  open,
  onOpenChange,
  client,
  onSubmit,
  isLoading,
}: ClientModalProps) {
  const isEditing = !!client;

  const form = useForm<ClientFormData>({
    resolver: zodResolver(clientSchema),
    defaultValues: {
      cliNam: '',
      cliTyp: '01',
      cliEma: '',
      cliPho: '',
      cliAdd: '',
      cliSta: 'A',
      cliDes: '',
    },
  });

  // Reset form when modal opens/closes or client changes
  useEffect(() => {
    if (open && client) {
      form.reset({
        cliNam: client.cliNam || '',
        cliTyp: client.cliTyp || '01',
        cliEma: client.cliEma || '',
        cliPho: client.cliPho || '',
        cliAdd: client.cliAdd || '',
        cliSta: client.cliSta || 'A',
        cliDes: client.cliDes || '',
      });
    } else if (open) {
      form.reset({
        cliNam: '',
        cliTyp: '01',
        cliEma: '',
        cliPho: '',
        cliAdd: '',
        cliSta: 'A',
        cliDes: '',
      });
    }
  }, [open, client, form]);

  const handleSubmit = (data: ClientFormData) => {
    // Limpiar strings vacíos para campos opcionales (convertir a undefined)
    const cleanedData = {
      cliNam: data.cliNam,
      cliTyp: data.cliTyp,
      cliSta: data.cliSta,
      cliEma: data.cliEma || undefined,
      cliPho: data.cliPho || undefined,
      cliAdd: data.cliAdd || undefined,
      cliDes: data.cliDes || undefined,
    };

    onSubmit({
      ...(client && { cliYea: client.cliYea, cliCod: client.cliCod }),
      ...cleanedData,
    });
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="bg-card border-border sm:max-w-[500px]">
        <DialogHeader>
          <DialogTitle className="text-foreground">
            {isEditing ? 'Editar Cliente' : 'Nuevo Cliente'}
          </DialogTitle>
          <DialogDescription className="text-muted-foreground">
            {isEditing
              ? 'Modifica la información del cliente'
              : 'Completa la información para agregar un nuevo cliente'}
          </DialogDescription>
        </DialogHeader>

        <Form {...form}>
          <form onSubmit={form.handleSubmit(handleSubmit)} className="space-y-4">
            <FormField
              control={form.control}
              name="cliNam"
              render={({ field }) => (
                <FormItem>
                  <FormLabel className="text-foreground">Nombre *</FormLabel>
                  <FormControl>
                    <Input
                      {...field}
                      placeholder="Nombre del cliente o empresa"
                      className="bg-background border-input text-foreground placeholder:text-muted-foreground focus:border-primary"
                    />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />

            <div className="grid grid-cols-2 gap-4">
              <FormField
                control={form.control}
                name="cliTyp"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel className="text-foreground">Tipo *</FormLabel>
                    <Select onValueChange={field.onChange} value={field.value}>
                      <FormControl>
                        <SelectTrigger className="bg-background border-input text-foreground">
                          <SelectValue placeholder="Seleccionar tipo" />
                        </SelectTrigger>
                      </FormControl>
                      <SelectContent className="bg-card border-border">
                        {Object.entries(CLIENT_TYPES).map(([key, label]) => (
                          <SelectItem key={key} value={key} className="text-foreground">
                            {label}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                    <FormMessage />
                  </FormItem>
                )}
              />

              <FormField
                control={form.control}
                name="cliSta"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel className="text-foreground">Estado</FormLabel>
                    <Select onValueChange={field.onChange} value={field.value}>
                      <FormControl>
                        <SelectTrigger className="bg-background border-input text-foreground">
                          <SelectValue placeholder="Estado" />
                        </SelectTrigger>
                      </FormControl>
                      <SelectContent className="bg-card border-border">
                        <SelectItem value="A" className="text-foreground">Activo</SelectItem>
                        <SelectItem value="I" className="text-foreground">Inactivo</SelectItem>
                      </SelectContent>
                    </Select>
                    <FormMessage />
                  </FormItem>
                )}
              />
            </div>

            <FormField
              control={form.control}
              name="cliEma"
              render={({ field }) => (
                <FormItem>
                  <FormLabel className="text-foreground">Email</FormLabel>
                  <FormControl>
                    <Input
                      {...field}
                      type="email"
                      placeholder="correo@ejemplo.com"
                      className="bg-background border-input text-foreground placeholder:text-muted-foreground focus:border-primary"
                    />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />

            <FormField
              control={form.control}
              name="cliPho"
              render={({ field }) => (
                <FormItem>
                  <FormLabel className="text-foreground">Teléfono</FormLabel>
                  <FormControl>
                    <Input
                      {...field}
                      placeholder="+51 999 999 999"
                      className="bg-background border-input text-foreground placeholder:text-muted-foreground focus:border-primary"
                    />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />

            <FormField
              control={form.control}
              name="cliAdd"
              render={({ field }) => (
                <FormItem>
                  <FormLabel className="text-foreground">Dirección</FormLabel>
                  <FormControl>
                    <Input
                      {...field}
                      placeholder="Dirección del cliente"
                      className="bg-background border-input text-foreground placeholder:text-muted-foreground focus:border-primary"
                    />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />

            <FormField
              control={form.control}
              name="cliDes"
              render={({ field }) => (
                <FormItem>
                  <FormLabel className="text-foreground">Notas</FormLabel>
                  <FormControl>
                    <Textarea
                      {...field}
                      placeholder="Notas adicionales sobre el cliente..."
                      className="bg-background border-input text-foreground placeholder:text-muted-foreground focus:border-primary resize-none"
                      rows={3}
                    />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />

            <DialogFooter className="pt-4">
              <Button
                type="button"
                variant="outline"
                onClick={() => onOpenChange(false)}
                className="border-input hover:bg-accent hover:text-accent-foreground"
              >
                Cancelar
              </Button>
              <Button
                type="submit"
                disabled={isLoading}
                className="bg-primary hover:bg-primary/90"
              >
                {isLoading && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                {isEditing ? 'Guardar cambios' : 'Crear cliente'}
              </Button>
            </DialogFooter>
          </form>
        </Form>
      </DialogContent>
    </Dialog>
  );
}
