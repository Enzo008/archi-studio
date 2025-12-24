-- *****************************************************************************************************
-- Description       : Create a new document record
-- Created by        : Enzo Gago Aguirre
-- Creation Date     : 09/12/2025
-- Updated           : 17/12/2025 - Standardized with common utilities
-- Purpose           : Inserts a new document with auto-generated year/code
-- Features          : - Uses SP_GENERATE_CODE_WITH_YEAR for code generation
--                     - ALWAYS logs operations (SP_REGISTER_LOG + SP_UPDATE_DATE_END_SQL)
-- *****************************************************************************************************

CREATE OR ALTER PROCEDURE SP_DOCUMENT_CREATE
    @P_DOCNAM               VARCHAR(200),
    @P_DOCDES               VARCHAR(500) = NULL,
    @P_DOCTYP               CHAR(02) = '06',
    @P_DOCPAT               VARCHAR(500),
    @P_DOCFIL               VARCHAR(200) = NULL,
    @P_DOCSIZ               BIGINT = NULL,
    @P_DOCMIM               VARCHAR(100) = NULL,
    @P_DOCSTA               CHAR(01) = 'A',
    @P_PROYEA               CHAR(04) = NULL,
    @P_PROCOD               CHAR(06) = NULL,
    @P_LOGIPMAC             VARCHAR(15) = NULL,
    @P_USEYEA_U             CHAR(04) = NULL,
    @P_USECOD_U             CHAR(06) = NULL,
    @P_USENAM_U             VARCHAR(30) = NULL,
    @P_USELAS_U             VARCHAR(30) = NULL,
    @P_ROLCOD_U             CHAR(02) = NULL,
    @P_DOCYEA_OUT           CHAR(04) OUTPUT,
    @P_DOCCOD_OUT           CHAR(06) OUTPUT,
    @P_MESSAGE_DESCRIPTION  NVARCHAR(500) OUTPUT,
    @P_MESSAGE_TYPE         INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @V_NAME_TABLE       NVARCHAR(100) = 'TM_DOCUMENT',
            @V_CODE_LOG_YEAR    CHAR(4) = '',
            @V_CODE_LOG         CHAR(10) = '',
            @V_DESCRIPTION_LOG  NVARCHAR(300) = 'DOCUMENT CREATE',
            @V_LOG_CODE_REC     VARCHAR(20) = '',
            @V_CODE_GENERATED   NVARCHAR(300) = '';
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        IF @P_PROYEA IS NOT NULL AND @P_PROCOD IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM TM_PROJECT WHERE PROYEA = @P_PROYEA AND PROCOD = @P_PROCOD AND STAREC <> 'D')
            BEGIN
                SET @P_MESSAGE_TYPE = 2;
                SET @P_MESSAGE_DESCRIPTION = 'Proyecto no encontrado';
                ROLLBACK TRANSACTION;
                RETURN;
            END
        END
        
        SET @P_DOCYEA_OUT = CAST(YEAR(GETDATE()) AS CHAR(04));
        EXEC SP_GENERATE_CODE_WITH_YEAR '000001', 'TM_DOCUMENT', 'DOCCOD', 'DOCYEA', @V_CODE = @V_CODE_GENERATED OUTPUT;
        SET @P_DOCCOD_OUT = @V_CODE_GENERATED;
        SET @V_LOG_CODE_REC = @P_DOCYEA_OUT + '-' + @P_DOCCOD_OUT;
        
        INSERT INTO TM_DOCUMENT (
            DOCYEA, DOCCOD, DOCNAM, DOCDES, DOCTYP, DOCPAT, DOCFIL, DOCSIZ, DOCMIM, DOCSTA,
            PROYEA, PROCOD, USECRE, DATCRE, ZONCRE, STAREC
        )
        VALUES (
            @P_DOCYEA_OUT, @P_DOCCOD_OUT, @P_DOCNAM, @P_DOCDES, @P_DOCTYP, @P_DOCPAT, @P_DOCFIL, @P_DOCSIZ, @P_DOCMIM, @P_DOCSTA,
            @P_PROYEA, @P_PROCOD, LTRIM(RTRIM(@P_USENAM_U)) + ' ' + LTRIM(RTRIM(@P_USELAS_U)), GETDATE(), 'America/Lima', 'C'
        );
        
        COMMIT TRANSACTION;
        
        SET @P_MESSAGE_TYPE = 3;
        SET @P_MESSAGE_DESCRIPTION = 'Documento creado correctamente';
        
        EXEC SP_REGISTER_LOG @V_DESCRIPTION_LOG, 'INSERT', @P_LOGIPMAC, @V_LOG_CODE_REC,
            @V_NAME_TABLE, '', 'SUCCESS', @P_USEYEA_U, @P_USECOD_U, @P_USENAM_U, @P_USELAS_U,
            @P_MESSAGE_DESCRIPTION = @P_MESSAGE_DESCRIPTION OUTPUT, @P_MESSAGE_TYPE = @P_MESSAGE_TYPE OUTPUT,
            @P_LOGYEA = @V_CODE_LOG_YEAR OUTPUT, @P_LOGCOD = @V_CODE_LOG OUTPUT;
        EXEC SP_UPDATE_DATE_END_SQL @V_CODE_LOG_YEAR, @V_CODE_LOG, '';
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        
        DECLARE @V_ERROR NVARCHAR(MAX) = ERROR_MESSAGE();
        SET @V_LOG_CODE_REC = ISNULL(@P_DOCYEA_OUT, '') + '-' + ISNULL(@P_DOCCOD_OUT, '');
        
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
