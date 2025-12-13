// *****************************************************************************************************
// Descripcion       : User Controller
// Creado por        : Enzo Gago Aguirre
// Fecha de Creacion : 10/02/2025
// Accion a Realizar : Gestion de usuarios y sincronizacion con Clerk
// *****************************************************************************************************

using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using archi_studio.server.Data.Interfaces;
using archi_studio.server.Models;
using archi_studio.server.Data.Helper;
using archi_studio.server.Controllers.Base;
using static Helper.Types;
using Helper;

namespace archi_studio.server.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class UserController : BaseController
    {
        private readonly IUserRepository _userRepo;
        private readonly LogHelper _logHelper;

        // Constructor using proper Dependency Injection (DIP principle)
        public UserController(IUserRepository userRepo, LogHelper logHelper)
        {
            _userRepo = userRepo;
            _logHelper = logHelper;
        }

        /// <summary>
        /// Sincroniza usuario desde Clerk. Crea si no existe, actualiza ultimo acceso si existe.
        /// </summary>
        [HttpPost("sync")]
        public async Task<ActionResult<ApiResponse>> Sync([FromBody] SyncUserRequest request)
        {
            try
            {
                var bLog = await _logHelper.CreateLogFromTokenAsync(HttpContext);
                var response = await _userRepo.SyncFromClerk(request, bLog);
                
                return response.MessageType == MessageType.Success
                    ? Ok(new ApiResponse(true, response.Message ?? "Usuario sincronizado", "Success", response.Data))
                    : BadRequest(new ApiResponse(false, response.Message ?? "Error al sincronizar", "Error", null));
            }
            catch (Exception ex)
            {
                return HandleException<ApiResponse>(ex);
            }
        }

        /// <summary>
        /// Obtiene todos los usuarios con paginacion
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<ApiResponse>> GetAll([FromQuery] int page = 1, [FromQuery] int pageSize = 10)
        {
            try
            {
                var bLog = await _logHelper.CreateLogFromTokenAsync(HttpContext);
                var bUser = new User { PageNumber = page, PageSize = pageSize };
                var response = await _userRepo.GetAll(bUser, bLog);
                return FromOperationResponse<ApiResponse>(response);
            }
            catch (Exception ex)
            {
                return HandleException<ApiResponse>(ex);
            }
        }

        /// <summary>
        /// Obtiene un usuario por su ID
        /// </summary>
        [HttpGet("{useYea}/{useCod}")]
        public async Task<ActionResult<ApiResponse>> GetById(string useYea, string useCod)
        {
            try
            {
                var bLog = await _logHelper.CreateLogFromTokenAsync(HttpContext);
                var response = await _userRepo.GetById(useYea, useCod, bLog);
                return FromOperationResponse<ApiResponse>(response);
            }
            catch (Exception ex)
            {
                return HandleException<ApiResponse>(ex);
            }
        }

        /// <summary>
        /// Crea un nuevo usuario (uso interno/admin)
        /// </summary>
        [HttpPost]
        public async Task<ActionResult<ApiResponse>> Create([FromBody] User bUser)
        {
            try
            {
                var bLog = await _logHelper.CreateLogFromTokenAsync(HttpContext);
                var response = await _userRepo.Create(bUser, bLog);
                return FromOperationResponse<ApiResponse>(response);
            }
            catch (Exception ex)
            {
                return HandleException<ApiResponse>(ex);
            }
        }

        /// <summary>
        /// Actualiza un usuario existente
        /// </summary>
        [HttpPut]
        public async Task<ActionResult<ApiResponse>> Update([FromBody] User bUser)
        {
            try
            {
                var bLog = await _logHelper.CreateLogFromTokenAsync(HttpContext);
                var response = await _userRepo.Update(bUser, bLog);
                return FromOperationResponse<ApiResponse>(response);
            }
            catch (Exception ex)
            {
                return HandleException<ApiResponse>(ex);
            }
        }

        /// <summary>
        /// Elimina (desactiva) un usuario
        /// </summary>
        [HttpDelete("{useYea}/{useCod}")]
        public async Task<ActionResult<ApiResponse>> Delete(string useYea, string useCod)
        {
            try
            {
                var bLog = await _logHelper.CreateLogFromTokenAsync(HttpContext);
                var response = await _userRepo.Delete(useYea, useCod, bLog);
                return FromOperationResponse<ApiResponse>(response);
            }
            catch (Exception ex)
            {
                return HandleException<ApiResponse>(ex);
            }
        }

    }
}
