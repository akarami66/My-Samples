IF NOT EXISTS (SELECT 1
			   FROM     sys.indexes ix
			       JOIN sys.objects obj ON obj.[object_id] = ix.[object_id]
			       JOIN sys.index_columns ixc ON ixc.index_id = ix.index_id
											 AND ixc.[object_id] = ix.[object_id]
			       JOIN sys.columns c ON c.column_id = ixc.column_id
								     AND c.[object_id] = ix.[object_id]
			   WHERE     ix.[name] = 'UIX_FK_AccDocRow_Bill_LocalId'
			         AND ixc.is_included_column = 1
			         AND c.[name] = 'T1Id')
BEGIN
	IF EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = 'UIX_FK_AccDocRow_Bill_LocalId')
		EXEC(N'DROP INDEX [UIX_FK_AccDocRow_Bill_LocalId] ON [dbo].[ACC_AccDocRow]')
	;
	DECLARE @InsexStrEnd NVARCHAR(MAX) = 
		CASE 
			WHEN EXISTS (SELECT 1 FROM sys.filegroups WHERE [Name] = 'INDEXES_Doc') THEN ' ON [INDEXES_Doc]'
			WHEN EXISTS (SELECT 1 FROM sys.filegroups WHERE [Name] = 'INDEXES') THEN ' ON [INDEXES]' 
			ELSE '' 
		END

	EXEC(N'CREATE NONCLUSTERED INDEX [UIX_FK_AccDocRow_Bill_LocalId]
	ON [dbo].[ACC_AccDocRow]
	(
		[Bill_LocalId] ASC,
		[DId] ASC
	)
	INCLUDE
	(
		[RowNo],
		[T1Id]
	) 
	' + @InsexStrEnd)
END