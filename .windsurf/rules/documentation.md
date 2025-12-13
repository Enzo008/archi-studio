---
trigger: always_on
---

# Documentation Standards

## Headers de Archivo

### Frontend (.ts, .tsx)

Headers concisos (1-2 líneas máximo):

```typescript
/**
 * [Propósito breve]
 * [Contexto adicional si es necesario]
 */
```

**Ejemplos por tipo:**

- **Services**: `Servicio para gestión de usuarios - operaciones CRUD`
- **Hooks**: `Hook para CRUD de proyectos con paginación`
- **Pages**: `Página de usuarios - tabla con modal CRUD`
- **Components**: `Header con sidebar trigger y breadcrumbs`

### Backend (.cs)

Mantener formato C# existente:

```csharp
// *****************************************************************************************************
// Descripción       : [Descripción del controller/clase]
// Creado por        : [Nombre del desarrollador]
// Fecha de Creación : [DD/MM/YYYY]
// Acción a Realizar : [Acciones principales]
// *****************************************************************************************************
```

## Niveles de Documentación

| Nivel | Archivos | Documentación |
|-------|----------|---------------|
| 1 | Services, hooks complejos, pages, layouts | Header + comentarios críticos |
| 2 | Componentes UI, hooks simples, configs | Header básico |
| 3 | Types, index files, constantes | Solo inline si es necesario |

## Reglas

### ✅ Documentar

- Headers en services, hooks, pages, componentes principales
- Comentarios inline en lógica compleja
- JSDoc en funciones públicas exportadas
- Decisiones técnicas no obvias

### ❌ Evitar

- Documentación excesiva (600+ líneas de comentarios)
- README innecesarios - preferir comentarios en código
- Comentarios obvios que repiten el código
- Documentación duplicada
- Headers en archivos triviales (types simples, exports)

## Comentarios Inline

```typescript
// ✅ Explica el POR QUÉ, no el QUÉ
// Usamos debounce de 300ms para evitar llamadas excesivas al API
const debouncedSearch = useDebouncedCallback(search, 300);

// ❌ Obvio - no agrega valor
// Incrementa el contador
counter++;
```

## JSDoc para Funciones Públicas

```typescript
/**
 * Obtiene proyectos paginados del usuario actual
 * @param params - Parámetros de paginación
 * @returns Lista de proyectos con metadata de paginación
 */
export async function getProjects(params: PaginationParams): Promise<PaginatedResponse<Project>> {
  // ...
}
```