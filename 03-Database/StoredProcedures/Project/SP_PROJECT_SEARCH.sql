-- *****************************************************************************************************
-- Description       : Unified search for projects with pagination support
-- Created by        : Enzo Gago Aguirre  
-- Creation Date     : 17/12/2025
-- Purpose           : Search and retrieve project data (replaces GetAll/GetById)
-- Features          : - Parameterized dynamic SQL (SQL injection prevention)
--                     - Multitenancy via @P_ROLCOD_U (admin bypass)
--                     - Optional pagination
--                     - Always logs errors, success logging optional (@P_USE_LOG)
--                     - Returns JSON (FOR JSON PATH)
-- Parameters        : @P_PROYEA/@P_PROCOD = GetById mode
--                     @P_SEARCH = Search by name/description/address
--                     @P_PROSTA = Status filter
--                     @P_CLIYEA/@P_CLICOD = Client filter
--                     @P_USEYEA/@P_USECOD = Manager filter
-- *****************************************************************************************************

CREATE OR ALTER PROCEDURE SP_PROJECT_SEARCH
    @P_PROYEA               CHAR(04) = NULL,
    @P_PROCOD               CHAR(06) = NULL,
    @P_SEARCH               VARCHAR(100) = NULL,
    @P_PROSTA               CHAR(02) = NULL,
    @P_CLIYEA               CHAR(04) = NULL,
    @P_CLICOD               CHAR(06) = NULL,
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
                @V_WHERE            NVARCHAR(MAX) = ' WHERE P.STAREC <> ''D'' ',
                @V_PARAMS           NVARCHAR(MAX) = '',
                @V_NAME_TABLE       NVARCHAR(100) = 'TM_PROJECT',
                @V_CODE_LOG_YEAR    CHAR(4) = '',
                @V_CODE_LOG         CHAR(10) = '',
                @V_DESCRIPTION_LOG  NVARCHAR(300) = 'PROJECT SEARCH',
                @V_OFFSET           INT = 0,
                @V_USE_PAGINATION   BIT = 0,
                @V_LOG_CODE_REC     VARCHAR(20) = '';
        
        SET @V_LOG_CODE_REC = ISNULL(@P_PROYEA, '') + '-' + ISNULL(@P_PROCOD, '');
        
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
        
        IF @P_PROYEA IS NOT NULL AND @P_PROCOD IS NOT NULL
            SET @V_WHERE = @V_WHERE + ' AND P.PROYEA = @P_PROYEA AND P.PROCOD = @P_PROCOD';
        
        IF @P_SEARCH IS NOT NULL AND LEN(LTRIM(RTRIM(@P_SEARCH))) > 0
            SET @V_WHERE = @V_WHERE + ' AND (P.PRONAM LIKE ''%'' + @P_SEARCH + ''%'' 
                                         OR P.PRODES LIKE ''%'' + @P_SEARCH + ''%''
                                         OR P.PROADD LIKE ''%'' + @P_SEARCH + ''%'')';
        
        IF @P_PROSTA IS NOT NULL
            SET @V_WHERE = @V_WHERE + ' AND P.PROSTA = @P_PROSTA';
        
        IF @P_CLIYEA IS NOT NULL AND @P_CLICOD IS NOT NULL
            SET @V_WHERE = @V_WHERE + ' AND P.CLIYEA = @P_CLIYEA AND P.CLICOD = @P_CLICOD';
        
        IF @P_USEYEA IS NOT NULL AND @P_USECOD IS NOT NULL
            SET @V_WHERE = @V_WHERE + ' AND P.USEYEA = @P_USEYEA AND P.USECOD = @P_USECOD';
        
        -- Multitenancy: Non-admin users only see their own projects
        IF @P_ROLCOD_U IS NOT NULL AND @P_ROLCOD_U <> '01' 
           AND @P_USEYEA_U IS NOT NULL AND @P_USECOD_U IS NOT NULL
            SET @V_WHERE = @V_WHERE + ' AND P.USEYEA = @P_USEYEA_U AND P.USECOD = @P_USECOD_U';
        
        SET @V_SQL_COUNT = 'SELECT @V_TOTAL = COUNT(*) FROM TM_PROJECT P ' + @V_WHERE;
        
        SET @V_PARAMS = N'@P_PROYEA CHAR(04), @P_PROCOD CHAR(06), @P_SEARCH VARCHAR(100), 
                         @P_PROSTA CHAR(02), @P_CLIYEA CHAR(04), @P_CLICOD CHAR(06),
                         @P_USEYEA CHAR(04), @P_USECOD CHAR(06), @P_USEYEA_U CHAR(04), 
                         @P_USECOD_U CHAR(06), @V_TOTAL INT OUTPUT';
        
        EXEC sp_executesql @V_SQL_COUNT, @V_PARAMS,
            @P_PROYEA = @P_PROYEA, @P_PROCOD = @P_PROCOD, @P_SEARCH = @P_SEARCH,
            @P_PROSTA = @P_PROSTA, @P_CLIYEA = @P_CLIYEA, @P_CLICOD = @P_CLICOD,
            @P_USEYEA = @P_USEYEA, @P_USECOD = @P_USECOD, @P_USEYEA_U = @P_USEYEA_U,
            @P_USECOD_U = @P_USECOD_U, @V_TOTAL = @P_TOTAL_RECORDS OUTPUT;
        
        SET @V_SQL = '
            SELECT 
                P.PROYEA, P.PROCOD, P.PRONAM, P.PRODES, P.PROSTA,
                S.PROSTANAM, S.PROSTAICO, S.PROSTACOL,
                P.PROPRO, P.PRODATINI, P.PRODATEND, P.PROBUDGET, P.PROADD,
                P.CLIYEA, P.CLICOD, C.CLINAM,
                P.USEYEA, P.USECOD, U.USENAM, U.USELAS,
                P.USECRE, P.DATCRE, P.ZONCRE, P.USEUPD, P.DATUPD, P.ZONUPD, P.STAREC
            FROM TM_PROJECT P
            LEFT JOIN TB_PROJECT_STATUS S ON P.PROSTA = S.PROSTA
            LEFT JOIN TM_CLIENT C ON P.CLIYEA = C.CLIYEA AND P.CLICOD = C.CLICOD
            LEFT JOIN TM_USER U ON P.USEYEA = U.USEYEA AND P.USECOD = U.USECOD
            ' + @V_WHERE + '
            ORDER BY P.DATCRE DESC';
        
        IF @V_USE_PAGINATION = 1
            SET @V_SQL = @V_SQL + ' OFFSET ' + CAST(@V_OFFSET AS VARCHAR(10)) + ' ROWS FETCH NEXT ' + CAST(@P_PAGE_SIZE AS VARCHAR(10)) + ' ROWS ONLY';
        
        SET @V_SQL = @V_SQL + ' FOR JSON PATH';
        
        SET @V_PARAMS = N'@P_PROYEA CHAR(04), @P_PROCOD CHAR(06), @P_SEARCH VARCHAR(100), 
                         @P_PROSTA CHAR(02), @P_CLIYEA CHAR(04), @P_CLICOD CHAR(06),
                         @P_USEYEA CHAR(04), @P_USECOD CHAR(06), @P_USEYEA_U CHAR(04), 
                         @P_USECOD_U CHAR(06)';
        
        EXEC sp_executesql @V_SQL, @V_PARAMS,
            @P_PROYEA = @P_PROYEA, @P_PROCOD = @P_PROCOD, @P_SEARCH = @P_SEARCH,
            @P_PROSTA = @P_PROSTA, @P_CLIYEA = @P_CLIYEA, @P_CLICOD = @P_CLICOD,
            @P_USEYEA = @P_USEYEA, @P_USECOD = @P_USECOD, @P_USEYEA_U = @P_USEYEA_U,
            @P_USECOD_U = @P_USECOD_U;
        
        SET @P_MESSAGE_DESCRIPTION = 'Proyectos obtenidos correctamente';
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
