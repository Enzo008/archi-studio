// *****************************************************************************************************
// Descripción       : Clase de ayuda para la creación de los atributos de los logs según el token
// Creado por        : Enzo Gago Aguirre
// Fecha de Creación : 10/02/2025
// Acción a Realizar : Crear un log según el token
// *****************************************************************************************************

// Modelos
using archi_studio.server.Models;
// Libreria Helper
using static Helper.CommonHelper;

namespace archi_studio.server.Data.Helper
{
    public class LogHelper
    {
        public async Task<Log> CreateLogFromTokenAsync(HttpContext clsHttpContext)
        {
            // Declaración de variables
            var clsUser = clsHttpContext.User;
            var strClientIp = await GetPublicIpAddressAsync();

            return new Log
            {
                LogIpMac = strClientIp,
                UseYea = clsUser.FindFirst("USEYEA")?.Value ?? DateTime.Now.Year.ToString(),
                UseCod = clsUser.FindFirst("USECOD")?.Value ?? "SYSTEM",
                UseNam = clsUser.FindFirst("USENAM")?.Value ?? "SYSTEM",
                UseLas = clsUser.FindFirst("USELAS")?.Value ?? "SYSTEM",
                RolCod = clsUser.FindFirst("ROLCOD")?.Value ?? "02" // Default to User role
            };
        }
    }
}
