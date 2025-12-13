/**
 * Error boundary para rutas del dashboard
 */

"use client"

import { useEffect } from "react"
import { Button } from "@/components/ui/button"
import { AlertTriangle } from "lucide-react"

interface ErrorProps {
  error: Error & { digest?: string }
  reset: () => void
}

export default function DashboardError({ error, reset }: ErrorProps) {
  useEffect(() => {
    console.error("Dashboard Error:", error)
  }, [error])

  return (
    <div className="flex flex-col items-center justify-center min-h-[400px] space-y-4">
      <AlertTriangle className="w-12 h-12 text-destructive" />
      <h2 className="text-xl font-semibold">Algo salió mal</h2>
      <p className="text-muted-foreground text-center max-w-md">
        {error.message || "Ocurrió un error inesperado. Por favor intenta de nuevo."}
      </p>
      <Button onClick={reset}>Intentar de nuevo</Button>
    </div>
  )
}
