/**
 * Budget Detail Page - Detalle completo del presupuesto
 */
import { BudgetDetail } from './components/budget-detail'

interface BudgetDetailPageProps {
  params: Promise<{ id: string }>
}

export default async function BudgetDetailPage({ params }: BudgetDetailPageProps) {
  const { id } = await params
  
  return <BudgetDetail budgetId={id} />
}
