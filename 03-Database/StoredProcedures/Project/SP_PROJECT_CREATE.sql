-- *****************************************************************************************************
-- Description       : Create a new project
-- Created by        : Enzo Gago Aguirre
-- Creation Date     : 09/12/2025
-- Purpose           : Inserts a new project with auto-generated year/code
-- *****************************************************************************************************

CREATE OR ALTER PROCEDURE SP_PROJECT_CREATE
    @P_PRONAM VARCHAR(200),
    @P_PRODES VARCHAR(500) = NULL,
    @P_PROSTA CHAR(02) = '01',
    @P_PROPRO INT = 0,
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
    @P_PROYEA_OUT CHAR(04) OUTPUT,
    @P_PROCOD_OUT CHAR(06) OUTPUT,
    @P_MESSAGE_DESCRIPTION VARCHAR(500) OUTPUT,
    @P_MESSAGE_TYPE INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
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
        
        -- Validate manager if provided
        IF @P_USEYEA IS NOT NULL AND @P_USECOD IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM TM_USER WHERE USEYEA = @P_USEYEA AND USECOD = @P_USECOD AND STAREC <> 'D')
            BEGIN
                SET @P_MESSAGE_TYPE = 2; -- Warning
                SET @P_MESSAGE_DESCRIPTION = 'Usuario responsable no encontrado';
                ROLLBACK TRANSACTION;
                RETURN;
            END
        END
        
        -- Generate PROYEA (current year)
        SET @P_PROYEA_OUT = CAST(YEAR(GETDATE()) AS CHAR(04));
        
        -- Generate PROCOD (next sequential code for this year)
        SELECT @P_PROCOD_OUT = RIGHT('000000' + CAST(ISNULL(MAX(CAST(PROCOD AS INT)), 0) + 1 AS VARCHAR), 6)
        FROM TM_PROJECT
        WHERE PROYEA = @P_PROYEA_OUT;
        
        -- Insert the project
        INSERT INTO TM_PROJECT (
            PROYEA, PROCOD, PRONAM, PRODES, PROSTA, PROPRO, 
            PRODATINI, PRODATEND, PROBUDGET, PROADD,
            CLIYEA, CLICOD, USEYEA, USECOD,
            USECRE, DATCRE, ZONCRE, STAREC
        )
        VALUES (
            @P_PROYEA_OUT, @P_PROCOD_OUT, @P_PRONAM, @P_PRODES, @P_PROSTA, @P_PROPRO,
            @P_PRODATINI, @P_PRODATEND, @P_PROBUDGET, @P_PROADD,
            @P_CLIYEA, @P_CLICOD, @P_USEYEA, @P_USECOD,
            @P_USECRE, GETDATE(), @P_ZONCRE, 'C'
        );
        
        COMMIT TRANSACTION;
        
        SET @P_MESSAGE_TYPE = 3; -- Success
        SET @P_MESSAGE_DESCRIPTION = 'Proyecto creado correctamente';
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @P_MESSAGE_TYPE = 1; -- Error
        SET @P_MESSAGE_DESCRIPTION = ERROR_MESSAGE();
    END CATCH
END
GO
