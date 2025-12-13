import { SignUp } from '@clerk/nextjs'
import { dark } from '@clerk/themes'

/**
 * Sign Up Page - Página de registro con Clerk
 */
export default function SignUpPage() {
  return (
    <SignUp 
      appearance={{
        baseTheme: dark,
        elements: {
          rootBox: 'w-full',
          card: 'bg-card border border-border shadow-xl rounded-2xl w-full',
          headerTitle: 'text-2xl font-bold text-foreground',
          headerSubtitle: 'text-muted-foreground',
          socialButtonsBlockButton: 
            'bg-secondary hover:bg-secondary/80 border border-border text-foreground font-medium transition-colors',
          socialButtonsBlockButtonText: 'font-medium',
          dividerLine: 'bg-border',
          dividerText: 'text-muted-foreground text-xs',
          formFieldLabel: 'text-foreground font-medium',
          formFieldInput: 
            'bg-background border-input text-foreground rounded-lg focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all',
          formButtonPrimary: 
            'bg-primary hover:bg-primary/90 text-primary-foreground font-medium rounded-lg h-11 transition-colors',
          footerActionLink: 'text-primary hover:text-primary/80 font-medium',
          footer: 'hidden',
          identityPreviewEditButton: 'text-primary hover:text-primary/80',
          formFieldInputShowPasswordButton: 'text-muted-foreground hover:text-foreground',
          alert: 'bg-destructive/10 border-destructive/20 text-destructive',
          alertText: 'text-destructive text-sm',
        },
        variables: {
          colorPrimary: 'hsl(15 50% 45%)',
          colorBackground: 'hsl(30 10% 10%)',
          colorText: 'hsl(40 20% 90%)',
          colorTextSecondary: 'hsl(35 10% 55%)',
          colorInputBackground: 'hsl(30 10% 12%)',
          colorInputText: 'hsl(40 20% 90%)',
          colorDanger: 'hsl(0 70% 50%)',
          borderRadius: '0.625rem',
          spacingUnit: '1rem',
        },
      }}
    />
  )
}
