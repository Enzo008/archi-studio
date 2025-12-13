// *****************************************************************************************************
// Description       : Query DTO for client list filtering
// Created by        : Gemini Code Assist
// Creation Date     : 10/12/2025
// Purpose           : Clean separation of query parameters from Client entity
// *****************************************************************************************************

namespace archi_studio.server.DTOs.Queries
{
    /// <summary>
    /// Query parameters for filtering and paginating clients
    /// </summary>
    public class ClientQuery : BaseQuery
    {
        public string? Type { get; set; }
        public char? Status { get; set; }
    }
}
