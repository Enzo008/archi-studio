import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Clientes | ArchiStudio',
  description: 'Gestiona tu cartera de clientes',
};

export default function ClientsLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return children;
}
