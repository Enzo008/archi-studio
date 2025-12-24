-- *****************************************************************************************************
-- Description       : Create a new client
-- Created by        : Enzo Gago Aguirre
-- Creation Date     : 09/12/2025
-- Updated           : 17/12/2025 - Standardized with common utilities
-- Purpose           : Inserts a new client with auto-generated year/code
-- Features          : - Uses SP_GENERATE_CODE_WITH_YEAR for code generation
--                     - ALWAYS logs operations (SP_REGISTER_LOG + SP_UPDATE_DATE_END_SQL)
-- *****************************************************************************************************

CREATE OR ALTER PROCEDURE SP_CLIENT_CREATE
    @P_CLINAM               VARCHAR(100),
    @P_CLITYP               CHAR(02) = '01',
    @P_CLIEMA               VARCHAR(100) = NULL,
    @P_CLIPHO               VARCHAR(20) = NULL,
    @P_CLIADD               VARCHAR(200) = NULL,
    @P_CLISTA               CHAR(01) = 'A',
    @P_CLIDES               VARCHAR(500) = NULL,
    @P_USEYEA               CHAR(04),
    @P_USECOD               CHAR(06),
    @P_LOGIPMAC             VARCHAR(15) = NULL,
    @P_USEYEA_U             CHAR(04) = NULL,
    @P_USECOD_U             CHAR(06) = NULL,
    @P_USENAM_U             VARCHAR(30) = NULL,
    @P_USELAS_U             VARCHAR(30) = NULL,
    @P_ROLCOD_U             CHAR(02) = NULL,
    @P_CLIYEA_OUT           CHAR(04) OUTPUT,
    @P_CLICOD_OUT           CHAR(06) OUTPUT,
    @P_MESSAGE_DESCRIPTION  NVARCHAR(500) OUTPUT,
    @P_MESSAGE_TYPE         INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @V_NAME_TABLE       NVARCHAR(100) = 'TM_CLIENT',
            @V_CODE_LOG_YEAR    CHAR(4) = '',
            @V_CODE_LOG         CHAR(10) = '',
            @V_DESCRIPTION_LOG  NVARCHAR(300) = 'CLIENT CREATE',
            @V_LOG_CODE_REC     VARCHAR(20) = '',
            @V_CODE_GENERATED   NVARCHAR(300) = '';
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        IF @P_CLIEMA IS NOT NULL AND EXISTS (
            SELECT 1 FROM TM_CLIENT 
            WHERE CLIEMA = @P_CLIEMA AND USEYEA = @P_USEYEA AND USECOD = @P_USECOD AND STAREC <> 'D'
        )
        BEGIN
            SET @P_MESSAGE_TYPE = 2;
            SET @P_MESSAGE_DESCRIPTION = 'El email ya está registrado para este usuario';
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        SET @P_CLIYEA_OUT = CAST(YEAR(GETDATE()) AS CHAR(04));
        EXEC SP_GENERATE_CODE_WITH_YEAR '000001', 'TM_CLIENT', 'CLICOD', 'CLIYEA', @V_CODE = @V_CODE_GENERATED OUTPUT;
        SET @P_CLICOD_OUT = @V_CODE_GENERATED;
        SET @V_LOG_CODE_REC = @P_CLIYEA_OUT + '-' + @P_CLICOD_OUT;
        
        INSERT INTO TM_CLIENT (
            CLIYEA, CLICOD, CLINAM, CLITYP, CLIEMA, CLIPHO, CLIADD, CLISTA, CLIDES,
            USEYEA, USECOD, USECRE, DATCRE, ZONCRE, STAREC
        )
        VALUES (
            @P_CLIYEA_OUT, @P_CLICOD_OUT, @P_CLINAM, @P_CLITYP, @P_CLIEMA, @P_CLIPHO, @P_CLIADD, @P_CLISTA, @P_CLIDES,
            @P_USEYEA, @P_USECOD, LTRIM(RTRIM(@P_USENAM_U)) + ' ' + LTRIM(RTRIM(@P_USELAS_U)), GETDATE(), 'America/Lima', 'C'
        );
        
        COMMIT TRANSACTION;
        
        SET @P_MESSAGE_TYPE = 3;
        SET @P_MESSAGE_DESCRIPTION = 'Cliente creado correctamente';
        
        EXEC SP_REGISTER_LOG @V_DESCRIPTION_LOG, 'INSERT', @P_LOGIPMAC, @V_LOG_CODE_REC,
            @V_NAME_TABLE, '', 'SUCCESS', @P_USEYEA_U, @P_USECOD_U, @P_USENAM_U, @P_USELAS_U,
            @P_MESSAGE_DESCRIPTION = @P_MESSAGE_DESCRIPTION OUTPUT, @P_MESSAGE_TYPE = @P_MESSAGE_TYPE OUTPUT,
            @P_LOGYEA = @V_CODE_LOG_YEAR OUTPUT, @P_LOGCOD = @V_CODE_LOG OUTPUT;
        EXEC SP_UPDATE_DATE_END_SQL @V_CODE_LOG_YEAR, @V_CODE_LOG, '';
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        
        DECLARE @V_ERROR NVARCHAR(MAX) = ERROR_MESSAGE();
        SET @V_LOG_CODE_REC = ISNULL(@P_CLIYEA_OUT, '') + '-' + ISNULL(@P_CLICOD_OUT, '');
        
        EXEC SP_REGISTER_LOG @V_ERROR, 'INSERT', @P_LOGIPMAC, @V_LOG_CODE_REC,
            @V_NAME_TABLE, '', 'ERROR', @P_USEYEA_U, @P_USECOD_U, @P_USENAM_U, @P_USELAS_U,
            @P_MESSAGE_DESCRIPTION = @P_MESSAGE_DESCRIPTION OUTPUT, @P_MESSAGE_TYPE = @P_MESSAGE_TYPE OUTPUT,
            @P_LOGYEA = @V_CODE_LOG_YEAR OUTPUT, @P_LOGCOD = @V_CODE_LOG OUTPUT;
        EXEC SP_UPDATE_DATE_END_SQL @V_CODE_LOG_YEAR, @V_CODE_LOG, '';
            
        SET @P_MESSAGE_TYPE = 1;
        SET @P_MESSAGE_DESCRIPTION = @V_ERROR;
    END CATCH
END
GO
