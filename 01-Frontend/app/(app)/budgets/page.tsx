/**
 * Página de Presupuestos - Gestión completa de presupuestos
 */
'use client';

import { useState } from 'react';
import { PageHeader } from '@/components/layout/page-header';
import { ExportButtons } from '@/components/shared';
import { BudgetsTable } from './components/budgets-table';
import { BudgetModal } from './components/budget-modal';
import {
  useBudgets,
  useBudgetStatuses,
  useCreateBudget,
  useUpdateBudget,
  useDeleteBudget,
} from '@/hooks/use-budgets';
import { useProjects } from '@/hooks/use-projects';
import { exportBudgetsToPDF } from '@/lib/utils/export-pdf';
import { exportToExcel, budgetExportColumns } from '@/lib/utils/export-excel';
import type { Budget } from '@/types';

export default function BudgetsPage() {
  const [modalOpen, setModalOpen] = useState(false);
  const [selectedBudget, setSelectedBudget] = useState<Budget | null>(null);

  // Queries y mutations
  const { data: budgetsData, isLoading } = useBudgets({ page: 1, pageSize: 50 });
  const { data: statusesData } = useBudgetStatuses();
  const { data: projectsData } = useProjects({ page: 1, pageSize: 100 });
  const createMutation = useCreateBudget();
  const updateMutation = useUpdateBudget();
  const deleteMutation = useDeleteBudget();

  const handleCreate = () => {
    setSelectedBudget(null);
    setModalOpen(true);
  };

  const handleEdit = (budget: Budget) => {
    setSelectedBudget(budget);
    setModalOpen(true);
  };

  const handleDelete = (budget: Budget) => {
    deleteMutation.mutate({ budYea: budget.budYea, budCod: budget.budCod });
  };

  const handleSubmit = (budgetData: Partial<Budget>) => {
    if (selectedBudget) {
      updateMutation.mutate(budgetData, {
        onSuccess: () => setModalOpen(false),
      });
    } else {
      createMutation.mutate(budgetData, {
        onSuccess: () => setModalOpen(false),
      });
    }
  };

  const budgets = budgetsData?.budgets || [];

  const handleExportPDF = async () => {
    await exportBudgetsToPDF(budgets, `presupuestos-${new Date().toISOString().split('T')[0]}`);
  };

  const handleExportExcel = () => {
    exportToExcel({
      data: budgets,
      columns: budgetExportColumns,
      filename: `presupuestos-${new Date().toISOString().split('T')[0]}`,
      sheetName: 'Presupuestos',
    });
  };

  return (
    <div className="space-y-6">
      <PageHeader
        title="Presupuestos"
        description="Gestiona tus presupuestos y cotizaciones"
        action={{
          label: 'Nuevo Presupuesto',
          onClick: handleCreate,
        }}
      >
        <ExportButtons
          onExportPDF={handleExportPDF}
          onExportExcel={handleExportExcel}
          disabled={budgets.length === 0}
        />
      </PageHeader>

      <BudgetsTable
        budgets={budgetsData?.budgets || []}
        isLoading={isLoading}
        onEdit={handleEdit}
        onDelete={handleDelete}
      />

      <BudgetModal
        open={modalOpen}
        onOpenChange={setModalOpen}
        budget={selectedBudget}
        onSubmit={handleSubmit}
        isLoading={createMutation.isPending || updateMutation.isPending}
        statuses={statusesData || []}
        projects={projectsData?.projects || []}
      />
    </div>
  );
}
