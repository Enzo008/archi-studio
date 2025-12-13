/**
 * Tipos para respuestas de API y operaciones
 */

export interface ApiResponse<T = unknown> {
  success: boolean;
  message: string;
  messageType: 'Success' | 'Error' | 'Warning' | 'Info';
  data: T;
}

export interface PaginatedResponse<T> {
  items: T[];
  totalCount: number;
  pageNumber: number;
  pageSize: number;
  totalPages: number;
}

export interface PaginationParams {
  page?: number;
  pageSize?: number;
}
