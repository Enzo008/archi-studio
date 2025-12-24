// *****************************************************************************************************
// Description       : Interface IBudgetRepository
// Created by        : Enzo Gago Aguirre
// Creation Date     : 09/12/2025
// Purpose           : CRUD operations for budgets and budget items
// *****************************************************************************************************

using archi_studio.server.Models;
using Helper;

namespace archi_studio.server.Data.Interfaces
{
    public interface IBudgetRepository
    {
        // Budget CRUD
        Task<OperationResponse> Search(Budget bBudget, Log bLog);
        Task<OperationResponse> Create(Budget bBudget, Log bLog);
        Task<OperationResponse> Update(Budget bBudget, Log bLog);
        Task<OperationResponse> Delete(string budYea, string budCod, Log bLog);
        
        // Budget Items
        Task<OperationResponse> SaveItem(BudgetItem bItem, Log bLog);
        Task<OperationResponse> DeleteItem(string budYea, string budCod, int budIteNum, Log bLog);
        Task<OperationResponse> UpdateItemImage(string budYea, string budCod, int budIteNum, 
            string imgPat, string imgFil, long imgSiz, string imgMim, Log bLog);
        
        // Status catalog
        Task<List<BudgetStatus>> GetStatuses();
    }
}
