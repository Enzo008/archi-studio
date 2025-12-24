-- *****************************************************************************************************
-- Description       : Unified search for clients with pagination support
-- Created by        : Enzo Gago Aguirre  
-- Creation Date     : 17/12/2025
-- Purpose           : Search and retrieve client data (replaces GetAll/GetById)
-- Features          : - Parameterized dynamic SQL (SQL injection prevention)
--                     - Multitenancy via @P_ROLCOD_U (admin bypass)
--                     - Optional pagination
--                     - Always logs errors, success logging optional (@P_USE_LOG)
--                     - Returns JSON (FOR JSON PATH)
-- Parameters        : @P_CLIYEA/@P_CLICOD = GetById mode
--                     @P_SEARCH = Search by name/email
--                     @P_CLITYP = Type filter (01=Person, 02=Company)
--                     @P_CLISTA = Status filter (A=Active, I=Inactive)
-- *****************************************************************************************************

CREATE OR ALTER PROCEDURE SP_CLIENT_SEARCH
    @P_CLIYEA               CHAR(04) = NULL,
    @P_CLICOD               CHAR(06) = NULL,
    @P_SEARCH               VARCHAR(100) = NULL,
    @P_CLITYP               CHAR(02) = NULL,
    @P_CLISTA               CHAR(01) = NULL,
    @P_USEYEA               CHAR(04) = NULL,
    @P_USECOD               CHAR(06) = NULL,
    @P_PAGE_NUMBER          INT = NULL,
    @P_PAGE_SIZE            INT = NULL,
    @P_LOGIPMAC             VARCHAR(15) = NULL,
    @P_USEYEA_U             CHAR(04) = NULL,
    @P_USECOD_U             CHAR(06) = NULL,
    @P_USENAM_U             VARCHAR(30) = NULL,
    @P_USELAS_U             VARCHAR(30) = NULL,
    @P_ROLCOD_U             CHAR(02) = NULL,
    @P_USE_LOG              BIT = 0,
    @P_TOTAL_RECORDS        INT OUTPUT,
    @P_MESSAGE_DESCRIPTION  NVARCHAR(500) OUTPUT,
    @P_MESSAGE_TYPE         INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        DECLARE @V_SQL              NVARCHAR(MAX) = '',
                @V_SQL_COUNT        NVARCHAR(MAX) = '',
                @V_WHERE            NVARCHAR(MAX) = ' WHERE C.STAREC <> ''D'' ',
                @V_PARAMS           NVARCHAR(MAX) = '',
                @V_NAME_TABLE       NVARCHAR(100) = 'TM_CLIENT',
                @V_CODE_LOG_YEAR    CHAR(4) = '',
                @V_CODE_LOG         CHAR(10) = '',
                @V_DESCRIPTION_LOG  NVARCHAR(300) = 'CLIENT SEARCH',
                @V_OFFSET           INT = 0,
                @V_USE_PAGINATION   BIT = 0,
                @V_LOG_CODE_REC     VARCHAR(20) = '';
        
        SET @V_LOG_CODE_REC = ISNULL(@P_CLIYEA, '') + '-' + ISNULL(@P_CLICOD, '');
        
        IF @P_USE_LOG = 1
        BEGIN
            EXEC SP_REGISTER_LOG @V_DESCRIPTION_LOG, 'SEARCH', @P_LOGIPMAC, @V_LOG_CODE_REC,
                @V_NAME_TABLE, '', 'START', @P_USEYEA_U, @P_USECOD_U, @P_USENAM_U, @P_USELAS_U,
                @P_MESSAGE_DESCRIPTION = @P_MESSAGE_DESCRIPTION OUTPUT,
                @P_MESSAGE_TYPE = @P_MESSAGE_TYPE OUTPUT,
                @P_LOGYEA = @V_CODE_LOG_YEAR OUTPUT,
                @P_LOGCOD = @V_CODE_LOG OUTPUT;
        END
        
        IF @P_PAGE_NUMBER IS NOT NULL AND @P_PAGE_SIZE IS NOT NULL AND @P_PAGE_SIZE > 0
        BEGIN
            SET @V_USE_PAGINATION = 1;
            SET @V_OFFSET = (@P_PAGE_NUMBER - 1) * @P_PAGE_SIZE;
        END
        
        IF @P_CLIYEA IS NOT NULL AND @P_CLICOD IS NOT NULL
            SET @V_WHERE = @V_WHERE + ' AND C.CLIYEA = @P_CLIYEA AND C.CLICOD = @P_CLICOD';
        
        IF @P_SEARCH IS NOT NULL AND LEN(LTRIM(RTRIM(@P_SEARCH))) > 0
            SET @V_WHERE = @V_WHERE + ' AND (C.CLINAM LIKE ''%'' + @P_SEARCH + ''%'' 
                                         OR C.CLIEMA LIKE ''%'' + @P_SEARCH + ''%'')';
        
        IF @P_CLITYP IS NOT NULL
            SET @V_WHERE = @V_WHERE + ' AND C.CLITYP = @P_CLITYP';
        
        IF @P_CLISTA IS NOT NULL
            SET @V_WHERE = @V_WHERE + ' AND C.CLISTA = @P_CLISTA';
        
        IF @P_USEYEA IS NOT NULL AND @P_USECOD IS NOT NULL
            SET @V_WHERE = @V_WHERE + ' AND C.USEYEA = @P_USEYEA AND C.USECOD = @P_USECOD';
        
        IF @P_ROLCOD_U IS NOT NULL AND @P_ROLCOD_U <> '01' 
           AND @P_USEYEA_U IS NOT NULL AND @P_USECOD_U IS NOT NULL
            SET @V_WHERE = @V_WHERE + ' AND C.USEYEA = @P_USEYEA_U AND C.USECOD = @P_USECOD_U';
        
        SET @V_SQL_COUNT = 'SELECT @V_TOTAL = COUNT(*) FROM TM_CLIENT C ' + @V_WHERE;
        
        SET @V_PARAMS = N'@P_CLIYEA CHAR(04), @P_CLICOD CHAR(06), @P_SEARCH VARCHAR(100), 
                         @P_CLITYP CHAR(02), @P_CLISTA CHAR(01),
                         @P_USEYEA CHAR(04), @P_USECOD CHAR(06), @P_USEYEA_U CHAR(04), 
                         @P_USECOD_U CHAR(06), @V_TOTAL INT OUTPUT';
        
        EXEC sp_executesql @V_SQL_COUNT, @V_PARAMS,
            @P_CLIYEA = @P_CLIYEA, @P_CLICOD = @P_CLICOD, @P_SEARCH = @P_SEARCH,
            @P_CLITYP = @P_CLITYP, @P_CLISTA = @P_CLISTA,
            @P_USEYEA = @P_USEYEA, @P_USECOD = @P_USECOD, @P_USEYEA_U = @P_USEYEA_U,
            @P_USECOD_U = @P_USECOD_U, @V_TOTAL = @P_TOTAL_RECORDS OUTPUT;
        
        SET @V_SQL = '
            SELECT 
                C.CLIYEA, C.CLICOD, C.CLINAM, C.CLITYP, C.CLIEMA, C.CLIPHO, C.CLIADD,
                C.CLISTA, C.CLIDES, C.USEYEA, C.USECOD,
                C.USECRE, C.DATCRE, C.ZONCRE, C.USEUPD, C.DATUPD, C.ZONUPD, C.STAREC
            FROM TM_CLIENT C
            ' + @V_WHERE + '
            ORDER BY C.DATCRE DESC';
        
        IF @V_USE_PAGINATION = 1
            SET @V_SQL = @V_SQL + ' OFFSET ' + CAST(@V_OFFSET AS VARCHAR(10)) + ' ROWS FETCH NEXT ' + CAST(@P_PAGE_SIZE AS VARCHAR(10)) + ' ROWS ONLY';
        
        SET @V_SQL = @V_SQL + ' FOR JSON PATH';
        
        SET @V_PARAMS = N'@P_CLIYEA CHAR(04), @P_CLICOD CHAR(06), @P_SEARCH VARCHAR(100), 
                         @P_CLITYP CHAR(02), @P_CLISTA CHAR(01),
                         @P_USEYEA CHAR(04), @P_USECOD CHAR(06), @P_USEYEA_U CHAR(04), 
                         @P_USECOD_U CHAR(06)';
        
        EXEC sp_executesql @V_SQL, @V_PARAMS,
            @P_CLIYEA = @P_CLIYEA, @P_CLICOD = @P_CLICOD, @P_SEARCH = @P_SEARCH,
            @P_CLITYP = @P_CLITYP, @P_CLISTA = @P_CLISTA,
            @P_USEYEA = @P_USEYEA, @P_USECOD = @P_USECOD, @P_USEYEA_U = @P_USEYEA_U,
            @P_USECOD_U = @P_USECOD_U;
        
        SET @P_MESSAGE_DESCRIPTION = 'Clientes obtenidos correctamente';
        SET @P_MESSAGE_TYPE = 3;
        
        IF @P_USE_LOG = 1
            EXEC SP_UPDATE_DATE_END_SQL @V_CODE_LOG_YEAR, @V_CODE_LOG, @V_SQL;
        
    END TRY
    BEGIN CATCH
        DECLARE @V_ERROR NVARCHAR(MAX) = ERROR_MESSAGE();
        
        EXEC SP_REGISTER_LOG @V_ERROR, 'SEARCH', @P_LOGIPMAC, @V_LOG_CODE_REC,
            @V_NAME_TABLE, @V_SQL, 'ERROR', @P_USEYEA_U, @P_USECOD_U, @P_USENAM_U, @P_USELAS_U,
            @P_MESSAGE_DESCRIPTION = @P_MESSAGE_DESCRIPTION OUTPUT,
            @P_MESSAGE_TYPE = @P_MESSAGE_TYPE OUTPUT,
            @P_LOGYEA = @V_CODE_LOG_YEAR OUTPUT,
            @P_LOGCOD = @V_CODE_LOG OUTPUT;
            
        EXEC SP_UPDATE_DATE_END_SQL @V_CODE_LOG_YEAR, @V_CODE_LOG, @V_SQL;
        
        SET @P_MESSAGE_DESCRIPTION = @V_ERROR;
        SET @P_MESSAGE_TYPE = 1;
        SET @P_TOTAL_RECORDS = 0;
    END CATCH
END
GO
