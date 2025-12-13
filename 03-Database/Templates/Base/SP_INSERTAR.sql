-- =============================================
-- Autor:           [Developer Name]
-- Fecha Creación:  [YYYY-MM-DD]
-- Descripción:     Template para inserción de registros - Tablas Base (TB_)
-- Modificaciones:  [Date] - [Author] - [Description]
-- =============================================
CREATE OR ALTER PROCEDURE SP_INSERTAR_[ENTITY]
@P_[FIELD1]             [DATA_TYPE],
@P_[FIELD2]             [DATA_TYPE],
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
            @V_NAME_TABLE          NVARCHAR(300)  = 'TB_[ENTITY]',
            @V_DEFAULT               NVARCHAR(02)   = '01',
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

    -- Verificar duplicados
    SET @V_SQL = ' SELECT @V_CANTIDAD_REGISTRO = COUNT(*) ' +
                 ' FROM ' + @V_NAME_TABLE + 
                 ' WHERE [FIELD1] = ''' + LTRIM(RTRIM(UPPER(@P_[FIELD1]))) + ''' AND ' + 
                 ' ESTREG <> ''E'' '

    EXECUTE sp_executesql @V_SQL, N'@V_CANTIDAD_REGISTRO INT OUTPUT', @V_CANTIDAD_REGISTRO OUTPUT

    IF @V_CANTIDAD_REGISTRO > 0
    BEGIN
        SET @P_MESSAGE_DESCRIPTION = 'El registro ya existe en la Base de Datos'
        SET @P_MESSAGE_TYPE = '2'
        RETURN
    END

    -- Generar código automático
    EXEC SP_GENERAR_CODIGO @V_DEFAULT, @V_NAME_TABLE, '[ENTITY]COD', @V_CODE = @V_CODE_GENERATED OUTPUT

    -- Obtener zona horaria del usuario
    EXEC SP_OBTENER_ZONA_HORARIA_USUARIO
        @P_USUANO_U,
        @P_USUCOD_U,
        @P_LOCOFFZON = @V_TIME_ZONE_OFFSET OUTPUT,
        @P_LOCLOC = @V_TIME_ZONE_LOCALE OUTPUT,
        @P_LOCNAMZON = @V_TIME_ZONE_NAME OUTPUT

    -- Insertar registro
    SET @V_SQL = ' INSERT INTO ' + @V_NAME_TABLE + '(' +
                 '  [ENTITY]COD, ' +
                 '  [FIELD1], ' +
                 '  [FIELD2], ' +
                 '  USUING, ' +
                 '  FECING, ' +
                 '  ZONING, ' +
                 '  USUMOD, ' +
                 '  FECMOD, ' +
                 '  ZONMOD, ' +
                 '  ESTREG' +
                 ' ) VALUES(' +
                 '  ''' + LTRIM(RTRIM(UPPER(@V_CODE_GENERATED))) + ''', ' +
                 '  ''' + LTRIM(RTRIM(UPPER(@P_[FIELD1]))) + ''', ' +
                 '  ''' + LTRIM(RTRIM(UPPER(@P_[FIELD2]))) + ''', ' +
                 '  ''' + LTRIM(RTRIM(UPPER(@P_USUING))) + ''', ' +
                 '  SWITCHOFFSET(SYSDATETIME(), ''' + @V_TIME_ZONE_OFFSET + '''), ' +
                 '  ''' + LTRIM(RTRIM(UPPER(@V_TIME_ZONE_NAME))) + ''', ' +
                 '  ''' + LTRIM(RTRIM(UPPER(@P_USUING))) + ''', ' +
                 '  SWITCHOFFSET(SYSDATETIME(), ''' + @V_TIME_ZONE_OFFSET + '''), ' +
                 '  ''' + LTRIM(RTRIM(UPPER(@V_TIME_ZONE_NAME))) + ''', ' +
                 '  ''I'')'

    EXECUTE sp_executesql @V_SQL

    -- Generar mensaje de éxito
    SET @V_SQL_MENSAJE = ' SELECT @V_CADENA = ''EL [ENTITY] ['' + [FIELD1] + '']'' ' +
                         ' FROM ' + @V_NAME_TABLE + 
                         ' WHERE [ENTITY]COD = ''' + @V_CODE_GENERATED + ''''

    EXEC sp_executesql @V_SQL_MENSAJE, N'@V_CADENA NVARCHAR(MAX) OUTPUT', @V_CADENA OUTPUT

    SET @V_DESCRIPTION_LOG = 'REGISTRÓ ' + @V_CADENA
    SET @V_CODE_COMPLETE = @V_CODE_GENERATED

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
-- 1. Reemplazar [ENTITY] con el nombre de la entidad (ej: CARGO, GENERO)
-- 2. Reemplazar [FIELD1], [FIELD2] con los campos específicos
-- 3. Reemplazar [DATA_TYPE] con el tipo de dato correspondiente
-- 4. Ajustar @V_DEFAULT según el patrón de códigos requerido
-- 5. Agregar campos adicionales según la estructura de la tabla
-- 6. Modificar validaciones según reglas de negocio
-- 
-- CARACTERÍSTICAS:
-- - Generación automática de códigos
-- - Validación de duplicados
-- - Manejo de zona horaria del usuario
-- - Auditoría completa (FECING, USUMOD, etc.)
-- - Logging de operaciones
-- - Manejo de errores robusto
-- - Compatible con tablas base (TB_)
-- =============================================
