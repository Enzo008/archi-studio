// *****************************************************************************************************
// Descripción       : Definición de tipos y enumeraciones comunes para el sistema
// Creado por        : Enzo Gago Aguirre
// Fecha de Creación : 10/02/2025
// Acción a Realizar : Proporcionar tipos de datos enumerados para mensajes, almacenamiento y operaciones
// *****************************************************************************************************

namespace Helper
{
    /// <summary>
    /// Clase estática que contiene enumeraciones y tipos comunes utilizados en todo el sistema
    /// </summary>
    public static class Types
    {
        /// <summary>
        /// Define los tipos de mensajes para las respuestas del sistema
        /// </summary>
        /// <remarks>
        /// Estos tipos de mensajes se utilizan para categorizar las respuestas del sistema
        /// y determinar cómo deben ser presentadas al usuario o procesadas por el cliente.
        /// </remarks>
        public enum MessageType
        {
            /// <summary>
            /// Mensajes de error que indican un problema que impidió completar la operación
            /// </summary>
            Error = 1,
            
            /// <summary>
            /// Mensajes de advertencia que indican un problema potencial pero no crítico
            /// </summary>
            Warning = 2,
            
            /// <summary>
            /// Mensajes de éxito que indican que la operación se completó correctamente
            /// </summary>
            Success = 3,
            
            /// <summary>
            /// Mensajes informativos que proporcionan datos adicionales sin indicar éxito o fracaso
            /// </summary>
            Information = 4
        }

        /// <summary>
        /// Define las unidades de almacenamiento para el manejo de datos
        /// </summary>
        /// <remarks>
        /// Estas unidades se utilizan para representar tamaños de archivos y datos
        /// en diferentes escalas, desde bytes hasta yottabytes.
        /// </remarks>
        public enum UnitStorageType
        {
            /// <summary>
            /// Unidad básica de almacenamiento (1 byte = 8 bits)
            /// </summary>
            Bytes = 1,
            
            /// <summary>
            /// 1 KB = 1024 bytes
            /// </summary>
            KiloBytes = 2,
            
            /// <summary>
            /// 1 MB = 1024 KB
            /// </summary>
            MegaBytes = 3,
            
            /// <summary>
            /// 1 GB = 1024 MB
            /// </summary>
            GigaBytes = 4,
            
            /// <summary>
            /// 1 TB = 1024 GB
            /// </summary>
            TeraBytes = 5,
            
            /// <summary>
            /// 1 PB = 1024 TB
            /// </summary>
            PetaBytes = 6,
            
            /// <summary>
            /// 1 EB = 1024 PB
            /// </summary>
            ExaBytes = 7,
            
            /// <summary>
            /// 1 ZB = 1024 EB
            /// </summary>
            ZettaBytes = 8,
            
            /// <summary>
            /// 1 YB = 1024 ZB
            /// </summary>
            YottaBytes = 9
        }

        /// <summary>
        /// Define los tipos de operaciones para transacciones en la base de datos
        /// </summary>
        /// <remarks>
        /// Estas operaciones representan las acciones CRUD (Create, Read, Update, Delete)
        /// que se pueden realizar en la base de datos.
        /// </remarks>
        public enum OperationType
        {
            /// <summary>
            /// Operación de consulta (Read)
            /// </summary>
            Query,
            
            /// <summary>
            /// Operación de inserción (Create)
            /// </summary>
            Insert,
            
            /// <summary>
            /// Operación de actualización (Update)
            /// </summary>
            Update,
            
            /// <summary>
            /// Operación de eliminación (Delete)
            /// </summary>
            Delete
        }
    }
}