-- *****************************************************************************************************
-- Description       : Unified search for documents with pagination support
-- Created by        : Enzo Gago Aguirre  
-- Creation Date     : 17/12/2025
-- Purpose           : Search and retrieve document data (replaces GetAll/GetById)
-- Features          : - Parameterized dynamic SQL (SQL injection prevention)
--                     - Multitenancy via @P_ROLCOD_U (admin bypass via project owner)
--                     - Optional pagination
--                     - Always logs errors, success logging optional (@P_USE_LOG)
--                     - Returns JSON (FOR JSON PATH)
-- Parameters        : @P_DOCYEA/@P_DOCCOD = GetById mode
--                     @P_SEARCH = Search by document name
--                     @P_DOCTYP = Type filter
--                     @P_DOCSTA = Status filter
--                     @P_PROYEA/@P_PROCOD = Project filter
-- *****************************************************************************************************

CREATE OR ALTER PROCEDURE SP_DOCUMENT_SEARCH
    @P_DOCYEA               CHAR(04) = NULL,
    @P_DOCCOD               CHAR(06) = NULL,
    @P_SEARCH               VARCHAR(100) = NULL,
    @P_DOCTYP               CHAR(02) = NULL,
    @P_DOCSTA               CHAR(01) = NULL,
    @P_PROYEA               CHAR(04) = NULL,
    @P_PROCOD               CHAR(06) = NULL,
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
                @V_WHERE            NVARCHAR(MAX) = ' WHERE D.STAREC <> ''D'' ',
                @V_PARAMS           NVARCHAR(MAX) = '',
                @V_NAME_TABLE       NVARCHAR(100) = 'TM_DOCUMENT',
                @V_CODE_LOG_YEAR    CHAR(4) = '',
                @V_CODE_LOG         CHAR(10) = '',
                @V_DESCRIPTION_LOG  NVARCHAR(300) = 'DOCUMENT SEARCH',
                @V_OFFSET           INT = 0,
                @V_USE_PAGINATION   BIT = 0,
                @V_LOG_CODE_REC     VARCHAR(20) = '';
        
        SET @V_LOG_CODE_REC = ISNULL(@P_DOCYEA, '') + '-' + ISNULL(@P_DOCCOD, '');
        
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
        
        IF @P_DOCYEA IS NOT NULL AND @P_DOCCOD IS NOT NULL
            SET @V_WHERE = @V_WHERE + ' AND D.DOCYEA = @P_DOCYEA AND D.DOCCOD = @P_DOCCOD';
        
        IF @P_SEARCH IS NOT NULL AND LEN(LTRIM(RTRIM(@P_SEARCH))) > 0
            SET @V_WHERE = @V_WHERE + ' AND D.DOCNAM LIKE ''%'' + @P_SEARCH + ''%''';
        
        IF @P_DOCTYP IS NOT NULL
            SET @V_WHERE = @V_WHERE + ' AND D.DOCTYP = @P_DOCTYP';
        
        IF @P_DOCSTA IS NOT NULL
            SET @V_WHERE = @V_WHERE + ' AND D.DOCSTA = @P_DOCSTA';
        
        IF @P_PROYEA IS NOT NULL AND @P_PROCOD IS NOT NULL
            SET @V_WHERE = @V_WHERE + ' AND D.PROYEA = @P_PROYEA AND D.PROCOD = @P_PROCOD';
        
        -- Multitenancy: Non-admin users only see documents from their projects
        IF @P_ROLCOD_U IS NOT NULL AND @P_ROLCOD_U <> '01' 
           AND @P_USEYEA_U IS NOT NULL AND @P_USECOD_U IS NOT NULL
            SET @V_WHERE = @V_WHERE + ' AND P.USEYEA = @P_USEYEA_U AND P.USECOD = @P_USECOD_U';
        
        SET @V_SQL_COUNT = 'SELECT @V_TOTAL = COUNT(*) FROM TM_DOCUMENT D 
                           LEFT JOIN TM_PROJECT P ON D.PROYEA = P.PROYEA AND D.PROCOD = P.PROCOD ' + @V_WHERE;
        
        SET @V_PARAMS = N'@P_DOCYEA CHAR(04), @P_DOCCOD CHAR(06), @P_SEARCH VARCHAR(100), 
                         @P_DOCTYP CHAR(02), @P_DOCSTA CHAR(01), @P_PROYEA CHAR(04), @P_PROCOD CHAR(06),
                         @P_USEYEA_U CHAR(04), @P_USECOD_U CHAR(06), @V_TOTAL INT OUTPUT';
        
        EXEC sp_executesql @V_SQL_COUNT, @V_PARAMS,
            @P_DOCYEA = @P_DOCYEA, @P_DOCCOD = @P_DOCCOD, @P_SEARCH = @P_SEARCH,
            @P_DOCTYP = @P_DOCTYP, @P_DOCSTA = @P_DOCSTA, @P_PROYEA = @P_PROYEA, @P_PROCOD = @P_PROCOD,
            @P_USEYEA_U = @P_USEYEA_U, @P_USECOD_U = @P_USECOD_U, @V_TOTAL = @P_TOTAL_RECORDS OUTPUT;
        
        SET @V_SQL = '
            SELECT 
                D.DOCYEA, D.DOCCOD, D.DOCNAM, D.DOCDES, D.DOCTYP,
                T.DOCTYPNAM, T.DOCTYPICO,
                D.DOCPAT, D.DOCFIL, D.DOCSIZ, D.DOCMIM, D.DOCSTA,
                D.PROYEA, D.PROCOD, P.PRONAM,
                D.USECRE, D.DATCRE, D.ZONCRE, D.USEUPD, D.DATUPD, D.ZONUPD, D.STAREC
            FROM TM_DOCUMENT D
            LEFT JOIN TB_DOCUMENT_TYPE T ON D.DOCTYP = T.DOCTYP
            LEFT JOIN TM_PROJECT P ON D.PROYEA = P.PROYEA AND D.PROCOD = P.PROCOD
            ' + @V_WHERE + '
            ORDER BY D.DATCRE DESC';
        
        IF @V_USE_PAGINATION = 1
            SET @V_SQL = @V_SQL + ' OFFSET ' + CAST(@V_OFFSET AS VARCHAR(10)) + ' ROWS FETCH NEXT ' + CAST(@P_PAGE_SIZE AS VARCHAR(10)) + ' ROWS ONLY';
        
        SET @V_SQL = @V_SQL + ' FOR JSON PATH';
        
        SET @V_PARAMS = N'@P_DOCYEA CHAR(04), @P_DOCCOD CHAR(06), @P_SEARCH VARCHAR(100), 
                         @P_DOCTYP CHAR(02), @P_DOCSTA CHAR(01), @P_PROYEA CHAR(04), @P_PROCOD CHAR(06),
                         @P_USEYEA_U CHAR(04), @P_USECOD_U CHAR(06)';
        
        EXEC sp_executesql @V_SQL, @V_PARAMS,
            @P_DOCYEA = @P_DOCYEA, @P_DOCCOD = @P_DOCCOD, @P_SEARCH = @P_SEARCH,
            @P_DOCTYP = @P_DOCTYP, @P_DOCSTA = @P_DOCSTA, @P_PROYEA = @P_PROYEA, @P_PROCOD = @P_PROCOD,
            @P_USEYEA_U = @P_USEYEA_U, @P_USECOD_U = @P_USECOD_U;
        
        SET @P_MESSAGE_DESCRIPTION = 'Documentos obtenidos correctamente';
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
