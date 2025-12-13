-- *****************************************************************************************************
-- Description       : Update an existing user
-- Created by        : Enzo Gago Aguirre
-- Creation Date     : 09/12/2025
-- Purpose           : Updates user information
-- *****************************************************************************************************

CREATE OR ALTER PROCEDURE SP_USER_UPDATE
    @P_USEYEA CHAR(04),
    @P_USECOD CHAR(06),
    @P_USENAM VARCHAR(50) = NULL,
    @P_USELAS VARCHAR(50) = NULL,
    @P_USEEMA VARCHAR(100) = NULL,
    @P_USEIMG VARCHAR(500) = NULL,
    @P_ROLCOD CHAR(02) = NULL,
    @P_USESTA CHAR(01) = NULL,
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
        
        -- Check if user exists
        IF NOT EXISTS (SELECT 1 FROM TM_USER WHERE USEYEA = @P_USEYEA AND USECOD = @P_USECOD AND STAREC <> 'D')
        BEGIN
            SET @P_MESSAGE_TYPE = 2; -- Warning
            SET @P_MESSAGE_DESCRIPTION = 'Usuario no encontrado';
            SET @P_TOTAL_RECORDS = 0;
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Check if new email already exists for another user
        IF @P_USEEMA IS NOT NULL AND EXISTS (
            SELECT 1 FROM TM_USER 
            WHERE USEEMA = @P_USEEMA 
              AND NOT (USEYEA = @P_USEYEA AND USECOD = @P_USECOD)
              AND STAREC <> 'D'
        )
        BEGIN
            SET @P_MESSAGE_TYPE = 2; -- Warning
            SET @P_MESSAGE_DESCRIPTION = 'El email ya está registrado por otro usuario';
            SET @P_TOTAL_RECORDS = 0;
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Update user
        UPDATE TM_USER
        SET 
            USENAM = ISNULL(@P_USENAM, USENAM),
            USELAS = ISNULL(@P_USELAS, USELAS),
            USEEMA = ISNULL(@P_USEEMA, USEEMA),
            USEIMG = ISNULL(@P_USEIMG, USEIMG),
            ROLCOD = ISNULL(@P_ROLCOD, ROLCOD),
            USESTA = ISNULL(@P_USESTA, USESTA),
            USEUPD = @P_USECRE,
            DATUPD = GETDATE(),
            ZONUPD = @P_ZONCRE,
            STAREC = 'U'
        WHERE USEYEA = @P_USEYEA AND USECOD = @P_USECOD;
        
        COMMIT TRANSACTION;
        
        SET @P_MESSAGE_TYPE = 3; -- Success
        SET @P_MESSAGE_DESCRIPTION = 'Usuario actualizado correctamente';
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
