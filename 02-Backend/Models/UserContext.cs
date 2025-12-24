// *****************************************************************************************************
// Description       : User context model for HttpContext caching
// Created by        : Enzo Gago Aguirre
// Creation Date     : 24/12/2025
// Purpose           : Holds user data cached in HttpContext.Items to avoid DB queries per request
// *****************************************************************************************************

namespace archi_studio.server.Models
{
    /// <summary>
    /// User context data cached in HttpContext.Items for the duration of a request.
    /// Populated from JWT claims or sync response.
    /// </summary>
    public class UserContext
    {
        public string? UseYea { get; set; }
        public string? UseCod { get; set; }
        public string? UseNam { get; set; }
        public string? UseLas { get; set; }
        public string? RolCod { get; set; }
        
        /// <summary>
        /// Returns true if context has valid user data
        /// </summary>
        public bool IsValid => !string.IsNullOrEmpty(UseYea) && !string.IsNullOrEmpty(UseCod);
    }
}
