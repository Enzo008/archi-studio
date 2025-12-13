-- *****************************************************************************************************
-- Description       : Update an existing client
-- Created by        : Enzo Gago Aguirre
-- Creation Date     : 09/12/2025
-- Purpose           : Updates client information
-- *****************************************************************************************************

CREATE OR ALTER PROCEDURE SP_CLIENT_UPDATE
    @P_CLIYEA CHAR(04),
    @P_CLICOD CHAR(06),
    @P_CLINAM VARCHAR(100) = NULL,
    @P_CLITYP CHAR(02) = NULL,
    @P_CLIEMA VARCHAR(100) = NULL,
    @P_CLIPHO VARCHAR(20) = NULL,
    @P_CLIADD VARCHAR(200) = NULL,
    @P_CLISTA CHAR(01) = NULL,
    @P_CLIDES VARCHAR(500) = NULL,
    -- Log parameters
    @P_USECRE VARCHAR(30),
    @P_ZONCRE VARCHAR(50),
    -- Output parameters
    @P_STAREC CHAR(01) OUTPUT,
    @P_MESSAGE_DESCRIPTION VARCHAR(500) OUTPUT,
    @P_MESSAGE_TYPE INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if client exists
        IF NOT EXISTS (SELECT 1 FROM TM_CLIENT WHERE CLIYEA = @P_CLIYEA AND CLICOD = @P_CLICOD AND STAREC <> 'D')
        BEGIN
            SET @P_MESSAGE_TYPE = 2; -- Warning
            SET @P_MESSAGE_DESCRIPTION = 'Cliente no encontrado';
            SET @P_STAREC = 'U';
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Check if new email already exists for another client
        IF @P_CLIEMA IS NOT NULL AND EXISTS (
            SELECT 1 FROM TM_CLIENT 
            WHERE CLIEMA = @P_CLIEMA 
              AND NOT (CLIYEA = @P_CLIYEA AND CLICOD = @P_CLICOD)
              AND STAREC <> 'D'
        )
        BEGIN
            SET @P_MESSAGE_TYPE = 2; -- Warning
            SET @P_MESSAGE_DESCRIPTION = 'El email ya está registrado por otro cliente';
            SET @P_STAREC = 'U';
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Update client
        UPDATE TM_CLIENT
        SET 
            CLINAM = ISNULL(@P_CLINAM, CLINAM),
            CLITYP = ISNULL(@P_CLITYP, CLITYP),
            CLIEMA = ISNULL(@P_CLIEMA, CLIEMA),
            CLIPHO = ISNULL(@P_CLIPHO, CLIPHO),
            CLIADD = ISNULL(@P_CLIADD, CLIADD),
            CLISTA = ISNULL(@P_CLISTA, CLISTA),
            CLIDES = ISNULL(@P_CLIDES, CLIDES),
            USEUPD = @P_USECRE,
            DATUPD = GETDATE(),
            ZONUPD = @P_ZONCRE,
            STAREC = 'U'
        WHERE CLIYEA = @P_CLIYEA AND CLICOD = @P_CLICOD;
        
        COMMIT TRANSACTION;
        
        SET @P_MESSAGE_TYPE = 3; -- Success
        SET @P_MESSAGE_DESCRIPTION = 'Cliente actualizado correctamente';
        SET @P_STAREC = 'U';
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @P_MESSAGE_TYPE = 1; -- Error
        SET @P_MESSAGE_DESCRIPTION = ERROR_MESSAGE();
        SET @P_STAREC = 'U';
    END CATCH
END
GO
