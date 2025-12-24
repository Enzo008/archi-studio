USE master

CREATE OR ALTER PROCEDURE SP_GENERATE_CODE
       @P_DEFAULT_VALUE     VARCHAR(50),
       @P_TABLE_NAME        VARCHAR(50),
       @P_PK_FIELD_NAME     VARCHAR(50),
       @V_CODE              NVARCHAR(300) OUTPUT
AS
BEGIN
    DECLARE
            @V_DIGIT             CHAR = '0',
            @V_SQL               NVARCHAR(MAX),
            @V_NUMBER_COUNTER    INT = 0,
            @V_LETTER_COUNTER    INT = 0,
            @V_LENGTH1           INT = 0,
            @V_LENGTH2           INT = 0,
            @V_LETTERS           NVARCHAR(100) = '',
            @V_INDEX             INT = 1

    WHILE @V_INDEX < LEN(@P_DEFAULT_VALUE)
    BEGIN

        IF  ISNUMERIC(SUBSTRING(@P_DEFAULT_VALUE,1,@V_INDEX)) = 1
            BEGIN
                SET @V_NUMBER_COUNTER = @V_NUMBER_COUNTER + 1
            End
        Else
            BEGIN
                SET @V_LETTER_COUNTER = @V_LETTER_COUNTER + 1
                SET @V_LETTERS = @V_LETTERS + SUBSTRING(@P_DEFAULT_VALUE,1,@V_INDEX)
            End
        SET @V_INDEX = @V_INDEX + 1;
    End

    SET @V_LENGTH1 = @V_LETTER_COUNTER + 1
    SET @V_LENGTH2 = LEN(@P_DEFAULT_VALUE) - @V_LETTER_COUNTER

    SET @V_SQL = 'SELECT @V_CODE= RIGHT(REPLICATE(''' + CAST(@V_DIGIT AS VARCHAR) + ''',' +  CAST(@V_LENGTH2 AS VARCHAR) + ') + CAST(MAX(SUBSTRING(' +  @P_PK_FIELD_NAME + ',' + CAST(@V_LENGTH1 AS VARCHAR) + ',' + CAST(LEN(@P_DEFAULT_VALUE) AS VARCHAR) + ')) + 1 AS VARCHAR),' + CAST(@V_LENGTH2 AS VARCHAR)  + ') FROM ' + @P_TABLE_NAME    
    EXECUTE sp_executesql @V_SQL, N'@V_CODE NVARCHAR(300) OUTPUT', @V_CODE OUTPUT
    
    IF @V_CODE IS NULL
        SET @V_CODE= @P_DEFAULT_VALUE;
    Else
        SET @V_CODE= LTRIM(RTRIM(@V_LETTERS)) + LTRIM(RTRIM(@V_CODE ));
End
GO

CREATE OR ALTER PROCEDURE SP_GENERATE_CODE_WITH_YEAR
       @P_DEFAULT_VALUE       VARCHAR(50),
       @P_TABLE_NAME          VARCHAR(50),
       @P_PK_FIELD_NAME       VARCHAR(50),
       @P_PK_FIELD_NAME_YEAR  VARCHAR(50),
       @V_CODE                NVARCHAR(300) OUTPUT
AS
BEGIN
    DECLARE
            @V_DIGIT           CHAR = '0',
            @V_SQL              NVARCHAR(MAX),
            @V_NUMBER_COUNTER INT = 0,
            @V_LETTER_COUNTER  INT = 0,
            @V_LENGTH1        INT = 0,
            @V_LENGTH2        INT = 0,
            @V_LETTERS           NVARCHAR(100) = '',
            @V_INDEX             INT = 1

    WHILE @V_INDEX < LEN(@P_DEFAULT_VALUE)
    BEGIN

        IF  ISNUMERIC(SUBSTRING(@P_DEFAULT_VALUE,1,@V_INDEX)) = 1
            BEGIN
                SET @V_NUMBER_COUNTER = @V_NUMBER_COUNTER + 1
            End
        Else
            BEGIN
                SET @V_LETTER_COUNTER = @V_LETTER_COUNTER + 1
                SET @V_LETTERS = @V_LETTERS + SUBSTRING(@P_DEFAULT_VALUE,1,@V_INDEX)
            End

        SET @V_INDEX = @V_INDEX + 1;
    End

    SET @V_LENGTH1 = @V_LETTER_COUNTER + 1
    SET @V_LENGTH2 = LEN(@P_DEFAULT_VALUE) - @V_LETTER_COUNTER

    SET @V_SQL = 'SELECT @V_CODE= RIGHT(REPLICATE(''' + CAST(@V_DIGIT AS VARCHAR) + ''',' +  CAST(@V_LENGTH2 AS VARCHAR) + ') + CAST(MAX(SUBSTRING(' +  @P_PK_FIELD_NAME + ',' + CAST(@V_LENGTH1 AS VARCHAR) + ',' + CAST(LEN(@P_DEFAULT_VALUE) AS VARCHAR) + ')) + 1 AS VARCHAR),' + CAST(@V_LENGTH2 AS VARCHAR)  + ') FROM ' + @P_TABLE_NAME + ' WHERE ' + @P_PK_FIELD_NAME_YEAR + ' = YEAR(SYSDATETIME()) '
    
    EXECUTE sp_executesql @V_SQL, N'@V_CODE NVARCHAR(300) OUTPUT', @V_CODE OUTPUT
   
    IF @V_CODE IS NULL
        SET @V_CODE= @P_DEFAULT_VALUE;
    Else
        SET @V_CODE= LTRIM(RTRIM(@V_LETTERS)) + LTRIM(RTRIM(@V_CODE ));
End
GO

CREATE OR ALTER PROCEDURE SP_REGISTER_LOG
                                            @P_LOGDES               VARCHAR  (3000),
                                            @P_LOGACT               VARCHAR  (100),
                                            @P_LOGIPMAC             VARCHAR  (15),
                                            @P_LOGCODREC            VARCHAR  (100),
                                            @P_LOGNAMTAB            VARCHAR  (100),
                                            @P_LOGSQL               VARCHAR  (MAX),
                                            @P_LOGTYP               CHAR     (5),
                                            @P_USEYEA               CHAR     (4),
                                            @P_USECOD               CHAR     (6),
                                            @P_USENAM               VARCHAR  (30),
                                            @P_USELAS               VARCHAR  (30),
                                            @P_MESSAGE_DESCRIPTION  NVARCHAR (MAX) OUTPUT,
                                            @P_MESSAGE_TYPE         CHAR     (1) OUTPUT,
                                            @P_LOGYEA               CHAR     (4) OUTPUT,
                                            @P_LOGCOD               CHAR     (10) OUTPUT
AS
BEGIN TRY
    DECLARE
            @V_SQL               NVARCHAR(MAX)  = '',
            @V_MSG_ERROR         NVARCHAR(MAX)  = '',
            @V_NAME_TABLE        NVARCHAR(100)  = 'TL_LOG',
            @V_CODE_GENERATE     NVARCHAR(10)   = '',
            @V_YEAR              CHAR(4)        = '',
            @V_VALIDATE           NVARCHAR(100)  = ''


            EXEC SP_GENERATE_CODE '0000000001', 'TL_LOG', 'LOGCOD', @V_CODE = @V_CODE_GENERATE OUTPUT

            SET @V_YEAR = YEAR(GETDATE())

            INSERT INTO TL_LOG
              (
                  LOGYEA,
                  LOGCOD,
                  LOGDES,
                  LOGACT,
                  LOGIPMAC,
                  LOGCODREC,
                  LOGNAMTAB,
                  LOGSQL,
                  LOGDATCRE,
                  LOGTYP,
                  USEYEA,
                  USECOD,
                  USENAM,
                  USELAS
              )
            Values
              (
                @V_YEAR,
                @V_CODE_GENERATE,
                LTRIM(RTRIM(UPPER(@P_LOGDES))),
                LTRIM(RTRIM(UPPER(@P_LOGACT))),
                LTRIM(RTRIM(UPPER(@P_LOGIPMAC))),
                LTRIM(RTRIM(UPPER(@P_LOGCODREC))),
                LTRIM(RTRIM(UPPER(@P_LOGNAMTAB))),
                LTRIM(RTRIM(UPPER(@P_LOGSQL))),
                SWITCHOFFSET(SYSDATETIME(), '-05:00'),
                LTRIM(RTRIM(UPPER(@P_LOGTYP))),
                LTRIM(RTRIM(UPPER(@P_USEYEA))),
                LTRIM(RTRIM(UPPER(@P_USECOD))),
                LTRIM(RTRIM(UPPER(@P_USENAM))),
                LTRIM(RTRIM(UPPER(@P_USELAS)))
              )

            SET @P_MESSAGE_DESCRIPTION  = 'El Registro se Insert� Correctamente'
            SET @P_MESSAGE_TYPE         = '3'
            
            SET @P_LOGYEA                =  @V_YEAR
            SET @P_LOGCOD                =  @V_CODE_GENERATE
END TRY
BEGIN CATCH
            SET @P_MESSAGE_DESCRIPTION  = ERROR_MESSAGE()
            SET @P_MESSAGE_TYPE         = '1'
END CATCH
GO

CREATE OR ALTER PROCEDURE SP_UPDATE_DATE_END_SQL
                                            @P_CODE_YEAR         CHAR     (4),
                                            @P_CODE              CHAR     (10),
                                            @P_SQL               NVARCHAR (MAX)
AS
BEGIN TRY
            UPDATE
                TL_LOG
            SET
                LOGSQL = LTRIM(RTRIM(UPPER(@P_SQL))),
                LOGDATEND = SWITCHOFFSET(SYSDATETIME(), '-05:00')
            WHERE
                LOGYEA = @P_CODE_YEAR AND
                LOGCOD = @P_CODE

END TRY
BEGIN CATCH

END CATCH
GO

CREATE OR ALTER PROCEDURE SP_GET_USER_TIMEZONE
    @P_USEYEA CHAR(4),
    @P_USECOD CHAR(6),
    @P_LOCOFFZON VARCHAR(6) OUTPUT,
    @P_LOCLOC VARCHAR(5) OUTPUT,
    @P_LOCNAMZON VARCHAR(50) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        @P_LOCOFFZON = ISNULL(LOC.LOCOFFZON, '-05:00'),
        @P_LOCLOC = ISNULL(LOC.LOCLOC, 'PE'),
        @P_LOCNAMZON = ISNULL(LOC.LOCNAMZON, 'AMERICA/LIMA')
    FROM TM_USER USR
    INNER JOIN TM_LOCATION LOC ON USR.LOCYEA = LOC.LOCYEA 
                                AND USR.LOCCOD = LOC.LOCCOD
    WHERE USR.USEYEA = @P_USEYEA 
      AND USR.USECOD = @P_USECOD
      AND USR.STAREC <> 'D';
END
GO