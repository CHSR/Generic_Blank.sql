SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE  [dbo].[spGetPreintakesbyHVCaseFK](
	@HVCaseFK INT,
	@ProgramFK INT = NULL
)

AS
BEGIN
	SET NOCOUNT ON;

    SELECT *
	FROM Preintake	
	WHERE HVCaseFK = @HVCaseFK
	AND ProgramFK = ISNULL(@ProgramFK, ProgramFK)
	ORDER BY PIDate DESC, CaseStatus DESC
	 
END
GO
