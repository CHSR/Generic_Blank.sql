SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelCIParticipant](@CIParticipantPK int)

AS


DELETE 
FROM CIParticipant
WHERE CIParticipantPK = @CIParticipantPK
GO
