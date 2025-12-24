// *****************************************************************************************************
// Descripción       : Punto de entrada principal de la aplicación web API
// Creado por        : Enzo Gago Aguirre
// Fecha de Creación : 11/02/2025
// Acción a Realizar : Configuración y ejecución del servidor web API
// *****************************************************************************************************

using System.Globalization;
using System.Text.Json.Serialization;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using archi_studio.server.Config;
using archi_studio.server.Data.Helper;
using archi_studio.server.Data.Factory;
using archi_studio.server.Data.Interfaces;
using Microsoft.AspNetCore.Http.Features;
using Microsoft.AspNetCore.Server.IIS;

namespace archi_studio.server
{
    public class Program
    {
        public static void Main(string[] args)
        {
            // Configuración de globalización para el servidor
            ConfigureGlobalization();

            // Crear y configurar la aplicación
            var builder = CreateAndConfigureBuilder(args);

            // Construir y configurar el pipeline HTTP
            var app = ConfigureApplication(builder);

            // Ejecutar la aplicación
            app.Run();
        }

        private static void ConfigureGlobalization()
        {
            AppContext.SetSwitch("System.Globalization.Invariant", false);
            Thread.CurrentThread.CurrentCulture = new CultureInfo("es-ES");
            Thread.CurrentThread.CurrentUICulture = new CultureInfo("es-ES");
            CultureInfo.DefaultThreadCurrentCulture = new CultureInfo("es-ES");
            CultureInfo.DefaultThreadCurrentUICulture = new CultureInfo("es-ES");
        }

        private static WebApplicationBuilder CreateAndConfigureBuilder(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);
            
            // En producción, Kestrel usa ASPNETCORE_URLS del entorno
            // En desarrollo, usa launchSettings.json

            // Configurar servicios básicos
            ConfigureBasicServices(builder);

            // Configurar autenticación JWT
            ConfigureJwtAuthentication(builder);

            // Configurar controladores y opciones JSON
            ConfigureControllersAndJson(builder);

            // Configurar contexto HTTP
            builder.Services.AddHttpContextAccessor();

            // Configurar CORS
            ConfigureCors(builder);

            return builder;
        }

        private static void ConfigureBasicServices(WebApplicationBuilder builder)
        {
            builder.Services.AddMemoryCache();
            builder.Services.AddHttpClient();
            builder.Services.AddScoped<LogHelper>();
            builder.Services.AddSingleton<AppSettings>();

            // Register RepositoryFactory as singleton (manages connection string)
            builder.Services.AddSingleton(sp => 
                RepositoryFactory.GetInstanceSqlServer(builder.Configuration));

            // Register repositories via DI (using factory pattern)
            builder.Services.AddScoped<IUserRepository>(sp => 
                sp.GetRequiredService<RepositoryFactory>().GetUserRepository());
            builder.Services.AddScoped<IRoleRepository>(sp => 
                sp.GetRequiredService<RepositoryFactory>().GetRoleRepository());
            builder.Services.AddScoped<ILogRepository>(sp => 
                sp.GetRequiredService<RepositoryFactory>().GetLogRepository());
            builder.Services.AddScoped<IClientRepository>(sp => 
                sp.GetRequiredService<RepositoryFactory>().GetClientRepository());
            builder.Services.AddScoped<IProjectRepository>(sp => 
                sp.GetRequiredService<RepositoryFactory>().GetProjectRepository());
            builder.Services.AddScoped<IBudgetRepository>(sp => 
                sp.GetRequiredService<RepositoryFactory>().GetBudgetRepository());
            builder.Services.AddScoped<IDocumentRepository>(sp => 
                sp.GetRequiredService<RepositoryFactory>().GetDocumentRepository());
        }

        /// <summary>
        /// Configura la autenticación JWT para tokens de Clerk.
        /// Clerk usa RS256 (claves asimétricas) y publica sus claves en un JWKS endpoint.
        /// </summary>
        private static void ConfigureJwtAuthentication(WebApplicationBuilder builder)
        {
            // Obtener el dominio de Clerk desde la configuración
            var clerkDomain = builder.Configuration["Clerk:Domain"] 
                ?? "first-jawfish-39.clerk.accounts.dev";
            
            var authority = $"https://{clerkDomain}";
            
            Console.WriteLine($"Configurando autenticación Clerk con dominio: {clerkDomain}");
            
            builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
                .AddJwtBearer(options =>
                {
                    // Clerk usa OIDC, configurar Authority para obtener JWKS automáticamente
                    options.Authority = authority;
                    
                    options.TokenValidationParameters = new TokenValidationParameters
                    {
                        ValidateIssuer = true,
                        ValidIssuer = authority,
                        ValidateAudience = false, // Clerk no usa audience por defecto
                        ValidateLifetime = true,
                        ValidateIssuerSigningKey = true,
                        ClockSkew = TimeSpan.FromMinutes(1)
                    };
                    
                    // Eventos de depuración
                    options.Events = new JwtBearerEvents
                    {
                        OnAuthenticationFailed = context =>
                        {
                            Console.WriteLine($"❌ Auth failed: {context.Exception.Message}");
                            return Task.CompletedTask;
                        },
                        OnTokenValidated = context =>
                        {
                            var userId = context.Principal?.FindFirst("user_id")?.Value 
                                      ?? context.Principal?.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
                            Console.WriteLine($"✅ Token validado para usuario: {userId}");
                            return Task.CompletedTask;
                        }
                    };
                });
        }

        private static void ConfigureControllersAndJson(WebApplicationBuilder builder)
        {
            // Configurar límites para permitir archivos grandes (hasta 100MB)
            builder.Services.AddControllers()
            .AddJsonOptions(options =>
            {
                options.JsonSerializerOptions.ReferenceHandler = ReferenceHandler.IgnoreCycles;
                options.JsonSerializerOptions.WriteIndented = true;
            });
            
            // Configurar límites de tamaño para la carga de archivos
            builder.Services.Configure<IISServerOptions>(options =>
            {
                options.MaxRequestBodySize = 104857600; // 100MB en bytes
            });
            
            // Configurar límites de tamaño para el formateador de formularios
            builder.Services.Configure<FormOptions>(options =>
            {
                options.MultipartBodyLengthLimit = 104857600; // 100MB en bytes
                options.ValueLengthLimit = int.MaxValue;
                options.MultipartHeadersLengthLimit = int.MaxValue;
            });
        }

        private static void ConfigureCors(WebApplicationBuilder builder)
        {
            // Obtener la configuración de CORS
            var corsSettings = builder.Configuration.GetSection("CorsSettings").Get<Config.CorsSettings>();
            var defaultOrigins = new[] 
            { 
                "http://localhost:3000",
                "http://localhost:4200",
                "https://localhost:5173",
                "http://localhost:5174"
            };
            
            builder.Services.AddCors(options =>
            {
                options.AddPolicy("AllowedOrigins",
                    policy =>
                    {
                        var origins = corsSettings?.AllowedOrigins;
                        if (origins == null || origins.Length == 0)
                        {
                            origins = defaultOrigins;
                        }
                        
                        var policyBuilder = policy.WithOrigins(origins);

                        if (corsSettings?.AllowAnyMethod ?? true)
                            policyBuilder.AllowAnyMethod();

                        if (corsSettings?.AllowAnyHeader ?? true)
                            policyBuilder.AllowAnyHeader();

                        if (corsSettings?.AllowCredentials ?? true)
                            policyBuilder.AllowCredentials();
                            
                        // Exponer encabezados necesarios para la descarga de archivos
                        policyBuilder.WithExposedHeaders("Content-Disposition", "Content-Length", "Content-Type");
                    });
            });
        }

        private static WebApplication ConfigureApplication(WebApplicationBuilder builder)
        {
            var app = builder.Build();

            // Configurar middleware de CORS
            app.UseCors("AllowedOrigins");
            
            if (app.Environment.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }
            else
            {
                app.UseExceptionHandler("/Error");
                // app.UseHsts();
            }
            
            // Configurar pipeline de autenticación y autorización
            // app.UseHttpsRedirection();
            app.UseAuthentication();
            app.UseAuthorization();

            // Configurar rutas API
            app.MapControllers();
            
            // Configurar para servir archivos de uploads (documentos subidos)
            // SIN Content-Disposition para permitir preview inline
            var uploadsPath = Path.Combine(Directory.GetCurrentDirectory(), "uploads");
            if (!Directory.Exists(uploadsPath))
            {
                Directory.CreateDirectory(uploadsPath);
            }
            
            app.UseStaticFiles(new StaticFileOptions
            {
                FileProvider = new Microsoft.Extensions.FileProviders.PhysicalFileProvider(uploadsPath),
                RequestPath = "/uploads"
            });
            
            // Configurar para servir archivos estáticos y la aplicación SPA
            app.UseDefaultFiles();
            app.UseStaticFiles();
            
            // Configurar para que todas las rutas no API se redirijan al index.html para React Router
            app.MapFallbackToFile("index.html");

            return app;
        }
    }

    public class CorsSettings
    {
        public string[] AllowedOrigins { get; set; } = Array.Empty<string>();
        public bool AllowAnyMethod { get; set; } = true;
        public bool AllowAnyHeader { get; set; } = true;
        public bool AllowCredentials { get; set; } = true;
    }
}
