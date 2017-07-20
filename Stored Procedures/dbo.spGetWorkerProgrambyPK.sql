SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetWorkerProgrambyPK]

(@WorkerProgramPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM WorkerProgram
WHERE WorkerProgramPK = @WorkerProgramPK
GO
