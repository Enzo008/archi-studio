-- *****************************************************************************************************
-- Description       : Save budget items (insert/update)
-- Created by        : Enzo Gago Aguirre
-- Creation Date     : 09/12/2025
-- Updated           : 11/12/2025 - Added image file columns
-- Purpose           : Inserts or updates a budget line item and recalculates total
-- *****************************************************************************************************

CREATE OR ALTER PROCEDURE SP_BUDGET_ITEM_SAVE
    @P_BUDYEA CHAR(04),
    @P_BUDCOD CHAR(06),
    @P_BUDITENUM INT = NULL,  -- NULL for new item
    @P_BUDITENAM VARCHAR(200),
    @P_BUDITEQTY DECIMAL(10,2) = 1,
    @P_BUDITEUNI VARCHAR(20) = NULL,
    @P_BUDITEPRI DECIMAL(18,2) = 0,
    @P_BUDITESTA CHAR(02) = '01',
    @P_BUDITENOT VARCHAR(500) = NULL,
    @P_BUDITEIMGPAT VARCHAR(500) = NULL,   -- File path
    @P_BUDITEIMGFIL VARCHAR(200) = NULL,   -- Original filename
    @P_BUDITEIMGSIZ BIGINT = NULL,         -- File size
    @P_BUDITEIMGMIM VARCHAR(100) = NULL,   -- MIME type
    -- Log parameters
    @P_USECRE VARCHAR(30),
    @P_ZONCRE VARCHAR(50),
    -- Output parameters
    @P_BUDITENUM_OUT INT OUTPUT,
    @P_MESSAGE_DESCRIPTION VARCHAR(500) OUTPUT,
    @P_MESSAGE_TYPE INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if budget exists
        IF NOT EXISTS (SELECT 1 FROM TM_BUDGET WHERE BUDYEA = @P_BUDYEA AND BUDCOD = @P_BUDCOD AND STAREC <> 'D')
        BEGIN
            SET @P_MESSAGE_TYPE = 2; -- Warning
            SET @P_MESSAGE_DESCRIPTION = 'Presupuesto no encontrado';
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Calculate line total
        DECLARE @LineTotal DECIMAL(18,2) = @P_BUDITEQTY * @P_BUDITEPRI;
        
        IF @P_BUDITENUM IS NULL
        BEGIN
            -- Get next item number
            SELECT @P_BUDITENUM_OUT = ISNULL(MAX(BUDITENUM), 0) + 1
            FROM TD_BUDGET_ITEM
            WHERE BUDYEA = @P_BUDYEA AND BUDCOD = @P_BUDCOD;
            
            -- Insert new item
            INSERT INTO TD_BUDGET_ITEM (
                BUDYEA, BUDCOD, BUDITENUM, BUDITENAM, BUDITEQTY, BUDITEUNI,
                BUDITEPRI, BUDITETOT, BUDITESTA, BUDITENOT,
                BUDITEIMGPAT, BUDITEIMGFIL, BUDITEIMGSIZ, BUDITEIMGMIM,
                USECRE, DATCRE, ZONCRE, STAREC
            )
            VALUES (
                @P_BUDYEA, @P_BUDCOD, @P_BUDITENUM_OUT, @P_BUDITENAM, @P_BUDITEQTY, @P_BUDITEUNI,
                @P_BUDITEPRI, @LineTotal, @P_BUDITESTA, @P_BUDITENOT,
                @P_BUDITEIMGPAT, @P_BUDITEIMGFIL, @P_BUDITEIMGSIZ, @P_BUDITEIMGMIM,
                @P_USECRE, GETDATE(), @P_ZONCRE, 'C'
            );
        END
        ELSE
        BEGIN
            SET @P_BUDITENUM_OUT = @P_BUDITENUM;
            
            -- Update existing item (COALESCE preserves existing values when params are NULL)
            UPDATE TD_BUDGET_ITEM
            SET 
                BUDITENAM = COALESCE(@P_BUDITENAM, BUDITENAM),
                BUDITEQTY = COALESCE(@P_BUDITEQTY, BUDITEQTY),
                BUDITEUNI = COALESCE(@P_BUDITEUNI, BUDITEUNI),
                BUDITEPRI = COALESCE(@P_BUDITEPRI, BUDITEPRI),
                BUDITETOT = CASE WHEN @P_BUDITEQTY IS NOT NULL AND @P_BUDITEPRI IS NOT NULL 
                            THEN @LineTotal 
                            ELSE BUDITETOT END,
                BUDITESTA = COALESCE(@P_BUDITESTA, BUDITESTA),
                BUDITENOT = COALESCE(@P_BUDITENOT, BUDITENOT),
                BUDITEIMGPAT = COALESCE(@P_BUDITEIMGPAT, BUDITEIMGPAT),
                BUDITEIMGFIL = COALESCE(@P_BUDITEIMGFIL, BUDITEIMGFIL),
                BUDITEIMGSIZ = COALESCE(@P_BUDITEIMGSIZ, BUDITEIMGSIZ),
                BUDITEIMGMIM = COALESCE(@P_BUDITEIMGMIM, BUDITEIMGMIM),
                USEUPD = @P_USECRE,
                DATUPD = GETDATE(),
                ZONUPD = @P_ZONCRE,
                STAREC = 'U'
            WHERE BUDYEA = @P_BUDYEA AND BUDCOD = @P_BUDCOD AND BUDITENUM = @P_BUDITENUM;
        END
        
        -- Recalculate budget total
        UPDATE TM_BUDGET
        SET BUDTOT = (
            SELECT ISNULL(SUM(BUDITETOT), 0)
            FROM TD_BUDGET_ITEM
            WHERE BUDYEA = @P_BUDYEA AND BUDCOD = @P_BUDCOD AND STAREC <> 'D'
        ),
        USEUPD = @P_USECRE,
        DATUPD = GETDATE(),
        ZONUPD = @P_ZONCRE
        WHERE BUDYEA = @P_BUDYEA AND BUDCOD = @P_BUDCOD;
        
        COMMIT TRANSACTION;
        
        SET @P_MESSAGE_TYPE = 3; -- Success
        SET @P_MESSAGE_DESCRIPTION = 'Item guardado correctamente';
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @P_MESSAGE_TYPE = 1; -- Error
        SET @P_MESSAGE_DESCRIPTION = ERROR_MESSAGE();
    END CATCH
END
GO

