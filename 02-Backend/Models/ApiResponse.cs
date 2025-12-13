// *****************************************************************************************************
// Descripción       : Modelo para respuestas de operaciones
// Creado por        : Enzo Gago Aguirre
// Fecha de Creación : 19/06/2025
// Acción a Realizar : Definir modelo de respuesta estándar para operaciones
// *****************************************************************************************************

namespace archi_studio.server.Models
{
    /// <summary>
    /// Modelo estándar para respuestas de operaciones
    /// </summary>
    public class ApiResponse
    {
        /// <summary>
        /// Indica si la operación fue exitosa
        /// </summary>
        public bool Success { get; set; }
        
        /// <summary>
        /// Mensaje descriptivo del resultado de la operación
        /// </summary>
        public string Message { get; set; } = string.Empty;
        
        /// <summary>
        /// Tipo de mensaje (Success, Error, Warning, Info)
        /// </summary>
        public string MessageType { get; set; } = "Info";
        
        /// <summary>
        /// Datos adicionales de la operación
        /// </summary>
        public object Data { get; set; } = new object();
        
        /// <summary>
        /// Constructor por defecto
        /// </summary>
        public ApiResponse()
        {
            Message = string.Empty;
            MessageType = "Info";
            Data = new object();
        }
        
        /// <summary>
        /// Constructor con parámetros básicos
        /// </summary>
        public ApiResponse(bool success, string message, string messageType = "Info", object? data = null)
        {
            Success = success;
            Message = message;
            MessageType = messageType;
            Data = data ?? new object();
        }
    }
}
