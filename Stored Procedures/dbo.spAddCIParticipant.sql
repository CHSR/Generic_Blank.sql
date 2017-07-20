SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddCIParticipant](@CIFollowUpFK int=NULL,
@CIParticipantCreator char(10)=NULL,
@CIParticipantName varchar(200)=NULL,
@CIParticipantType char(2)=NULL,
@CriticalIncidentFK int=NULL)
AS
INSERT INTO CIParticipant(
CIFollowUpFK,
CIParticipantCreator,
CIParticipantName,
CIParticipantType,
CriticalIncidentFK
)
VALUES(
@CIFollowUpFK,
@CIParticipantCreator,
@CIParticipantName,
@CIParticipantType,
@CriticalIncidentFK
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
