// *****************************************************************************************************
// Descripcion       : Repositorio de logs para SQL Server
// Creado por        : Enzo Gago Aguirre
// Fecha de Creacion : 10/02/2025
// Accion a Realizar : Agregar parametros de auditoria a las operaciones
// *****************************************************************************************************

using Microsoft.Data.SqlClient;
using System.Data;
using archi_studio.server.Models;
using archi_studio.server.Data.Interfaces;
using static Helper.SqlHelper;
using static Helper.Types;

namespace archi_studio.server.Data.Repositories.SqlServer
{
    public class SqlServerLogRepository : ILogRepository
    {
        public SqlParameter[] AgregarParametrosLog(SqlParameter[] parametrosExistentes, Log log, OperationType operationType = OperationType.Query)
        {
            var parameters = CreateParameters();
            parameters.AddRange(parametrosExistentes);

            // Parametros de auditoria basicos
            AddParameter(parameters, "@P_USECRE", log.UseCod ?? "SYSTEM");
            AddParameter(parameters, "@P_ZONCRE", TimeZoneInfo.Local.Id);

            // Parametros de salida estandar
            // if (operationType != OperationType.Query)
            // {
            //     AddOutputParameter(parameters, "@P_STAREC", SqlDbType.Char, 1);
            // }

            if (operationType == OperationType.Query)
            {
                AddOutputParameter(parameters, "@P_TOTAL_RECORDS", SqlDbType.Int);
            }
            
            AddOutputParameter(parameters, "@P_MESSAGE_DESCRIPTION", SqlDbType.VarChar, 500);
            AddOutputParameter(parameters, "@P_MESSAGE_TYPE", SqlDbType.Int);

            return parameters.ToArray();
        }
    }
}
