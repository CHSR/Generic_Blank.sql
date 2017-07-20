SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetWorkerAssignmentbyPK]

(@WorkerAssignmentPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM WorkerAssignment
WHERE WorkerAssignmentPK = @WorkerAssignmentPK
GO
