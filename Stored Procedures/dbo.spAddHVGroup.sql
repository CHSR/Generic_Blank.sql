SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddHVGroup](@ActivityTopic varchar(500)=NULL,
@FAModerator1 int=NULL,
@FAModerator2 int=NULL,
@GroupCreator char(10)=NULL,
@GroupDate datetime=NULL,
@GroupLengthHours int=NULL,
@GroupLengthMinutes int=NULL,
@GroupTime datetime=NULL,
@GroupTitle varchar(500)=NULL,
@HVGroupPK_old int=NULL,
@NumberParticipating int=NULL,
@ProgramFK int=NULL)
AS
INSERT INTO HVGroup(
ActivityTopic,
FAModerator1,
FAModerator2,
GroupCreator,
GroupDate,
GroupLengthHours,
GroupLengthMinutes,
GroupTime,
GroupTitle,
HVGroupPK_old,
NumberParticipating,
ProgramFK
)
VALUES(
@ActivityTopic,
@FAModerator1,
@FAModerator2,
@GroupCreator,
@GroupDate,
@GroupLengthHours,
@GroupLengthMinutes,
@GroupTime,
@GroupTitle,
@HVGroupPK_old,
@NumberParticipating,
@ProgramFK
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
