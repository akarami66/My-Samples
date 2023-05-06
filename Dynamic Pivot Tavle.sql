IF EXISTS
(
    SELECT [name]
    FROM tempdb.sys.tables
    WHERE [name] LIKE '##TMPBookletBalance%'
)
BEGIN
    DROP TABLE ##TMPBookletBalance;
    DROP TABLE ##TMPBookletBalance2;
END;

DECLARE 
        @cols AS NVARCHAR(MAX),
        @query AS NVARCHAR(MAX),
		@selectCols AS NVARCHAR(MAX),
        @finalQuery AS NVARCHAR(MAX);


SELECT  @selectCols = STUFF
(
(
SELECT  ', ISNULL(' + QUOTENAME(BookletTitle) + ', 0) AS ' + QUOTENAME(BookletTitle)
    FROM dbo.FactInpersonStudent_booklet
	WHERE ExamID = @ExamID
    GROUP BY BookletTitle
    ORDER BY BookletTitle
    FOR XML PATH(''), TYPE
).value('.', 'NVARCHAR(MAX)'),
1   ,
1   ,
''
                    );
SELECT @cols = STUFF(
(
    SELECT ','  + QUOTENAME(BookletTitle)
    FROM dbo.FactInpersonStudent_booklet
	WHERE ExamID = @ExamID
    GROUP BY BookletTitle
    ORDER BY BookletTitle
    FOR XML PATH(''), TYPE
).value('.', 'NVARCHAR(MAX)'),
1   ,
1   ,
''
                    );

SET @query
    = N'SELECT StudentID,' + @selectCols
      + N' into ##TMPBookletBalance from 
             (
                SELECT StudentID,TotalBalanceBooklet,BookletTitle FROM dbo.FactInpersonStudent_booklet  WHERE ExamID = '
      + CAST(@ExamID AS NVARCHAR(50))
      + N' 
            ) x 
            pivot 
            (
                sum(TotalBalanceBooklet)
                for BookletTitle in (' + @cols + N')
            ) p ';

EXECUTE (@query);
--SELECT * FROM ##TMPBookletBalance

SELECT @finalQuery  = ISNULL(@finalQuery  + ')' + '+'',''+ ', '') + CHAR(39) + c.name + ':' + CHAR(39) + N' + convert(nvarchar(100), ' + isnull (c.name,0)
FROM tempdb.sys.columns c
WHERE object_id = OBJECT_ID('tempdb..##TMPBookletBalance');

EXEC ('SELECT StudentID,'' ''+' + @finalQuery  + ')+' + ''' '' as BookletBalance into ##TMPBookletBalance2 FROM ##TMPBookletBalance');
