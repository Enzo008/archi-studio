// *****************************************************************************************************
// Descripción       : Interface ILogRepository
// Creado por        : Enzo Gago Aguirre
// Fecha de Creación : 10/02/2025
// Acción a Realizar : Agregar parametros a un log
// *****************************************************************************************************

// Extensiones
using Microsoft.Data.SqlClient;
// Modelos
using archi_studio.server.Models;
// Libreria Helper
using static Helper.Types;

namespace archi_studio.server.Data.Interfaces
{
    public interface ILogRepository
    {
        SqlParameter[] AgregarParametrosLog(SqlParameter[] parametrosExistentes, Log bLog, OperationType operationType = OperationType.Query);
    }
}
