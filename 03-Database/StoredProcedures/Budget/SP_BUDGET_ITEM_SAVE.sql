-- *****************************************************************************************************
-- Description       : Save budget items (insert/update)
-- Created by        : Enzo Gago Aguirre
-- Creation Date     : 09/12/2025
-- Updated           : 17/12/2025 - Standardized with common utilities
-- Purpose           : Inserts or updates a budget line item and recalculates total
-- Features          : - UPSERT pattern (NULL @P_BUDITENUM = INSERT, otherwise UPDATE)
--                     - Auto-recalculates budget total
--                     - ALWAYS logs operations (SP_REGISTER_LOG + SP_UPDATE_DATE_END_SQL)
-- *****************************************************************************************************

CREATE OR ALTER PROCEDURE SP_BUDGET_ITEM_SAVE
    @P_BUDYEA               CHAR(04),
    @P_BUDCOD               CHAR(06),
    @P_BUDITENUM            INT = NULL,
    @P_BUDITENAM            VARCHAR(200),
    @P_BUDITEQTY            DECIMAL(10,2) = 1,
    @P_BUDITEUNI            VARCHAR(20) = NULL,
    @P_BUDITEPRI            DECIMAL(18,2) = 0,
    @P_BUDITESTA            CHAR(02) = '01',
    @P_BUDITENOT            VARCHAR(500) = NULL,
    @P_BUDITEIMGPAT         VARCHAR(500) = NULL,
    @P_BUDITEIMGFIL         VARCHAR(200) = NULL,
    @P_BUDITEIMGSIZ         BIGINT = NULL,
    @P_BUDITEIMGMIM         VARCHAR(100) = NULL,
    @P_LOGIPMAC             VARCHAR(15) = NULL,
    @P_USEYEA_U             CHAR(04) = NULL,
    @P_USECOD_U             CHAR(06) = NULL,
    @P_USENAM_U             VARCHAR(30) = NULL,
    @P_USELAS_U             VARCHAR(30) = NULL,
    @P_ROLCOD_U             CHAR(02) = NULL,
    @P_BUDITENUM_OUT        INT OUTPUT,
    @P_MESSAGE_DESCRIPTION  NVARCHAR(500) OUTPUT,
    @P_MESSAGE_TYPE         INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @V_NAME_TABLE       NVARCHAR(100) = 'TD_BUDGET_ITEM',
            @V_CODE_LOG_YEAR    CHAR(4) = '',
            @V_CODE_LOG         CHAR(10) = '',
            @V_DESCRIPTION_LOG  NVARCHAR(300) = '',
            @V_LOG_CODE_REC     VARCHAR(30) = '',
            @V_USER_FULL        VARCHAR(65) = '',
            @V_LOG_ACTION       VARCHAR(10) = '',
            @V_LineTotal        DECIMAL(18,2) = @P_BUDITEQTY * @P_BUDITEPRI;
    
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
        
        IF @P_BUDITENUM IS NULL
        BEGIN
            -- INSERT new item
            SELECT @P_BUDITENUM_OUT = ISNULL(MAX(BUDITENUM), 0) + 1 FROM TD_BUDGET_ITEM WHERE BUDYEA = @P_BUDYEA AND BUDCOD = @P_BUDCOD;
            SET @V_DESCRIPTION_LOG = 'BUDGET ITEM CREATE';
            SET @V_LOG_ACTION = 'INSERT';
            
            INSERT INTO TD_BUDGET_ITEM (
                BUDYEA, BUDCOD, BUDITENUM, BUDITENAM, BUDITEQTY, BUDITEUNI, BUDITEPRI, BUDITETOT, BUDITESTA, BUDITENOT,
                BUDITEIMGPAT, BUDITEIMGFIL, BUDITEIMGSIZ, BUDITEIMGMIM, USECRE, DATCRE, ZONCRE, STAREC
            ) VALUES (
                @P_BUDYEA, @P_BUDCOD, @P_BUDITENUM_OUT, @P_BUDITENAM, @P_BUDITEQTY, @P_BUDITEUNI, @P_BUDITEPRI, @V_LineTotal, @P_BUDITESTA, @P_BUDITENOT,
                @P_BUDITEIMGPAT, @P_BUDITEIMGFIL, @P_BUDITEIMGSIZ, @P_BUDITEIMGMIM, @V_USER_FULL, GETDATE(), 'America/Lima', 'C'
            );
        END
        ELSE
        BEGIN
            -- UPDATE existing item
            SET @P_BUDITENUM_OUT = @P_BUDITENUM;
            SET @V_DESCRIPTION_LOG = 'BUDGET ITEM UPDATE';
            SET @V_LOG_ACTION = 'UPDATE';
            
            UPDATE TD_BUDGET_ITEM
            SET BUDITENAM = COALESCE(@P_BUDITENAM, BUDITENAM), BUDITEQTY = COALESCE(@P_BUDITEQTY, BUDITEQTY),
                BUDITEUNI = COALESCE(@P_BUDITEUNI, BUDITEUNI), BUDITEPRI = COALESCE(@P_BUDITEPRI, BUDITEPRI),
                BUDITETOT = CASE WHEN @P_BUDITEQTY IS NOT NULL AND @P_BUDITEPRI IS NOT NULL THEN @V_LineTotal ELSE BUDITETOT END,
                BUDITESTA = COALESCE(@P_BUDITESTA, BUDITESTA), BUDITENOT = COALESCE(@P_BUDITENOT, BUDITENOT),
                BUDITEIMGPAT = COALESCE(@P_BUDITEIMGPAT, BUDITEIMGPAT), BUDITEIMGFIL = COALESCE(@P_BUDITEIMGFIL, BUDITEIMGFIL),
                BUDITEIMGSIZ = COALESCE(@P_BUDITEIMGSIZ, BUDITEIMGSIZ), BUDITEIMGMIM = COALESCE(@P_BUDITEIMGMIM, BUDITEIMGMIM),
                USEUPD = @V_USER_FULL, DATUPD = GETDATE(), ZONUPD = 'America/Lima', STAREC = 'U'
            WHERE BUDYEA = @P_BUDYEA AND BUDCOD = @P_BUDCOD AND BUDITENUM = @P_BUDITENUM;
        END
        
        SET @V_LOG_CODE_REC = @P_BUDYEA + '-' + @P_BUDCOD + '-' + CAST(@P_BUDITENUM_OUT AS VARCHAR(10));
        
        -- Recalculate budget total
        UPDATE TM_BUDGET
        SET BUDTOT = (SELECT ISNULL(SUM(BUDITETOT), 0) FROM TD_BUDGET_ITEM WHERE BUDYEA = @P_BUDYEA AND BUDCOD = @P_BUDCOD AND STAREC <> 'D'),
            USEUPD = @V_USER_FULL, DATUPD = GETDATE(), ZONUPD = 'America/Lima'
        WHERE BUDYEA = @P_BUDYEA AND BUDCOD = @P_BUDCOD;
        
        COMMIT TRANSACTION;
        
        SET @P_MESSAGE_TYPE = 3;
        SET @P_MESSAGE_DESCRIPTION = 'Item guardado correctamente';
        
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
        SET @V_LOG_CODE_REC = @P_BUDYEA + '-' + @P_BUDCOD + '-' + ISNULL(CAST(@P_BUDITENUM_OUT AS VARCHAR(10)), '0');
        
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
