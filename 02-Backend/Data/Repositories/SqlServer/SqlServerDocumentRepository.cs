// *****************************************************************************************************
// Description       : SQL Server repository for documents
// Created by        : Enzo Gago Aguirre
// Creation Date     : 09/12/2025
// Purpose           : CRUD operations for documents using stored procedures
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
    public class SqlServerDocumentRepository : BaseDAO, IDocumentRepository
    {
        private readonly string _connectionString;
        private readonly SqlServerLogRepository _logRepo;

        public SqlServerDocumentRepository(string connectionString)
        {
            _connectionString = connectionString;
            _logRepo = new SqlServerLogRepository();
        }

        public async Task<OperationResponse> Search(Document bDocument, Log bLog)
        {
            var dtsDatos = new DataSet();
            var parameters = CreateParameters();

            try
            {
                AddParameter(parameters, "@P_DOCYEA", bDocument.DocYea);
                AddParameter(parameters, "@P_DOCCOD", bDocument.DocCod);
                AddParameter(parameters, "@P_SEARCH", bDocument.DocNam);
                AddParameter(parameters, "@P_DOCTYP", bDocument.DocTyp);
                AddParameter(parameters, "@P_DOCSTA", bDocument.DocSta);
                AddParameter(parameters, "@P_PROYEA", bDocument.ProYea);
                AddParameter(parameters, "@P_PROCOD", bDocument.ProCod);
                AddParameter(parameters, "@P_PAGE_NUMBER", bDocument.PageNumber);
                AddParameter(parameters, "@P_PAGE_SIZE", bDocument.PageSize);

                var logParameters = _logRepo.AgregarParametrosLog(parameters.ToArray(), bLog, OperationType.Query);

                if (await GetDataSetAsync("SP_DOCUMENT_SEARCH", CommandType.StoredProcedure,
                    _connectionString, logParameters, dtsDatos))
                {
                    var dtsData = DeserializeDataSet<List<Document>>(dtsDatos) ?? new List<Document>();
                    
                    if (!string.IsNullOrEmpty(bDocument.DocYea) && !string.IsNullOrEmpty(bDocument.DocCod))
                        return CreateResponseFromParameters(logParameters.ToList(), dtsData.FirstOrDefault());
                    
                    return CreateResponseFromParameters(logParameters.ToList(), dtsData);
                }
                return CreateErrorResponse("Error al buscar documentos");
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

        public async Task<OperationResponse> Create(Document bDocument, Log bLog)
        {
            var parameters = CreateParameters();

            try
            {
                AddParameter(parameters, "@P_DOCNAM", bDocument.DocNam);
                AddParameter(parameters, "@P_DOCDES", bDocument.DocDes);
                AddParameter(parameters, "@P_DOCTYP", bDocument.DocTyp ?? "06");
                AddParameter(parameters, "@P_DOCPAT", bDocument.DocPat);
                AddParameter(parameters, "@P_DOCFIL", bDocument.DocFil);
                AddParameter(parameters, "@P_DOCSIZ", bDocument.DocSiz);
                AddParameter(parameters, "@P_DOCMIM", bDocument.DocMim);
                AddParameter(parameters, "@P_DOCSTA", bDocument.DocSta ?? 'A');
                AddParameter(parameters, "@P_PROYEA", bDocument.ProYea);
                AddParameter(parameters, "@P_PROCOD", bDocument.ProCod);
                AddOutputParameter(parameters, "@P_DOCYEA_OUT", SqlDbType.Char, 4);
                AddOutputParameter(parameters, "@P_DOCCOD_OUT", SqlDbType.Char, 6);

                var logParameters = _logRepo.AgregarParametrosLog(parameters.ToArray(), bLog, OperationType.Insert);

                if (await ExecuteTransactionAsync("SP_DOCUMENT_CREATE", CommandType.StoredProcedure,
                    _connectionString, logParameters))
                {
                    var result = new {
                        DocYea = GetOutputValue(logParameters, "@P_DOCYEA_OUT"),
                        DocCod = GetOutputValue(logParameters, "@P_DOCCOD_OUT")
                    };
                    return CreateResponseFromParameters(logParameters.ToList(), result);
                }
                return CreateErrorResponse("Error al crear documento");
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }

        public async Task<OperationResponse> Update(Document bDocument, Log bLog)
        {
            var parameters = CreateParameters();

            try
            {
                AddParameter(parameters, "@P_DOCYEA", bDocument.DocYea);
                AddParameter(parameters, "@P_DOCCOD", bDocument.DocCod);
                AddParameter(parameters, "@P_DOCNAM", bDocument.DocNam);
                AddParameter(parameters, "@P_DOCDES", bDocument.DocDes);
                AddParameter(parameters, "@P_DOCTYP", bDocument.DocTyp);
                AddParameter(parameters, "@P_DOCSTA", bDocument.DocSta);
                AddParameter(parameters, "@P_PROYEA", bDocument.ProYea);
                AddParameter(parameters, "@P_PROCOD", bDocument.ProCod);

                var logParameters = _logRepo.AgregarParametrosLog(parameters.ToArray(), bLog, OperationType.Update);

                if (await ExecuteTransactionAsync("SP_DOCUMENT_UPDATE", CommandType.StoredProcedure,
                    _connectionString, logParameters))
                {
                    return CreateResponseFromParameters(logParameters.ToList(), "Documento actualizado");
                }
                return CreateErrorResponse("Error al actualizar documento");
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }

        public async Task<OperationResponse> Delete(string docYea, string docCod, Log bLog)
        {
            var parameters = CreateParameters();

            try
            {
                AddParameter(parameters, "@P_DOCYEA", docYea);
                AddParameter(parameters, "@P_DOCCOD", docCod);

                var logParameters = _logRepo.AgregarParametrosLog(parameters.ToArray(), bLog, OperationType.Delete);

                if (await ExecuteTransactionAsync("SP_DOCUMENT_DELETE", CommandType.StoredProcedure,
                    _connectionString, logParameters))
                {
                    return CreateResponseFromParameters(logParameters.ToList(), "Documento eliminado");
                }
                return CreateErrorResponse("Error al eliminar documento");
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }

        public async Task<List<DocumentType>> GetTypes()
        {
            var dtsDatos = new DataSet();
            var list = new List<DocumentType>();

            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("SELECT DOCTYP, DOCTYPNAM, DOCTYPICO, DOCTYPEXT FROM TB_DOCUMENT_TYPE WHERE STAREC <> 'D' ORDER BY DOCTYP", connection);
                
                await connection.OpenAsync();
                using var adapter = new SqlDataAdapter(command);
                adapter.Fill(dtsDatos);

                if (dtsDatos.Tables.Count > 0)
                {
                    foreach (DataRow row in dtsDatos.Tables[0].Rows)
                    {
                        list.Add(new DocumentType
                        {
                            DocTyp = row["DOCTYP"]?.ToString(),
                            DocTypNam = row["DOCTYPNAM"]?.ToString(),
                            DocTypIco = row["DOCTYPICO"]?.ToString(),
                            DocTypExt = row["DOCTYPEXT"]?.ToString()
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
