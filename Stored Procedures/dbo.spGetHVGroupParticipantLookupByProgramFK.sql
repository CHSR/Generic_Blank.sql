SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[spGetHVGroupParticipantLookupByProgramFK]
	@programfk  int = NULL,
	@groupDate DATE = NULL
    
as
set nocount ON

--DECLARE @programfk  INT = 12

;with
all_case
AS
(
SELECT b.PC1ID, b.HVCaseFK, a.PC1FK AS [PC1], a.PC2FK AS [PC2], a.OBPFK AS [OBP], c.PCFK AS [FF]
FROM HVCase AS a
JOIN CaseProgram AS b ON a.HVCasePK = b.HVCaseFK
LEFT OUTER JOIN FatherFigure AS c ON c.HVCaseFK = a.HVCasePK AND 
(c.DateInactive IS NULL OR c.DateInactive > getdate())
WHERE b.ProgramFK = @programfk AND a.IntakeDate IS NOT NULL 
AND (b.DischargeDate IS NULL OR b.DischargeDate > isnull(@groupDate, getdate()))
)

, pc1 AS
(
SELECT a.PC1ID, a.HVCaseFK, b.PCLastName, b.PCFirstName, 'PC1' AS [type], b.PCPK
FROM all_case AS a
JOIN PC AS b ON b.PCPK = a.PC1
)

, pc2 AS
(
SELECT a.PC1ID, a.HVCaseFK, b.PCLastName, b.PCFirstName, 'PC2' AS [type], b.PCPK
FROM all_case AS a
JOIN PC AS b ON b.PCPK = a.PC2
)
, obp AS
(
SELECT a.PC1ID, a.HVCaseFK, b.PCLastName, b.PCFirstName, 'OBP' AS [type], b.PCPK
FROM all_case AS a
JOIN PC AS b ON b.PCPK = a.obp
)

, ff AS
(
SELECT a.PC1ID, a.HVCaseFK, b.PCLastName, b.PCFirstName, 'FF' AS [type], b.PCPK
FROM all_case AS a
JOIN PC AS b ON b.PCPK = a.ff
)
, xx AS
(
  SELECT * FROM pc1
  UNION
  SELECT * FROM pc2
  UNION 
  SELECT * FROM obp
  UNION
  SELECT * FROM ff
)

SELECT rtrim(PCLastName) + ', ' + rtrim(PCFirstName) + ' (' + type + ')' [name]
,PC1ID [pc1id] ,type, PCPK [pcfk], HVCaseFK [hvcasefk] FROM xx
ORDER BY name
GO
