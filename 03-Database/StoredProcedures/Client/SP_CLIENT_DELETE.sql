-- *****************************************************************************************************
-- Description       : Delete (soft delete) a client
-- Created by        : Enzo Gago Aguirre
-- Creation Date     : 09/12/2025
-- Purpose           : Marks client as eliminated (STAREC = 'D')
-- *****************************************************************************************************

CREATE OR ALTER PROCEDURE SP_CLIENT_DELETE
    @P_CLIYEA CHAR(04),
    @P_CLICOD CHAR(06),
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
            SET @P_STAREC = 'D';
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Check if client has active projects
        IF EXISTS (SELECT 1 FROM TM_PROJECT WHERE CLIYEA = @P_CLIYEA AND CLICOD = @P_CLICOD AND STAREC <> 'D')
        BEGIN
            SET @P_MESSAGE_TYPE = 2; -- Warning
            SET @P_MESSAGE_DESCRIPTION = 'No se puede eliminar el cliente porque tiene proyectos asociados';
            SET @P_STAREC = 'D';
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Soft delete client
        UPDATE TM_CLIENT
        SET 
            CLISTA = 'I',
            USEUPD = @P_USECRE,
            DATUPD = GETDATE(),
            ZONUPD = @P_ZONCRE,
            STAREC = 'D'
        WHERE CLIYEA = @P_CLIYEA AND CLICOD = @P_CLICOD;
        
        COMMIT TRANSACTION;
        
        SET @P_MESSAGE_TYPE = 3; -- Success
        SET @P_MESSAGE_DESCRIPTION = 'Cliente eliminado correctamente';
        SET @P_STAREC = 'D';
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @P_MESSAGE_TYPE = 1; -- Error
        SET @P_MESSAGE_DESCRIPTION = ERROR_MESSAGE();
        SET @P_STAREC = 'D';
    END CATCH
END
GO
