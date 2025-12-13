-- *****************************************************************************************************
-- Description       : Get all menus
-- Created by        : Enzo Gago Aguirre
-- Creation Date     : 09/12/2025
-- Purpose           : Returns all active menus in hierarchical order
-- *****************************************************************************************************

CREATE OR ALTER PROCEDURE SP_MENU_GETALL
    -- Log parameters
    @P_USECRE VARCHAR(30) = NULL,
    @P_ZONCRE VARCHAR(50) = NULL,
    -- Output parameters
    @P_TOTAL_RECORDS INT OUTPUT,
    @P_MESSAGE_DESCRIPTION VARCHAR(500) OUTPUT,
    @P_MESSAGE_TYPE INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Get total count
        SELECT @P_TOTAL_RECORDS = COUNT(*)
        FROM TM_MENU
        WHERE STAREC <> 'D';
        
        -- Return menus ordered hierarchically
        SELECT 
            MENYEA,
            MENCOD,
            MENNAM,
            MENREF,
            MENICO,
            MENORD,
            MENYEAPAR,
            MENCODPAR,
            USECRE,
            DATCRE,
            ZONCRE,
            USEUPD,
            DATUPD,
            ZONUPD,
            STAREC
        FROM TM_MENU
        WHERE STAREC <> 'D'
        ORDER BY MENYEAPAR, MENCODPAR, MENORD, MENYEA, MENCOD;
        
        SET @P_MESSAGE_TYPE = 3; -- Success
        SET @P_MESSAGE_DESCRIPTION = 'Menús obtenidos correctamente';
        
    END TRY
    BEGIN CATCH
        SET @P_MESSAGE_TYPE = 1; -- Error
        SET @P_MESSAGE_DESCRIPTION = ERROR_MESSAGE();
        SET @P_TOTAL_RECORDS = 0;
    END CATCH
END
GO
