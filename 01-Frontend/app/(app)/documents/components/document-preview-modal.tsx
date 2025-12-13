/**
 * DocumentPreviewModal - Preview modal for documents (PDF, images, etc.)
 */
'use client'

import { useState } from 'react'
import {
    Dialog,
    DialogContent,
    DialogHeader,
    DialogTitle,
} from '@/components/ui/dialog'
import { Button } from '@/components/ui/button'
import { Download, ExternalLink, X, FileText, AlertCircle } from 'lucide-react'
import { cn } from '@/lib/utils'
import { documentService } from '@/lib/api/services/document-service'
import type { Document } from '@/types'
import { toast } from 'sonner'
import { getClerkToken } from '@/lib/api/client'

interface DocumentPreviewModalProps {
    document: Document | null
    open: boolean
    onOpenChange: (open: boolean) => void
}

const getFileExtension = (filename: string | undefined): string => {
    if (!filename) return ''
    return filename.split('.').pop()?.toLowerCase() || ''
}

const isImage = (ext: string): boolean => {
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg'].includes(ext)
}

const isPDF = (ext: string): boolean => {
    return ext === 'pdf'
}

export function DocumentPreviewModal({ document: doc, open, onOpenChange }: DocumentPreviewModalProps) {
    const [imageError, setImageError] = useState(false)
    const [pdfError, setPdfError] = useState(false)

    if (!doc || !doc.docPat) return null

    // Usa docPat para construir la URL real del archivo
    const fileUrl = documentService.getFileUrl(doc.docPat)
    // Detecta extensión desde docFil (nombre del archivo) o docPat
    const ext = getFileExtension(doc.docFil || doc.docPat)
    const canPreview = isImage(ext) || isPDF(ext)

    const handleDownload = async () => {
        if (!doc.docYea || !doc.docCod) return;

        try {
            const token = await getClerkToken();
            const url = documentService.getDownloadUrl(doc.docYea, doc.docCod);

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
    }

    const handleOpenExternal = () => {
        window.open(fileUrl, '_blank')
    }

    return (
        <Dialog open={open} onOpenChange={onOpenChange}>
            <DialogContent className="bg-card border-border max-w-4xl h-[85vh] flex flex-col p-0">
                {/* Header */}
                <DialogHeader className="px-6 py-4 border-b border-border">
                    <div className="flex items-start justify-between gap-4">
                        <div className="flex-1 min-w-0">
                            <DialogTitle className="text-foreground text-lg truncate">
                                {doc.docNam}
                            </DialogTitle>
                            <p className="text-sm text-muted-foreground mt-1">
                                {doc.docTypNam} {doc.proNam && `• ${doc.proNam}`}
                            </p>
                        </div>
                        <div className="flex items-center gap-2 shrink-0">
                            <Button
                                variant="outline"
                                size="sm"
                                onClick={handleDownload}
                                className="gap-2"
                            >
                                <Download className="h-4 w-4" />
                                Descargar
                            </Button>
                            {canPreview && (
                                <Button
                                    variant="outline"
                                    size="sm"
                                    onClick={handleOpenExternal}
                                    className="gap-2"
                                >
                                    <ExternalLink className="h-4 w-4" />
                                    Abrir
                                </Button>
                            )}
                        </div>
                    </div>
                </DialogHeader>

                {/* Preview Content */}
                <div className="flex-1 overflow-hidden bg-muted/20 relative">
                    {isImage(ext) && !imageError ? (
                        <div className="h-full w-full flex items-center justify-center p-4">
                            <img
                                src={fileUrl}
                                alt={doc.docNam || 'Document preview'}
                                className="max-w-full max-h-full object-contain rounded-lg shadow-lg"
                                onError={() => setImageError(true)}
                            />
                        </div>
                    ) : isPDF(ext) && !pdfError ? (
                        <iframe
                            src={`${fileUrl}#view=FitH`}
                            className="w-full h-full border-0"
                            title={doc.docNam || 'PDF preview'}
                            onError={() => setPdfError(true)}
                        />
                    ) : (
                        <div className="h-full flex flex-col items-center justify-center p-8 text-center">
                            {imageError || pdfError ? (
                                <>
                                    <AlertCircle className="h-16 w-16 text-muted-foreground mb-4" />
                                    <p className="text-foreground font-medium mb-2">
                                        No se pudo cargar la vista previa
                                    </p>
                                    <p className="text-sm text-muted-foreground mb-6">
                                        El archivo podría estar protegido o en un formato no compatible
                                    </p>
                                    <Button onClick={handleDownload} className="gap-2">
                                        <Download className="h-4 w-4" />
                                        Descargar archivo
                                    </Button>
                                </>
                            ) : (
                                <>
                                    <FileText className="h-16 w-16 text-muted-foreground mb-4" />
                                    <p className="text-foreground font-medium mb-2">
                                        Vista previa no disponible
                                    </p>
                                    <p className="text-sm text-muted-foreground mb-1">
                                        Tipo de archivo: <span className="font-mono uppercase">{ext || 'desconocido'}</span>
                                    </p>
                                    <p className="text-xs text-muted-foreground mb-6">
                                        Solo PDF e imágenes se pueden previsualizar
                                    </p>
                                    <Button onClick={handleDownload} className="gap-2">
                                        <Download className="h-4 w-4" />
                                        Descargar archivo
                                    </Button>
                                </>
                            )}
                        </div>
                    )}
                </div>

                {/* Description Footer (if available) */}
                {doc.docDes && (
                    <div className="px-6 py-3 border-t border-border bg-muted/30">
                        <p className="text-xs font-medium text-muted-foreground mb-1">Descripción:</p>
                        <p className="text-sm text-foreground">{doc.docDes}</p>
                    </div>
                )}
            </DialogContent>
        </Dialog>
    )
}
