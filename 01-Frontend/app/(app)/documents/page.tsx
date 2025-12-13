/**
 * Página de Documentos - Gestión de documentos y archivos
 */
'use client';

import { useState } from 'react';
import { PageHeader } from '@/components/layout/page-header';
import { DocumentsGrid } from './components/documents-grid';
import { DocumentUploadModal } from './components/document-upload-modal';
import { DocumentPreviewModal } from './components/document-preview-modal';
import {
  useDocuments,
  useDeleteDocument,
} from '@/hooks/use-documents';
import type { Document } from '@/types';
import { toast } from 'sonner';

export default function DocumentsPage() {
  const [uploadModalOpen, setUploadModalOpen] = useState(false);
  const [previewDoc, setPreviewDoc] = useState<Document | null>(null);

  // Queries y mutations
  const { data: docsData, isLoading } = useDocuments({ page: 1, pageSize: 50 });
  const deleteMutation = useDeleteDocument();

  const handleEdit = (doc: Document) => {
    // TODO: Implementar modal de edición
    toast.info('Edición de documento próximamente');
  };

  const handleDelete = (doc: Document) => {
    deleteMutation.mutate({ docYea: doc.docYea, docCod: doc.docCod });
  };

  const handlePreview = (doc: Document) => {
    setPreviewDoc(doc);
  };

  return (
    <div className="space-y-6">
      <PageHeader
        title="Documentos"
        description="Gestiona tus documentos y archivos"
        action={{
          label: 'Subir Documento',
          onClick: () => setUploadModalOpen(true),
        }}
      />

      <DocumentsGrid
        documents={docsData?.documents || []}
        isLoading={isLoading}
        onEdit={handleEdit}
        onDelete={handleDelete}
        onPreview={handlePreview}
      />

      <DocumentUploadModal
        open={uploadModalOpen}
        onOpenChange={setUploadModalOpen}
      />

      <DocumentPreviewModal
        document={previewDoc}
        open={!!previewDoc}
        onOpenChange={(open) => !open && setPreviewDoc(null)}
      />
    </div>
  );
}
