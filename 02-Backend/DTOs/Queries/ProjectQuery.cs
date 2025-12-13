// *****************************************************************************************************
// Description       : Query DTO for project list filtering
// Created by        : Gemini Code Assist
// Creation Date     : 10/12/2025
// Purpose           : Clean separation of query parameters from Project entity
// *****************************************************************************************************

namespace archi_studio.server.DTOs.Queries
{
    /// <summary>
    /// Query parameters for filtering and paginating projects
    /// </summary>
    public class ProjectQuery : BaseQuery
    {
        public string? Status { get; set; }
        public string? CliYea { get; set; }
        public string? CliCod { get; set; }
        public string? UseYea { get; set; }
        public string? UseCod { get; set; }
    }
}
