SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Dar Chen
-- Create date: 06/18/2010
-- Description:	FAW Monthly Report
-- =============================================
CREATE PROCEDURE [dbo].[rspFAWMonthlyReport_Part1] 
	-- Add the parameters for the stored procedure here
	@programfk INT = NULL, 
	@StartDt datetime,
	@EndDt datetime
AS

--DECLARE @StartDt DATE = '08/01/2015'
--DECLARE @EndDt DATE = '08/31/2015'
--DECLARE @programfk INT = 1

;WITH section2 AS (
SELECT count(*) [PreAssessmentCaseLoad]
FROM HVScreen AS a 
JOIN CaseProgram AS b ON a.HVCaseFK = b.HVCaseFK
JOIN HVCase AS c ON c.HVCasePK = a.HVCaseFK
WHERE b.ProgramFK = @programfk 
AND a.ScreenDate < @StartDt AND a.ScreenResult = '1' AND a.ReferralMade = '1' 
AND (b.DischargeDate IS NULL OR b.DischargeDate >= @StartDt)
AND (c.KempeDate IS NULL OR c.KempeDate >= @StartDt)
)

, section1 AS (
SELECT count(*) [TotalScreen]
, sum(CASE WHEN a.ScreenResult = '1' THEN 1 ELSE 0 END) [ScreenPositive]
, sum(CASE WHEN a.ScreenResult <> '1' THEN 1 ELSE 0 END) [ScreenNegative]
, sum(CASE WHEN a.ScreenResult = '1' AND a.ReferralMade = '1' THEN 1 ELSE 0 END) [PositiveReferred]
, sum(CASE WHEN a.ScreenResult = '1' AND a.ReferralMade <> '1' THEN 1 ELSE 0 END) [PositiveNotReferred]
FROM HVScreen  AS a
WHERE ProgramFK = @programfk AND a.ScreenDate BETWEEN @StartDt AND @EndDt
)

, section3 AS (
SELECT 
--  sum(Case when CaseStatus = '02' THEN 1 ELSE 0 END) [PAAssessed]
-- sum(Case when CaseStatus = '04' THEN 1 ELSE 0 END) [PAAssessedNotAssigned]
 sum(CASE WHEN CaseStatus = '03' THEN 1 ELSE 0 END) [PATerminated]
, sum(CASE WHEN CaseStatus = '01' THEN 1 ELSE 0 END) [PAContinue]
, sum(CASE WHEN p.CaseStatus IS NULL OR p.CaseStatus NOT IN ('01', '02', '03', '04') THEN 1 ELSE 0 END) [PANone]

FROM HVScreen AS a 
JOIN CaseProgram AS b ON a.HVCaseFK = b.HVCaseFK
JOIN HVCase AS c ON c.HVCasePK = a.HVCaseFK
LEFT OUTER JOIN Preassessment AS p ON p.HVCaseFK = a.HVCaseFK AND p.PADate BETWEEN @StartDt AND @EndDt
WHERE b.ProgramFK = @programfk 
AND a.ScreenDate <= @EndDt AND a.ScreenResult = '1' AND a.ReferralMade = '1' 
AND (b.DischargeDate IS NULL OR b.DischargeDate >= @StartDt)
AND (c.KempeDate IS NULL OR c.KempeDate >= @StartDt)
)

, section3X AS (

SELECT 
sum(CASE WHEN a.KempeResult <> 1 THEN 1 ELSE 0 END) AS [PAAssignedNegative]
,sum(CASE WHEN (a.KempeResult = 1 AND fsw.WorkerPK IS NOT NULL) THEN 1 ELSE 0 END) [PAAssessed]
,sum(CASE WHEN (a.KempeResult = 1 AND fsw.WorkerPK IS NULL) THEN 1 ELSE 0 END) [PAAssessedNotAssigned]
FROM Kempe AS a
JOIN HVCase AS c ON a.HVCaseFK = c.HVCasePK
JOIN PC d ON d.PCPK = c.PC1FK
LEFT OUTER JOIN Preassessment AS b ON a.HVCaseFK = b.HVCaseFK AND b.CaseStatus in ('02', '04')
LEFT OUTER JOIN Worker faw ON a.FAWFK = faw.WorkerPK
LEFT OUTER JOIN Worker fsw ON b.PAFSWFK = fsw.WorkerPK

WHERE a.ProgramFK = @programfk AND (a.KempeDate BETWEEN @StartDt AND @EndDt)
--ORDER BY a.KempeDate asc
)

SELECT * 
FROM section1 
JOIN section2 ON 1 = 1
JOIN section3 ON 1 = 1
JOIN section3X ON 1 = 1









GO
