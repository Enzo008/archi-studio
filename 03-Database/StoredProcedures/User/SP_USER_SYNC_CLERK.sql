-- *****************************************************************************************************
-- Description       : Sync user from Clerk authentication
-- Created by        : Enzo Gago Aguirre
-- Creation Date     : 09/12/2025
-- Updated           : 24/12/2025 - Returns complete user data + role + menus in single query
-- Purpose           : Creates user if not exists, updates if exists (UPSERT by EXTID or EMAIL)
--                     Returns complete user info, role, and menus in ResultSet (no additional queries needed)
-- Features          : - UPSERT pattern by USEEXTID or USEEMA
--                     - Uses SP_GENERATE_CODE_WITH_YEAR for new users
--                     - ALWAYS logs operations (SP_REGISTER_LOG + SP_UPDATE_DATE_END_SQL)
--                     - Returns 2 ResultSets: User+Role, Menus
-- *****************************************************************************************************

CREATE OR ALTER PROCEDURE SP_USER_SYNC_CLERK
    @P_USEEXTID             NVARCHAR(100),
    @P_USEEMA               VARCHAR(100),
    @P_USENAM               VARCHAR(50) = NULL,
    @P_USELAS               VARCHAR(50) = NULL,
    @P_USEIMG               VARCHAR(500) = NULL,
    @P_LOGIPMAC             VARCHAR(15) = NULL,
    @P_USEYEA_U             CHAR(04) = NULL,
    @P_USECOD_U             CHAR(06) = NULL,
    @P_USENAM_U             VARCHAR(30) = NULL,
    @P_USELAS_U             VARCHAR(30) = NULL,
    @P_ROLCOD_U             CHAR(02) = NULL,
    @P_USEYEA_OUT           CHAR(04) OUTPUT,
    @P_USECOD_OUT           CHAR(06) OUTPUT,
    @P_ACTION_OUT           VARCHAR(10) OUTPUT,
    @P_MESSAGE_DESCRIPTION  NVARCHAR(500) OUTPUT,
    @P_MESSAGE_TYPE         INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @V_NAME_TABLE       NVARCHAR(100) = 'TM_USER',
            @V_CODE_LOG_YEAR    CHAR(4) = '',
            @V_CODE_LOG         CHAR(10) = '',
            @V_DESCRIPTION_LOG  NVARCHAR(300) = '',
            @V_LOG_CODE_REC     VARCHAR(20) = '',
            @V_LOG_ACTION       VARCHAR(10) = '',
            @V_USER_FULL        VARCHAR(65) = '',
            @V_CODE_GENERATED   NVARCHAR(300) = '',
            @V_ROLCOD           CHAR(02) = NULL;
    
    SET @V_USER_FULL = COALESCE(LTRIM(RTRIM(@P_USENAM)) + ' ' + LTRIM(RTRIM(@P_USELAS)), 'CLERK SYNC');
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if user exists by external ID
        IF EXISTS (SELECT 1 FROM TM_USER WHERE USEEXTID = @P_USEEXTID AND STAREC <> 'D')
        BEGIN
            -- UPDATE existing user
            UPDATE TM_USER
            SET USENAM = COALESCE(@P_USENAM, USENAM), USELAS = COALESCE(@P_USELAS, USELAS),
                USEEMA = COALESCE(@P_USEEMA, USEEMA), USEIMG = COALESCE(@P_USEIMG, USEIMG),
                USEUPD = @V_USER_FULL, DATUPD = GETDATE(), ZONUPD = 'America/Lima'
            WHERE USEEXTID = @P_USEEXTID;
            
            SELECT @P_USEYEA_OUT = USEYEA, @P_USECOD_OUT = USECOD, @V_ROLCOD = ROLCOD 
            FROM TM_USER WHERE USEEXTID = @P_USEEXTID;
            
            SET @V_DESCRIPTION_LOG = 'USER SYNC - UPDATE';
            SET @V_LOG_ACTION = 'UPDATE';
            SET @P_ACTION_OUT = 'UPDATE';
        END
        ELSE IF EXISTS (SELECT 1 FROM TM_USER WHERE USEEMA = @P_USEEMA AND STAREC <> 'D')
        BEGIN
            -- LINK existing user to Clerk
            UPDATE TM_USER
            SET USEEXTID = @P_USEEXTID, USENAM = COALESCE(@P_USENAM, USENAM), USELAS = COALESCE(@P_USELAS, USELAS),
                USEIMG = COALESCE(@P_USEIMG, USEIMG),
                USEUPD = @V_USER_FULL, DATUPD = GETDATE(), ZONUPD = 'America/Lima'
            WHERE USEEMA = @P_USEEMA;
            
            SELECT @P_USEYEA_OUT = USEYEA, @P_USECOD_OUT = USECOD, @V_ROLCOD = ROLCOD 
            FROM TM_USER WHERE USEEMA = @P_USEEMA;
            
            SET @V_DESCRIPTION_LOG = 'USER SYNC - LINK';
            SET @V_LOG_ACTION = 'UPDATE';
            SET @P_ACTION_OUT = 'LINK';
        END
        ELSE
        BEGIN
            -- INSERT new user
            SET @P_USEYEA_OUT = CAST(YEAR(GETDATE()) AS CHAR(04));
            EXEC SP_GENERATE_CODE_WITH_YEAR '000001', 'TM_USER', 'USECOD', 'USEYEA', @V_CODE = @V_CODE_GENERATED OUTPUT;
            SET @P_USECOD_OUT = @V_CODE_GENERATED;
            SET @V_ROLCOD = '02'; -- Default role for new users
            
            INSERT INTO TM_USER (
                USEYEA, USECOD, USEEXTID, USENAM, USELAS, USEEMA, USEIMG, ROLCOD, USESTA,
                USECRE, DATCRE, ZONCRE, STAREC
            ) VALUES (
                @P_USEYEA_OUT, @P_USECOD_OUT, @P_USEEXTID, @P_USENAM, @P_USELAS, @P_USEEMA, @P_USEIMG, @V_ROLCOD, 'A',
                @V_USER_FULL, GETDATE(), 'America/Lima', 'C'
            );
            
            SET @V_DESCRIPTION_LOG = 'USER SYNC - CREATE';
            SET @V_LOG_ACTION = 'INSERT';
            SET @P_ACTION_OUT = 'CREATE';
        END
        
        SET @V_LOG_CODE_REC = @P_USEYEA_OUT + '-' + @P_USECOD_OUT;
        
        COMMIT TRANSACTION;
        
        SET @P_MESSAGE_TYPE = 3;
        SET @P_MESSAGE_DESCRIPTION = 'Usuario sincronizado correctamente';
        
        -- Log the operation
        EXEC SP_REGISTER_LOG @V_DESCRIPTION_LOG, @V_LOG_ACTION, @P_LOGIPMAC, @V_LOG_CODE_REC,
            @V_NAME_TABLE, '', 'SUCCESS', @P_USEYEA_U, @P_USECOD_U, @P_USENAM_U, @P_USELAS_U,
            @P_MESSAGE_DESCRIPTION = @P_MESSAGE_DESCRIPTION OUTPUT, @P_MESSAGE_TYPE = @P_MESSAGE_TYPE OUTPUT,
            @P_LOGYEA = @V_CODE_LOG_YEAR OUTPUT, @P_LOGCOD = @V_CODE_LOG OUTPUT;
        EXEC SP_UPDATE_DATE_END_SQL @V_CODE_LOG_YEAR, @V_CODE_LOG, '';
        
        -- =========================================================================
        -- RESULT SET 1: User data with Role (as JSON for consistency with other SPs)
        -- =========================================================================
        SELECT 
            U.USEYEA, U.USECOD, U.USEEXTID, U.USENAM, U.USELAS, U.USEEMA, U.USEIMG, U.USESTA,
            U.ROLCOD, R.ROLNAM,
            U.DATCRE, U.DATUPD, U.STAREC
        FROM TM_USER U
        LEFT JOIN TB_ROLE R ON U.ROLCOD = R.ROLCOD
        WHERE U.USEYEA = @P_USEYEA_OUT AND U.USECOD = @P_USECOD_OUT
        FOR JSON PATH;
        
        -- =========================================================================
        -- RESULT SET 2: Menus for user's role (as JSON)
        -- =========================================================================
        SELECT M.MENYEA, M.MENCOD, M.MENNAM, M.MENREF, M.MENICO, M.MENORD, M.MENYEAPAR, M.MENCODPAR
        FROM TM_MENU M
        WHERE M.STAREC <> 'D'
          AND EXISTS (
              SELECT 1 FROM TV_ROLE_MENU RM 
              WHERE RM.MENYEA = M.MENYEA AND RM.MENCOD = M.MENCOD 
                AND RM.ROLCOD = @V_ROLCOD AND RM.STAREC <> 'D'
          )
        ORDER BY M.MENYEAPAR, M.MENCODPAR, M.MENORD, M.MENYEA, M.MENCOD
        FOR JSON PATH;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        
        DECLARE @V_ERROR NVARCHAR(MAX) = ERROR_MESSAGE();
        DECLARE @V_LOG_ACTION_FINAL VARCHAR(10) = COALESCE(@V_LOG_ACTION, 'INSERT');
        SET @V_LOG_CODE_REC = ISNULL(@P_USEYEA_OUT, '') + '-' + ISNULL(@P_USECOD_OUT, '');
        
        EXEC SP_REGISTER_LOG @V_ERROR, @V_LOG_ACTION_FINAL, @P_LOGIPMAC, @V_LOG_CODE_REC,
            @V_NAME_TABLE, '', 'ERROR', @P_USEYEA_U, @P_USECOD_U, @P_USENAM_U, @P_USELAS_U,
            @P_MESSAGE_DESCRIPTION = @P_MESSAGE_DESCRIPTION OUTPUT, @P_MESSAGE_TYPE = @P_MESSAGE_TYPE OUTPUT,
            @P_LOGYEA = @V_CODE_LOG_YEAR OUTPUT, @P_LOGCOD = @V_CODE_LOG OUTPUT;
        EXEC SP_UPDATE_DATE_END_SQL @V_CODE_LOG_YEAR, @V_CODE_LOG, '';
        
        SET @P_MESSAGE_TYPE = 1;
        SET @P_MESSAGE_DESCRIPTION = @V_ERROR;
        SET @P_ACTION_OUT = 'ERROR';
    END CATCH
END
GO
