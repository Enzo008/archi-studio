// *****************************************************************************************************
// Descripción       : Clase de ayuda para las principales funcionalidades de seguridad del sistema
// Creado por        : Enzo Gago Aguirre
// Fecha de Creación : 10/02/2025
// Acción a Realizar : Generar un token de seguridad JWT para autenticación
// *****************************************************************************************************

// Extensiones
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
// Modelos
using archi_studio.server.Models;

namespace archi_studio.server.Data.Helper
{
    public class SecurityHelper
    {
        // Usar HashSet para búsqueda O(1)
        private static readonly HashSet<string> invalidatedTokens = new HashSet<string>();
        private static readonly object lockObject = new object();

        /// <summary>
        /// Clave por defecto que se utilizará si no se encuentra la clave en la configuración.
        /// IMPORTANTE: Esta clave debe coincidir con la clave en appsettings.Production.json
        /// para garantizar la consistencia en la validación de tokens.
        /// </summary>
        private static readonly string DEFAULT_SECRET_KEY = "03qQXpA0X3Z6O6RWbPOR1SizVCx0QHL1";
        
        /// <summary>
        /// Instancia de configuración que se utiliza para obtener la clave secreta.
        /// Esta instancia se establece desde Program.cs al inicio de la aplicación.
        /// </summary>
        private static IConfiguration? _configuration;
        
        /// <summary>
        /// Establece la configuración para que SecurityHelper pueda acceder a los valores
        /// de configuración, especialmente la clave secreta para JWT.
        /// Este método debe llamarse al inicio de la aplicación desde Program.cs.
        /// </summary>
        /// <param name="configuration">La instancia de IConfiguration de la aplicación</param>
        public static void SetConfiguration(IConfiguration configuration)
        {
            _configuration = configuration;
            // Registrar que se ha establecido la configuración
            Console.WriteLine("SecurityHelper: Configuración establecida correctamente");
        }

        /// <summary>
        /// Genera un token JWT (JSON Web Token) para un User específico.
        /// Este token servirá como credencial de autenticación para las solicitudes del User.
        /// 
        /// IMPORTANTE: Este método utiliza la clave secreta de la configuración (JwtSettings:SecretKey)
        /// o la clave por defecto (DEFAULT_SECRET_KEY) si la configuración no está disponible.
        /// La misma clave debe utilizarse para validar el token en AuthenticationController.ValidateSession.
        /// </summary>
        /// <param name="bUser">Objeto User que contiene la información del User</param>
        /// <param name="keepSession">Si true, el token durará 30 días; si false, durará 8 horas</param>
        /// <returns>String que representa el token JWT generado</returns>
        public static string GenerateToken(User bUser, bool keepSession = false)
        {
            // 1. Crear claims (información del User que se incluirá en el token)
            var listClaims = new List<Claim>
            {
                new Claim("USEYEA", bUser.UseYea ?? ""),
                new Claim("USECOD", bUser.UseCod ?? ""),
                new Claim("USENAM", bUser.UseNam ?? ""),
                new Claim("USELAS", bUser.UseLas ?? ""),
                new Claim("ROLCOD", bUser.RolCod ?? "02"), // Role code for multi-tenancy
                new Claim(ClaimTypes.Email, bUser.UseEma ?? ""),
                // Agregar un claim para el ID del token
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
            };

            // 2. Obtener la clave secreta para firmar el token
            string secretKey;
            
            // Intentar obtener la clave de la configuración
            if (_configuration != null)
            {
                secretKey = _configuration["JwtSettings:SecretKey"] ?? DEFAULT_SECRET_KEY;
                // Registrar la clave que se está utilizando (solo para depuración)
                Console.WriteLine($"Usando clave de configuración para generar token: {secretKey.Substring(0, 5)}...");
            }
            else
            {
                secretKey = DEFAULT_SECRET_KEY;
                Console.WriteLine("Advertencia: Usando clave por defecto para generar token");
            }
            
            var bytKey = Encoding.ASCII.GetBytes(secretKey);
            
            // Crear una clave simétrica
            var signingKey = new SymmetricSecurityKey(bytKey);

            // 3. Configurar los parámetros del token con duración variable
            var expiryTime = keepSession ? DateTime.UtcNow.AddDays(30) : DateTime.UtcNow.AddHours(8);
            
            var clsTokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(listClaims),       // Información del User
                Expires = expiryTime,                           // Token válido por 8 horas o 30 días
                SigningCredentials = new SigningCredentials(     // Credenciales de firma
                    signingKey,                                 // Clave simétrica para firmar
                    SecurityAlgorithms.HmacSha256Signature),    // Algoritmo de firma
                IssuedAt = DateTime.UtcNow,                     // Fecha de emisión
                NotBefore = DateTime.UtcNow                     // Fecha desde la que es válido
            };

            // 4. Crear y devolver el token
            var clsTokenHandler = new JwtSecurityTokenHandler();
            var token = clsTokenHandler.CreateToken(clsTokenDescriptor);
            return clsTokenHandler.WriteToken(token);              // Convertir el token a string
        }

        /// <summary>
        /// Invalida un token JWT para que no pueda ser usado en futuras peticiones
        /// </summary>
        /// <param name="token">Token JWT a invalidar</param>
        public static void InvalidateToken(string token)
        {
            if (string.IsNullOrEmpty(token)) return;

            lock (lockObject)
            {
                invalidatedTokens.Add(token);
            }

            // Programar la limpieza del token cuando expire
            var handler = new JwtSecurityTokenHandler();
            if (handler.CanReadToken(token))
            {
                var jwtToken = handler.ReadJwtToken(token);
                var expiryTime = jwtToken.ValidTo;
                
                // Programar la eliminación del token cuando expire
                Task.Delay(expiryTime - DateTime.UtcNow)
                    .ContinueWith(_ =>
                    {
                        lock (lockObject)
                        {
                            invalidatedTokens.Remove(token);
                        }
                    });
            }
        }

        /// <summary>
        /// Verifica si un token está invalidado
        /// </summary>
        /// <param name="token">Token JWT a verificar</param>
        /// <returns>true si el token está invalidado, false en caso contrario</returns>
        public static bool IsTokenInvalidated(string token)
        {
            if (string.IsNullOrEmpty(token)) return true;

            lock (lockObject)
            {
                return invalidatedTokens.Contains(token);
            }
        }

        /// <summary>
        /// Obtiene la fecha de expiración de un token JWT
        /// </summary>
        /// <param name="token">Token JWT</param>
        /// <returns>Fecha de expiración del token</returns>
        public static DateTime GetTokenExpiration(string token)
        {
            if (string.IsNullOrEmpty(token)) return DateTime.MinValue;

            try
            {
                var handler = new JwtSecurityTokenHandler();
                if (handler.CanReadToken(token))
                {
                    var jwtToken = handler.ReadJwtToken(token);
                    return jwtToken.ValidTo;
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error al obtener expiración del token: {ex.Message}");
            }

            return DateTime.MinValue;
        }
    }
}