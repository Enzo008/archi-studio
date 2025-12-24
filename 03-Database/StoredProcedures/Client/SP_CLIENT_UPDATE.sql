-- *****************************************************************************************************
-- Description       : Update an existing client
-- Created by        : Enzo Gago Aguirre
-- Creation Date     : 09/12/2025
-- Updated           : 17/12/2025 - Standardized with common utilities
-- Purpose           : Updates client information
-- Features          : - COALESCE to preserve existing values
--                     - ALWAYS logs operations (SP_REGISTER_LOG + SP_UPDATE_DATE_END_SQL)
-- *****************************************************************************************************

CREATE OR ALTER PROCEDURE SP_CLIENT_UPDATE
    @P_CLIYEA               CHAR(04),
    @P_CLICOD               CHAR(06),
    @P_CLINAM               VARCHAR(100) = NULL,
    @P_CLITYP               CHAR(02) = NULL,
    @P_CLIEMA               VARCHAR(100) = NULL,
    @P_CLIPHO               VARCHAR(20) = NULL,
    @P_CLIADD               VARCHAR(200) = NULL,
    @P_CLISTA               CHAR(01) = NULL,
    @P_CLIDES               VARCHAR(500) = NULL,
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
    
    DECLARE @V_NAME_TABLE       NVARCHAR(100) = 'TM_CLIENT',
            @V_CODE_LOG_YEAR    CHAR(4) = '',
            @V_CODE_LOG         CHAR(10) = '',
            @V_DESCRIPTION_LOG  NVARCHAR(300) = 'CLIENT UPDATE',
            @V_LOG_CODE_REC     VARCHAR(20) = '';
    
    SET @V_LOG_CODE_REC = @P_CLIYEA + '-' + @P_CLICOD;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        IF NOT EXISTS (SELECT 1 FROM TM_CLIENT WHERE CLIYEA = @P_CLIYEA AND CLICOD = @P_CLICOD AND STAREC <> 'D')
        BEGIN
            SET @P_MESSAGE_TYPE = 2;
            SET @P_MESSAGE_DESCRIPTION = 'Cliente no encontrado';
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        IF @P_CLIEMA IS NOT NULL AND EXISTS (
            SELECT 1 FROM TM_CLIENT WHERE CLIEMA = @P_CLIEMA AND NOT (CLIYEA = @P_CLIYEA AND CLICOD = @P_CLICOD) AND STAREC <> 'D'
        )
        BEGIN
            SET @P_MESSAGE_TYPE = 2;
            SET @P_MESSAGE_DESCRIPTION = 'El email ya está registrado por otro cliente';
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        UPDATE TM_CLIENT
        SET CLINAM = COALESCE(@P_CLINAM, CLINAM), CLITYP = COALESCE(@P_CLITYP, CLITYP),
            CLIEMA = COALESCE(@P_CLIEMA, CLIEMA), CLIPHO = COALESCE(@P_CLIPHO, CLIPHO),
            CLIADD = COALESCE(@P_CLIADD, CLIADD), CLISTA = COALESCE(@P_CLISTA, CLISTA),
            CLIDES = COALESCE(@P_CLIDES, CLIDES),
            USEUPD = LTRIM(RTRIM(@P_USENAM_U)) + ' ' + LTRIM(RTRIM(@P_USELAS_U)),
            DATUPD = GETDATE(), ZONUPD = 'America/Lima', STAREC = 'U'
        WHERE CLIYEA = @P_CLIYEA AND CLICOD = @P_CLICOD;
        
        COMMIT TRANSACTION;
        
        SET @P_MESSAGE_TYPE = 3;
        SET @P_MESSAGE_DESCRIPTION = 'Cliente actualizado correctamente';
        
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
