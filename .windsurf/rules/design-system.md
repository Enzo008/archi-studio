---
trigger: always_on
---

# Design System & UI/UX Guidelines

## Visual Identity - "Premium Dark"

Filosofía: Interfaz profesional, inmersiva y elegante (inspirada en Linear, Vercel).

### Paleta de Colores

| Elemento | Clase Tailwind |
|----------|----------------|
| Canvas principal | `bg-slate-950` |
| Cards/Paneles | `bg-slate-900` o `bg-slate-900/50` + `backdrop-blur` |
| Sidebar | `bg-slate-950` + `border-r border-slate-800` |
| Bordes | `border-slate-800` |

### Acento Primario (Verde ArchiStudio)

| Uso | Clase |
|-----|-------|
| Acciones principales | `bg-primary hover:bg-primary/90` |
| Estados activos | `text-primary` o `bg-primary/10` |
| Focus rings | `focus:ring-primary` |

### Jerarquía de Texto

| Tipo | Clase |
|------|-------|
| Headings | `text-white` o `text-slate-50` |
| Body | `text-slate-300` |
| Meta/Subtítulos | `text-slate-500` |
| Muted | `text-muted-foreground` |

## Componentes Shadcn/ui

**REGLA**: NUNCA inventar componentes si existe un primitivo en Shadcn/ui.

### Buttons

```tsx
// ✅ Usar variantes de Button
<Button variant="default">Acción Principal</Button>
<Button variant="outline">Secundario</Button>
<Button variant="ghost">Terciario</Button>
<Button variant="destructive">Eliminar</Button>
```

### Cards

```tsx
// ✅ Patrón compuesto de Card
<Card className="border-slate-800 bg-slate-900">
  <CardHeader>
    <CardTitle className="text-white">Título</CardTitle>
    <CardDescription className="text-slate-400">Subtítulo</CardDescription>
  </CardHeader>
  <CardContent>...</CardContent>
</Card>
```

### Inputs/Forms

```tsx
// ✅ Estilos consistentes
<Input className="bg-slate-950 border-slate-800 placeholder:text-slate-600 focus:border-primary" />
```

## Tailwind CSS Best Practices

### Class Merging

**SIEMPRE** usar `cn()` para combinar clases:

```tsx
import { cn } from '@/lib/utils';

<div className={cn(
  "base-classes",
  condition && "conditional-classes",
  className
)} />
```

### Spacing

Usar espaciado estándar de Tailwind: `4, 6, 8, 12`
**NUNCA** usar valores arbitrarios como `mt-[13px]`

## Micro-Interacciones

### Hover States

```tsx
// Table rows
<TableRow className="hover:bg-slate-800/50 transition-colors" />

// Links
<Link className="hover:text-primary transition-colors" />

// Cards interactivas
<Card className="hover:border-slate-700 transition-all duration-200" />
```

### Badges de Estado

```tsx
// ✅ Badges con forma pill
<Badge className="bg-emerald-500/10 text-emerald-500 border-emerald-500/20">
  Aprobado
</Badge>
<Badge className="bg-amber-500/10 text-amber-500 border-amber-500/20">
  Pendiente
</Badge>
<Badge className="bg-red-500/10 text-red-500 border-red-500/20">
  Rechazado
</Badge>
```

## Layout Patterns

### Dashboard Structure

```
┌─────────────────────────────────────────────────┐
│ Header (sticky, backdrop-blur)                  │
├──────────┬──────────────────────────────────────┤
│ Sidebar  │ Main Content                         │
│ (fixed)  │ (scrollable, padded)                 │
│ 64/240px │                                      │
└──────────┴──────────────────────────────────────┘
```

### Data Tables

| Elemento | Estilo |
|----------|--------|
| Header | `text-xs uppercase text-slate-500 h-10` |
| Rows | `py-4 border-b border-slate-800` |
| Hover | `hover:bg-slate-800/50` |
| Actions | Siempre a la derecha |