// *****************************************************************************************************
// Description       : Model for system activity logging
// Created by        : Enzo Gago Aguirre
// Creation Date     : 10/02/2025
// Purpose           : Stores detailed information about actions performed in the system
// *****************************************************************************************************

namespace archi_studio.server.Models
{
    /// <summary>
    /// Represents an activity log entry in the system
    /// </summary>
    public class Log
    {
        /// <summary>
        /// Log registration year
        /// </summary>
        public string? LogYea { get; set; }

        /// <summary>
        /// Unique log code
        /// </summary>
        public string? LogCod { get; set; }

        /// <summary>
        /// Detailed log description
        /// </summary>
        public string? LogDes { get; set; }

        /// <summary>
        /// Action performed (e.g., INSERT, UPDATE, DELETE)
        /// </summary>
        public string? LogAct { get; set; }

        /// <summary>
        /// IP address of the machine that performed the action
        /// </summary>
        public string? LogIpMac { get; set; }

        /// <summary>
        /// Code of the affected record
        /// </summary>
        public string? LogCodRec { get; set; }

        /// <summary>
        /// Name of the affected table
        /// </summary>
        public string? LogNamTab { get; set; }

        /// <summary>
        /// SQL query executed
        /// </summary>
        public string? LogSql { get; set; }

        /// <summary>
        /// Start date and time of the action
        /// </summary>
        public DateTime? LogDatSta { get; set; }

        /// <summary>
        /// End date and time of the action
        /// </summary>
        public DateTime? LogDatEnd { get; set; }

        /// <summary>
        /// Log type
        /// </summary>
        public string? LogTyp { get; set; }

        /// <summary>
        /// Year of the user who performed the action
        /// </summary>
        public string? UseYea { get; set; }

        /// <summary>
        /// Code of the user who performed the action
        /// </summary>
        public string? UseCod { get; set; }

        /// <summary>
        /// First name of the user who performed the action
        /// </summary>
        public string? UseNam { get; set; }

        /// <summary>
        /// Last name of the user who performed the action
        /// </summary>
        public string? UseLas { get; set; }

        /// <summary>
        /// Role code of the user (01=Admin, 02=User, 03=Supervisor)
        /// </summary>
        public string? RolCod { get; set; }

        /// <summary>
        /// Avatar of the user who performed the action
        /// </summary>
        public string? UseAva { get; set; }

        /// <summary>
        /// Gender of the user who performed the action
        /// </summary>
        public string? UseSex { get; set; }
    }
}
