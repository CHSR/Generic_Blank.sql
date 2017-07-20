SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: Aug. 15, 2012
-- Description:	Returns 1 if site is doing form reviews for the form, 0 if not (used by FormReviewedTableList table function)
-- =============================================
CREATE FUNCTION [dbo].[FormReviewReady]	
(
	-- Add the parameters for the function here
	@formtype varchar(2),
	@prog INT	
)
returns bit
AS
BEGIN
	-- Declare the return variable here
	DECLARE @ReturnValue Bit

	-- Add the T-SQL statements to compute the return value here
	set @ReturnValue = Case (SELECT FormReviewOptionsPK FROM FormReviewOptions fro WHERE ProgramFK=@prog AND FormType=@formtype) 
		WHEN NULL THEN 1 
		ELSE 0 
		END

	-- Return the result of the function
	RETURN @ReturnValue

END
GO
