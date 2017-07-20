SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[spGetWorkerProgrambyWorkerFK](@WorkerFK int,@ProgramFK int)  

AS

BEGIN
	SET NOCOUNT ON;

	SELECT *
	FROM [dbo].[WorkerProgram]
	WHERE WorkerFK = @WorkerFK 
	AND ProgramFK = @ProgramFK

END

GO
