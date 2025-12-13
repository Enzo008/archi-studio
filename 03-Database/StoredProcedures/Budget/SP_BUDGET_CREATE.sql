-- *****************************************************************************************************
-- Description       : Create a new budget
-- Created by        : Enzo Gago Aguirre
-- Creation Date     : 09/12/2025
-- Purpose           : Inserts a new budget with auto-generated year/code
-- *****************************************************************************************************

CREATE OR ALTER PROCEDURE SP_BUDGET_CREATE
    @P_BUDNAM VARCHAR(200),
    @P_BUDDES VARCHAR(500) = NULL,
    @P_BUDSTA CHAR(02) = '01',
    @P_BUDDAT DATE = NULL,
    @P_BUDEXP DATE = NULL,
    @P_BUDNOT VARCHAR(1000) = NULL,
    @P_PROYEA CHAR(04) = NULL,
    @P_PROCOD CHAR(06) = NULL,
    -- Log parameters
    @P_USECRE VARCHAR(30),
    @P_ZONCRE VARCHAR(50),
    -- Output parameters
    @P_BUDYEA_OUT CHAR(04) OUTPUT,
    @P_BUDCOD_OUT CHAR(06) OUTPUT,
    @P_MESSAGE_DESCRIPTION VARCHAR(500) OUTPUT,
    @P_MESSAGE_TYPE INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate project if provided
        IF @P_PROYEA IS NOT NULL AND @P_PROCOD IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM TM_PROJECT WHERE PROYEA = @P_PROYEA AND PROCOD = @P_PROCOD AND STAREC <> 'D')
            BEGIN
                SET @P_MESSAGE_TYPE = 2; -- Warning
                SET @P_MESSAGE_DESCRIPTION = 'Proyecto no encontrado';
                ROLLBACK TRANSACTION;
                RETURN;
            END
        END
        
        -- Generate BUDYEA (current year)
        SET @P_BUDYEA_OUT = CAST(YEAR(GETDATE()) AS CHAR(04));
        
        -- Generate BUDCOD (next sequential code for this year)
        SELECT @P_BUDCOD_OUT = RIGHT('000000' + CAST(ISNULL(MAX(CAST(BUDCOD AS INT)), 0) + 1 AS VARCHAR), 6)
        FROM TM_BUDGET
        WHERE BUDYEA = @P_BUDYEA_OUT;
        
        -- Insert the budget
        INSERT INTO TM_BUDGET (
            BUDYEA, BUDCOD, BUDNAM, BUDDES, BUDSTA, BUDTOT,
            BUDDAT, BUDEXP, BUDNOT,
            PROYEA, PROCOD,
            USECRE, DATCRE, ZONCRE, STAREC
        )
        VALUES (
            @P_BUDYEA_OUT, @P_BUDCOD_OUT, @P_BUDNAM, @P_BUDDES, @P_BUDSTA, 0,
            ISNULL(@P_BUDDAT, GETDATE()), @P_BUDEXP, @P_BUDNOT,
            @P_PROYEA, @P_PROCOD,
            @P_USECRE, GETDATE(), @P_ZONCRE, 'C'
        );
        
        COMMIT TRANSACTION;
        
        SET @P_MESSAGE_TYPE = 3; -- Success
        SET @P_MESSAGE_DESCRIPTION = 'Presupuesto creado correctamente';
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @P_MESSAGE_TYPE = 1; -- Error
        SET @P_MESSAGE_DESCRIPTION = ERROR_MESSAGE();
    END CATCH
END
GO
