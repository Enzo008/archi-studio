-- =============================================
-- Autor:           [Developer Name]
-- Fecha Creación:  [YYYY-MM-DD]
-- Descripción:     Template para búsqueda paginada con filtros - Tablas Base (TB_)
-- Modificaciones:  [Date] - [Author] - [Description]
-- =============================================
CREATE OR ALTER PROCEDURE SP_BUSCAR_[ENTITY]
@P_[ENTITY]COD          CHAR(2),                -- Código de la entidad
@P_[FIELD1]             [DATA_TYPE],            -- Campo principal de filtrado
@P_[FIELD2]             [DATA_TYPE],            -- Campo secundario de filtrado
@P_LOGIPMAC             VARCHAR(15),
@P_USUANO_U             CHAR(4),
@P_USUCOD_U             CHAR(6),
@P_USUNOM_U             VARCHAR(30),
@P_USUAPE_U             VARCHAR(30),
@P_PAGE_NUMBER          INT = NULL,
@P_PAGE_SIZE            INT = NULL,
@P_TOTAL_RECORDS      INT OUTPUT,
@P_MESSAGE_DESCRIPTION  NVARCHAR(MAX) OUTPUT,
@P_MESSAGE_TYPE         CHAR(1) OUTPUT
AS
BEGIN TRY
    SET NOCOUNT ON

    DECLARE @V_SQL               NVARCHAR(MAX)  = '',
            @V_NAME_TABLE      NVARCHAR(300)  = 'TB_[ENTITY]',
            @V_CODE_LOG_YEAR   CHAR(4)        = '',
            @V_CODE_LOG        CHAR(10)       = '',
            @V_DESCRIPTION_LOG   NVARCHAR(300)  = '',
            @V_ERROR             NVARCHAR(MAX)  = '',
            @V_OFFSET            INT            = 0,
            @V_USAR_PAGINACION   BIT            = 0

    SET @V_DESCRIPTION_LOG = 'SE BUSCÓ [ENTITY] '

    -- Determinar si usar paginación
    IF @P_PAGE_NUMBER IS NOT NULL AND @P_PAGE_SIZE IS NOT NULL AND @P_PAGE_SIZE > 0
    BEGIN
        SET @V_USAR_PAGINACION = 1
        SET @V_OFFSET = (@P_PAGE_NUMBER - 1) * @P_PAGE_SIZE
    END

    -- Construir consulta base para contar registros
    SET @V_SQL = 'SELECT @TOTAL = COUNT(*) ' +
                 'FROM TB_[ENTITY] AS ENT ' +
                 'WHERE ENT.ESTREG <> ''E'''

    -- Aplicar filtros al conteo
    IF @P_[ENTITY]COD IS NOT NULL
    BEGIN
        SET @V_SQL = @V_SQL + ' AND ENT.[ENTITY]COD = ''' + LTRIM(RTRIM(@P_[ENTITY]COD)) + ''''
    END

    IF @P_[FIELD1] IS NOT NULL
    BEGIN
        SET @V_SQL = @V_SQL + ' AND ENT.[FIELD1] LIKE ''%' + LTRIM(RTRIM(@P_[FIELD1])) + '%'''
    END

    IF @P_[FIELD2] IS NOT NULL
    BEGIN
        SET @V_SQL = @V_SQL + ' AND ENT.[FIELD2] LIKE ''%' + LTRIM(RTRIM(@P_[FIELD2])) + '%'''
    END

    -- Obtener total de registros
    EXEC sp_executesql @V_SQL, N'@TOTAL INT OUTPUT', @TOTAL = @P_TOTAL_RECORDS OUTPUT

    -- Construir consulta principal para datos
    SET @V_SQL = 'SELECT ENT.[ENTITY]COD, ENT.[FIELD1], ENT.[FIELD2], ' +
                 'ENT.USUING, ENT.FECING, ENT.ZONING, ENT.USUMOD, ENT.FECMOD, ENT.ZONMOD, ENT.ESTREG ' +
                 'FROM TB_[ENTITY] AS ENT ' +
                 'WHERE ENT.ESTREG <> ''E'''

    -- Aplicar mismos filtros a la consulta principal
    IF @P_[ENTITY]COD IS NOT NULL
    BEGIN
        SET @V_SQL = @V_SQL + ' AND ENT.[ENTITY]COD = ''' + LTRIM(RTRIM(@P_[ENTITY]COD)) + ''''
    END

    IF @P_[FIELD1] IS NOT NULL
    BEGIN
        SET @V_SQL = @V_SQL + ' AND ENT.[FIELD1] LIKE ''%' + LTRIM(RTRIM(@P_[FIELD1])) + '%'''
    END

    IF @P_[FIELD2] IS NOT NULL
    BEGIN
        SET @V_SQL = @V_SQL + ' AND ENT.[FIELD2] LIKE ''%' + LTRIM(RTRIM(@P_[FIELD2])) + '%'''
    END

    -- Ordenamiento
    SET @V_SQL = @V_SQL + ' ORDER BY ENT.[ENTITY]COD '

    -- Aplicar paginación si se especifica
    IF @V_USAR_PAGINACION = 1
    BEGIN
        SET @V_SQL = @V_SQL + 
                    ' OFFSET ' + CAST(@V_OFFSET AS VARCHAR) + ' ROWS ' +
                    ' FETCH NEXT ' + CAST(@P_PAGE_SIZE AS VARCHAR) + ' ROWS ONLY '
    END

    -- Formatear como JSON
    SET @V_SQL = @V_SQL + ' FOR JSON PATH'

    -- Ejecutar consulta
    EXECUTE sp_executesql @V_SQL

    SET @P_MESSAGE_DESCRIPTION = 'Llenado de datos exitoso'
    SET @P_MESSAGE_TYPE = '3'

END TRY
BEGIN CATCH
    SET @V_ERROR = LTRIM(RTRIM(UPPER(ERROR_MESSAGE())))
    EXEC SP_REGISTER_LOG @V_ERROR, 'BUSCAR', @P_LOGIPMAC, '', @V_NAME_TABLE, @V_SQL, 'ERROR', 
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
-- 2. Reemplazar [FIELD1], [FIELD2] con los campos específicos de filtrado
-- 3. Reemplazar [DATA_TYPE] con el tipo de dato correspondiente
-- 4. Ajustar filtros según las necesidades de búsqueda
-- 5. Modificar ordenamiento según requerimientos
-- 
-- CARACTERÍSTICAS:
-- - Paginación opcional del lado del servidor
-- - Filtros dinámicos con LIKE para texto
-- - Conteo total separado para paginación
-- - Formato JSON PATH para frontend
-- - Manejo de errores con logging
-- - Compatible con tablas base (TB_)
-- =============================================
