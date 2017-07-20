SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditCIParticipant](@CIParticipantPK int=NULL,
@CIFollowUpFK int=NULL,
@CIParticipantEditor char(10)=NULL,
@CIParticipantName varchar(200)=NULL,
@CIParticipantType char(2)=NULL,
@CriticalIncidentFK int=NULL)
AS
UPDATE CIParticipant
SET 
CIFollowUpFK = @CIFollowUpFK, 
CIParticipantEditor = @CIParticipantEditor, 
CIParticipantName = @CIParticipantName, 
CIParticipantType = @CIParticipantType, 
CriticalIncidentFK = @CriticalIncidentFK
WHERE CIParticipantPK = @CIParticipantPK
GO
