/**
 * DocumentsGrid - Grid de documentos con vista de tarjetas
 */
'use client';

import { useState } from 'react';
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Skeleton } from '@/components/ui/skeleton';
import { Input } from '@/components/ui/input';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import {
  MoreVertical, Pencil, Trash2, Download, FileText, Image,
  FileCheck, FileSpreadsheet, Camera, File, Search, Grid, List, Eye
} from 'lucide-react';
import { cn } from '@/lib/utils';
import { formatDate } from '@/lib/utils/format';
import { EmptyState, DeleteDialog } from '@/components/shared';
import { documentService } from '@/lib/api/services';
import type { Document } from '@/types';
import { toast } from 'sonner';
import { getClerkToken } from '@/lib/api/client';

interface DocumentsGridProps {
  documents: Document[];
  isLoading?: boolean;
  onEdit: (doc: Document) => void;
  onDelete: (doc: Document) => void;
  onPreview?: (doc: Document) => void;
}

const iconMap: Record<string, React.ComponentType<{ className?: string }>> = {
  FileText,
  Image,
  FileCheck,
  FileSpreadsheet,
  Camera,
  File,
};

export function DocumentsGrid({ documents, isLoading, onEdit, onDelete, onPreview }: DocumentsGridProps) {
  const [deleteDoc, setDeleteDoc] = useState<Document | null>(null);
  const [searchQuery, setSearchQuery] = useState('');
  const [viewMode, setViewMode] = useState<'grid' | 'list'>('grid');

  const filteredDocs = documents.filter(
    (d) =>
      d.docNam?.toLowerCase().includes(searchQuery.toLowerCase()) ||
      d.docTypNam?.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const formatFileSize = (bytes?: number) => {
    if (!bytes) return '-';
    if (bytes < 1024) return `${bytes} B`;
    if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
    return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
  };

  const handleDownload = async (doc: Document) => {
    if (!doc.docYea || !doc.docCod) return;

    try {
      const token = await getClerkToken();
      const url = documentService.getDownloadUrl(doc.docYea, doc.docCod);

      // Fetch con Authorization header
      const response = await fetch(url, {
        credentials: 'include',
        headers: {
          ...(token ? { 'Authorization': `Bearer ${token}` } : {})
        }
      });

      if (!response.ok) {
        toast.error('Error al descargar el archivo');
        return;
      }

      const blob = await response.blob();
      const blobUrl = window.URL.createObjectURL(blob);

      const a = document.createElement('a');
      a.href = blobUrl;
      a.download = doc.docFil || doc.docNam || 'documento';
      a.style.display = 'none';
      document.body.appendChild(a);
      a.click();

      setTimeout(() => {
        document.body.removeChild(a);
        window.URL.revokeObjectURL(blobUrl);
      }, 100);
    } catch (error) {
      console.error('Error downloading:', error);
      toast.error('Error al descargar el archivo');
    }
  };

  if (isLoading) {
    return <DocumentsGridSkeleton />;
  }

  if (!documents || documents.length === 0) {
    return (
      <EmptyState
        icon={FileText}
        title="Sin documentos"
        description="Comienza subiendo tu primer documento"
      />
    );
  }

  return (
    <>
      <div className="space-y-4">
        {/* Search and View Toggle */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div className="relative flex-1 max-w-md">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
            <Input
              placeholder="Buscar documento..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="pl-9"
            />
          </div>
          <div className="flex items-center gap-1 bg-muted rounded-lg p-1">
            <Button
              variant="ghost"
              size="icon"
              className={cn(
                "h-8 w-8",
                viewMode === 'grid' && "bg-background"
              )}
              onClick={() => setViewMode('grid')}
            >
              <Grid className="h-4 w-4" />
            </Button>
            <Button
              variant="ghost"
              size="icon"
              className={cn(
                "h-8 w-8",
                viewMode === 'list' && "bg-background"
              )}
              onClick={() => setViewMode('list')}
            >
              <List className="h-4 w-4" />
            </Button>
          </div>
        </div>

        {/* Documents Grid/List */}
        {viewMode === 'grid' ? (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
            {filteredDocs.map((doc) => {
              const IconComponent = iconMap[doc.docTypIco || 'File'] || File;
              return (
                <Card
                  key={`${doc.docYea}-${doc.docCod}`}
                  className="hover:border-primary/50 transition-all"
                >
                  <CardHeader className="pb-2">
                    <div className="flex items-start justify-between">
                      <div className="p-2 rounded-lg bg-muted">
                        <IconComponent className="h-6 w-6 text-primary" />
                      </div>
                      <DropdownMenu>
                        <DropdownMenuTrigger asChild>
                          <Button variant="ghost" size="icon" className="h-8 w-8">
                            <MoreVertical className="h-4 w-4" />
                          </Button>
                        </DropdownMenuTrigger>
                        <DropdownMenuContent align="end">
                          {onPreview && (
                            <DropdownMenuItem
                              className="cursor-pointer"
                              onClick={() => onPreview(doc)}
                            >
                              <Eye className="mr-2 h-4 w-4" />
                              Vista previa
                            </DropdownMenuItem>
                          )}
                          <DropdownMenuItem
                            className="cursor-pointer"
                            onClick={() => handleDownload(doc)}
                          >
                            <Download className="mr-2 h-4 w-4" />
                            Descargar
                          </DropdownMenuItem>
                          <DropdownMenuItem
                            onClick={() => onEdit(doc)}
                            className="cursor-pointer"
                          >
                            <Pencil className="mr-2 h-4 w-4" />
                            Editar
                          </DropdownMenuItem>
                          <DropdownMenuItem
                            onClick={() => setDeleteDoc(doc)}
                            className="cursor-pointer text-red-500 focus:text-red-500"
                          >
                            <Trash2 className="mr-2 h-4 w-4" />
                            Eliminar
                          </DropdownMenuItem>
                        </DropdownMenuContent>
                      </DropdownMenu>
                    </div>
                    <CardTitle className="text-base line-clamp-2 mt-2">
                      {doc.docNam || 'Sin nombre'}
                    </CardTitle>
                    <CardDescription className="text-xs">
                      {doc.docTypNam}
                    </CardDescription>
                  </CardHeader>
                  <CardContent className="pt-0">
                    <div className="flex items-center justify-between text-xs text-muted-foreground">
                      <span>{formatFileSize(doc.docSiz)}</span>
                      <span>{formatDate(doc.datCre)}</span>
                    </div>
                    {doc.proNam && (
                      <Badge variant="outline" className="mt-2 text-xs">
                        {doc.proNam}
                      </Badge>
                    )}
                  </CardContent>
                </Card>
              );
            })}
          </div>
        ) : (
          <Card>
            <CardContent className="p-0">
              <div className="divide-y">
                {filteredDocs.map((doc) => {
                  const IconComponent = iconMap[doc.docTypIco || 'File'] || File;
                  return (
                    <div
                      key={`${doc.docYea}-${doc.docCod}`}
                      className="flex items-center gap-4 p-4 hover:bg-muted/50 transition-colors"
                    >
                      <div className="p-2 rounded-lg bg-muted">
                        <IconComponent className="h-5 w-5 text-primary" />
                      </div>
                      <div className="flex-1 min-w-0">
                        <p className="font-medium truncate">{doc.docNam || 'Sin nombre'}</p>
                        <p className="text-xs text-muted-foreground">{doc.docTypNam}</p>
                      </div>
                      <div className="hidden sm:block text-sm text-muted-foreground">
                        {formatFileSize(doc.docSiz)}
                      </div>
                      <div className="hidden md:block text-sm text-muted-foreground">
                        {formatDate(doc.datCre)}
                      </div>
                      <DropdownMenu>
                        <DropdownMenuTrigger asChild>
                          <Button variant="ghost" size="icon" className="h-8 w-8">
                            <MoreVertical className="h-4 w-4" />
                          </Button>
                        </DropdownMenuTrigger>
                        <DropdownMenuContent align="end">
                          {onPreview && (
                            <DropdownMenuItem
                              className="cursor-pointer"
                              onClick={() => onPreview(doc)}
                            >
                              <Eye className="mr-2 h-4 w-4" />
                              Vista previa
                            </DropdownMenuItem>
                          )}
                          <DropdownMenuItem
                            className="cursor-pointer"
                            onClick={() => handleDownload(doc)}
                          >
                            <Download className="mr-2 h-4 w-4" />
                            Descargar
                          </DropdownMenuItem>
                          <DropdownMenuItem
                            onClick={() => onEdit(doc)}
                            className="cursor-pointer"
                          >
                            <Pencil className="mr-2 h-4 w-4" />
                            Editar
                          </DropdownMenuItem>
                          <DropdownMenuItem
                            onClick={() => setDeleteDoc(doc)}
                            className="cursor-pointer text-red-500 focus:text-red-500"
                          >
                            <Trash2 className="mr-2 h-4 w-4" />
                            Eliminar
                          </DropdownMenuItem>
                        </DropdownMenuContent>
                      </DropdownMenu>
                    </div>
                  );
                })}
              </div>
            </CardContent>
          </Card>
        )}

        {filteredDocs.length === 0 && searchQuery && (
          <div className="text-center py-8 text-muted-foreground">
            No se encontraron documentos para &quot;{searchQuery}&quot;
          </div>
        )}
      </div>

      <DeleteDialog
        open={!!deleteDoc}
        onOpenChange={() => setDeleteDoc(null)}
        onConfirm={() => {
          if (deleteDoc) {
            onDelete(deleteDoc);
            setDeleteDoc(null);
          }
        }}
        title="¿Eliminar documento?"
        itemName={deleteDoc?.docNam}
        itemType="documento"
      />
    </>
  );
}

function DocumentsGridSkeleton() {
  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <Skeleton className="h-9 w-64" />
        <Skeleton className="h-9 w-20" />
      </div>
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
        {Array.from({ length: 8 }).map((_, i) => (
          <Card key={i}>
            <CardHeader className="pb-2">
              <div className="flex items-start justify-between">
                <Skeleton className="h-10 w-10 rounded-lg" />
                <Skeleton className="h-8 w-8" />
              </div>
              <Skeleton className="h-4 w-3/4 mt-2" />
              <Skeleton className="h-3 w-1/2" />
            </CardHeader>
            <CardContent className="pt-0">
              <div className="flex items-center justify-between">
                <Skeleton className="h-3 w-16" />
                <Skeleton className="h-3 w-20" />
              </div>
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
}
