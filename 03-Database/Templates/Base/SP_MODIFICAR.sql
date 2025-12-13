-- =============================================
-- Autor:           [Developer Name]
-- Fecha Creación:  [YYYY-MM-DD]
-- Descripción:     Template para modificación de registros - Tablas Base (TB_)
-- Modificaciones:  [Date] - [Author] - [Description]
-- =============================================
CREATE OR ALTER PROCEDURE SP_MODIFICAR_[ENTITY]
@P_[ENTITY]COD          CHAR(2),
@P_[FIELD1]             [DATA_TYPE],
@P_[FIELD2]             [DATA_TYPE],
@P_USUMOD               VARCHAR(50),
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
            @V_SQL_MODIFICADO        NVARCHAR(MAX)  = '',
            @V_NAME_TABLE          NVARCHAR(300)  = 'TB_[ENTITY]',
            @V_CODE_LOG_YEAR       CHAR(4)        = '',
            @V_CODE_LOG            CHAR(10)       = '',
            @V_CANTIDAD_REGISTRO     INT,
            @V_DESCRIPTION_LOG       NVARCHAR(300)  = '',
            @V_ERROR                 NVARCHAR(MAX)  = '',
            @V_CADENA                NVARCHAR(MAX)  = '',
            @V_CADENA_MODIFICADO     NVARCHAR(MAX)  = '',
            @V_CODE_COMPLETE       NVARCHAR(20)   = '',
            @V_TIME_ZONE_OFFSET   NVARCHAR(6)    = '',
            @V_TIME_ZONE_NAME   NVARCHAR(50)   = '',
            @V_TIME_ZONE_LOCALE   NVARCHAR(50)   = ''

    -- Validaciones de entrada
    IF @P_[ENTITY]COD IS NULL OR LTRIM(RTRIM(@P_[ENTITY]COD)) = ''
    BEGIN
        SET @P_MESSAGE_DESCRIPTION = 'El código de [ENTITY] es requerido'
        SET @P_MESSAGE_TYPE = '2'
        RETURN
    END

    IF @P_[FIELD1] IS NULL OR LTRIM(RTRIM(@P_[FIELD1])) = ''
    BEGIN
        SET @P_MESSAGE_DESCRIPTION = 'El campo [FIELD1] es requerido'
        SET @P_MESSAGE_TYPE = '2'
        RETURN
    END

    -- Verificar que el registro existe
    SET @V_SQL = ' SELECT @V_CANTIDAD_REGISTRO = COUNT(*) ' +
                 ' FROM ' + @V_NAME_TABLE + 
                 ' WHERE [ENTITY]COD = ''' + LTRIM(RTRIM(@P_[ENTITY]COD)) + ''' ' +
                 ' AND ESTREG <> ''E'' '

    EXECUTE sp_executesql @V_SQL, N'@V_CANTIDAD_REGISTRO INT OUTPUT', @V_CANTIDAD_REGISTRO OUTPUT

    IF @V_CANTIDAD_REGISTRO = 0
    BEGIN
        SET @P_MESSAGE_DESCRIPTION = 'El registro no existe en la Base de Datos'
        SET @P_MESSAGE_TYPE = '2'
        RETURN
    END

    -- Obtener datos antes de la modificación
    SET @V_SQL = ' SELECT @V_CADENA = ''EL [ENTITY] ['' + [FIELD1] + '']'' ' +
                 ' FROM ' + @V_NAME_TABLE + 
                 ' WHERE [ENTITY]COD = ''' + LTRIM(RTRIM(UPPER(@P_[ENTITY]COD))) + ''' '

    EXEC sp_executesql @V_SQL, N'@V_CADENA NVARCHAR(MAX) OUTPUT', @V_CADENA OUTPUT

    -- Verificar duplicados (excluyendo el registro actual)
    SET @V_SQL = ' SELECT @V_CANTIDAD_REGISTRO = COUNT(*) ' +
                 ' FROM ' + @V_NAME_TABLE + 
                 ' WHERE [FIELD1] = ''' + LTRIM(RTRIM(UPPER(@P_[FIELD1]))) + ''' ' +
                 ' AND [ENTITY]COD <> ''' + LTRIM(RTRIM(@P_[ENTITY]COD)) + ''' ' +
                 ' AND ESTREG <> ''E'' '

    EXEC sp_executesql @V_SQL, N'@V_CANTIDAD_REGISTRO INT OUTPUT', @V_CANTIDAD_REGISTRO OUTPUT

    IF @V_CANTIDAD_REGISTRO > 0
    BEGIN
        SET @P_MESSAGE_DESCRIPTION = 'Ya existe otro registro con el mismo [FIELD1]'
        SET @P_MESSAGE_TYPE = '2'
        RETURN
    END

    -- Obtener zona horaria del usuario
    EXEC SP_OBTENER_ZONA_HORARIA_USUARIO 
        @P_USUANO_U,
        @P_USUCOD_U,
        @P_LOCOFFZON = @V_TIME_ZONE_OFFSET OUTPUT,
        @P_LOCLOC = @V_TIME_ZONE_LOCALE OUTPUT,
        @P_LOCNAMZON = @V_TIME_ZONE_NAME OUTPUT

    -- Actualizar registro
    SET @V_SQL = ' UPDATE ' + @V_NAME_TABLE + ' SET ' +
                 ' [FIELD1] = ''' + LTRIM(RTRIM(UPPER(@P_[FIELD1]))) + ''', ' +
                 ' [FIELD2] = ''' + LTRIM(RTRIM(UPPER(@P_[FIELD2]))) + ''', ' +
                 ' USUMOD = ''' + LTRIM(RTRIM(UPPER(@P_USUMOD))) + ''', ' +
                 ' FECMOD = SWITCHOFFSET(SYSDATETIME(), ''' + @V_TIME_ZONE_OFFSET + '''), ' +
                 ' ZONMOD = ''' + LTRIM(RTRIM(UPPER(@V_TIME_ZONE_NAME))) + ''', ' +
                 ' ESTREG = ''M'' ' +
                 ' WHERE [ENTITY]COD = ''' + LTRIM(RTRIM(UPPER(@P_[ENTITY]COD))) + ''' '

    EXEC sp_executesql @V_SQL

    -- Obtener datos después de la modificación
    SET @V_SQL_MODIFICADO = ' SELECT @V_CADENA_MODIFICADO = ''EL [ENTITY] ['' + [FIELD1] + '']'' ' +
                            ' FROM ' + @V_NAME_TABLE + 
                            ' WHERE [ENTITY]COD = ''' + LTRIM(RTRIM(UPPER(@P_[ENTITY]COD))) + ''' '

    EXEC sp_executesql @V_SQL_MODIFICADO, N'@V_CADENA_MODIFICADO NVARCHAR(MAX) OUTPUT', @V_CADENA_MODIFICADO OUTPUT

    SET @V_DESCRIPTION_LOG = 'MODIFICÓ ' + @V_CADENA + ' POR ' + @V_CADENA_MODIFICADO
    SET @V_CODE_COMPLETE = LTRIM(RTRIM(UPPER(@P_[ENTITY]COD)))

    -- Registrar log de éxito
    EXEC SP_REGISTER_LOG @V_DESCRIPTION_LOG, 'MODIFICAR', @P_LOGIPMAC, @V_CODE_COMPLETE, @V_NAME_TABLE, @V_SQL, 'EXITO',
         @P_USUANO_U, @P_USUCOD_U, @P_USUNOM_U, @P_USUAPE_U,
         @P_MESSAGE_DESCRIPTION = @P_MESSAGE_DESCRIPTION OUTPUT,
         @P_MESSAGE_TYPE = @P_MESSAGE_TYPE OUTPUT,
         @P_LOGYEA = @V_CODE_LOG_YEAR OUTPUT,
         @P_LOGCOD = @V_CODE_LOG OUTPUT

    SET @P_MESSAGE_DESCRIPTION = 'El [ENTITY] se modificó correctamente'
    SET @P_MESSAGE_TYPE = '3'

    EXEC SP_UPDATE_DATE_END_SQL @V_CODE_LOG_YEAR, @V_CODE_LOG, @V_SQL

END TRY
BEGIN CATCH
    SET @V_ERROR = LTRIM(RTRIM(UPPER(ERROR_MESSAGE())))
    EXEC SP_REGISTER_LOG @V_ERROR, 'MODIFICAR', @P_LOGIPMAC, @V_CODE_COMPLETE, @V_NAME_TABLE, @V_SQL, 'ERROR',
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
-- 4. Agregar campos adicionales según la estructura de la tabla
-- 5. Modificar validaciones según reglas de negocio
-- 
-- CARACTERÍSTICAS:
-- - Validación de existencia del registro
-- - Verificación de duplicados excluyendo registro actual
-- - Auditoría de cambios (antes y después)
-- - Manejo de zona horaria del usuario
-- - Actualización de campos de auditoría (FECMOD, USUMOD, etc.)
-- - Estado ESTREG = 'M' para modificado
-- - Logging detallado de operaciones
-- - Compatible con tablas base (TB_)
-- =============================================
