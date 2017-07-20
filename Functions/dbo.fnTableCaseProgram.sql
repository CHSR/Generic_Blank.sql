SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fnTableCaseProgram](@ProgramFK INT = NULL) RETURNS TABLE 
AS 
-- Objective: To return sub set of the table i.e. CaseProgram given ProgramFK
-- Devinder Singh Khalsa, 05/11/2012
RETURN 
(

	SELECT * FROM caseprogram cp
	WHERE cp.ProgramFK = ISNULL(@ProgramFK, cp.ProgramFK)
	

)
GO
