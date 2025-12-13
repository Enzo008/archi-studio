---
trigger: always_on
---

# ArchiStudio - Project Structure

## Organización del Monorepo

```
archi-studio/
├── 01-Frontend/          # Next.js 16 App
├── 02-Backend/           # .NET 10 Web API
├── 03-Database/          # SQL Server Scripts
```

## Frontend (01-Frontend/)

```
01-Frontend/
├── app/                          # App Router
│   ├── (auth)/                   # Route Group: Auth
│   │   ├── sign-in/[[...sign-in]]/
│   │   ├── sign-up/[[...sign-up]]/
│   │   └── layout.tsx            # Centered, minimal
│   │
│   ├── (app)/                    # Route Group: Protected
│   │   ├── dashboard/
│   │   ├── projects/
│   │   │   ├── page.tsx          # Lista
│   │   │   └── [id]/page.tsx     # Detalle
│   │   ├── budgets/
│   │   ├── clients/
│   │   ├── documents/
│   │   ├── settings/
│   │   ├── layout.tsx            # Sidebar + Header
│   │   ├── loading.tsx
│   │   └── error.tsx
│   │
│   ├── (marketing)/              # Landing page
│   ├── layout.tsx                # Root layout
│   └── globals.css
│
├── components/
│   ├── ui/                       # Shadcn/ui components
│   ├── layout/                   # Header, Sidebar, Footer
│   └── [feature]-*.tsx           # Feature components
│
├── lib/
│   ├── api/
│   │   ├── client.ts             # Fetch wrapper + JWT
│   │   └── services/             # Service por entidad
│   ├── providers/                # React providers
│   └── utils.ts                  # cn() y helpers
│
├── hooks/                        # Custom hooks
├── store/                        # Zustand (solo UI state)
├── types/                        # TypeScript types
│   ├── api.ts                    # ApiResponse, Pagination
│   ├── entities.ts               # User, Project, etc.
│   └── index.ts                  # Re-exports
└── public/                       # Static assets
```

## Backend (02-Backend/)

```
02-Backend/
├── Controllers/
│   ├── Base/
│   │   └── BaseController.cs     # Controller base
│   └── [Entity]Controller.cs     # Un controller por entidad
│
├── Models/
│   ├── Base/
│   │   └── AuditableEntity.cs    # Campos auditoría
│   ├── [Entity].cs               # Entidades
│   └── ApiResponse.cs            # Respuesta estándar
│
├── Data/
│   ├── Factory/
│   │   └── RepositoryFactory.cs  # Abstract Factory
│   ├── Interfaces/
│   │   └── I[Entity]Repository.cs
│   ├── Repositories/
│   │   └── SqlServer/
│   │       ├── SqlServerRepositoryFactory.cs
│   │       └── SqlServer[Entity]Repository.cs
│   └── Helper/
│       ├── LogHelper.cs
│       └── SecurityHelper.cs
│
├── Middleware/
│   └── TokenValidationMiddleware.cs
├── Extensions/
├── Config/
│   └── AppSettings.cs
│
├── Program.cs                    # Entry point
├── appsettings.Development.json
└── appsettings.Production.json
```

## Database (03-Database/)

```
03-Database/
├── Scripts/
│   ├── INIT_ARCHISTUDIO_DB.sql   # Crear BD + tablas mínimas
│   └── INIT_ARCHISTUDIO_CLEAN.sql
├── Tables/
│   └── TABLES_EN.sql             # Todas las tablas
├── StoredProcedures/             # SPs por entidad
├── TableTypes/                   # Table-valued parameters
└── Templates/                    # Templates para nuevos SPs
```

## Convenciones de Nombres

### Archivos y Carpetas

| Tipo | Convención | Ejemplo |
|------|------------|---------|
| Componentes React | PascalCase | `UserTable.tsx`, `ProjectCard.tsx` |
| Hooks | camelCase + use | `use-projects.ts`, `use-mobile.ts` |
| Services | kebab-case + service | `user-service.ts` |
| Stores | kebab-case + store | `auth-store.ts` |
| Types | kebab-case | `entities.ts`, `api.ts` |
| Pages Next.js | `page.tsx` en carpeta | `projects/page.tsx` |

### Código

| Contexto | Convención | Ejemplo |
|----------|------------|---------|
| Componentes | PascalCase | `UserTable`, `ProjectCard` |
| Hooks | camelCase + use | `useProjects`, `useAuth` |
| Funciones | camelCase | `getProjects`, `syncUser` |
| Constantes | UPPER_SNAKE | `API_URL`, `DEFAULT_PAGE_SIZE` |
| Types/Interfaces | PascalCase | `User`, `ApiResponse<T>` |
| C# Classes | PascalCase | `UserController`, `Project` |
| C# Properties | PascalCase 3-char | `UseCod`, `ProNam` |
| SQL Tables | UPPER + prefijo | `TM_USER`, `TB_ROLE` |
| SQL Columns | UPPER 3-char | `USECOD`, `PRONAM` |
| SQL SPs | SP_VERBO_ENTIDAD | `SP_USER_GETALL` |

## Patrones de Implementación

### Nueva Entidad (Full Stack)

1. **Database**: Crear tabla en `03-Database/Tables/`
2. **Database**: Crear SPs en `03-Database/StoredProcedures/`
3. **Backend Model**: `02-Backend/Models/[Entity].cs`
4. **Backend Interface**: `02-Backend/Data/Interfaces/I[Entity]Repository.cs`
5. **Backend Repository**: `02-Backend/Data/Repositories/SqlServer/SqlServer[Entity]Repository.cs`
6. **Backend Factory**: Agregar método en `RepositoryFactory.cs`
7. **Backend Controller**: `02-Backend/Controllers/[Entity]Controller.cs`
8. **Frontend Types**: `01-Frontend/types/entities.ts`
9. **Frontend Service**: `01-Frontend/lib/api/services/[entity]-service.ts`
10. **Frontend Page**: `01-Frontend/app/(app)/[entities]/page.tsx`

### Nuevo Componente UI

1. Si es de Shadcn: `npx shadcn@latest add [component]`
2. Si es custom: `01-Frontend/components/[feature]-[name].tsx`
3. Si necesita estado global: agregar a store existente o crear nuevo

## Import Order (Frontend)

```typescript
// 1. React y externos
import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';

// 2. Componentes UI
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';

// 3. Hooks y stores
import { useAuthActions } from '@/store';

// 4. Services y utils
import { userService } from '@/lib/api/services/user-service';
import { cn } from '@/lib/utils';

// 5. Types
import type { User } from '@/types';

// 6. Relativos
import { UserForm } from './user-form';
```