/**
 * Servicio de documentos - operaciones CRUD y catálogos
 */

import { api } from '../client';
import type { Document, DocumentType, ApiResponse, PaginationParams } from '@/types';

export interface DocumentFilters extends PaginationParams {
  docNam?: string;
  docTyp?: string;
  proYea?: string;
  proCod?: string;
}

export const documentService = {
  /**
   * Obtiene todos los documentos (paginado)
   */
  getAll: async (filters: DocumentFilters = {}): Promise<ApiResponse<Document[]>> => {
    const params = new URLSearchParams();
    if (filters.page) params.append('page', String(filters.page));
    if (filters.pageSize) params.append('pageSize', String(filters.pageSize));
    if (filters.docNam) params.append('docNam', filters.docNam);
    if (filters.docTyp) params.append('docTyp', filters.docTyp);
    if (filters.proYea) params.append('proYea', filters.proYea);
    if (filters.proCod) params.append('proCod', filters.proCod);

    const query = params.toString();
    return api.get<Document[]>(`/api/document${query ? `?${query}` : ''}`);
  },

  /**
   * Obtiene un documento por ID (año + código)
   */
  getById: async (docYea: string, docCod: string): Promise<ApiResponse<Document>> => {
    return api.get<Document>(`/api/document/${docYea}/${docCod}`);
  },

  /**
   * Crea un nuevo documento
   */
  create: async (document: Partial<Document>): Promise<ApiResponse<Document>> => {
    return api.post<Document>('/api/document', document);
  },

  /**
   * Actualiza un documento existente
   */
  update: async (document: Partial<Document>): Promise<ApiResponse<Document>> => {
    return api.put<Document>('/api/document', document);
  },

  /**
   * Elimina un documento (soft delete)
   */
  delete: async (docYea: string, docCod: string): Promise<ApiResponse<void>> => {
    return api.delete<void>(`/api/document/${docYea}/${docCod}`);
  },

  /**
   * Obtiene el catálogo de tipos de documento
   */
  getTypes: async (): Promise<ApiResponse<DocumentType[]>> => {
    return api.get<DocumentType[]>('/api/document/types');
  },

  /**
   * Sube un archivo y crea el registro de documento
   */
  upload: async (
    file: File,
    data: {
      docNam?: string;
      docDes?: string;
      docTyp: string;
      proYea?: string;
      proCod?: string;
    }
  ): Promise<ApiResponse<Document>> => {
    const formData = new FormData();
    formData.append('file', file);
    if (data.docNam) formData.append('docNam', data.docNam);
    if (data.docDes) formData.append('docDes', data.docDes);
    formData.append('docTyp', data.docTyp);
    if (data.proYea) formData.append('proYea', data.proYea);
    if (data.proCod) formData.append('proCod', data.proCod);

    return api.upload<Document>('/api/document/upload', formData);
  },


  /**
   * Obtiene la URL de descarga de un documento
   */
  getDownloadUrl: (docYea: string, docCod: string): string => {
    const baseUrl = process.env.NEXT_PUBLIC_API_URL || '';
    return `${baseUrl}/api/document/download/${docYea}/${docCod}`;
  },

  /**
   * Obtiene la URL de preview de un documento (para imágenes)
   */
  getPreviewUrl: (docYea: string, docCod: string): string => {
    const baseUrl = process.env.NEXT_PUBLIC_API_URL || '';
    return `${baseUrl}/api/document/preview/${docYea}/${docCod}`;
  },

  /**
   * Obtiene la URL directa del archivo usando docPat
   * Funciona en localhost (uploads/) y producción (API sirve archivos)
   */
  getFileUrl: (docPat: string): string => {
    const baseUrl = process.env.NEXT_PUBLIC_API_URL || '';
    // En producción, el API sirve los archivos desde /uploads/
    // En desarrollo, también apunta al backend que sirve static files
    return `${baseUrl}/uploads/${docPat}`;
  },
};
