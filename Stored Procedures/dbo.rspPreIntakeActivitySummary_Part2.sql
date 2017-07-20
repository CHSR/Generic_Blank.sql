SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Dar Chen
-- Create date: 06/18/2010
-- Description:	FAW Monthly Report
-- exec rspPreIntakeActivitySummary_Part2 1,'20111101','20121031',null,null
-- =============================================
CREATE procedure [dbo].[rspPreIntakeActivitySummary_Part2]-- Add the parameters for the stored procedure here
    @programfk int = null,
    @StartDt   datetime,
    @EndDt     datetime,
    @WorkerFK int,
    @SupervisorFK int
as

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

PreIntakeCase 
AS (
SELECT a.HVCaseFK
,a.CaseStatus
,a.ProgramFK
,a.DischargeReason
,a.PIDate
,a.PIFSWFK
,a.KempeFK
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
SELECT 
c.PC1ID [Participant]
,rtrim(w.LastName)+', '+rtrim(w.FirstName) [Worker]
,cast(datediff(day,h.KempeDate,isnull(p.PIDate, @EndDt)) as varchar(12))+' days' [DaysInPreintake]
,case when p.CaseStatus = '01' then 'Engagement Continue'
      when p.CaseStatus = '02' then 'Enrolled '+ convert(varchar(12),h.IntakeDate,101)
      when p.CaseStatus = '03' then isnull((select top 1 rtrim(ReportDischargeText)
							   from codeDischarge
							   where DischargeCode = p.DischargeReason)+' ','Terminated ')
				                  +isnull(convert(varchar(12),c.DischargeDate,101),'')
	  when (isnull(p.PIDate, h.KempeDate) NOT BETWEEN dateadd(day, -30.5,  @EndDt) AND  @EndDt) then 'No Status'
      else '(Status Unknown)' end [CaseStatus]
,z.[Letters]
,z.[Call2Parent]
,z.[CallFromParent]
,z.[VisitAttempted]
,z.[VisitConducted]
,z.[Referrals]
,z.[Parent2Office]
,z.[ProgramMaterial]
,z.[Gift]
,z.[CaseReview]
,z.[OtherActivity]

--,p.CaseStatus [CaseStatus]
,p.ProgramFK
,p.DischargeReason
,p.PIDate
,p.PIFSWFK
,p.KempeFK
,p.HVCaseFK

FROM 
(SELECT isnull(a.HVCasePK, b.HVCasePK) [HVCasePK]
, a.HVCasePK [HVCasePK_At_Start], b.HVCasePK [HVCasePK_At_End]
FROM At_Start_Of_Month AS a 
FULL OUTER JOIN At_End_Of_Month AS b ON a.HVCasePK = b.HVCasePK) x

JOIN HVCase AS h ON h.HVCasePK = x.HVCasePK
JOIN CaseProgram AS c ON c.HVCaseFK = x.HVCasePK
LEFT OUTER JOIN PreIntakeCase AS p ON p.HVCaseFK = x.HVCasePK
LEFT OUTER JOIN PreIntakeActivity AS z ON z.HVCaseFK = x.HVCasePK

left outer join Worker as w on w.WorkerPK = isnull(p.PIFSWFK, c.CurrentFSWFK)
inner join WorkerProgram wp on wp.WorkerFK = isnull(p.PIFSWFK, c.CurrentFSWFK)
inner join WorkerProgram sup on sup.WorkerFK = wp.SupervisorFK

where (p.CaseStatus is not null) or (isnull(p.PIDate, h.KempeDate) NOT BETWEEN dateadd(day, -30.5,  @EndDt) AND  @EndDt) 
)

select * from allinone


/* -- old codes
	select c.PC1ID [Participant]
		  ,rtrim(w.LastName)+', '+rtrim(w.FirstName) [Worker]
		  ,cast(datediff(day,b.KempeDate,a.PIDate) as varchar(12))+' days' [DaysInPreintake]
		  ,case when a.CaseStatus = '01' then 'Engagement Continue'
			   when a.CaseStatus = '02' then 'Enrolled '+(select top 1 convert(varchar(12),IntakeDate,101)
															  from HVCase
															  where HVCasePK = a.HVCaseFK)
			   when a.CaseStatus = '03' then
				   isnull((select top 1 rtrim(ReportDischargeText)
							   from codeDischarge
							   where DischargeCode = a.DischargeReason)+' ','Terminated ')
				   +isnull(convert(varchar(12),c.DischargeDate,101),'')
			   else '(Status Unknown)' end [CaseStatus]

		  ,ISNULL(PIParentLetter,0) [Letters]
		  ,ISNULL(PICall2Parent,0) [Call2Parent]
		  ,ISNULL(PICallFromParent,0) [CallFromParent]
		  ,ISNULL(PIVisitAttempt,0) [VisitAttempted]
		  ,ISNULL(PIVisitMade,0) [VisitConducted]
		  ,ISNULL(PIOtherHVProgram,0) [Referrals]
		  ,ISNULL(PIParent2Office,0) [Parent2Office]
		  ,ISNULL(PIProgramMaterial,0) [ProgramMaterial]
		  ,ISNULL(PIGift,0) [Gift]
		  ,ISNULL(PICaseReview,0) [CaseReview]
		  ,ISNULL(PIOtherActivity,0) [OtherActivity]

		  ,a.CaseStatus
		  ,a.ProgramFK
		  ,a.DischargeReason
		  ,a.PIDate
		  ,a.PIFSWFK
		  ,a.KempeFK
		  ,a.HVCaseFK
		from Preintake as a
			join CaseProgram as c on c.HVCaseFK = a.HVCaseFK
			join Kempe as b on b.KempePK = a.KempeFK
			left outer join Worker as w on w.WorkerPK = a.PIFSWFK
			inner join WorkerProgram wp on wp.WorkerFK = PIFSWFK
			inner join WorkerProgram sup on sup.WorkerFK = wp.SupervisorFK
		where a.ProgramFK = @programfk
			and a.PIDate between @StartDt and @EndDt
			and wp.WorkerFK = isnull(@WorkerFK, wp.WorkerFK)
			and sup.WorkerFK = isnull(@SupervisorFK, sup.WorkerFK)
		order by [Participant]
		
		*/
GO
