-- *****************************************************************************************************
-- Description       : Get menus by role
-- Created by        : Enzo Gago Aguirre
-- Creation Date     : 09/12/2025
-- Purpose           : Returns menus assigned to a specific role
-- *****************************************************************************************************

CREATE OR ALTER PROCEDURE SP_MENU_GETBY_ROLE
    @P_ROLCOD CHAR(02)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Return menus for the role
    SELECT DISTINCT
        M.MENYEA,
        M.MENCOD,
        M.MENNAM,
        M.MENREF,
        M.MENICO,
        M.MENORD,
        M.MENYEAPAR,
        M.MENCODPAR
    FROM TM_MENU M
    INNER JOIN TV_ROLE_MENU RM ON M.MENYEA = RM.MENYEA AND M.MENCOD = RM.MENCOD
    WHERE RM.ROLCOD = @P_ROLCOD
      AND M.STAREC <> 'D'
      AND RM.STAREC <> 'D'
    ORDER BY M.MENYEAPAR, M.MENCODPAR, M.MENORD, M.MENYEA, M.MENCOD;
END
GO
