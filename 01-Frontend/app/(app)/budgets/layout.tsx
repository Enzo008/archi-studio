import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Presupuestos | ArchiStudio',
  description: 'Gestiona los presupuestos de tus proyectos',
};

export default function BudgetsLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return children;
}
