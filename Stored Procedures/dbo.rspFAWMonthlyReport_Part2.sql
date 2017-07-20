SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Dar Chen
-- Create date: 06/18/2010
-- Description:	FAW Monthly Report
-- =============================================
CREATE PROCEDURE [dbo].[rspFAWMonthlyReport_Part2] 
	-- Add the parameters for the stored procedure here
	@programfk INT = NULL, 
	@StartDt datetime,
	@EndDt datetime
AS

--DECLARE @StartDt DATE = '01/01/2012'
--DECLARE @EndDt DATE = '01/31/2012'
--DECLARE @programfk INT = 6

SELECT rtrim(w.LastName) + ', ' + rtrim(w.FirstName) [workerName]
, [FAWFK]
, isnull([AssignThisMonth],0) [AssignThisMonth]
, isnull([CaseAtBeginning],0) [CaseAtBeginning]
, isnull([PAAssessed],0) [PAAssessed]
, isnull([PAAssessedNegative],0) [PAAssessedNegative]
, isnull([PAAssessedNotAssigned],0) [PAAssessedNotAssigned]

, isnull([PATerminated],0) [PATerminated]
, isnull([PAPending],0) [PAPending]
, isnull([MOBOnly],0) [MOBOnly]
, isnull([BOTH],0) [BOTH]
, isnull([FOBOnly],0) [FOBOnly]
, isnull([MOBPartner],0) [MOBPartner]
, isnull([FOBPartner],0) [FOBPartner]
, isnull([MOBGrandmother],0) [MOBGrandmother]
, isnull([Other],0) [Other]
FROM
(SELECT isnull(aa1.FAWFK, d.FAWFK) [FAWFK]
, [AssignThisMonth], [CaseAtBeginning] 
, [PAAssessed], [PAAssessedNegative], [PAAssessedNotAssigned], [PATerminated], [PAPending]
, [MOBOnly],[BOTH], [FOBOnly], [MOBPartner], [FOBPartner], [MOBGrandmother], [Other]
FROM 
(SELECT isnull(a1.FAWFK, c.FAWFK) [FAWFK]
, [AssignThisMonth], [CaseAtBeginning] 
, [PAAssessed], [PAAssessedNegative],[PAAssessedNotAssigned], [PATerminated], [PAPending]
FROM
(SELECT 
isnull(a.FAWFK, b.FAWFK) [FAWFK], [AssignThisMonth], [CaseAtBeginning] 
FROM 
(SELECT p2.CurrentFAWFK [FAWFK], count(*) [AssignThisMonth]
FROM HVScreen AS p1 JOIN CaseProgram AS p2 ON p1.HVCaseFK = p2.HVCaseFK
WHERE p1.ProgramFK = @programfk AND (p1.ScreenDate BETWEEN @StartDt AND @EndDt)
AND p1.ScreenResult = '1' AND p1.ReferralMade = '1'
GROUP BY p2.CurrentFAWFK) AS a
FULL OUTER JOIN

(
SELECT b.CurrentFAWFK [FAWFK], count(*) [CaseAtBeginning]
FROM HVScreen AS a 
JOIN CaseProgram AS b ON a.HVCaseFK = b.HVCaseFK
JOIN HVCase AS c ON c.HVCasePK = a.HVCaseFK
WHERE b.ProgramFK = @programfk 
AND a.ScreenDate < @StartDt AND a.ScreenResult = '1' AND a.ReferralMade = '1' 
AND (b.DischargeDate IS NULL OR b.DischargeDate >= @StartDt)
AND (c.KempeDate IS NULL OR c.KempeDate >= @StartDt)
GROUP BY b.CurrentFAWFK --a.FAWFK
) AS b
ON a.FAWFK = b.FAWFK) AS a1

FULL OUTER JOIN
(SELECT a.PAFAWFK [FAWFK]
, sum(CASE WHEN (a.CaseStatus = '02' AND b.KempeResult <> 1) THEN 1 ELSE 0 END) [PAAssessedNegative]
, sum(CASE WHEN (a.CaseStatus = '02' AND (b.KempeResult = 1 OR b.KempeResult IS NULL)) THEN 1 ELSE 0 END) [PAAssessed]
, sum(CASE WHEN a.CaseStatus = '04' THEN 1 ELSE 0 END) [PAAssessedNotAssigned]
, sum(CASE WHEN a.CaseStatus = '03' THEN 1 ELSE 0 END) [PATerminated]
, sum(CASE WHEN a.CaseStatus = '01' THEN 1 ELSE 0 END) [PAPending]
FROM Preassessment AS a
LEFT OUTER JOIN kempe AS b ON a.HVCaseFK = b.HVCaseFK
WHERE a.ProgramFK = @programfk AND (a.PADate BETWEEN @StartDt AND @EndDt)
GROUP BY a.PAFAWFK) AS c
ON a1.FAWFK = c.FAWFK
) AS aa1

FULL OUTER JOIN
(SELECT FAWFK, sum(CASE WHEN MOBPresent = 1 AND FOBPresent != 1 THEN 1 ELSE 0 END) [MOBOnly]
, sum(CASE WHEN MOBPresent = 1 AND FOBPresent = 1 THEN 1 ELSE 0 END) [BOTH]
, sum(CASE WHEN MOBPresent != 1 AND FOBPresent = 1 THEN 1 ELSE 0 END) [FOBOnly]
, sum(CASE WHEN MOBPartnerPresent = 1 THEN 1 ELSE 0 END) [MOBPartner]
, sum(CASE WHEN FOBPartnerPresent = 1 THEN 1 ELSE 0 END) [FOBPartner]
, sum(CASE WHEN GrandParentPresent = 1 THEN 1 ELSE 0 END) [MOBGrandmother]
, sum(CASE WHEN OtherPresent = 1 THEN 1 ELSE 0 END) [Other]
FROM Kempe
WHERE ProgramFK = @programfk AND (KempeDate BETWEEN @StartDt AND @EndDt) 
GROUP BY FAWFK) AS d
ON aa1.FAWFK = d.FAWFK
) z

JOIN Worker w
ON z.FAWFK = w.WorkerPK
ORDER BY w.LastName












GO
