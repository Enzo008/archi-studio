// *****************************************************************************************************
// Description       : Model representing a system user
// Created by        : Enzo Gago Aguirre
// Creation Date     : 10/02/2025
// Purpose           : Stores user information synced from Clerk with role assignment
// *****************************************************************************************************

using archi_studio.server.Models.Base;

namespace archi_studio.server.Models
{
    /// <summary>
    /// Represents a system user with Clerk authentication
    /// </summary>
    public class User : AuditableEntity
    {
        // Primary Key
        public string? UseYea { get; set; }  // User registration year
        public string? UseCod { get; set; }  // Unique user code

        // Clerk Integration
        public string? UseExtId { get; set; } // External ID from Clerk (user_xxxx)

        // User Information
        public string? UseNam { get; set; }  // First name
        public string? UseLas { get; set; }  // Last name
        public string? UseEma { get; set; }  // Email
        public string? UseImg { get; set; }  // Profile image URL

        // Role Assignment
        public string? RolCod { get; set; }  // Role code (FK to TB_ROLE)
        public string? RolNam { get; set; }  // Role name (from join)

        // Status
        public char? UseSta { get; set; }    // Status: A=Active, I=Inactive

        // Last Access
        public DateTime? UseLastAccess { get; set; } // Last login timestamp

        // Pagination (not persisted)
        public int? PageNumber { get; set; }
        public int? PageSize { get; set; }
        public int? TotalCount { get; set; }

        // Navigation property
        public List<Menu>? Menus { get; set; }
    }

    /// <summary>
    /// DTO for Clerk user synchronization
    /// </summary>
    public class SyncUserRequest
    {
        public required string ExternalId { get; set; }
        public required string Email { get; set; }
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public string? ImageUrl { get; set; }
    }

    /// <summary>
    /// Response from user sync operation
    /// </summary>
    public class SyncUserResponse
    {
        public bool IsNewUser { get; set; }
        public string? UseYea { get; set; }
        public string? UseCod { get; set; }
        public string? UseNam { get; set; }
        public string? UseLas { get; set; }
        public string? RolCod { get; set; }
        public string? RolNam { get; set; }
        public List<Menu>? Menus { get; set; }
    }
}
