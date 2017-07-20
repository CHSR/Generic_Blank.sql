SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- pr_Disable_Triggers_v2 0

CREATE procedure [dbo].[pr_Disable_Triggers] @disable bit = 1, @tableNames nvarchar(max)
as
	declare @sql         varchar(500),
            @tableName   varchar(128),
            @tableSchema varchar(128)

	if @tableNames='' or @tableNames is null
		-- List of all tables
		begin
			declare triggerCursor cursor
			for
			select t.TABLE_NAME as TableName
				  ,t.TABLE_SCHEMA as TableSchema
				from INFORMATION_SCHEMA.TABLES t
				where TABLE_TYPE<>'VIEW'
				order by t.TABLE_NAME
						,t.TABLE_SCHEMA
		end
	else
		-- only the passed table names
		begin
			declare triggerCursor cursor
			for
			select t.TABLE_NAME as TableName
				  ,t.TABLE_SCHEMA as TableSchema
				from INFORMATION_SCHEMA.TABLES t
				inner join dbo.SplitString(@tableNames,',') on t.TABLE_NAME = listitem
				where TABLE_TYPE<>'VIEW'
				order by t.TABLE_NAME
						,t.TABLE_SCHEMA
		end
		
	open triggerCursor

	fetch next from triggerCursor into @tableName,@tableSchema
	while (@@FETCH_STATUS = 0)
	begin
		if @disable = 1
			set @sql = 'ALTER TABLE '+@tableSchema+'.['+@tableName+'] DISABLE TRIGGER ALL'
		else
			set @sql = 'ALTER TABLE '+@tableSchema+'.['+@tableName+'] ENABLE TRIGGER ALL'
		print 'Executing Statement - '+@sql
		execute (@sql)
		fetch next from triggerCursor into @tableName,@tableSchema
	end

	close triggerCursor
	deallocate triggerCursor
GO
