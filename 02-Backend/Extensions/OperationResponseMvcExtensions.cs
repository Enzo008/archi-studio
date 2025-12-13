// *****************************************************************************************************
// Descripción       : Extensiones MVC para OperationResponse
// Creado por        : Enzo Gago Aguirre
// Fecha de Creación : 22/07/2025
// Acción a Realizar : Proporcionar métodos de extensión MVC para OperationResponse
// *****************************************************************************************************

using Microsoft.AspNetCore.Mvc;
using Helper;

namespace archi_studio.server.Extensions
{
    /// <summary>
    /// Extensiones MVC para convertir OperationResponse a ActionResult
    /// </summary>
    public static class OperationResponseMvcExtensions
    {
        /// <summary>
        /// Convierte un OperationResponse a un ActionResult con el código de estado HTTP apropiado
        /// </summary>
        /// <typeparam name="T">Tipo de datos del ActionResult</typeparam>
        /// <param name="response">OperationResponse a convertir</param>
        /// <returns>ActionResult con el código de estado HTTP apropiado</returns>
        public static ActionResult<T> ToActionResult<T>(this OperationResponse response)
        {
            // Usar la extensión GetHttpStatusCode de Helper
            int statusCode = response.GetHttpStatusCode();
            
            // Crear el ActionResult apropiado según el código de estado
            return statusCode switch
            {
                400 => new BadRequestObjectResult(response),
                409 => new ConflictObjectResult(response),
                _ => new OkObjectResult(response)
            };
        }

        /// <summary>
        /// Convierte un OperationResponse a un ActionResult con el código de estado HTTP apropiado
        /// </summary>
        /// <param name="response">OperationResponse a convertir</param>
        /// <returns>ActionResult con el código de estado HTTP apropiado</returns>
        public static ActionResult ToActionResult(this OperationResponse response)
        {
            // Usar la extensión GetHttpStatusCode de Helper
            int statusCode = response.GetHttpStatusCode();
            
            // Crear el ActionResult apropiado según el código de estado
            return statusCode switch
            {
                400 => new BadRequestObjectResult(response),
                409 => new ConflictObjectResult(response),
                _ => new OkObjectResult(response)
            };
        }
    }
}