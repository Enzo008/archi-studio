/**
 * BudgetModal - Modal para crear/editar presupuestos
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
import type { Budget, BudgetStatus, Project } from '@/types';

// Schema de validación
const budgetSchema = z.object({
  budNam: z.string().min(1, 'El nombre es requerido').max(200, 'Máximo 200 caracteres'),
  budDes: z.string().max(500, 'Máximo 500 caracteres').optional().or(z.literal('')),
  budSta: z.string().min(1, 'Seleccione un estado'),
  budDat: z.string().optional().or(z.literal('')),
  budExp: z.string().optional().or(z.literal('')),
  budNot: z.string().max(1000, 'Máximo 1000 caracteres').optional().or(z.literal('')),
  proYea: z.string().optional().or(z.literal('')),
  proCod: z.string().optional().or(z.literal('')),
});

type BudgetFormData = z.infer<typeof budgetSchema>;

interface BudgetModalProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  budget?: Budget | null;
  onSubmit: (data: Partial<Budget>) => void;
  isLoading?: boolean;
  statuses?: BudgetStatus[];
  projects?: Project[];
}

export function BudgetModal({
  open,
  onOpenChange,
  budget,
  onSubmit,
  isLoading,
  statuses = [],
  projects = [],
}: BudgetModalProps) {
  const isEditing = !!budget;

  const form = useForm<BudgetFormData>({
    resolver: zodResolver(budgetSchema),
    defaultValues: {
      budNam: '',
      budDes: '',
      budSta: '01',
      budDat: '',
      budExp: '',
      budNot: '',
      proYea: '',
      proCod: '',
    },
  });

  // Reset form when modal opens/closes or budget changes
  useEffect(() => {
    if (open && budget) {
      form.reset({
        budNam: budget.budNam || '',
        budDes: budget.budDes || '',
        budSta: budget.budSta || '01',
        budDat: budget.budDat?.split('T')[0] || '',
        budExp: budget.budExp?.split('T')[0] || '',
        budNot: budget.budNot || '',
        proYea: budget.proYea || '',
        proCod: budget.proCod || '',
      });
    } else if (open) {
      form.reset({
        budNam: '',
        budDes: '',
        budSta: '01',
        budDat: new Date().toISOString().split('T')[0],
        budExp: '',
        budNot: '',
        proYea: '',
        proCod: '',
      });
    }
  }, [open, budget, form]);

  const handleSubmit = (data: BudgetFormData) => {
    // Limpiar strings vacíos para campos opcionales (convertir a undefined)
    const cleanedData = {
      budNam: data.budNam,
      budSta: data.budSta,
      budDes: data.budDes || undefined,
      budDat: data.budDat || undefined,
      budExp: data.budExp || undefined,
      budNot: data.budNot || undefined,
      proYea: data.proYea || undefined,
      proCod: data.proCod || undefined,
    };

    onSubmit({
      ...(budget && { budYea: budget.budYea, budCod: budget.budCod }),
      ...cleanedData,
    });
  };

  const handleProjectChange = (value: string) => {
    if (value === 'none') {
      form.setValue('proYea', '');
      form.setValue('proCod', '');
    } else {
      const [proYea, proCod] = value.split('-');
      form.setValue('proYea', proYea);
      form.setValue('proCod', proCod);
    }
  };

  const selectedProject = form.watch('proYea') && form.watch('proCod')
    ? `${form.watch('proYea')}-${form.watch('proCod')}`
    : 'none';

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="bg-card border-border sm:max-w-[550px] max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle className="text-foreground">
            {isEditing ? 'Editar Presupuesto' : 'Nuevo Presupuesto'}
          </DialogTitle>
          <DialogDescription className="text-muted-foreground">
            {isEditing
              ? 'Modifica la información del presupuesto'
              : 'Completa la información para crear un nuevo presupuesto'}
          </DialogDescription>
        </DialogHeader>

        <Form {...form}>
          <form onSubmit={form.handleSubmit(handleSubmit)} className="space-y-4">
            <FormField
              control={form.control}
              name="budNam"
              render={({ field }) => (
                <FormItem>
                  <FormLabel className="text-foreground">Nombre *</FormLabel>
                  <FormControl>
                    <Input
                      {...field}
                      placeholder="Ej: Presupuesto Inicial - Fase 1"
                      className="bg-background border-input text-foreground placeholder:text-muted-foreground focus:border-primary"
                    />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />

            <FormField
              control={form.control}
              name="budDes"
              render={({ field }) => (
                <FormItem>
                  <FormLabel className="text-foreground">Descripción</FormLabel>
                  <FormControl>
                    <Textarea
                      {...field}
                      placeholder="Descripción del presupuesto..."
                      className="bg-background border-input text-foreground placeholder:text-muted-foreground focus:border-primary resize-none"
                      rows={2}
                    />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />

            <div className="grid grid-cols-2 gap-4">
              <FormField
                control={form.control}
                name="budSta"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel className="text-foreground">Estado *</FormLabel>
                    <Select 
                      key={`status-${statuses.length}-${field.value}`}
                      onValueChange={field.onChange} 
                      value={field.value}
                    >
                      <FormControl>
                        <SelectTrigger className="bg-background border-input text-foreground">
                          <SelectValue placeholder="Seleccionar estado" />
                        </SelectTrigger>
                      </FormControl>
                      <SelectContent className="bg-card border-border">
                        {statuses.map((status) => (
                          <SelectItem key={status.budSta} value={status.budSta} className="text-foreground">
                            {status.budStaNam}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                    <FormMessage />
                  </FormItem>
                )}
              />

              <FormItem>
                <FormLabel className="text-foreground">Proyecto</FormLabel>
                <Select 
                  key={`project-${projects.length}-${selectedProject}`}
                  onValueChange={handleProjectChange} 
                  value={selectedProject}
                >
                  <SelectTrigger className="bg-background border-input text-foreground">
                    <SelectValue placeholder="Seleccionar proyecto" />
                  </SelectTrigger>
                  <SelectContent className="bg-card border-border">
                    <SelectItem value="none" className="text-foreground">Sin proyecto</SelectItem>
                    {projects.map((project) => (
                      <SelectItem 
                        key={`${project.proYea}-${project.proCod}`} 
                        value={`${project.proYea}-${project.proCod}`}
                        className="text-foreground"
                      >
                        {project.proNam}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </FormItem>
            </div>

            <div className="grid grid-cols-2 gap-4">
              <FormField
                control={form.control}
                name="budDat"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel className="text-foreground">Fecha</FormLabel>
                    <FormControl>
                      <Input
                        {...field}
                        type="date"
                        className="bg-background border-input text-foreground focus:border-primary"
                      />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />

              <FormField
                control={form.control}
                name="budExp"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel className="text-foreground">Vencimiento</FormLabel>
                    <FormControl>
                      <Input
                        {...field}
                        type="date"
                        className="bg-background border-input text-foreground focus:border-primary"
                      />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />
            </div>

            <FormField
              control={form.control}
              name="budNot"
              render={({ field }) => (
                <FormItem>
                  <FormLabel className="text-foreground">Notas</FormLabel>
                  <FormControl>
                    <Textarea
                      {...field}
                      placeholder="Notas adicionales..."
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
                {isEditing ? 'Guardar cambios' : 'Crear presupuesto'}
              </Button>
            </DialogFooter>
          </form>
        </Form>
      </DialogContent>
    </Dialog>
  );
}
