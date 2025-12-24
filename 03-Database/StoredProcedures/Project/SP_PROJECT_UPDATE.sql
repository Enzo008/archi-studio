-- *****************************************************************************************************
-- Description       : Update an existing project
-- Created by        : Enzo Gago Aguirre
-- Creation Date     : 09/12/2025
-- Updated           : 17/12/2025 - Standardized with common utilities
-- Purpose           : Updates project information
-- Features          : - COALESCE to preserve existing values
--                     - ALWAYS logs operations (SP_REGISTER_LOG + SP_UPDATE_DATE_END_SQL)
-- *****************************************************************************************************

CREATE OR ALTER PROCEDURE SP_PROJECT_UPDATE
    @P_PROYEA               CHAR(04),
    @P_PROCOD               CHAR(06),
    @P_PRONAM               VARCHAR(200) = NULL,
    @P_PRODES               VARCHAR(500) = NULL,
    @P_PROSTA               CHAR(02) = NULL,
    @P_PROPRO               INT = NULL,
    @P_PRODATINI            DATE = NULL,
    @P_PRODATEND            DATE = NULL,
    @P_PROBUDGET            DECIMAL(18,2) = NULL,
    @P_PROADD               VARCHAR(200) = NULL,
    @P_CLIYEA               CHAR(04) = NULL,
    @P_CLICOD               CHAR(06) = NULL,
    @P_USEYEA               CHAR(04) = NULL,
    @P_USECOD               CHAR(06) = NULL,
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
    
    DECLARE @V_NAME_TABLE       NVARCHAR(100) = 'TM_PROJECT',
            @V_CODE_LOG_YEAR    CHAR(4) = '',
            @V_CODE_LOG         CHAR(10) = '',
            @V_DESCRIPTION_LOG  NVARCHAR(300) = 'PROJECT UPDATE',
            @V_LOG_CODE_REC     VARCHAR(20) = '';
    
    SET @V_LOG_CODE_REC = @P_PROYEA + '-' + @P_PROCOD;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        IF NOT EXISTS (SELECT 1 FROM TM_PROJECT WHERE PROYEA = @P_PROYEA AND PROCOD = @P_PROCOD AND STAREC <> 'D')
        BEGIN
            SET @P_MESSAGE_TYPE = 2;
            SET @P_MESSAGE_DESCRIPTION = 'Proyecto no encontrado';
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        IF @P_CLIYEA IS NOT NULL AND @P_CLICOD IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM TM_CLIENT WHERE CLIYEA = @P_CLIYEA AND CLICOD = @P_CLICOD AND STAREC <> 'D')
            BEGIN
                SET @P_MESSAGE_TYPE = 2;
                SET @P_MESSAGE_DESCRIPTION = 'Cliente no encontrado';
                ROLLBACK TRANSACTION;
                RETURN;
            END
        END
        
        UPDATE TM_PROJECT
        SET PRONAM = COALESCE(@P_PRONAM, PRONAM), PRODES = COALESCE(@P_PRODES, PRODES),
            PROSTA = COALESCE(@P_PROSTA, PROSTA), PROPRO = COALESCE(@P_PROPRO, PROPRO),
            PRODATINI = COALESCE(@P_PRODATINI, PRODATINI), PRODATEND = COALESCE(@P_PRODATEND, PRODATEND),
            PROBUDGET = COALESCE(@P_PROBUDGET, PROBUDGET), PROADD = COALESCE(@P_PROADD, PROADD),
            CLIYEA = COALESCE(@P_CLIYEA, CLIYEA), CLICOD = COALESCE(@P_CLICOD, CLICOD),
            USEYEA = COALESCE(@P_USEYEA, USEYEA), USECOD = COALESCE(@P_USECOD, USECOD),
            USEUPD = LTRIM(RTRIM(@P_USENAM_U)) + ' ' + LTRIM(RTRIM(@P_USELAS_U)),
            DATUPD = GETDATE(), ZONUPD = 'America/Lima', STAREC = 'U'
        WHERE PROYEA = @P_PROYEA AND PROCOD = @P_PROCOD;
        
        COMMIT TRANSACTION;
        
        SET @P_MESSAGE_TYPE = 3;
        SET @P_MESSAGE_DESCRIPTION = 'Proyecto actualizado correctamente';
        
        EXEC SP_REGISTER_LOG @V_DESCRIPTION_LOG, 'UPDATE', @P_LOGIPMAC, @V_LOG_CODE_REC,
            @V_NAME_TABLE, '', 'SUCCESS', @P_USEYEA_U, @P_USECOD_U, @P_USENAM_U, @P_USELAS_U,
            @P_MESSAGE_DESCRIPTION = @P_MESSAGE_DESCRIPTION OUTPUT, @P_MESSAGE_TYPE = @P_MESSAGE_TYPE OUTPUT,
            @P_LOGYEA = @V_CODE_LOG_YEAR OUTPUT, @P_LOGCOD = @V_CODE_LOG OUTPUT;
        EXEC SP_UPDATE_DATE_END_SQL @V_CODE_LOG_YEAR, @V_CODE_LOG, '';
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        
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
