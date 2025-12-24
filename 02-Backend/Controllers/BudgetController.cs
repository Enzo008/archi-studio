// *****************************************************************************************************
// Description       : Budget Controller
// Created by        : Enzo Gago Aguirre
// Creation Date     : 09/12/2025
// Purpose           : CRUD operations for budgets and budget items
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
    public class BudgetController : BaseController
    {
        private readonly IBudgetRepository _budgetRepo;
        private readonly LogHelper _logHelper;

        // Constructor using proper Dependency Injection (DIP principle)
        public BudgetController(IBudgetRepository budgetRepo, LogHelper logHelper)
        {
            _budgetRepo = budgetRepo;
            _logHelper = logHelper;
        }

        /// <summary>
        /// Get all budgets with pagination and filters
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<ApiResponse>> GetAll(
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 10,
            [FromQuery] string? search = null,
            [FromQuery] string? status = null,
            [FromQuery] string? proYea = null,
            [FromQuery] string? proCod = null)
        {
            try
            {
                var bLog = await _logHelper.CreateLogFromTokenAsync(HttpContext);
                var bBudget = new Budget
                {
                    PageNumber = page,
                    PageSize = pageSize,
                    BudNam = search,
                    BudSta = status,
                    ProYea = proYea,
                    ProCod = proCod
                };
                var response = await _budgetRepo.Search(bBudget, bLog);
                return FromOperationResponse<ApiResponse>(response);
            }
            catch (Exception ex)
            {
                return HandleException<ApiResponse>(ex);
            }
        }

        /// <summary>
        /// Get budget by ID with items
        /// </summary>
        [HttpGet("{budYea}/{budCod}")]
        public async Task<ActionResult<ApiResponse>> GetById(string budYea, string budCod)
        {
            try
            {
                var bLog = await _logHelper.CreateLogFromTokenAsync(HttpContext);
                var bBudget = new Budget { BudYea = budYea, BudCod = budCod };
                var response = await _budgetRepo.Search(bBudget, bLog);
                return FromOperationResponse<ApiResponse>(response);
            }
            catch (Exception ex)
            {
                return HandleException<ApiResponse>(ex);
            }
        }

        /// <summary>
        /// Create a new budget
        /// </summary>
        [HttpPost]
        public async Task<ActionResult<ApiResponse>> Create([FromBody] Budget bBudget)
        {
            try
            {
                var bLog = await _logHelper.CreateLogFromTokenAsync(HttpContext);
                var response = await _budgetRepo.Create(bBudget, bLog);
                return FromOperationResponse<ApiResponse>(response);
            }
            catch (Exception ex)
            {
                return HandleException<ApiResponse>(ex);
            }
        }

        /// <summary>
        /// Update an existing budget
        /// </summary>
        [HttpPut]
        public async Task<ActionResult<ApiResponse>> Update([FromBody] Budget bBudget)
        {
            try
            {
                var bLog = await _logHelper.CreateLogFromTokenAsync(HttpContext);
                var response = await _budgetRepo.Update(bBudget, bLog);
                return FromOperationResponse<ApiResponse>(response);
            }
            catch (Exception ex)
            {
                return HandleException<ApiResponse>(ex);
            }
        }

        /// <summary>
        /// Delete a budget
        /// </summary>
        [HttpDelete("{budYea}/{budCod}")]
        public async Task<ActionResult<ApiResponse>> Delete(string budYea, string budCod)
        {
            try
            {
                var bLog = await _logHelper.CreateLogFromTokenAsync(HttpContext);
                var response = await _budgetRepo.Delete(budYea, budCod, bLog);
                return FromOperationResponse<ApiResponse>(response);
            }
            catch (Exception ex)
            {
                return HandleException<ApiResponse>(ex);
            }
        }

        /// <summary>
        /// Save (create/update) a budget item
        /// </summary>
        [HttpPost("{budYea}/{budCod}/items")]
        public async Task<ActionResult<ApiResponse>> SaveItem(string budYea, string budCod, [FromBody] BudgetItem bItem)
        {
            try
            {
                var bLog = await _logHelper.CreateLogFromTokenAsync(HttpContext);
                bItem.BudYea = budYea;
                bItem.BudCod = budCod;
                var response = await _budgetRepo.SaveItem(bItem, bLog);
                return FromOperationResponse<ApiResponse>(response);
            }
            catch (Exception ex)
            {
                return HandleException<ApiResponse>(ex);
            }
        }

        /// <summary>
        /// Delete a budget item
        /// </summary>
        [HttpDelete("{budYea}/{budCod}/items/{budIteNum}")]
        public async Task<ActionResult<ApiResponse>> DeleteItem(string budYea, string budCod, int budIteNum)
        {
            try
            {
                var bLog = await _logHelper.CreateLogFromTokenAsync(HttpContext);
                var response = await _budgetRepo.DeleteItem(budYea, budCod, budIteNum, bLog);
                return FromOperationResponse<ApiResponse>(response);
            }
            catch (Exception ex)
            {
                return HandleException<ApiResponse>(ex);
            }
        }

        /// <summary>
        /// Get budget statuses catalog
        /// </summary>
        [HttpGet("statuses")]
        public async Task<ActionResult<ApiResponse>> GetStatuses()
        {
            try
            {
                var statuses = await _budgetRepo.GetStatuses();
                return Success<ApiResponse>("Catálogo de estados obtenido", statuses);
            }
            catch (Exception ex)
            {
                return HandleException<ApiResponse>(ex);
            }
        }

        // =============================================
        // Image Upload for Budget Items
        // =============================================
        
        private const long MaxImageSize = 10 * 1024 * 1024; // 10 MB
        private static readonly string[] AllowedImageExtensions = { ".jpg", ".jpeg", ".png", ".gif", ".webp" };
        private readonly string _uploadsPath = Path.Combine(Directory.GetCurrentDirectory(), "uploads");

        /// <summary>
        /// Upload an image for a budget item
        /// </summary>
        [HttpPost("{budYea}/{budCod}/items/{budIteNum}/image")]
        [RequestSizeLimit(MaxImageSize)]
        public async Task<ActionResult<ApiResponse>> UploadItemImage(
            string budYea, string budCod, int budIteNum, IFormFile file)
        {
            try
            {
                // Validate file
                if (file == null || file.Length == 0)
                {
                    return Error<ApiResponse>("No se proporcionó ningún archivo");
                }

                if (file.Length > MaxImageSize)
                {
                    return Error<ApiResponse>($"La imagen excede el tamaño máximo permitido ({MaxImageSize / 1024 / 1024}MB)");
                }

                var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
                if (!AllowedImageExtensions.Contains(extension))
                {
                    return Error<ApiResponse>($"Extensión '{extension}' no permitida. Use: {string.Join(", ", AllowedImageExtensions)}");
                }

                // Generate file path: budgets/{budYea}/{budCod}/{uuid}.{ext}
                var fileName = $"{Guid.NewGuid()}{extension}";
                var relativePath = Path.Combine("budgets", budYea, budCod);
                var fullPath = Path.Combine(_uploadsPath, relativePath);
                
                // Create directory if not exists
                if (!Directory.Exists(fullPath))
                {
                    Directory.CreateDirectory(fullPath);
                }

                var filePath = Path.Combine(fullPath, fileName);
                var relativeFilePath = Path.Combine(relativePath, fileName).Replace("\\", "/");

                // Save file
                using (var stream = new FileStream(filePath, FileMode.Create))
                {
                    await file.CopyToAsync(stream);
                }

                // Update only image fields (not other item data)
                var bLog = await _logHelper.CreateLogFromTokenAsync(HttpContext);
                var response = await _budgetRepo.UpdateItemImage(
                    budYea, budCod, budIteNum,
                    relativeFilePath, file.FileName, file.Length, file.ContentType,
                    bLog);
                
                if (response.Success)
                {
                    return Success<ApiResponse>("Imagen subida correctamente", new {
                        budIteImgPat = relativeFilePath,
                        budIteImgFil = file.FileName,
                        budIteImgSiz = file.Length,
                        budIteImgMim = file.ContentType
                    });
                }
                
                return FromOperationResponse<ApiResponse>(response);
            }
            catch (Exception ex)
            {
                return HandleException<ApiResponse>(ex);
            }
        }

        /// <summary>
        /// Get budget item image file
        /// </summary>
        [HttpGet("{budYea}/{budCod}/items/{budIteNum}/image")]
        public IActionResult GetItemImage(string budYea, string budCod, int budIteNum, [FromQuery] string path)
        {
            try
            {
                if (string.IsNullOrEmpty(path))
                {
                    return NotFound(new ApiResponse { Success = false, Message = "Path no especificado" });
                }

                var filePath = Path.Combine(_uploadsPath, path.Replace("/", Path.DirectorySeparatorChar.ToString()));
                
                if (!System.IO.File.Exists(filePath))
                {
                    return NotFound(new ApiResponse { Success = false, Message = "Imagen no encontrada" });
                }

                var mimeType = GetMimeType(filePath);
                return PhysicalFile(filePath, mimeType);
            }
            catch
            {
                return NotFound(new ApiResponse { Success = false, Message = "Error al obtener imagen" });
            }
        }

        private static string GetMimeType(string filePath)
        {
            var ext = Path.GetExtension(filePath).ToLowerInvariant();
            return ext switch
            {
                ".jpg" or ".jpeg" => "image/jpeg",
                ".png" => "image/png",
                ".gif" => "image/gif",
                ".webp" => "image/webp",
                _ => "application/octet-stream"
            };
        }
    }
}
