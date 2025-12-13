---
trigger: always_on
---

# ArchiStudio - Product Overview

## Descripción

ArchiStudio es una plataforma SaaS para arquitectos y diseñadores de interiores que centraliza la gestión de proyectos, clientes, presupuestos y documentación profesional.

## Funcionalidades Core

| Módulo | Descripción |
|--------|-------------|
| Dashboard | Métricas, actividad reciente, próximas entregas |
| Proyectos | Seguimiento con estados, hitos y progreso |
| Clientes | CRM básico con proyectos asociados |
| Presupuestos | Creación y seguimiento por proyecto |
| Documentos | Planos, renders y documentación |
| Configuración | Perfil, preferencias, roles y permisos |

## Autenticación y Autorización

- **Clerk** como provider de autenticación (frontend)
- **JWT Bearer** para validación en backend
- Sincronización automática: Clerk → `TM_USER` (base de datos local)
- Menús dinámicos basados en rol (`TV_ROLE_MENU`)
- Permisos granulares por menú y acción (`TV_ROLE_PERMISSION`)

## Modelo de Datos Principal

```
Usuario (TM_USER)
  └── Rol (TB_ROLE)
        ├── Menús (TV_ROLE_MENU)
        └── Permisos (TV_ROLE_PERMISSION)
  └── Proyectos (TM_PROJECT)
        ├── Presupuestos
        └── Documentos
  └── Clientes (TM_CLIENT)
```

## UX Principles

- **Dark Mode** por defecto (slate-950 base, primary verde)
- **Elegancia profesional**: UI limpia para profesionales del diseño
- **Feedback inmediato**: Toast notifications con Sonner
- **Mobile-first**: Responsive en todos los dispositivos
- **Accesibilidad**: WCAG 2.1 AA compliance

## Convenciones de Idioma

| Contexto | Idioma |
|----------|--------|
| Código (variables, funciones, clases) | Inglés |
| UI (labels, textos, notificaciones) | Español |
| Documentación técnica | Español |
| Comentarios en código | Español |

## Notificaciones

- Usar `sonner` para toast notifications
- **NUNCA** usar `alert()` o `confirm()` nativos
- Tipos: success (3s), error (5s), warning, info
