-- *****************************************************************************************************
-- Description       : Get all documents with pagination
-- Created by        : Enzo Gago Aguirre
-- Creation Date     : 09/12/2025
-- Purpose           : Returns paginated list of documents with project info
-- *****************************************************************************************************

CREATE OR ALTER PROCEDURE SP_DOCUMENT_GETALL
    -- Pagination
    @P_PAGE_NUMBER INT = 1,
    @P_PAGE_SIZE INT = 10,
    -- Filters
    @P_SEARCH VARCHAR(100) = NULL,
    @P_DOCTYP CHAR(02) = NULL,
    @P_DOCSTA CHAR(01) = NULL,
    @P_PROYEA CHAR(04) = NULL,
    @P_PROCOD CHAR(06) = NULL,
    -- User filter (multitenancy via project)
    @P_USEYEA CHAR(04) = NULL,
    @P_USECOD CHAR(06) = NULL,
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
        -- Calculate offset
        DECLARE @Offset INT = (@P_PAGE_NUMBER - 1) * @P_PAGE_SIZE;
        
        -- Get user role for admin bypass
        DECLARE @UserRolCod CHAR(02) = NULL;
        IF @P_USEYEA IS NOT NULL AND @P_USECOD IS NOT NULL
        BEGIN
            SELECT @UserRolCod = ROLCOD FROM TM_USER 
            WHERE USEYEA = @P_USEYEA AND USECOD = @P_USECOD AND STAREC <> 'D';
        END
        
        -- Get total count with filters (admin bypass when RolCod='01')
        SELECT @P_TOTAL_RECORDS = COUNT(*)
        FROM TM_DOCUMENT D
        LEFT JOIN TM_PROJECT P ON D.PROYEA = P.PROYEA AND D.PROCOD = P.PROCOD
        WHERE D.STAREC <> 'D'
          AND (@P_SEARCH IS NULL OR D.DOCNAM LIKE '%' + @P_SEARCH + '%')
          AND (@P_DOCTYP IS NULL OR D.DOCTYP = @P_DOCTYP)
          AND (@P_DOCSTA IS NULL OR D.DOCSTA = @P_DOCSTA)
          AND (@P_PROYEA IS NULL OR (D.PROYEA = @P_PROYEA AND D.PROCOD = @P_PROCOD))
          AND (@UserRolCod = '01' OR @P_USEYEA IS NULL OR (P.USEYEA = @P_USEYEA AND P.USECOD = @P_USECOD));
        
        -- Return paginated data
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
            D.STAREC,
            @P_TOTAL_RECORDS AS TOTALCOUNT
        FROM TM_DOCUMENT D
        LEFT JOIN TB_DOCUMENT_TYPE T ON D.DOCTYP = T.DOCTYP
        LEFT JOIN TM_PROJECT P ON D.PROYEA = P.PROYEA AND D.PROCOD = P.PROCOD
        WHERE D.STAREC <> 'D'
          AND (@P_SEARCH IS NULL OR D.DOCNAM LIKE '%' + @P_SEARCH + '%')
          AND (@P_DOCTYP IS NULL OR D.DOCTYP = @P_DOCTYP)
          AND (@P_DOCSTA IS NULL OR D.DOCSTA = @P_DOCSTA)
          AND (@P_PROYEA IS NULL OR (D.PROYEA = @P_PROYEA AND D.PROCOD = @P_PROCOD))
          AND (@UserRolCod = '01' OR @P_USEYEA IS NULL OR (P.USEYEA = @P_USEYEA AND P.USECOD = @P_USECOD))
        ORDER BY D.DATCRE DESC
        OFFSET @Offset ROWS
        FETCH NEXT @P_PAGE_SIZE ROWS ONLY;
        
        SET @P_MESSAGE_TYPE = 3; -- Success
        SET @P_MESSAGE_DESCRIPTION = 'Documentos obtenidos correctamente';
        
    END TRY
    BEGIN CATCH
        SET @P_MESSAGE_TYPE = 1; -- Error
        SET @P_MESSAGE_DESCRIPTION = ERROR_MESSAGE();
        SET @P_TOTAL_RECORDS = 0;
    END CATCH
END
GO
