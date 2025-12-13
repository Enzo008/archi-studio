-- *****************************************************************************************************
-- Description       : Get all projects with pagination
-- Created by        : Enzo Gago Aguirre
-- Creation Date     : 09/12/2025
-- Purpose           : Returns paginated list of projects with client info
-- *****************************************************************************************************

CREATE OR ALTER PROCEDURE SP_PROJECT_GETALL
    -- Pagination
    @P_PAGE_NUMBER INT = 1,
    @P_PAGE_SIZE INT = 10,
    -- Filters
    @P_SEARCH VARCHAR(100) = NULL,
    @P_PROSTA CHAR(02) = NULL,
    @P_CLIYEA CHAR(04) = NULL,
    @P_CLICOD CHAR(06) = NULL,
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
        
        -- Get total count with filters
        SELECT @P_TOTAL_RECORDS = COUNT(*)
        FROM TM_PROJECT P
        WHERE P.STAREC <> 'D'
          AND (@P_SEARCH IS NULL OR P.PRONAM LIKE '%' + @P_SEARCH + '%' OR P.PRODES LIKE '%' + @P_SEARCH + '%')
          AND (@P_PROSTA IS NULL OR P.PROSTA = @P_PROSTA)
          AND (@P_CLIYEA IS NULL OR (P.CLIYEA = @P_CLIYEA AND P.CLICOD = @P_CLICOD))
          AND (@P_USEYEA IS NULL OR (P.USEYEA = @P_USEYEA AND P.USECOD = @P_USECOD));
        
        -- Return paginated data
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
            P.USEYEA,
            P.USECOD,
            U.USENAM,
            U.USELAS,
            P.USECRE,
            P.DATCRE,
            P.ZONCRE,
            P.USEUPD,
            P.DATUPD,
            P.ZONUPD,
            P.STAREC,
            @P_TOTAL_RECORDS AS TOTALCOUNT
        FROM TM_PROJECT P
        LEFT JOIN TB_PROJECT_STATUS S ON P.PROSTA = S.PROSTA
        LEFT JOIN TM_CLIENT C ON P.CLIYEA = C.CLIYEA AND P.CLICOD = C.CLICOD
        LEFT JOIN TM_USER U ON P.USEYEA = U.USEYEA AND P.USECOD = U.USECOD
        WHERE P.STAREC <> 'D'
          AND (@P_SEARCH IS NULL OR P.PRONAM LIKE '%' + @P_SEARCH + '%' OR P.PRODES LIKE '%' + @P_SEARCH + '%')
          AND (@P_PROSTA IS NULL OR P.PROSTA = @P_PROSTA)
          AND (@P_CLIYEA IS NULL OR (P.CLIYEA = @P_CLIYEA AND P.CLICOD = @P_CLICOD))
          AND (@P_USEYEA IS NULL OR (P.USEYEA = @P_USEYEA AND P.USECOD = @P_USECOD))
        ORDER BY P.DATCRE DESC
        OFFSET @Offset ROWS
        FETCH NEXT @P_PAGE_SIZE ROWS ONLY;
        
        SET @P_MESSAGE_TYPE = 3; -- Success
        SET @P_MESSAGE_DESCRIPTION = 'Proyectos obtenidos correctamente';
        
    END TRY
    BEGIN CATCH
        SET @P_MESSAGE_TYPE = 1; -- Error
        SET @P_MESSAGE_DESCRIPTION = ERROR_MESSAGE();
        SET @P_TOTAL_RECORDS = 0;
    END CATCH
END
GO
