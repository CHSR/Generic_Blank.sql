SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jrobohn
-- Create date: 20130303
-- Description:	gets data for Performance Target report - FLC6. Education of Participants under 21 at 
--				Target Child's First birthday
-- rspPerformanceTargetReportSummary 19, '07/01/2012', '09/30/2012', null, null, 0, null
-- rspPerformanceTargetReportSummary 19, '10/01/2012', '12/31/2012'
-- =============================================
CREATE procedure [dbo].[rspPerformanceTargetFLC6]
(
    @StartDate      datetime,
    @EndDate		datetime,
    @tblPTCases		PTCases readonly,
    @ReportType		char(7)    = null
)

as
begin

	with cteTotalCases
	as
	(
	select
		  ptc.HVCaseFK
		 , ptc.PC1ID
		 , ptc.OldID
		 , ptc.PC1FullName
		 , ptc.CurrentWorkerFK
		 , ptc.CurrentWorkerFullName
		 , ptc.CurrentLevelName
		 , ptc.ProgramFK
		 , ptc.TCIDPK
		 , ptc.TCDOB
		 , DischargeDate
		 , case
			  when DischargeDate is not null and DischargeDate <> '' and DischargeDate <= @EndDate then
				  datediff(day,ptc.tcdob,DischargeDate)
			  else
				  datediff(day,ptc.tcdob,@EndDate)
		  end as tcAgeDays
		 , case
			  when DischargeDate is not null and DischargeDate <> '' and DischargeDate <= @EndDate then
				  DischargeDate
			  else
				  @EndDate
		  end as lastdate
		from @tblPTCases ptc
			inner join HVCase h WITH (NOLOCK) on ptc.hvcaseFK = h.HVCasePK
			inner join CaseProgram cp WITH (NOLOCK) on cp.CaseProgramPK = ptc.CaseProgramPK
			-- h.hvcasePK = cp.HVCaseFK and cp.ProgramFK = ptc.ProgramFK -- AND cp.DischargeDate IS NULL
	)
	,
	cteCohort
	as
		(
		select tc.*
				, HighestGrade
			from cteTotalCases tc
			inner join HVCase c WITH (NOLOCK) on c.HVCasePK = tc.HVCaseFK
			inner join Intake i WITH (NOLOCK) on i.HVCaseFK = c.HVCasePK
			inner join CommonAttributes ca WITH (NOLOCK) on ca.HVCaseFK = c.HVCasePK and FormFK = IntakePK and FormType = 'IN-PC1'
			inner join PC P on P.PCPK = c.PC1FK
			where datediff(day,tc.tcdob,@StartDate) <= 548
				 and datediff(day,tc.tcdob,lastdate) > 365
				 and HighestGrade < '03'
				 and (datediff(month,PCDOB,c.IntakeDate) / 12) < 21
		)
	,
	cteInterval
	as
		(
			select HVCaseFK					
					, max(Interval) as Interval
			from cteCohort
				inner join codeDueByDates on ScheduledEvent = 'Follow Up' and tcAgeDays >= DueBy
			-- there are no 18 month follow ups (interval code '18') in foxpro, though they're there now
			-- therefore, they're not required until 2013
			where Interval = '12' 
			--<> case when @StartDate >= '01/01/2013' then 'xx'
			--					else '18'
			--					end
			group by HVCaseFK
		)
	,
	cteExpectedForm
	as
		(
		select 'FLC6' as PTCode
			  , c.HVCaseFK
			  , PC1ID
			  , OldID
			  , TCDOB
			  , PC1FullName
			  , CurrentWorkerFullName
			  , CurrentLevelName
			  , EventDescription as FormName
			  , FollowUpDate as FormDate
			  , case when dbo.IsFormReviewed(FollowUpDate,'FU',FollowUpPK) = 1 then 1 else 0 end as FormReviewed
			  , case when (FollowUpPK is null or FUPInWindow = 1) then 0 else 1 end as FormOutOfWindow
			  , case when FollowUpPK is null then 1 else 0 end as FormMissing
			  , EducationalEnrollment
			  , ca.HighestGrade
			  , e.ProgramType
			from cteCohort c
			left outer join cteInterval i on c.HVCaseFK = i.HVCaseFK
			left outer join codeDueByDates cd on ScheduledEvent = 'Follow Up' 
											and i.Interval = cd.Interval 
			-- to get dueby, max, min (given interval)
			-- The following line gets those fu's that are due for the Interval
			-- note 'Interval' is the minimum interval 
			left outer join FollowUp fu WITH (NOLOCK) on fu.HVCaseFK = c.HVCaseFK and fu.FollowUpInterval = i.Interval
			left outer join CommonAttributes ca WITH (NOLOCK) on ca.HVCaseFK = fu.HVCaseFK and FormType = 'FU-PC1' 
												and fu.FollowUpInterval = ca.FormInterval 
			left outer join Education e WITH (NOLOCK) on e.FormType = 'FU' and e.FormFK = ca.FormFK and e.PCType = 'PC1'
											and ProgramType in ('01','02','03','06')
		)
	select distinct PTCode
			  , HVCaseFK
			  , PC1ID
			  , OldID
			  , TCDOB
			  , PC1FullName
			  , CurrentWorkerFullName
			  , CurrentLevelName
			  , FormName
			  , FormDate
			  , FormReviewed
			  , FormOutOfWindow
			  , FormMissing
			  , case when FormMissing = 0 and FormOutOfWindow = 0 and FormReviewed = 1 and 
							(HighestGrade >='03' or 
							 (HighestGrade < '03' and 
								EducationalEnrollment = '1' 
								and ProgramType in ('01','02','03','06')))
						then 1 
						else 0 
						end as FormMeetsTarget
			  , case when FormMissing = 1 then 'Form missing'
						when FormOutOfWindow = 1 then 'Form out of window'
						when FormReviewed = 0 then 'Form not reviewed by supervisor'
						when HighestGrade < '03' and EducationalEnrollment <> '1' 
							then 'Not currently enrolled'
						when HighestGrade < '03' and EducationalEnrollment = '1' and ProgramType not in ('01','02','03','06') 
							then 'Enrolled, but wrong program'
						else '' end as ReasonNotMeeting
	from cteExpectedForm
	-- order by OldID

--select * from cteTotalCases
	--select * from cteCohort	--	begin
	--		select ReportTitleText
	--			  ,PC1ID
	--			  ,TCDOB
	--			  ,Reason
	--			  ,CurrentWorker
	--			  ,LevelAtEndOfReport
	--			  ,Explanation
	--			from @tblPTReportNotMeetingPT
	--			order by CurrentWorker
	--					,PC1ID
	--	end
end
GO
