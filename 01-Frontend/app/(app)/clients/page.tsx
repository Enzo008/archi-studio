/**
 * Página de Clientes - Gestión completa de clientes
 */
'use client';

import { useState } from 'react';
import { PageHeader } from '@/components/layout/page-header';
import { ExportButtons } from '@/components/shared';
import { ClientsTable } from './components/clients-table';
import { ClientModal } from './components/client-modal';
import {
  useClients,
  useCreateClient,
  useUpdateClient,
  useDeleteClient,
} from '@/hooks/use-clients';
import { exportClientsToPDF } from '@/lib/utils/export-pdf';
import { exportToExcel, clientExportColumns } from '@/lib/utils/export-excel';
import type { Client } from '@/types';

export default function ClientsPage() {
  const [modalOpen, setModalOpen] = useState(false);
  const [selectedClient, setSelectedClient] = useState<Client | null>(null);

  // Queries y mutations
  const { data, isLoading } = useClients({ page: 1, pageSize: 50 });
  const createMutation = useCreateClient();
  const updateMutation = useUpdateClient();
  const deleteMutation = useDeleteClient();

  const clients = data?.clients || [];

  const handleCreate = () => {
    setSelectedClient(null);
    setModalOpen(true);
  };

  const handleEdit = (client: Client) => {
    setSelectedClient(client);
    setModalOpen(true);
  };

  const handleDelete = (client: Client) => {
    deleteMutation.mutate({ cliYea: client.cliYea, cliCod: client.cliCod });
  };

  const handleSubmit = (clientData: Partial<Client>) => {
    if (selectedClient) {
      updateMutation.mutate(clientData, {
        onSuccess: () => setModalOpen(false),
      });
    } else {
      createMutation.mutate(clientData, {
        onSuccess: () => setModalOpen(false),
      });
    }
  };

  const handleExportPDF = async () => {
    await exportClientsToPDF(clients, `clientes-${new Date().toISOString().split('T')[0]}`);
  };

  const handleExportExcel = () => {
    exportToExcel({
      data: clients,
      columns: clientExportColumns,
      filename: `clientes-${new Date().toISOString().split('T')[0]}`,
      sheetName: 'Clientes',
    });
  };

  return (
    <div className="space-y-6">
      <PageHeader
        title="Clientes"
        description="Gestiona tu cartera de clientes"
        action={{
          label: 'Nuevo Cliente',
          onClick: handleCreate,
        }}
      >
        <ExportButtons
          onExportPDF={handleExportPDF}
          onExportExcel={handleExportExcel}
          disabled={clients.length === 0}
        />
      </PageHeader>

      <ClientsTable
        clients={clients}
        isLoading={isLoading}
        onEdit={handleEdit}
        onDelete={handleDelete}
      />

      <ClientModal
        open={modalOpen}
        onOpenChange={setModalOpen}
        client={selectedClient}
        onSubmit={handleSubmit}
        isLoading={createMutation.isPending || updateMutation.isPending}
      />
    </div>
  );
}

