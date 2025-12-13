'use client';

/**
 * UsersTable - Wrapper que usa DataTable con configuración de usuarios
 * Reutiliza componente compartido DataTable (DRY principle)
 */

import { Badge } from '@/components/ui/badge';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { Shield, Users, Pencil } from 'lucide-react';
import { DataTable, type DataTableColumn } from '@/components/shared';
import type { User } from '@/types';

interface UsersTableProps {
  users: User[];
  isLoading?: boolean;
  onEdit: (user: User) => void;
}

export function UsersTable({ users, isLoading, onEdit }: UsersTableProps) {
  const getInitials = (user: User) => {
    if (user.useNam && user.useLas) {
      return `${user.useNam[0]}${user.useLas[0]}`.toUpperCase();
    }
    return user.useEma?.[0]?.toUpperCase() || 'U';
  };

  const columns: DataTableColumn<User>[] = [
    {
      key: 'name',
      header: 'Usuario',
      skeleton: { width: 'w-32', hasSubtext: true },
      render: (user) => (
        <div className="flex items-center gap-3">
          <Avatar className="h-9 w-9">
            <AvatarImage src={user.useImg} alt={user.useNam || ''} />
            <AvatarFallback className="bg-primary/10 text-primary text-sm">
              {getInitials(user)}
            </AvatarFallback>
          </Avatar>
          <div>
            <p className="font-medium">{user.useNam} {user.useLas}</p>
            <p className="text-xs text-muted-foreground">ID: {user.useYea}-{user.useCod}</p>
          </div>
        </div>
      ),
    },
    {
      key: 'email',
      header: 'Email',
      skeleton: { width: 'w-40' },
      hideOn: 'sm',
      render: (user) => (
        <span className="text-muted-foreground">{user.useEma}</span>
      ),
    },
    {
      key: 'role',
      header: 'Rol',
      skeleton: { width: 'w-20', isBadge: true },
      render: (user) => (
        <Badge variant="outline" className="gap-1">
          <Shield className="h-3 w-3" />
          {user.rolNam || 'Sin rol'}
        </Badge>
      ),
    },
    {
      key: 'status',
      header: 'Estado',
      skeleton: { width: 'w-16', isBadge: true },
      render: (user) => (
        <Badge
          variant="outline"
          className={
            user.useSta === 'A'
              ? 'bg-emerald-500/10 text-emerald-500 border-emerald-500/20'
              : 'bg-red-500/10 text-red-500 border-red-500/20'
          }
        >
          {user.useSta === 'A' ? 'Activo' : 'Inactivo'}
        </Badge>
      ),
    },
  ];

  return (
    <DataTable
      data={users}
      columns={columns}
      getRowId={(user) => `${user.useYea}-${user.useCod}`}
      isLoading={isLoading}
      emptyIcon={Users}
      emptyTitle="No hay usuarios"
      emptyDescription="Los usuarios aparecerán aquí cuando se registren"
      searchPlaceholder="Buscar usuario..."
      filterFn={(user, query) =>
        (user.useNam?.toLowerCase().includes(query.toLowerCase()) ?? false) ||
        (user.useLas?.toLowerCase().includes(query.toLowerCase()) ?? false) ||
        (user.useEma?.toLowerCase().includes(query.toLowerCase()) ?? false)
      }
      withCard={false}
      actions={[
        {
          label: 'Editar',
          icon: Pencil,
          onClick: onEdit,
        },
      ]}
    />
  );
}
