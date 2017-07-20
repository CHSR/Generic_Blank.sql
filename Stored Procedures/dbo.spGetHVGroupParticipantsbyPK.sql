SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetHVGroupParticipantsbyPK]

(@HVGroupParticipantsPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM HVGroupParticipants
WHERE HVGroupParticipantsPK = @HVGroupParticipantsPK
GO
