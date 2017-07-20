SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelWorkerAssignment](@WorkerAssignmentPK int)

AS


DELETE 
FROM WorkerAssignment
WHERE WorkerAssignmentPK = @WorkerAssignmentPK
GO
