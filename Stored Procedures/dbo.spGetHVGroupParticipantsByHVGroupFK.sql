SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[spGetHVGroupParticipantsByHVGroupFK]
	@HVGroupFK  int = null
    
as
set nocount on

select rtrim(c.PCLastName) + ', ' + rtrim(c.PCFirstName) + ' (' + rtrim(a.RoleType) + ')' [name]
, b.PC1ID [pc1id] , a.RoleType [type], a.PCFK [pcfk], a.HVCaseFK [hvcasefk]
, a.HVGroupParticipantsPK
FROM HVGroupParticipants AS a
JOIN CaseProgram AS b ON a.HVCaseFK = b.HVCaseFK
JOIN PC AS c ON c.PCPK = a.PCFK
WHERE a.HVGroupFK = @HVGroupFK
ORDER BY name


GO
