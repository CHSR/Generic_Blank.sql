SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetCriticalIncidentbyPK]

(@CriticalIncidentPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM CriticalIncident
WHERE CriticalIncidentPK = @CriticalIncidentPK
GO
