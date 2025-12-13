// *****************************************************************************************************
// Description       : Client Controller
// Created by        : Enzo Gago Aguirre
// Creation Date     : 09/12/2025
// Purpose           : CRUD operations for clients
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
    public class ClientController : BaseController
    {
        private readonly IClientRepository _clientRepo;
        private readonly LogHelper _logHelper;

        // Constructor using proper Dependency Injection (DIP principle)
        public ClientController(IClientRepository clientRepo, LogHelper logHelper)
        {
            _clientRepo = clientRepo;
            _logHelper = logHelper;
        }

        /// <summary>
        /// Get all clients with pagination
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<ApiResponse>> GetAll(
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 10,
            [FromQuery] string? search = null,
            [FromQuery] string? type = null,
            [FromQuery] char? status = null)
        {
            try
            {
                var bLog = await _logHelper.CreateLogFromTokenAsync(HttpContext);
                var bClient = new Client
                {
                    PageNumber = page,
                    PageSize = pageSize,
                    CliNam = search,
                    CliTyp = type,
                    CliSta = status,
                    // Multi-tenancy: filter by user unless admin (RolCod='01')
                    UseYea = bLog.RolCod == "01" ? null : bLog.UseYea,
                    UseCod = bLog.RolCod == "01" ? null : bLog.UseCod
                };
                var response = await _clientRepo.GetAll(bClient, bLog);
                return FromOperationResponse<ApiResponse>(response);
            }
            catch (Exception ex)
            {
                return HandleException<ApiResponse>(ex);
            }
        }

        /// <summary>
        /// Get client by ID
        /// </summary>
        [HttpGet("{cliYea}/{cliCod}")]
        public async Task<ActionResult<ApiResponse>> GetById(string cliYea, string cliCod)
        {
            try
            {
                var bLog = await _logHelper.CreateLogFromTokenAsync(HttpContext);
                var response = await _clientRepo.GetById(cliYea, cliCod, bLog);
                return FromOperationResponse<ApiResponse>(response);
            }
            catch (Exception ex)
            {
                return HandleException<ApiResponse>(ex);
            }
        }

        /// <summary>
        /// Create a new client
        /// </summary>
        [HttpPost]
        public async Task<ActionResult<ApiResponse>> Create([FromBody] Client bClient)
        {
            try
            {
                var bLog = await _logHelper.CreateLogFromTokenAsync(HttpContext);
                var response = await _clientRepo.Create(bClient, bLog);
                return FromOperationResponse<ApiResponse>(response);
            }
            catch (Exception ex)
            {
                return HandleException<ApiResponse>(ex);
            }
        }

        /// <summary>
        /// Update an existing client
        /// </summary>
        [HttpPut]
        public async Task<ActionResult<ApiResponse>> Update([FromBody] Client bClient)
        {
            try
            {
                var bLog = await _logHelper.CreateLogFromTokenAsync(HttpContext);
                var response = await _clientRepo.Update(bClient, bLog);
                return FromOperationResponse<ApiResponse>(response);
            }
            catch (Exception ex)
            {
                return HandleException<ApiResponse>(ex);
            }
        }

        /// <summary>
        /// Delete a client
        /// </summary>
        [HttpDelete("{cliYea}/{cliCod}")]
        public async Task<ActionResult<ApiResponse>> Delete(string cliYea, string cliCod)
        {
            try
            {
                var bLog = await _logHelper.CreateLogFromTokenAsync(HttpContext);
                var response = await _clientRepo.Delete(cliYea, cliCod, bLog);
                return FromOperationResponse<ApiResponse>(response);
            }
            catch (Exception ex)
            {
                return HandleException<ApiResponse>(ex);
            }
        }
    }
}
