# ════════════════════════════════════════════════════════════════════════════
# STAGE 1: Build
# ════════════════════════════════════════════════════════════════════════════
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Copy project file and restore dependencies
COPY ["archi_studio.server.csproj", "./"]
RUN dotnet restore "archi_studio.server.csproj"

# Copy all source files
COPY . .

# Build and publish the application
RUN dotnet publish "archi_studio.server.csproj" -c Release -o /app/publish /p:UseAppHost=false

# ════════════════════════════════════════════════════════════════════════════
# STAGE 2: Runtime
# ════════════════════════════════════════════════════════════════════════════
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app

# Install curl for healthcheck
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Copy published application from build stage
COPY --from=build /app/publish .

# Create uploads directory for file storage
RUN mkdir -p /app/uploads && chown -R app:app /app/uploads

# Switch to non-root user (built-in 'app' user from Microsoft's image)
USER app

# Expose port
EXPOSE 8080

# Set environment variables
ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD curl --fail http://localhost:8080/api/health || exit 1

# Run the application
ENTRYPOINT ["dotnet", "archi_studio.server.dll"]
