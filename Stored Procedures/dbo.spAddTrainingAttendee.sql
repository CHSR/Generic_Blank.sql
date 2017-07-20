SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddTrainingAttendee](@TrainingAttendeeCreator nvarchar(50)=NULL,
@TrainingFK int=NULL,
@WorkerFK int=NULL)
AS
INSERT INTO TrainingAttendee(
TrainingAttendeeCreator,
TrainingFK,
WorkerFK
)
VALUES(
@TrainingAttendeeCreator,
@TrainingFK,
@WorkerFK
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
