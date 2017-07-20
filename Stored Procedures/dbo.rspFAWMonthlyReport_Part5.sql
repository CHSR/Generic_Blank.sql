SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Dar Chen
-- Create date: 06/18/2010
-- Description:	FAW Monthly Report
-- =============================================
CREATE PROCEDURE [dbo].[rspFAWMonthlyReport_Part5] 
	-- Add the parameters for the stored procedure here
	@programfk INT = NULL, 
	@StartDt datetime,
	@EndDt datetime
AS

--DECLARE @StartDt DATE = '01/01/2012'
--DECLARE @EndDt DATE = '01/31/2012'
--DECLARE @programfk INT = 6

DECLARE @NoAnyPreAssessment TABLE (
    [PreassessmentPK] [int] NULL,
	[CaseStatus] [char](2) NOT NULL,
	[DischargeReason] [char](2) NULL,
	[DischargeReasonSpecify] [varchar](500) NULL,
	[DischargeSafetyReason] [char](2) NULL,
	[DischargeSafetyReasonDV] [bit] NULL,
	[DischargeSafetyReasonMH] [bit] NULL,
	[DischargeSafetyReasonOther] [bit] NULL,
	[DischargeSafetyReasonSA] [bit] NULL,
	[DischargeSafetyReasonSpecify] [varchar](500) NULL,
	[FSWAssignDate] [datetime] NULL,
	[HVCaseFK] [int] NOT NULL,
	[KempeDate] [datetime] NULL,
	[KempeResult] [bit] NULL,
	[PAActivitySpecify] [varchar](500) NULL,
	[PACall2Parent] [int] NULL,
	[PACallFromParent] [int] NULL,
	[PACaseReview] [int] NULL,
	[PACreateDate] [datetime] NULL,
	[PACreator] [char](10) NULL,
	[PADate] [datetime] NULL,
	[PAEditDate] [datetime] NULL,
	[PAEditor] [char](10) NULL,
	[PAFAWFK] [int] NULL,
	[PAFSWFK] [int] NULL,
	[PAGift] [int] NULL,
	[PAOtherActivity] [int] NULL,
	[PAOtherHVProgram] [int] NULL,
	[PAParent2Office] [int] NULL,
	[PAParentLetter] [int] NULL,
	[PAProgramMaterial] [int] NULL,
	[PAVisitAttempt] [int] NULL,
	[PAVisitMade] [int] NULL,
	[ProgramFK] [int] NOT NULL,
	[TransferredtoProgram] [varchar](50) NULL )

INSERT INTO @NoAnyPreAssessment ([HVCaseFK], [CaseStatus], [PAFAWFK], [ProgramFK])
SELECT ppp.HVCaseFK, '99', ppp.FAWFK, @programfk
FROM 
(SELECT a.*
FROM (
SELECT HVCaseFK, FAWFK
FROM HVScreen WHERE ProgramFK = @programfk
AND ScreenDate < @StartDt 
AND ScreenResult = 1 AND ReferralMade = 1
) AS a
JOIN CaseProgram AS c ON a.HVCaseFK = c.HVCaseFK
LEFT OUTER JOIN Preassessment AS b ON a.HVCaseFK = b.HVCaseFK AND  b.PADate <= @EndDt
WHERE b.HVCaseFK IS NULL AND (c.DischargeDate IS NULL OR c.DischargeDate > @StartDt)
) as ppp
;

-- no status pre-assessment cases (no form this month)
--;WITH zzz AS (
--SELECT x.*
--FROM Preassessment AS x
--JOIN (SELECT a.HVCaseFK, max(a.PADate) [maxDate]
--FROM Preassessment AS a
--WHERE a.ProgramFK = @programfk AND a.PADate < @StartDt
--GROUP BY a.HVCaseFK) AS y
--ON x.HVCaseFK = y.HVCaseFK AND x.PADate = maxDate
--WHERE x.CaseStatus = '01')

-- no status pre-assessment cases (no form this month)
;WITH zzz AS (
SELECT xx.* 
FROM (SELECT x.*
FROM Preassessment AS x
JOIN (SELECT a.HVCaseFK, max(a.PADate) [maxDate]
FROM Preassessment AS a
WHERE a.ProgramFK = @programfk AND a.PADate < @StartDt
GROUP BY a.HVCaseFK) AS y
ON x.HVCaseFK = y.HVCaseFK AND x.PADate = maxDate
WHERE x.CaseStatus = '01') AS xx
JOIN CaseProgram AS yy ON xx.HVCaseFK = yy.HVCaseFK
WHERE (yy.DischargeDate IS NULL OR yy.DischargeDate >= @StartDt)
)


,
qqq AS (
SELECT *
FROM Preassessment AS a
WHERE a.ProgramFK = @programfk AND a.PADate BETWEEN @StartDt AND @EndDt
)
,
NoStatus AS (
SELECT a.*
FROM zzz AS a LEFT OUTER JOIN qqq AS b ON a.HVCaseFK = b.HVCaseFK
WHERE b.HVCaseFK IS NULL
)
,
AllPreAssessment AS (
SELECT a.*
FROM Preassessment AS a
WHERE a.ProgramFK = @programfk AND a.PADate BETWEEN @StartDt AND @EndDt
UNION
SELECT * FROM NoStatus
)

SELECT c.PC1ID [Participant]
, rtrim(w.LastName) + ', ' + rtrim(w.FirstName) [Worker]
, CASE WHEN a.PADate < @StartDt THEN rtrim(str(datediff(dd, b.ScreenDate , @EndDt),10))
  WHEN a.CaseStatus = '03' THEN rtrim(str(datediff(dd, b.ScreenDate , a.PADate),10))
  WHEN a.CaseStatus = '01' THEN rtrim(str(datediff(dd, b.ScreenDate, @EndDt),10))
  WHEN a.CaseStatus = '02' THEN rtrim(str(datediff(dd, b.ScreenDate, a.PADate),10))
  WHEN a.CaseStatus = '04' THEN rtrim(str(datediff(dd, b.ScreenDate, a.PADate),10))
  WHEN a.CaseStatus = '99' THEN rtrim(str(datediff(dd, b.ScreenDate, @EndDt),10))
  ELSE 0 END [DaysInPreassess]
  
, CASE WHEN a.PADate < @StartDt THEN 'No Status'
  WHEN a.CaseStatus = '03' THEN rtrim(x.ReportDischargeText) + ' ' + convert(VARCHAR(12), a.PADate, 101) 
  WHEN a.CaseStatus = '01' THEN 'Continue ' + convert(VARCHAR(12), @EndDt, 101) 

  WHEN (a.CaseStatus = '02' AND KempeResult <> 1)  THEN 'Assessment Completed ' + convert(VARCHAR(12), b.KempeDate, 101) + ' (Negative)'
  WHEN (a.CaseStatus = '02' AND (KempeResult = 1 OR KempeResult IS NULL)) THEN 'Assessment Completed ' + convert(VARCHAR(12), b.KempeDate, 101) + ' (Assigned)'

  WHEN a.CaseStatus = '04' THEN 'Assessment Completed, Not Assigned ' + rtrim(x.ReportDischargeText) + ' ' + convert(VARCHAR(12), a.PADate, 101) 
  WHEN a.CaseStatus = '99' THEN 'No Preassessments'
  ELSE '' END [CurrentStatus]
  
, CASE WHEN a.PADate < @StartDt THEN 0 ELSE ISNULL(a.PAParentLetter, 0) END [Letters]
, CASE WHEN a.PADate < @StartDt THEN 0 ELSE ISNULL(a.PACall2Parent, 0) END [Call2Parent]
, CASE WHEN a.PADate < @StartDt THEN 0 ELSE ISNULL(a.PACallFromParent, 0) END [CallFromParent]
, CASE WHEN a.PADate < @StartDt THEN 0 ELSE ISNULL(a.PAVisitAttempt, 0) END [VisitAttempted]
, CASE WHEN a.PADate < @StartDt THEN 0 ELSE ISNULL(a.PAVisitMade, 0) END [VisitConducted]
, CASE WHEN a.PADate < @StartDt THEN 0 ELSE ISNULL(a.PAOtherHVProgram, 0) END [Referrals]
, CASE WHEN a.PADate < @StartDt THEN 0 ELSE ISNULL(a.PAParent2Office, 0) END [Parent2Office]
, CASE WHEN a.PADate < @StartDt THEN 0 ELSE ISNULL(a.PAProgramMaterial, 0) END [ProgramMaterial]
, CASE WHEN a.PADate < @StartDt THEN 0 ELSE ISNULL(a.PAGift, 0) END [Gift]
, CASE WHEN a.PADate < @StartDt THEN 0 ELSE ISNULL(a.PACaseReview, 0) END [CaseReview]
, CASE WHEN a.PADate < @StartDt THEN 0 ELSE ISNULL(a.PAOtherActivity, 0) END [OtherActivity]
-- support fields
--, b.ScreenDate , a.PADate 
--, CASE WHEN c.DischargeDate > @EndDt THEN NULL ELSE c.DischargeDate END [xDischargeDate] 
--,a.HVCaseFK, b.KempeDate, a.CaseStatus, a.KempeResult, a.DischargeReason, x.ReportDischargeText

FROM 
(SELECT * FROM AllPreAssessment 
UNION
SELECT * FROM @NoAnyPreAssessment
) AS a
JOIN CaseProgram AS c ON c.HVCaseFK = a.HVCaseFK
JOIN HVCase AS b ON b.HVCasePK = a.HVCaseFK
LEFT OUTER JOIN codeDischarge x ON x.DischargeCode = a.DischargeReason 
AND x.DischargeUsedWhere LIKE '%PA%'
LEFT OUTER JOIN Worker AS w ON w.WorkerPK = a.PAFAWFK
ORDER BY [Participant]
GO
