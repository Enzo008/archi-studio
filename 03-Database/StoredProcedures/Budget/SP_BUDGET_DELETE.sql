-- *****************************************************************************************************
-- Description       : Delete (soft delete) a budget
-- Created by        : Enzo Gago Aguirre
-- Creation Date     : 09/12/2025
-- Updated           : 17/12/2025 - Standardized with common utilities
-- Purpose           : Marks budget and its items as eliminated (STAREC = 'D')
-- Features          : - Also deletes budget items (cascade soft delete)
--                     - ALWAYS logs operations (SP_REGISTER_LOG + SP_UPDATE_DATE_END_SQL)
-- *****************************************************************************************************

CREATE OR ALTER PROCEDURE SP_BUDGET_DELETE
    @P_BUDYEA               CHAR(04),
    @P_BUDCOD               CHAR(06),
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
    
    DECLARE @V_NAME_TABLE       NVARCHAR(100) = 'TM_BUDGET',
            @V_CODE_LOG_YEAR    CHAR(4) = '',
            @V_CODE_LOG         CHAR(10) = '',
            @V_DESCRIPTION_LOG  NVARCHAR(300) = 'BUDGET DELETE',
            @V_LOG_CODE_REC     VARCHAR(20) = '',
            @V_USER_FULL        VARCHAR(65) = '';
    
    SET @V_LOG_CODE_REC = @P_BUDYEA + '-' + @P_BUDCOD;
    SET @V_USER_FULL = LTRIM(RTRIM(@P_USENAM_U)) + ' ' + LTRIM(RTRIM(@P_USELAS_U));
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        IF NOT EXISTS (SELECT 1 FROM TM_BUDGET WHERE BUDYEA = @P_BUDYEA AND BUDCOD = @P_BUDCOD AND STAREC <> 'D')
        BEGIN
            SET @P_MESSAGE_TYPE = 2;
            SET @P_MESSAGE_DESCRIPTION = 'Presupuesto no encontrado';
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Soft delete budget items first
        UPDATE TD_BUDGET_ITEM
        SET USEUPD = @V_USER_FULL, DATUPD = GETDATE(), ZONUPD = 'America/Lima', STAREC = 'D'
        WHERE BUDYEA = @P_BUDYEA AND BUDCOD = @P_BUDCOD;
        
        -- Soft delete budget
        UPDATE TM_BUDGET
        SET USEUPD = @V_USER_FULL, DATUPD = GETDATE(), ZONUPD = 'America/Lima', STAREC = 'D'
        WHERE BUDYEA = @P_BUDYEA AND BUDCOD = @P_BUDCOD;
        
        COMMIT TRANSACTION;
        
        SET @P_MESSAGE_TYPE = 3;
        SET @P_MESSAGE_DESCRIPTION = 'Presupuesto eliminado correctamente';
        
        EXEC SP_REGISTER_LOG @V_DESCRIPTION_LOG, 'DELETE', @P_LOGIPMAC, @V_LOG_CODE_REC,
            @V_NAME_TABLE, '', 'SUCCESS', @P_USEYEA_U, @P_USECOD_U, @P_USENAM_U, @P_USELAS_U,
            @P_MESSAGE_DESCRIPTION = @P_MESSAGE_DESCRIPTION OUTPUT, @P_MESSAGE_TYPE = @P_MESSAGE_TYPE OUTPUT,
            @P_LOGYEA = @V_CODE_LOG_YEAR OUTPUT, @P_LOGCOD = @V_CODE_LOG OUTPUT;
        EXEC SP_UPDATE_DATE_END_SQL @V_CODE_LOG_YEAR, @V_CODE_LOG, '';
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        
        DECLARE @V_ERROR NVARCHAR(MAX) = ERROR_MESSAGE();
        
        EXEC SP_REGISTER_LOG @V_ERROR, 'DELETE', @P_LOGIPMAC, @V_LOG_CODE_REC,
            @V_NAME_TABLE, '', 'ERROR', @P_USEYEA_U, @P_USECOD_U, @P_USENAM_U, @P_USELAS_U,
            @P_MESSAGE_DESCRIPTION = @P_MESSAGE_DESCRIPTION OUTPUT, @P_MESSAGE_TYPE = @P_MESSAGE_TYPE OUTPUT,
            @P_LOGYEA = @V_CODE_LOG_YEAR OUTPUT, @P_LOGCOD = @V_CODE_LOG OUTPUT;
        EXEC SP_UPDATE_DATE_END_SQL @V_CODE_LOG_YEAR, @V_CODE_LOG, '';
            
        SET @P_MESSAGE_TYPE = 1;
        SET @P_MESSAGE_DESCRIPTION = @V_ERROR;
    END CATCH
END
GO
