/**
 * Project Detail Page - Detalle completo del proyecto
 */
import { ProjectDetail } from './components/project-detail'

interface ProjectDetailPageProps {
  params: Promise<{ id: string }>
}

export default async function ProjectDetailPage({ params }: ProjectDetailPageProps) {
  const { id } = await params
  
  return <ProjectDetail projectId={id} />
}
