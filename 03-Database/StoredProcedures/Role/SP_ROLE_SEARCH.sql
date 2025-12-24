 -- *****************************************************************************************************
-- Description       : Search roles
-- Created by        : Enzo Gago Aguirre
-- Creation Date     : 09/12/2025
-- Updated           : 17/12/2025 - Standardized
-- Purpose           : Returns all active roles as JSON
-- Features          : - FOR JSON PATH output
--                     - Optional @P_USE_LOG for logging
-- *****************************************************************************************************

CREATE OR ALTER PROCEDURE SP_ROLE_SEARCH
    @P_ROLCOD               CHAR(02) = NULL,
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
    
    DECLARE @V_NAME_TABLE       NVARCHAR(100) = 'TB_ROLE',
            @V_CODE_LOG_YEAR    CHAR(4) = '',
            @V_CODE_LOG         CHAR(10) = '',
            @V_DESCRIPTION_LOG  NVARCHAR(300) = 'ROLE SEARCH',
            @V_LOG_CODE_REC     VARCHAR(20) = 'ALL',
            @V_SQL              NVARCHAR(MAX) = '',
            @V_WHERE            NVARCHAR(MAX) = ' WHERE STAREC <> ''D'' ';
    
    BEGIN TRY
        IF @P_USE_LOG = 1
        BEGIN
            EXEC SP_REGISTER_LOG @V_DESCRIPTION_LOG, 'SELECT', @P_LOGIPMAC, @V_LOG_CODE_REC,
                @V_NAME_TABLE, '', 'SUCCESS', @P_USEYEA_U, @P_USECOD_U, @P_USENAM_U, @P_USELAS_U,
                @P_MESSAGE_DESCRIPTION = @P_MESSAGE_DESCRIPTION OUTPUT, @P_MESSAGE_TYPE = @P_MESSAGE_TYPE OUTPUT,
                @P_LOGYEA = @V_CODE_LOG_YEAR OUTPUT, @P_LOGCOD = @V_CODE_LOG OUTPUT;
        END
        
        IF @P_ROLCOD IS NOT NULL
        BEGIN
            SET @V_WHERE = @V_WHERE + ' AND ROLCOD = ''' + @P_ROLCOD + '''';
            SET @V_LOG_CODE_REC = @P_ROLCOD;
        END
        
        -- Count
        SET @V_SQL = 'SELECT @CNT = COUNT(*) FROM TB_ROLE ' + @V_WHERE;
        EXEC sp_executesql @V_SQL, N'@CNT INT OUTPUT', @P_TOTAL_RECORDS OUTPUT;
        
        -- Query
        SET @V_SQL = '
            SELECT ROLCOD, ROLNAM, ROLDES, USECRE, DATCRE, ZONCRE, USEUPD, DATUPD, ZONUPD, STAREC
            FROM TB_ROLE ' + @V_WHERE + ' ORDER BY ROLCOD FOR JSON PATH';
        
        EXEC sp_executesql @V_SQL;
        
        IF @P_USE_LOG = 1
            EXEC SP_UPDATE_DATE_END_SQL @V_CODE_LOG_YEAR, @V_CODE_LOG, @V_SQL;
        
        SET @P_MESSAGE_TYPE = 3;
        SET @P_MESSAGE_DESCRIPTION = 'Roles obtenidos correctamente';
        
    END TRY
    BEGIN CATCH
        DECLARE @V_ERROR NVARCHAR(MAX) = ERROR_MESSAGE();
        
        EXEC SP_REGISTER_LOG @V_ERROR, 'SELECT', @P_LOGIPMAC, @V_LOG_CODE_REC,
            @V_NAME_TABLE, '', 'ERROR', @P_USEYEA_U, @P_USECOD_U, @P_USENAM_U, @P_USELAS_U,
            @P_MESSAGE_DESCRIPTION = @P_MESSAGE_DESCRIPTION OUTPUT, @P_MESSAGE_TYPE = @P_MESSAGE_TYPE OUTPUT,
            @P_LOGYEA = @V_CODE_LOG_YEAR OUTPUT, @P_LOGCOD = @V_CODE_LOG OUTPUT;
        EXEC SP_UPDATE_DATE_END_SQL @V_CODE_LOG_YEAR, @V_CODE_LOG, '';
        
        SET @P_MESSAGE_TYPE = 1;
        SET @P_MESSAGE_DESCRIPTION = @V_ERROR;
        SET @P_TOTAL_RECORDS = 0;
    END CATCH
END
GO
