-- *****************************************************************************************************
-- Description       : Unified search for users with pagination support
-- Created by        : Enzo Gago Aguirre  
-- Creation Date     : 17/12/2025
-- Purpose           : Search and retrieve user data (replaces GetAll/GetById)
-- Features          : - Parameterized dynamic SQL (SQL injection prevention)
--                     - Admin only access (users table should be admin-restricted)
--                     - Optional pagination
--                     - Always logs errors, success logging optional (@P_USE_LOG)
--                     - Returns JSON (FOR JSON PATH)
-- Parameters        : @P_USEYEA/@P_USECOD = GetById mode
--                     @P_SEARCH = Search by name/email
--                     @P_ROLCOD = Role filter
--                     @P_USESTA = Status filter
-- *****************************************************************************************************

CREATE OR ALTER PROCEDURE SP_USER_SEARCH
    @P_USEYEA               CHAR(04) = NULL,
    @P_USECOD               CHAR(06) = NULL,
    @P_USEEXTID             NVARCHAR(100) = NULL,
    @P_SEARCH               VARCHAR(100) = NULL,
    @P_ROLCOD               CHAR(02) = NULL,
    @P_USESTA               CHAR(01) = NULL,
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
                @V_WHERE            NVARCHAR(MAX) = ' WHERE U.STAREC <> ''D'' ',
                @V_PARAMS           NVARCHAR(MAX) = '',
                @V_NAME_TABLE       NVARCHAR(100) = 'TM_USER',
                @V_CODE_LOG_YEAR    CHAR(4) = '',
                @V_CODE_LOG         CHAR(10) = '',
                @V_DESCRIPTION_LOG  NVARCHAR(300) = 'USER SEARCH',
                @V_OFFSET           INT = 0,
                @V_USE_PAGINATION   BIT = 0,
                @V_LOG_CODE_REC     VARCHAR(20) = '';
        
        SET @V_LOG_CODE_REC = ISNULL(@P_USEYEA, '') + '-' + ISNULL(@P_USECOD, '');
        
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
        
        IF @P_USEYEA IS NOT NULL AND @P_USECOD IS NOT NULL
            SET @V_WHERE = @V_WHERE + ' AND U.USEYEA = @P_USEYEA AND U.USECOD = @P_USECOD';
        
        IF @P_USEEXTID IS NOT NULL
            SET @V_WHERE = @V_WHERE + ' AND U.USEEXTID = @P_USEEXTID';
        
        IF @P_SEARCH IS NOT NULL AND LEN(LTRIM(RTRIM(@P_SEARCH))) > 0
            SET @V_WHERE = @V_WHERE + ' AND (U.USENAM LIKE ''%'' + @P_SEARCH + ''%'' 
                                         OR U.USELAS LIKE ''%'' + @P_SEARCH + ''%''
                                         OR U.USEEMA LIKE ''%'' + @P_SEARCH + ''%'')';
        
        IF @P_ROLCOD IS NOT NULL
            SET @V_WHERE = @V_WHERE + ' AND U.ROLCOD = @P_ROLCOD';
        
        IF @P_USESTA IS NOT NULL
            SET @V_WHERE = @V_WHERE + ' AND U.USESTA = @P_USESTA';
        
        SET @V_SQL_COUNT = 'SELECT @V_TOTAL = COUNT(*) FROM TM_USER U ' + @V_WHERE;
        
        SET @V_PARAMS = N'@P_USEYEA CHAR(04), @P_USECOD CHAR(06), @P_USEEXTID NVARCHAR(100), @P_SEARCH VARCHAR(100), 
                         @P_ROLCOD CHAR(02), @P_USESTA CHAR(01), @V_TOTAL INT OUTPUT';
        
        EXEC sp_executesql @V_SQL_COUNT, @V_PARAMS,
            @P_USEYEA = @P_USEYEA, @P_USECOD = @P_USECOD, @P_USEEXTID = @P_USEEXTID, @P_SEARCH = @P_SEARCH,
            @P_ROLCOD = @P_ROLCOD, @P_USESTA = @P_USESTA, @V_TOTAL = @P_TOTAL_RECORDS OUTPUT;
        
        SET @V_SQL = '
            SELECT 
                U.USEYEA, U.USECOD, U.USEEXTID, U.USENAM, U.USELAS, U.USEEMA, U.USEIMG, U.USESTA,
                U.ROLCOD, R.ROLNAM,
                U.DATCRE, U.DATUPD, U.STAREC
            FROM TM_USER U
            LEFT JOIN TB_ROLE R ON U.ROLCOD = R.ROLCOD
            ' + @V_WHERE + '
            ORDER BY U.DATCRE DESC';
        
        IF @V_USE_PAGINATION = 1
            SET @V_SQL = @V_SQL + ' OFFSET ' + CAST(@V_OFFSET AS VARCHAR(10)) + ' ROWS FETCH NEXT ' + CAST(@P_PAGE_SIZE AS VARCHAR(10)) + ' ROWS ONLY';
        
        SET @V_SQL = @V_SQL + ' FOR JSON PATH';
        
        SET @V_PARAMS = N'@P_USEYEA CHAR(04), @P_USECOD CHAR(06), @P_USEEXTID NVARCHAR(100), @P_SEARCH VARCHAR(100), 
                         @P_ROLCOD CHAR(02), @P_USESTA CHAR(01)';
        
        EXEC sp_executesql @V_SQL, @V_PARAMS,
            @P_USEYEA = @P_USEYEA, @P_USECOD = @P_USECOD, @P_USEEXTID = @P_USEEXTID, @P_SEARCH = @P_SEARCH,
            @P_ROLCOD = @P_ROLCOD, @P_USESTA = @P_USESTA;
        
        SET @P_MESSAGE_DESCRIPTION = 'Usuarios obtenidos correctamente';
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
