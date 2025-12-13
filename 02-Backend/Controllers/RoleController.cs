// *****************************************************************************************************
// Descripcion       : Role Controller
// Creado por        : Cascade AI
// Fecha de Creacion : 10/12/2024
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

        // Constructor using proper Dependency Injection (DIP principle)
        public RoleController(IRoleRepository roleRepo, LogHelper logHelper)
        {
            _roleRepo = roleRepo;
            _logHelper = logHelper;
        }

        /// <summary>
        /// Obtiene todos los roles
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<ApiResponse>> GetAll()
        {
            try
            {
                var bLog = await _logHelper.CreateLogFromTokenAsync(HttpContext);
                var response = await _roleRepo.GetAll(bLog);
                
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
                var menus = await _roleRepo.GetMenusByRole(rolCod);
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
        public async Task<ActionResult<ApiResponse>> Upsert([FromBody] Role role)
        {
            try
            {
                var bLog = await _logHelper.CreateLogFromTokenAsync(HttpContext);
                var response = await _roleRepo.Upsert(role, bLog);
                
                return response.MessageType == MessageType.Success
                    ? Ok(new ApiResponse(true, response.Message ?? "Rol guardado", "Success", response.Data))
                    : BadRequest(new ApiResponse(false, response.Message ?? "Error al guardar rol", "Error", null));
            }
            catch (Exception ex)
            {
                return HandleException<ApiResponse>(ex);
            }
        }
    }
}
