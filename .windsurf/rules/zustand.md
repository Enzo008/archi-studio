---
trigger: always_on
---

# Zustand State Management

## Principio Fundamental

- **Zustand**: Solo para UI state (sidebar, theme, modals)
- **TanStack Query**: Para server state (datos del API)
- **NUNCA** guardar datos del servidor en Zustand

## Patrón de Store

```typescript
// store/sidebar-store.ts
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

interface SidebarState {
  isCollapsed: boolean;
  actions: {
    toggle: () => void;
    setCollapsed: (collapsed: boolean) => void;
  };
}

// ⬇️ Store NO exportado directamente
const useSidebarStore = create<SidebarState>()(
  persist(
    (set) => ({
      isCollapsed: false,
      actions: {
        toggle: () => set((state) => ({ isCollapsed: !state.isCollapsed })),
        setCollapsed: (collapsed) => set({ isCollapsed: collapsed }),
      },
    }),
    { name: 'sidebar-state' }
  )
);

// ✅ Exportar selectores atómicos
export const useSidebarCollapsed = () => 
  useSidebarStore((state) => state.isCollapsed);

// ✅ Exportar actions (nunca cambian, no causan re-renders)
export const useSidebarActions = () => 
  useSidebarStore((state) => state.actions);
```

## Modal Store

```typescript
// store/modal-store.ts
import { create } from 'zustand';

interface ModalState {
  modals: Record<string, boolean>;
  modalData: Record<string, unknown>;
  actions: {
    open: (id: string, data?: unknown) => void;
    close: (id: string) => void;
    closeAll: () => void;
  };
}

const useModalStore = create<ModalState>((set) => ({
  modals: {},
  modalData: {},
  actions: {
    open: (id, data) => set((state) => ({
      modals: { ...state.modals, [id]: true },
      modalData: data ? { ...state.modalData, [id]: data } : state.modalData,
    })),
    close: (id) => set((state) => ({
      modals: { ...state.modals, [id]: false },
      modalData: { ...state.modalData, [id]: undefined },
    })),
    closeAll: () => set({ modals: {}, modalData: {} }),
  },
}));

// Selectores atómicos
export const useModalOpen = (id: string) => 
  useModalStore((state) => state.modals[id] ?? false);

export const useModalData = <T>(id: string) => 
  useModalStore((state) => state.modalData[id] as T);

export const useModalActions = () => 
  useModalStore((state) => state.actions);
```

## Uso en Componentes

```tsx
// ✅ CORRECTO: Selectores atómicos
const MyComponent = () => {
  const isCollapsed = useSidebarCollapsed();
  const { toggle } = useSidebarActions();
  
  return (
    <Button onClick={toggle}>
      {isCollapsed ? 'Expandir' : 'Colapsar'}
    </Button>
  );
};

// ❌ INCORRECTO: Suscribirse a todo el store
const BadComponent = () => {
  const { isCollapsed, actions } = useSidebarStore(); // Re-render en cualquier cambio!
};
```

## Casos de Uso Válidos

| ✅ Usar Zustand | ❌ NO usar Zustand |
|-----------------|-------------------|
| Estado del sidebar | Lista de proyectos |
| Theme (dark/light) | Datos de usuario |
| Modals abiertos | Resultados de búsqueda |
| Selección en tablas | Cualquier dato del API |
| Preferencias UI | Cache de datos |

## Persist Middleware

```typescript
// Solo persistir lo necesario
persist(
  (set) => ({ /* ... */ }),
  {
    name: 'app-ui-storage',
    partialize: (state) => ({
      // Solo persistir preferencias, no estados temporales
      isCollapsed: state.isCollapsed,
      theme: state.theme,
    }),
  }
)
```

## Anti-Patterns

```typescript
// ❌ Exportar store directamente
export const useStore = create(/* ... */);

// ❌ Guardar server data
const useUserStore = create(() => ({
  users: [], // Esto va en TanStack Query!
  loading: false,
}));

// ❌ Setters en lugar de eventos
actions: {
  setOpen: (open) => set({ open }), // ❌
  toggle: () => set((s) => ({ open: !s.open })), // ✅
}

// ❌ Store monolítico
const useAppStore = create(() => ({
  theme: 'dark',
  sidebar: true,
  modals: {},
  users: [], // ❌ Server data
  projects: [], // ❌ Server data
}));
```