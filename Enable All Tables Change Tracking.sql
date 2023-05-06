SET NOCOUNT ON;
GO

-- Is CHANGE TRACKING enabled at database level ?
IF CONVERT(INT, PARSENAME(CONVERT(NVARCHAR(128), SERVERPROPERTY('ProductVersion')), 4)) >= 10 -- 10 = SQL2008
BEGIN
    EXEC sp_executesql N'SELECT * FROM sys.change_tracking_databases db WHERE db.database_id = DB_ID(); ';
    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('CHANGE TRACKING is not enabled at database level.', 16, 1);
        RETURN;
    END;
END;

-- It generates the final T-SQL script
SELECT -- N'PRINT ''Enable CHANGE_TRACKING on ' + full_table_name + ''';'+ CHAR(13) + N'GO'+ CHAR(13) +
    N'ALTER TABLE ' + full_table_name + N' ENABLE CHANGE_TRACKING' + CHAR(13) + CHAR(10) + N'GO'
FROM
(
    SELECT QUOTENAME(s.name) + '.' + QUOTENAME(t.name) AS full_table_name,
           s.name AS schema_name,
           t.name AS table_name
    FROM sys.key_constraints x
        JOIN sys.tables t
            ON x.parent_object_id = t.object_id
        JOIN sys.schemas s
            ON t.schema_id = s.schema_id
    WHERE x.[type] = 'PK'
) y
ORDER BY schema_name,
         table_name;