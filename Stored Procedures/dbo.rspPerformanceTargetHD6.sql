SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <Febu. 28, 2013>
-- Description:	<gets you data for Performance Target report - HD6. Target Child Well Baby Medical Provider Visits by 27 months >
-- rspPerformanceTargetReportSummary 5 ,'10/01/2012' ,'12/31/2012'
-- rspPerformanceTargetReportSummary 5 ,'01/01/2012' ,'03/31/2012'

-- =============================================
CREATE procedure [dbo].[rspPerformanceTargetHD6]
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
		where dateadd(month,27,TCDOB)  < lastdate -- 27 months 
		and dateadd(month,33,TCDOB) > @StartDate  -- 33 months
		
	)	

	,
	cteWBV -- WellBabyVisit
	as
	(
	select coh.HVCaseFK
			, coh.TCIDPK
			, MedicalItemTitle
			, count(coh.TCIDPK) as WBVCount
			, count(case when dbo.IsFormReviewed(TCItemDate,'TM',TCMedicalPK) = 1 
					then 1 
					else 0 
					end) as FormReviewedCountWBV
		from cteCohort coh
			left join TCMedical WITH (NOLOCK) on TCMedical.hvcasefk = coh.hvcaseFK and TCMedical.TCIDFK = coh.TCIDPK
			inner join codeMedicalItem cmi on cmi.MedicalItemCode = TCMedical.TCMedicalItem
		where TCItemDate between dateadd(month,15,TCDOB) and dateadd(month,27,TCDOB)
				and MedicalItemTitle = 'WBV'
		group by coh.HVCaseFK
				, coh.TCIDPK
				, MedicalItemTitle
				
	)

	,
	cteWellBabyVisitCounts
	as
	(
		select 'HD6' as PTCode
			  , coh.HVCaseFK
			  , PC1ID
			  , OldID
			  , TCDOB
			  , PC1FullName
			  , CurrentWorkerFullName
			  , CurrentLevelName
			  , NULL as FormDate	
			  , case when WBVCount IS NULL OR WBVCount = FormReviewedCountWBV -- # of shots = # of forms reveiwed
					then 1 
					else 0 
					end as FormReviewed				
			, 0 as FormOutOfWindow -- not out of window
			, 0 as FormMissing
			, case when WBVCount >= 2 then 1 else 0 end as FormMeetsTarget
	 from cteCohort coh
	 LEFT join cteWBV wbv on wbv.HVCaseFK = coh.HVCaseFK AND coh.TCIDPK = wbv.TCIDPK 
	 
	),

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
				, 'TC Medical' as FormName 
				, FormDate
				, FormReviewed
				, FormOutOfWindow
				, FormMissing
				, FormMeetsTarget
				, case when FormMissing = 1 then 'Form missing'
						when FormOutOfWindow = 1 then 'Form out of window'
						when FormReviewed = 0 then 'Form not reviewed by supervisor'
						when FormReviewed = 1 and FormOutOfWindow = 0 and FormMissing = 0 
							then 'Missing Well Baby Visits'
						else '' end as ReasonNotMeeting
		from cteWellBabyVisitCounts
	)
	
	select * from cteMain

end
GO
