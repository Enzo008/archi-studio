/**
 * Store del sidebar - Estado de colapso
 */

import { create } from 'zustand';
import { persist } from 'zustand/middleware';

interface SidebarState {
  isCollapsed: boolean;
  isMobileOpen: boolean;

  actions: {
    toggle: () => void;
    setCollapsed: (collapsed: boolean) => void;
    toggleMobile: () => void;
    setMobileOpen: (open: boolean) => void;
  };
}

const useSidebarStore = create<SidebarState>()(
  persist(
    (set) => ({
      isCollapsed: false,
      isMobileOpen: false,

      actions: {
        toggle: () => set((state) => ({ isCollapsed: !state.isCollapsed })),
        setCollapsed: (collapsed) => set({ isCollapsed: collapsed }),
        toggleMobile: () => set((state) => ({ isMobileOpen: !state.isMobileOpen })),
        setMobileOpen: (open) => set({ isMobileOpen: open }),
      },
    }),
    {
      name: 'archistudio-sidebar',
      partialize: (state) => ({ isCollapsed: state.isCollapsed }),
    }
  )
);

// Selectores atómicos
export const useIsCollapsed = () => useSidebarStore((state) => state.isCollapsed);
export const useIsMobileOpen = () => useSidebarStore((state) => state.isMobileOpen);

// Actions
export const useSidebarActions = () => useSidebarStore((state) => state.actions);
