// *****************************************************************************************************
// Descripción       : Clase base para el manejo de respuestas de operaciones
// Creado por        : Enzo Gago Aguirre
// Fecha de Creación : 10/02/2025
// Acción a Realizar : Proporcionar una estructura estandarizada para las respuestas de operaciones del sistema
// *****************************************************************************************************

using static Helper.Types;

namespace Helper
{
    /// <summary>
    /// Clase que encapsula la respuesta de una operación del sistema
    /// </summary>
    /// <remarks>
    /// Esta clase se utiliza para estandarizar las respuestas de todas las operaciones del sistema,
    /// proporcionando información sobre el éxito o fracaso de la operación, mensajes descriptivos,
    /// y datos adicionales cuando sea necesario.
    /// </remarks>
    /// <example>
    /// Ejemplo de uso:
    /// <code>
    /// var response = new OperationResponse
    /// {
    ///     Success = true,
    ///     Message = "Operación completada con éxito",
    ///     MessageType = MessageType.Success,
    ///     Data = result
    /// };
    /// </code>
    /// </example>
    public class OperationResponse
    {
        /// <summary>
        /// Indica si la operación fue exitosa
        /// </summary>
        public bool Success { get; set; }

        /// <summary>
        /// Tipo de mensaje de la respuesta (Error, Warning, Success, Information)
        /// </summary>
        public MessageType MessageType { get; set; } = MessageType.Information;

        /// <summary>
        /// Mensaje descriptivo de la operación
        /// </summary>
        public string? Message { get; set; }

        /// <summary>
        /// Datos adicionales de la respuesta
        /// </summary>
        public object? Data { get; set; }

        /// <summary>
        /// Cantidad total de registros
        /// </summary>
        public int TotalCount { get; set; }

        /// <summary>
        /// Constructor por defecto
        /// </summary>
        public OperationResponse()
        {
        }

        /// <summary>
        /// Constructor con parámetros básicos
        /// </summary>
        /// <param name="success">Indica si la operación fue exitosa</param>
        /// <param name="message">Mensaje descriptivo</param>
        /// <param name="messageType">Tipo de mensaje</param>
        public OperationResponse(bool success, string message, MessageType messageType)
        {
            Success = success;
            Message = message;
            MessageType = messageType;
        }

        /// <summary>
        /// Constructor completo
        /// </summary>
        /// <param name="success">Indica si la operación fue exitosa</param>
        /// <param name="message">Mensaje descriptivo</param>
        /// <param name="messageType">Tipo de mensaje</param>
        /// <param name="data">Datos adicionales</param>
        /// <param name="totalCount">Cantidad total de registros</param>
        public OperationResponse(bool success, string message, MessageType messageType, object? data, int totalCount)
        {
            Success = success;
            Message = message;
            MessageType = messageType;
            Data = data;
            TotalCount = totalCount;
        }

        /// <summary>
        /// Crea una respuesta de éxito
        /// </summary>
        /// <param name="message">Mensaje descriptivo</param>
        /// <param name="data">Datos adicionales (opcional)</param>
        /// <param name="totalCount">Cantidad total de registros (opcional)</param>
        /// <returns>Respuesta de éxito</returns>
        public static OperationResponse CreateSuccess(string message, object? data = null, int totalCount = 0)
        {
            return new OperationResponse
            {
                Success = true,
                Message = message,
                MessageType = MessageType.Success,
                Data = data,
                TotalCount = totalCount
            };
        }

        /// <summary>
        /// Crea una respuesta de error
        /// </summary>
        /// <param name="message">Mensaje de error</param>
        /// <param name="data">Datos adicionales (opcional)</param>
        /// <param name="totalCount">Cantidad total de registros (opcional)</param>
        /// <returns>Respuesta de error</returns>
        public static OperationResponse CreateError(string message, object? data = null, int totalCount = 0)
        {
            return new OperationResponse
            {
                Success = false,
                Message = message,
                MessageType = MessageType.Error,
                Data = data,
                TotalCount = totalCount
            };
        }

        /// <summary>
        /// Crea una respuesta de advertencia
        /// </summary>
        /// <param name="message">Mensaje de advertencia</param>
        /// <param name="data">Datos adicionales (opcional)</param>
        /// <param name="totalCount">Cantidad total de registros (opcional)</param>
        /// <returns>Respuesta de advertencia</returns>
        public static OperationResponse CreateWarning(string message, object? data = null, int totalCount = 0)
        {
            return new OperationResponse
            {
                Success = false,
                Message = message,
                MessageType = MessageType.Warning,
                Data = data,
                TotalCount = totalCount
            };
        }

        /// <summary>
        /// Crea una respuesta informativa
        /// </summary>
        /// <param name="message">Mensaje informativo</param>
        /// <param name="data">Datos adicionales (opcional)</param>
        /// <param name="totalCount">Cantidad total de registros (opcional)</param>
        /// <returns>Respuesta informativa</returns>
        public static OperationResponse CreateInformation(string message, object? data = null, int totalCount = 0)
        {
            return new OperationResponse
            {
                Success = true,
                Message = message,
                MessageType = MessageType.Information,
                Data = data,
                TotalCount = totalCount
            };
        }
    }
}