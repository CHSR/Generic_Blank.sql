SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		jrobohn
-- Create date: June 21, 2014
-- Description:	return stored procs and functions 
--				modified with the last <n> days	
-- exec pr_GetLatestStoredProcs @CutoffDays = 100 -- int
-- =============================================
CREATE procedure [dbo].[pr_GetLatestStoredProcs] (@CutoffDays int)
as
begin
	if @CutoffDays is null 
	begin
       set @CutoffDays = -5
    end
	else if @CutoffDays > 0
	begin
		set @CutoffDays = @CutoffDays * -1
	end

	declare @CutoffDate date = DATEADD(dd, @CutoffDays, CURRENT_TIMESTAMP)
	
	select object_schema_name([object_id]) as SchemaName
		  , name
		  , create_date
		  , modify_date
		  , 'StoredProc                  ' as type
		from sys.procedures
		where modify_date >= @CutoffDate
	union all
	select object_schema_name([object_id])
		  , name
		  , create_date
		  , modify_date
		  , case when type = 'FN' then 'Scalar Function'
				when type = 'IF' then 'Inline Table-valued Function' 
				when type = 'TF' then 'Table-valued Function' 
			end as type
	from sys.objects
	where type IN ('FN', 'IF', 'TF')  -- scalar, inline table-valued, table-valued
			and modify_date >= @CutoffDate
	order by modify_date desc;
end
GO
