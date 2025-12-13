// *****************************************************************************************************
// Description       : Model representing a role in the system
// Created by        : Enzo Gago Aguirre
// Creation Date     : 10/02/2025
// Purpose           : Stores information about available roles
// *****************************************************************************************************

using archi_studio.server.Models.Base;

namespace archi_studio.server.Models
{
    /// <summary>
    /// Represents a role in the system
    /// </summary>
    public class Role : AuditableEntity
    {
        /// <summary>
        /// Unique role code
        /// </summary>
        public string? RolCod { get; set; }

        /// <summary>
        /// Role name
        /// </summary>
        public string? RolNam { get; set; }

        /// <summary>
        /// Role description
        /// </summary>
        public string? RolDes { get; set; }

        /// <summary>
        /// Menus assigned to the role
        /// </summary>
        public List<Menu>? Menus { get; set; }
    }
}
