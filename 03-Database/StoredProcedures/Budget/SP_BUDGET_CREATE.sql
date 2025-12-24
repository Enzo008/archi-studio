-- *****************************************************************************************************
-- Description       : Create a new budget
-- Created by        : Enzo Gago Aguirre
-- Creation Date     : 09/12/2025
-- Updated           : 17/12/2025 - Standardized with common utilities
-- Purpose           : Inserts a new budget with auto-generated year/code
-- Features          : - Uses SP_GENERATE_CODE_WITH_YEAR for code generation
--                     - ALWAYS logs operations (SP_REGISTER_LOG + SP_UPDATE_DATE_END_SQL)
-- *****************************************************************************************************

CREATE OR ALTER PROCEDURE SP_BUDGET_CREATE
    @P_BUDNAM               VARCHAR(200),
    @P_BUDDES               VARCHAR(500) = NULL,
    @P_BUDSTA               CHAR(02) = '01',
    @P_BUDDAT               DATE = NULL,
    @P_BUDEXP               DATE = NULL,
    @P_BUDNOT               VARCHAR(1000) = NULL,
    @P_PROYEA               CHAR(04) = NULL,
    @P_PROCOD               CHAR(06) = NULL,
    @P_LOGIPMAC             VARCHAR(15) = NULL,
    @P_USEYEA_U             CHAR(04) = NULL,
    @P_USECOD_U             CHAR(06) = NULL,
    @P_USENAM_U             VARCHAR(30) = NULL,
    @P_USELAS_U             VARCHAR(30) = NULL,
    @P_ROLCOD_U             CHAR(02) = NULL,
    @P_BUDYEA_OUT           CHAR(04) OUTPUT,
    @P_BUDCOD_OUT           CHAR(06) OUTPUT,
    @P_MESSAGE_DESCRIPTION  NVARCHAR(500) OUTPUT,
    @P_MESSAGE_TYPE         INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @V_NAME_TABLE       NVARCHAR(100) = 'TM_BUDGET',
            @V_CODE_LOG_YEAR    CHAR(4) = '',
            @V_CODE_LOG         CHAR(10) = '',
            @V_DESCRIPTION_LOG  NVARCHAR(300) = 'BUDGET CREATE',
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
        
        SET @P_BUDYEA_OUT = CAST(YEAR(GETDATE()) AS CHAR(04));
        EXEC SP_GENERATE_CODE_WITH_YEAR '000001', 'TM_BUDGET', 'BUDCOD', 'BUDYEA', @V_CODE = @V_CODE_GENERATED OUTPUT;
        SET @P_BUDCOD_OUT = @V_CODE_GENERATED;
        SET @V_LOG_CODE_REC = @P_BUDYEA_OUT + '-' + @P_BUDCOD_OUT;
        
        INSERT INTO TM_BUDGET (
            BUDYEA, BUDCOD, BUDNAM, BUDDES, BUDSTA, BUDTOT, BUDDAT, BUDEXP, BUDNOT,
            PROYEA, PROCOD, USECRE, DATCRE, ZONCRE, STAREC
        )
        VALUES (
            @P_BUDYEA_OUT, @P_BUDCOD_OUT, @P_BUDNAM, @P_BUDDES, @P_BUDSTA, 0,
            ISNULL(@P_BUDDAT, GETDATE()), @P_BUDEXP, @P_BUDNOT,
            @P_PROYEA, @P_PROCOD, LTRIM(RTRIM(@P_USENAM_U)) + ' ' + LTRIM(RTRIM(@P_USELAS_U)), GETDATE(), 'America/Lima', 'C'
        );
        
        COMMIT TRANSACTION;
        
        SET @P_MESSAGE_TYPE = 3;
        SET @P_MESSAGE_DESCRIPTION = 'Presupuesto creado correctamente';
        
        EXEC SP_REGISTER_LOG @V_DESCRIPTION_LOG, 'INSERT', @P_LOGIPMAC, @V_LOG_CODE_REC,
            @V_NAME_TABLE, '', 'SUCCESS', @P_USEYEA_U, @P_USECOD_U, @P_USENAM_U, @P_USELAS_U,
            @P_MESSAGE_DESCRIPTION = @P_MESSAGE_DESCRIPTION OUTPUT, @P_MESSAGE_TYPE = @P_MESSAGE_TYPE OUTPUT,
            @P_LOGYEA = @V_CODE_LOG_YEAR OUTPUT, @P_LOGCOD = @V_CODE_LOG OUTPUT;
        EXEC SP_UPDATE_DATE_END_SQL @V_CODE_LOG_YEAR, @V_CODE_LOG, '';
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        
        DECLARE @V_ERROR NVARCHAR(MAX) = ERROR_MESSAGE();
        SET @V_LOG_CODE_REC = ISNULL(@P_BUDYEA_OUT, '') + '-' + ISNULL(@P_BUDCOD_OUT, '');
        
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
