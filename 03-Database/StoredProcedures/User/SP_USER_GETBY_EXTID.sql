-- *****************************************************************************************************
-- Description       : Get user by External ID (Clerk ID)
-- Created by        : Enzo Gago Aguirre
-- Creation Date     : 09/12/2025
-- Purpose           : Returns user by Clerk external ID
-- *****************************************************************************************************

CREATE OR ALTER PROCEDURE SP_USER_GETBY_EXTID
    @P_USEEXTID NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    
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
        U.STAREC
    FROM TM_USER U
    LEFT JOIN TB_ROLE R ON U.ROLCOD = R.ROLCOD
    WHERE U.USEEXTID = @P_USEEXTID
      AND U.STAREC <> 'D';
END
GO
