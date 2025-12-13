// *****************************************************************************************************
// Description       : Model representing a budget
// Created by        : Enzo Gago Aguirre
// Creation Date     : 09/12/2025
// Purpose           : Stores budget information with line items
// *****************************************************************************************************

using archi_studio.server.Models.Base;

namespace archi_studio.server.Models
{
    /// <summary>
    /// Represents a project budget
    /// </summary>
    public class Budget : AuditableEntity
    {
        // Primary Key
        public string? BudYea { get; set; }  // Budget registration year
        public string? BudCod { get; set; }  // Unique budget code

        // Budget Information
        public string? BudNam { get; set; }  // Budget name
        public string? BudDes { get; set; }  // Description
        public string? BudSta { get; set; }  // Status code (FK to TB_BUDGET_STATUS)
        public string? BudStaNam { get; set; } // Status name (from join)
        public string? BudStaIco { get; set; } // Status icon (from join)
        public string? BudStaCol { get; set; } // Status color (from join)
        public decimal? BudTot { get; set; } // Total amount
        public DateTime? BudDat { get; set; } // Budget date
        public DateTime? BudExp { get; set; } // Expiration date
        public string? BudNot { get; set; }  // Notes

        // Foreign Keys - Project
        public string? ProYea { get; set; }  // Project year
        public string? ProCod { get; set; }  // Project code
        public string? ProNam { get; set; }  // Project name (from join)
        public string? CliNam { get; set; }  // Client name (from join through project)

        // Pagination (not persisted)
        public int? PageNumber { get; set; }
        public int? PageSize { get; set; }
        public int? TotalCount { get; set; }

        // Multi-tenancy filter (via project)
        public string? UseYea { get; set; }
        public string? UseCod { get; set; }

        // Navigation properties
        public List<BudgetItem>? Items { get; set; }
    }

    /// <summary>
    /// Represents a budget line item
    /// </summary>
    public class BudgetItem : AuditableEntity
    {
        // Primary Key
        public string? BudYea { get; set; }  // Budget year
        public string? BudCod { get; set; }  // Budget code
        public int? BudIteNum { get; set; }  // Line number

        // Item Information
        public string? BudIteNam { get; set; } // Item description
        public decimal? BudIteQty { get; set; } // Quantity
        public string? BudIteUni { get; set; } // Unit (m2, units, hours, etc.)
        public decimal? BudItePri { get; set; } // Unit price
        public decimal? BudIteTot { get; set; } // Total (Qty * Price)
        public string? BudIteSta { get; set; } // Status: 01=Pending, 02=Approved, 03=Rejected
        public string? BudIteNot { get; set; } // Notes
        
        // Image file storage
        public string? BudIteImgPat { get; set; } // File path (e.g., "budgets/2025/000001/uuid.jpg")
        public string? BudIteImgFil { get; set; } // Original filename
        public long? BudIteImgSiz { get; set; }   // File size in bytes
        public string? BudIteImgMim { get; set; } // MIME type (image/jpeg, etc.)
    }

    /// <summary>
    /// Budget status catalog item
    /// </summary>
    public class BudgetStatus
    {
        public string? BudSta { get; set; }
        public string? BudStaNam { get; set; }
        public int? BudStaOrd { get; set; }
        public string? BudStaIco { get; set; }
        public string? BudStaCol { get; set; }
    }
}
