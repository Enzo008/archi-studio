-- *****************************************************************************************************
-- Description       : Update an existing budget
-- Created by        : Enzo Gago Aguirre
-- Creation Date     : 09/12/2025
-- Purpose           : Updates budget information
-- *****************************************************************************************************

CREATE OR ALTER PROCEDURE SP_BUDGET_UPDATE
    @P_BUDYEA CHAR(04),
    @P_BUDCOD CHAR(06),
    @P_BUDNAM VARCHAR(200) = NULL,
    @P_BUDDES VARCHAR(500) = NULL,
    @P_BUDSTA CHAR(02) = NULL,
    @P_BUDDAT DATE = NULL,
    @P_BUDEXP DATE = NULL,
    @P_BUDNOT VARCHAR(1000) = NULL,
    @P_PROYEA CHAR(04) = NULL,
    @P_PROCOD CHAR(06) = NULL,
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
        
        -- Update budget
        UPDATE TM_BUDGET
        SET 
            BUDNAM = ISNULL(@P_BUDNAM, BUDNAM),
            BUDDES = ISNULL(@P_BUDDES, BUDDES),
            BUDSTA = ISNULL(@P_BUDSTA, BUDSTA),
            BUDDAT = ISNULL(@P_BUDDAT, BUDDAT),
            BUDEXP = ISNULL(@P_BUDEXP, BUDEXP),
            BUDNOT = ISNULL(@P_BUDNOT, BUDNOT),
            PROYEA = ISNULL(@P_PROYEA, PROYEA),
            PROCOD = ISNULL(@P_PROCOD, PROCOD),
            USEUPD = @P_USECRE,
            DATUPD = GETDATE(),
            ZONUPD = @P_ZONCRE,
            STAREC = 'U'
        WHERE BUDYEA = @P_BUDYEA AND BUDCOD = @P_BUDCOD;
        
        COMMIT TRANSACTION;
        
        SET @P_MESSAGE_TYPE = 3; -- Success
        SET @P_MESSAGE_DESCRIPTION = 'Presupuesto actualizado correctamente';
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
