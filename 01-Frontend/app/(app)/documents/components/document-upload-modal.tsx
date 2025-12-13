/**
 * DocumentUploadModal - Modal para subir documentos con drag & drop
 */
'use client';

import { useState, useCallback } from 'react';
import { useDropzone } from 'react-dropzone';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Textarea } from '@/components/ui/textarea';
import { Label } from '@/components/ui/label';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import {
  Upload, X, FileText, Image, FileCheck,
  FileSpreadsheet, File, Loader2
} from 'lucide-react';
import { cn } from '@/lib/utils';
import { useDocumentTypes, useUploadDocument } from '@/hooks/use-documents';
import { useProjects } from '@/hooks/use-projects';

interface DocumentUploadModalProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
}

const iconMap: Record<string, React.ComponentType<{ className?: string }>> = {
  FileText,
  Image,
  FileCheck,
  FileSpreadsheet,
  File,
};

const formatFileSize = (bytes: number) => {
  if (bytes < 1024) return `${bytes} B`;
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
  return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
};

export function DocumentUploadModal({ open, onOpenChange }: DocumentUploadModalProps) {
  const [file, setFile] = useState<File | null>(null);
  const [docNam, setDocNam] = useState('');
  const [docDes, setDocDes] = useState('');
  const [docTyp, setDocTyp] = useState('');
  const [projectId, setProjectId] = useState('');

  const { data: types = [] } = useDocumentTypes();
  const { data: projectsData } = useProjects({ page: 1, pageSize: 100 });
  const uploadMutation = useUploadDocument();

  const onDrop = useCallback((acceptedFiles: File[]) => {
    if (acceptedFiles.length > 0) {
      const selectedFile = acceptedFiles[0];
      setFile(selectedFile);
      // Auto-fill name if empty
      if (!docNam) {
        setDocNam(selectedFile.name.replace(/\.[^/.]+$/, ''));
      }
    }
  }, [docNam]);

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    multiple: false,
    maxSize: 50 * 1024 * 1024, // 50MB
  });

  const handleSubmit = () => {
    if (!file || !docTyp) return;

    const [proYea, proCod] = projectId ? projectId.split('-') : [undefined, undefined];

    uploadMutation.mutate(
      {
        file,
        data: {
          docNam: docNam || file.name,
          docDes: docDes || undefined,
          docTyp,
          proYea,
          proCod,
        },
      },
      {
        onSuccess: () => {
          handleClose();
        },
      }
    );
  };

  const handleClose = () => {
    setFile(null);
    setDocNam('');
    setDocDes('');
    setDocTyp('');
    setProjectId('');
    onOpenChange(false);
  };

  const removeFile = () => {
    setFile(null);
  };

  const getFileIcon = () => {
    if (!file) return File;
    const ext = file.name.split('.').pop()?.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].includes(ext || '')) return Image;
    if (['pdf', 'doc', 'docx'].includes(ext || '')) return FileText;
    if (['xls', 'xlsx'].includes(ext || '')) return FileSpreadsheet;
    return File;
  };

  const FileIcon = getFileIcon();

  return (
    <Dialog open={open} onOpenChange={handleClose}>
      <DialogContent className="bg-card border-border sm:max-w-[500px]">
        <DialogHeader>
          <DialogTitle className="text-foreground">Subir Documento</DialogTitle>
          <DialogDescription className="text-muted-foreground">
            Arrastra un archivo o haz clic para seleccionar
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-4">
          {/* Dropzone */}
          {!file ? (
            <>
              <div
                {...getRootProps()}
                className={cn(
                  'border-2 border-dashed rounded-lg p-8 text-center cursor-pointer transition-colors',
                  isDragActive
                    ? 'border-primary bg-primary/5'
                    : 'border-border hover:border-primary/50 hover:bg-muted/50'
                )}
              >
                <input {...getInputProps()} />
                <Upload className="h-10 w-10 mx-auto text-muted-foreground mb-4" />
                {isDragActive ? (
                  <p className="text-primary">Suelta el archivo aquí...</p>
                ) : (
                  <>
                    <p className="text-foreground font-medium">
                      Arrastra un archivo aquí
                    </p>
                    <p className="text-sm text-muted-foreground mt-1">
                      o haz clic para seleccionar (máx. 50MB)
                    </p>
                  </>
                )}
              </div>

              {/* File Format Help */}
              <div className="bg-muted/30 rounded-lg p-3 border border-border/50">
                <p className="text-xs font-medium text-muted-foreground mb-2">Formatos soportados:</p>
                <div className="grid grid-cols-2 gap-2 text-xs text-muted-foreground">
                  <div className="flex items-center gap-1.5">
                    <FileText className="h-3.5 w-3.5" />
                    <span>PDF, DOC, DOCX, TXT</span>
                  </div>
                  <div className="flex items-center gap-1.5">
                    <Image className="h-3.5 w-3.5" />
                    <span>JPG, PNG, GIF, WEBP</span>
                  </div>
                  <div className="flex items-center gap-1.5">
                    <FileSpreadsheet className="h-3.5 w-3.5" />
                    <span>XLS, XLSX, CSV</span>
                  </div>
                  <div className="flex items-center gap-1.5">
                    <File className="h-3.5 w-3.5" />
                    <span>ZIP, RAR, DWG</span>
                  </div>
                </div>
              </div>
            </>
          ) : (
            <div className="flex items-center gap-3 p-4 bg-muted/50 rounded-lg overflow-hidden">
              <div className="h-10 w-10 rounded bg-primary/10 flex items-center justify-center shrink-0">
                <FileIcon className="h-5 w-5 text-primary" />
              </div>
              <div className="flex-1 min-w-0 overflow-hidden">
                <p className="font-medium truncate text-sm" title={file.name}>{file.name}</p>
                <p className="text-xs text-muted-foreground">
                  {formatFileSize(file.size)}
                </p>
              </div>
              <Button
                type="button"
                variant="ghost"
                size="icon"
                onClick={removeFile}
                className="text-muted-foreground hover:text-destructive"
              >
                <X className="h-4 w-4" />
              </Button>
            </div>
          )}

          {/* Form fields */}
          <div className="space-y-4">
            <div className="space-y-2">
              <Label>Nombre del documento</Label>
              <Input
                value={docNam}
                onChange={(e) => setDocNam(e.target.value)}
                placeholder="Nombre descriptivo"
                className="bg-background border-input"
              />
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>Tipo *</Label>
                <Select value={docTyp} onValueChange={setDocTyp}>
                  <SelectTrigger className="bg-background border-input">
                    <SelectValue placeholder="Seleccionar tipo" />
                  </SelectTrigger>
                  <SelectContent className="bg-card border-border">
                    {types
                      .filter((type) => type.docTyp) // Filtrar tipos sin código
                      .map((type) => {
                        const Icon = iconMap[type.docTypIco || 'File'] || File;
                        return (
                          <SelectItem key={type.docTyp} value={type.docTyp!}>
                            <div className="flex items-center gap-2">
                              <Icon className="h-4 w-4" />
                              {type.docTypNam}
                            </div>
                          </SelectItem>
                        );
                      })}
                  </SelectContent>
                </Select>
              </div>

              <div className="space-y-2">
                <Label>Proyecto (opcional)</Label>
                <Select value={projectId || 'none'} onValueChange={(val) => setProjectId(val === 'none' ? '' : val)}>
                  <SelectTrigger className="bg-background border-input">
                    <SelectValue placeholder="Sin proyecto" />
                  </SelectTrigger>
                  <SelectContent className="bg-card border-border">
                    <SelectItem value="none">Sin proyecto</SelectItem>
                    {projectsData?.projects?.map((project) => (
                      <SelectItem
                        key={`${project.proYea}-${project.proCod}`}
                        value={`${project.proYea}-${project.proCod}`}
                        className="truncate"
                      >
                        <span className="truncate" title={project.proNam}>
                          {project.proNam}
                        </span>
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
            </div>

            <div className="space-y-2">
              <Label>Descripción (opcional)</Label>
              <Textarea
                value={docDes}
                onChange={(e) => setDocDes(e.target.value)}
                placeholder="Descripción del documento..."
                className="bg-background border-input resize-none"
                rows={2}
              />
            </div>
          </div>
        </div>

        <DialogFooter className="pt-4">
          <Button
            type="button"
            variant="outline"
            onClick={handleClose}
            className="border-input"
          >
            Cancelar
          </Button>
          <Button
            onClick={handleSubmit}
            disabled={!file || !docTyp || uploadMutation.isPending}
            className="bg-primary hover:bg-primary/90"
          >
            {uploadMutation.isPending && (
              <Loader2 className="mr-2 h-4 w-4 animate-spin" />
            )}
            Subir documento
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
