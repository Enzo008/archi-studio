// *****************************************************************************************************
// Description       : SQL Server repository for budgets
// Created by        : Enzo Gago Aguirre
// Creation Date     : 09/12/2025
// Purpose           : CRUD operations for budgets using stored procedures
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
    public class SqlServerBudgetRepository : BaseDAO, IBudgetRepository
    {
        private readonly string _connectionString;
        private readonly SqlServerLogRepository _logRepo;

        public SqlServerBudgetRepository(string connectionString)
        {
            _connectionString = connectionString;
            _logRepo = new SqlServerLogRepository();
        }

        public async Task<OperationResponse> Search(Budget bBudget, Log bLog)
        {
            var dtsDatos = new DataSet();
            var parameters = CreateParameters();

            try
            {
                AddParameter(parameters, "@P_BUDYEA", bBudget.BudYea);
                AddParameter(parameters, "@P_BUDCOD", bBudget.BudCod);
                AddParameter(parameters, "@P_SEARCH", bBudget.BudNam);
                AddParameter(parameters, "@P_BUDSTA", bBudget.BudSta);
                AddParameter(parameters, "@P_PROYEA", bBudget.ProYea);
                AddParameter(parameters, "@P_PROCOD", bBudget.ProCod);
                AddParameter(parameters, "@P_PAGE_NUMBER", bBudget.PageNumber);
                AddParameter(parameters, "@P_PAGE_SIZE", bBudget.PageSize);

                var logParameters = _logRepo.AgregarParametrosLog(parameters.ToArray(), bLog, OperationType.Query);

                if (await GetDataSetAsync("SP_BUDGET_SEARCH", CommandType.StoredProcedure,
                    _connectionString, logParameters, dtsDatos))
                {
                    var dtsData = DeserializeDataSet<List<Budget>>(dtsDatos) ?? new List<Budget>();
                    
                    // Detail mode: return single item
                    if (!string.IsNullOrEmpty(bBudget.BudYea) && !string.IsNullOrEmpty(bBudget.BudCod))
                        return CreateResponseFromParameters(logParameters.ToList(), dtsData.FirstOrDefault());
                    
                    // List mode: return array
                    return CreateResponseFromParameters(logParameters.ToList(), dtsData);
                }
                return CreateErrorResponse("Error al buscar presupuestos");
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

        public async Task<OperationResponse> Create(Budget bBudget, Log bLog)
        {
            var parameters = CreateParameters();

            try
            {
                AddParameter(parameters, "@P_BUDNAM", bBudget.BudNam);
                AddParameter(parameters, "@P_BUDDES", bBudget.BudDes);
                AddParameter(parameters, "@P_BUDSTA", bBudget.BudSta ?? "01");
                AddParameter(parameters, "@P_BUDDAT", bBudget.BudDat);
                AddParameter(parameters, "@P_BUDEXP", bBudget.BudExp);
                AddParameter(parameters, "@P_BUDNOT", bBudget.BudNot);
                AddParameter(parameters, "@P_PROYEA", bBudget.ProYea);
                AddParameter(parameters, "@P_PROCOD", bBudget.ProCod);
                AddOutputParameter(parameters, "@P_BUDYEA_OUT", SqlDbType.Char, 4);
                AddOutputParameter(parameters, "@P_BUDCOD_OUT", SqlDbType.Char, 6);

                var logParameters = _logRepo.AgregarParametrosLog(parameters.ToArray(), bLog, OperationType.Insert);

                if (await ExecuteTransactionAsync("SP_BUDGET_CREATE", CommandType.StoredProcedure,
                    _connectionString, logParameters))
                {
                    var result = new {
                        BudYea = GetOutputValue(logParameters, "@P_BUDYEA_OUT"),
                        BudCod = GetOutputValue(logParameters, "@P_BUDCOD_OUT")
                    };
                    return CreateResponseFromParameters(logParameters.ToList(), result);
                }
                return CreateErrorResponse("Error al crear presupuesto");
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }

        public async Task<OperationResponse> Update(Budget bBudget, Log bLog)
        {
            var parameters = CreateParameters();

            try
            {
                AddParameter(parameters, "@P_BUDYEA", bBudget.BudYea);
                AddParameter(parameters, "@P_BUDCOD", bBudget.BudCod);
                AddParameter(parameters, "@P_BUDNAM", bBudget.BudNam);
                AddParameter(parameters, "@P_BUDDES", bBudget.BudDes);
                AddParameter(parameters, "@P_BUDSTA", bBudget.BudSta);
                AddParameter(parameters, "@P_BUDDAT", bBudget.BudDat);
                AddParameter(parameters, "@P_BUDEXP", bBudget.BudExp);
                AddParameter(parameters, "@P_BUDNOT", bBudget.BudNot);
                AddParameter(parameters, "@P_PROYEA", bBudget.ProYea);
                AddParameter(parameters, "@P_PROCOD", bBudget.ProCod);

                var logParameters = _logRepo.AgregarParametrosLog(parameters.ToArray(), bLog, OperationType.Update);

                if (await ExecuteTransactionAsync("SP_BUDGET_UPDATE", CommandType.StoredProcedure,
                    _connectionString, logParameters))
                {
                    return CreateResponseFromParameters(logParameters.ToList(), "Presupuesto actualizado");
                }
                return CreateErrorResponse("Error al actualizar presupuesto");
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }

        public async Task<OperationResponse> Delete(string budYea, string budCod, Log bLog)
        {
            var parameters = CreateParameters();

            try
            {
                AddParameter(parameters, "@P_BUDYEA", budYea);
                AddParameter(parameters, "@P_BUDCOD", budCod);

                var logParameters = _logRepo.AgregarParametrosLog(parameters.ToArray(), bLog, OperationType.Delete);

                if (await ExecuteTransactionAsync("SP_BUDGET_DELETE", CommandType.StoredProcedure,
                    _connectionString, logParameters))
                {
                    return CreateResponseFromParameters(logParameters.ToList(), "Presupuesto eliminado");
                }
                return CreateErrorResponse("Error al eliminar presupuesto");
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }

        public async Task<OperationResponse> SaveItem(BudgetItem bItem, Log bLog)
        {
            var parameters = CreateParameters();

            try
            {
                AddParameter(parameters, "@P_BUDYEA", bItem.BudYea);
                AddParameter(parameters, "@P_BUDCOD", bItem.BudCod);
                AddParameter(parameters, "@P_BUDITENUM", bItem.BudIteNum);
                AddParameter(parameters, "@P_BUDITENAM", bItem.BudIteNam);
                AddParameter(parameters, "@P_BUDITEQTY", bItem.BudIteQty ?? 1);
                AddParameter(parameters, "@P_BUDITEUNI", bItem.BudIteUni);
                AddParameter(parameters, "@P_BUDITEPRI", bItem.BudItePri ?? 0);
                AddParameter(parameters, "@P_BUDITESTA", bItem.BudIteSta ?? "01");
                AddParameter(parameters, "@P_BUDITENOT", bItem.BudIteNot);
                AddParameter(parameters, "@P_BUDITEIMGPAT", bItem.BudIteImgPat);
                AddParameter(parameters, "@P_BUDITEIMGFIL", bItem.BudIteImgFil);
                AddParameter(parameters, "@P_BUDITEIMGSIZ", bItem.BudIteImgSiz);
                AddParameter(parameters, "@P_BUDITEIMGMIM", bItem.BudIteImgMim);
                AddOutputParameter(parameters, "@P_BUDITENUM_OUT", SqlDbType.Int, 0);

                var logParameters = _logRepo.AgregarParametrosLog(parameters.ToArray(), bLog, OperationType.Insert);

                if (await ExecuteTransactionAsync("SP_BUDGET_ITEM_SAVE", CommandType.StoredProcedure,
                    _connectionString, logParameters))
                {
                    var result = new {
                        BudIteNum = GetOutputValueInt(logParameters, "@P_BUDITENUM_OUT")
                    };
                    return CreateResponseFromParameters(logParameters.ToList(), result);
                }
                return CreateErrorResponse("Error al guardar item");
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }

        public async Task<OperationResponse> DeleteItem(string budYea, string budCod, int budIteNum, Log bLog)
        {
            var parameters = CreateParameters();

            try
            {
                AddParameter(parameters, "@P_BUDYEA", budYea);
                AddParameter(parameters, "@P_BUDCOD", budCod);
                AddParameter(parameters, "@P_BUDITENUM", budIteNum);

                var logParameters = _logRepo.AgregarParametrosLog(parameters.ToArray(), bLog, OperationType.Delete);

                if (await ExecuteTransactionAsync("SP_BUDGET_ITEM_DELETE", CommandType.StoredProcedure,
                    _connectionString, logParameters))
                {
                    return CreateResponseFromParameters(logParameters.ToList(), "Item eliminado");
                }
                return CreateErrorResponse("Error al eliminar item");
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }

        public async Task<OperationResponse> UpdateItemImage(
            string budYea, string budCod, int budIteNum,
            string imgPat, string imgFil, long imgSiz, string imgMim, Log bLog)
        {
            var parameters = CreateParameters();

            try
            {
                AddParameter(parameters, "@P_BUDYEA", budYea);
                AddParameter(parameters, "@P_BUDCOD", budCod);
                AddParameter(parameters, "@P_BUDITENUM", budIteNum);
                AddParameter(parameters, "@P_BUDITEIMGPAT", imgPat);
                AddParameter(parameters, "@P_BUDITEIMGFIL", imgFil);
                AddParameter(parameters, "@P_BUDITEIMGSIZ", imgSiz);
                AddParameter(parameters, "@P_BUDITEIMGMIM", imgMim);

                var logParameters = _logRepo.AgregarParametrosLog(parameters.ToArray(), bLog, OperationType.Update);

                if (await ExecuteTransactionAsync("SP_BUDGET_ITEM_UPDATE_IMAGE", CommandType.StoredProcedure,
                    _connectionString, logParameters))
                {
                    return CreateResponseFromParameters(logParameters.ToList(), "Imagen actualizada");
                }
                return CreateErrorResponse("Error al actualizar imagen");
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }

        public async Task<List<BudgetStatus>> GetStatuses()
        {
            var dtsDatos = new DataSet();
            var list = new List<BudgetStatus>();

            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("SELECT BUDSTA, BUDSTANAM, BUDSTAORD, BUDSTAICO, BUDSTACOL FROM TB_BUDGET_STATUS WHERE STAREC <> 'D' ORDER BY BUDSTAORD", connection);
                
                await connection.OpenAsync();
                using var adapter = new SqlDataAdapter(command);
                adapter.Fill(dtsDatos);

                if (dtsDatos.Tables.Count > 0)
                {
                    foreach (DataRow row in dtsDatos.Tables[0].Rows)
                    {
                        list.Add(new BudgetStatus
                        {
                            BudSta = row["BUDSTA"]?.ToString(),
                            BudStaNam = row["BUDSTANAM"]?.ToString(),
                            BudStaOrd = row["BUDSTAORD"] as int?,
                            BudStaIco = row["BUDSTAICO"]?.ToString(),
                            BudStaCol = row["BUDSTACOL"]?.ToString()
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

        private int? GetOutputValueInt(SqlParameter[] parameters, string paramName)
        {
            var param = parameters.FirstOrDefault(p => p.ParameterName == paramName);
            return param?.Value as int?;
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
