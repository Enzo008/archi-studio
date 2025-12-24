// *****************************************************************************************************
// Descripcion       : Interface IRoleRepository
// Creado por        : Enzo Gago Aguirre
// Fecha de Creacion : 10/02/2025
// Updated           : 17/12/2025 - Standardized with Search/Save/Delete
// Accion a Realizar : Operaciones de roles y menus
// *****************************************************************************************************

using archi_studio.server.Models;
using Helper;

namespace archi_studio.server.Data.Interfaces
{
    public interface IRoleRepository
    {
        Task<OperationResponse> Search(Log bLog);
        Task<List<Menu>> GetMenusByRole(string rolCod, Log bLog);
        Task<OperationResponse> Save(Role role, Log bLog);
        Task<OperationResponse> Delete(string rolCod, Log bLog);
    }
}
