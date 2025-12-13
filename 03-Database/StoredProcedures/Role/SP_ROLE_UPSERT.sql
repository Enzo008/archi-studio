-- *****************************************************************************************************
-- Description        : Stored Procedure to create or update a role
-- Created by         : Enzo Gago Aguirre
-- Creation Date      : 10/12/2024
-- Action             : Insert or Update role
-- *****************************************************************************************************

CREATE OR ALTER PROCEDURE SP_ROLE_UPSERT
    @P_ROLCOD       CHAR(02),
    @P_ROLNAM       VARCHAR(50),
    @P_ROLDES       VARCHAR(200) = NULL,
    @P_USER         VARCHAR(30),
    @P_TIMEZONE     VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Action VARCHAR(10);
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if role exists
        IF EXISTS (SELECT 1 FROM TB_ROLE WHERE ROLCOD = @P_ROLCOD AND STAREC <> 'D')
        BEGIN
            -- Update existing role
            UPDATE TB_ROLE
            SET ROLNAM = @P_ROLNAM,
                ROLDES = @P_ROLDES,
                USEUPD = @P_USER,
                DATUPD = GETDATE(),
                ZONUPD = @P_TIMEZONE,
                STAREC = 'U'
            WHERE ROLCOD = @P_ROLCOD;
            
            SET @Action = 'UPDATED';
        END
        ELSE
        BEGIN
            -- Insert new role
            INSERT INTO TB_ROLE (
                ROLCOD, ROLNAM, ROLDES,
                USECRE, DATCRE, ZONCRE, STAREC
            ) VALUES (
                @P_ROLCOD, @P_ROLNAM, @P_ROLDES,
                @P_USER, GETDATE(), @P_TIMEZONE, 'C'
            );
            
            SET @Action = 'CREATED';
        END
        
        COMMIT TRANSACTION;
        
        -- Return the role
        SELECT 
            ROLCOD,
            ROLNAM,
            ROLDES,
            @Action AS [ACTION]
        FROM TB_ROLE
        WHERE ROLCOD = @P_ROLCOD;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO
