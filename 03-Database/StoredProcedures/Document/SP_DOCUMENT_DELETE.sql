-- *****************************************************************************************************
-- Description       : Delete (soft delete) a document
-- Created by        : Enzo Gago Aguirre
-- Creation Date     : 09/12/2025
-- Purpose           : Marks document as eliminated
-- *****************************************************************************************************

CREATE OR ALTER PROCEDURE SP_DOCUMENT_DELETE
    @P_DOCYEA CHAR(04),
    @P_DOCCOD CHAR(06),
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
        
        -- Soft delete document
        UPDATE TM_DOCUMENT
        SET 
            DOCSTA = 'I',
            USEUPD = @P_USECRE,
            DATUPD = GETDATE(),
            ZONUPD = @P_ZONCRE,
            STAREC = 'D'
        WHERE DOCYEA = @P_DOCYEA AND DOCCOD = @P_DOCCOD;
        
        COMMIT TRANSACTION;
        
        SET @P_MESSAGE_TYPE = 3; -- Success
        SET @P_MESSAGE_DESCRIPTION = 'Documento eliminado correctamente';
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
