SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelHVGroupParticipants](@HVGroupParticipantsPK int)

AS


DELETE 
FROM HVGroupParticipants
WHERE HVGroupParticipantsPK = @HVGroupParticipantsPK
GO
