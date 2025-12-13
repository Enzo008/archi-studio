// *****************************************************************************************************
// Description       : Interface IClientRepository
// Created by        : Enzo Gago Aguirre
// Creation Date     : 09/12/2025
// Purpose           : CRUD operations for clients
// *****************************************************************************************************

using archi_studio.server.Models;
using Helper;

namespace archi_studio.server.Data.Interfaces
{
    public interface IClientRepository
    {
        Task<OperationResponse> GetAll(Client bClient, Log bLog);
        Task<OperationResponse> GetById(string cliYea, string cliCod, Log bLog);
        Task<OperationResponse> Create(Client bClient, Log bLog);
        Task<OperationResponse> Update(Client bClient, Log bLog);
        Task<OperationResponse> Delete(string cliYea, string cliCod, Log bLog);
    }
}
