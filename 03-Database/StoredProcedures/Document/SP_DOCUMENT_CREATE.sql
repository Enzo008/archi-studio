-- *****************************************************************************************************
-- Description       : Create a new document record
-- Created by        : Enzo Gago Aguirre
-- Creation Date     : 09/12/2025
-- Purpose           : Inserts a new document with auto-generated year/code
-- *****************************************************************************************************

CREATE OR ALTER PROCEDURE SP_DOCUMENT_CREATE
    @P_DOCNAM VARCHAR(200),
    @P_DOCDES VARCHAR(500) = NULL,
    @P_DOCTYP CHAR(02) = '06',
    @P_DOCPAT VARCHAR(500),
    @P_DOCFIL VARCHAR(200) = NULL,
    @P_DOCSIZ BIGINT = NULL,
    @P_DOCMIM VARCHAR(100) = NULL,
    @P_DOCSTA CHAR(01) = 'A',
    @P_PROYEA CHAR(04) = NULL,
    @P_PROCOD CHAR(06) = NULL,
    -- Log parameters
    @P_USECRE VARCHAR(30),
    @P_ZONCRE VARCHAR(50),
    -- Output parameters
    @P_DOCYEA_OUT CHAR(04) OUTPUT,
    @P_DOCCOD_OUT CHAR(06) OUTPUT,
    @P_MESSAGE_DESCRIPTION VARCHAR(500) OUTPUT,
    @P_MESSAGE_TYPE INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate project if provided
        IF @P_PROYEA IS NOT NULL AND @P_PROCOD IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM TM_PROJECT WHERE PROYEA = @P_PROYEA AND PROCOD = @P_PROCOD AND STAREC <> 'D')
            BEGIN
                SET @P_MESSAGE_TYPE = 2; -- Warning
                SET @P_MESSAGE_DESCRIPTION = 'Proyecto no encontrado';
                ROLLBACK TRANSACTION;
                RETURN;
            END
        END
        
        -- Generate DOCYEA (current year)
        SET @P_DOCYEA_OUT = CAST(YEAR(GETDATE()) AS CHAR(04));
        
        -- Generate DOCCOD (next sequential code for this year)
        SELECT @P_DOCCOD_OUT = RIGHT('000000' + CAST(ISNULL(MAX(CAST(DOCCOD AS INT)), 0) + 1 AS VARCHAR), 6)
        FROM TM_DOCUMENT
        WHERE DOCYEA = @P_DOCYEA_OUT;
        
        -- Insert the document
        INSERT INTO TM_DOCUMENT (
            DOCYEA, DOCCOD, DOCNAM, DOCDES, DOCTYP, DOCPAT, DOCFIL,
            DOCSIZ, DOCMIM, DOCSTA,
            PROYEA, PROCOD,
            USECRE, DATCRE, ZONCRE, STAREC
        )
        VALUES (
            @P_DOCYEA_OUT, @P_DOCCOD_OUT, @P_DOCNAM, @P_DOCDES, @P_DOCTYP, @P_DOCPAT, @P_DOCFIL,
            @P_DOCSIZ, @P_DOCMIM, @P_DOCSTA,
            @P_PROYEA, @P_PROCOD,
            @P_USECRE, GETDATE(), @P_ZONCRE, 'C'
        );
        
        COMMIT TRANSACTION;
        
        SET @P_MESSAGE_TYPE = 3; -- Success
        SET @P_MESSAGE_DESCRIPTION = 'Documento creado correctamente';
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @P_MESSAGE_TYPE = 1; -- Error
        SET @P_MESSAGE_DESCRIPTION = ERROR_MESSAGE();
    END CATCH
END
GO
