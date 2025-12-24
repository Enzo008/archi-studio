-- *****************************************************************************************************
-- Description       : Create or Update a role (UPSERT)
-- Created by        : Enzo Gago Aguirre
-- Creation Date     : 10/12/2024
-- Updated           : 17/12/2025 - Standardized with common utilities
-- Purpose           : Inserts or updates a role
-- Features          : - UPSERT pattern
--                     - ALWAYS logs operations (SP_REGISTER_LOG + SP_UPDATE_DATE_END_SQL)
-- *****************************************************************************************************

CREATE OR ALTER PROCEDURE SP_ROLE_SAVE
    @P_ROLCOD               CHAR(02),
    @P_ROLNAM               VARCHAR(50),
    @P_ROLDES               VARCHAR(200) = NULL,
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
    
    DECLARE @V_NAME_TABLE       NVARCHAR(100) = 'TB_ROLE',
            @V_CODE_LOG_YEAR    CHAR(4) = '',
            @V_CODE_LOG         CHAR(10) = '',
            @V_DESCRIPTION_LOG  NVARCHAR(300) = '',
            @V_LOG_CODE_REC     VARCHAR(20) = '',
            @V_LOG_ACTION       VARCHAR(10) = '',
            @V_USER_FULL        VARCHAR(65) = '';
    
    SET @V_LOG_CODE_REC = @P_ROLCOD;
    SET @V_USER_FULL = LTRIM(RTRIM(@P_USENAM_U)) + ' ' + LTRIM(RTRIM(@P_USELAS_U));
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        IF EXISTS (SELECT 1 FROM TB_ROLE WHERE ROLCOD = @P_ROLCOD AND STAREC <> 'D')
        BEGIN
            -- UPDATE
            UPDATE TB_ROLE
            SET ROLNAM = COALESCE(@P_ROLNAM, ROLNAM), ROLDES = COALESCE(@P_ROLDES, ROLDES),
                USEUPD = @V_USER_FULL, DATUPD = GETDATE(), ZONUPD = 'America/Lima', STAREC = 'U'
            WHERE ROLCOD = @P_ROLCOD;
            
            SET @V_DESCRIPTION_LOG = 'ROLE UPDATE';
            SET @V_LOG_ACTION = 'UPDATE';
        END
        ELSE
        BEGIN
            -- INSERT
            INSERT INTO TB_ROLE (ROLCOD, ROLNAM, ROLDES, USECRE, DATCRE, ZONCRE, STAREC)
            VALUES (@P_ROLCOD, @P_ROLNAM, @P_ROLDES, @V_USER_FULL, GETDATE(), 'America/Lima', 'C');
            
            SET @V_DESCRIPTION_LOG = 'ROLE CREATE';
            SET @V_LOG_ACTION = 'INSERT';
        END
        
        COMMIT TRANSACTION;
        
        SET @P_MESSAGE_TYPE = 3;
        SET @P_MESSAGE_DESCRIPTION = 'Rol guardado correctamente';
        
        EXEC SP_REGISTER_LOG @V_DESCRIPTION_LOG, @V_LOG_ACTION, @P_LOGIPMAC, @V_LOG_CODE_REC,
            @V_NAME_TABLE, '', 'SUCCESS', @P_USEYEA_U, @P_USECOD_U, @P_USENAM_U, @P_USELAS_U,
            @P_MESSAGE_DESCRIPTION = @P_MESSAGE_DESCRIPTION OUTPUT, @P_MESSAGE_TYPE = @P_MESSAGE_TYPE OUTPUT,
            @P_LOGYEA = @V_CODE_LOG_YEAR OUTPUT, @P_LOGCOD = @V_CODE_LOG OUTPUT;
        EXEC SP_UPDATE_DATE_END_SQL @V_CODE_LOG_YEAR, @V_CODE_LOG, '';
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        
        DECLARE @V_ERROR NVARCHAR(MAX) = ERROR_MESSAGE();
        DECLARE @V_LOG_ACTION_FINAL VARCHAR(10) = COALESCE(@V_LOG_ACTION, 'INSERT');
        
        EXEC SP_REGISTER_LOG @V_ERROR, @V_LOG_ACTION_FINAL, @P_LOGIPMAC, @V_LOG_CODE_REC,
            @V_NAME_TABLE, '', 'ERROR', @P_USEYEA_U, @P_USECOD_U, @P_USENAM_U, @P_USELAS_U,
            @P_MESSAGE_DESCRIPTION = @P_MESSAGE_DESCRIPTION OUTPUT, @P_MESSAGE_TYPE = @P_MESSAGE_TYPE OUTPUT,
            @P_LOGYEA = @V_CODE_LOG_YEAR OUTPUT, @P_LOGCOD = @V_CODE_LOG OUTPUT;
        EXEC SP_UPDATE_DATE_END_SQL @V_CODE_LOG_YEAR, @V_CODE_LOG, '';
        
        SET @P_MESSAGE_TYPE = 1;
        SET @P_MESSAGE_DESCRIPTION = @V_ERROR;
    END CATCH
END
GO
