// *****************************************************************************************************
// Descripcion       : Interface IUserRepository
// Creado por        : Enzo Gago Aguirre
// Fecha de Creacion : 10/02/2025
// Updated           : 17/12/2025 - Added Log param to all methods
// Accion a Realizar : Operaciones CRUD de usuarios y sincronizacion con Clerk
// *****************************************************************************************************

using archi_studio.server.Models;
using Helper;

namespace archi_studio.server.Data.Interfaces
{
    public interface IUserRepository
    {
        // CRUD Operations
        Task<OperationResponse> Search(User bUser, Log bLog);
        Task<OperationResponse> Create(User bUser, Log bLog);
        Task<OperationResponse> Update(User bUser, Log bLog);
        Task<OperationResponse> Delete(string useYea, string useCod, Log bLog);
        
        // Clerk Sync
        Task<OperationResponse> SyncFromClerk(SyncUserRequest request, Log bLog);
        Task<User?> GetByExternalId(string externalId);
        
        // Menus by Role
        Task<List<Menu>> GetMenusByRole(string rolCod, Log bLog);
    }
}
