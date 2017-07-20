SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jrobohn
-- Create date: 20130302
-- Description:	gets data for Performance Target report - FLC2. Employment, Education and Training
--				at target child's second birthday
-- exec [rspPerformanceTargetPCI1] '07/01/2012', '09/30/2012', <<table>>, null
-- rspPerformanceTargetReportSummary 19, '07/01/2012', '09/30/2012'
-- rspPerformanceTargetReportSummary 19 ,'10/01/2012' ,'12/31/2012'	
-- testing siteFK below
-- rspPerformanceTargetReportSummary 19, '07/01/2012', '09/30/2012', null, 1
-- based on initial work on PTHD1 by dkhalsa
-- =============================================
CREATE procedure [dbo].[rspPerformanceTargetFLC2]
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
		select ptc.HVCaseFK
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
				, PC1FK
				, PC2FK
				, OBPFK
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
			where datediff(day,tcdob,@StartDate) <= 913
				 and datediff(day,tcdob,lastdate) >= 730
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
		select 'FLC2' as PTCode
				, c.HVCaseFK
				, PC1ID
				, OldID
				, TCDOB
				, PC1FullName
				, CurrentWorkerFullName
				, CurrentLevelName
				, FollowUpDate as FormDate
				, case when dbo.IsFormReviewed(FollowUpDate,'FU',FollowUpPK) = 1 then 1 else 0 end as FormReviewed
				, case when (FUPInWindow = 1) then 0 else 1 end as FormOutOfWindow
				, case when FollowUpPK is null then 1 else 0 end as FormMissing
				, EventDescription as FormName
				, FormType
				, PC1InHome
				, PC2InHome
				, OBPInHome
				, IsCurrentlyEmployed
				, EducationalEnrollment
				, PC1FK
				, PC2FK
				, OBPFK
				, tcAgeDays
			from cteCohort c
			inner join cteInterval i on c.HVCaseFK = i.HVCaseFK
			inner join codeDueByDates cd on ScheduledEvent = 'Follow Up' 
											and i.Interval = cd.Interval 
			-- to get dueby, max, min (given interval)
			-- The following line gets those fu's that are due for the Interval
			-- note 'Interval' is the minimum interval 
			left outer join FollowUp fu WITH (NOLOCK) on fu.HVCaseFK = c.HVCaseFK and fu.FollowUpInterval = i.Interval
			left outer join CommonAttributes ca WITH (NOLOCK) on ca.HVCaseFK = fu.HVCaseFK and FormType like 'FU-%' 
												and fu.FollowUpInterval = ca.FormInterval 
		)
	,
	cteTargetElements
	as
		(
			select HVCaseFK
				, count(HVCaseFK) as PersonCount
				, sum(case when FormType = 'FU-PC1' and 
								-- (PC1InHome= '0' or 
									(PC1InHome = '1' and 
										(IsCurrentlyEmployed = '1' or EducationalEnrollment = '1'))
								--	)
								then 1
								else 0
								end)
						as PC1Score
				, sum(case when PC1InHome = '1' then 1 else 0 end) 
						as PC1InHome
				, sum(case when FormType = 'FU-PC2' and 
								-- (PC2InHome= '0' or 
									(PC2InHome = '1' and 
										(IsCurrentlyEmployed = '1' or EducationalEnrollment = '1'))
								--	)
								then 1
								else 0
								end)
						as PC2Score
				, sum(case when PC2InHome = '1' then 1 else 0 end) 
						as PC2InHome
				, sum(case when FormType = 'FU-OBP' and 
								-- (OBPInHome= '0' or 
									(OBPInHome = '1' and 
										(IsCurrentlyEmployed = '1' or EducationalEnrollment = '1'))
								--	)
								then 1
								else 0
								end)
						as OBPScore
				, sum(case when OBPInHome = '1' then 1 else 0 end) 
						as OBPInHome
			from cteExpectedForm
			group by HVCaseFK
		)
	,
	cteDistinctFollowUps
	as
		(
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
			  , PC1FK
			  , PC2FK
			  , OBPFK
		from cteExpectedForm
		)
	,
	cteMain 
	as
		(
		select PTCode
				, dfu.HVCaseFK
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
				, case when FormReviewed = 1 
							and FormOutOfWindow = 0
							and FormMissing = 0
							and (PC1Score + PC2Score + OBPScore) >= 1
						then 1
						else 0
						end
					as FormMeetsTarget
				, case when FormMissing = 1 then 'Form missing'
						when FormOutOfWindow = 1 then 'Form out of window'
						when FormReviewed = 0 then 'Form not reviewed by supervisor'
						when (PC1FK is not null and te.PC1InHome >= 1 and PC1Score = 0)
								or (PC2FK is not null and te.PC2InHome >= 1 and PC2Score = 0)
								or (OBPFK is not null and te.OBPInHome >= 1 and OBPScore = 0)
							then 'Family members not employed or enrolled'
						else '' end as ReasonNotMeeting
				--, case when FormMissing = 1 then 'Form missing'
				--		when FormOutOfWindow = 1 then 'Form out of window'
				--		when FormReviewed = 0 then 'Form not reviewed by supervisor'
				--		when PC1FK is not null and te.PC1InHome >= 1
				--			 and PC2FK is null 
				--			 and OBPFK is null 
				--			 and PC1Score = 0
				--			then 'PC1 not employed or enrolled'
				--		when PC1FK is not null and te.PC1InHome >= 1
				--			 and PC2FK is not null and te.PC2InHome >= 1
				--			 and OBPFK is null 
				--			 and PC1Score = 0 
				--			 and PC2Score = 0
				--			then 'PC1/PC2 not employed or enrolled'
				--		when PC1FK is not null and te.PC1InHome >= 1
				--			 and PC2FK is null 
				--			 and OBPFK is not null and te.OBPInHome >= 1
				--			 and PC1Score = 0 
				--			 and OBPScore = 0
				--			then 'PC1/OBP not employed or enrolled'
				--		when PC1FK is not null and te.PC1InHome >= 1
				--			 and PC2FK is not null and te.PC2InHome >= 1
				--			 and OBPFK is not null and te.OBPInHome >= 1
				--			 and PC1Score = 0 
				--			 and PC2Score = 0 
				--			 and OBPScore = 0
				--			then 'PC1/PC2/OBP not employed or enrolled'
				--		else '' end as ReasonNotMeeting
				--, case when FormReviewed = 0 then 'Form not reviewed by supervisor'
				--		when FormOutOfWindow = 1 then 'Form out of window'
				--		when FormMissing = 1 then 'Form missing'
				--		when PC1FK is not null and PC1InHome = '1'
				--			 and PC2FK is null 
				--			 and OBPFK is null 
				--			 and PC1Score = 0
				--			then 'PC1 not employed or enrolled'
				--		when PC1FK is not null and PC1InHome = '1'
				--			 and PC2FK is not null and PC2InHome = '1'
				--			 and OBPFK is null 
				--			 and PC1Score = 0 
				--			 and PC2Score = 0
				--			then 'PC1/PC2 not employed or enrolled'
				--		when PC1FK is not null and PC1InHome = '1'
				--			 and PC2FK is null 
				--			 and OBPFK is not null and OBPInHome = '1'
				--			 and PC1Score = 0 
				--			 and OBPScore = 0
				--			then 'PC1/OBP not employed or enrolled'
				--		when PC1FK is not null and PC1InHome = '1'
				--			 and PC2FK is not null and PC2InHome = '1'
				--			 and OBPFK is not null and OBPInHome = '1'
				--			 and PC1Score = 0 
				--			 and PC2Score = 0 
				--			 and OBPScore = 0
				--			then 'PC1/PC2/OBP not employed or enrolled'
				--		else '' end as ReasonNotMeeting
				--, case when PersonCount = (PC1Score + PC2Score + OBPScore) 
				--		then 1
				--		else 0
				--		end
				--	as FormMeetsTarget
				--, case when FormReviewed = 0 then 'Form not reviewed by supervisor'
				--		when FormOutOfWindow = 1 then 'Form out of window'
				--		when FormMissing = 1 then 'Form missing'
				--		when PC1FK is not null and PC1Score = 0 and
				--			 (PC2FK is null or (PC2FK is not null and PC2Score = 1)) and 
				--			 (OBPFK is null or (OBPFK is not null and OBPScore = 1)) 
				--			then 'PC1 not employed or enrolled'
				--		when (PC1FK is null or (PC1FK is not null and PC1Score = 1)) and 
				--			 PC2FK is not null and PC2Score = 0 and
				--			 (OBPFK is null or (OBPFK is not null and OBPScore = 1)) 
				--			then 'PC2 not employed or enrolled'
				--		when (PC1FK is null or (PC1FK is not null and PC1Score = 1)) and 
				--			 (PC2FK is null or (PC2FK is not null and PC2Score = 1)) and 
				--			 OBPFK is not null and OBPScore = 0 
				--			then 'OBP not employed or enrolled'
				--		when PC1FK is not null and PC1Score = 0 and
				--			 PC2FK is not null and PC2Score = 0 and
				--			 (OBPFK is null or (OBPFK is not null and OBPScore = 1)) 
				--			then 'PC1/PC2 not employed or enrolled'
				--		when PC1FK is not null and PC1Score = 0 and
				--			 (PC2FK is null or (PC2FK is not null and PC2Score = 1)) and 
				--			 OBPFK is not null and OBPScore = 0
				--			then 'PC1/OBP not employed or enrolled'
				--		when (PC1FK is null or (PC1FK is not null and PC1Score = 1)) and 
				--			 PC2FK is not null and PC2Score = 0 and
				--			 OBPFK is not null and OBPScore = 0
				--			then 'PC2/OBP not employed or enrolled'
				--		when PC1FK is not null and PC1Score = 0 and
				--			 PC2FK is not null and PC2Score = 0 and
				--			 OBPFK is not null and OBPScore = 0
				--			then 'PC1/PC2/OBP not employed or enrolled'
				--		else '' end as NotMeetingReason
				--, case when FormReviewed = 0 then 'Form not reviewed by supervisor'
				--		when FormOutOfWindow = 1 then 'Form out of window'
				--		when FormMissing = 1 then 'Form missing'
				--		when PC1FK is not null and (PC1InHome = '0' or (PC1InHome = '1' and PC1Score = 0)) and
				--			 (PC2FK is null or (PC2FK is not null and PC2InHome = '1' and PC2Score = 1)) and 
				--			 (OBPFK is null or (OBPFK is not null and OBPInHome = '1' and OBPScore = 1)) 
				--			then 'PC1 not employed or enrolled'
				--		when (PC1FK is null or (PC1FK is not null and PC1InHome = '1' and PC1Score = 1)) and 
				--			 PC2FK is not null and PC2InHome = '1' and PC2Score = 0 and
				--			 (OBPFK is null or (OBPFK is not null and OBPInHome = '1' and OBPScore = 1)) 
				--			then 'PC2 not employed or enrolled'
				--		when (PC1FK is null or (PC1FK is not null and PC1InHome = '1' and PC1Score = 1)) and 
				--			 (PC2FK is null or (PC2FK is not null and PC2InHome = '1' and PC2Score = 1)) and 
				--			 OBPFK is not null and OBPInHome = '1' and OBPScore = 0 
				--			then 'OBP not employed or enrolled'
				--		when PC1FK is not null and PC1InHome = '1' and PC1Score = 0 and
				--			 PC2FK is not null and PC2InHome = '1' and PC2Score = 0 and
				--			 (OBPFK is null or (OBPFK is not null and OBPInHome = '1' and OBPScore = 1)) 
				--			then 'PC1/PC2 not employed or enrolled'
				--		when PC1FK is not null and PC1InHome = '1' and PC1Score = 0 and
				--			 (PC2FK is null or (PC2FK is not null and PC2InHome = '1' and PC2Score = 1)) and 
				--			 OBPFK is not null and OBPInHome = '1' and OBPScore = 0
				--			then 'PC1/OBP not employed or enrolled'
				--		when (PC1FK is null or (PC1FK is not null and PC1InHome = '1' and PC1Score = 1)) and 
				--			 PC2FK is not null and PC2InHome = '1' and PC2Score = 0 and
				--			 OBPFK is not null and OBPInHome = '1' and OBPScore = 0
				--			then 'PC2/OBP not employed or enrolled'
				--		when PC1FK is not null and PC1InHome = '1' and PC1Score = 0 and
				--			 PC2FK is not null and PC2InHome = '1' and PC2Score = 0 and
				--			 OBPFK is not null and OBPInHome = '1' and OBPScore = 0
				--			then 'PC1/PC2/OBP not employed or enrolled'
				--		else '' end as ReasonNotMeeting
			from cteDistinctFollowUps dfu
			inner join cteTargetElements te on te.HVCaseFK = dfu.HVCaseFK
		)
	
	select * from cteMain

	-- select * from cteExpectedForm
	-- select * from cteCohort
	--select PTCode
	--		, HVCaseFK
	--		, PC1ID
	--		, OldID
	--		, TCDOB
	--		, PC1FullName
	--		, CurrentWorkerFullName
	--		, CurrentLevelName
	--		, FormDate
	--		, FormReviewed
	--		, FormOutOfWindow
	--		, FormMissing
	--		, case when (TimeBreastFed >= '04' and FormReviewed = 1 and FormOutOfWindow = 0 and FormMissing = 0) then 1 else 0 end as FormMeetsTarget
	--from cteExpectedForm
	-- order by OldID

end
GO
