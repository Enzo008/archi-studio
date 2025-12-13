/**
 * ProjectForm - Formulario reutilizable para crear/editar proyectos
 * Se usa en /projects/new y /projects/[id]/edit
 */
'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
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
import { Loader2, ArrowLeft } from 'lucide-react';
import Link from 'next/link';
import type { Project, ProjectStatus, Client } from '@/types';

// Schema de validación
const projectSchema = z.object({
  proNam: z.string().min(1, 'El nombre es requerido').max(200, 'Máximo 200 caracteres'),
  proDes: z.string().max(500, 'Máximo 500 caracteres').optional().or(z.literal('')),
  proSta: z.string().min(1, 'Seleccione un estado'),
  proPro: z.coerce.number().min(0).max(100).default(0),
  proDatIni: z.string().min(1, 'La fecha de inicio es requerida'),
  proDatEnd: z.string().min(1, 'La fecha de fin es requerida'),
  proBudget: z.coerce.number().min(0).optional(),
  proAdd: z.string().max(200, 'Máximo 200 caracteres').optional().or(z.literal('')),
  cliYea: z.string().min(1, 'El cliente es requerido'),
  cliCod: z.string().min(1, 'El cliente es requerido'),
});

type ProjectFormData = z.infer<typeof projectSchema>;

interface ProjectFormProps {
  project?: Project | null;
  onSubmit: (data: Partial<Project>) => void;
  isLoading?: boolean;
  statuses?: ProjectStatus[];
  clients?: Client[];
}

export function ProjectForm({
  project,
  onSubmit,
  isLoading,
  statuses = [],
  clients = [],
}: ProjectFormProps) {
  const router = useRouter();
  const isEditing = !!project;

  const form = useForm<ProjectFormData>({
    resolver: zodResolver(projectSchema),
    defaultValues: {
      proNam: '',
      proDes: '',
      proSta: '01',
      proPro: 0,
      proDatIni: '',
      proDatEnd: '',
      proBudget: 0,
      proAdd: '',
      cliYea: '',
      cliCod: '',
    },
  });

  // Cargar datos del proyecto al editar
  useEffect(() => {
    if (project) {
      form.reset({
        proNam: project.proNam || '',
        proDes: project.proDes || '',
        proSta: project.proSta || '01',
        proPro: project.proPro || 0,
        proDatIni: project.proDatIni?.split('T')[0] || '',
        proDatEnd: project.proDatEnd?.split('T')[0] || '',
        proBudget: project.proBudget || 0,
        proAdd: project.proAdd || '',
        cliYea: project.cliYea || '',
        cliCod: project.cliCod || '',
      });
    }
  }, [project, form]);

  const handleSubmit = (data: ProjectFormData) => {
    const cleanedData = {
      // Requeridos
      proNam: data.proNam,
      proSta: data.proSta,
      proDatIni: data.proDatIni,
      proDatEnd: data.proDatEnd,
      cliYea: data.cliYea,
      cliCod: data.cliCod,
      // Opcionales
      proPro: data.proPro,
      proBudget: data.proBudget || undefined,
      proDes: data.proDes || undefined,
      proAdd: data.proAdd || undefined,
    };

    onSubmit({
      ...(project && { proYea: project.proYea, proCod: project.proCod }),
      ...cleanedData,
    });
  };

  const handleClientChange = (value: string) => {
    const [cliYea, cliCod] = value.split('-');
    form.setValue('cliYea', cliYea, { shouldValidate: true });
    form.setValue('cliCod', cliCod, { shouldValidate: true });
  };

  const selectedClient = form.watch('cliYea') && form.watch('cliCod')
    ? `${form.watch('cliYea')}-${form.watch('cliCod')}`
    : '';

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center gap-4">
        <Button variant="ghost" size="icon" asChild>
          <Link href="/projects">
            <ArrowLeft className="h-5 w-5" />
          </Link>
        </Button>
        <div>
          <h1 className="text-2xl font-bold">
            {isEditing ? 'Editar Proyecto' : 'Nuevo Proyecto'}
          </h1>
          <p className="text-muted-foreground">
            {isEditing
              ? 'Modifica la información del proyecto'
              : 'Completa la información para crear un nuevo proyecto'}
          </p>
        </div>
      </div>

      {/* Formulario */}
      <Form {...form}>
        <form onSubmit={form.handleSubmit(handleSubmit)} className="space-y-6">
          <div className="grid gap-6 lg:grid-cols-2">
            {/* Información básica */}
            <Card>
              <CardHeader>
                <CardTitle>Información General</CardTitle>
                <CardDescription>Datos principales del proyecto</CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <FormField
                  control={form.control}
                  name="proNam"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Nombre del Proyecto *</FormLabel>
                      <FormControl>
                        <Input
                          {...field}
                          placeholder="Ej: Residencia Familiar Los Olivos"
                        />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={form.control}
                  name="proDes"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Descripción</FormLabel>
                      <FormControl>
                        <Textarea
                          {...field}
                          placeholder="Descripción del proyecto..."
                          rows={4}
                        />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={form.control}
                  name="proAdd"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Ubicación</FormLabel>
                      <FormControl>
                        <Input
                          {...field}
                          placeholder="Dirección del proyecto"
                        />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />
              </CardContent>
            </Card>

            {/* Estado y progreso */}
            <Card>
              <CardHeader>
                <CardTitle>Estado y Progreso</CardTitle>
                <CardDescription>Seguimiento del proyecto</CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <FormField
                  control={form.control}
                  name="proSta"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Estado *</FormLabel>
                      <Select 
                        key={`status-${statuses.length}-${field.value}`}
                        onValueChange={field.onChange} 
                        value={field.value}
                      >
                        <FormControl>
                          <SelectTrigger>
                            <SelectValue placeholder="Seleccionar estado" />
                          </SelectTrigger>
                        </FormControl>
                        <SelectContent>
                          {statuses.map((status) => (
                            <SelectItem key={status.proSta} value={status.proSta}>
                              {status.proStaNam}
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
                  name="proPro"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Avance (%)</FormLabel>
                      <FormControl>
                        <Input
                          {...field}
                          type="number"
                          min={0}
                          max={100}
                        />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={form.control}
                  name="cliYea"
                  render={() => (
                    <FormItem>
                      <FormLabel>Cliente *</FormLabel>
                      <Select 
                        key={`client-${clients.length}-${selectedClient}`}
                        onValueChange={handleClientChange} 
                        value={selectedClient}
                      >
                        <SelectTrigger>
                          <SelectValue placeholder="Seleccionar cliente" />
                        </SelectTrigger>
                        <SelectContent>
                          {clients.map((client) => (
                            <SelectItem 
                              key={`${client.cliYea}-${client.cliCod}`} 
                              value={`${client.cliYea}-${client.cliCod}`}
                            >
                              {client.cliNam}
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                      <FormMessage />
                    </FormItem>
                  )}
                />
              </CardContent>
            </Card>

            {/* Fechas */}
            <Card>
              <CardHeader>
                <CardTitle>Cronograma</CardTitle>
                <CardDescription>Fechas del proyecto</CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <FormField
                  control={form.control}
                  name="proDatIni"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Fecha de Inicio *</FormLabel>
                      <FormControl>
                        <Input {...field} type="date" />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={form.control}
                  name="proDatEnd"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Fecha de Fin Estimada *</FormLabel>
                      <FormControl>
                        <Input {...field} type="date" />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />
              </CardContent>
            </Card>

            {/* Presupuesto */}
            <Card>
              <CardHeader>
                <CardTitle>Presupuesto</CardTitle>
                <CardDescription>Información financiera</CardDescription>
              </CardHeader>
              <CardContent>
                <FormField
                  control={form.control}
                  name="proBudget"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Presupuesto (USD)</FormLabel>
                      <FormControl>
                        <Input
                          {...field}
                          type="number"
                          min={0}
                          step={100}
                          placeholder="0.00"
                        />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />
              </CardContent>
            </Card>
          </div>

          {/* Acciones */}
          <div className="flex items-center justify-end gap-4">
            <Button
              type="button"
              variant="outline"
              onClick={() => router.push('/projects')}
            >
              Cancelar
            </Button>
            <Button type="submit" disabled={isLoading}>
              {isLoading && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
              {isEditing ? 'Guardar cambios' : 'Crear proyecto'}
            </Button>
          </div>
        </form>
      </Form>
    </div>
  );
}
