// *****************************************************************************************************
// Description       : Health check endpoint for Docker/Kubernetes
// Created by        : Enzo Gago Aguirre
// Creation Date     : 24/12/2025
// Purpose           : Provides /api/health endpoint for container health checks
// *****************************************************************************************************

using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace archi_studio.server.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class HealthController : ControllerBase
    {
        /// <summary>
        /// Health check endpoint for Docker/Kubernetes probes
        /// </summary>
        [HttpGet]
        [AllowAnonymous]
        public IActionResult Get()
        {
            return Ok(new { status = "healthy", timestamp = DateTime.UtcNow });
        }
    }
}
