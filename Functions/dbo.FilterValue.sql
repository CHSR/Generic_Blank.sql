SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jay Robohn
-- Create date: July 10, 2012
-- Description:	Converts various case filter options into a text string
-- =============================================
CREATE function [dbo].[FilterValue] ( @FilterType int, @FilterChoice bit, @FilterNameOptionFK int, @FilterValue varchar(100))
returns varchar(100)
as
begin
	-- Declare the return variable here
	declare @ReturnString as varchar(100)

	-- Add the T-SQL statements to compute the return value here
	set @ReturnString = 
		case 
			when @FilterType = 1 then case when @FilterChoice = 1 then 'Yes' else 'No' end
			when @FilterType = 2 
				then (select cfno.FilterOption from listCaseFilterNameOption cfno where listCaseFilterNameOptionPK=@FilterNameOptionFK)
			when @FilterType = 3
				then @FilterValue
		end
	
-- Return the result of the function
return @ReturnString

end
GO
