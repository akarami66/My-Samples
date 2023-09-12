SELECT c1.TABLE_NAME,
       c1.COLUMN_NAME,
       c1.IS_NULLABLE,
       c1.DATA_TYPE + ' '
       + CASE
             WHEN c1.DATA_TYPE = 'sql_variant' THEN
             (
                 SELECT '(' + CAST(c.CHARACTER_MAXIMUM_LENGTH AS NVARCHAR(200)) + ')'
                 FROM INFORMATION_SCHEMA.COLUMNS AS c
                 WHERE c.TABLE_NAME = c1.TABLE_NAME
                       AND c.COLUMN_NAME = c1.COLUMN_NAME
             )
             WHEN c1.DATA_TYPE = 'money' THEN
             (
                 SELECT '(' + CAST(c.NUMERIC_PRECISION AS NVARCHAR(200)) + ',' + CAST(c.NUMERIC_SCALE AS NVARCHAR(200))
                        + ')'
                 FROM INFORMATION_SCHEMA.COLUMNS AS c
                 WHERE c.TABLE_NAME = c1.TABLE_NAME
                       AND c.COLUMN_NAME = c1.COLUMN_NAME
             )
             WHEN c1.DATA_TYPE = 'int' THEN
                 ''
             WHEN c1.DATA_TYPE = 'decimal' THEN
             (
                 SELECT '(' + CAST(c.NUMERIC_PRECISION AS NVARCHAR(200)) + ',' + CAST(c.NUMERIC_SCALE AS NVARCHAR(200))
                        + ')'
                 FROM INFORMATION_SCHEMA.COLUMNS AS c
                 WHERE c.TABLE_NAME = c1.TABLE_NAME
                       AND c.COLUMN_NAME = c1.COLUMN_NAME
             )
             WHEN c1.DATA_TYPE = 'varbinary' THEN
             (
                 SELECT '(' + REPLACE(CAST(c.CHARACTER_MAXIMUM_LENGTH AS NVARCHAR(200)), -1, 'MAX') + ')'
                 FROM INFORMATION_SCHEMA.COLUMNS AS c
                 WHERE c.TABLE_NAME = c1.TABLE_NAME
                       AND c.COLUMN_NAME = c1.COLUMN_NAME
             )
             WHEN c1.DATA_TYPE = 'smallint' THEN
                 ''
             WHEN c1.DATA_TYPE = 'varchar' THEN
             (
                 SELECT '(' + CAST(c.CHARACTER_MAXIMUM_LENGTH AS NVARCHAR(200)) + ')'
                 FROM INFORMATION_SCHEMA.COLUMNS AS c
                 WHERE c.TABLE_NAME = c1.TABLE_NAME
                       AND c.COLUMN_NAME = c1.COLUMN_NAME
             )
             WHEN c1.DATA_TYPE = 'datetime' THEN
                 ''
             WHEN c1.DATA_TYPE = 'numeric' THEN
             (
                 SELECT '(' + CAST(c.NUMERIC_PRECISION AS NVARCHAR(200)) + ',' + CAST(c.NUMERIC_SCALE AS NVARCHAR(200))
                        + ')'
                 FROM INFORMATION_SCHEMA.COLUMNS AS c
                 WHERE c.TABLE_NAME = c1.TABLE_NAME
                       AND c.COLUMN_NAME = c1.COLUMN_NAME
             )
             WHEN c1.DATA_TYPE = 'uniqueidentifier' THEN
                 ''
             WHEN c1.DATA_TYPE = 'tinyint' THEN
                 ''
             WHEN c1.DATA_TYPE = 'nchar' THEN
             (
                 SELECT '(' + CAST(c.CHARACTER_MAXIMUM_LENGTH AS NVARCHAR(200)) + ')'
                 FROM INFORMATION_SCHEMA.COLUMNS AS c
                 WHERE c.TABLE_NAME = c1.TABLE_NAME
                       AND c.COLUMN_NAME = c1.COLUMN_NAME
             )
             WHEN c1.DATA_TYPE = 'smalldatetime' THEN
                 ''
             WHEN c1.DATA_TYPE = 'float' THEN
                 ''
             WHEN c1.DATA_TYPE = 'date' THEN
                 ''
             WHEN c1.DATA_TYPE = 'char' THEN
             (
                 SELECT '(' + REPLACE(CAST(c.CHARACTER_MAXIMUM_LENGTH AS NVARCHAR(200)), -1, 'MAX') + ')'
                 FROM INFORMATION_SCHEMA.COLUMNS AS c
                 WHERE c.TABLE_NAME = c1.TABLE_NAME
                       AND c.COLUMN_NAME = c1.COLUMN_NAME
             )
             WHEN c1.DATA_TYPE = 'real' THEN
             (
                 SELECT '(' + CAST(c.NUMERIC_PRECISION AS NVARCHAR(200)) + ','
                        + CAST(c.NUMERIC_PRECISION_RADIX AS NVARCHAR(200)) + ')'
                 FROM INFORMATION_SCHEMA.COLUMNS AS c
                 WHERE c.TABLE_NAME = c1.TABLE_NAME
                       AND c.COLUMN_NAME = c1.COLUMN_NAME
             )
             WHEN c1.DATA_TYPE = 'bigint' THEN
                 ''
             WHEN c1.DATA_TYPE = 'nvarchar' THEN
             (
                 SELECT '(' + REPLACE(CAST(c.CHARACTER_MAXIMUM_LENGTH AS NVARCHAR(200)), -1, 'MAX') + ')'
                 FROM INFORMATION_SCHEMA.COLUMNS AS c
                 WHERE c.TABLE_NAME = c1.TABLE_NAME
                       AND c.COLUMN_NAME = c1.COLUMN_NAME
             )
             WHEN c1.DATA_TYPE = 'bit' THEN
                 ''
         END AS DATA_TYPE,
       --c1.NUMERIC_PRECISION,
       --c1.NUMERIC_PRECISION_RADIX,
       --c1.NUMERIC_SCALE,
       --c1.CHARACTER_MAXIMUM_LENGTH,
       '' AS 'TableDescribtion',
       '' AS 'ColumnDescribtion',
       '' AS 'Edit1',
       '' AS 'Edit2',
       '' AS 'Edit3'
FROM INFORMATION_SCHEMA.COLUMNS AS c1
    JOIN INFORMATION_SCHEMA.TABLES AS t
        ON t.TABLE_NAME = c1.TABLE_NAME
           AND t.TABLE_TYPE = 'BASE TABLE'
ORDER BY c1.TABLE_NAME,
         c1.COLUMN_NAME,
         c1.DATA_TYPE;
