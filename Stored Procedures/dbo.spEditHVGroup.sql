SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditHVGroup](@HVGroupPK int=NULL,
@ActivityTopic varchar(500)=NULL,
@FAModerator1 int=NULL,
@FAModerator2 int=NULL,
@GroupDate datetime=NULL,
@GroupEditor char(10)=NULL,
@GroupLengthHours int=NULL,
@GroupLengthMinutes int=NULL,
@GroupTime datetime=NULL,
@GroupTitle varchar(500)=NULL,
@HVGroupPK_old int=NULL,
@NumberParticipating int=NULL,
@ProgramFK int=NULL)
AS
UPDATE HVGroup
SET 
ActivityTopic = @ActivityTopic, 
FAModerator1 = @FAModerator1, 
FAModerator2 = @FAModerator2, 
GroupDate = @GroupDate, 
GroupEditor = @GroupEditor, 
GroupLengthHours = @GroupLengthHours, 
GroupLengthMinutes = @GroupLengthMinutes, 
GroupTime = @GroupTime, 
GroupTitle = @GroupTitle, 
HVGroupPK_old = @HVGroupPK_old, 
NumberParticipating = @NumberParticipating, 
ProgramFK = @ProgramFK
WHERE HVGroupPK = @HVGroupPK
GO
