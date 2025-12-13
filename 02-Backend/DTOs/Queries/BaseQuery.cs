// *****************************************************************************************************
// Description       : Base query DTO for pagination parameters
// Created by        : Gemini Code Assist
// Creation Date     : 10/12/2025
// Purpose           : Centralize pagination parameters following DRY principle
// *****************************************************************************************************

namespace archi_studio.server.DTOs.Queries
{
    /// <summary>
    /// Base class for all query DTOs with pagination support
    /// </summary>
    public abstract class BaseQuery
    {
        public int Page { get; set; } = 1;
        public int PageSize { get; set; } = 10;
        public string? Search { get; set; }
    }
}
