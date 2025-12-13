import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Calendario | ArchiStudio',
  description: 'Calendario de entregas y fechas importantes de proyectos',
};

export default function CalendarLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return children;
}
