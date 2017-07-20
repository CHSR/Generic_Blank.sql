SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <Febu. 28, 2013>
-- Description:	<gets you data for Performance Target report - HD4. Medical Provider for target children>
-- rspPerformanceTargetReportSummary 5 ,'10/01/2012' ,'12/31/2012'
-- rspPerformanceTargetReportSummary 5 ,'01/01/2012' ,'03/31/2012'
-- rspPerformanceTargetReportSummary 2 ,'10/01/2012' ,'12/31/2012'
-- rspPerformanceTargetReportSummary 35 ,'10/01/2012' ,'12/31/2012'

-- =============================================
CREATE procedure [dbo].[rspPerformanceTargetHD4]
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
		where ((TCDOB > IntakeDate
			 and tcAgeDays > 30)
			 or (TCDOB <= IntakeDate
			 and DATEADD(dd,30,IntakeDate) <= lastdate)) -- Target children 30 days and older
	)

	-- TC less than 6 months old (while doing TCID, a row is inserted into CommonAttribute table). There are no followups for tc < 6 mos
	-- There may be one or more CH Forms for TC < 6 months
	-- Question: Is a one Medical Provider per case - Yes (so twins etc have only one doc)
	,
	cteTCLessThan6MonthsTCForm
	as
	(
	select c.HVCaseFK
		  , cach.TCHasMedicalProvider
		  , 'TC ID' as FormName
		  , FormDate
		  , TCIDPK
		  , TCDOB
		  , FormFK
		from cteCohort c
			left join CommonAttributes cach WITH (NOLOCK) on cach.HVCaseFK = c.HVCaseFK and cach.FormType = 'TC'
		where c.tcAgeDays < 183
			 and FormDate <= @EndDate
	)

	,
	cteTCLessThan6MonthsCHForm
	as
	(
	select c.HVCaseFK
		  , case when cach.TCMedicalFacilityFK is not null or cach.TCMedicalProviderFK is not null
				then 1
				else 0
			end as TCHasMedicalProvider
		  , 'Change Form' as FormName
		  , max(FormDate) as FormDate -- get the latest CH
		from cteCohort c
			left join CommonAttributes cach WITH (NOLOCK) on cach.HVCaseFK = c.HVCaseFK and cach.FormType = 'CH'
		where c.tcAgeDays < 183
			 and FormDate <= @EndDate
		group by c.HVCaseFK
				, cach.TCHasMedicalProvider
				, cach.TCMedicalFacilityFK
				, cach.TCMedicalProviderFK

	)

	,
	cteExpectedForm4TCLessThan6Months
	as
		(

		select 'HD4' as PTCode
			  ,c.HVCaseFK
			  ,PC1ID
			  ,OldID
			  ,c.TCDOB
			  ,PC1FullName
			  ,CurrentWorkerFullName
			  ,CurrentLevelName
			  -- latest of either TC or CH
			  ,case
					when (chl6.FormDate > tcl6.FormDate or tcl6.FormDate is null) 
							and chl6.FormDate > '01/04/13' 
							-- and chl6.TCHasMedicalProvider is not null and chl6.TCHasMedicalProvider = 1 -- latest CH first preferred
						then 'Change Form' -- note: preference is given to the latest CH record first, if there is one
					else -- note: otherwise we will use tcid record's info
						'TC ID'
					 --  case when tcl6.TCHasMedicalProvider is not null and tcl6.TCHasMedicalProvider = 1 
						--then 'Follow Up' 
						--else null end
			   end as FormName
			  ,case
					when (chl6.FormDate > tcl6.FormDate or tcl6.FormDate is null) 
							and chl6.FormDate > '01/04/13' 
							-- and chl6.TCHasMedicalProvider is not null and chl6.TCHasMedicalProvider = 1 -- latest CH first preferred
						then chl6.FormDate -- note: preference is given to the latest CH record first, if there is one
					else -- note: otherwise we will use tcid record's info
						case 
							when tcl6.FormDate is not null -- tcl6.TCHasMedicalProvider is not null and tcl6.TCHasMedicalProvider = 1 
								then tcl6.FormDate 
							else null 
						end
			   end as FormDate
			  ,case -- there is no formreview for formtype = CH
					when (chl6.FormDate is not null) or	-- and chl6.TCHasMedicalProvider is not null
							(tcl6.FormDate is not null		-- and tcl6.TCHasMedicalProvider is not null
								and dbo.IsFormReviewed(tcl6.FormDate,'TC',tcl6.FormFK) = 1)
						then 1
				   else 0
			   end
			   as FormReviewed
			  ,case -- Here FormOutOfWindow means that there must be either FU (Due now) or latest CH record in CommonAttribute table for tc >= 6 months
				   when (chl6.FormDate is not null) or		--  and chl6.TCHasMedicalProvider is not null
						(tcl6.FormDate is not null) then 0	-- and tcl6.TCHasMedicalProvider is not null
				   else
					   1
			   end as FormOutOfWindow
			  ,case 
				  -- there is at least we one of either FU (Due now) or latest CH record in CommonAttribute table (FormDate belongs to CommonAttribute table)
				   when (chl6.FormDate is not null and 
						chl6.FormDate > '01/04/13') or		--  and chl6.TCHasMedicalProvider is not null
						(tcl6.FormDate is not null) then 0	-- and tcl6.TCHasMedicalProvider is not null
				   else
					   1
			   end as FormMissing		  
			  ,case
				   when chl6.TCHasMedicalProvider is not null and chl6.FormDate > tcl6.FormDate and 
						chl6.FormDate > '01/04/13' and chl6.TCHasMedicalProvider = 1 -- latest CH first preferred
					   then 1 -- note: preference is given to the latest CH record first, if there is one
				   else -- note: otherwise we will use tcid record's info
					   case when tcl6.TCHasMedicalProvider is not null and tcl6.TCHasMedicalProvider = 1 then 1 else 0 end
			   end as FormMeetsTarget
			from cteCohort c
				inner join cteTCLessThan6MonthsTCForm tcl6 on tcl6.HVCaseFK = c.HVCaseFK
				left outer join cteTCLessThan6MonthsCHForm chl6 on chl6.hvcasefk = tcl6.hvcasefk
		)

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
			Interval <> case when @StartDate >= '01/01/2013' 
							then 'xx'
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
		  ,cach.TCHasMedicalProvider
		  ,'Change Form' as FormName
		  ,max(FormDate) as FormDate -- get the latest CH
		from cteCohort c
			left join CommonAttributes cach WITH (NOLOCK) on cach.HVCaseFK = c.HVCaseFK and cach.FormType = 'CH'
		where c.tcAgeDays >= 183
			 and FormDate <= @EndDate
		group by c.HVCaseFK
				, cach.TCHasMedicalProvider
		order by FormDate desc
	)

	-- the following are not used. left it here for future look up
	--	,
	--	cteIntervalNextFollowUp
	--	as
	--		(
	--			select HVCaseFK, TCIDPK				
	--					, min(Interval) as Interval
	--			from cteCohort
	--				LEFT join codeDueByDates on ScheduledEvent = 'Follow Up' and tcAgeDays < DueBy 
	--				WHERE Interval <> (SELECT dbd.Interval FROM codeDueByDates dbd WHERE dbd.EventDescription = '18 month Follow Up') -- there are no 18 months follow up in foxpro, but it is there in new HFNY. So need discussion w/JH. ... khalsa
	--			group by HVCaseFK, TCIDPK
	--		)

	--,
	--	cteChangeFormBeforeNextFollowUp
	--	as
	--		(

	--			SELECT c.HVCaseFK
	--			,  cach.TCHasMedicalProvider, max(FormDate) AS FormDate
	--			from cteCohort c	
	--			left join CommonAttributes cach on cach.HVCaseFK = c.HVCaseFK and cach.FormType='CH' 
	--			INNER JOIN cteIntervalNextFollowUp ctf ON ctf.HVCaseFK = c.HVCaseFK
	--			LEFT join codeDueByDates cd on ScheduledEvent = 'Follow Up' and cd.Interval = ctf.Interval  
	--			WHERE c.tcAgeDays >= 183
	--			AND 
	--			FormDate < DATEADD(dd,cd.DueBy,tcdob)
	--			GROUP BY c.HVCaseFK, cach.TCHasMedicalProvider

	--		)
	,
	cteExpectedForm4TC6MonthsOrOlder
	as
	(

	select 'HD4' as PTCode
		  ,c.HVCaseFK
		  ,PC1ID
		  ,OldID
		  ,TCDOB
		  ,PC1FullName
		  ,CurrentWorkerFullName
		  ,CurrentLevelName
		  ,case
			   when (cach.FormDate > cafu.FormDate or cafu.FormDate is null) and 
					cach.FormDate > '01/04/13' 
					-- and cach.TCHasMedicalProvider is not null and cach.TCHasMedicalProvider = 1 -- latest CH first preferred
				then 'Change Form' -- note: preference is given to the latest CH record first, if there is one

			   else -- note: otherwise we will use follow up record's info
					replace(rtrim(capp.AppCodeText),'s','') + ' Follow Up'
					--case when cafu.TCHasMedicalProvider is not null and cafu.TCHasMedicalProvider = 1 
					--		then 'Follow Up' 
					--	else null 
					--end
		   end as FormName
		  ,case
			   when (cach.FormDate > cafu.FormDate or cafu.FormDate is null) and 
					cach.FormDate > '01/04/13' 
					-- and cach.TCHasMedicalProvider is not null and cach.TCHasMedicalProvider = 1 -- latest CH first preferred
				   then cach.FormDate -- note: preference is given to the latest CH record first, if there is one

			   else -- note: otherwise we will use follow up record's info
					case 
						when cafu.FormDate is not null -- cafu.TCHasMedicalProvider is not null and cafu.TCHasMedicalProvider = 1 
							then cafu.FormDate 
						else null 
					end
		   end as FormDate
		  ,case
			   when (cach.FormDate is not null) or	-- and cach.TCHasMedicalProvider is not null
					(cafu.FormDate is not null		-- and cafu.TCHasMedicalProvider is not null
							and dbo.IsFormReviewed(cafu.FormDate,'FU',cafu.FormFK) = 1) 
					then 1
			   else 0
		   end
		   as FormReviewed
		  ,case 
			  -- Here FormOutOfWindow means that there must be either FU (Due now) or latest CH record in CommonAttribute table for tc >= 6 months
			   when (cach.FormDate is not null) or		-- and cach.TCHasMedicalProvider is not null
					(cafu.FormDate is not null) then 0	-- and cafu.TCHasMedicalProvider is not null
			   else
				   1
		   end as FormOutOfWindow
		  ,case 
			  -- there is at least one of either FU (Due now) or latest CH record in CommonAttribute table (FormDate belongs to CommonAttribute table)
			   when (cach.FormDate is not null and 
					cach.FormDate > '01/04/13') or		-- and cach.TCHasMedicalProvider is not null
					(cafu.FormDate is not null) then 0	-- and cafu.TCHasMedicalProvider is not null
			   else
				   1
		   end as FormMissing
		  ,case
			   when cach.TCHasMedicalProvider is not null and 
					(cafu.FormDate is null or cach.FormDate > cafu.FormDate) and 
					cach.FormDate > '01/04/13' and cach.TCHasMedicalProvider = 1 -- latest CH first preferred
				   then 1 -- note: preference is given to the latest CH record first, if there is one
			   else -- note: otherwise we will use tcid record's info
				   case when cafu.TCHasMedicalProvider is not null and cafu.TCHasMedicalProvider = 1 then 1 else 0 end
		   end as FormMeetsTarget
		from cteCohort c
			inner join cteIntervals4TC6MonthsOrOlderTCForm tcGE6FUInterval on c.HVCaseFK = tcGE6FUInterval.HVCaseFK 
																				and tcGE6FUInterval.TCIDPK = c.TCIDPK -- GE = Greater or Equal
			left outer join codeApp capp on tcGE6FUInterval.Interval = AppCode and AppCodeGroup = 'TCAge' and 
												AppCodeUsedWhere like '%FU%'
			left join CommonAttributes cafu WITH (NOLOCK) on cafu.HVCaseFK = c.HVCaseFK and cafu.FormType = 'FU' 
												and tcGE6FUInterval.Interval = cafu.FormInterval -- get the FU row
			left join cteLatestCHForm4TC6MonthsOrOlder ch on ch.HVCaseFK = c.HVCaseFK
			left join CommonAttributes cach WITH (NOLOCK) on cach.HVCaseFK = ch.HVCaseFK and cach.FormType = 'CH' 
												and cach.FormDate = ch.FormDate -- get the latest CH row	
	)
	-- combine the above two disconnected tables (one for tc < 6 and other for TC >= 6)
	, 
	cteMain 
	as
		(select PTCode
				,HVCaseFK
				,PC1ID
				,OldID
				,TCDOB
				,PC1FullName
				,CurrentWorkerFullName
				,CurrentLevelName
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
			select  PTCode
					,HVCaseFK
					,PC1ID
					,OldID
					,TCDOB
					,PC1FullName
					,CurrentWorkerFullName
					,CurrentLevelName
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
		
	--select * from tcid where HVCaseFK in (55811,56014,56074,56189,56388)
	---- rspPerformanceTargetReportSummary 5 ,'10/01/2012' ,'12/31/2012'	

	-- for the final join 
	select distinct isnull(PTCode,'HD4')
				    , c.HVCaseFK
					, c.PC1ID,c.OldID
					, c.TCDOB
					, c.PC1FullName
					, isnull(c.CurrentWorkerFullName,c.CurrentWorkerFullName) as CurrentWorkerFullName
					, isnull(c.CurrentLevelName,m.CurrentLevelName) as CurrentLevelName
					, isnull(FormName,isnull(rtrim(cast(i.Interval as int)) + ' month Follow Up', 'TC ID')) as FormName
					, FormDate
					, FormReviewed
					, FormOutOfWindow
					, isnull(FormMissing,1) as FormMissing
					, case when FormReviewed = 1 and FormOutOfWindow = 0 and FormMissing = 0 and FormMeetsTarget = 1
							then 1
							else 0
						end as FormMeetsTarget
					, isnull(NotMeetingReason, 'Form missing')
	from cteCohort c
	left outer join cteMain m on c.HVCaseFK = m.HVCaseFK
	left outer join cteIntervals4TC6MonthsOrOlderTCForm i on i.HVCaseFK = c.HVCaseFK
	-- order by c.HVCaseFK

end
GO
