-- *****************************************************************************************************
-- Description       : Delete (soft delete) a budget
-- Created by        : Enzo Gago Aguirre
-- Creation Date     : 09/12/2025
-- Purpose           : Marks budget and its items as eliminated
-- *****************************************************************************************************

CREATE OR ALTER PROCEDURE SP_BUDGET_DELETE
    @P_BUDYEA CHAR(04),
    @P_BUDCOD CHAR(06),
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
        
        -- Check if budget exists
        IF NOT EXISTS (SELECT 1 FROM TM_BUDGET WHERE BUDYEA = @P_BUDYEA AND BUDCOD = @P_BUDCOD AND STAREC <> 'D')
        BEGIN
            SET @P_MESSAGE_TYPE = 2; -- Warning
            SET @P_MESSAGE_DESCRIPTION = 'Presupuesto no encontrado';
            SET @P_TOTAL_RECORDS = 0;
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Soft delete budget items first
        UPDATE TD_BUDGET_ITEM
        SET 
            USEUPD = @P_USECRE,
            DATUPD = GETDATE(),
            ZONUPD = @P_ZONCRE,
            STAREC = 'D'
        WHERE BUDYEA = @P_BUDYEA AND BUDCOD = @P_BUDCOD;
        
        -- Soft delete budget
        UPDATE TM_BUDGET
        SET 
            USEUPD = @P_USECRE,
            DATUPD = GETDATE(),
            ZONUPD = @P_ZONCRE,
            STAREC = 'D'
        WHERE BUDYEA = @P_BUDYEA AND BUDCOD = @P_BUDCOD;
        
        COMMIT TRANSACTION;
        
        SET @P_MESSAGE_TYPE = 3; -- Success
        SET @P_MESSAGE_DESCRIPTION = 'Presupuesto eliminado correctamente';
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
