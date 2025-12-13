// *****************************************************************************************************
// Descripción       : Utilidades comunes para el manejo de datos y operaciones del sistema
// Creado por        : Enzo Gago Aguirre
// Fecha de Creación : 10/02/2025
// Acción a Realizar : Proporcionar métodos de utilidad para deserialización y obtención de IP pública
// *****************************************************************************************************

using System;
using System.Data;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using Microsoft.Extensions.Caching.Memory;
using Newtonsoft.Json;

namespace Helper
{
    /// <summary>
    /// Clase de utilidades comunes para el sistema
    /// </summary>
    /// <remarks>
    /// Esta clase proporciona métodos estáticos para operaciones comunes como deserialización de datos
    /// y obtención de información de red.
    /// </remarks>
    public static class CommonHelper
    {
        /// <summary>
        /// Deserializa un DataSet a un objeto del tipo especificado
        /// </summary>
        /// <typeparam name="T">Tipo de objeto a deserializar</typeparam>
        /// <param name="ds">DataSet que contiene los datos JSON</param>
        /// <returns>Objeto deserializado o null si no hay datos</returns>
        /// <exception cref="Exception">Se lanza cuando hay un error en la deserialización</exception>
        public static T? DeserializeDataSet<T>(DataSet ds) where T : class
        {
            if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                // Concatenar todas las filas para manejar JSON truncado
                var jsonBuilder = new StringBuilder();
                foreach (DataRow row in ds.Tables[0].Rows)
                {
                    jsonBuilder.Append(row[0]?.ToString() ?? "");
                }
                var jsonString = jsonBuilder.ToString();

                if (!string.IsNullOrEmpty(jsonString))
                {
                    var settings = new JsonSerializerSettings
                    {
                        NullValueHandling = NullValueHandling.Ignore,
                        DateFormatHandling = DateFormatHandling.IsoDateFormat,
                        DateParseHandling = DateParseHandling.DateTimeOffset,
                        DateTimeZoneHandling = DateTimeZoneHandling.Local
                    };

                    try
                    {
                        return JsonConvert.DeserializeObject<T>(jsonString, settings);
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine($"Error deserializando JSON: {ex.Message}");
                        Console.WriteLine($"JSON string: {(jsonString.Length > 500 ? jsonString.Substring(0, 500) + "..." : jsonString)}");
                        throw;
                    }
                }
            }
            return null;
        }

        /// <summary>
        /// Deserializa un DataSet a una lista de objetos del tipo especificado
        /// </summary>
        /// <typeparam name="T">Tipo de objeto a deserializar</typeparam>
        /// <param name="ds">DataSet que contiene los datos JSON</param>
        /// <returns>Lista de objetos deserializados o null si no hay datos</returns>
        /// <exception cref="Exception">Se lanza cuando hay un error en la deserialización</exception>
        public static List<T>? DeserializeDataSetToList<T>(DataSet ds) where T : class
        {
            if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                // Concatenar todas las filas para manejar JSON truncado
                var jsonBuilder = new StringBuilder();
                foreach (DataRow row in ds.Tables[0].Rows)
                {
                    jsonBuilder.Append(row[0]?.ToString() ?? "");
                }
                var jsonString = jsonBuilder.ToString();

                if (!string.IsNullOrEmpty(jsonString))
                {
                    var settings = new JsonSerializerSettings
                    {
                        NullValueHandling = NullValueHandling.Ignore,
                        DateFormatHandling = DateFormatHandling.IsoDateFormat,
                        DateParseHandling = DateParseHandling.DateTimeOffset,
                        DateTimeZoneHandling = DateTimeZoneHandling.Local
                    };

                    try
                    {
                        return JsonConvert.DeserializeObject<List<T>>(jsonString, settings);
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine($"Error deserializando JSON array: {ex.Message}");
                        Console.WriteLine($"JSON string: {(jsonString.Length > 500 ? jsonString.Substring(0, 500) + "..." : jsonString)}");
                        throw;
                    }
                }
            }
            return null;
        }

        /// <summary>
        /// Obtiene la dirección IP pública del usuario
        /// </summary>
        /// <returns>Dirección IP pública o "0.0.0.0" en caso de error</returns>
        public static async Task<string> GetPublicIpAddressAsync()
        {
            // Declaración de variables
            const string strIpCacheKey = "PublicIpAddress";
            IMemoryCache clsCache = new MemoryCache(new MemoryCacheOptions());
            TimeSpan clsCacheDuration = TimeSpan.FromMinutes(30);
            using var clsHttpClient = new HttpClient { Timeout = TimeSpan.FromSeconds(5) }; // Configurar timeout de solicitud

            // Intentar obtener la IP del caché
            if (clsCache.TryGetValue(strIpCacheKey, out string? strCachedIp))
            {
                return strCachedIp ?? "0.0.0.0";
            }

            try
            {
                var response = await clsHttpClient.GetAsync("https://api.ipify.org?format=json");

                if (response.IsSuccessStatusCode)
                {
                    var strContent = await response.Content.ReadAsStringAsync();
                    var jsonDoc = JsonDocument.Parse(strContent);
                    var strIp = jsonDoc.RootElement.GetProperty("ip").GetString() ?? "0.0.0.0";

                    // Guardar en cache por 30 minutos
                    clsCache.Set(strIpCacheKey, strIp, clsCacheDuration);
                    return strIp;
                }

                return "0.0.0.0";
            }
            catch (Exception)
            {
                // Si todo falla, devolver IP por defecto
                return "0.0.0.0";
            }
        }
    }
}