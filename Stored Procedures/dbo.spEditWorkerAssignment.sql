SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditWorkerAssignment](@WorkerAssignmentPK int=NULL,
@HVCaseFK int=NULL,
@ProgramFK int=NULL,
@WorkerAssignmentDate datetime=NULL,
@WorkerAssignmentEditor char(10)=NULL,
@WorkerFK int=NULL)
AS
UPDATE WorkerAssignment
SET 
HVCaseFK = @HVCaseFK, 
ProgramFK = @ProgramFK, 
WorkerAssignmentDate = @WorkerAssignmentDate, 
WorkerAssignmentEditor = @WorkerAssignmentEditor, 
WorkerFK = @WorkerFK
WHERE WorkerAssignmentPK = @WorkerAssignmentPK
GO
