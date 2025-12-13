// *****************************************************************************************************
// Description       : Model representing a project
// Created by        : Enzo Gago Aguirre
// Creation Date     : 09/12/2025
// Purpose           : Stores architectural project information
// *****************************************************************************************************

using archi_studio.server.Models.Base;

namespace archi_studio.server.Models
{
    /// <summary>
    /// Represents an architectural project
    /// </summary>
    public class Project : AuditableEntity
    {
        // Primary Key
        public string? ProYea { get; set; }  // Project registration year
        public string? ProCod { get; set; }  // Unique project code

        // Project Information
        public string? ProNam { get; set; }  // Project name
        public string? ProDes { get; set; }  // Description
        public string? ProSta { get; set; }  // Status code (FK to TB_PROJECT_STATUS)
        public string? ProStaNam { get; set; } // Status name (from join)
        public string? ProStaIco { get; set; } // Status icon (from join)
        public string? ProStaCol { get; set; } // Status color (from join)
        public int? ProPro { get; set; }     // Progress (0-100)
        public DateTime? ProDatIni { get; set; } // Start date
        public DateTime? ProDatEnd { get; set; } // Estimated end date
        public decimal? ProBudget { get; set; } // Budget amount
        public string? ProAdd { get; set; }  // Project address/location

        // Foreign Keys - Client
        public string? CliYea { get; set; }  // Client year
        public string? CliCod { get; set; }  // Client code
        public string? CliNam { get; set; }  // Client name (from join)

        // Foreign Keys - Manager (User)
        public string? UseYea { get; set; }  // User year (project manager)
        public string? UseCod { get; set; }  // User code (project manager)
        public string? UseNam { get; set; }  // Manager first name (from join)
        public string? UseLas { get; set; }  // Manager last name (from join)

        // Pagination (not persisted)
        public int? PageNumber { get; set; }
        public int? PageSize { get; set; }
        public int? TotalCount { get; set; }

        // Navigation properties
        public List<Budget>? Budgets { get; set; }
        public List<Document>? Documents { get; set; }
    }

    /// <summary>
    /// Project status catalog item
    /// </summary>
    public class ProjectStatus
    {
        public string? ProSta { get; set; }
        public string? ProStaNam { get; set; }
        public int? ProStaOrd { get; set; }
        public string? ProStaIco { get; set; }
        public string? ProStaCol { get; set; }
    }
}
