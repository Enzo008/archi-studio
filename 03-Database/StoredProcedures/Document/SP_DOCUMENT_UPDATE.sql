-- *****************************************************************************************************
-- Description       : Update an existing document
-- Created by        : Enzo Gago Aguirre
-- Creation Date     : 09/12/2025
-- Purpose           : Updates document information
-- *****************************************************************************************************

CREATE OR ALTER PROCEDURE SP_DOCUMENT_UPDATE
    @P_DOCYEA CHAR(04),
    @P_DOCCOD CHAR(06),
    @P_DOCNAM VARCHAR(200) = NULL,
    @P_DOCDES VARCHAR(500) = NULL,
    @P_DOCTYP CHAR(02) = NULL,
    @P_DOCSTA CHAR(01) = NULL,
    @P_PROYEA CHAR(04) = NULL,
    @P_PROCOD CHAR(06) = NULL,
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
        
        -- Check if document exists
        IF NOT EXISTS (SELECT 1 FROM TM_DOCUMENT WHERE DOCYEA = @P_DOCYEA AND DOCCOD = @P_DOCCOD AND STAREC <> 'D')
        BEGIN
            SET @P_MESSAGE_TYPE = 2; -- Warning
            SET @P_MESSAGE_DESCRIPTION = 'Documento no encontrado';
            SET @P_TOTAL_RECORDS = 0;
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Update document
        UPDATE TM_DOCUMENT
        SET 
            DOCNAM = ISNULL(@P_DOCNAM, DOCNAM),
            DOCDES = ISNULL(@P_DOCDES, DOCDES),
            DOCTYP = ISNULL(@P_DOCTYP, DOCTYP),
            DOCSTA = ISNULL(@P_DOCSTA, DOCSTA),
            PROYEA = ISNULL(@P_PROYEA, PROYEA),
            PROCOD = ISNULL(@P_PROCOD, PROCOD),
            USEUPD = @P_USECRE,
            DATUPD = GETDATE(),
            ZONUPD = @P_ZONCRE,
            STAREC = 'U'
        WHERE DOCYEA = @P_DOCYEA AND DOCCOD = @P_DOCCOD;
        
        COMMIT TRANSACTION;
        
        SET @P_MESSAGE_TYPE = 3; -- Success
        SET @P_MESSAGE_DESCRIPTION = 'Documento actualizado correctamente';
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
