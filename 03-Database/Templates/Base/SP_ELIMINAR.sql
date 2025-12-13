-- =============================================
-- Autor:           [Developer Name]
-- Fecha Creación:  [YYYY-MM-DD]
-- Descripción:     Template para eliminación lógica de registros - Tablas Base (TB_)
-- Modificaciones:  [Date] - [Author] - [Description]
-- =============================================
CREATE OR ALTER PROCEDURE SP_ELIMINAR_[ENTITY]
@P_[ENTITY]COD          [DATA_TYPE],
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

    -- Validaciones de entrada
    IF @P_[ENTITY]COD IS NULL OR LTRIM(RTRIM(@P_[ENTITY]COD)) = ''
    BEGIN
        SET @P_MESSAGE_DESCRIPTION = 'El código de [ENTITY] es requerido'
        SET @P_MESSAGE_TYPE = '2'
        RETURN
    END

    -- Verificar que el registro existe
    IF NOT EXISTS (SELECT 1 FROM TB_[ENTITY] WHERE [ENTITY]COD = LTRIM(RTRIM(@P_[ENTITY]COD)) AND ESTREG <> 'E')
    BEGIN
        SET @P_MESSAGE_DESCRIPTION = 'El registro no existe en la Base de Datos'
        SET @P_MESSAGE_TYPE = '2'
        RETURN
    END

    -- Verificar referencias en otras tablas (agregar según necesidad)
    /*
    IF EXISTS (SELECT 1 FROM TM_[RELATED_TABLE] WHERE [ENTITY]COD = LTRIM(RTRIM(@P_[ENTITY]COD)) AND ESTREG <> 'E')
    BEGIN
        SET @P_MESSAGE_DESCRIPTION = 'No puedes eliminar el registro hasta que elimines todas sus referencias en otras tablas del sistema'
        SET @P_MESSAGE_TYPE = '2'
        RETURN
    END
    */

    DECLARE @V_SQL                   NVARCHAR(MAX)  = '',
            @V_SQL_MENSAJE           NVARCHAR(MAX)  = '',
            @V_NAME_TABLE          NVARCHAR(300)  = 'TB_[ENTITY]',
            @V_CODE_LOG_YEAR       CHAR(4)        = '',
            @V_CODE_LOG            CHAR(10)       = '',
            @V_DESCRIPTION_LOG       NVARCHAR(300)  = '',
            @V_ERROR                 NVARCHAR(MAX)  = '',
            @V_CADENA                NVARCHAR(MAX)  = '',
            @V_CODE_COMPLETE       NVARCHAR(20)   = '',
            @V_TIME_ZONE_OFFSET   NVARCHAR(6)    = '',
            @V_TIME_ZONE_NAME   NVARCHAR(50)   = '',
            @V_TIME_ZONE_LOCALE   NVARCHAR(50)   = ''

    -- Obtener zona horaria del usuario
    EXEC SP_OBTENER_ZONA_HORARIA_USUARIO 
        @P_USUANO_U,
        @P_USUCOD_U,
        @P_LOCOFFZON = @V_TIME_ZONE_OFFSET OUTPUT,
        @P_LOCLOC = @V_TIME_ZONE_LOCALE OUTPUT,
        @P_LOCNAMZON = @V_TIME_ZONE_NAME OUTPUT

    -- Realizar eliminación lógica
    SET @V_SQL = ' UPDATE ' + @V_NAME_TABLE + 
                 ' SET ' + 
                 ' USUMOD = ''' + LTRIM(RTRIM(UPPER(@P_USUMOD))) + ''', ' +
                 ' FECMOD = SWITCHOFFSET(SYSDATETIME(), ''' + @V_TIME_ZONE_OFFSET + '''), ' +
                 ' ZONMOD = ''' + LTRIM(RTRIM(UPPER(@V_TIME_ZONE_NAME))) + ''', ' +
                 ' ESTREG = ''E'' ' +
                 ' WHERE [ENTITY]COD = ''' + LTRIM(RTRIM(UPPER(@P_[ENTITY]COD))) + ''' '

    EXEC sp_executesql @V_SQL

    -- Obtener información del registro eliminado
    SET @V_SQL_MENSAJE = ' SELECT @V_CADENA = ''EL [ENTITY] ['' + [FIELD1] + '']'' ' +
                         ' FROM ' + @V_NAME_TABLE + 
                         ' WHERE [ENTITY]COD = ''' + LTRIM(RTRIM(UPPER(@P_[ENTITY]COD))) + ''' '

    EXEC sp_executesql @V_SQL_MENSAJE, N'@V_CADENA NVARCHAR(MAX) OUTPUT', @V_CADENA OUTPUT

    SET @V_DESCRIPTION_LOG = 'ELIMINÓ ' + @V_CADENA
    SET @V_CODE_COMPLETE = LTRIM(RTRIM(UPPER(@P_[ENTITY]COD)))

    -- Registrar log de éxito
    EXEC SP_REGISTER_LOG @V_DESCRIPTION_LOG, 'ELIMINAR', @P_LOGIPMAC, @V_CODE_COMPLETE, @V_NAME_TABLE, @V_SQL, 'EXITO',
         @P_USUANO_U, @P_USUCOD_U, @P_USUNOM_U, @P_USUAPE_U,
         @P_MESSAGE_DESCRIPTION = @P_MESSAGE_DESCRIPTION OUTPUT,
         @P_MESSAGE_TYPE = @P_MESSAGE_TYPE OUTPUT,
         @P_LOGYEA = @V_CODE_LOG_YEAR OUTPUT,
         @P_LOGCOD = @V_CODE_LOG OUTPUT

    SET @P_MESSAGE_DESCRIPTION = 'El [ENTITY] se eliminó correctamente'
    SET @P_MESSAGE_TYPE = '3'

    EXEC SP_UPDATE_DATE_END_SQL @V_CODE_LOG_YEAR, @V_CODE_LOG, @V_SQL

END TRY
BEGIN CATCH
    SET @V_ERROR = LTRIM(RTRIM(UPPER(ERROR_MESSAGE())))
    EXEC SP_REGISTER_LOG @V_ERROR, 'ELIMINAR', @P_LOGIPMAC, @V_CODE_COMPLETE, @V_NAME_TABLE, @V_SQL, 'ERROR',
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
-- 2. Reemplazar [FIELD1] con el campo descriptivo principal
-- 3. Reemplazar [DATA_TYPE] con el tipo de dato correspondiente
-- 4. Descomentar y configurar validaciones de integridad referencial
-- 5. Agregar más validaciones según reglas de negocio
-- 
-- VALIDACIONES DE INTEGRIDAD REFERENCIAL:
-- Descomentar y personalizar según las relaciones de la tabla:
-- 
-- Para tablas que son referenciadas por otras:
-- IF EXISTS (SELECT 1 FROM TM_USUARIO WHERE CARCOD = @P_CARCOD AND ESTREG <> 'E')
-- BEGIN
--     SET @P_MESSAGE_DESCRIPTION = 'No se puede eliminar: existen usuarios con este cargo'
--     SET @P_MESSAGE_TYPE = '2'
--     RETURN
-- END
-- 
-- CARACTERÍSTICAS:
-- - Eliminación lógica (ESTREG = 'E')
-- - Validación de existencia del registro
-- - Validaciones de integridad referencial
-- - Manejo de zona horaria del usuario
-- - Actualización de campos de auditoría (FECMOD, USUMOD, etc.)
-- - Logging detallado de operaciones
-- - Compatible con tablas base (TB_)
-- =============================================
