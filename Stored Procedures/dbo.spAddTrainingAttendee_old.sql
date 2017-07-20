SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddTrainingAttendee_old](@ExemptDescription varchar(500)=NULL,
@ExemptType char(2)=NULL,
@IsExempt bit=NULL,
@ProgramFK int=NULL,
@SubtopicFK int=NULL,
@TopicFK int=NULL,
@TrainingAttendeeCreator char(10)=NULL,
@TrainingAttendeePK_old int=NULL,
@TrainingFK int=NULL,
@WorkerFK int=NULL)
AS
INSERT INTO TrainingAttendee_old(
ExemptDescription,
ExemptType,
IsExempt,
ProgramFK,
SubtopicFK,
TopicFK,
TrainingAttendeeCreator,
TrainingAttendeePK_old,
TrainingFK,
WorkerFK
)
VALUES(
@ExemptDescription,
@ExemptType,
@IsExempt,
@ProgramFK,
@SubtopicFK,
@TopicFK,
@TrainingAttendeeCreator,
@TrainingAttendeePK_old,
@TrainingFK,
@WorkerFK
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
