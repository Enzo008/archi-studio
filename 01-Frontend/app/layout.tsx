import type React from "react"
import type { Metadata } from "next"
import { Geist, Geist_Mono } from "next/font/google"
import { Analytics } from "@vercel/analytics/next"
import { ClerkProvider } from "@clerk/nextjs"
import { dark } from "@clerk/themes"
import { ThemeProvider } from "@/components/theme-provider"
import { QueryProvider } from "@/lib/providers/query-provider"
import { AuthApiProvider } from "@/lib/providers/auth-api-provider"
import { UserSyncProvider } from "@/lib/providers/user-sync-provider"
import { Toaster } from "@/components/ui/sonner"
import "./globals.css"

const geistSans = Geist({ 
  subsets: ["latin"],
  variable: "--font-geist-sans",
})
const geistMono = Geist_Mono({ 
  subsets: ["latin"],
  variable: "--font-geist-mono",
})

export const metadata: Metadata = {
  title: "ArchiStudio - Plataforma para Arquitectos",
  description: "Plataforma profesional para gestión de proyectos, portafolios y presupuestos de arquitectura",
}

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode
}>) {
  return (
    <ClerkProvider
      appearance={{
        baseTheme: dark,
        variables: {
          colorPrimary: "hsl(15 50% 45%)",
        },
      }}
    >
      <html lang="es" suppressHydrationWarning>
        <body className={`${geistSans.variable} ${geistMono.variable} font-sans antialiased`}>
          <AuthApiProvider>
            <UserSyncProvider>
              <QueryProvider>
                <ThemeProvider attribute="class" defaultTheme="dark" enableSystem={false} disableTransitionOnChange>
                  {children}
                  <Toaster richColors position="top-right" />
                </ThemeProvider>
              </QueryProvider>
            </UserSyncProvider>
          </AuthApiProvider>
          <Analytics />
        </body>
      </html>
    </ClerkProvider>
  )
}
