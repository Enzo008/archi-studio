// *****************************************************************************************************
// Description       : Model representing a navigation menu item
// Created by        : Enzo Gago Aguirre
// Creation Date     : 10/02/2025
// Purpose           : Stores navigation menu items for role-based access
// *****************************************************************************************************

using archi_studio.server.Models.Base;

namespace archi_studio.server.Models
{
    /// <summary>
    /// Represents a navigation menu item in the system
    /// </summary>
    public class Menu : AuditableEntity
    {
        // Primary Key
        public string? MenCod { get; set; }      // Menu code (e.g., "01", "0101")

        // Hierarchy
        public string? MenCodPar { get; set; }   // Parent menu code (null for root)

        // Menu Info
        public string? MenNam { get; set; }      // Display name
        public string? MenRef { get; set; }      // Route/path (e.g., "/dashboard")
        public string? MenIco { get; set; }      // Icon name (e.g., "LayoutDashboard")
        public int? MenOrd { get; set; }         // Display order

        // Navigation property
        public List<Menu>? Children { get; set; }
    }
}
