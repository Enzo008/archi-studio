-- *****************************************************************************************************
-- Description       : Update budget item image only
-- Created by        : Enzo Gago Aguirre
-- Creation Date     : 12/12/2025
-- Purpose           : Updates only the image fields of a budget item (partial update)
-- *****************************************************************************************************

CREATE OR ALTER PROCEDURE SP_BUDGET_ITEM_UPDATE_IMAGE
    @P_BUDYEA CHAR(04),
    @P_BUDCOD CHAR(06),
    @P_BUDITENUM INT,
    -- Image fields only
    @P_BUDITEIMGPAT VARCHAR(500),
    @P_BUDITEIMGFIL VARCHAR(200),
    @P_BUDITEIMGSIZ BIGINT,
    @P_BUDITEIMGMIM VARCHAR(100),
    -- Log parameters
    @P_USECRE VARCHAR(30),
    @P_ZONCRE VARCHAR(50),
    -- Output parameters
    @P_MESSAGE_DESCRIPTION VARCHAR(500) OUTPUT,
    @P_MESSAGE_TYPE INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Check if item exists
        IF NOT EXISTS (SELECT 1 FROM TD_BUDGET_ITEM WHERE BUDYEA = @P_BUDYEA AND BUDCOD = @P_BUDCOD AND BUDITENUM = @P_BUDITENUM AND STAREC <> 'D')
        BEGIN
            SET @P_MESSAGE_TYPE = 2; -- Warning
            SET @P_MESSAGE_DESCRIPTION = 'Item no encontrado';
            RETURN;
        END
        
        -- Update only image fields
        UPDATE TD_BUDGET_ITEM
        SET 
            BUDITEIMGPAT = @P_BUDITEIMGPAT,
            BUDITEIMGFIL = @P_BUDITEIMGFIL,
            BUDITEIMGSIZ = @P_BUDITEIMGSIZ,
            BUDITEIMGMIM = @P_BUDITEIMGMIM,
            USEUPD = @P_USECRE,
            DATUPD = GETDATE(),
            ZONUPD = @P_ZONCRE
        WHERE BUDYEA = @P_BUDYEA AND BUDCOD = @P_BUDCOD AND BUDITENUM = @P_BUDITENUM;
        
        SET @P_MESSAGE_TYPE = 3; -- Success
        SET @P_MESSAGE_DESCRIPTION = 'Imagen actualizada correctamente';
        
    END TRY
    BEGIN CATCH
        SET @P_MESSAGE_TYPE = 1; -- Error
        SET @P_MESSAGE_DESCRIPTION = ERROR_MESSAGE();
    END CATCH
END
GO
