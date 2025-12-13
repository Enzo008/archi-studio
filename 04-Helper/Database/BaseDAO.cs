// *****************************************************************************************************
// Descripción       : Clase base para todos los DAOs
// Creado por        : Enzo Gago Aguirre
// Fecha de Creación : 22/07/2025
// Acción a Realizar : Proporcionar funcionalidad común para todos los DAOs
// *****************************************************************************************************

using System;
using System.Collections.Generic;
using System.Data;
using Microsoft.Data.SqlClient;
using static Helper.Types;
using static Helper.SqlHelper;
using static Helper.CommonHelper;

namespace Helper
{
    /// <summary>
    /// Clase base que proporciona funcionalidad común para todos los DAOs (Data Access Objects)
    /// </summary>
    /// <remarks>
    /// Esta clase abstracta proporciona métodos comunes para manejar excepciones, crear respuestas
    /// estandarizadas y procesar resultados de operaciones de base de datos.
    /// </remarks>
    /// <example>
    /// Ejemplo de uso:
    /// <code>
    /// public class MyDAO : BaseDAO
    /// {
    ///     public async Task&lt;OperationResponse&gt; GetData(int id)
    ///     {
    ///         try
    ///         {
    ///             // Lógica de acceso a datos
    ///             return CreateSuccessResponse("Datos obtenidos con éxito", data);
    ///         }
    ///         catch (Exception ex)
    ///         {
    ///             return HandleException(ex);
    ///         }
    ///     }
    /// }
    /// </code>
    /// </example>
    public abstract class BaseDAO
    {
        /// <summary>
        /// Maneja una excepción y devuelve un OperationResponse con el mensaje de error
        /// </summary>
        /// <param name="ex">Excepción a manejar</param>
        /// <param name="customMessage">Mensaje personalizado (opcional)</param>
        /// <returns>OperationResponse con el mensaje de error</returns>
        protected OperationResponse HandleException(Exception ex, string? customMessage = null)
        {
            return OperationResponse.CreateError(customMessage ?? ex.Message);
        }

        /// <summary>
        /// Crea un OperationResponse de éxito con un mensaje personalizado
        /// </summary>
        /// <param name="message">Mensaje de éxito</param>
        /// <param name="data">Datos a incluir en la respuesta (opcional)</param>
        /// <returns>OperationResponse con mensaje de éxito</returns>
        protected OperationResponse CreateSuccessResponse(string message, object? data = null)
        {
            return OperationResponse.CreateSuccess(message, data);
        }

        /// <summary>
        /// Crea un OperationResponse de error con un mensaje personalizado
        /// </summary>
        /// <param name="message">Mensaje de error</param>
        /// <param name="data">Datos a incluir en la respuesta (opcional)</param>
        /// <returns>OperationResponse con mensaje de error</returns>
        protected OperationResponse CreateErrorResponse(string message, object? data = null)
        {
            return OperationResponse.CreateError(message, data);
        }

        /// <summary>
        /// Crea un OperationResponse de advertencia con un mensaje personalizado
        /// </summary>
        /// <param name="message">Mensaje de advertencia</param>
        /// <param name="data">Datos a incluir en la respuesta (opcional)</param>
        /// <returns>OperationResponse con mensaje de advertencia</returns>
        protected OperationResponse CreateWarningResponse(string message, object? data = null)
        {
            return OperationResponse.CreateWarning(message, data);
        }

        /// <summary>
        /// Crea un OperationResponse a partir de los parámetros de salida de un procedimiento almacenado
        /// </summary>
        /// <param name="parameters">Lista de parámetros</param>
        /// <param name="data">Datos a incluir en la respuesta (opcional)</param>
        /// <returns>OperationResponse con los valores de los parámetros de salida</returns>
        protected OperationResponse CreateResponseFromParameters(List<SqlParameter> parameters, object? data = null)
        {
            var totalCount = GetOutputParameterValue(parameters, "@P_TOTAL_RECORDS");
            var strMessage = GetOutputParameterValue(parameters, "@P_MESSAGE_DESCRIPTION") ?? "";
            var strMessageType = GetOutputParameterValue(parameters, "@P_MESSAGE_TYPE") ?? "1";
            var messageType = (MessageType)int.Parse(strMessageType);

            return new OperationResponse
            {
                Success = messageType == MessageType.Success,
                Message = strMessage,
                MessageType = messageType,
                Data = data,
                TotalCount = int.Parse(totalCount ?? "0")
            };
        }

        /// <summary>
        /// Procesa el resultado de una operación de base de datos y devuelve un OperationResponse
        /// </summary>
        /// <param name="success">Indica si la operación fue exitosa</param>
        /// <param name="parameters">Lista de parámetros</param>
        /// <param name="data">Datos a incluir en la respuesta (opcional)</param>
        /// <returns>OperationResponse con el resultado de la operación</returns>
        protected OperationResponse ProcessDatabaseResult(bool success, List<SqlParameter> parameters, object? data = null)
        {
            if (success)
            {
                return CreateResponseFromParameters(parameters, data);
            }
            else
            {
                return CreateErrorResponse("Error al ejecutar el procedimiento almacenado");
            }
        }
    }
}