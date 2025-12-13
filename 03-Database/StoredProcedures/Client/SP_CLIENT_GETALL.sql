-- *****************************************************************************************************
-- Description       : Get all clients with pagination
-- Created by        : Enzo Gago Aguirre
-- Creation Date     : 09/12/2025
-- Purpose           : Returns paginated list of clients
-- *****************************************************************************************************

CREATE OR ALTER PROCEDURE SP_CLIENT_GETALL
    -- Pagination
    @P_PAGE_NUMBER INT = 1,
    @P_PAGE_SIZE INT = 10,
    -- User filter (multitenancy)
    @P_USEYEA CHAR(04) = NULL,
    @P_USECOD CHAR(06) = NULL,
    -- Filters
    @P_SEARCH VARCHAR(100) = NULL,
    @P_CLITYP CHAR(02) = NULL,
    @P_CLISTA CHAR(01) = NULL,
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
        
        -- Get total count with filters (including user filter for multitenancy)
        SELECT @P_TOTAL_RECORDS = COUNT(*)
        FROM TM_CLIENT
        WHERE STAREC <> 'D'
          AND (@P_USEYEA IS NULL OR USEYEA = @P_USEYEA)
          AND (@P_USECOD IS NULL OR USECOD = @P_USECOD)
          AND (@P_SEARCH IS NULL OR CLINAM LIKE '%' + @P_SEARCH + '%' OR CLIEMA LIKE '%' + @P_SEARCH + '%')
          AND (@P_CLITYP IS NULL OR CLITYP = @P_CLITYP)
          AND (@P_CLISTA IS NULL OR CLISTA = @P_CLISTA);
        
        -- Return paginated data
        SELECT 
            CLIYEA,
            CLICOD,
            CLINAM,
            CLITYP,
            CLIEMA,
            CLIPHO,
            CLIADD,
            CLISTA,
            CLIDES,
            USEYEA,
            USECOD,
            USECRE,
            DATCRE,
            ZONCRE,
            USEUPD,
            DATUPD,
            ZONUPD,
            STAREC,
            @P_TOTAL_RECORDS AS TOTALCOUNT
        FROM TM_CLIENT
        WHERE STAREC <> 'D'
          AND (@P_USEYEA IS NULL OR USEYEA = @P_USEYEA)
          AND (@P_USECOD IS NULL OR USECOD = @P_USECOD)
          AND (@P_SEARCH IS NULL OR CLINAM LIKE '%' + @P_SEARCH + '%' OR CLIEMA LIKE '%' + @P_SEARCH + '%')
          AND (@P_CLITYP IS NULL OR CLITYP = @P_CLITYP)
          AND (@P_CLISTA IS NULL OR CLISTA = @P_CLISTA)
        ORDER BY DATCRE DESC
        OFFSET @Offset ROWS
        FETCH NEXT @P_PAGE_SIZE ROWS ONLY;
        
        SET @P_MESSAGE_TYPE = 3; -- Success
        SET @P_MESSAGE_DESCRIPTION = 'Clientes obtenidos correctamente';
        
    END TRY
    BEGIN CATCH
        SET @P_MESSAGE_TYPE = 1; -- Error
        SET @P_MESSAGE_DESCRIPTION = ERROR_MESSAGE();
        SET @P_TOTAL_RECORDS = 0;
    END CATCH
END
GO
