SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[pr_Disable_Foreign_Keys] @disable bit = 1, @tableNames nvarchar(max)
as
	declare @sql            varchar(500),
            @tableName      varchar(128),
            @foreignKeyName varchar(128)

	if @tableNames='' or @tableNames is null
		-- A list of all of the Foreign Keys and the table names
		begin
			declare foreignKeyCursor cursor
			for
			select ref.constraint_name as FK_Name
				  ,fk.table_name as FK_Table
				from INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS ref
					inner join INFORMATION_SCHEMA.TABLE_CONSTRAINTS fk on ref.constraint_name = fk.constraint_name
				order by fk.table_name
						,ref.constraint_name
		end
	else
		-- only the Foriegn keys from the passed table names
		begin
			declare foreignKeyCursor cursor
			for
			select ref.constraint_name as FK_Name
				  ,fk.table_name as FK_Table
				from INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS ref
					inner join INFORMATION_SCHEMA.TABLE_CONSTRAINTS fk on ref.constraint_name = fk.constraint_name
				inner join dbo.SplitString(@tableNames,',') on fk.TABLE_NAME = listitem
				order by fk.table_name
						,ref.constraint_name
		end

	open foreignKeyCursor

	fetch next from foreignKeyCursor into @foreignKeyName,@tableName
	while (@@FETCH_STATUS = 0)
	begin
		if @disable = 1
			set @sql = 'ALTER TABLE ['+@tableName+'] NOCHECK CONSTRAINT ['+@foreignKeyName+']'
		else
			set @sql = 'ALTER TABLE ['+@tableName+'] CHECK CONSTRAINT ['+@foreignKeyName+']'
		print 'Executing Statement - '+@sql
		execute (@sql)
		fetch next from foreignKeyCursor into @foreignKeyName,@tableName
	end

	close foreignKeyCursor

	deallocate foreignKeyCursor
GO
