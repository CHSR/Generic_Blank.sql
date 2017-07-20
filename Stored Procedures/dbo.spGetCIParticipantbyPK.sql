SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetCIParticipantbyPK]

(@CIParticipantPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM CIParticipant
WHERE CIParticipantPK = @CIParticipantPK
GO
