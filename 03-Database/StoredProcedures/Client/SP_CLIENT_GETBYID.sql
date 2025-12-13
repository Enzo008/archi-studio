-- *****************************************************************************************************
-- Description       : Get client by ID
-- Created by        : Enzo Gago Aguirre
-- Creation Date     : 09/12/2025
-- Purpose           : Returns a single client by composite key
-- *****************************************************************************************************

CREATE OR ALTER PROCEDURE SP_CLIENT_GETBYID
    @P_CLIYEA CHAR(04),
    @P_CLICOD CHAR(06),
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
        -- Check if client exists
        IF NOT EXISTS (SELECT 1 FROM TM_CLIENT WHERE CLIYEA = @P_CLIYEA AND CLICOD = @P_CLICOD AND STAREC <> 'D')
        BEGIN
            SET @P_MESSAGE_TYPE = 2; -- Warning
            SET @P_MESSAGE_DESCRIPTION = 'Cliente no encontrado';
            SET @P_TOTAL_RECORDS = 0;
            RETURN;
        END
        
        -- Return client data
        SELECT 
            CLIYEA,
            CLICOD,
            CLINAM,
            CLITYP,
            CLIEMA,
            CLIPHO,
            CLIADD,
            CLISTA,
            CLIDES,
            USECRE,
            DATCRE,
            ZONCRE,
            USEUPD,
            DATUPD,
            ZONUPD,
            STAREC
        FROM TM_CLIENT
        WHERE CLIYEA = @P_CLIYEA 
          AND CLICOD = @P_CLICOD
          AND STAREC <> 'D';
        
        SET @P_MESSAGE_TYPE = 3; -- Success
        SET @P_MESSAGE_DESCRIPTION = 'Cliente encontrado';
        SET @P_TOTAL_RECORDS = 1;
        
    END TRY
    BEGIN CATCH
        SET @P_MESSAGE_TYPE = 1; -- Error
        SET @P_MESSAGE_DESCRIPTION = ERROR_MESSAGE();
        SET @P_TOTAL_RECORDS = 0;
    END CATCH
END
GO
