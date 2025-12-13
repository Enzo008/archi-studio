// *****************************************************************************************************
// Descripcion       : Interface IRoleRepository
// Creado por        : Enzo Gago Aguirre
// Fecha de Creacion : 10/02/2025
// Accion a Realizar : Operaciones de roles y menus
// *****************************************************************************************************

using archi_studio.server.Models;
using Helper;

namespace archi_studio.server.Data.Interfaces
{
    public interface IRoleRepository
    {
        Task<OperationResponse> GetAll(Log bLog);
        Task<List<Menu>> GetMenusByRole(string rolCod);
        Task<OperationResponse> Upsert(Role role, Log bLog);
    }
}
