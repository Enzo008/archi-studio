// *****************************************************************************************************
// Description       : Interface IDocumentRepository
// Created by        : Enzo Gago Aguirre
// Creation Date     : 09/12/2025
// Purpose           : CRUD operations for documents
// *****************************************************************************************************

using archi_studio.server.Models;
using Helper;

namespace archi_studio.server.Data.Interfaces
{
    public interface IDocumentRepository
    {
        Task<OperationResponse> GetAll(Document bDocument, Log bLog);
        Task<OperationResponse> GetById(string docYea, string docCod, Log bLog);
        Task<OperationResponse> Create(Document bDocument, Log bLog);
        Task<OperationResponse> Update(Document bDocument, Log bLog);
        Task<OperationResponse> Delete(string docYea, string docCod, Log bLog);
        
        // Document types catalog
        Task<List<DocumentType>> GetTypes();
    }
}
