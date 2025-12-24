// *****************************************************************************************************
// Descripcion       : Role Controller
// Creado por        : Cascade AI
// Fecha de Creacion : 10/12/2024
// Updated           : 17/12/2025 - Standardized with new method names
// Accion a Realizar : Gestion de roles
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
    public class RoleController : BaseController
    {
        private readonly IRoleRepository _roleRepo;
        private readonly LogHelper _logHelper;

        public RoleController(IRoleRepository roleRepo, LogHelper logHelper)
        {
            _roleRepo = roleRepo;
            _logHelper = logHelper;
        }

        /// <summary>
        /// Obtiene todos los roles
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<ApiResponse>> Search()
        {
            try
            {
                var bLog = await _logHelper.CreateLogFromTokenAsync(HttpContext);
                var response = await _roleRepo.Search(bLog);
                
                return response.MessageType == MessageType.Success
                    ? Ok(new ApiResponse(true, response.Message ?? "Roles obtenidos", "Success", response.Data))
                    : BadRequest(new ApiResponse(false, response.Message ?? "Error al obtener roles", "Error", null));
            }
            catch (Exception ex)
            {
                return HandleException<ApiResponse>(ex);
            }
        }

        /// <summary>
        /// Obtiene los menús de un rol específico
        /// </summary>
        [HttpGet("{rolCod}/menus")]
        public async Task<ActionResult<ApiResponse>> GetMenusByRole(string rolCod)
        {
            try
            {
                var bLog = await _logHelper.CreateLogFromTokenAsync(HttpContext);
                var menus = await _roleRepo.GetMenusByRole(rolCod, bLog);
                return Ok(new ApiResponse(true, "Menús obtenidos", "Success", menus));
            }
            catch (Exception ex)
            {
                return HandleException<ApiResponse>(ex);
            }
        }

        /// <summary>
        /// Crea o actualiza un rol
        /// </summary>
        [HttpPost]
        public async Task<ActionResult<ApiResponse>> Save([FromBody] Role role)
        {
            try
            {
                var bLog = await _logHelper.CreateLogFromTokenAsync(HttpContext);
                var response = await _roleRepo.Save(role, bLog);
                
                return response.MessageType == MessageType.Success
                    ? Ok(new ApiResponse(true, response.Message ?? "Rol guardado", "Success", response.Data))
                    : BadRequest(new ApiResponse(false, response.Message ?? "Error al guardar rol", "Error", null));
            }
            catch (Exception ex)
            {
                return HandleException<ApiResponse>(ex);
            }
        }

        /// <summary>
        /// Elimina un rol
        /// </summary>
        [HttpDelete("{rolCod}")]
        public async Task<ActionResult<ApiResponse>> Delete(string rolCod)
        {
            try
            {
                var bLog = await _logHelper.CreateLogFromTokenAsync(HttpContext);
                var response = await _roleRepo.Delete(rolCod, bLog);
                
                return response.MessageType == MessageType.Success
                    ? Ok(new ApiResponse(true, response.Message ?? "Rol eliminado", "Success", null))
                    : BadRequest(new ApiResponse(false, response.Message ?? "Error al eliminar rol", "Error", null));
            }
            catch (Exception ex)
            {
                return HandleException<ApiResponse>(ex);
            }
        }
    }
}
