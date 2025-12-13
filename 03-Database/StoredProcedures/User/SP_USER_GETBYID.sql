-- *****************************************************************************************************
-- Description       : Get user by ID (Year + Code)
-- Created by        : Enzo Gago Aguirre
-- Creation Date     : 09/12/2025
-- Purpose           : Returns a single user by composite key
-- *****************************************************************************************************

CREATE OR ALTER PROCEDURE SP_USER_GETBYID
    @P_USEYEA CHAR(04),
    @P_USECOD CHAR(06),
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
        -- Check if user exists
        IF NOT EXISTS (SELECT 1 FROM TM_USER WHERE USEYEA = @P_USEYEA AND USECOD = @P_USECOD AND STAREC <> 'D')
        BEGIN
            SET @P_MESSAGE_TYPE = 2; -- Warning
            SET @P_MESSAGE_DESCRIPTION = 'Usuario no encontrado';
            SET @P_TOTAL_RECORDS = 0;
            RETURN;
        END
        
        -- Return user data
        SELECT 
            U.USEYEA,
            U.USECOD,
            U.USEEXTID,
            U.USENAM,
            U.USELAS,
            U.USEEMA,
            U.USEIMG,
            U.USESTA,
            U.ROLCOD,
            R.ROLNAM,
            U.USECRE,
            U.DATCRE,
            U.ZONCRE,
            U.USEUPD,
            U.DATUPD,
            U.ZONUPD,
            U.STAREC
        FROM TM_USER U
        LEFT JOIN TB_ROLE R ON U.ROLCOD = R.ROLCOD
        WHERE U.USEYEA = @P_USEYEA 
          AND U.USECOD = @P_USECOD
          AND U.STAREC <> 'D';
        
        SET @P_MESSAGE_TYPE = 3; -- Success
        SET @P_MESSAGE_DESCRIPTION = 'Usuario encontrado';
        SET @P_TOTAL_RECORDS = 1;
        
    END TRY
    BEGIN CATCH
        SET @P_MESSAGE_TYPE = 1; -- Error
        SET @P_MESSAGE_DESCRIPTION = ERROR_MESSAGE();
        SET @P_TOTAL_RECORDS = 0;
    END CATCH
END
GO
