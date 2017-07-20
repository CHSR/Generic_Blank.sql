SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelWorkerProgram](@WorkerProgramPK int)

AS


DELETE 
FROM WorkerProgram
WHERE WorkerProgramPK = @WorkerProgramPK
GO
