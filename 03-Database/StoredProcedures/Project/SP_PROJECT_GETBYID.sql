-- *****************************************************************************************************
-- Description       : Get project by ID
-- Created by        : Enzo Gago Aguirre
-- Creation Date     : 09/12/2025
-- Purpose           : Returns a single project by composite key with all relations
-- *****************************************************************************************************

CREATE OR ALTER PROCEDURE SP_PROJECT_GETBYID
    @P_PROYEA CHAR(04),
    @P_PROCOD CHAR(06),
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
        -- Check if project exists
        IF NOT EXISTS (SELECT 1 FROM TM_PROJECT WHERE PROYEA = @P_PROYEA AND PROCOD = @P_PROCOD AND STAREC <> 'D')
        BEGIN
            SET @P_MESSAGE_TYPE = 2; -- Warning
            SET @P_MESSAGE_DESCRIPTION = 'Proyecto no encontrado';
            SET @P_TOTAL_RECORDS = 0;
            RETURN;
        END
        
        -- Return project data
        SELECT 
            P.PROYEA,
            P.PROCOD,
            P.PRONAM,
            P.PRODES,
            P.PROSTA,
            S.PROSTANAM,
            S.PROSTAICO,
            S.PROSTACOL,
            P.PROPRO,
            P.PRODATINI,
            P.PRODATEND,
            P.PROBUDGET,
            P.PROADD,
            P.CLIYEA,
            P.CLICOD,
            C.CLINAM,
            C.CLIEMA AS CLIEMA,
            C.CLIPHO AS CLIPHO,
            P.USEYEA,
            P.USECOD,
            U.USENAM,
            U.USELAS,
            U.USEEMA AS MANAGEREMA,
            P.USECRE,
            P.DATCRE,
            P.ZONCRE,
            P.USEUPD,
            P.DATUPD,
            P.ZONUPD,
            P.STAREC
        FROM TM_PROJECT P
        LEFT JOIN TB_PROJECT_STATUS S ON P.PROSTA = S.PROSTA
        LEFT JOIN TM_CLIENT C ON P.CLIYEA = C.CLIYEA AND P.CLICOD = C.CLICOD
        LEFT JOIN TM_USER U ON P.USEYEA = U.USEYEA AND P.USECOD = U.USECOD
        WHERE P.PROYEA = @P_PROYEA 
          AND P.PROCOD = @P_PROCOD
          AND P.STAREC <> 'D';
        
        SET @P_MESSAGE_TYPE = 3; -- Success
        SET @P_MESSAGE_DESCRIPTION = 'Proyecto encontrado';
        SET @P_TOTAL_RECORDS = 1;
        
    END TRY
    BEGIN CATCH
        SET @P_MESSAGE_TYPE = 1; -- Error
        SET @P_MESSAGE_DESCRIPTION = ERROR_MESSAGE();
        SET @P_TOTAL_RECORDS = 0;
    END CATCH
END
GO
