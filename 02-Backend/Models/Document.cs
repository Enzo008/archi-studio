// *****************************************************************************************************
// Description       : Model representing a document/file
// Created by        : Enzo Gago Aguirre
// Creation Date     : 09/12/2025
// Purpose           : Stores document/file information
// *****************************************************************************************************

using archi_studio.server.Models.Base;

namespace archi_studio.server.Models
{
    /// <summary>
    /// Represents a document or file
    /// </summary>
    public class Document : AuditableEntity
    {
        // Primary Key
        public string? DocYea { get; set; }  // Document registration year
        public string? DocCod { get; set; }  // Unique document code

        // Document Information
        public string? DocNam { get; set; }  // Document name
        public string? DocDes { get; set; }  // Description
        public string? DocTyp { get; set; }  // Type code (FK to TB_DOCUMENT_TYPE)
        public string? DocTypNam { get; set; } // Type name (from join)
        public string? DocTypIco { get; set; } // Type icon (from join)
        public string? DocPat { get; set; }  // Path/URL
        public string? DocFil { get; set; }  // Original filename
        public long? DocSiz { get; set; }    // Size in bytes
        public string? DocMim { get; set; }  // MIME type
        public char? DocSta { get; set; }    // Status: A=Active, I=Inactive

        // Foreign Keys - Project (optional)
        public string? ProYea { get; set; }  // Project year
        public string? ProCod { get; set; }  // Project code
        public string? ProNam { get; set; }  // Project name (from join)

        // Pagination (not persisted)
        public int? PageNumber { get; set; }
        public int? PageSize { get; set; }
        public int? TotalCount { get; set; }

        // Multi-tenancy filter (via project)
        public string? UseYea { get; set; }
        public string? UseCod { get; set; }
    }

    /// <summary>
    /// Document type catalog item
    /// </summary>
    public class DocumentType
    {
        public string? DocTyp { get; set; }
        public string? DocTypNam { get; set; }
        public string? DocTypIco { get; set; }
        public string? DocTypExt { get; set; } // Allowed extensions
    }
}
