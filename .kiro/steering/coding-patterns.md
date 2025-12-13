---
inclusion: always
---

# Coding Patterns - ArchiStudio

## Backend Patterns (.NET 10 / C# 14 / ADO.NET)

### Controller Pattern

```csharp
[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ProjectController : ControllerBase
{
    private readonly RepositoryFactory _repositoryFactory;
    private readonly LogHelper _logHelper;
    
    public ProjectController(RepositoryFactory repositoryFactory, LogHelper logHelper)
    {
        _repositoryFactory = repositoryFactory;
        _logHelper = logHelper;
    }
    
    [HttpGet]
    public async Task<ActionResult<ApiResponse>> GetAll()
    {
        var repo = _repositoryFactory.GetProjectRepository();
        var data = await repo.GetAllAsync();
        return Ok(new ApiResponse(true, "Operación exitosa", "Success", data));
    }
    
    [HttpPost]
    public async Task<ActionResult<ApiResponse>> Create([FromBody] Project project)
    {
        var log = await _logHelper.CreateLogFromTokenAsync(HttpContext);
        var repo = _repositoryFactory.GetProjectRepository();
        var result = await repo.InsertAsync(project, log);
        return Ok(result);
    }
}
```

### Model Pattern (Nomenclatura 3-Char)

```csharp
// Entity con nomenclatura de 3 caracteres por palabra
public class Project : AuditableEntity
{
    // Primary Key: PROject + YEAr + CODe
    public string? ProYea { get; set; }  // PROject YEAr
    public string? ProCod { get; set; }  // PROject CODe
    
    // Attributes
    public string? ProNam { get; set; }  // PROject NAMe
    public string? ProDes { get; set; }  // PROject DEScription
    public string? ProSta { get; set; }  // PROject STAtus
    
    // Foreign Keys
    public string? CliYea { get; set; }  // CLIent YEAr
    public string? CliCod { get; set; }  // CLIent CODe
    
    // Pagination (no se persisten)
    public int? PageNumber { get; set; }
    public int? PageSize { get; set; }
}

// Base class para auditoría
public class AuditableEntity
{
    public string? UseCre { get; set; }  // USEr CREation
    public DateTime? DatCre { get; set; } // DATe CREation
    public string? ZonCre { get; set; }  // ZONe CREation
    public string? UseUpd { get; set; }  // USEr UPDate
    public DateTime? DatUpd { get; set; } // DATe UPDate
    public string? ZonUpd { get; set; }  // ZONe UPDate
    public string? StaReg { get; set; }  // STAtus REGister (I/M/E)
}
```

### Repository Pattern (ADO.NET + SP)

```csharp
public class SqlServerProjectRepository : IProjectRepository
{
    private readonly string _connectionString;
    
    public async Task<List<Project>> GetAllAsync()
    {
        var projects = new List<Project>();
        
        using var connection = new SqlConnection(_connectionString);
        using var command = new SqlCommand("SP_LISTAR_PROJECT", connection);
        command.CommandType = CommandType.StoredProcedure;
        
        await connection.OpenAsync();
        using var reader = await command.ExecuteReaderAsync();
        
        while (await reader.ReadAsync())
        {
            projects.Add(MapFromReader(reader));
        }
        
        return projects;
    }
}
```

### Async/Await Obligatorio

```csharp
// ✅ CORRECTO
await connection.OpenAsync();
await command.ExecuteReaderAsync();

// ❌ INCORRECTO - NUNCA usar versiones síncronas
connection.Open();
command.ExecuteReader();
```

---

## Frontend Patterns (Next.js 16 / React 19)

### Server Components (Por Defecto)

```tsx
// app/(app)/projects/page.tsx - NO 'use client'
import { getProjects } from '@/lib/api/services/project-service';
import { ProjectsTable } from './components/projects-table';

export default async function ProjectsPage() {
  const projects = await getProjects();
  
  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold">Proyectos</h1>
      <ProjectsTable data={projects} />
    </div>
  );
}
```

### Client Components (Solo Cuando Necesario)

```tsx
// components/create-project-button.tsx
'use client';

import { useState } from 'react';
import { Button } from '@/components/ui/button';

export function CreateProjectButton() {
  const [open, setOpen] = useState(false);
  
  return (
    <Button onClick={() => setOpen(true)}>
      Nuevo Proyecto
    </Button>
  );
}
```

### Server Actions para Mutations

```tsx
// app/(app)/projects/actions.ts
'use server';

import { revalidatePath } from 'next/cache';
import { z } from 'zod';

const createProjectSchema = z.object({
  title: z.string().min(1, 'Título requerido'),
  clientId: z.number().positive(),
});

export async function createProject(formData: FormData) {
  const validated = createProjectSchema.safeParse({
    title: formData.get('title'),
    clientId: Number(formData.get('clientId')),
  });
  
  if (!validated.success) {
    return { error: validated.error.flatten() };
  }
  
  // API call...
  revalidatePath('/projects');
  return { success: true };
}
```

### Validación con Zod

```tsx
// lib/validations/project.ts
import { z } from 'zod';

export const projectSchema = z.object({
  title: z.string()
    .min(1, 'El título es requerido')
    .max(100, 'Máximo 100 caracteres'),
  description: z.string()
    .max(500, 'Máximo 500 caracteres')
    .optional(),
  status: z.enum(['draft', 'active', 'completed', 'cancelled']),
});

export type ProjectFormData = z.infer<typeof projectSchema>;
```

---

## Anti-Patterns (EVITAR)

### Backend
- ❌ `.Result` o `.Wait()` en código async
- ❌ Business logic en Controllers
- ❌ Retornar IQueryable desde repositorios

### Frontend
- ❌ `'use client'` en páginas que no lo necesitan
- ❌ `useEffect` para fetch inicial
- ❌ Guardar server state en Zustand
- ❌ `any` en TypeScript
- ❌ Axios (usar fetch nativo)
