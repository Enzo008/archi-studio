-- *****************************************************************************************************
-- Description       : Get budget by ID with items
-- Created by        : Enzo Gago Aguirre
-- Creation Date     : 09/12/2025
-- Purpose           : Returns a single budget with its line items
-- *****************************************************************************************************

CREATE OR ALTER PROCEDURE SP_BUDGET_GETBYID
    @P_BUDYEA CHAR(04),
    @P_BUDCOD CHAR(06),
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
        -- Check if budget exists
        IF NOT EXISTS (SELECT 1 FROM TM_BUDGET WHERE BUDYEA = @P_BUDYEA AND BUDCOD = @P_BUDCOD AND STAREC <> 'D')
        BEGIN
            SET @P_MESSAGE_TYPE = 2; -- Warning
            SET @P_MESSAGE_DESCRIPTION = 'Presupuesto no encontrado';
            SET @P_TOTAL_RECORDS = 0;
            RETURN;
        END
        
        -- Return budget data (first result set)
        SELECT 
            B.BUDYEA,
            B.BUDCOD,
            B.BUDNAM,
            B.BUDDES,
            B.BUDSTA,
            S.BUDSTANAM,
            S.BUDSTAICO,
            S.BUDSTACOL,
            B.BUDTOT,
            B.BUDDAT,
            B.BUDEXP,
            B.BUDNOT,
            B.PROYEA,
            B.PROCOD,
            P.PRONAM,
            C.CLINAM,
            B.USECRE,
            B.DATCRE,
            B.ZONCRE,
            B.USEUPD,
            B.DATUPD,
            B.ZONUPD,
            B.STAREC
        FROM TM_BUDGET B
        LEFT JOIN TB_BUDGET_STATUS S ON B.BUDSTA = S.BUDSTA
        LEFT JOIN TM_PROJECT P ON B.PROYEA = P.PROYEA AND B.PROCOD = P.PROCOD
        LEFT JOIN TM_CLIENT C ON P.CLIYEA = C.CLIYEA AND P.CLICOD = C.CLICOD
        WHERE B.BUDYEA = @P_BUDYEA 
          AND B.BUDCOD = @P_BUDCOD
          AND B.STAREC <> 'D';
        
        -- Return budget items (second result set)
        SELECT 
            BUDYEA,
            BUDCOD,
            BUDITENUM,
            BUDITENAM,
            BUDITEQTY,
            BUDITEUNI,
            BUDITEPRI,
            BUDITETOT,
            BUDITESTA,
            BUDITENOT,
            BUDITEIMGPAT,
            BUDITEIMGFIL,
            BUDITEIMGSIZ,
            BUDITEIMGMIM
        FROM TD_BUDGET_ITEM
        WHERE BUDYEA = @P_BUDYEA 
          AND BUDCOD = @P_BUDCOD
          AND STAREC <> 'D'
        ORDER BY BUDITENUM;
        
        SET @P_MESSAGE_TYPE = 3; -- Success
        SET @P_MESSAGE_DESCRIPTION = 'Presupuesto encontrado';
        SET @P_TOTAL_RECORDS = 1;
        
    END TRY
    BEGIN CATCH
        SET @P_MESSAGE_TYPE = 1; -- Error
        SET @P_MESSAGE_DESCRIPTION = ERROR_MESSAGE();
        SET @P_TOTAL_RECORDS = 0;
    END CATCH
END
GO
