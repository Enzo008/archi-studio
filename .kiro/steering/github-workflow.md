---
inclusion: manual
---

# GitHub Workflow

## Quick Start

```bash
git pull origin main                    # 1. Actualizar
git checkout -b feat/feature-name       # 2. Crear branch
# ... hacer cambios ...
git add . && git commit -m "feat: ..."  # 3. Commit
git push origin feat/feature-name       # 4. Push
# 5. Crear PR en GitHub
# 6. Squash and merge cuando aprobado
```

## Branch Naming

Formato: `<type>/<short-description>`

```bash
feat/user-authentication
fix/login-validation
refactor/api-client
chore/update-dependencies
```

## Commit Messages

Formato: `<type>: <descripción en minúsculas>`

### Types

| Type | Uso |
|------|-----|
| `feat` | Nueva funcionalidad |
| `fix` | Corrección de bug |
| `refactor` | Reestructuración sin cambiar funcionalidad |
| `chore` | Mantenimiento (deps, configs) |
| `docs` | Documentación |
| `test` | Tests |

### Ejemplos

```bash
feat: add user authentication with clerk
fix: resolve foreign key constraint in user assignment
refactor: extract validation to middleware
chore: update tanstack query to v5
docs: add api documentation
```

### Reglas

- ✅ Usar minúsculas después del tipo
- ✅ Ser específico sobre el cambio
- ✅ Menos de 72 caracteres
- ✅ Modo imperativo ("add" no "added")
- ❌ No usar emojis
- ❌ No usar lenguaje vago ("fix stuff")
- ❌ No usar signos de exclamación

## Pull Request

### Título

```
[Type] Descripción breve
```

Ejemplos:
```
[Feat] User authentication with Clerk
[Fix] Login validation error handling
```

### Template

```markdown
## Cambios
- Descripción de los cambios realizados

## Checklist
- [ ] Tests pasando
- [ ] Sin errores de lint
- [ ] Documentación actualizada
```

## Reglas de Protección

- Branch protection en main
- Review requerido antes de merge
- Squash and merge habilitado
- Commits directos a main bloqueados

## ❌ NUNCA

- Force push a main
- Commit secrets o API keys
- Dejar código comentado sin explicación

## ✅ SIEMPRE

- Testear localmente antes de PR
- Actualizar docs con cambios de código
- Mantener commits atómicos y enfocados
