SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <Febu. 28, 2013>
-- Description:	<gets you data for Performance Target report - HD8. Medical Provider for Primary CareTaker 1 >
-- rspPerformanceTargetReportSummary 5 ,'10/01/2012' ,'12/31/2012'
-- rspPerformanceTargetReportSummary 15 ,'07/01/2013' ,'09/30/2013'
-- rspPerformanceTargetReportDetails 15 ,'07/01/2013' ,'09/30/2013'

-- =============================================
CREATE procedure [dbo].[rspPerformanceTargetHD8]
(
    @StartDate  datetime,
    @EndDate    datetime,
    @tblPTCases PTCases readonly
)

as
begin

	;
	with cteTotalCases
	as
		(
		select
			  ptc.HVCaseFK
			 ,ptc.PC1ID
			 ,ptc.OldID
			 ,ptc.PC1FullName
			 ,ptc.CurrentWorkerFK
			 ,ptc.CurrentWorkerFullName
			 ,ptc.CurrentLevelName
			 ,ptc.ProgramFK
			 ,ptc.TCIDPK
			 ,ptc.TCDOB
			 ,cp.DischargeDate
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
			 ,h.IntakeDate
			from @tblPTCases ptc
				inner join HVCase h WITH (NOLOCK) on ptc.hvcaseFK = h.HVCasePK
				inner join CaseProgram cp WITH (NOLOCK) on cp.CaseProgramPK = ptc.CaseProgramPK
				-- h.hvcasePK = cp.HVCaseFK and cp.ProgramFK = ptc.ProgramFK -- AND cp.DischargeDate IS NULL
		)
	,

	cteCohort
	as
		(
		select HVCaseFK
			  ,PC1ID
			  ,OldID
			  ,PC1FullName
			  ,CurrentWorkerFK
			  ,CurrentWorkerFullName
			  ,CurrentLevelName
			  ,ProgramFK
			  ,TCIDPK
			  ,TCDOB
			  ,DischargeDate
			  ,tcAgeDays
			  ,lastdate
			from cteTotalCases
			where DATEADD(dd,30,IntakeDate) <= lastdate --PC1's enrolled 30 days atleast
		)
	-- TC less than 6 months old (while doing TCID, a row is inserted into CommonAttribute table). There are no followups for tc < 6 mos
	-- There may be one or more CH Forms for TC < 6 months
	-- Question: Is a one Medical Provider per case - Yes (so twins etc have only one doc)
	,
	cteTCLessThan6MonthsINForm
	as
	(
		select c.HVCaseFK
				, cach.PC1HasMedicalProvider
				, 'Intake' as FormName
				, FormDate
				, FormFK
			from cteCohort c
				left join CommonAttributes cach WITH (NOLOCK) on cach.HVCaseFK = c.HVCaseFK and cach.FormType = 'IN'
			where c.tcAgeDays < 183
				 and FormDate <= @EndDate
	)
	,
	cteTCLessThan6MonthsCHForm
	as
		(
		select c.HVCaseFK
			  , case when cach.PC1MedicalFacilityFK is not null or cach.PC1MedicalProviderFK is not null
					then 1
					else 0
				end as PC1HasMedicalProvider
			  , 'Change Form' as FormName
			  , max(FormDate) as FormDate -- get the latest CH
			from cteCohort c
				left join CommonAttributes cach on cach.HVCaseFK = c.HVCaseFK and cach.FormType = 'CH'
			where c.tcAgeDays < 183
				 and FormDate <= @EndDate
			group by c.HVCaseFK
					, cach.PC1HasMedicalProvider
					, cach.PC1MedicalFacilityFK
					, cach.PC1MedicalProviderFK
		)
	,
	cteExpectedForm4TCLessThan6Months
	as
		(
		select 'HD8' as PTCode
			  ,c.HVCaseFK
			  ,PC1ID
			  ,OldID
			  ,TCDOB
			  ,PC1FullName
			  ,CurrentWorkerFullName
			  ,CurrentLevelName
			  -- latest of either Intake or CH
			  ,case 
					when (chl6.FormDate > inl6.FormDate or inl6.FormDate is null)
							and chl6.FormDate > '01/04/13' 
							-- and chl6.PC1HasMedicalProvider is not null and chl6.PC1HasMedicalProvider = 1 
						then 'Change Form'
					else
						'Intake'
						--case when inl6.PC1HasMedicalProvider is not null and inl6.PC1HasMedicalProvider = 1 
						--then 'Intake'
						--else null end
			   end as FormName
			  ,case
					when (chl6.FormDate > inl6.FormDate or inl6.FormDate is null)
							and chl6.FormDate > '01/04/13' 
							-- and chl6.PC1HasMedicalProvider is not null and chl6.PC1HasMedicalProvider = 1
						then chl6.FormDate -- note: preference is given to the latest CH record first, if there is one
					else -- note: otherwise we will use tcid record's info
						case 
							when inl6.FormDate is not null -- inl6.PC1HasMedicalProvider is not null and inl6.PC1HasMedicalProvider = 1 
								then inl6.FormDate 
							else null 
						end
			   end as FormDate
			  ,case -- there is no formreview for formtype = CH
					when (chl6.FormDate is not null) or	-- and cach.PC1HasMedicalProvider is not null
							(inl6.FormDate is not null		-- and cafu.PC1HasMedicalProvider is not null
								and dbo.IsFormReviewed(inl6.FormDate,'IN',inl6.FormFK) = 1)
						then 1
				   else 0
			   end
			   as FormReviewed
			  ,case -- Here FormOutOfWindow means that there must be an tcid record in CommonAttribute table for tc < 6 months
				   when (chl6.FormDate is not null) or		--  and chl6.TCHasMedicalProvider is not null
						(inl6.FormDate is not null) then 0	-- and inl6.TCHasMedicalProvider is not null
				   else
					   1
			   end as FormOutOfWindow
			  ,case 
				  -- there is at least we one of either TC or CH record in CommonAttribute table (FormDate belongs to CommonAttribute table)
				   when (chl6.FormDate is not null and 
						chl6.FormDate > '01/04/13') or		--  and chl6.TCHasMedicalProvider is not null
						(inl6.FormDate is not null) then 0	-- and inl6.TCHasMedicalProvider is not null
				   else
					   1
			   end as FormMissing
			  ,case
				   when chl6.PC1HasMedicalProvider is not null and chl6.FormDate > inl6.FormDate 
						and chl6.FormDate > '01/04/13' and chl6.PC1HasMedicalProvider = 1 -- latest of either TC or CH
					   then 1 -- note: preference is given to the latest CH record first, if there is one
				   else -- note: otherwise we will use tcid record's info
					   case when inl6.PC1HasMedicalProvider is not null and inl6.PC1HasMedicalProvider = 1 then 1 else 0 end
			   end as FormMeetsTarget
			from cteCohort c
				inner join cteTCLessThan6MonthsINForm inl6 on inl6.HVCaseFK = c.HVCaseFK
				left outer join cteTCLessThan6MonthsCHForm chl6 on chl6.hvcasefk = inl6.hvcasefk
		)

	--SELECT * FROM cteExpectedForm4TCLessThan6Months

	---- rspPerformanceTargetReportSummary 5 ,'10/01/2012' ,'12/31/2012'	

	-- TC 6 months or older
	,
	cteIntervals4TC6MonthsOrOlderTCForm -- age appropriate follow up that is due for the TC
	as
	(
	select HVCaseFK
		  ,TCIDPK
		  ,max(Interval) as Interval
		from cteCohort c
			left join codeDueByDates on ScheduledEvent = 'Follow Up' and c.tcAgeDays >= DueBy
		where c.tcAgeDays >= 183 and
			-- there are no 18 month follow ups (interval code '18') in foxpro, though they're there now
			-- therefore, they're not required until 2013
			Interval <> case when @StartDate >= '01/01/2013' then 'xx'
								else '18'
								end
		group by HVCaseFK
				,TCIDPK
	)
	,
	cteLatestCHForm4TC6MonthsOrOlder -- latest CH form for the TC
	as
	(
	select top 1 c.HVCaseFK
		  , cach.PC1HasMedicalProvider
		  , 'Change Form' as FormName
		  , max(FormDate) as FormDate -- get the latest CH
		from cteCohort c
			left join CommonAttributes cach on cach.HVCaseFK = c.HVCaseFK and cach.FormType = 'CH'
		where c.tcAgeDays >= 183
			 and FormDate <= @EndDate
		group by c.HVCaseFK
				,cach.PC1HasMedicalProvider
		order by FormDate desc
	)
	,
	cteExpectedForm4TC6MonthsOrOlder
	as
	(

	select 'HD8' as PTCode
		  ,c.HVCaseFK
		  ,PC1ID
		  ,OldID
		  ,TCDOB
		  ,PC1FullName
		  ,CurrentWorkerFullName
		  ,CurrentLevelName
		  , case 
				when cach.FormDate > cafu.FormDate and cach.FormDate > '01/04/13'
					then '1'
				when cafu.FormDate is null
					then '1'
				else
					fu.PC1InHome
			end as PC1InHome
		  , case
			   when (cach.FormDate > cafu.FormDate or cafu.FormDate is null) and 
					cach.FormDate > '01/04/13' 
					-- and cach.PC1HasMedicalProvider is not null and cach.PC1HasMedicalProvider = 1 -- latest CH first preferred
				   then 'Change Form' -- note: preference is given to the latest CH record first, if there is one

			   else -- note: otherwise we will use tcid record's info
					replace(rtrim(capp.AppCodeText),'s','') + ' Follow Up'
				 --  case when cafu.PC1HasMedicalProvider is not null and cafu.PC1HasMedicalProvider = 1 
					--then 'Follow Up' 
					--else null 
				 --  end
		   end as FormName
		  , case
			   when (cach.FormDate > cafu.FormDate or cafu.FormDate is null) and 
					cach.FormDate > '01/04/13' 
					-- and cach.PC1HasMedicalProvider is not null and cach.PC1HasMedicalProvider = 1 -- latest CH first preferred
				   then cach.FormDate -- note: preference is given to the latest CH record first, if there is one
			   else -- note: otherwise we will use tcid record's info
					case 
						when cafu.FormDate is not null -- cafu.PC1HasMedicalProvider is not null and cafu.PC1HasMedicalProvider = 1 
							then cafu.FormDate 
						else null 
					end
		   end as FormDate
		  , case
			   when (cach.FormDate is not null) or	-- and cach.PC1HasMedicalProvider is not null
					(cafu.FormDate is not null		-- and cafu.PC1HasMedicalProvider is not null
							and dbo.IsFormReviewed(cafu.FormDate,'FU',cafu.FormFK) = 1)
					then 1
			   else 0
		   end
		   as FormReviewed
		  , case 
			  -- Here FormOutOfWindow means that there must be either FU (Due now) or latest CH record in CommonAttribute table for tc >= 6 months
			   when (cach.FormDate is not null) or		--  and cach.PC1HasMedicalProvider is not null
					(cafu.FormDate is not null) then 0	-- and cafu.PC1HasMedicalProvider is not null
			   else
				   1
		   end as FormOutOfWindow
		  , case 
			  -- there is at least we one of either FU (Due now) or latest CH record in CommonAttribute table (FormDate belongs to CommonAttribute table)
			   when (cach.FormDate is not null and 
					cach.FormDate > '01/04/13') or		--  and cach.PC1HasMedicalProvider is not null
					(cafu.FormDate is not null) then 0	-- and cafu.PC1HasMedicalProvider is not null
			   else
				   1
		   end as FormMissing		  
		  , case
			   when cach.TCHasMedicalProvider is not null and 
					(cafu.FormDate is null or cach.FormDate > cafu.FormDate) and 
					cach.FormDate > '01/04/13' and cach.TCHasMedicalProvider = 1 -- latest CH first preferred
				   then 1 -- note: preference is given to the latest CH record first, if there is one
			   else -- note: otherwise we will use tcid record's info
				   case when cafu.PC1HasMedicalProvider is not null and cafu.PC1HasMedicalProvider = 1 then 1 else 0 end
		   end as FormMeetsTarget
		from cteCohort c
			inner join cteIntervals4TC6MonthsOrOlderTCForm tcGE6FUInterval on c.HVCaseFK = tcGE6FUInterval.HVCaseFK and 
				tcGE6FUInterval.TCIDPK = c.TCIDPK -- GE = Greater or Equal
			left join CommonAttributes cafu on cafu.HVCaseFK = c.HVCaseFK and cafu.FormType = 'FU' and tcGE6FUInterval.Interval = 
				cafu.FormInterval -- get the FU row
			left outer join codeApp capp on tcGE6FUInterval.Interval = AppCode and AppCodeGroup = 'TCAge' and 
												AppCodeUsedWhere like '%FU%'
			left join cteLatestCHForm4TC6MonthsOrOlder ch on ch.HVCaseFK = c.HVCaseFK
			left join CommonAttributes cach WITH (NOLOCK) on cach.HVCaseFK = ch.HVCaseFK and cach.FormType = 'CH' and cach.FormDate = ch.
				FormDate -- get the latest CH row	
			left join FollowUp fu WITH (NOLOCK) on fu.HVCaseFK = c.HVCaseFK and fu.FollowUpInterval = tcGE6FUInterval.Interval
		-- where fu.PC1InHome = '1'
	)
	-- combine the above two disconnected tables (one for tc < 6 and other for TC >= 6)
	, cteMain as
		(select PTCode
			   ,HVCaseFK
			   ,PC1ID
			   ,OldID
			   ,TCDOB
			   ,PC1FullName
			   ,CurrentWorkerFullName
			   ,CurrentLevelName
			   ,'1' as PC1InHome
			   ,FormName
			   ,FormDate
			   ,FormReviewed
			   ,FormOutOfWindow
			   ,FormMissing
			   ,FormMeetsTarget
					, case when FormMissing = 1 then 'Form missing'
							when FormOutOfWindow = 1 then 'Form out of window'
							when FormReviewed = 0 then 'Form not reviewed by supervisor'
							when FormReviewed = 1 and FormOutOfWindow = 0 and FormMissing = 0 and 
									FormMeetsTarget = 0 then 'No Medical Provider recorded'
							else '' end as NotMeetingReason
				from cteExpectedForm4TCLessThan6Months
			union
			select PTCode
				  ,HVCaseFK
				  ,PC1ID
				  ,OldID
				  ,TCDOB
				  ,PC1FullName
				  ,CurrentWorkerFullName
				  ,CurrentLevelName
				  ,PC1InHome
				  ,FormName
				  ,FormDate
				  ,FormReviewed
				  ,FormOutOfWindow
				  ,FormMissing
				  ,FormMeetsTarget
					, case when FormMissing = 1 then 'Form missing'
							when FormOutOfWindow = 1 then 'Form out of window'
							when FormReviewed = 0 then 'Form not reviewed by supervisor'
							when FormReviewed = 1 and FormOutOfWindow = 0 and FormMissing = 0 and 
									FormMeetsTarget = 0 then 'No Medical Provider recorded'
							else '' end as NotMeetingReason
				from cteExpectedForm4TC6MonthsOrOlder
		)
	
	select distinct isnull(PTCode,'HD8')
		  ,c.HVCaseFK
		  ,c.PC1ID
		  ,c.OldID
		  ,c.TCDOB
		  ,c.PC1FullName
		  ,isnull(c.CurrentWorkerFullName,m.CurrentWorkerFullName) as CurrentWorkerFullName
		  ,isnull(c.CurrentLevelName,m.CurrentLevelName) as CurrentLevelName
		  ,isnull(FormName,isnull(rtrim(cast(i.Interval as int)) + ' month Follow Up', 'Intake')) as FormName
		  ,FormDate
		  ,FormReviewed
		  ,FormOutOfWindow
		  ,isnull(FormMissing,1) as FormMissing
		  ,case when FormReviewed = 1 and FormOutOfWindow = 0 and (FormMissing is null or FormMissing = 0) and FormMeetsTarget = 1 then 1 else 0 end as FormMeetsTarget
		  ,isnull(NotMeetingReason, 'Form missing') as NotMeetingReason
	from cteCohort c
	left outer join cteMain m on c.HVCaseFK = m.HVCaseFK
	left outer join cteIntervals4TC6MonthsOrOlderTCForm i on i.HVCaseFK = c.HVCaseFK
	where PC1InHome is null or PC1InHome <> '0'
	-- order by c.PC1ID

end
GO
