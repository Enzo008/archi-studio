# Helper Library

Helper es una biblioteca de utilidades para aplicaciones .NET que proporciona funcionalidades comunes para el desarrollo de aplicaciones empresariales.

## Características

- **Manejo de respuestas estandarizadas**: Clase `OperationResponse` para estandarizar las respuestas de operaciones.
- **Acceso a datos**: Utilidades para trabajar con SQL Server y bases de datos relacionales.
- **Deserialización de datos**: Métodos para deserializar datos JSON desde DataSets.
- **Utilidades de red**: Obtención de información de red como la dirección IP pública.

## Estructura

```
Helper/
├── Core/                      # Clases y funcionalidades principales
│   ├── Types.cs               # Enumeraciones y tipos básicos
│   └── OperationResponse.cs   # Clase de respuesta estándar
│
├── Database/                  # Funcionalidades relacionadas con bases de datos
│   ├── SqlHelper.cs           # Utilidades para SQL Server
│   └── BaseDAO.cs             # Clase base para DAOs
│
├── Extensions/                # Extensiones de clases
│   └── OperationResponseExtensions.cs  # Extensiones para OperationResponse
│
├── Helpers/                   # Clases de ayuda y utilidades
│   └── CommonHelper.cs        # Utilidades comunes
```

## Uso

### OperationResponse

```csharp
// Crear una respuesta de éxito
var successResponse = OperationResponse.CreateSuccess("Operación completada con éxito", data);

// Crear una respuesta de error
var errorResponse = OperationResponse.CreateError("Error al procesar la solicitud");

// Verificar el tipo de respuesta
if (response.IsSuccess())
{
    // Procesar respuesta exitosa
}
else if (response.IsError())
{
    // Manejar error
}
```

### SqlHelper

```csharp
// Crear parámetros
var parameters = SqlHelper.CreateParameters();
SqlHelper.AddParameter(parameters, "@P_ID", id);
SqlHelper.AddParameter(parameters, "@P_NAME", name);

// Ejecutar consulta
var dataSet = new DataSet();
await SqlHelper.GetDataSetAsync("SP_GET_DATA", CommandType.StoredProcedure, connectionString, parameters.ToArray(), dataSet);

// Deserializar resultados
var result = CommonHelper.DeserializeDataSet<MyEntity>(dataSet);
```

### BaseDAO

```csharp
public class MyDAO : BaseDAO
{
    public async Task<OperationResponse> GetData(int id)
    {
        try
        {
            // Lógica de acceso a datos
            return CreateSuccessResponse("Datos obtenidos con éxito", data);
        }
        catch (Exception ex)
        {
            return HandleException(ex);
        }
    }
}
```

## Requisitos

- .NET 8.0 o superior
- Microsoft.Data.SqlClient
- Microsoft.Extensions.Caching.Memory
- Newtonsoft.Json

## Licencia

Este proyecto está licenciado bajo la Licencia MIT - ver el archivo LICENSE para más detalles.