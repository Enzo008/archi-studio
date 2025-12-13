// *****************************************************************************************************
// Descripcion       : Clase abstracta que define las fabricas de repositorios
// Creado por        : Enzo Gago Aguirre
// Fecha de Creacion : 10/02/2025
// Accion a Realizar : Crear conexiones a diferentes bases de datos segun el tipo especificado
// *****************************************************************************************************

using archi_studio.server.Data.Interfaces;
using archi_studio.server.Data.Repositories.SqlServer;

namespace archi_studio.server.Data.Factory
{
    public abstract class RepositoryFactory
    {
        public const string SQLSERVER = "SQLSERVER";
        
        private static RepositoryFactory? clsInstanceSqlServer;
        
        public static RepositoryFactory GetInstanceSqlServer(IConfiguration iConfiguration)
        {
            return clsInstanceSqlServer ??= GetRepositoryFactory(SQLSERVER, 
                iConfiguration.GetConnectionString("ConnectionStringSqlServer") ?? "");
        }

        public static RepositoryFactory GetRepositoryFactory(string strDatabaseType, string strConnectionString)
        {
            return strDatabaseType.ToUpper() switch
            {
                SQLSERVER => new SqlServerRepositoryFactory(strConnectionString),
                _ => throw new ArgumentException($"Tipo de base de datos no soportado: {strDatabaseType}")
            };
        }

        // Repositorios disponibles
        public abstract IUserRepository GetUserRepository();
        public abstract IRoleRepository GetRoleRepository();
        public abstract ILogRepository GetLogRepository();
        public abstract IClientRepository GetClientRepository();
        public abstract IProjectRepository GetProjectRepository();
        public abstract IBudgetRepository GetBudgetRepository();
        public abstract IDocumentRepository GetDocumentRepository();
    }
}