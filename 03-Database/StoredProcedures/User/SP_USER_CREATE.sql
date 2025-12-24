-- *****************************************************************************************************
-- Description       : Create a new user
-- Created by        : Enzo Gago Aguirre
-- Creation Date     : 09/12/2025
-- Updated           : 17/12/2025 - Standardized with common utilities
-- Purpose           : Inserts a new user with auto-generated year/code
-- Features          : - Uses SP_GENERATE_CODE_WITH_YEAR for code generation
--                     - ALWAYS logs operations (SP_REGISTER_LOG + SP_UPDATE_DATE_END_SQL)
-- *****************************************************************************************************

CREATE OR ALTER PROCEDURE SP_USER_CREATE
    @P_USEEXTID             NVARCHAR(100) = NULL,
    @P_USENAM               VARCHAR(50),
    @P_USELAS               VARCHAR(50) = NULL,
    @P_USEEMA               VARCHAR(100),
    @P_USEIMG               VARCHAR(500) = NULL,
    @P_ROLCOD               CHAR(02) = '01',
    @P_USESTA               CHAR(01) = 'A',
    @P_LOGIPMAC             VARCHAR(15) = NULL,
    @P_USEYEA_U             CHAR(04) = NULL,
    @P_USECOD_U             CHAR(06) = NULL,
    @P_USENAM_U             VARCHAR(30) = NULL,
    @P_USELAS_U             VARCHAR(30) = NULL,
    @P_ROLCOD_U             CHAR(02) = NULL,
    @P_USEYEA_OUT           CHAR(04) OUTPUT,
    @P_USECOD_OUT           CHAR(06) OUTPUT,
    @P_MESSAGE_DESCRIPTION  NVARCHAR(500) OUTPUT,
    @P_MESSAGE_TYPE         INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @V_NAME_TABLE       NVARCHAR(100) = 'TM_USER',
            @V_CODE_LOG_YEAR    CHAR(4) = '',
            @V_CODE_LOG         CHAR(10) = '',
            @V_DESCRIPTION_LOG  NVARCHAR(300) = 'USER CREATE',
            @V_LOG_CODE_REC     VARCHAR(20) = '',
            @V_CODE_GENERATED   NVARCHAR(300) = '';
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        IF EXISTS (SELECT 1 FROM TM_USER WHERE USEEMA = @P_USEEMA AND STAREC <> 'D')
        BEGIN
            SET @P_MESSAGE_TYPE = 2;
            SET @P_MESSAGE_DESCRIPTION = 'El email ya está registrado';
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        SET @P_USEYEA_OUT = CAST(YEAR(GETDATE()) AS CHAR(04));
        EXEC SP_GENERATE_CODE_WITH_YEAR '000001', 'TM_USER', 'USECOD', 'USEYEA', @V_CODE = @V_CODE_GENERATED OUTPUT;
        SET @P_USECOD_OUT = @V_CODE_GENERATED;
        SET @V_LOG_CODE_REC = @P_USEYEA_OUT + '-' + @P_USECOD_OUT;
        
        INSERT INTO TM_USER (
            USEYEA, USECOD, USEEXTID, USENAM, USELAS, USEEMA, USEIMG, ROLCOD, USESTA,
            USECRE, DATCRE, ZONCRE, STAREC
        )
        VALUES (
            @P_USEYEA_OUT, @P_USECOD_OUT, @P_USEEXTID, @P_USENAM, @P_USELAS, @P_USEEMA, @P_USEIMG, @P_ROLCOD, @P_USESTA,
            LTRIM(RTRIM(@P_USENAM_U)) + ' ' + LTRIM(RTRIM(@P_USELAS_U)), GETDATE(), 'America/Lima', 'C'
        );
        
        COMMIT TRANSACTION;
        
        SET @P_MESSAGE_TYPE = 3;
        SET @P_MESSAGE_DESCRIPTION = 'Usuario creado correctamente';
        
        EXEC SP_REGISTER_LOG @V_DESCRIPTION_LOG, 'INSERT', @P_LOGIPMAC, @V_LOG_CODE_REC,
            @V_NAME_TABLE, '', 'SUCCESS', @P_USEYEA_U, @P_USECOD_U, @P_USENAM_U, @P_USELAS_U,
            @P_MESSAGE_DESCRIPTION = @P_MESSAGE_DESCRIPTION OUTPUT, @P_MESSAGE_TYPE = @P_MESSAGE_TYPE OUTPUT,
            @P_LOGYEA = @V_CODE_LOG_YEAR OUTPUT, @P_LOGCOD = @V_CODE_LOG OUTPUT;
        EXEC SP_UPDATE_DATE_END_SQL @V_CODE_LOG_YEAR, @V_CODE_LOG, '';
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        
        DECLARE @V_ERROR NVARCHAR(MAX) = ERROR_MESSAGE();
        SET @V_LOG_CODE_REC = ISNULL(@P_USEYEA_OUT, '') + '-' + ISNULL(@P_USECOD_OUT, '');
        
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
