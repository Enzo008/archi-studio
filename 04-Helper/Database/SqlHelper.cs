// *****************************************************************************************************
// Descripción       : Utilidades para el manejo de operaciones con SQL Server
// Creado por        : Enzo Gago Aguirre
// Fecha de Creación : 10/02/2025
// Acción a Realizar : Proporcionar métodos para ejecutar consultas y transacciones en SQL Server
// *****************************************************************************************************

using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Reflection;
using System.Threading.Tasks;
using Microsoft.Data.SqlClient;

namespace Helper
{
    /// <summary>
    /// Clase de utilidad para operaciones con SQL Server
    /// </summary>
    /// <remarks>
    /// Esta clase proporciona métodos estáticos para ejecutar consultas y transacciones en SQL Server,
    /// así como para manejar parámetros SQL de manera eficiente.
    /// </remarks>
    public static class SqlHelper
    {
        /// <summary>
        /// Ejecuta una consulta SQL y llena un DataSet con los resultados
        /// </summary>
        /// <param name="sqlQuery">Consulta SQL a ejecutar</param>
        /// <param name="commandType">Tipo de comando (Text, StoredProcedure, etc.)</param>
        /// <param name="connectionString">String de conexión a la base de datos</param>
        /// <param name="parameters">Parámetros SQL para la consulta</param>
        /// <param name="dataSet">DataSet que se llenará con los resultados</param>
        /// <returns>True si la operación fue exitosa</returns>
        /// <exception cref="SqlException">Se lanza cuando ocurre un error en la base de datos</exception>
        /// <exception cref="Exception">Se lanza cuando ocurre un error general</exception>
        public static async Task<bool> GetDataSetAsync(string sqlQuery, CommandType commandType, string connectionString, SqlParameter[] parameters, DataSet dataSet)
        {
            using SqlConnection sqlConnection = new(connectionString);
            using SqlCommand sqlCommand = new();

            try
            {
                await sqlConnection.OpenAsync();

                sqlCommand.Connection = sqlConnection;
                sqlCommand.CommandType = commandType;
                sqlCommand.CommandText = sqlQuery;

                if (parameters != null)
                {
                    AddCommandParameters(sqlCommand, parameters);
                }

                using var dataAdapter = new SqlDataAdapter(sqlCommand);
                dataAdapter.Fill(dataSet);

                return true;
            }
            catch (SqlException ex)
            {
                Console.WriteLine($"SQL Error: {ex.Message}, Number: {ex.Number}");
                throw;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
                throw;
            }
        }

        /// <summary>
        /// Ejecuta una transacción SQL que no retorna resultados
        /// </summary>
        /// <param name="sqlQuery">Consulta SQL a ejecutar</param>
        /// <param name="commandType">Tipo de comando (Text, StoredProcedure, etc.)</param>
        /// <param name="connectionString">String de conexión a la base de datos</param>
        /// <param name="parameters">Parámetros SQL para la consulta</param>
        /// <returns>True si la operación fue exitosa</returns>
        /// <exception cref="Exception">Se lanza cuando ocurre un error</exception>
        public static async Task<bool> ExecuteTransactionAsync(string sqlQuery, CommandType commandType, string connectionString, SqlParameter[] parameters)
        {
            using SqlConnection sqlConnection = new(connectionString);
            using SqlCommand sqlCommand = new();

            try
            {
                await sqlConnection.OpenAsync();
                
                sqlCommand.Connection = sqlConnection;
                sqlCommand.CommandType = commandType;
                sqlCommand.CommandText = sqlQuery;

                if (parameters != null)
                {
                    AddCommandParameters(sqlCommand, parameters);
                }

                await sqlCommand.ExecuteNonQueryAsync();
                return true;
            }
            catch
            {
                throw;
            }
        }

        /// <summary>
        /// Crea una nueva lista de parámetros SQL
        /// </summary>
        /// <returns>Lista vacía de parámetros SQL</returns>
        public static List<SqlParameter> CreateParameters()
        {
            return new List<SqlParameter>();
        }

        /// <summary>
        /// Agrega un parámetro binario a la lista de parámetros
        /// </summary>
        /// <param name="parameters">Lista de parámetros</param>
        /// <param name="name">Nombre del parámetro</param>
        /// <param name="value">Valor binario del parámetro</param>
        public static void AddBinaryParameter(List<SqlParameter> parameters, string name, byte[]? value)
        {
            SqlParameter sqlParameter = new(name, SqlDbType.VarBinary, -1) // -1 significa tamaño máximo
            {
                Direction = ParameterDirection.Input,
                Value = value == null ? DBNull.Value : value
            };
            
            parameters.Add(sqlParameter);
        }

        /// <summary>
        /// Agrega un parámetro de entrada a la lista de parámetros
        /// </summary>
        /// <param name="parameters">Lista de parámetros</param>
        /// <param name="name">Nombre del parámetro</param>
        /// <param name="value">Valor del parámetro</param>
        /// <param name="size">Tamaño del parámetro (opcional)</param>
        public static void AddParameter(List<SqlParameter> parameters, string name, object? value, int size = 0)
        {
            var parameter = new SqlParameter(name, value ?? DBNull.Value)
            {
                Direction = ParameterDirection.Input
            };

            if (size > 0 && (value == null || value is string))
            {
                parameter.Size = size;
            }
            parameters.Add(parameter);
        }

        /// <summary>
        /// Agrega un parámetro de salida a la lista de parámetros
        /// </summary>
        /// <param name="parameters">Lista de parámetros</param>
        /// <param name="name">Nombre del parámetro</param>
        /// <param name="type">Tipo de dato SQL del parámetro</param>
        /// <param name="size">Tamaño del parámetro (opcional)</param>
        public static void AddOutputParameter(List<SqlParameter> parameters, string name, SqlDbType type, int size = 0)
        {
            var parameter = new SqlParameter(name, type)
            {
                Direction = ParameterDirection.Output
            };

            if (size > 0)
            {
                parameter.Size = size;
            }

            parameters.Add(parameter);
        }

        /// <summary>
        /// Obtiene el valor de un parámetro de salida
        /// </summary>
        /// <param name="parameters">Lista de parámetros</param>
        /// <param name="name">Nombre del parámetro</param>
        /// <returns>Valor del parámetro como string o null si no existe</returns>
        public static string? GetOutputParameterValue(List<SqlParameter> parameters, string name)
        {
            return parameters.Find(p => p.ParameterName == name)?.Value?.ToString();
        }

        /// <summary>
        /// Agrega un parámetro de tipo DataTable (Table-Valued Parameter) a la lista de parámetros
        /// </summary>
        /// <param name="parameters">Lista de parámetros</param>
        /// <param name="name">Nombre del parámetro</param>
        /// <param name="dataTable">DataTable con los datos</param>
        /// <param name="typeName">Nombre del tipo de tabla definido en SQL Server</param>
        public static void AddTableParameter(List<SqlParameter> parameters, string name, DataTable? dataTable, string typeName)
        {
            var parameter = new SqlParameter(name, SqlDbType.Structured)
            {
                Direction = ParameterDirection.Input,
                TypeName = typeName,
                Value = dataTable ?? new DataTable()
            };
            
            parameters.Add(parameter);
        }

        /// <summary>
        /// Convierte una lista de objetos a DataTable para usar como Table-Valued Parameter
        /// </summary>
        /// <typeparam name="T">Tipo de objeto</typeparam>
        /// <param name="items">Lista de objetos a convertir</param>
        /// <param name="columnMappings">Mapeo de propiedades a columnas (PropertyName -> ColumnName)</param>
        /// <returns>DataTable con los datos convertidos</returns>
        public static DataTable ConvertToDataTable<T>(IEnumerable<T>? items, Dictionary<string, string>? columnMappings = null)
        {
            var dataTable = new DataTable();
            
            if (items == null || !items.Any())
                return dataTable;

            var properties = typeof(T).GetProperties();
            
            // Crear columnas basadas en las propiedades del tipo
            foreach (var property in properties)
            {
                var columnName = columnMappings?.ContainsKey(property.Name) == true 
                    ? columnMappings[property.Name] 
                    : property.Name;
                    
                var columnType = Nullable.GetUnderlyingType(property.PropertyType) ?? property.PropertyType;
                dataTable.Columns.Add(columnName, columnType);
            }

            // Agregar filas con los datos
            foreach (var item in items)
            {
                var row = dataTable.NewRow();
                foreach (var property in properties)
                {
                    var columnName = columnMappings?.ContainsKey(property.Name) == true 
                        ? columnMappings[property.Name] 
                        : property.Name;
                        
                    var value = property.GetValue(item);
                    row[columnName] = value ?? DBNull.Value;
                }
                dataTable.Rows.Add(row);
            }

            return dataTable;
        }

        /// <summary>
        /// Convierte una lista de objetos a DataTable para usar como Table-Valued Parameter
        /// Solo incluye las propiedades especificadas en columnMappings (versión optimizada para tipos de tabla específicos)
        /// </summary>
        /// <typeparam name="T">Tipo de objeto</typeparam>
        /// <param name="items">Lista de objetos a convertir</param>
        /// <param name="columnMappings">Mapeo de propiedades a columnas (PropertyName -> ColumnName). Solo se incluirán estas propiedades.</param>
        /// <returns>DataTable con los datos convertidos solo para las columnas especificadas</returns>
        public static DataTable ConvertToDataTableFiltered<T>(IEnumerable<T>? items, Dictionary<string, string> columnMappings)
        {
            var dataTable = new DataTable();
            
            if (items == null || !items.Any())
                return dataTable;

            // Obtener solo las propiedades especificadas en columnMappings
            var typeProperties = typeof(T).GetProperties().ToDictionary(p => p.Name, p => p);
            var selectedProperties = new List<PropertyInfo>();

            // Crear columnas solo para las propiedades especificadas en columnMappings
            foreach (var mapping in columnMappings)
            {
                if (typeProperties.TryGetValue(mapping.Key, out var property))
                {
                    selectedProperties.Add(property);
                    var columnType = Nullable.GetUnderlyingType(property.PropertyType) ?? property.PropertyType;
                    dataTable.Columns.Add(mapping.Value, columnType);
                }
            }

            // Agregar filas con los datos solo de las propiedades seleccionadas
            foreach (var item in items)
            {
                var row = dataTable.NewRow();
                foreach (var property in selectedProperties)
                {
                    var columnName = columnMappings[property.Name];
                    var value = property.GetValue(item);
                    row[columnName] = value ?? DBNull.Value;
                }
                dataTable.Rows.Add(row);
            }

            return dataTable;
        }

        /// <summary>
        /// Agrega parámetros a un comando SQL
        /// </summary>
        /// <param name="command">Comando SQL</param>
        /// <param name="parameters">Array de parámetros a agregar</param>
        private static void AddCommandParameters(SqlCommand command, SqlParameter[] parameters)
        {
            try
            {
                if (parameters == null) return;

                foreach (var parameter in parameters)
                {
                    if (parameter == null) continue;

                    if ((parameter.Direction == ParameterDirection.InputOutput ||
                        parameter.Direction == ParameterDirection.Input) &&
                        parameter.Value == null)
                    {
                        parameter.Value = DBNull.Value;
                    }

                    command.Parameters.Add(parameter);
                }
            }
            catch
            {
                throw;
            }
        }
    }
}