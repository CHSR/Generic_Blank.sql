SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddWorkerAssignment](@HVCaseFK int=NULL,
@ProgramFK int=NULL,
@WorkerAssignmentCreator char(10)=NULL,
@WorkerAssignmentDate datetime=NULL,
@WorkerFK int=NULL)
AS
INSERT INTO WorkerAssignment(
HVCaseFK,
ProgramFK,
WorkerAssignmentCreator,
WorkerAssignmentDate,
WorkerFK
)
VALUES(
@HVCaseFK,
@ProgramFK,
@WorkerAssignmentCreator,
@WorkerAssignmentDate,
@WorkerFK
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
