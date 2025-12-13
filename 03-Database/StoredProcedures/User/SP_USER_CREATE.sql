-- *****************************************************************************************************
-- Description       : Create a new user
-- Created by        : Enzo Gago Aguirre
-- Creation Date     : 09/12/2025
-- Purpose           : Inserts a new user with auto-generated year/code
-- *****************************************************************************************************

CREATE OR ALTER PROCEDURE SP_USER_CREATE
    @P_USEEXTID NVARCHAR(100) = NULL,
    @P_USENAM VARCHAR(50),
    @P_USELAS VARCHAR(50) = NULL,
    @P_USEEMA VARCHAR(100),
    @P_USEIMG VARCHAR(500) = NULL,
    @P_ROLCOD CHAR(02) = '01',
    @P_USESTA CHAR(01) = 'A',
    -- Log parameters
    @P_USECRE VARCHAR(30),
    @P_ZONCRE VARCHAR(50),
    -- Output parameters
    @P_USEYEA_OUT CHAR(04) OUTPUT,
    @P_USECOD_OUT CHAR(06) OUTPUT,
    @P_TOTAL_RECORDS INT OUTPUT,
    @P_MESSAGE_DESCRIPTION VARCHAR(500) OUTPUT,
    @P_MESSAGE_TYPE INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if email already exists
        IF EXISTS (SELECT 1 FROM TM_USER WHERE USEEMA = @P_USEEMA AND STAREC <> 'D')
        BEGIN
            SET @P_MESSAGE_TYPE = 2; -- Warning
            SET @P_MESSAGE_DESCRIPTION = 'El email ya está registrado';
            SET @P_TOTAL_RECORDS = 0;
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Generate USEYEA (current year)
        SET @P_USEYEA_OUT = CAST(YEAR(GETDATE()) AS CHAR(04));
        
        -- Generate USECOD (next sequential code for this year)
        SELECT @P_USECOD_OUT = RIGHT('000000' + CAST(ISNULL(MAX(CAST(USECOD AS INT)), 0) + 1 AS VARCHAR), 6)
        FROM TM_USER
        WHERE USEYEA = @P_USEYEA_OUT;
        
        -- Insert the user
        INSERT INTO TM_USER (
            USEYEA, USECOD, USEEXTID, USENAM, USELAS, USEEMA, USEIMG,
            ROLCOD, USESTA,
            USECRE, DATCRE, ZONCRE, STAREC
        )
        VALUES (
            @P_USEYEA_OUT, @P_USECOD_OUT, @P_USEEXTID, @P_USENAM, @P_USELAS, @P_USEEMA, @P_USEIMG,
            @P_ROLCOD, @P_USESTA,
            @P_USECRE, GETDATE(), @P_ZONCRE, 'C'
        );
        
        COMMIT TRANSACTION;
        
        SET @P_MESSAGE_TYPE = 3; -- Success
        SET @P_MESSAGE_DESCRIPTION = 'Usuario creado correctamente';
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
