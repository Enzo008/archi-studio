// *****************************************************************************************************
// Descripción       : Clase de ayuda para la creación de los atributos de los logs según el token
// Creado por        : Enzo Gago Aguirre
// Fecha de Creación : 10/02/2025
// Updated           : 24/12/2025 - Refactored to use cached UserContext (no DB query per request)
// Acción a Realizar : Crear un log según el UserContext cacheado en HttpContext.Items
// *****************************************************************************************************

// Modelos
using archi_studio.server.Models;
// Libreria Helper
using static Helper.CommonHelper;

namespace archi_studio.server.Data.Helper
{
    public class LogHelper
    {
        /// <summary>
        /// Creates a Log object from cached UserContext in HttpContext.Items.
        /// NO database query is made - data comes from UserContextMiddleware cache.
        /// </summary>
        public async Task<Log> CreateLogFromTokenAsync(HttpContext clsHttpContext)
        {
            // Obtener la IP del cliente
            var strClientIp = await GetPublicIpAddressAsync();

            // Try to get cached UserContext from middleware
            var userContext = clsHttpContext.Items["UserContext"] as UserContext;

            if (userContext?.IsValid == true)
            {
                // Use cached user data - NO DB QUERY
                return new Log
                {
                    LogIpMac = strClientIp,
                    UseYea = userContext.UseYea ?? DateTime.Now.Year.ToString(),
                    UseCod = userContext.UseCod ?? "SYSTEM",
                    UseNam = userContext.UseNam ?? "SYSTEM",
                    UseLas = userContext.UseLas ?? "SYSTEM",
                    RolCod = userContext.RolCod ?? "02"
                };
            }

            // Fallback to SYSTEM if no cached context (should rarely happen)
            return CreateSystemLog(strClientIp);
        }

        private static Log CreateSystemLog(string clientIp)
        {
            return new Log
            {
                LogIpMac = clientIp,
                UseYea = DateTime.Now.Year.ToString(),
                UseCod = "SYSTEM",
                UseNam = "SYSTEM",
                UseLas = "SYSTEM",
                RolCod = "02"
            };
        }
    }
}
