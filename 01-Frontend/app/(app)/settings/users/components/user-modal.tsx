/**
 * UserModal - Componente presentacional de modal de usuario
 * Solo renderiza formulario, recibe callbacks via props (Single Responsibility)
 */
'use client';

import { useEffect, useState } from 'react';
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
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { Loader2 } from 'lucide-react';
import { roleService } from '@/lib/api/services/role-service';
import type { User, Role } from '@/types';

const userSchema = z.object({
  useYea: z.string(),
  useCod: z.string(),
  useNam: z.string().optional(),
  useLas: z.string().optional(),
  useEma: z.string().email('Email inválido'),
  rolCod: z.string().min(1, 'Selecciona un rol'),
  useSta: z.enum(['A', 'I']),
});

type UserFormData = z.infer<typeof userSchema>;

interface UserModalProps {
  user: User | null;
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onSubmit: (data: Partial<User>) => void;
  isLoading?: boolean;
}

export function UserModal({ user, open, onOpenChange, onSubmit, isLoading }: UserModalProps) {
  const [roles, setRoles] = useState<Role[]>([]);
  const [isLoadingRoles, setIsLoadingRoles] = useState(false);

  const form = useForm<UserFormData>({
    resolver: zodResolver(userSchema),
    defaultValues: {
      useYea: '',
      useCod: '',
      useNam: '',
      useLas: '',
      useEma: '',
      rolCod: '',
      useSta: 'A',
    },
  });

  // Cargar roles al abrir el modal
  useEffect(() => {
    if (open) {
      setIsLoadingRoles(true);
      roleService.getAll()
        .then((response) => {
          if (response.success && response.data) {
            setRoles(response.data);
          }
        })
        .catch(console.error)
        .finally(() => setIsLoadingRoles(false));
    }
  }, [open]);

  // Resetear formulario cuando cambia el usuario
  useEffect(() => {
    if (user) {
      form.reset({
        useYea: user.useYea,
        useCod: user.useCod,
        useNam: user.useNam || '',
        useLas: user.useLas || '',
        useEma: user.useEma,
        rolCod: user.rolCod || '',
        useSta: user.useSta || 'A',
      });
    }
  }, [user, form]);

  const handleSubmit = (data: UserFormData) => {
    onSubmit(data);
  };

  const getInitials = () => {
    if (user?.useNam && user?.useLas) {
      return `${user.useNam[0]}${user.useLas[0]}`.toUpperCase();
    }
    return user?.useEma?.[0]?.toUpperCase() || 'U';
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-[500px]">
        <DialogHeader>
          <DialogTitle>Editar Usuario</DialogTitle>
          <DialogDescription>
            Modifica la información del usuario y su rol en el sistema
          </DialogDescription>
        </DialogHeader>

        {user && (
          <div className="flex items-center gap-4 py-4 border-b">
            <Avatar className="h-16 w-16">
              <AvatarImage src={user.useImg} alt={user.useNam || ''} />
              <AvatarFallback className="bg-primary/10 text-primary text-lg">
                {getInitials()}
              </AvatarFallback>
            </Avatar>
            <div>
              <p className="font-semibold text-lg">
                {user.useNam} {user.useLas}
              </p>
              <p className="text-sm text-muted-foreground">{user.useEma}</p>
            </div>
          </div>
        )}

        <Form {...form}>
          <form onSubmit={form.handleSubmit(handleSubmit)} className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <FormField
                control={form.control}
                name="useNam"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Nombre</FormLabel>
                    <FormControl>
                      <Input {...field} disabled className="bg-muted" />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />

              <FormField
                control={form.control}
                name="useLas"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Apellido</FormLabel>
                    <FormControl>
                      <Input {...field} disabled className="bg-muted" />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />
            </div>

            <FormField
              control={form.control}
              name="useEma"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Email</FormLabel>
                  <FormControl>
                    <Input {...field} disabled className="bg-muted" />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />

            <FormField
              control={form.control}
              name="rolCod"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Rol</FormLabel>
                  <Select
                    key={`role-${roles.length}-${field.value}`}
                    onValueChange={field.onChange}
                    value={field.value}
                    disabled={isLoadingRoles}
                  >
                    <FormControl>
                      <SelectTrigger>
                        <SelectValue placeholder="Selecciona un rol" />
                      </SelectTrigger>
                    </FormControl>
                    <SelectContent>
                      {roles.map((role) => (
                        <SelectItem key={role.rolCod} value={role.rolCod}>
                          {role.rolNam}
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
              name="useSta"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Estado</FormLabel>
                  <Select onValueChange={field.onChange} value={field.value}>
                    <FormControl>
                      <SelectTrigger>
                        <SelectValue />
                      </SelectTrigger>
                    </FormControl>
                    <SelectContent>
                      <SelectItem value="A">Activo</SelectItem>
                      <SelectItem value="I">Inactivo</SelectItem>
                    </SelectContent>
                  </Select>
                  <FormMessage />
                </FormItem>
              )}
            />

            <DialogFooter className="pt-4">
              <Button type="button" variant="outline" onClick={() => onOpenChange(false)}>
                Cancelar
              </Button>
              <Button type="submit" disabled={isLoading}>
                {isLoading && (
                  <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                )}
                Guardar cambios
              </Button>
            </DialogFooter>
          </form>
        </Form>
      </DialogContent>
    </Dialog>
  );
}
