// *****************************************************************************************************
// Description       : Model representing a client/customer
// Created by        : Enzo Gago Aguirre
// Creation Date     : 09/12/2025
// Purpose           : Stores client information for project management
// *****************************************************************************************************

using archi_studio.server.Models.Base;

namespace archi_studio.server.Models
{
    /// <summary>
    /// Represents a client or customer
    /// </summary>
    public class Client : AuditableEntity
    {
        // Primary Key
        public string? CliYea { get; set; }  // Client registration year
        public string? CliCod { get; set; }  // Unique client code

        // Client Information
        public string? CliNam { get; set; }  // Name / Business name
        public string? CliTyp { get; set; }  // Type: 01=Person, 02=Company
        public string? CliEma { get; set; }  // Email
        public string? CliPho { get; set; }  // Phone
        public string? CliAdd { get; set; }  // Address
        public char? CliSta { get; set; }    // Status: A=Active, I=Inactive
        public string? CliDes { get; set; }  // Description/Notes

        // Pagination (not persisted)
        public int? PageNumber { get; set; }
        public int? PageSize { get; set; }
        public int? TotalCount { get; set; }

        // Multi-tenancy filter (owner user)
        public string? UseYea { get; set; }
        public string? UseCod { get; set; }
    }
}
