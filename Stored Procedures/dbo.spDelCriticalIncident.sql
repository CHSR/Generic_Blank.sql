SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelCriticalIncident](@CriticalIncidentPK int)

AS


DELETE 
FROM CriticalIncident
WHERE CriticalIncidentPK = @CriticalIncidentPK
GO
