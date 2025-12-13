-- *****************************************************************************************************
-- Description       : Delete a budget item
-- Created by        : Enzo Gago Aguirre
-- Creation Date     : 09/12/2025
-- Purpose           : Soft deletes a budget item and recalculates total
-- *****************************************************************************************************

CREATE OR ALTER PROCEDURE SP_BUDGET_ITEM_DELETE
    @P_BUDYEA CHAR(04),
    @P_BUDCOD CHAR(06),
    @P_BUDITENUM INT,
    -- Log parameters
    @P_USECRE VARCHAR(30),
    @P_ZONCRE VARCHAR(50),
    -- Output parameters
    @P_TOTAL_RECORDS INT OUTPUT,
    @P_MESSAGE_DESCRIPTION VARCHAR(500) OUTPUT,
    @P_MESSAGE_TYPE INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if item exists
        IF NOT EXISTS (SELECT 1 FROM TD_BUDGET_ITEM WHERE BUDYEA = @P_BUDYEA AND BUDCOD = @P_BUDCOD AND BUDITENUM = @P_BUDITENUM AND STAREC <> 'D')
        BEGIN
            SET @P_MESSAGE_TYPE = 2; -- Warning
            SET @P_MESSAGE_DESCRIPTION = 'Item no encontrado';
            SET @P_TOTAL_RECORDS = 0;
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Soft delete item
        UPDATE TD_BUDGET_ITEM
        SET 
            USEUPD = @P_USECRE,
            DATUPD = GETDATE(),
            ZONUPD = @P_ZONCRE,
            STAREC = 'D'
        WHERE BUDYEA = @P_BUDYEA AND BUDCOD = @P_BUDCOD AND BUDITENUM = @P_BUDITENUM;
        
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
        SET @P_MESSAGE_DESCRIPTION = 'Item eliminado correctamente';
        SET @P_TOTAL_RECORDS = 1;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @P_MESSAGE_TYPE = 1; -- Error
        SET @P_MESSAGE_DESCRIPTION = ERROR_MESSAGE();
        SET @P_TOTAL_RECORDS = 0;
    END CATCH
END
GO
