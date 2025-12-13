using Microsoft.AspNetCore.Http;
using System.Threading.Tasks;
using archi_studio.server.Data.Helper;

namespace archi_studio.server.Middleware
{
    public class TokenValidationMiddleware
    {
        private readonly RequestDelegate _next;

        public TokenValidationMiddleware(RequestDelegate next)
        {
            _next = next;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            var authHeader = context.Request.Headers["Authorization"].ToString();
            if (!string.IsNullOrEmpty(authHeader) && authHeader.StartsWith("Bearer "))
            {
                var token = authHeader.Substring("Bearer ".Length);
                if (SecurityHelper.IsTokenInvalidated(token))
                {
                    context.Response.StatusCode = 401; // Unauthorized
                    await context.Response.WriteAsJsonAsync(new
                    {
                        Success = false,
                        Message = "Token invalidado o expirado",
                        MessageType = "Error"
                    });
                    return;
                }
            }

            await _next(context);
        }
    }
}
