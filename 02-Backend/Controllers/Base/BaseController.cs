// *****************************************************************************************************
// Descripción       : Controlador base para todos los controladores
// Creado por        : Enzo Gago Aguirre
// Fecha de Creación : 22/07/2025
// Acción a Realizar : Proporcionar funcionalidad común para todos los controladores
// *****************************************************************************************************

using Microsoft.AspNetCore.Mvc;
using archi_studio.server.Models;
using archi_studio.server.Extensions;
using Helper;
using static Helper.Types;

namespace archi_studio.server.Controllers.Base
{
    /// <summary>
    /// Controlador base que proporciona funcionalidad común para todos los controladores
    /// </summary>
    public abstract class BaseController : ControllerBase
    {
        /// <summary>
        /// Maneja una excepción y devuelve un ActionResult con el código de estado HTTP apropiado
        /// </summary>
        /// <typeparam name="T">Tipo de datos del ActionResult</typeparam>
        /// <param name="ex">Excepción a manejar</param>
        /// <param name="customMessage">Mensaje personalizado (opcional)</param>
        /// <returns>ActionResult con el código de estado HTTP apropiado</returns>
        protected ActionResult<T> HandleException<T>(Exception ex, string? customMessage = null)
        {
            var errorResponse = new OperationResponse
            {
                Success = false,
                Message = customMessage ?? ex.Message,
                MessageType = MessageType.Error
            };
            return errorResponse.ToActionResult<T>();
        }

        /// <summary>
        /// Crea un ActionResult a partir de un OperationResponse
        /// </summary>
        /// <typeparam name="T">Tipo de datos del ActionResult</typeparam>
        /// <param name="response">OperationResponse a convertir</param>
        /// <returns>ActionResult con el código de estado HTTP apropiado</returns>
        protected ActionResult<T> FromOperationResponse<T>(OperationResponse response)
        {
            return response.ToActionResult<T>();
        }

        /// <summary>
        /// Crea un ActionResult de éxito con un mensaje personalizado
        /// </summary>
        /// <typeparam name="T">Tipo de datos del ActionResult</typeparam>
        /// <param name="message">Mensaje de éxito</param>
        /// <param name="data">Datos a incluir en la respuesta (opcional)</param>
        /// <returns>ActionResult con código de estado 200 (OK)</returns>
        protected ActionResult<T> Success<T>(string message, object? data = null)
        {
            var response = new OperationResponse
            {
                Success = true,
                Message = message,
                MessageType = MessageType.Success,
                Data = data
            };
            return response.ToActionResult<T>();
        }

        /// <summary>
        /// Crea un ActionResult de error con un mensaje personalizado
        /// </summary>
        /// <typeparam name="T">Tipo de datos del ActionResult</typeparam>
        /// <param name="message">Mensaje de error</param>
        /// <param name="data">Datos a incluir en la respuesta (opcional)</param>
        /// <returns>ActionResult con código de estado 400 (BadRequest)</returns>
        protected ActionResult<T> Error<T>(string message, object? data = null)
        {
            var response = new OperationResponse
            {
                Success = false,
                Message = message,
                MessageType = MessageType.Error,
                Data = data
            };
            return response.ToActionResult<T>();
        }

        /// <summary>
        /// Crea un ActionResult de advertencia con un mensaje personalizado
        /// </summary>
        /// <typeparam name="T">Tipo de datos del ActionResult</typeparam>
        /// <param name="message">Mensaje de advertencia</param>
        /// <param name="data">Datos a incluir en la respuesta (opcional)</param>
        /// <returns>ActionResult con código de estado 409 (Conflict)</returns>
        protected ActionResult<T> Warning<T>(string message, object? data = null)
        {
            var response = new OperationResponse
            {
                Success = false,
                Message = message,
                MessageType = MessageType.Warning,
                Data = data
            };
            return response.ToActionResult<T>();
        }

        /// <summary>
        /// Crea un ActionResult informativo con un mensaje personalizado
        /// </summary>
        /// <typeparam name="T">Tipo de datos del ActionResult</typeparam>
        /// <param name="message">Mensaje informativo</param>
        /// <param name="data">Datos a incluir en la respuesta (opcional)</param>
        /// <returns>ActionResult con código de estado 200 (OK)</returns>
        protected ActionResult<T> Information<T>(string message, object? data = null)
        {
            var response = new OperationResponse
            {
                Success = true,
                Message = message,
                MessageType = MessageType.Information,
                Data = data
            };
            return response.ToActionResult<T>();
        }
    }
}