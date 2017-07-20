SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <Febu. 28, 2013>
-- Description:	<gets you data for Performance Target report - HD3. Lead Assessment>
-- exec [rspPerformanceTargetHD3] '07/01/2012','09/30/2012','01',null,null
-- rspPerformanceTargetReportSummary 5 ,'10/01/2012' ,'12/31/2012'
-- testing siteFK below
-- rspPerformanceTargetReportSummary 1 ,'10/01/2012' ,'12/31/2012', null,1
-- mods by jrobohn 20130222 - clean up names, code and layout
-- =============================================
CREATE procedure [dbo].[rspPerformanceTargetHD3]
(
    @StartDate	datetime,
    @EndDate	datetime,
    @tblPTCases	PTCases	readonly
)

as
begin

	;
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
			 , cp.DischargeDate
			 ,case
				  when DischargeDate is not null and DischargeDate <> '' and DischargeDate <= @EndDate then
					  datediff(day,ptc.tcdob,DischargeDate)
				  else
					  datediff(day,ptc.tcdob,@EndDate)
			  end as tcAgeDays
			 ,case
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
	-- Report: HD1. Immunization at one year
	cteCohort
	as
		(
		select HVCaseFK
			  , PC1ID
			  , OldID		 
			  , PC1FullName
			  , CurrentWorkerFK
			  , CurrentWorkerFullName
			  , CurrentLevelName
			  , ProgramFK
			  , TCIDPK
			  , TCDOB
			  , DischargeDate
			  , tcAgeDays
			  , lastdate
			from cteTotalCases
			where datediff(day, tcdob + (.75 * 365.25), lastdate) > 0 -- Target children between 9 months and older
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
		select 'HD3' as PTCode
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
			  , case when (FollowUpPK is NULL OR FUPInWindow = 1) then 0 else 1 end as FormOutOfWindow
			  , case when FollowUpPK is null then 1 else 0 end as FormMissing
			  , LeadAssessment
			from cteCohort c
			inner join cteInterval i on c.HVCaseFK = i.HVCaseFK 
			inner join codeDueByDates cd on ScheduledEvent = 'Follow Up' 
											and i.Interval = cd.Interval 
			left join FollowUp fu WITH (NOLOCK) on fu.HVCaseFK = c.HVCaseFK and fu.FollowUpInterval = i.Interval
		)
	,
	cteMain
	as
		(
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
			  , case when FormReviewed = 1 and FormOutOfWindow = 0 and FormMissing = 0 and 
							(LeadAssessment = 1 OR LeadAssessment = 0) then 1 else 0 end as FormMeetsTarget
			  , case when FormMissing = 1 then 'Form missing'
						when FormOutOfWindow = 1 then 'Form out of window'
						when FormReviewed = 0 then 'Form not reviewed by supervisor'
						when FormReviewed = 1 and FormOutOfWindow = 0 and FormMissing = 0 and 
							LeadAssessment is null then 'Lead Assessment is blank'
						else '' end as NotMeetingReason
		from cteExpectedForm
		)
	
	select * from cteMain
	-- rspPerformanceTargetReportSummary 2 ,'10/01/2012' ,'12/31/2012'	

end
GO
