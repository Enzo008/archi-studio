import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Proyectos | ArchiStudio',
  description: 'Gestiona todos tus proyectos de arquitectura y diseño',
};

export default function ProjectsLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return children;
}
