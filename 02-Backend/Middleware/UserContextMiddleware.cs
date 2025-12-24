// *****************************************************************************************************
// Description       : User Context Middleware with IMemoryCache
// Created by        : Enzo Gago Aguirre  
// Creation Date     : 24/12/2025
// Purpose           : Caches user data in memory to avoid DB query per request
// Best Practice     : ASP.NET Core 9 IMemoryCache pattern for user context
// *****************************************************************************************************

using Microsoft.Extensions.Caching.Memory;
using archi_studio.server.Data.Interfaces;
using archi_studio.server.Models;

namespace archi_studio.server.Middleware
{
    /// <summary>
    /// Middleware that caches user context data in IMemoryCache.
    /// Only queries DB when cache miss occurs (every 5 minutes per user).
    /// Sets UserContext in HttpContext.Items for LogHelper consumption.
    /// </summary>
    public class UserContextMiddleware
    {
        private readonly RequestDelegate _next;

        public UserContextMiddleware(RequestDelegate next)
        {
            _next = next;
        }

        public async Task InvokeAsync(HttpContext context, IMemoryCache cache, IUserRepository userRepo)
        {
            // Only process authenticated requests
            if (context.User.Identity?.IsAuthenticated == true)
            {
                var clerkUserId = context.User.FindFirst("sub")?.Value 
                               ?? context.User.FindFirst("user_id")?.Value
                               ?? context.User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;

                if (!string.IsNullOrEmpty(clerkUserId))
                {
                    var cacheKey = $"UserContext_{clerkUserId}";
                    
                    // Try to get from cache
                    if (!cache.TryGetValue(cacheKey, out UserContext? userContext))
                    {
                        // Cache miss - query DB
                        var dbUser = await userRepo.GetByExternalId(clerkUserId);
                        
                        if (dbUser != null)
                        {
                            userContext = new UserContext
                            {
                                UseYea = dbUser.UseYea?.Trim(),
                                UseCod = dbUser.UseCod?.Trim(),
                                UseNam = dbUser.UseNam?.Trim(),
                                UseLas = dbUser.UseLas?.Trim(),
                                RolCod = dbUser.RolCod?.Trim()
                            };
                            
                            // Cache for 5 minutes with sliding expiration
                            var cacheOptions = new MemoryCacheEntryOptions()
                                .SetSlidingExpiration(TimeSpan.FromMinutes(5))
                                .SetAbsoluteExpiration(TimeSpan.FromMinutes(30));
                            
                            cache.Set(cacheKey, userContext, cacheOptions);
                        }
                    }
                    
                    // Set in HttpContext.Items for current request
                    if (userContext != null)
                    {
                        context.Items["UserContext"] = userContext;
                    }
                }
            }

            await _next(context);
        }
    }

    /// <summary>
    /// Extension methods for UserContextMiddleware registration
    /// </summary>
    public static class UserContextMiddlewareExtensions
    {
        public static IApplicationBuilder UseUserContext(this IApplicationBuilder builder)
        {
            return builder.UseMiddleware<UserContextMiddleware>();
        }
    }
}
