-- *****************************************************************************************************
-- Description       : Sync user from Clerk authentication
-- Created by        : Enzo Gago Aguirre
-- Creation Date     : 09/12/2025
-- Purpose           : Creates user if not exists, updates last access if exists
-- *****************************************************************************************************

CREATE OR ALTER PROCEDURE SP_USER_SYNC_CLERK
    @P_USEEXTID NVARCHAR(100),
    @P_USEEMA VARCHAR(100),
    @P_USENAM VARCHAR(50) = NULL,
    @P_USELAS VARCHAR(50) = NULL,
    @P_USEIMG VARCHAR(500) = NULL,
    @P_USECRE VARCHAR(30),
    @P_ZONCRE VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @UseYea CHAR(04);
    DECLARE @UseCod CHAR(06);
    DECLARE @Action VARCHAR(10);
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if user exists by external ID
        IF EXISTS (SELECT 1 FROM TM_USER WHERE USEEXTID = @P_USEEXTID AND STAREC <> 'D')
        BEGIN
            -- Update existing user (update last access and sync data)
            UPDATE TM_USER
            SET 
                USENAM = ISNULL(@P_USENAM, USENAM),
                USELAS = ISNULL(@P_USELAS, USELAS),
                USEEMA = ISNULL(@P_USEEMA, USEEMA),
                USEIMG = ISNULL(@P_USEIMG, USEIMG),
                USEUPD = @P_USECRE,
                DATUPD = GETDATE(),
                ZONUPD = @P_ZONCRE
            WHERE USEEXTID = @P_USEEXTID;
            
            SELECT @UseYea = USEYEA, @UseCod = USECOD
            FROM TM_USER
            WHERE USEEXTID = @P_USEEXTID;
            
            SET @Action = 'UPDATE';
        END
        ELSE
        BEGIN
            -- Check if email exists (user might exist without external ID)
            IF EXISTS (SELECT 1 FROM TM_USER WHERE USEEMA = @P_USEEMA AND STAREC <> 'D')
            BEGIN
                -- Link existing user to Clerk
                UPDATE TM_USER
                SET 
                    USEEXTID = @P_USEEXTID,
                    USENAM = ISNULL(@P_USENAM, USENAM),
                    USELAS = ISNULL(@P_USELAS, USELAS),
                    USEIMG = ISNULL(@P_USEIMG, USEIMG),
                    USEUPD = @P_USECRE,
                    DATUPD = GETDATE(),
                    ZONUPD = @P_ZONCRE
                WHERE USEEMA = @P_USEEMA;
                
                SELECT @UseYea = USEYEA, @UseCod = USECOD
                FROM TM_USER
                WHERE USEEMA = @P_USEEMA;
                
                SET @Action = 'LINK';
            END
            ELSE
            BEGIN
                -- Create new user
                SET @UseYea = CAST(YEAR(GETDATE()) AS CHAR(04));
                
                SELECT @UseCod = RIGHT('000000' + CAST(ISNULL(MAX(CAST(USECOD AS INT)), 0) + 1 AS VARCHAR), 6)
                FROM TM_USER
                WHERE USEYEA = @UseYea;
                
                INSERT INTO TM_USER (
                    USEYEA, USECOD, USEEXTID, USENAM, USELAS, USEEMA, USEIMG,
                    ROLCOD, USESTA,
                    USECRE, DATCRE, ZONCRE, STAREC
                )
                VALUES (
                    @UseYea, @UseCod, @P_USEEXTID, @P_USENAM, @P_USELAS, @P_USEEMA, @P_USEIMG,
                    '02', 'A',  -- Default role: 01 (User), Active status
                    @P_USECRE, GETDATE(), @P_ZONCRE, 'C'
                );
                
                SET @Action = 'INSERT';
            END
        END
        
        COMMIT TRANSACTION;
        
        -- Return user data with action taken
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
            @Action AS [ACTION]
        FROM TM_USER U
        LEFT JOIN TB_ROLE R ON U.ROLCOD = R.ROLCOD
        WHERE U.USEYEA = @UseYea AND U.USECOD = @UseCod;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        -- Return error
        SELECT 
            NULL AS USEYEA,
            NULL AS USECOD,
            NULL AS USEEXTID,
            NULL AS USENAM,
            NULL AS USELAS,
            NULL AS USEEMA,
            NULL AS USEIMG,
            NULL AS USESTA,
            NULL AS ROLCOD,
            NULL AS ROLNAM,
            'ERROR' AS [ACTION],
            ERROR_MESSAGE() AS ERROR_MSG;
    END CATCH
END
GO
