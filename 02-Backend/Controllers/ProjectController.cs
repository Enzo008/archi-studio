// *****************************************************************************************************
// Description       : Project Controller
// Created by        : Enzo Gago Aguirre
// Creation Date     : 09/12/2025
// Purpose           : CRUD operations for projects
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
    public class ProjectController : BaseController
    {
        private readonly IProjectRepository _projectRepo;
        private readonly LogHelper _logHelper;

        // Constructor using proper Dependency Injection (DIP principle)
        public ProjectController(IProjectRepository projectRepo, LogHelper logHelper)
        {
            _projectRepo = projectRepo;
            _logHelper = logHelper;
        }

        /// <summary>
        /// Get all projects with pagination
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<ApiResponse>> GetAll(
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 10,
            [FromQuery] string? search = null,
            [FromQuery] string? status = null,
            [FromQuery] string? cliYea = null,
            [FromQuery] string? cliCod = null,
            [FromQuery] string? useYea = null,
            [FromQuery] string? useCod = null)
        {
            try
            {
                var bLog = await _logHelper.CreateLogFromTokenAsync(HttpContext);
                
                // Multi-tenancy: force filter by logged user unless admin (RolCod='01')
                var filterUseYea = bLog.RolCod == "01" ? useYea : bLog.UseYea;
                var filterUseCod = bLog.RolCod == "01" ? useCod : bLog.UseCod;
                
                var bProject = new Project
                {
                    PageNumber = page,
                    PageSize = pageSize,
                    ProNam = search,
                    ProSta = status,
                    CliYea = cliYea,
                    CliCod = cliCod,
                    UseYea = filterUseYea,
                    UseCod = filterUseCod
                };
                var response = await _projectRepo.GetAll(bProject, bLog);
                return FromOperationResponse<ApiResponse>(response);
            }
            catch (Exception ex)
            {
                return HandleException<ApiResponse>(ex);
            }
        }

        /// <summary>
        /// Get project by ID
        /// </summary>
        [HttpGet("{proYea}/{proCod}")]
        public async Task<ActionResult<ApiResponse>> GetById(string proYea, string proCod)
        {
            try
            {
                var bLog = await _logHelper.CreateLogFromTokenAsync(HttpContext);
                var response = await _projectRepo.GetById(proYea, proCod, bLog);
                return FromOperationResponse<ApiResponse>(response);
            }
            catch (Exception ex)
            {
                return HandleException<ApiResponse>(ex);
            }
        }

        /// <summary>
        /// Create a new project
        /// </summary>
        [HttpPost]
        public async Task<ActionResult<ApiResponse>> Create([FromBody] Project bProject)
        {
            try
            {
                var bLog = await _logHelper.CreateLogFromTokenAsync(HttpContext);
                var response = await _projectRepo.Create(bProject, bLog);
                return FromOperationResponse<ApiResponse>(response);
            }
            catch (Exception ex)
            {
                return HandleException<ApiResponse>(ex);
            }
        }

        /// <summary>
        /// Update an existing project
        /// </summary>
        [HttpPut]
        public async Task<ActionResult<ApiResponse>> Update([FromBody] Project bProject)
        {
            try
            {
                var bLog = await _logHelper.CreateLogFromTokenAsync(HttpContext);
                var response = await _projectRepo.Update(bProject, bLog);
                return FromOperationResponse<ApiResponse>(response);
            }
            catch (Exception ex)
            {
                return HandleException<ApiResponse>(ex);
            }
        }

        /// <summary>
        /// Delete a project
        /// </summary>
        [HttpDelete("{proYea}/{proCod}")]
        public async Task<ActionResult<ApiResponse>> Delete(string proYea, string proCod)
        {
            try
            {
                var bLog = await _logHelper.CreateLogFromTokenAsync(HttpContext);
                var response = await _projectRepo.Delete(proYea, proCod, bLog);
                return FromOperationResponse<ApiResponse>(response);
            }
            catch (Exception ex)
            {
                return HandleException<ApiResponse>(ex);
            }
        }

        /// <summary>
        /// Get project statuses catalog
        /// </summary>
        [HttpGet("statuses")]
        public async Task<ActionResult<ApiResponse>> GetStatuses()
        {
            try
            {
                var statuses = await _projectRepo.GetStatuses();
                return Success<ApiResponse>("Catálogo de estados obtenido", statuses);
            }
            catch (Exception ex)
            {
                return HandleException<ApiResponse>(ex);
            }
        }
    }
}
