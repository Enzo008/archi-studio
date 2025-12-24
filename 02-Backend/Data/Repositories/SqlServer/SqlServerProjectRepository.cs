// *****************************************************************************************************
// Description       : SQL Server repository for projects
// Created by        : Enzo Gago Aguirre
// Creation Date     : 09/12/2025
// Purpose           : CRUD operations for projects using stored procedures
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
    public class SqlServerProjectRepository : BaseDAO, IProjectRepository
    {
        private readonly string _connectionString;
        private readonly SqlServerLogRepository _logRepo;

        public SqlServerProjectRepository(string connectionString)
        {
            _connectionString = connectionString;
            _logRepo = new SqlServerLogRepository();
        }

        /// <summary>
        /// Unified search method using SP_PROJECT_SEARCH
        /// - Provides ProYea + ProCod for single project lookup (GetById behavior)
        /// - Provides filters/pagination for list (GetAll behavior)
        /// </summary>
        public async Task<OperationResponse> Search(Project bProject, Log bLog)
        {
            var dtsDatos = new DataSet();
            var parameters = CreateParameters();

            try
            {
                // Primary key filters (for GetById mode)
                AddParameter(parameters, "@P_PROYEA", bProject.ProYea);
                AddParameter(parameters, "@P_PROCOD", bProject.ProCod);
                
                // Search filters
                AddParameter(parameters, "@P_SEARCH", bProject.ProNam);  // Search by name/desc/address
                AddParameter(parameters, "@P_PROSTA", bProject.ProSta);  // Status filter
                AddParameter(parameters, "@P_CLIYEA", bProject.CliYea);  // Client filter
                AddParameter(parameters, "@P_CLICOD", bProject.CliCod);
                
                // User filter (for explicit manager filtering)
                AddParameter(parameters, "@P_USEYEA", bProject.UseYea);
                AddParameter(parameters, "@P_USECOD", bProject.UseCod);
                
                // Pagination
                AddParameter(parameters, "@P_PAGE_NUMBER", bProject.PageNumber);
                AddParameter(parameters, "@P_PAGE_SIZE", bProject.PageSize);
                
                // Log parameters (includes RolCod for multitenancy in SP)
                var logParameters = _logRepo.AgregarParametrosLog(parameters.ToArray(), bLog, OperationType.Query);
                
                foreach (var param in logParameters)
                {
                    Console.WriteLine($"Parametro: {param.ParameterName}, Valor: {param.Value}");
                }
                
                if (await GetDataSetAsync("SP_PROJECT_SEARCH", CommandType.StoredProcedure,
                    _connectionString, logParameters, dtsDatos))
                {
                    var dtsData = DeserializeDataSet<List<Project>>(dtsDatos) ?? new List<Project>();
                    
                    // If searching by PK, return single item or null
                    if (!string.IsNullOrEmpty(bProject.ProYea) && !string.IsNullOrEmpty(bProject.ProCod))
                    {
                        return CreateResponseFromParameters(logParameters.ToList(), dtsData.FirstOrDefault());
                    }
                    
                    // Otherwise return list
                    return CreateResponseFromParameters(logParameters.ToList(), dtsData);
                }
                return CreateErrorResponse("Error al buscar proyectos");
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

        public async Task<OperationResponse> Create(Project bProject, Log bLog)
        {
            var parameters = CreateParameters();

            try
            {
                AddParameter(parameters, "@P_PRONAM", bProject.ProNam);
                AddParameter(parameters, "@P_PRODES", bProject.ProDes);
                AddParameter(parameters, "@P_PROSTA", bProject.ProSta ?? "01");
                AddParameter(parameters, "@P_PROPRO", bProject.ProPro ?? 0);
                AddParameter(parameters, "@P_PRODATINI", bProject.ProDatIni);
                AddParameter(parameters, "@P_PRODATEND", bProject.ProDatEnd);
                AddParameter(parameters, "@P_PROBUDGET", bProject.ProBudget);
                AddParameter(parameters, "@P_PROADD", bProject.ProAdd);
                AddParameter(parameters, "@P_CLIYEA", bProject.CliYea);
                AddParameter(parameters, "@P_CLICOD", bProject.CliCod);
                AddParameter(parameters, "@P_USEYEA", bProject.UseYea);
                AddParameter(parameters, "@P_USECOD", bProject.UseCod);
                AddOutputParameter(parameters, "@P_PROYEA_OUT", SqlDbType.Char, 4);
                AddOutputParameter(parameters, "@P_PROCOD_OUT", SqlDbType.Char, 6);

                var logParameters = _logRepo.AgregarParametrosLog(parameters.ToArray(), bLog, OperationType.Insert);

                if (await ExecuteTransactionAsync("SP_PROJECT_CREATE", CommandType.StoredProcedure,
                    _connectionString, logParameters))
                {
                    var result = new {
                        ProYea = GetOutputValue(logParameters, "@P_PROYEA_OUT"),
                        ProCod = GetOutputValue(logParameters, "@P_PROCOD_OUT")
                    };
                    return CreateResponseFromParameters(logParameters.ToList(), result);
                }
                return CreateErrorResponse("Error al crear proyecto");
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }

        public async Task<OperationResponse> Update(Project bProject, Log bLog)
        {
            var parameters = CreateParameters();

            try
            {
                AddParameter(parameters, "@P_PROYEA", bProject.ProYea);
                AddParameter(parameters, "@P_PROCOD", bProject.ProCod);
                AddParameter(parameters, "@P_PRONAM", bProject.ProNam);
                AddParameter(parameters, "@P_PRODES", bProject.ProDes);
                AddParameter(parameters, "@P_PROSTA", bProject.ProSta);
                AddParameter(parameters, "@P_PROPRO", bProject.ProPro);
                AddParameter(parameters, "@P_PRODATINI", bProject.ProDatIni);
                AddParameter(parameters, "@P_PRODATEND", bProject.ProDatEnd);
                AddParameter(parameters, "@P_PROBUDGET", bProject.ProBudget);
                AddParameter(parameters, "@P_PROADD", bProject.ProAdd);
                AddParameter(parameters, "@P_CLIYEA", bProject.CliYea);
                AddParameter(parameters, "@P_CLICOD", bProject.CliCod);
                AddParameter(parameters, "@P_USEYEA", bProject.UseYea);
                AddParameter(parameters, "@P_USECOD", bProject.UseCod);

                var logParameters = _logRepo.AgregarParametrosLog(parameters.ToArray(), bLog, OperationType.Update);

                if (await ExecuteTransactionAsync("SP_PROJECT_UPDATE", CommandType.StoredProcedure,
                    _connectionString, logParameters))
                {
                    return CreateResponseFromParameters(logParameters.ToList(), "Proyecto actualizado");
                }
                return CreateErrorResponse("Error al actualizar proyecto");
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }

        public async Task<OperationResponse> Delete(string proYea, string proCod, Log bLog)
        {
            var parameters = CreateParameters();

            try
            {
                AddParameter(parameters, "@P_PROYEA", proYea);
                AddParameter(parameters, "@P_PROCOD", proCod);

                var logParameters = _logRepo.AgregarParametrosLog(parameters.ToArray(), bLog, OperationType.Delete);

                if (await ExecuteTransactionAsync("SP_PROJECT_DELETE", CommandType.StoredProcedure,
                    _connectionString, logParameters))
                {
                    return CreateResponseFromParameters(logParameters.ToList(), "Proyecto eliminado");
                }
                return CreateErrorResponse("Error al eliminar proyecto");
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }

        public async Task<List<ProjectStatus>> GetStatuses()
        {
            var dtsDatos = new DataSet();
            var list = new List<ProjectStatus>();

            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("SELECT PROSTA, PROSTANAM, PROSTAORD, PROSTAICO, PROSTACOL FROM TB_PROJECT_STATUS WHERE STAREC <> 'D' ORDER BY PROSTAORD", connection);
                
                await connection.OpenAsync();
                using var adapter = new SqlDataAdapter(command);
                adapter.Fill(dtsDatos);

                if (dtsDatos.Tables.Count > 0)
                {
                    foreach (DataRow row in dtsDatos.Tables[0].Rows)
                    {
                        list.Add(new ProjectStatus
                        {
                            ProSta = row["PROSTA"]?.ToString(),
                            ProStaNam = row["PROSTANAM"]?.ToString(),
                            ProStaOrd = row["PROSTAORD"] as int?,
                            ProStaIco = row["PROSTAICO"]?.ToString(),
                            ProStaCol = row["PROSTACOL"]?.ToString()
                        });
                    }
                }
            }
            catch { }
            finally
            {
                dtsDatos.Dispose();
            }

            return list;
        }

        private string? GetOutputValue(SqlParameter[] parameters, string paramName)
        {
            var param = parameters.FirstOrDefault(p => p.ParameterName == paramName);
            return param?.Value?.ToString();
        }

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
