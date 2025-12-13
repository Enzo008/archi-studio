-- *****************************************************************************************************
-- Description       : Get all roles
-- Created by        : Enzo Gago Aguirre
-- Creation Date     : 09/12/2025
-- Purpose           : Returns all active roles
-- *****************************************************************************************************

CREATE OR ALTER PROCEDURE SP_ROLE_GETALL
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
        FROM TB_ROLE
        WHERE STAREC <> 'D';
        
        -- Return roles
        SELECT 
            ROLCOD,
            ROLNAM,
            USECRE,
            DATCRE,
            ZONCRE,
            USEUPD,
            DATUPD,
            ZONUPD,
            STAREC
        FROM TB_ROLE
        WHERE STAREC <> 'D'
        ORDER BY ROLCOD;
        
        SET @P_MESSAGE_TYPE = 3; -- Success
        SET @P_MESSAGE_DESCRIPTION = 'Roles obtenidos correctamente';
        
    END TRY
    BEGIN CATCH
        SET @P_MESSAGE_TYPE = 1; -- Error
        SET @P_MESSAGE_DESCRIPTION = ERROR_MESSAGE();
        SET @P_TOTAL_RECORDS = 0;
    END CATCH
END
GO
