// *****************************************************************************************************
// Description       : Base class for auditable entities
// Created by        : Enzo Gago Aguirre
// Creation Date     : 10/03/2025
// Purpose           : Provides common audit fields for all entities
// *****************************************************************************************************

namespace archi_studio.server.Models.Base
{
    /// <summary>
    /// Base class that provides audit fields for entities
    /// All entities that need audit tracking should inherit from this class
    /// </summary>
    public abstract class AuditableEntity
    {
        /// <summary>
        /// User who created the record
        /// </summary>
        public string? UseCre { get; set; }

        /// <summary>
        /// Creation date with full timezone (ISO 8601)
        /// </summary>
        public DateTimeOffset? DatCre { get; set; }

        /// <summary>
        /// Timezone name for record creation
        /// </summary>
        public string? ZonCre { get; set; }

        /// <summary>
        /// User who updated the record
        /// </summary>
        public string? UseUpd { get; set; }

        /// <summary>
        /// Update date with full timezone (ISO 8601)
        /// </summary>
        public DateTimeOffset? DatUpd { get; set; }

        /// <summary>
        /// Timezone name for record update
        /// </summary>
        public string? ZonUpd { get; set; }

        /// <summary>
        /// Status Record: C=Created, U=Updated, D=Deleted
        /// </summary>
        public char? StaRec { get; set; }
    }
}
