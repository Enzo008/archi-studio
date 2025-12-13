/**
 * Página de gestión de usuarios - Solo Admin
 * Coordina estado, queries y mutations (Single Responsibility)
 */
'use client';

import { useState } from 'react';
import { PageHeader } from '@/components/layout/page-header';
import { UsersTable } from './components/users-table';
import { UserModal } from './components/user-modal';
import { useUsers, useUpdateUser } from '@/hooks/use-users';
import type { User } from '@/types';

export default function UsersPage() {
  const [modalOpen, setModalOpen] = useState(false);
  const [selectedUser, setSelectedUser] = useState<User | null>(null);

  // Queries y mutations
  const { data, isLoading } = useUsers({ page: 1, pageSize: 50 });
  const updateMutation = useUpdateUser();

  const handleEdit = (user: User) => {
    setSelectedUser(user);
    setModalOpen(true);
  };

  const handleSubmit = (userData: Partial<User>) => {
    updateMutation.mutate(userData, {
      onSuccess: () => setModalOpen(false),
    });
  };

  return (
    <div className="space-y-6">
      <PageHeader
        title="Gestión de Usuarios"
        description="Administra los usuarios del sistema y sus roles"
      />

      <UsersTable
        users={data?.users || []}
        isLoading={isLoading}
        onEdit={handleEdit}
      />

      <UserModal
        open={modalOpen}
        onOpenChange={setModalOpen}
        user={selectedUser}
        onSubmit={handleSubmit}
        isLoading={updateMutation.isPending}
      />
    </div>
  );
}
