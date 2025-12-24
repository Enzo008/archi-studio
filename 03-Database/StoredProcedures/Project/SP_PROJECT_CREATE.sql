-- *****************************************************************************************************
-- Description       : Create a new project
-- Created by        : Enzo Gago Aguirre
-- Creation Date     : 09/12/2025
-- Updated           : 17/12/2025 - Standardized with common utilities
-- Purpose           : Inserts a new project with auto-generated year/code
-- Features          : - Uses SP_GENERATE_CODE_WITH_YEAR for code generation
--                     - Validates FK references (Client, User)
--                     - ALWAYS logs operations (SP_REGISTER_LOG + SP_UPDATE_DATE_END_SQL)
-- *****************************************************************************************************

CREATE OR ALTER PROCEDURE SP_PROJECT_CREATE
    @P_PRONAM               VARCHAR(200),
    @P_PRODES               VARCHAR(500) = NULL,
    @P_PROSTA               CHAR(02) = '01',
    @P_PROPRO               INT = 0,
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
    @P_PROYEA_OUT           CHAR(04) OUTPUT,
    @P_PROCOD_OUT           CHAR(06) OUTPUT,
    @P_MESSAGE_DESCRIPTION  NVARCHAR(500) OUTPUT,
    @P_MESSAGE_TYPE         INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @V_NAME_TABLE       NVARCHAR(100) = 'TM_PROJECT',
            @V_CODE_LOG_YEAR    CHAR(4) = '',
            @V_CODE_LOG         CHAR(10) = '',
            @V_DESCRIPTION_LOG  NVARCHAR(300) = 'PROJECT CREATE',
            @V_LOG_CODE_REC     VARCHAR(20) = '',
            @V_CODE_GENERATED   NVARCHAR(300) = '';
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
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
        
        IF @P_USEYEA IS NOT NULL AND @P_USECOD IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM TM_USER WHERE USEYEA = @P_USEYEA AND USECOD = @P_USECOD AND STAREC <> 'D')
            BEGIN
                SET @P_MESSAGE_TYPE = 2;
                SET @P_MESSAGE_DESCRIPTION = 'Usuario responsable no encontrado';
                ROLLBACK TRANSACTION;
                RETURN;
            END
        END
        
        SET @P_PROYEA_OUT = CAST(YEAR(GETDATE()) AS CHAR(04));
        EXEC SP_GENERATE_CODE_WITH_YEAR '000001', 'TM_PROJECT', 'PROCOD', 'PROYEA', @V_CODE = @V_CODE_GENERATED OUTPUT;
        SET @P_PROCOD_OUT = @V_CODE_GENERATED;
        SET @V_LOG_CODE_REC = @P_PROYEA_OUT + '-' + @P_PROCOD_OUT;
        
        INSERT INTO TM_PROJECT (
            PROYEA, PROCOD, PRONAM, PRODES, PROSTA, PROPRO, PRODATINI, PRODATEND, PROBUDGET, PROADD,
            CLIYEA, CLICOD, USEYEA, USECOD, USECRE, DATCRE, ZONCRE, STAREC
        )
        VALUES (
            @P_PROYEA_OUT, @P_PROCOD_OUT, @P_PRONAM, @P_PRODES, @P_PROSTA, @P_PROPRO, @P_PRODATINI, @P_PRODATEND, @P_PROBUDGET, @P_PROADD,
            @P_CLIYEA, @P_CLICOD, @P_USEYEA, @P_USECOD, LTRIM(RTRIM(@P_USENAM_U)) + ' ' + LTRIM(RTRIM(@P_USELAS_U)), GETDATE(), 'America/Lima', 'C'
        );
        
        COMMIT TRANSACTION;
        
        SET @P_MESSAGE_TYPE = 3;
        SET @P_MESSAGE_DESCRIPTION = 'Proyecto creado correctamente';
        
        EXEC SP_REGISTER_LOG @V_DESCRIPTION_LOG, 'INSERT', @P_LOGIPMAC, @V_LOG_CODE_REC,
            @V_NAME_TABLE, '', 'SUCCESS', @P_USEYEA_U, @P_USECOD_U, @P_USENAM_U, @P_USELAS_U,
            @P_MESSAGE_DESCRIPTION = @P_MESSAGE_DESCRIPTION OUTPUT, @P_MESSAGE_TYPE = @P_MESSAGE_TYPE OUTPUT,
            @P_LOGYEA = @V_CODE_LOG_YEAR OUTPUT, @P_LOGCOD = @V_CODE_LOG OUTPUT;
        EXEC SP_UPDATE_DATE_END_SQL @V_CODE_LOG_YEAR, @V_CODE_LOG, '';
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        
        DECLARE @V_ERROR NVARCHAR(MAX) = ERROR_MESSAGE();
        SET @V_LOG_CODE_REC = ISNULL(@P_PROYEA_OUT, '') + '-' + ISNULL(@P_PROCOD_OUT, '');
        
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
