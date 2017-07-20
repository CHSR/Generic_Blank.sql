SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE  [dbo].[spGetPreassessmentsbyHVCaseFK](
	@HVCaseFK INT,
	@ProgramFK INT = NULL
)

AS
BEGIN
	SET NOCOUNT ON;

    SELECT *
	FROM Preassessment	
	WHERE HVCaseFK = @HVCaseFK
	AND ProgramFK = ISNULL(@ProgramFK, ProgramFK)
	ORDER BY PADate DESC, CaseStatus DESC
	 
END
GO
