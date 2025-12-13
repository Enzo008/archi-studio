// *****************************************************************************************************
// Description       : Document Controller
// Created by        : Enzo Gago Aguirre
// Creation Date     : 09/12/2025
// Purpose           : CRUD operations for documents
// *****************************************************************************************************

using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using archi_studio.server.Data.Interfaces;
using archi_studio.server.Models;
using archi_studio.server.Data.Helper;
using archi_studio.server.Controllers.Base;

namespace archi_studio.server.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class DocumentController : BaseController
    {
        private readonly IDocumentRepository _documentRepo;
        private readonly LogHelper _logHelper;
        private readonly IConfiguration _configuration;
        private readonly string _uploadsPath;

        // Extensiones permitidas por tipo de documento
        private static readonly Dictionary<string, string[]> AllowedExtensions = new()
        {
            { "01", new[] { ".pdf", ".doc", ".docx", ".xls", ".xlsx" } }, // Documentos
            { "02", new[] { ".jpg", ".jpeg", ".png", ".gif", ".webp" } }, // Imágenes
            { "03", new[] { ".dwg", ".dxf", ".rvt", ".skp" } },          // Planos CAD
            { "04", new[] { ".jpg", ".jpeg", ".png", ".psd", ".tiff" } }, // Renders
            { "05", new[] { ".pdf", ".jpg", ".png" } },                  // Contratos
        };

        private const long MaxFileSize = 50 * 1024 * 1024; // 50MB

        // Constructor using proper Dependency Injection (DIP principle)
        public DocumentController(IDocumentRepository documentRepo, LogHelper logHelper, IConfiguration configuration)
        {
            _documentRepo = documentRepo;
            _logHelper = logHelper;
            _configuration = configuration;
            
            // Configurar ruta de uploads
            _uploadsPath = configuration["FileStorage:Path"] ?? Path.Combine(Directory.GetCurrentDirectory(), "uploads");
            if (!Directory.Exists(_uploadsPath))
            {
                Directory.CreateDirectory(_uploadsPath);
            }
        }

        /// <summary>
        /// Get all documents with pagination
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<ApiResponse>> GetAll(
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 10,
            [FromQuery] string? search = null,
            [FromQuery] string? type = null,
            [FromQuery] char? status = null,
            [FromQuery] string? proYea = null,
            [FromQuery] string? proCod = null)
        {
            try
            {
                var bLog = await _logHelper.CreateLogFromTokenAsync(HttpContext);
                var bDocument = new Document
                {
                    PageNumber = page,
                    PageSize = pageSize,
                    DocNam = search,
                    DocTyp = type,
                    DocSta = status,
                    ProYea = proYea,
                    ProCod = proCod,
                    // Multi-tenancy: filter by user unless admin (RolCod='01')
                    UseYea = bLog.RolCod == "01" ? null : bLog.UseYea,
                    UseCod = bLog.RolCod == "01" ? null : bLog.UseCod
                };
                var response = await _documentRepo.GetAll(bDocument, bLog);
                return FromOperationResponse<ApiResponse>(response);
            }
            catch (Exception ex)
            {
                return HandleException<ApiResponse>(ex);
            }
        }

        /// <summary>
        /// Get document by ID
        /// </summary>
        [HttpGet("{docYea}/{docCod}")]
        public async Task<ActionResult<ApiResponse>> GetById(string docYea, string docCod)
        {
            try
            {
                var bLog = await _logHelper.CreateLogFromTokenAsync(HttpContext);
                var response = await _documentRepo.GetById(docYea, docCod, bLog);
                return FromOperationResponse<ApiResponse>(response);
            }
            catch (Exception ex)
            {
                return HandleException<ApiResponse>(ex);
            }
        }

        /// <summary>
        /// Create a new document record
        /// </summary>
        [HttpPost]
        public async Task<ActionResult<ApiResponse>> Create([FromBody] Document bDocument)
        {
            try
            {
                var bLog = await _logHelper.CreateLogFromTokenAsync(HttpContext);
                var response = await _documentRepo.Create(bDocument, bLog);
                return FromOperationResponse<ApiResponse>(response);
            }
            catch (Exception ex)
            {
                return HandleException<ApiResponse>(ex);
            }
        }

        /// <summary>
        /// Update an existing document
        /// </summary>
        [HttpPut]
        public async Task<ActionResult<ApiResponse>> Update([FromBody] Document bDocument)
        {
            try
            {
                var bLog = await _logHelper.CreateLogFromTokenAsync(HttpContext);
                var response = await _documentRepo.Update(bDocument, bLog);
                return FromOperationResponse<ApiResponse>(response);
            }
            catch (Exception ex)
            {
                return HandleException<ApiResponse>(ex);
            }
        }

        /// <summary>
        /// Delete a document
        /// </summary>
        [HttpDelete("{docYea}/{docCod}")]
        public async Task<ActionResult<ApiResponse>> Delete(string docYea, string docCod)
        {
            try
            {
                var bLog = await _logHelper.CreateLogFromTokenAsync(HttpContext);
                var response = await _documentRepo.Delete(docYea, docCod, bLog);
                return FromOperationResponse<ApiResponse>(response);
            }
            catch (Exception ex)
            {
                return HandleException<ApiResponse>(ex);
            }
        }

        /// <summary>
        /// Get document types catalog
        /// </summary>
        [HttpGet("types")]
        public async Task<ActionResult<ApiResponse>> GetTypes()
        {
            try
            {
                var types = await _documentRepo.GetTypes();
                return Success<ApiResponse>("Catálogo de tipos obtenido", types);
            }
            catch (Exception ex)
            {
                return HandleException<ApiResponse>(ex);
            }
        }

        /// <summary>
        /// Upload a new document file
        /// </summary>
        [HttpPost("upload")]
        [RequestSizeLimit(MaxFileSize)]
        public async Task<ActionResult<ApiResponse>> Upload(
            IFormFile file,
            [FromForm] string? docNam,
            [FromForm] string? docDes,
            [FromForm] string docTyp,
            [FromForm] string? proYea,
            [FromForm] string? proCod)
        {
            try
            {
                // Validar archivo
                if (file == null || file.Length == 0)
                {
                    return Error<ApiResponse>("No se proporcionó ningún archivo");
                }

                if (file.Length > MaxFileSize)
                {
                    return Error<ApiResponse>($"El archivo excede el tamaño máximo permitido ({MaxFileSize / 1024 / 1024}MB)");
                }

                // Validar extensión
                var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
                if (!IsValidExtension(docTyp, extension))
                {
                    return Error<ApiResponse>($"Extensión '{extension}' no permitida para este tipo de documento");
                }

                // Generar nombre único y ruta
                var fileName = $"{Guid.NewGuid()}{extension}";
                var yearFolder = DateTime.Now.Year.ToString();
                var typeFolder = docTyp;
                var relativePath = Path.Combine(yearFolder, typeFolder);
                var fullPath = Path.Combine(_uploadsPath, relativePath);
                
                // Crear directorio si no existe
                if (!Directory.Exists(fullPath))
                {
                    Directory.CreateDirectory(fullPath);
                }

                var filePath = Path.Combine(fullPath, fileName);
                var relativeFilePath = Path.Combine(relativePath, fileName);

                // Guardar archivo
                using (var stream = new FileStream(filePath, FileMode.Create))
                {
                    await file.CopyToAsync(stream);
                }

                // Crear registro en BD
                var bLog = await _logHelper.CreateLogFromTokenAsync(HttpContext);
                var document = new Document
                {
                    DocNam = docNam ?? Path.GetFileNameWithoutExtension(file.FileName),
                    DocDes = docDes,
                    DocTyp = docTyp,
                    DocPat = relativeFilePath.Replace("\\", "/"),
                    DocFil = file.FileName,
                    DocSiz = file.Length,
                    DocMim = file.ContentType,
                    DocSta = 'A',
                    ProYea = proYea,
                    ProCod = proCod
                };

                var response = await _documentRepo.Create(document, bLog);
                return FromOperationResponse<ApiResponse>(response);
            }
            catch (Exception ex)
            {
                return HandleException<ApiResponse>(ex);
            }
        }

        /// <summary>
        /// Download a document file
        /// </summary>
        [HttpGet("download/{docYea}/{docCod}")]
        public async Task<IActionResult> Download(string docYea, string docCod)
        {
            try
            {
                var bLog = await _logHelper.CreateLogFromTokenAsync(HttpContext);
                var response = await _documentRepo.GetById(docYea, docCod, bLog);
                
                if (!response.Success || response.Data == null)
                {
                    return NotFound(new ApiResponse { Success = false, Message = "Documento no encontrado" });
                }

                var document = response.Data as Document;
                if (document == null || string.IsNullOrEmpty(document.DocPat))
                {
                    return NotFound(new ApiResponse { Success = false, Message = "Archivo no encontrado" });
                }

                var filePath = Path.Combine(_uploadsPath, document.DocPat.Replace("/", Path.DirectorySeparatorChar.ToString()));
                
                if (!System.IO.File.Exists(filePath))
                {
                    return NotFound(new ApiResponse { Success = false, Message = "El archivo físico no existe" });
                }

                var memory = new MemoryStream();
                using (var stream = new FileStream(filePath, FileMode.Open, FileAccess.Read))
                {
                    await stream.CopyToAsync(memory);
                }
                memory.Position = 0;

                var contentType = document.DocMim ?? "application/octet-stream";
                var downloadName = document.DocFil ?? $"document{Path.GetExtension(document.DocPat)}";

                return File(memory, contentType, downloadName);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new ApiResponse { Success = false, Message = ex.Message });
            }
        }

        /// <summary>
        /// Get file preview (for images)
        /// </summary>
        [HttpGet("preview/{docYea}/{docCod}")]
        public async Task<IActionResult> Preview(string docYea, string docCod)
        {
            try
            {
                var bLog = await _logHelper.CreateLogFromTokenAsync(HttpContext);
                var response = await _documentRepo.GetById(docYea, docCod, bLog);
                
                if (!response.Success || response.Data == null)
                {
                    return NotFound();
                }

                var document = response.Data as Document;
                if (document == null || string.IsNullOrEmpty(document.DocPat))
                {
                    return NotFound();
                }

                var filePath = Path.Combine(_uploadsPath, document.DocPat.Replace("/", Path.DirectorySeparatorChar.ToString()));
                
                if (!System.IO.File.Exists(filePath))
                {
                    return NotFound();
                }

                var contentType = document.DocMim ?? "application/octet-stream";
                
                // Solo permitir preview de imágenes y PDFs
                var allowedPreviewTypes = new[] { "image/", "application/pdf" };
                if (!allowedPreviewTypes.Any(t => contentType.StartsWith(t)))
                {
                    return BadRequest("Preview no disponible para este tipo de archivo");
                }

                var fileStream = new FileStream(filePath, FileMode.Open, FileAccess.Read);
                return File(fileStream, contentType);
            }
            catch
            {
                return NotFound();
            }
        }

        private bool IsValidExtension(string docType, string extension)
        {
            if (AllowedExtensions.TryGetValue(docType, out var extensions))
            {
                return extensions.Contains(extension.ToLowerInvariant());
            }
            // Si no hay restricción para el tipo, permitir extensiones comunes
            var commonExtensions = new[] { ".pdf", ".doc", ".docx", ".jpg", ".jpeg", ".png" };
            return commonExtensions.Contains(extension.ToLowerInvariant());
        }
    }
}
