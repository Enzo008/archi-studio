-- *****************************************************************************************************
-- Description       : Unified search for budgets with pagination support
-- Created by        : Enzo Gago Aguirre  
-- Creation Date     : 17/12/2025
-- Purpose           : Search and retrieve budget data (replaces GetAll/GetById)
-- Features          : - Parameterized dynamic SQL (SQL injection prevention)
--                     - Multitenancy via @P_ROLCOD_U (admin bypass via project owner)
--                     - Optional pagination
--                     - Always logs errors, success logging optional (@P_USE_LOG)
--                     - Returns JSON (FOR JSON PATH)
--                     - List mode: Returns budgets WITHOUT items
--                     - Detail mode (PK provided): Returns budget WITH items as nested array
-- Parameters        : @P_BUDYEA/@P_BUDCOD = GetById mode (includes items)
--                     @P_SEARCH = Search by budget name
--                     @P_BUDSTA = Status filter
--                     @P_PROYEA/@P_PROCOD = Project filter
-- *****************************************************************************************************

CREATE OR ALTER PROCEDURE SP_BUDGET_SEARCH
    @P_BUDYEA               CHAR(04) = NULL,
    @P_BUDCOD               CHAR(06) = NULL,
    @P_SEARCH               VARCHAR(100) = NULL,
    @P_BUDSTA               CHAR(02) = NULL,
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
                @V_WHERE            NVARCHAR(MAX) = ' WHERE B.STAREC <> ''D'' ',
                @V_PARAMS           NVARCHAR(MAX) = '',
                @V_NAME_TABLE       NVARCHAR(100) = 'TM_BUDGET',
                @V_CODE_LOG_YEAR    CHAR(4) = '',
                @V_CODE_LOG         CHAR(10) = '',
                @V_DESCRIPTION_LOG  NVARCHAR(300) = 'BUDGET SEARCH',
                @V_OFFSET           INT = 0,
                @V_USE_PAGINATION   BIT = 0,
                @V_LOG_CODE_REC     VARCHAR(20) = '',
                @V_IS_DETAIL_MODE   BIT = 0;
        
        SET @V_LOG_CODE_REC = ISNULL(@P_BUDYEA, '') + '-' + ISNULL(@P_BUDCOD, '');
        
        IF @P_BUDYEA IS NOT NULL AND @P_BUDCOD IS NOT NULL
            SET @V_IS_DETAIL_MODE = 1;
        
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
        
        IF @V_IS_DETAIL_MODE = 1
            SET @V_WHERE = @V_WHERE + ' AND B.BUDYEA = @P_BUDYEA AND B.BUDCOD = @P_BUDCOD';
        
        IF @P_SEARCH IS NOT NULL AND LEN(LTRIM(RTRIM(@P_SEARCH))) > 0
            SET @V_WHERE = @V_WHERE + ' AND B.BUDNAM LIKE ''%'' + @P_SEARCH + ''%''';
        
        IF @P_BUDSTA IS NOT NULL
            SET @V_WHERE = @V_WHERE + ' AND B.BUDSTA = @P_BUDSTA';
        
        IF @P_PROYEA IS NOT NULL AND @P_PROCOD IS NOT NULL
            SET @V_WHERE = @V_WHERE + ' AND B.PROYEA = @P_PROYEA AND B.PROCOD = @P_PROCOD';
        
        IF @P_ROLCOD_U IS NOT NULL AND @P_ROLCOD_U <> '01' 
           AND @P_USEYEA_U IS NOT NULL AND @P_USECOD_U IS NOT NULL
            SET @V_WHERE = @V_WHERE + ' AND P.USEYEA = @P_USEYEA_U AND P.USECOD = @P_USECOD_U';
        
        SET @V_SQL_COUNT = 'SELECT @V_TOTAL = COUNT(*) FROM TM_BUDGET B 
                           INNER JOIN TM_PROJECT P ON B.PROYEA = P.PROYEA AND B.PROCOD = P.PROCOD ' + @V_WHERE;
        
        SET @V_PARAMS = N'@P_BUDYEA CHAR(04), @P_BUDCOD CHAR(06), @P_SEARCH VARCHAR(100), 
                         @P_BUDSTA CHAR(02), @P_PROYEA CHAR(04), @P_PROCOD CHAR(06),
                         @P_USEYEA_U CHAR(04), @P_USECOD_U CHAR(06), @V_TOTAL INT OUTPUT';
        
        EXEC sp_executesql @V_SQL_COUNT, @V_PARAMS,
            @P_BUDYEA = @P_BUDYEA, @P_BUDCOD = @P_BUDCOD, @P_SEARCH = @P_SEARCH,
            @P_BUDSTA = @P_BUDSTA, @P_PROYEA = @P_PROYEA, @P_PROCOD = @P_PROCOD,
            @P_USEYEA_U = @P_USEYEA_U, @P_USECOD_U = @P_USECOD_U, @V_TOTAL = @P_TOTAL_RECORDS OUTPUT;
        
        -- DETAIL MODE: Return single budget with items as nested array
        IF @V_IS_DETAIL_MODE = 1
        BEGIN
            SET @V_SQL = '
                SELECT 
                    B.BUDYEA, B.BUDCOD, B.BUDNAM, B.BUDDES, B.BUDSTA,
                    S.BUDSTANAM, S.BUDSTAICO, S.BUDSTACOL,
                    B.BUDTOT, B.BUDDAT, B.BUDEXP, B.BUDNOT,
                    B.PROYEA, B.PROCOD, P.PRONAM, C.CLINAM,
                    B.USECRE, B.DATCRE, B.ZONCRE, B.USEUPD, B.DATUPD, B.ZONUPD, B.STAREC,
                    (SELECT 
                        I.BUDYEA, I.BUDCOD, I.BUDITENUM, I.BUDITENAM, I.BUDITEQTY, I.BUDITEUNI,
                        I.BUDITEPRI, I.BUDITETOT, I.BUDITESTA, I.BUDITENOT,
                        I.BUDITEIMGPAT, I.BUDITEIMGFIL, I.BUDITEIMGSIZ, I.BUDITEIMGMIM
                     FROM TD_BUDGET_ITEM I 
                     WHERE I.BUDYEA = B.BUDYEA AND I.BUDCOD = B.BUDCOD AND I.STAREC <> ''D''
                     ORDER BY I.BUDITENUM
                     FOR JSON PATH) AS Items
                FROM TM_BUDGET B
                LEFT JOIN TB_BUDGET_STATUS S ON B.BUDSTA = S.BUDSTA
                INNER JOIN TM_PROJECT P ON B.PROYEA = P.PROYEA AND B.PROCOD = P.PROCOD
                LEFT JOIN TM_CLIENT C ON P.CLIYEA = C.CLIYEA AND P.CLICOD = C.CLICOD
                ' + @V_WHERE + '
                FOR JSON PATH';
        END
        ELSE
        BEGIN
            -- LIST MODE: Return budgets WITHOUT items
            SET @V_SQL = '
                SELECT 
                    B.BUDYEA, B.BUDCOD, B.BUDNAM, B.BUDDES, B.BUDSTA,
                    S.BUDSTANAM, S.BUDSTAICO, S.BUDSTACOL,
                    B.BUDTOT, B.BUDDAT, B.BUDEXP, B.BUDNOT,
                    B.PROYEA, B.PROCOD, P.PRONAM,
                    B.USECRE, B.DATCRE, B.ZONCRE, B.USEUPD, B.DATUPD, B.ZONUPD, B.STAREC
                FROM TM_BUDGET B
                LEFT JOIN TB_BUDGET_STATUS S ON B.BUDSTA = S.BUDSTA
                INNER JOIN TM_PROJECT P ON B.PROYEA = P.PROYEA AND B.PROCOD = P.PROCOD
                ' + @V_WHERE + '
                ORDER BY B.DATCRE DESC';
            
            IF @V_USE_PAGINATION = 1
                SET @V_SQL = @V_SQL + ' OFFSET ' + CAST(@V_OFFSET AS VARCHAR(10)) + ' ROWS FETCH NEXT ' + CAST(@P_PAGE_SIZE AS VARCHAR(10)) + ' ROWS ONLY';
            
            SET @V_SQL = @V_SQL + ' FOR JSON PATH';
        END
        
        SET @V_PARAMS = N'@P_BUDYEA CHAR(04), @P_BUDCOD CHAR(06), @P_SEARCH VARCHAR(100), 
                         @P_BUDSTA CHAR(02), @P_PROYEA CHAR(04), @P_PROCOD CHAR(06),
                         @P_USEYEA_U CHAR(04), @P_USECOD_U CHAR(06)';
        
        EXEC sp_executesql @V_SQL, @V_PARAMS,
            @P_BUDYEA = @P_BUDYEA, @P_BUDCOD = @P_BUDCOD, @P_SEARCH = @P_SEARCH,
            @P_BUDSTA = @P_BUDSTA, @P_PROYEA = @P_PROYEA, @P_PROCOD = @P_PROCOD,
            @P_USEYEA_U = @P_USEYEA_U, @P_USECOD_U = @P_USECOD_U;
        
        SET @P_MESSAGE_DESCRIPTION = 'Presupuestos obtenidos correctamente';
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

