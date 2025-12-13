// *****************************************************************************************************
// Descripcion       : Repositorio de roles para SQL Server
// Creado por        : Enzo Gago Aguirre
// Fecha de Creacion : 10/02/2025
// Accion a Realizar : CRUD de roles
// *****************************************************************************************************

using archi_studio.server.Data.Interfaces;
using archi_studio.server.Models;
using System.Data;
using static Helper.SqlHelper;
using static Helper.Types;
using static Helper.BaseDAO;
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

        public async Task<OperationResponse> GetAll(Log bLog)
        {
            var dtsDatos = new DataSet();
            var parameters = CreateParameters();

            try
            {
                var logParameters = _logRepo.AgregarParametrosLog(parameters.ToArray(), bLog, OperationType.Query);

                if (await GetDataSetAsync("SP_ROLE_GETALL", CommandType.StoredProcedure,
                    _connectionString, logParameters, dtsDatos))
                {
                    var roles = DeserializeToList<Role>(dtsDatos);
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

        public async Task<List<Menu>> GetMenusByRole(string rolCod)
        {
            var dtsDatos = new DataSet();
            var parameters = CreateParameters();

            try
            {
                AddParameter(parameters, "@P_ROLCOD", rolCod);

                if (await GetDataSetAsync("SP_MENU_GETBY_ROLE", CommandType.StoredProcedure,
                    _connectionString, parameters.ToArray(), dtsDatos))
                {
                    return DeserializeToList<Menu>(dtsDatos);
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

        public async Task<OperationResponse> Upsert(Role role, Log bLog)
        {
            var dtsDatos = new DataSet();
            var parameters = CreateParameters();

            try
            {
                AddParameter(parameters, "@P_ROLCOD", role.RolCod);
                AddParameter(parameters, "@P_ROLNAM", role.RolNam);
                AddParameter(parameters, "@P_ROLDES", role.RolDes ?? "");
                AddParameter(parameters, "@P_USER", bLog.UseCod ?? "SYSTEM");
                AddParameter(parameters, "@P_TIMEZONE", TimeZoneInfo.Local.Id);

                if (await GetDataSetAsync("SP_ROLE_UPSERT", CommandType.StoredProcedure,
                    _connectionString, parameters.ToArray(), dtsDatos))
                {
                    var roles = DeserializeToList<Role>(dtsDatos);
                    return CreateSuccessResponse("Rol guardado correctamente", roles.FirstOrDefault());
                }
                return CreateErrorResponse("Error al guardar rol");
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

        // Helper para deserializar DataSet a List
        private List<T> DeserializeToList<T>(DataSet ds) where T : new()
        {
            var list = new List<T>();
            if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                foreach (DataRow row in ds.Tables[0].Rows)
                {
                    var item = new T();
                    var props = typeof(T).GetProperties();
                    foreach (var prop in props)
                    {
                        if (ds.Tables[0].Columns.Contains(prop.Name) && row[prop.Name] != DBNull.Value)
                        {
                            try
                            {
                                prop.SetValue(item, Convert.ChangeType(row[prop.Name], 
                                    Nullable.GetUnderlyingType(prop.PropertyType) ?? prop.PropertyType));
                            }
                            catch { }
                        }
                    }
                    list.Add(item);
                }
            }
            return list;
        }
    }
}
