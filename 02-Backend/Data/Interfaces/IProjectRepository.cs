// *****************************************************************************************************
// Description       : Interface IProjectRepository
// Created by        : Enzo Gago Aguirre
// Creation Date     : 09/12/2025
// Purpose           : CRUD operations for projects
// *****************************************************************************************************

using archi_studio.server.Models;
using Helper;

namespace archi_studio.server.Data.Interfaces
{
    public interface IProjectRepository
    {
        Task<OperationResponse> GetAll(Project bProject, Log bLog);
        Task<OperationResponse> GetById(string proYea, string proCod, Log bLog);
        Task<OperationResponse> Create(Project bProject, Log bLog);
        Task<OperationResponse> Update(Project bProject, Log bLog);
        Task<OperationResponse> Delete(string proYea, string proCod, Log bLog);
        
        // Status catalog
        Task<List<ProjectStatus>> GetStatuses();
    }
}
