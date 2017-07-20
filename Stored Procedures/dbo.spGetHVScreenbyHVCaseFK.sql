SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE  [dbo].[spGetHVScreenbyHVCaseFK](
	@HVCaseFK INT,
	@ProgramFK INT = NULL
)

AS
BEGIN
	SET NOCOUNT ON;

    SELECT *
	FROM HVScreen	
	WHERE HVCaseFK = @HVCaseFK
	AND ProgramFK = ISNULL(@ProgramFK, ProgramFK)
	 
END
GO
