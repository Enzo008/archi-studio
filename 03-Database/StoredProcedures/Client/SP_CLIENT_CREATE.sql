-- *****************************************************************************************************
-- Description       : Create a new client
-- Created by        : Enzo Gago Aguirre
-- Creation Date     : 09/12/2025
-- Purpose           : Inserts a new client with auto-generated year/code
-- *****************************************************************************************************

CREATE OR ALTER PROCEDURE SP_CLIENT_CREATE
    @P_CLINAM VARCHAR(100),
    @P_CLITYP CHAR(02) = '01',
    @P_CLIEMA VARCHAR(100) = NULL,
    @P_CLIPHO VARCHAR(20) = NULL,
    @P_CLIADD VARCHAR(200) = NULL,
    @P_CLISTA CHAR(01) = 'A',
    @P_CLIDES VARCHAR(500) = NULL,
    -- Owner user (multitenancy)
    @P_USEYEA CHAR(04),
    @P_USECOD CHAR(06),
    -- Log parameters
    @P_USECRE VARCHAR(30),
    @P_ZONCRE VARCHAR(50),
    -- Output parameters
    @P_CLIYEA_OUT CHAR(04) OUTPUT,
    @P_CLICOD_OUT CHAR(06) OUTPUT,
    @P_STAREC CHAR(01) OUTPUT,
    @P_MESSAGE_DESCRIPTION VARCHAR(500) OUTPUT,
    @P_MESSAGE_TYPE INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if email already exists for this user (if provided)
        IF @P_CLIEMA IS NOT NULL AND EXISTS (
            SELECT 1 FROM TM_CLIENT 
            WHERE CLIEMA = @P_CLIEMA 
              AND USEYEA = @P_USEYEA 
              AND USECOD = @P_USECOD 
              AND STAREC <> 'D'
        )
        BEGIN
            SET @P_MESSAGE_TYPE = 2; -- Warning
            SET @P_MESSAGE_DESCRIPTION = 'El email ya está registrado para este usuario';
            SET @P_STAREC = 'C';
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Generate CLIYEA (current year)
        SET @P_CLIYEA_OUT = CAST(YEAR(GETDATE()) AS CHAR(04));
        
        -- Generate CLICOD (next sequential code for this year)
        SELECT @P_CLICOD_OUT = RIGHT('000000' + CAST(ISNULL(MAX(CAST(CLICOD AS INT)), 0) + 1 AS VARCHAR), 6)
        FROM TM_CLIENT
        WHERE CLIYEA = @P_CLIYEA_OUT;
        
        -- Insert the client with owner user
        INSERT INTO TM_CLIENT (
            CLIYEA, CLICOD, CLINAM, CLITYP, CLIEMA, CLIPHO, CLIADD, CLISTA, CLIDES,
            USEYEA, USECOD,
            USECRE, DATCRE, ZONCRE, STAREC
        )
        VALUES (
            @P_CLIYEA_OUT, @P_CLICOD_OUT, @P_CLINAM, @P_CLITYP, @P_CLIEMA, @P_CLIPHO, @P_CLIADD, @P_CLISTA, @P_CLIDES,
            @P_USEYEA, @P_USECOD,
            @P_USECRE, GETDATE(), @P_ZONCRE, 'C'
        );
        
        COMMIT TRANSACTION;
        
        SET @P_MESSAGE_TYPE = 3; -- Success
        SET @P_MESSAGE_DESCRIPTION = 'Cliente creado correctamente';
        SET @P_STAREC = 'C';
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @P_MESSAGE_TYPE = 1; -- Error
        SET @P_MESSAGE_DESCRIPTION = ERROR_MESSAGE();
        SET @P_STAREC = 'C';
    END CATCH
END
GO
