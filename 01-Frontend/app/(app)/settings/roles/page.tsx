/**
 * Página de gestión de roles - Solo Admin
 */
'use client';

import { useState } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Skeleton } from '@/components/ui/skeleton';
import { Shield, Users, Plus, Pencil } from 'lucide-react';
import { useRoles, useUpsertRole } from '@/hooks/use-roles';
import { RoleModal } from './components/role-modal';
import type { Role } from '@/types';

export default function RolesPage() {
  const [modalOpen, setModalOpen] = useState(false);
  const [selectedRole, setSelectedRole] = useState<Role | null>(null);

  const { data: roles = [], isLoading } = useRoles();
  const upsertMutation = useUpsertRole();

  const handleCreate = () => {
    setSelectedRole(null);
    setModalOpen(true);
  };

  const handleEdit = (role: Role) => {
    setSelectedRole(role);
    setModalOpen(true);
  };

  const handleSubmit = (roleData: Partial<Role>) => {
    upsertMutation.mutate(roleData, {
      onSuccess: () => setModalOpen(false),
    });
  };

  if (isLoading) {
    return (
      <div className="space-y-4">
        <Skeleton className="h-8 w-48" />
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
          {[...Array(3)].map((_, i) => (
            <Skeleton key={i} className="h-32" />
          ))}
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-xl font-semibold">Roles del Sistema</h2>
          <p className="text-sm text-muted-foreground">
            Gestiona los roles y permisos de los usuarios
          </p>
        </div>
        <Button onClick={handleCreate} size="sm">
          <Plus className="h-4 w-4 mr-2" />
          Nuevo Rol
        </Button>
      </div>

      {roles.length === 0 ? (
        <Card>
          <CardContent className="flex flex-col items-center justify-center py-12">
            <Shield className="h-12 w-12 text-muted-foreground mb-4" />
            <p className="text-lg font-medium">No hay roles configurados</p>
            <p className="text-sm text-muted-foreground">
              Crea tu primer rol para empezar
            </p>
            <Button onClick={handleCreate} className="mt-4">
              <Plus className="h-4 w-4 mr-2" />
              Crear Rol
            </Button>
          </CardContent>
        </Card>
      ) : (
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
          {roles.map((role) => (
            <Card key={role.rolCod} className="hover:border-primary/50 transition-colors group">
              <CardHeader className="pb-3">
                <div className="flex items-center justify-between">
                  <CardTitle className="text-lg flex items-center gap-2">
                    <Shield className="h-5 w-5 text-primary" />
                    {role.rolNam}
                  </CardTitle>
                  <div className="flex items-center gap-2">
                    <Badge variant="outline">{role.rolCod}</Badge>
                    <Button
                      variant="ghost"
                      size="icon"
                      className="h-8 w-8 opacity-0 group-hover:opacity-100 transition-opacity"
                      onClick={() => handleEdit(role)}
                    >
                      <Pencil className="h-4 w-4" />
                    </Button>
                  </div>
                </div>
                {role.rolDes && (
                  <CardDescription>{role.rolDes}</CardDescription>
                )}
              </CardHeader>
              <CardContent>
                <div className="flex items-center gap-2 text-sm text-muted-foreground">
                  <Users className="h-4 w-4" />
                  <span>Usuarios asignados: -</span>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      )}

      <RoleModal
        open={modalOpen}
        onOpenChange={setModalOpen}
        role={selectedRole}
        onSubmit={handleSubmit}
        isLoading={upsertMutation.isPending}
      />
    </div>
  );
}
