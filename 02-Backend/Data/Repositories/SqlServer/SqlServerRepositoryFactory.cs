// *****************************************************************************************************
// Descripcion       : Implementacion de fabrica de repositorios para SQL Server
// Creado por        : Enzo Gago Aguirre
// Fecha de Creacion : 10/02/2025
// Accion a Realizar : Crear instancias de repositorios para SQL Server
// *****************************************************************************************************

using archi_studio.server.Data.Factory;
using archi_studio.server.Data.Interfaces;

namespace archi_studio.server.Data.Repositories.SqlServer
{
    public class SqlServerRepositoryFactory : RepositoryFactory
    {
        private readonly string _connectionString;

        // Instancias singleton de repositorios
        private SqlServerUserRepository? _userRepository;
        private SqlServerRoleRepository? _roleRepository;
        private SqlServerLogRepository? _logRepository;
        private SqlServerClientRepository? _clientRepository;
        private SqlServerProjectRepository? _projectRepository;
        private SqlServerBudgetRepository? _budgetRepository;
        private SqlServerDocumentRepository? _documentRepository;

        public SqlServerRepositoryFactory(string connectionString)
        {
            _connectionString = connectionString;
        }

        public override IUserRepository GetUserRepository()
        {
            return _userRepository ??= new SqlServerUserRepository(_connectionString);
        }

        public override IRoleRepository GetRoleRepository()
        {
            return _roleRepository ??= new SqlServerRoleRepository(_connectionString);
        }

        public override ILogRepository GetLogRepository()
        {
            return _logRepository ??= new SqlServerLogRepository();
        }

        public override IClientRepository GetClientRepository()
        {
            return _clientRepository ??= new SqlServerClientRepository(_connectionString);
        }

        public override IProjectRepository GetProjectRepository()
        {
            return _projectRepository ??= new SqlServerProjectRepository(_connectionString);
        }

        public override IBudgetRepository GetBudgetRepository()
        {
            return _budgetRepository ??= new SqlServerBudgetRepository(_connectionString);
        }

        public override IDocumentRepository GetDocumentRepository()
        {
            return _documentRepository ??= new SqlServerDocumentRepository(_connectionString);
        }
    }
}
