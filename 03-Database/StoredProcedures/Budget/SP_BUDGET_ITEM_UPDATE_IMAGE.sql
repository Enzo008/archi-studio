-- *****************************************************************************************************
-- Description       : Update budget item image only
-- Created by        : Enzo Gago Aguirre
-- Creation Date     : 12/12/2025
-- Updated           : 17/12/2025 - Standardized with common utilities
-- Purpose           : Updates only the image fields of a budget item (partial update)
-- Features          : - ALWAYS logs operations (SP_REGISTER_LOG + SP_UPDATE_DATE_END_SQL)
-- *****************************************************************************************************

CREATE OR ALTER PROCEDURE SP_BUDGET_ITEM_UPDATE_IMAGE
    @P_BUDYEA               CHAR(04),
    @P_BUDCOD               CHAR(06),
    @P_BUDITENUM            INT,
    @P_BUDITEIMGPAT         VARCHAR(500),
    @P_BUDITEIMGFIL         VARCHAR(200),
    @P_BUDITEIMGSIZ         BIGINT,
    @P_BUDITEIMGMIM         VARCHAR(100),
    @P_LOGIPMAC             VARCHAR(15) = NULL,
    @P_USEYEA_U             CHAR(04) = NULL,
    @P_USECOD_U             CHAR(06) = NULL,
    @P_USENAM_U             VARCHAR(30) = NULL,
    @P_USELAS_U             VARCHAR(30) = NULL,
    @P_ROLCOD_U             CHAR(02) = NULL,
    @P_MESSAGE_DESCRIPTION  NVARCHAR(500) OUTPUT,
    @P_MESSAGE_TYPE         INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @V_NAME_TABLE       NVARCHAR(100) = 'TD_BUDGET_ITEM',
            @V_CODE_LOG_YEAR    CHAR(4) = '',
            @V_CODE_LOG         CHAR(10) = '',
            @V_DESCRIPTION_LOG  NVARCHAR(300) = 'BUDGET ITEM IMAGE UPDATE',
            @V_LOG_CODE_REC     VARCHAR(30) = '',
            @V_USER_FULL        VARCHAR(65) = '';
    
    SET @V_LOG_CODE_REC = @P_BUDYEA + '-' + @P_BUDCOD + '-' + CAST(@P_BUDITENUM AS VARCHAR(10));
    SET @V_USER_FULL = LTRIM(RTRIM(@P_USENAM_U)) + ' ' + LTRIM(RTRIM(@P_USELAS_U));
    
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM TD_BUDGET_ITEM WHERE BUDYEA = @P_BUDYEA AND BUDCOD = @P_BUDCOD AND BUDITENUM = @P_BUDITENUM AND STAREC <> 'D')
        BEGIN
            SET @P_MESSAGE_TYPE = 2;
            SET @P_MESSAGE_DESCRIPTION = 'Item no encontrado';
            RETURN;
        END
        
        UPDATE TD_BUDGET_ITEM
        SET BUDITEIMGPAT = @P_BUDITEIMGPAT, BUDITEIMGFIL = @P_BUDITEIMGFIL,
            BUDITEIMGSIZ = @P_BUDITEIMGSIZ, BUDITEIMGMIM = @P_BUDITEIMGMIM,
            USEUPD = @V_USER_FULL, DATUPD = GETDATE(), ZONUPD = 'America/Lima'
        WHERE BUDYEA = @P_BUDYEA AND BUDCOD = @P_BUDCOD AND BUDITENUM = @P_BUDITENUM;
        
        SET @P_MESSAGE_TYPE = 3;
        SET @P_MESSAGE_DESCRIPTION = 'Imagen actualizada correctamente';
        
        EXEC SP_REGISTER_LOG @V_DESCRIPTION_LOG, 'UPDATE', @P_LOGIPMAC, @V_LOG_CODE_REC,
            @V_NAME_TABLE, '', 'SUCCESS', @P_USEYEA_U, @P_USECOD_U, @P_USENAM_U, @P_USELAS_U,
            @P_MESSAGE_DESCRIPTION = @P_MESSAGE_DESCRIPTION OUTPUT, @P_MESSAGE_TYPE = @P_MESSAGE_TYPE OUTPUT,
            @P_LOGYEA = @V_CODE_LOG_YEAR OUTPUT, @P_LOGCOD = @V_CODE_LOG OUTPUT;
        EXEC SP_UPDATE_DATE_END_SQL @V_CODE_LOG_YEAR, @V_CODE_LOG, '';
        
    END TRY
    BEGIN CATCH
        DECLARE @V_ERROR NVARCHAR(MAX) = ERROR_MESSAGE();
        
        EXEC SP_REGISTER_LOG @V_ERROR, 'UPDATE', @P_LOGIPMAC, @V_LOG_CODE_REC,
            @V_NAME_TABLE, '', 'ERROR', @P_USEYEA_U, @P_USECOD_U, @P_USENAM_U, @P_USELAS_U,
            @P_MESSAGE_DESCRIPTION = @P_MESSAGE_DESCRIPTION OUTPUT, @P_MESSAGE_TYPE = @P_MESSAGE_TYPE OUTPUT,
            @P_LOGYEA = @V_CODE_LOG_YEAR OUTPUT, @P_LOGCOD = @V_CODE_LOG OUTPUT;
        EXEC SP_UPDATE_DATE_END_SQL @V_CODE_LOG_YEAR, @V_CODE_LOG, '';
            
        SET @P_MESSAGE_TYPE = 1;
        SET @P_MESSAGE_DESCRIPTION = @V_ERROR;
    END CATCH
END
GO
