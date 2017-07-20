SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE  [dbo].[spGetWorkerAssignmentbyHVCaseFK](
	@HVCaseFK INT,
	@ProgramFK INT = NULL
)

AS
BEGIN
	SET NOCOUNT ON;

    SELECT *
	FROM WorkerAssignment	
	WHERE HVCaseFK = @HVCaseFK
	AND ProgramFK = ISNULL(@ProgramFK, ProgramFK)
	 
END

GO
