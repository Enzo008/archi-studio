// *****************************************************************************************************
// Descripción       : Extensiones para OperationResponse
// Creado por        : Enzo Gago Aguirre
// Fecha de Creación : 22/07/2025
// Acción a Realizar : Proporcionar métodos de extensión para OperationResponse
// *****************************************************************************************************

using System;
using static Helper.Types;

namespace Helper
{
    /// <summary>
    /// Extensiones para OperationResponse
    /// </summary>
    /// <remarks>
    /// Esta clase proporciona métodos de extensión para la clase OperationResponse,
    /// facilitando operaciones comunes como la obtención del código de estado HTTP
    /// y la verificación del tipo de respuesta.
    /// </remarks>
    public static class OperationResponseExtensions
    {
        /// <summary>
        /// Obtiene el código de estado HTTP apropiado según el tipo de mensaje
        /// </summary>
        /// <param name="response">OperationResponse a evaluar</param>
        /// <returns>Código de estado HTTP como entero</returns>
        public static int GetHttpStatusCode(this OperationResponse response)
        {
            // Determinar el código de estado HTTP según el MessageType
            return response.MessageType switch
            {
                MessageType.Error => 400,    // BadRequest
                MessageType.Warning => 409,  // Conflict
                MessageType.Success => 200,  // OK
                MessageType.Information => 200, // OK
                _ => 200, // Default to OK
            };
        }

        /// <summary>
        /// Determina si la respuesta representa un error
        /// </summary>
        /// <param name="response">OperationResponse a evaluar</param>
        /// <returns>True si es un error, False en caso contrario</returns>
        public static bool IsError(this OperationResponse response)
        {
            return response.MessageType == MessageType.Error;
        }

        /// <summary>
        /// Determina si la respuesta representa una advertencia
        /// </summary>
        /// <param name="response">OperationResponse a evaluar</param>
        /// <returns>True si es una advertencia, False en caso contrario</returns>
        public static bool IsWarning(this OperationResponse response)
        {
            return response.MessageType == MessageType.Warning;
        }

        /// <summary>
        /// Determina si la respuesta representa un éxito
        /// </summary>
        /// <param name="response">OperationResponse a evaluar</param>
        /// <returns>True si es un éxito, False en caso contrario</returns>
        public static bool IsSuccess(this OperationResponse response)
        {
            return response.MessageType == MessageType.Success || response.MessageType == MessageType.Information;
        }
    }
}