SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditTrainingAttendee_old](@TrainingAttendee_oldPK int=NULL,
@ExemptDescription varchar(500)=NULL,
@ExemptType char(2)=NULL,
@IsExempt bit=NULL,
@ProgramFK int=NULL,
@SubtopicFK int=NULL,
@TopicFK int=NULL,
@TrainingAttendeeEditor char(10)=NULL,
@TrainingAttendeePK_old int=NULL,
@TrainingFK int=NULL,
@WorkerFK int=NULL)
AS
UPDATE TrainingAttendee_old
SET 
ExemptDescription = @ExemptDescription, 
ExemptType = @ExemptType, 
IsExempt = @IsExempt, 
ProgramFK = @ProgramFK, 
SubtopicFK = @SubtopicFK, 
TopicFK = @TopicFK, 
TrainingAttendeeEditor = @TrainingAttendeeEditor, 
TrainingAttendeePK_old = @TrainingAttendeePK_old, 
TrainingFK = @TrainingFK, 
WorkerFK = @WorkerFK
WHERE TrainingAttendee_oldPK = @TrainingAttendee_oldPK
GO
