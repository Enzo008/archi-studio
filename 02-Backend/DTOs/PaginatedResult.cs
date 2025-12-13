// *****************************************************************************************************
// Description       : Generic paginated result for API responses
// Created by        : Gemini Code Assist
// Creation Date     : 10/12/2025
// Purpose           : Separate pagination concerns from domain models (SRP)
// *****************************************************************************************************

namespace archi_studio.server.DTOs
{
    /// <summary>
    /// Generic wrapper for paginated results following SOLID principles
    /// </summary>
    /// <typeparam name="T">Type of items in the result</typeparam>
    public class PaginatedResult<T>
    {
        public List<T> Items { get; set; } = new();
        public int TotalCount { get; set; }
        public int Page { get; set; }
        public int PageSize { get; set; }
        public int TotalPages => (int)Math.Ceiling((double)TotalCount / PageSize);
        public bool HasNext => Page < TotalPages;
        public bool HasPrevious => Page > 1;

        public PaginatedResult() { }

        public PaginatedResult(List<T> items, int totalCount, int page, int pageSize)
        {
            Items = items;
            TotalCount = totalCount;
            Page = page;
            PageSize = pageSize;
        }
    }
}
