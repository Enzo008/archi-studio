-- *****************************************************************************************************
-- Description       : Update an existing project
-- Created by        : Enzo Gago Aguirre
-- Creation Date     : 09/12/2025
-- Purpose           : Updates project information
-- *****************************************************************************************************

CREATE OR ALTER PROCEDURE SP_PROJECT_UPDATE
    @P_PROYEA CHAR(04),
    @P_PROCOD CHAR(06),
    @P_PRONAM VARCHAR(200) = NULL,
    @P_PRODES VARCHAR(500) = NULL,
    @P_PROSTA CHAR(02) = NULL,
    @P_PROPRO INT = NULL,
    @P_PRODATINI DATE = NULL,
    @P_PRODATEND DATE = NULL,
    @P_PROBUDGET DECIMAL(18,2) = NULL,
    @P_PROADD VARCHAR(200) = NULL,
    @P_CLIYEA CHAR(04) = NULL,
    @P_CLICOD CHAR(06) = NULL,
    @P_USEYEA CHAR(04) = NULL,
    @P_USECOD CHAR(06) = NULL,
    -- Log parameters
    @P_USECRE VARCHAR(30),
    @P_ZONCRE VARCHAR(50),
    -- Output parameters
    @P_MESSAGE_DESCRIPTION VARCHAR(500) OUTPUT,
    @P_MESSAGE_TYPE INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if project exists
        IF NOT EXISTS (SELECT 1 FROM TM_PROJECT WHERE PROYEA = @P_PROYEA AND PROCOD = @P_PROCOD AND STAREC <> 'D')
        BEGIN
            SET @P_MESSAGE_TYPE = 2; -- Warning
            SET @P_MESSAGE_DESCRIPTION = 'Proyecto no encontrado';
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Validate client if provided
        IF @P_CLIYEA IS NOT NULL AND @P_CLICOD IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM TM_CLIENT WHERE CLIYEA = @P_CLIYEA AND CLICOD = @P_CLICOD AND STAREC <> 'D')
            BEGIN
                SET @P_MESSAGE_TYPE = 2; -- Warning
                SET @P_MESSAGE_DESCRIPTION = 'Cliente no encontrado';
                ROLLBACK TRANSACTION;
                RETURN;
            END
        END
        
        -- Update project
        UPDATE TM_PROJECT
        SET 
            PRONAM = ISNULL(@P_PRONAM, PRONAM),
            PRODES = ISNULL(@P_PRODES, PRODES),
            PROSTA = ISNULL(@P_PROSTA, PROSTA),
            PROPRO = ISNULL(@P_PROPRO, PROPRO),
            PRODATINI = ISNULL(@P_PRODATINI, PRODATINI),
            PRODATEND = ISNULL(@P_PRODATEND, PRODATEND),
            PROBUDGET = ISNULL(@P_PROBUDGET, PROBUDGET),
            PROADD = ISNULL(@P_PROADD, PROADD),
            CLIYEA = ISNULL(@P_CLIYEA, CLIYEA),
            CLICOD = ISNULL(@P_CLICOD, CLICOD),
            USEYEA = ISNULL(@P_USEYEA, USEYEA),
            USECOD = ISNULL(@P_USECOD, USECOD),
            USEUPD = @P_USECRE,
            DATUPD = GETDATE(),
            ZONUPD = @P_ZONCRE,
            STAREC = 'U'
        WHERE PROYEA = @P_PROYEA AND PROCOD = @P_PROCOD;
        
        COMMIT TRANSACTION;
        
        SET @P_MESSAGE_TYPE = 3; -- Success
        SET @P_MESSAGE_DESCRIPTION = 'Proyecto actualizado correctamente';
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @P_MESSAGE_TYPE = 1; -- Error
        SET @P_MESSAGE_DESCRIPTION = ERROR_MESSAGE();
    END CATCH
END
GO
