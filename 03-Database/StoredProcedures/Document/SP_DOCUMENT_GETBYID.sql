-- *****************************************************************************************************
-- Description       : Get document by ID
-- Created by        : Enzo Gago Aguirre
-- Creation Date     : 09/12/2025
-- Purpose           : Returns a single document by composite key
-- *****************************************************************************************************

CREATE OR ALTER PROCEDURE SP_DOCUMENT_GETBYID
    @P_DOCYEA CHAR(04),
    @P_DOCCOD CHAR(06),
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
        -- Check if document exists
        IF NOT EXISTS (SELECT 1 FROM TM_DOCUMENT WHERE DOCYEA = @P_DOCYEA AND DOCCOD = @P_DOCCOD AND STAREC <> 'D')
        BEGIN
            SET @P_MESSAGE_TYPE = 2; -- Warning
            SET @P_MESSAGE_DESCRIPTION = 'Documento no encontrado';
            SET @P_TOTAL_RECORDS = 0;
            RETURN;
        END
        
        -- Return document data
        SELECT 
            D.DOCYEA,
            D.DOCCOD,
            D.DOCNAM,
            D.DOCDES,
            D.DOCTYP,
            T.DOCTYPNAM,
            T.DOCTYPICO,
            D.DOCPAT,
            D.DOCFIL,
            D.DOCSIZ,
            D.DOCMIM,
            D.DOCSTA,
            D.PROYEA,
            D.PROCOD,
            P.PRONAM,
            D.USECRE,
            D.DATCRE,
            D.ZONCRE,
            D.USEUPD,
            D.DATUPD,
            D.ZONUPD,
            D.STAREC
        FROM TM_DOCUMENT D
        LEFT JOIN TB_DOCUMENT_TYPE T ON D.DOCTYP = T.DOCTYP
        LEFT JOIN TM_PROJECT P ON D.PROYEA = P.PROYEA AND D.PROCOD = P.PROCOD
        WHERE D.DOCYEA = @P_DOCYEA 
          AND D.DOCCOD = @P_DOCCOD
          AND D.STAREC <> 'D';
        
        SET @P_MESSAGE_TYPE = 3; -- Success
        SET @P_MESSAGE_DESCRIPTION = 'Documento encontrado';
        SET @P_TOTAL_RECORDS = 1;
        
    END TRY
    BEGIN CATCH
        SET @P_MESSAGE_TYPE = 1; -- Error
        SET @P_MESSAGE_DESCRIPTION = ERROR_MESSAGE();
        SET @P_TOTAL_RECORDS = 0;
    END CATCH
END
GO
