SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Function:	IsNullOrEmpty
-- Author:		jrobohn
-- Create date: July 20, 2012
-- Description:	Mimics the VB/.NET function of the same name
-- =============================================
CREATE function [dbo].[IsNullOrEmpty]
(-- Add the parameters for the function here
    @VarString varchar(max)
)
returns bit
as
begin
	-- Declare the return variable here
	declare @ReturnValue bit

	-- Add the T-SQL statements to compute the return value here
	set @ReturnValue = case when @VarString is null or @VarString = '' then 1 else 0 end

	-- Return the result of the function
	return @ReturnValue

end
GO
