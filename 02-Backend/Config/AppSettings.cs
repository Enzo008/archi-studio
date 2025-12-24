using Microsoft.Extensions.Configuration;

namespace archi_studio.server.Config
{
    /// <summary>
    /// Clase para centralizar el acceso a las configuraciones de la aplicación
    /// </summary>
    public class AppSettings
    {
        private readonly IConfiguration _configuration;

        public AppSettings(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        /// <summary>
        /// Configuración de JWT
        /// </summary>
        public JwtSettings JwtSettings => _configuration.GetSection("JwtSettings").Get<JwtSettings>() ?? new JwtSettings();

        /// <summary>
        /// Configuración de CORS
        /// </summary>
        public CorsSettings CorsSettings => _configuration.GetSection("CorsSettings").Get<CorsSettings>() ?? new CorsSettings();

        /// <summary>
        /// Cadenas de conexión
        /// </summary>
        public ConnectionStrings ConnectionStrings => _configuration.GetSection("ConnectionStrings").Get<ConnectionStrings>() ?? new ConnectionStrings();

        /// <summary>
        /// Configuración de Email
        /// </summary>
        public EmailSettings EmailSettings => _configuration.GetSection("EmailSettings").Get<EmailSettings>() ?? new EmailSettings();

        /// <summary>
        /// Obtiene la URL base de la aplicación
        /// </summary>
        public string BaseUrl
        {
            get
            {
                var env = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT");
                return env == "Development" 
                    ? "http://localhost:5089" 
                    : "https://archi-studio-eight.vercel.app";
            }
        }
    }

    /// <summary>
    /// Configuración de JWT
    /// </summary>
    public class JwtSettings
    {
        public string SecretKey { get; set; } = string.Empty;
    }

    /// <summary>
    /// Configuración de CORS
    /// </summary>
    public class CorsSettings
    {
        public string[] AllowedOrigins { get; set; } = Array.Empty<string>();
        public bool AllowAnyMethod { get; set; } = true;
        public bool AllowAnyHeader { get; set; } = true;
        public bool AllowCredentials { get; set; } = true;
    }

    /// <summary>
    /// Cadenas de conexión
    /// </summary>
    public class ConnectionStrings
    {
        public string ConnectionStringSqlServer { get; set; } = string.Empty;
    }

    /// <summary>
    /// Configuración de Email
    /// </summary>
    public class EmailSettings
    {
        public string SmtpServer { get; set; } = string.Empty;
        public int SmtpPort { get; set; } = 587;
        public string SmtpUsername { get; set; } = string.Empty;
        public string SmtpPassword { get; set; } = string.Empty;
        public string SenderEmail { get; set; } = string.Empty;
        public string SenderName { get; set; } = string.Empty;
        public bool EnableSsl { get; set; } = true;
        public int TimeoutSeconds { get; set; } = 30;
    }
}
