-- =============================================
-- Autor:           [Developer Name]
-- Fecha Creación:  [YYYY-MM-DD]
-- Descripción:     Template para inserción de registros - Tablas Maestro (TM_)
-- Modificaciones:  [Date] - [Author] - [Description]
-- =============================================
CREATE OR ALTER PROCEDURE SP_INSERTAR_[ENTITY]
@P_[ENTITY]ANO_OUT      CHAR(4) OUTPUT,         -- Año generado de salida
@P_[ENTITY]COD_OUT      CHAR(6) OUTPUT,         -- Código generado de salida
@P_[FIELD1]             [DATA_TYPE],
@P_[FIELD2]             [DATA_TYPE],
@P_[RELATED_COD]        [DATA_TYPE],            -- Código de tabla relacionada si aplica
@P_USUING               VARCHAR(50),
@P_LOGIPMAC             VARCHAR(15),
@P_USUANO_U             CHAR(4),
@P_USUCOD_U             CHAR(6),
@P_USUNOM_U             VARCHAR(30),
@P_USUAPE_U             VARCHAR(30),
@P_MESSAGE_DESCRIPTION  NVARCHAR(MAX) OUTPUT,
@P_MESSAGE_TYPE         CHAR(1) OUTPUT
AS
BEGIN TRY
    SET NOCOUNT ON

    DECLARE @V_SQL                   NVARCHAR(MAX)  = '',
            @V_SQL_MENSAJE           NVARCHAR(MAX)  = '',
            @V_NAME_TABLE          NVARCHAR(300)  = 'TM_[ENTITY]',
            @V_DEFAULT               NVARCHAR(06)   = '000001',
            @V_CODE_GENERATED       NVARCHAR(300)  = '',
            @V_CODE_LOG_YEAR       CHAR(4)        = '',
            @V_CODE_LOG            CHAR(10)       = '',
            @V_CANTIDAD_REGISTRO     INT,
            @V_DESCRIPTION_LOG       NVARCHAR(300)  = '',
            @V_ERROR                 NVARCHAR(MAX)  = '',
            @V_CADENA                NVARCHAR(MAX)  = '',
            @V_CODE_COMPLETE       NVARCHAR(20)   = '',
            @V_TIME_ZONE_OFFSET   NVARCHAR(6)    = '',
            @V_TIME_ZONE_NAME   NVARCHAR(50)   = '',
            @V_TIME_ZONE_LOCALE   NVARCHAR(50)   = ''

    -- Validaciones de entrada
    IF @P_[FIELD1] IS NULL OR LTRIM(RTRIM(@P_[FIELD1])) = ''
    BEGIN
        SET @P_MESSAGE_DESCRIPTION = 'El campo [FIELD1] es requerido'
        SET @P_MESSAGE_TYPE = '2'
        RETURN
    END

    -- Validar tabla relacionada si aplica
    IF @P_[RELATED_COD] IS NOT NULL
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM TB_[RELATED_TABLE] WHERE [RELATED_COD] = @P_[RELATED_COD] AND ESTREG <> 'E')
        BEGIN
            SET @P_MESSAGE_DESCRIPTION = 'El código de [RELATED_TABLE] no existe'
            SET @P_MESSAGE_TYPE = '2'
            RETURN
        END
    END

    -- Verificar duplicados (incluir campos clave de validación)
    SET @V_SQL = ' SELECT @V_CANTIDAD_REGISTRO = COUNT(*) ' +
                 ' FROM ' + @V_NAME_TABLE + 
                 ' WHERE [FIELD1] = ''' + LTRIM(RTRIM(UPPER(@P_[FIELD1]))) + ''' ' +
                 ' AND ESTREG <> ''E'' '

    EXECUTE sp_executesql @V_SQL, N'@V_CANTIDAD_REGISTRO INT OUTPUT', @V_CANTIDAD_REGISTRO OUTPUT

    IF @V_CANTIDAD_REGISTRO > 0
    BEGIN
        SET @P_MESSAGE_DESCRIPTION = 'El registro ya existe en la Base de Datos'
        SET @P_MESSAGE_TYPE = '2'
        RETURN
    END

    -- Generar código con año
    EXEC SP_GENERATE_CODE_WITH_YEAR @V_DEFAULT, @V_NAME_TABLE, '[ENTITY]COD', '[ENTITY]ANO', @V_CODE = @V_CODE_GENERATED OUTPUT
    SET @P_[ENTITY]ANO_OUT = CAST(YEAR(SYSDATETIME()) AS CHAR(4))
    SET @P_[ENTITY]COD_OUT = @V_CODE_GENERATED

    -- Obtener zona horaria del usuario
    EXEC SP_OBTENER_ZONA_HORARIA_USUARIO
        @P_USUANO_U,
        @P_USUCOD_U,
        @P_LOCOFFZON = @V_TIME_ZONE_OFFSET OUTPUT,
        @P_LOCLOC = @V_TIME_ZONE_LOCALE OUTPUT,
        @P_LOCNAMZON = @V_TIME_ZONE_NAME OUTPUT

    -- Insertar registro
    SET @V_SQL = ' INSERT INTO ' + @V_NAME_TABLE + '(' +
                 '  [ENTITY]ANO, ' +
                 '  [ENTITY]COD, ' +
                 '  [FIELD1], ' +
                 '  [FIELD2], ' +
                 -- '  [RELATED_COD], ' +
                 '  USUING, ' +
                 '  FECING, ' +
                 '  ZONING, ' +
                 '  USUMOD, ' +
                 '  FECMOD, ' +
                 '  ZONMOD, ' +
                 '  ESTREG' +
                 ' ) VALUES(' +
                 '  YEAR(SYSDATETIME()), ' +
                 '  ''' + LTRIM(RTRIM(UPPER(@V_CODE_GENERATED))) + ''', ' +
                 '  ''' + LTRIM(RTRIM(UPPER(@P_[FIELD1]))) + ''', ' +
                 '  ''' + LTRIM(RTRIM(UPPER(@P_[FIELD2]))) + ''', ' +
                 -- '  ''' + LTRIM(RTRIM(UPPER(@P_[RELATED_COD]))) + ''', ' +
                 '  ''' + LTRIM(RTRIM(UPPER(@P_USUING))) + ''', ' +
                 '  SWITCHOFFSET(SYSDATETIME(), ''' + @V_TIME_ZONE_OFFSET + '''), ' +
                 '  ''' + LTRIM(RTRIM(UPPER(@V_TIME_ZONE_NAME))) + ''', ' +
                 '  ''' + LTRIM(RTRIM(UPPER(@P_USUING))) + ''', ' +
                 '  SWITCHOFFSET(SYSDATETIME(), ''' + @V_TIME_ZONE_OFFSET + '''), ' +
                 '  ''' + LTRIM(RTRIM(UPPER(@V_TIME_ZONE_NAME))) + ''', ' +
                 '  ''I'')'

    EXECUTE sp_executesql @V_SQL

    -- Generar mensaje de éxito con JOIN si hay tablas relacionadas
    SET @V_SQL_MENSAJE = ' SELECT @V_CADENA = ''EL [ENTITY] ['' + ENT.[FIELD1] + '']'' ' +
                         ' FROM ' + @V_NAME_TABLE + ' AS ENT ' +
                         -- ' INNER JOIN TB_[RELATED_TABLE] AS REL ON ENT.[RELATED_COD] = REL.[RELATED_COD] ' +
                         ' WHERE ENT.[ENTITY]ANO = YEAR(SYSDATETIME()) AND ENT.[ENTITY]COD = ''' + @V_CODE_GENERATED + ''''

    EXEC sp_executesql @V_SQL_MENSAJE, N'@V_CADENA NVARCHAR(MAX) OUTPUT', @V_CADENA OUTPUT

    SET @V_DESCRIPTION_LOG = 'REGISTRÓ ' + @V_CADENA
    SET @V_CODE_COMPLETE = CAST(YEAR(SYSDATETIME()) AS VARCHAR) + @V_CODE_GENERATED

    -- Registrar log de éxito
    EXEC SP_REGISTER_LOG @V_DESCRIPTION_LOG, 'INSERTAR', @P_LOGIPMAC, @V_CODE_COMPLETE, @V_NAME_TABLE, @V_SQL, 'EXITO',
         @P_USUANO_U, @P_USUCOD_U, @P_USUNOM_U, @P_USUAPE_U,
         @P_MESSAGE_DESCRIPTION = @P_MESSAGE_DESCRIPTION OUTPUT,
         @P_MESSAGE_TYPE = @P_MESSAGE_TYPE OUTPUT,
         @P_LOGYEA = @V_CODE_LOG_YEAR OUTPUT,
         @P_LOGCOD = @V_CODE_LOG OUTPUT

    SET @P_MESSAGE_DESCRIPTION = 'El [ENTITY] se registró correctamente'
    SET @P_MESSAGE_TYPE = '3'

    EXEC SP_UPDATE_DATE_END_SQL @V_CODE_LOG_YEAR, @V_CODE_LOG, @V_SQL

END TRY
BEGIN CATCH
    SET @V_ERROR = LTRIM(RTRIM(UPPER(ERROR_MESSAGE())))
    EXEC SP_REGISTER_LOG @V_ERROR, 'INSERTAR', @P_LOGIPMAC, @V_CODE_COMPLETE, @V_NAME_TABLE, @V_SQL, 'ERROR',
         @P_USUANO_U, @P_USUCOD_U, @P_USUNOM_U, @P_USUAPE_U,
         @P_MESSAGE_DESCRIPTION = @P_MESSAGE_DESCRIPTION OUTPUT,
         @P_MESSAGE_TYPE = @P_MESSAGE_TYPE OUTPUT,
         @P_LOGYEA = @V_CODE_LOG_YEAR OUTPUT,
         @P_LOGCOD = @V_CODE_LOG OUTPUT
    EXEC SP_UPDATE_DATE_END_SQL @V_CODE_LOG_YEAR, @V_CODE_LOG, @V_SQL
    SET @P_MESSAGE_DESCRIPTION = @V_ERROR
    SET @P_MESSAGE_TYPE = '1'
END CATCH
GO

-- =============================================
-- INSTRUCCIONES DE USO:
-- 1. Reemplazar [ENTITY] con el nombre de la entidad (ej: USUARIO, UBICACION)
-- 2. Reemplazar [FIELD1], [FIELD2] con los campos específicos
-- 3. Reemplazar [DATA_TYPE] con el tipo de dato correspondiente
-- 4. Configurar [RELATED_COD] y [RELATED_TABLE] si hay relaciones
-- 5. Descomentar líneas de campos relacionados si aplica
-- 6. Ajustar @V_DEFAULT según el patrón de códigos requerido
-- 7. Verificar que SP_GENERATE_CODE_WITH_YEAR existe
-- 
-- CARACTERÍSTICAS:
-- - Generación automática de códigos con año
-- - Claves compuestas (ANO + COD)
-- - Validación de duplicados
-- - Validación de tablas relacionadas
-- - Parámetros de salida para códigos generados
-- - Manejo de zona horaria del usuario
-- - Auditoría completa (FECING, USUMOD, etc.)
-- - Logging de operaciones
-- - Compatible con tablas maestro (TM_)
-- =============================================
