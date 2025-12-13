/**
 * Tipos de entidades del dominio ArchiStudio
 */

// =============================================
// Base Types
// =============================================

export interface AuditableEntity {
  useCre?: string;
  datCre?: string;
  zonCre?: string;
  useUpd?: string;
  datUpd?: string;
  zonUpd?: string;
  staRec?: 'C' | 'U' | 'D';
}

// =============================================
// User & Auth
// =============================================

export interface User extends AuditableEntity {
  useYea: string;
  useCod: string;
  useExtId?: string;
  useNam?: string;
  useLas?: string;
  useEma: string;
  useImg?: string;
  rolCod: string;
  rolNam?: string;
  useSta?: 'A' | 'I';
  menus?: Menu[];
}

export interface Menu {
  menYea: string;
  menCod: string;
  menYeaPar?: string;
  menCodPar?: string;
  menNam: string;
  menRef?: string;
  menIco?: string;
  menOrd?: string;
  children?: Menu[];
}

export interface Role {
  rolCod: string;
  rolNam: string;
  rolDes?: string;
}

export interface SyncUserRequest {
  externalId: string;
  email: string;
  firstName?: string;
  lastName?: string;
  imageUrl?: string;
}

export interface SyncUserResponse {
  isNewUser: boolean;
  useYea?: string;
  useCod?: string;
  rolCod?: string;
  rolNam?: string;
  menus?: Menu[];
}

// =============================================
// Client
// =============================================

export interface Client extends AuditableEntity {
  cliYea: string;
  cliCod: string;
  cliNam?: string;
  cliTyp?: '01' | '02'; // 01=Persona, 02=Empresa
  cliEma?: string;
  cliPho?: string;
  cliAdd?: string;
  cliSta?: 'A' | 'I';
  cliDes?: string;
}

export type ClientType = '01' | '02';

export const CLIENT_TYPES: Record<ClientType, string> = {
  '01': 'Persona',
  '02': 'Empresa',
};

// =============================================
// Project
// =============================================

export interface Project extends AuditableEntity {
  proYea: string;
  proCod: string;
  proNam?: string;
  proDes?: string;
  proSta?: string;
  proStaNam?: string;
  proStaIco?: string;
  proStaCol?: string;
  proPro?: number; // Progress 0-100
  proDatIni?: string;
  proDatEnd?: string;
  proBudget?: number;
  proAdd?: string;
  // Client FK
  cliYea?: string;
  cliCod?: string;
  cliNam?: string;
  // User FK (Project Manager)
  useYea?: string;
  useCod?: string;
  useNam?: string;
}

export interface ProjectStatus {
  proSta: string;
  proStaNam: string;
  proStaOrd?: number;
  proStaIco?: string;
  proStaCol?: string;
}

// =============================================
// Budget
// =============================================

export interface Budget extends AuditableEntity {
  budYea: string;
  budCod: string;
  budNam?: string;
  budDes?: string;
  budSta?: string;
  budStaNam?: string;
  budStaIco?: string;
  budStaCol?: string;
  budTot?: number;
  budDat?: string;
  budExp?: string;
  budNot?: string;
  // Project FK
  proYea?: string;
  proCod?: string;
  proNam?: string;
  // Items
  items?: BudgetItem[];
}

export interface BudgetItem extends AuditableEntity {
  budYea: string;
  budCod: string;
  budIteNum: number;
  budIteNam?: string;
  budIteQty?: number;
  budIteUni?: string;
  budItePri?: number;
  budIteTot?: number;
  budIteSta?: string;
  budIteNot?: string;
  budIteImgPat?: string;
  budIteImgFil?: string;
  budIteImgSiz?: number;
  budIteImgMim?: string;
}

export interface BudgetStatus {
  budSta: string;
  budStaNam: string;
  budStaOrd?: number;
  budStaIco?: string;
  budStaCol?: string;
}

// =============================================
// Document
// =============================================

export interface Document extends AuditableEntity {
  docYea: string;
  docCod: string;
  docNam?: string;
  docDes?: string;
  docTyp?: string;
  docTypNam?: string;
  docTypIco?: string;
  docPat?: string;
  docFil?: string;
  docSiz?: number;
  docMim?: string;
  docSta?: 'A' | 'I';
  // Project FK (optional)
  proYea?: string;
  proCod?: string;
  proNam?: string;
}

export interface DocumentType {
  docTyp: string;
  docTypNam: string;
  docTypIco?: string;
  docTypExt?: string;
}
