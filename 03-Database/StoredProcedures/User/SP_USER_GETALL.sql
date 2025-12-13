-- *****************************************************************************************************
-- Description       : Get all users with pagination
-- Created by        : Enzo Gago Aguirre
-- Creation Date     : 09/12/2025
-- Purpose           : Returns paginated list of users with role info
-- *****************************************************************************************************

CREATE OR ALTER PROCEDURE SP_USER_GETALL
    -- Pagination
    @P_PAGE_NUMBER INT = 1,
    @P_PAGE_SIZE INT = 10,
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
        
        -- Get total count
        SELECT @P_TOTAL_RECORDS = COUNT(*)
        FROM TM_USER
        WHERE STAREC <> 'D';
        
        -- Return paginated data
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
            U.DATCRE,
            U.DATUPD,
            U.STAREC,
            @P_TOTAL_RECORDS AS TOTALCOUNT
        FROM TM_USER U
        LEFT JOIN TB_ROLE R ON U.ROLCOD = R.ROLCOD
        WHERE U.STAREC <> 'D'
        ORDER BY U.DATCRE DESC
        OFFSET @Offset ROWS
        FETCH NEXT @P_PAGE_SIZE ROWS ONLY;
        
        SET @P_MESSAGE_TYPE = 3; -- Success
        SET @P_MESSAGE_DESCRIPTION = 'Usuarios obtenidos correctamente';
        
    END TRY
    BEGIN CATCH
        SET @P_MESSAGE_TYPE = 1; -- Error
        SET @P_MESSAGE_DESCRIPTION = ERROR_MESSAGE();
        SET @P_TOTAL_RECORDS = 0;
    END CATCH
END
GO
