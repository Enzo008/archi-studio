import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Documentos | ArchiStudio',
  description: 'Gestiona planos, renders y documentación de proyectos',
};

export default function DocumentsLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return children;
}
