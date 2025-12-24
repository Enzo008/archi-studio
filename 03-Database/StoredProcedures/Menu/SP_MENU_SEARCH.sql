-- *****************************************************************************************************
-- Description       : Search menus
-- Created by        : Enzo Gago Aguirre
-- Creation Date     : 09/12/2025
-- Updated           : 17/12/2025 - Standardized
-- Purpose           : Returns all active menus in hierarchical order as JSON
-- Features          : - FOR JSON PATH output
--                     - Optional @P_USE_LOG for logging
-- *****************************************************************************************************

CREATE OR ALTER PROCEDURE SP_MENU_SEARCH
    @P_MENYEA               CHAR(04) = NULL,
    @P_MENCOD               CHAR(06) = NULL,
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
    
    DECLARE @V_NAME_TABLE       NVARCHAR(100) = 'TM_MENU',
            @V_CODE_LOG_YEAR    CHAR(4) = '',
            @V_CODE_LOG         CHAR(10) = '',
            @V_DESCRIPTION_LOG  NVARCHAR(300) = 'MENU SEARCH',
            @V_LOG_CODE_REC     VARCHAR(20) = 'ALL',
            @V_SQL              NVARCHAR(MAX) = '',
            @V_WHERE            NVARCHAR(MAX) = ' WHERE M.STAREC <> ''D'' ';
    
    BEGIN TRY
        IF @P_USE_LOG = 1
        BEGIN
            EXEC SP_REGISTER_LOG @V_DESCRIPTION_LOG, 'SELECT', @P_LOGIPMAC, @V_LOG_CODE_REC,
                @V_NAME_TABLE, '', 'SUCCESS', @P_USEYEA_U, @P_USECOD_U, @P_USENAM_U, @P_USELAS_U,
                @P_MESSAGE_DESCRIPTION = @P_MESSAGE_DESCRIPTION OUTPUT, @P_MESSAGE_TYPE = @P_MESSAGE_TYPE OUTPUT,
                @P_LOGYEA = @V_CODE_LOG_YEAR OUTPUT, @P_LOGCOD = @V_CODE_LOG OUTPUT;
        END
        
        -- Build WHERE clause
        IF @P_MENYEA IS NOT NULL AND @P_MENCOD IS NOT NULL
        BEGIN
            SET @V_WHERE = @V_WHERE + ' AND M.MENYEA = ''' + @P_MENYEA + ''' AND M.MENCOD = ''' + @P_MENCOD + '''';
            SET @V_LOG_CODE_REC = @P_MENYEA + '-' + @P_MENCOD;
        END
        
        IF @P_ROLCOD IS NOT NULL
        BEGIN
            SET @V_WHERE = @V_WHERE + ' AND EXISTS (SELECT 1 FROM TV_ROLE_MENU RM WHERE RM.MENYEA = M.MENYEA AND RM.MENCOD = M.MENCOD AND RM.ROLCOD = ''' + @P_ROLCOD + ''' AND RM.STAREC <> ''D'')';
        END
        
        -- Count
        SET @V_SQL = 'SELECT @CNT = COUNT(*) FROM TM_MENU M ' + @V_WHERE;
        EXEC sp_executesql @V_SQL, N'@CNT INT OUTPUT', @P_TOTAL_RECORDS OUTPUT;
        
        -- Query
        SET @V_SQL = '
            SELECT M.MENYEA, M.MENCOD, M.MENNAM, M.MENREF, M.MENICO, M.MENORD, M.MENYEAPAR, M.MENCODPAR,
                   M.USECRE, M.DATCRE, M.ZONCRE, M.USEUPD, M.DATUPD, M.ZONUPD, M.STAREC
            FROM TM_MENU M ' + @V_WHERE + ' ORDER BY M.MENYEAPAR, M.MENCODPAR, M.MENORD, M.MENYEA, M.MENCOD FOR JSON PATH';
        
        EXEC sp_executesql @V_SQL;
        
        IF @P_USE_LOG = 1
            EXEC SP_UPDATE_DATE_END_SQL @V_CODE_LOG_YEAR, @V_CODE_LOG, @V_SQL;
        
        SET @P_MESSAGE_TYPE = 3;
        SET @P_MESSAGE_DESCRIPTION = 'Menús obtenidos correctamente';
        
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
