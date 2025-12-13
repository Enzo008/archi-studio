// *****************************************************************************************************
// Descripcion       : Repositorio de usuarios para SQL Server
// Creado por        : Enzo Gago Aguirre
// Fecha de Creacion : 10/02/2025
// Accion a Realizar : CRUD de usuarios y sincronizacion con Clerk
// *****************************************************************************************************

using archi_studio.server.Data.Interfaces;
using archi_studio.server.Models;
using Microsoft.Data.SqlClient;
using System.Data;
using static Helper.SqlHelper;
using static Helper.Types;
using static Helper.BaseDAO;
using Helper;

namespace archi_studio.server.Data.Repositories.SqlServer
{
    public class SqlServerUserRepository : BaseDAO, IUserRepository
    {
        private readonly string _connectionString;
        private readonly SqlServerLogRepository _logRepo;

        public SqlServerUserRepository(string connectionString)
        {
            _connectionString = connectionString;
            _logRepo = new SqlServerLogRepository();
        }

        public async Task<OperationResponse> GetAll(User bUser, Log bLog)
        {
            var dtsDatos = new DataSet();
            var parameters = CreateParameters();

            try
            {
                AddParameter(parameters, "@P_PAGE_NUMBER", bUser.PageNumber ?? 1);
                AddParameter(parameters, "@P_PAGE_SIZE", bUser.PageSize ?? 10);

                var logParameters = _logRepo.AgregarParametrosLog(parameters.ToArray(), bLog, OperationType.Query);

                if (await GetDataSetAsync("SP_USER_GETALL", CommandType.StoredProcedure,
                    _connectionString, logParameters, dtsDatos))
                {
                    var users = DeserializeToList<User>(dtsDatos);
                    return CreateResponseFromParameters(logParameters.ToList(), users);
                }
                return CreateErrorResponse("Error al obtener usuarios");
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

        public async Task<OperationResponse> GetById(string useYea, string useCod, Log bLog)
        {
            var dtsDatos = new DataSet();
            var parameters = CreateParameters();

            try
            {
                AddParameter(parameters, "@P_USEYEA", useYea);
                AddParameter(parameters, "@P_USECOD", useCod);

                var logParameters = _logRepo.AgregarParametrosLog(parameters.ToArray(), bLog, OperationType.Query);

                if (await GetDataSetAsync("SP_USER_GETBYID", CommandType.StoredProcedure,
                    _connectionString, logParameters, dtsDatos))
                {
                    var users = DeserializeToList<User>(dtsDatos);
                    var user = users.FirstOrDefault();
                    
                    if (user != null && !string.IsNullOrEmpty(user.RolCod))
                    {
                        user.Menus = await GetMenusByRole(user.RolCod);
                    }
                    
                    return CreateResponseFromParameters(logParameters.ToList(), user);
                }
                return CreateErrorResponse("Usuario no encontrado");
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

        public async Task<OperationResponse> Create(User bUser, Log bLog)
        {
            var parameters = CreateParameters();

            try
            {
                AddParameter(parameters, "@P_USEEXTID", bUser.UseExtId);
                AddParameter(parameters, "@P_USENAM", bUser.UseNam);
                AddParameter(parameters, "@P_USELAS", bUser.UseLas);
                AddParameter(parameters, "@P_USEEMA", bUser.UseEma);
                AddParameter(parameters, "@P_USEIMG", bUser.UseImg);
                AddParameter(parameters, "@P_ROLCOD", bUser.RolCod ?? "01");
                AddParameter(parameters, "@P_USESTA", bUser.UseSta ?? 'A');
                AddOutputParameter(parameters, "@P_USEYEA_OUT", SqlDbType.Char, 4);
                AddOutputParameter(parameters, "@P_USECOD_OUT", SqlDbType.Char, 6);

                var logParameters = _logRepo.AgregarParametrosLog(parameters.ToArray(), bLog, OperationType.Insert);

                if (await ExecuteTransactionAsync("SP_USER_CREATE", CommandType.StoredProcedure,
                    _connectionString, logParameters))
                {
                    var result = new {
                        UseYea = GetOutputValue(logParameters, "@P_USEYEA_OUT"),
                        UseCod = GetOutputValue(logParameters, "@P_USECOD_OUT")
                    };
                    return CreateResponseFromParameters(logParameters.ToList(), result);
                }
                return CreateErrorResponse("Error al crear usuario");
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }

        public async Task<OperationResponse> Update(User bUser, Log bLog)
        {
            var parameters = CreateParameters();

            try
            {
                AddParameter(parameters, "@P_USEYEA", bUser.UseYea);
                AddParameter(parameters, "@P_USECOD", bUser.UseCod);
                AddParameter(parameters, "@P_USENAM", bUser.UseNam);
                AddParameter(parameters, "@P_USELAS", bUser.UseLas);
                AddParameter(parameters, "@P_USEEMA", bUser.UseEma);
                AddParameter(parameters, "@P_USEIMG", bUser.UseImg);
                AddParameter(parameters, "@P_ROLCOD", bUser.RolCod);
                AddParameter(parameters, "@P_USESTA", bUser.UseSta);

                var logParameters = _logRepo.AgregarParametrosLog(parameters.ToArray(), bLog, OperationType.Update);

                if (await ExecuteTransactionAsync("SP_USER_UPDATE", CommandType.StoredProcedure,
                    _connectionString, logParameters))
                {
                    return CreateResponseFromParameters(logParameters.ToList(), "Usuario actualizado");
                }
                return CreateErrorResponse("Error al actualizar usuario");
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }

        public async Task<OperationResponse> Delete(string useYea, string useCod, Log bLog)
        {
            var parameters = CreateParameters();

            try
            {
                AddParameter(parameters, "@P_USEYEA", useYea);
                AddParameter(parameters, "@P_USECOD", useCod);

                var logParameters = _logRepo.AgregarParametrosLog(parameters.ToArray(), bLog, OperationType.Delete);

                if (await ExecuteTransactionAsync("SP_USER_DELETE", CommandType.StoredProcedure,
                    _connectionString, logParameters))
                {
                    return CreateResponseFromParameters(logParameters.ToList(), "Usuario eliminado");
                }
                return CreateErrorResponse("Error al eliminar usuario");
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }

        public async Task<OperationResponse> SyncFromClerk(SyncUserRequest request, Log bLog)
        {
            var dtsDatos = new DataSet();
            var parameters = CreateParameters();

            try
            {
                AddParameter(parameters, "@P_USEEXTID", request.ExternalId);
                AddParameter(parameters, "@P_USEEMA", request.Email);
                AddParameter(parameters, "@P_USENAM", request.FirstName);
                AddParameter(parameters, "@P_USELAS", request.LastName);
                AddParameter(parameters, "@P_USEIMG", request.ImageUrl);
                AddParameter(parameters, "@P_USECRE", bLog.UseCod ?? "SYSTEM");
                AddParameter(parameters, "@P_ZONCRE", TimeZoneInfo.Local.Id);

                if (await GetDataSetAsync("SP_USER_SYNC_CLERK", CommandType.StoredProcedure,
                    _connectionString, parameters.ToArray(), dtsDatos))
                {
                    var users = DeserializeToList<User>(dtsDatos);
                    var user = users.FirstOrDefault();
                    
                    List<Menu>? menus = null;
                    if (user?.RolCod != null)
                    {
                        menus = await GetMenusByRole(user.RolCod);
                    }
                    
                    return new OperationResponse
                    {
                        MessageType = MessageType.Success,
                        Message = "Usuario sincronizado correctamente",
                        Data = new SyncUserResponse
                        {
                            IsNewUser = dtsDatos.Tables[0].Rows[0]["ACTION"]?.ToString() == "INSERT",
                            UseYea = user?.UseYea,
                            UseCod = user?.UseCod,
                            RolCod = user?.RolCod,
                            RolNam = user?.RolNam,
                            Menus = menus
                        }
                    };
                }
                return CreateErrorResponse("Error al sincronizar usuario");
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

        public async Task<User?> GetByExternalId(string externalId)
        {
            var dtsDatos = new DataSet();
            var parameters = CreateParameters();

            try
            {
                AddParameter(parameters, "@P_USEEXTID", externalId);

                if (await GetDataSetAsync("SP_USER_GETBY_EXTID", CommandType.StoredProcedure,
                    _connectionString, parameters.ToArray(), dtsDatos))
                {
                    var users = DeserializeToList<User>(dtsDatos);
                    return users.FirstOrDefault();
                }
                return null;
            }
            catch
            {
                return null;
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

        // Helper para obtener valor de parametro de salida
        private string? GetOutputValue(SqlParameter[] parameters, string paramName)
        {
            var param = parameters.FirstOrDefault(p => p.ParameterName == paramName);
            return param?.Value?.ToString();
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
                        // Buscar columna con nombre exacto o en mayusculas
                        var colName = ds.Tables[0].Columns.Contains(prop.Name) ? prop.Name :
                                      ds.Tables[0].Columns.Contains(prop.Name.ToUpper()) ? prop.Name.ToUpper() : null;
                        
                        if (colName != null && row[colName] != DBNull.Value)
                        {
                            try
                            {
                                var targetType = Nullable.GetUnderlyingType(prop.PropertyType) ?? prop.PropertyType;
                                prop.SetValue(item, Convert.ChangeType(row[colName], targetType));
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
