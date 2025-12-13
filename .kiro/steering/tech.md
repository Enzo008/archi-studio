# ArchiStudio - Technical Stack

## Arquitectura

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   01-Frontend   │────▶│   02-Backend    │────▶│   SQL Server    │
│   Next.js 16    │     │   .NET 10       │     │   03-Database   │
│   React 19      │     │   ADO.NET + SP  │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘
                              │
                              ▼
                        ┌─────────────────┐
                        │      Helper     │
                        │   .NET 8 DLL    │
                        └─────────────────┘
```

## Frontend (01-Frontend/)

| Tecnología | Versión | Propósito |
|------------|---------|-----------|
| Next.js | 16.x | Framework con App Router |
| React | 19.x | UI con Server Components |
| TypeScript | 5.x | Tipado estático (strict) |
| Tailwind CSS | 4.x | Estilos utility-first |
| Shadcn/ui | latest | Componentes UI (Radix) |
| Clerk | 6.x | Autenticación |
| TanStack Query | 5.x | Server state |
| Zustand | 5.x | UI state (solo local) |
| React Hook Form | 7.x | Formularios |
| Zod | 3.x | Validación schemas |
| Sonner | 1.x | Toast notifications |

### Reglas TypeScript

- **NUNCA** usar `any` - usar tipos explícitos o `unknown`
- **SIEMPRE** usar `satisfies` para type-checking
- Preferir `type` para DTOs, `interface` para contratos
- Discriminated unions para estados: `loading | error | success`

### Reglas Next.js 16

- Server Components por defecto (sin `'use client'`)
- `'use client'` solo para: hooks, event handlers, browser APIs
- `loading.tsx` y `error.tsx` en cada ruta
- `generateMetadata()` para SEO dinámico

### Data Fetching

- **Server Components**: fetch directo
- **Client Components**: TanStack Query v5
- **Mutations**: Server Actions o TanStack Mutations
- **NUNCA** useEffect para fetching inicial

### State Management

- **Server State**: TanStack Query (NUNCA Zustand)
- **UI State**: Zustand solo para sidebar, theme, modals globales
- Exportar selectores atómicos, nunca el store completo

## Backend (02-Backend/)

| Tecnología | Versión | Propósito |
|------------|---------|-----------|
| .NET | 10.x | Framework principal |
| C# | 14 | Lenguaje |
| ASP.NET Core | 10.x | Web API |
| ADO.NET | - | Acceso a datos (NO EF) |
| JWT Bearer | - | Auth tokens Clerk |
| Swashbuckle | 6.x | Swagger/OpenAPI |

### Patrones Backend

- **Repository Pattern** con Abstract Factory
- **ADO.NET + Stored Procedures** (NO Entity Framework)
- **OperationResponse** para respuestas estandarizadas
- Todo async/await (nunca `.Result` o `.Wait()`)

### ApiResponse Estándar

```csharp
public class ApiResponse {
    public bool Success { get; set; }
    public string Message { get; set; }
    public string MessageType { get; set; }  // Success, Error, Warning, Info
    public object Data { get; set; }
}
```

## Database (03-Database/)

| Elemento | Ubicación |
|----------|-----------|
| Scripts inicialización | `Scripts/` |
| Definición de tablas | `Tables/TABLES_EN.sql` |
| Stored Procedures | `StoredProcedures/` |
| Table Types | `TableTypes/` |

### Nomenclatura Tablas

| Prefijo | Tipo | Ejemplo |
|---------|------|---------|
| `TB_` | Tabla Base (catálogos) | `TB_ROLE`, `TB_POSITION` |
| `TM_` | Tabla Maestra (entidades) | `TM_USER`, `TM_PROJECT` |
| `TV_` | Tabla Vínculo (N:M) | `TV_ROLE_MENU` |

### Nomenclatura Columnas (3 caracteres por palabra)

```sql
USECOD  -- USEr CODe
USENAM  -- USEr NAMe
PROCOD  -- PROject CODe
DATCRE  -- DATe CREation
STAREG  -- STAtus REGister (I=Insert, M=Modify, E=Eliminate)
```

### Campos Auditoría (obligatorios en todas las tablas)

```sql
USECRE VARCHAR(30),    -- User Creation
DATCRE DATETIMEOFFSET, -- Date Creation
ZONCRE VARCHAR(50),    -- Zone Creation
USEUPD VARCHAR(30),    -- User Update
DATUPD DATETIMEOFFSET, -- Date Update
ZONUPD VARCHAR(50),    -- Zone Update
STAREG CHAR(1)         -- Status Register
```

## Helper Library (03-Helper/)

Biblioteca .NET 8 compartida:
- `OperationResponse`: Respuesta estándar
- `BaseDAO`: Clase base acceso a datos
- `SqlHelper`: Helpers ADO.NET
- `Types`: Enums (MessageType, OperationType)

## Comandos de Desarrollo

### Frontend
```bash
cd 01-Frontend
pnpm install          # Instalar dependencias
pnpm dev              # Dev server (localhost:3000)
pnpm build            # Build producción
pnpm lint             # ESLint check
```

### Backend
```bash
cd 02-Backend
dotnet restore        # Restaurar paquetes
dotnet build          # Compilar
dotnet run            # Ejecutar (localhost:5181)
dotnet watch run      # Hot reload

# Helper (compilar primero)
cd 03-Helper
dotnet build          # Genera Helper.dll
```

## Puertos

| Servicio | Puerto |
|----------|--------|
| Frontend | 3000 |
| Backend | 5181 |
| SQL Server | 1433 |

## Variables de Entorno

### Frontend (.env.local)
```env
NEXT_PUBLIC_API_URL=http://localhost:5181
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_test_xxx
CLERK_SECRET_KEY=sk_test_xxx
```

### Backend (appsettings.Development.json)
```json
{
  "ConnectionStrings": {
    "ConnectionStringSqlServer": "Server=localhost;Database=ArchiStudioDB;..."
  },
  "Clerk": {
    "Domain": "xxx.clerk.accounts.dev"
  }
}
```
