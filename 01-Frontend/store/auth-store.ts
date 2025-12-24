/**
 * Store de autenticación - Menús y datos del usuario sincronizado
 */

import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import type { Menu, SyncUserResponse } from '@/types';

interface AuthState {
  // User data from sync
  userYea: string | null;
  userCod: string | null;
  useNam: string | null;
  useLas: string | null;
  rolCod: string | null;
  rolNam: string | null;
  menus: Menu[];
  isNewUser: boolean;
  isSynced: boolean;

  // Actions
  actions: {
    setUserData: (data: SyncUserResponse) => void;
    clearUserData: () => void;
  };
}

const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      userYea: null,
      userCod: null,
      useNam: null,
      useLas: null,
      rolCod: null,
      rolNam: null,
      menus: [],
      isNewUser: false,
      isSynced: false,

      actions: {
        setUserData: (data) =>
          set({
            userYea: data.useYea ?? null,
            userCod: data.useCod ?? null,
            useNam: data.useNam ?? null,
            useLas: data.useLas ?? null,
            rolCod: data.rolCod ?? null,
            rolNam: data.rolNam ?? null,
            menus: data.menus ?? [],
            isNewUser: data.isNewUser,
            isSynced: true,
          }),

        clearUserData: () =>
          set({
            userYea: null,
            userCod: null,
            useNam: null,
            useLas: null,
            rolCod: null,
            rolNam: null,
            menus: [],
            isNewUser: false,
            isSynced: false,
          }),
      },
    }),
    {
      name: 'archistudio-auth',
      partialize: (state) => ({
        userYea: state.userYea,
        userCod: state.userCod,
        useNam: state.useNam,
        useLas: state.useLas,
        rolCod: state.rolCod,
        rolNam: state.rolNam,
        menus: state.menus,
        isSynced: state.isSynced,
      }),
    }
  )
);

// Selectores atómicos
export const useUserYea = () => useAuthStore((state) => state.userYea);
export const useUserCod = () => useAuthStore((state) => state.userCod);
export const useUserNam = () => useAuthStore((state) => state.useNam);
export const useUserLas = () => useAuthStore((state) => state.useLas);
export const useRolCod = () => useAuthStore((state) => state.rolCod);
export const useRolNam = () => useAuthStore((state) => state.rolNam);
export const useMenus = () => useAuthStore((state) => state.menus);
export const useIsSynced = () => useAuthStore((state) => state.isSynced);
export const useIsNewUser = () => useAuthStore((state) => state.isNewUser);

// Actions
export const useAuthActions = () => useAuthStore((state) => state.actions);

