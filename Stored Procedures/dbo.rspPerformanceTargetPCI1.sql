SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jrobohn
-- Create date: 20130222
-- Description:	gets data for Performance Target report - PCI1. Primary Care Taker 1 breast feeding
-- exec [rspPerformanceTargetPCI1] '07/01/2012', '09/30/2012', <<table>>, null
-- rspPerformanceTargetReportSummary 19, '07/01/2012', '09/30/2012'
-- rspPerformanceTargetReportSummary 19 ,'10/01/2012' ,'12/31/2012'	
-- testing siteFK below
-- rspPerformanceTargetReportSummary 19, '07/01/2012', '09/30/2012', null, 1
-- based on initial work on PTHD1 by dkhalsa
-- =============================================
CREATE procedure [dbo].[rspPerformanceTargetPCI1]
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
		select *
			from cteTotalCases
			where datediff(day,tcdob,@StartDate) <= 457
				 and datediff(day,tcdob,lastdate) >= 183
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
			where Interval <> case when @StartDate >= '01/01/2013' then 'xx'
								else '18'
								end
			group by HVCaseFK
		)
	,
	cteExpectedForm
	as
		(
		select distinct 'PCI1' as PTCode
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
			  , case when (FUPInWindow = 1) then 0 else 1 end as FormOutOfWindow
			  , case when FollowUpPK is null then 1 else 0 end as FormMissing
			  , WasBreastFed
			  , TimeBreastFed
			from cteCohort c
			inner join cteInterval i on c.HVCaseFK = i.HVCaseFK
			inner join codeDueByDates cd on ScheduledEvent = 'Follow Up' 
											and i.Interval = cd.Interval 
			-- to get dueby, max, min (given interval)
			-- The following line gets those fu's that are due for the Interval
			-- note 'Interval' is the minimum interval 
			left outer join FollowUp fu WITH (NOLOCK) on fu.HVCaseFK = c.HVCaseFK and fu.FollowUpInterval = i.Interval
			left outer join CommonAttributes ca WITH (NOLOCK) on ca.HVCaseFK = fu.HVCaseFK and FormType='FU' 
												and fu.FollowUpInterval = ca.FormInterval 
		)
	
	
	-- select * from cteCohort
	select PTCode
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
			, case when (WasBreastFed = 1 and TimeBreastFed >= '04' and FormReviewed = 1 
							and FormOutOfWindow = 0 and FormMissing = 0) 
					then 1 
					else 0 
					end 
				as FormMeetsTarget
			  , case when FormMissing = 1 then 'Form missing'
						when FormOutOfWindow = 1 then 'Form out of window'
						when FormReviewed = 0 then 'Form not reviewed by supervisor'
						when WasBreastFed is null or (WasBreastFed = 1 and TimeBreastFed is null)
							then 'Breast fed question missing'
						when WasBreastFed = 0 
							then 'No breast feeding'
						when WasBreastFed = 1 and TimeBreastFed < '04' 
							then 'Breast fed < 3 months'
						else '' end as ReasonNotMeeting
	from cteExpectedForm
	-- order by OldID

	--	begin
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
