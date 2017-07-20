SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Dar Chen
-- Create date: 06/18/2010
-- Description:	PreIntakeActivitySummary Report
-- =============================================
CREATE PROCEDURE [dbo].[rspPreIntakeActivitySummary_Part1] 
	-- Add the parameters for the stored procedure here
	@programfk INT = NULL, 
	@StartDt datetime,
	@EndDt datetime,
	@WorkerFK int,
	@SupervisorFK int
AS

--DECLARE @StartDt DATE = '03/01/2013'
--DECLARE @EndDt DATE = '03/31/2013'
--DECLARE @programfk INT = 1
--DECLARE @WorkerFK INT = NULL
--DECLARE	@SupervisorFK INT = null

; with

At_Start_Of_Month
AS (
	SELECT DISTINCT a.HVCasePK
	FROM HVCase AS a
	JOIN CaseProgram AS b ON a.HVCasePK = b.HVCaseFK
	JOIN WorkerProgram wp on wp.WorkerFK = b.CurrentFSWFK
	JOIN WorkerProgram sup on sup.WorkerFK = wp.SupervisorFK
	WHERE b.ProgramFK = @programfk
	AND (a.KempeDate IS NOT NULL AND a.KempeDate < @StartDT)
	AND (IntakeDate IS NULL OR IntakeDate >= @StartDT)
	AND (b.DischargeDate IS NULL OR b.DischargeDate >= @StartDT)
	AND wp.WorkerFK = isnull(@WorkerFK, wp.WorkerFK)
	AND sup.WorkerFK = isnull(@SupervisorFK, sup.WorkerFK)
),

At_End_Of_Month
AS (
	SELECT DISTINCT a.HVCasePK
	FROM HVCase AS a
	JOIN CaseProgram AS b ON a.HVCasePK = b.HVCaseFK
	JOIN WorkerProgram wp on wp.WorkerFK = b.CurrentFSWFK
	JOIN WorkerProgram sup on sup.WorkerFK = wp.SupervisorFK
	WHERE b.ProgramFK = @programfk
	AND (a.KempeDate IS NOT NULL AND a.KempeDate <= @EndDT)
	AND (IntakeDate IS NULL OR IntakeDate > @EndDT)
	AND (b.DischargeDate IS NULL OR b.DischargeDate > @EndDT)
	AND wp.WorkerFK = isnull(@WorkerFK, wp.WorkerFK)
	AND sup.WorkerFK = isnull(@SupervisorFK, sup.WorkerFK)
),

PreAssessmentFSWAssignDate
AS (
SELECT DISTINCT a.HVCaseFK
FROM Preassessment AS a
WHERE a.KempeDate BETWEEN @StartDt AND @EndDt
-- a.FSWAssignDate BETWEEN @StartDt AND @EndDt
AND a.ProgramFK = @programfk
),

PreIntakeCase 
AS (
SELECT a.HVCaseFK, a.PIDate, a.CaseStatus, a.PIFSWFK
FROM Preintake AS a
JOIN (SELECT HVCaseFK, max(PIDate) max_pidate
FROM Preintake
WHERE PIDate BETWEEN @StartDt AND @EndDt
AND ProgramFK = @programfk
GROUP BY HVCaseFK) AS b ON a.HVCaseFK = b.HVCaseFK AND a.PIDate = b.max_pidate
),

PreIntakeActivity
AS (
SELECT HVCaseFK
,sum(ISNULL(PIParentLetter,0)) [Letters]
,sum(ISNULL(PICall2Parent,0)) [Call2Parent]
,sum(ISNULL(PICallFromParent,0)) [CallFromParent]
,sum(ISNULL(PIVisitAttempt,0)) [VisitAttempted]
,sum(ISNULL(PIVisitMade,0)) [VisitConducted]
,sum(ISNULL(PIOtherHVProgram,0)) [Referrals]
,sum(ISNULL(PIParent2Office,0)) [Parent2Office]
,sum(ISNULL(PIProgramMaterial,0)) [ProgramMaterial]
,sum(ISNULL(PIGift,0)) [Gift]
,sum(ISNULL(PICaseReview,0)) [CaseReview]
,sum(ISNULL(PIOtherActivity,0)) [OtherActivity]
FROM Preintake
WHERE PIDate BETWEEN @StartDt AND @EndDt AND ProgramFK = @programfk
GROUP BY HVCaseFK
),

AllInOne 
AS (
SELECT x.HVCasePK_At_Start, x.HVCasePK_At_End, 
h.KempeDate, h.IntakeDate, c.DischargeDate, p.CaseStatus, p.PIDate,
CASE WHEN (isnull(p.PIDate, h.KempeDate) NOT BETWEEN dateadd(day, -30.5,  @EndDt) AND  @EndDt) THEN 1 ELSE 0 END [No_Status],
CASE WHEN p.PIFSWFK IS NOT NULL AND y.HVCaseFK IS NOT NULL then 1 else 0 END [AssignedFSW]
, z.*
FROM (SELECT isnull(a.HVCasePK, b.HVCasePK) [HVCasePK]
, a.HVCasePK [HVCasePK_At_Start], b.HVCasePK [HVCasePK_At_End]
FROM At_Start_Of_Month AS a 
FULL OUTER JOIN At_End_Of_Month AS b ON a.HVCasePK = b.HVCasePK) x
JOIN HVCase AS h ON h.HVCasePK = x.HVCasePK
JOIN CaseProgram AS c ON c.HVCaseFK = x.HVCasePK
LEFT OUTER JOIN PreIntakeCase AS p ON p.HVCaseFK = x.HVCasePK
LEFT OUTER JOIN PreAssessmentFSWAssignDate AS y ON y.HVCaseFK = x.HVCasePK
LEFT OUTER JOIN PreIntakeActivity AS z ON z.HVCaseFK = x.HVCasePK
),

AllSummary 
AS (
SELECT sum(CASE WHEN PIDate IS NOT NULL THEN 1 ELSE 0 END) [PreInTakeCases]
, sum(CASE WHEN HVCasePK_At_Start IS NULL THEN 1 ELSE 0 END) [New_PreIntake_Cases]
, sum(CASE WHEN No_Status = 1 THEN 1 ELSE 0 END) [No_Status]
, sum(CASE WHEN HVCasePK_At_Start IS NOT NULL THEN 1 ELSE 0 END) [At_Start_of_Month]
, sum(CASE WHEN [AssignedFSW] = 1 THEN 1 ELSE 0 END) [AssignedFSW]
, sum(CASE WHEN CaseStatus = '02' THEN 1 ELSE 0 END) [Enrolled]
, sum(CASE WHEN CaseStatus = '03' THEN 1 ELSE 0 END) [Terminated]
, sum(CASE WHEN CaseStatus = '01' THEN 1 ELSE 0 END) [Continued]
, sum(CASE WHEN HVCasePK_At_End IS NOT NULL THEN 1 ELSE 0 END) [At_End_of_Month]
,sum(ISNULL([Letters],0)) [Letters]
,sum(ISNULL([Call2Parent],0)) [Call2Parent]
,sum(ISNULL([CallFromParent],0)) [CallFromParent]
,sum(ISNULL([VisitAttempted],0)) [VisitAttempted]
,sum(ISNULL([VisitConducted],0)) [VisitConducted]
,sum(ISNULL([Referrals],0)) [Referrals]
,sum(ISNULL([Parent2Office],0)) [Parent2Office]
,sum(ISNULL([ProgramMaterial],0)) [ProgramMaterial]
,sum(ISNULL([Gift],0)) [Gift]
,sum(ISNULL([CaseReview],0)) [CaseReview]
,sum(ISNULL([OtherActivity],0)) [OtherActivity]
FROM AllInOne

)
-- listing data
--SELECT * from AllInOne  

-- calculate summary 
SELECT * FROM AllSummary
GO
