// *****************************************************************************************************
// Description       : SQL Server repository for clients
// Created by        : Enzo Gago Aguirre
// Creation Date     : 09/12/2025
// Purpose           : CRUD operations for clients using stored procedures
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
    public class SqlServerClientRepository : BaseDAO, IClientRepository
    {
        private readonly string _connectionString;
        private readonly SqlServerLogRepository _logRepo;

        public SqlServerClientRepository(string connectionString)
        {
            _connectionString = connectionString;
            _logRepo = new SqlServerLogRepository();
        }

        public async Task<OperationResponse> Search(Client bClient, Log bLog)
        {
            var dtsDatos = new DataSet();
            var parameters = CreateParameters();

            try
            {
                AddParameter(parameters, "@P_CLIYEA", bClient.CliYea);
                AddParameter(parameters, "@P_CLICOD", bClient.CliCod);
                AddParameter(parameters, "@P_SEARCH", bClient.CliNam);
                AddParameter(parameters, "@P_CLITYP", bClient.CliTyp);
                AddParameter(parameters, "@P_CLISTA", bClient.CliSta);
                AddParameter(parameters, "@P_USEYEA", bClient.UseYea);
                AddParameter(parameters, "@P_USECOD", bClient.UseCod);
                AddParameter(parameters, "@P_PAGE_NUMBER", bClient.PageNumber);
                AddParameter(parameters, "@P_PAGE_SIZE", bClient.PageSize);

                var logParameters = _logRepo.AgregarParametrosLog(parameters.ToArray(), bLog, OperationType.Query);

                if (await GetDataSetAsync("SP_CLIENT_SEARCH", CommandType.StoredProcedure,
                    _connectionString, logParameters, dtsDatos))
                {
                    var dtsData = DeserializeDataSet<List<Client>>(dtsDatos) ?? new List<Client>();
                    
                    if (!string.IsNullOrEmpty(bClient.CliYea) && !string.IsNullOrEmpty(bClient.CliCod))
                        return CreateResponseFromParameters(logParameters.ToList(), dtsData.FirstOrDefault());
                    
                    return CreateResponseFromParameters(logParameters.ToList(), dtsData);
                }
                return CreateErrorResponse("Error al buscar clientes");
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

        public async Task<OperationResponse> Create(Client bClient, Log bLog)
        {
            var parameters = CreateParameters();

            try
            {
                AddParameter(parameters, "@P_CLINAM", bClient.CliNam);
                AddParameter(parameters, "@P_CLITYP", bClient.CliTyp ?? "01");
                AddParameter(parameters, "@P_CLIEMA", bClient.CliEma);
                AddParameter(parameters, "@P_CLIPHO", bClient.CliPho);
                AddParameter(parameters, "@P_CLIADD", bClient.CliAdd);
                AddParameter(parameters, "@P_CLISTA", bClient.CliSta ?? 'A');
                AddParameter(parameters, "@P_CLIDES", bClient.CliDes);
                AddParameter(parameters, "@P_USEYEA", bLog.UseYea);
                AddParameter(parameters, "@P_USECOD", bLog.UseCod);
                AddOutputParameter(parameters, "@P_CLIYEA_OUT", SqlDbType.Char, 4);
                AddOutputParameter(parameters, "@P_CLICOD_OUT", SqlDbType.Char, 6);

                var logParameters = _logRepo.AgregarParametrosLog(parameters.ToArray(), bLog, OperationType.Insert);

                if (await ExecuteTransactionAsync("SP_CLIENT_CREATE", CommandType.StoredProcedure,
                    _connectionString, logParameters))
                {
                    var result = new {
                        CliYea = GetOutputValue(logParameters, "@P_CLIYEA_OUT"),
                        CliCod = GetOutputValue(logParameters, "@P_CLICOD_OUT")
                    };
                    return CreateResponseFromParameters(logParameters.ToList(), result);
                }
                return CreateErrorResponse("Error al crear cliente");
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }

        public async Task<OperationResponse> Update(Client bClient, Log bLog)
        {
            var parameters = CreateParameters();

            try
            {
                AddParameter(parameters, "@P_CLIYEA", bClient.CliYea);
                AddParameter(parameters, "@P_CLICOD", bClient.CliCod);
                AddParameter(parameters, "@P_CLINAM", bClient.CliNam);
                AddParameter(parameters, "@P_CLITYP", bClient.CliTyp);
                AddParameter(parameters, "@P_CLIEMA", bClient.CliEma);
                AddParameter(parameters, "@P_CLIPHO", bClient.CliPho);
                AddParameter(parameters, "@P_CLIADD", bClient.CliAdd);
                AddParameter(parameters, "@P_CLISTA", bClient.CliSta);
                AddParameter(parameters, "@P_CLIDES", bClient.CliDes);

                var logParameters = _logRepo.AgregarParametrosLog(parameters.ToArray(), bLog, OperationType.Update);

                if (await ExecuteTransactionAsync("SP_CLIENT_UPDATE", CommandType.StoredProcedure,
                    _connectionString, logParameters))
                {
                    return CreateResponseFromParameters(logParameters.ToList(), "Cliente actualizado");
                }
                return CreateErrorResponse("Error al actualizar cliente");
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }

        public async Task<OperationResponse> Delete(string cliYea, string cliCod, Log bLog)
        {
            var parameters = CreateParameters();

            try
            {
                AddParameter(parameters, "@P_CLIYEA", cliYea);
                AddParameter(parameters, "@P_CLICOD", cliCod);

                var logParameters = _logRepo.AgregarParametrosLog(parameters.ToArray(), bLog, OperationType.Delete);

                if (await ExecuteTransactionAsync("SP_CLIENT_DELETE", CommandType.StoredProcedure,
                    _connectionString, logParameters))
                {
                    return CreateResponseFromParameters(logParameters.ToList(), "Cliente eliminado");
                }
                return CreateErrorResponse("Error al eliminar cliente");
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }

        private string? GetOutputValue(SqlParameter[] parameters, string paramName)
        {
            var param = parameters.FirstOrDefault(p => p.ParameterName == paramName);
            return param?.Value?.ToString();
        }
    }
}
