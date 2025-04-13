ALTER PROCEDURE [dbo].[USP_Create_Trace_Log_Event]
	@max_file_size NVARCHAR(10),
	@max_rollover_files NVARCHAR(10),
	@FilterTime NVARCHAR(50) = NULL,
	@FilterText NVARCHAR(50) = NULL,
	@FilterDbName NVARCHAR(50) = NULL,
	@TrcName NVARCHAR(50)
AS
BEGIN
	EXEC sp_configure 'show advanced options', 1;
	RECONFIGURE;
	EXEC sp_configure 'xp_cmdshell', 1;
	RECONFIGURE;


DECLARE @FileName NVARCHAR(500) =  N''
DECLARE @DiskDrive NVARCHAR(5)
DECLARE @FilePath NVARCHAR(500)
DECLARE @Result TABLE (OutputText VARCHAR(255))
DECLARE @Command NVARCHAR(500)
DECLARE @WhereCluse NVARCHAR(500) = ''
IF @FilterTime IS NOT NULL
	BEGIN
		SET @WhereCluse += CASE WHEN @WhereCluse = ''
								THEN '([duration] > (' + @FilterTime + '))'
								ELSE 'And ' + '([duration] > (' + @FilterTime + '))'
								END
		SET @TrcName += '_'+@FilterTime
	END
      
IF @FilterText IS NOT NULL
	BEGIN
		SET @WhereCluse += CASE WHEN @WhereCluse = ''
								THEN '([sqlserver].[like_i_sql_unicode_string]([statement], N''' + @FilterText + '%''))'
								ELSE ' And ' + '([sqlserver].[like_i_sql_unicode_string]([statement], N''' + @FilterText + '%''))'
								END
	END

IF @FilterDbName IS NOT NULL
	BEGIN
		SET @WhereCluse += CASE WHEN @WhereCluse = ''
								THEN '([sqlserver].[like_i_sql_unicode_string]([sqlserver].[database_name], N''' + @FilterDbName + '''))'
								ELSE ' And ' + '([sqlserver].[like_i_sql_unicode_string]([sqlserver].[database_name], N''' + @FilterDbName + '''))'
								END

		SET @TrcName += '_'+@FilterDbName
	END

SET @TrcName += '_All'

SELECT @DiskDrive = DiskDrive
FROM (
		SELECT DISTINCT TOP(1)
				ovs.volume_mount_point AS DiskDrive,
				CAST(ovs.available_bytes AS BIGINT) / 1024 / 1024 / 1024 AS FreeSpaceGB
		FROM sys.master_files mf
		CROSS APPLY sys.dm_os_volume_stats(mf.database_id, mf.file_id) ovs
		ORDER BY FreeSpaceGB DESC
	) k

SET @FilePath = @DiskDrive + 'Tookatech';

SET @Command = 'IF EXIST "' + @FilePath + '" (ECHO 1)';
INSERT INTO @Result
EXEC xp_cmdshell @Command;

IF NOT EXISTS (SELECT 1 FROM @Result WHERE OutputText IS NOT NULL)
	BEGIN
		SET @Command = 'mkdir ' + @FilePath
		EXEC xp_cmdshell @Command
	END;


SET @FilePath = @FilePath + '\TRC_'+ CAST(CONVERT(DATE,GETDATE()) AS NVARCHAR)

SET @Command = 'IF EXIST "' + @FilePath + '" (ECHO 1)';
INSERT INTO @Result
EXEC xp_cmdshell @Command;

IF NOT EXISTS (SELECT 1 FROM @Result WHERE OutputText IS NOT NULL)
	BEGIN
		SET @Command = 'mkdir ' + @FilePath
		EXEC xp_cmdshell @Command
	END;


PRINT @FilePath;
SET @FileName += @TrcName
SET @FileName = @FilePath +'\' + @FileName
IF NOT EXISTS (SELECT 1 FROM sys.server_event_sessions WHERE name = @TrcName)
	BEGIN
		DECLARE @STR1 NVARCHAR(MAX) = N'
			CREATE EVENT SESSION '+ @TrcName + '
			ON SERVER
				ADD EVENT sqlserver.rpc_completed
				(SET
					 collect_statement = (1)
				 ACTION(sqlserver.database_name,sqlos.task_time)
				 ' + CASE WHEN LEN(@WhereCluse) > 0 THEN 'Where (' + @WhereCluse + ')' ELSE N'' END + N')
				 ADD TARGET package0.event_file
				(
					SET filename = '''+@FileName+''',
					max_file_size = '+@max_file_size+',
					max_rollover_files = '+@max_rollover_files+'
				)
			WITH(
					MAX_MEMORY = 4096KB,
					EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS,
					MAX_DISPATCH_LATENCY = 30 SECONDS,
					MAX_EVENT_SIZE = 0KB,
					MEMORY_PARTITION_MODE = NONE,
					TRACK_CAUSALITY = OFF,
					STARTUP_STATE = ON
				)'
				PRINT @STR1
	EXEC (@STR1);
	END;
IF NOT EXISTS (SELECT 1 FROM sys.dm_xe_sessions WHERE name = @TrcName)
	BEGIN
		SET @STR1 = ''
		SET @STR1 = 'ALTER EVENT SESSION ' + @TrcName + ' ON SERVER STATE = START;'
		EXEC (@STR1)		
	END
END