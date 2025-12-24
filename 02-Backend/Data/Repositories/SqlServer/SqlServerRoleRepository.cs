// *****************************************************************************************************
// Descripcion       : Repositorio de roles para SQL Server
// Creado por        : Enzo Gago Aguirre
// Fecha de Creacion : 10/02/2025
// Updated           : 17/12/2025 - Standardized with new SP names
// Accion a Realizar : CRUD de roles
// *****************************************************************************************************

using archi_studio.server.Data.Interfaces;
using archi_studio.server.Models;
using Microsoft.Data.SqlClient;
using System.Data;
using static Helper.SqlHelper;
using static Helper.Types;
using static Helper.BaseDAO;
using static Helper.CommonHelper;
using Helper;

namespace archi_studio.server.Data.Repositories.SqlServer
{
    public class SqlServerRoleRepository : BaseDAO, IRoleRepository
    {
        private readonly string _connectionString;
        private readonly SqlServerLogRepository _logRepo;

        public SqlServerRoleRepository(string connectionString)
        {
            _connectionString = connectionString;
            _logRepo = new SqlServerLogRepository();
        }

        public async Task<OperationResponse> Search(Log bLog)
        {
            var dtsDatos = new DataSet();
            var parameters = CreateParameters();

            try
            {
                var logParameters = _logRepo.AgregarParametrosLog(parameters.ToArray(), bLog, OperationType.Query);

                if (await GetDataSetAsync("SP_ROLE_SEARCH", CommandType.StoredProcedure,
                    _connectionString, logParameters, dtsDatos))
                {
                    var roles = DeserializeDataSet<List<Role>>(dtsDatos) ?? new List<Role>();
                    return CreateResponseFromParameters(logParameters.ToList(), roles);
                }
                return CreateErrorResponse("Error al obtener roles");
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
            finally
            {
                dtsDatos.Dispose();
            }
        }

        public async Task<List<Menu>> GetMenusByRole(string rolCod, Log bLog)
        {
            var dtsDatos = new DataSet();
            var parameters = CreateParameters();

            try
            {
                AddParameter(parameters, "@P_ROLCOD", rolCod);
                var logParameters = _logRepo.AgregarParametrosLog(parameters.ToArray(), bLog, OperationType.Query);

                if (await GetDataSetAsync("SP_MENU_SEARCH", CommandType.StoredProcedure,
                    _connectionString, logParameters, dtsDatos))
                {
                    return DeserializeDataSet<List<Menu>>(dtsDatos) ?? new List<Menu>();
                }
                return new List<Menu>();
            }
            catch
            {
                return new List<Menu>();
            }
            finally
            {
                dtsDatos.Dispose();
            }
        }

        public async Task<OperationResponse> Save(Role role, Log bLog)
        {
            var parameters = CreateParameters();

            try
            {
                AddParameter(parameters, "@P_ROLCOD", role.RolCod);
                AddParameter(parameters, "@P_ROLNAM", role.RolNam);
                AddParameter(parameters, "@P_ROLDES", role.RolDes);
                
                // Output parameters
                AddOutputParameter(parameters, "@P_MESSAGE_DESCRIPTION", SqlDbType.NVarChar, 500);
                AddOutputParameter(parameters, "@P_MESSAGE_TYPE", SqlDbType.Int);
                
                var logParameters = _logRepo.AgregarParametrosLog(parameters.ToArray(), bLog, OperationType.Insert);

                if (await ExecuteTransactionAsync("SP_ROLE_SAVE", CommandType.StoredProcedure,
                    _connectionString, logParameters))
                {
                    return CreateResponseFromParameters(logParameters.ToList(), role);
                }
                return CreateErrorResponse("Error al guardar rol");
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }

        public async Task<OperationResponse> Delete(string rolCod, Log bLog)
        {
            var parameters = CreateParameters();

            try
            {
                AddParameter(parameters, "@P_ROLCOD", rolCod);
                
                // Output parameters
                AddOutputParameter(parameters, "@P_MESSAGE_DESCRIPTION", SqlDbType.NVarChar, 500);
                AddOutputParameter(parameters, "@P_MESSAGE_TYPE", SqlDbType.Int);
                
                var logParameters = _logRepo.AgregarParametrosLog(parameters.ToArray(), bLog, OperationType.Delete);

                if (await ExecuteTransactionAsync("SP_ROLE_DELETE", CommandType.StoredProcedure,
                    _connectionString, logParameters))
                {
                    return CreateResponseFromParameters(logParameters.ToList(), null);
                }
                return CreateErrorResponse("Error al eliminar rol");
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }
    }
}
