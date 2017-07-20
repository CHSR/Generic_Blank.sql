SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <Febu. 13, 2013>
-- Description:	<gets you data for Performance Target report - HD1. Immunizations at one year>
-- exec [rspPerformanceTargetHD1] '07/01/2012','09/30/2012','01',null,null
-- rspPerformanceTargetReportSummary 5 ,'10/01/2012' ,'12/31/2012'
-- testing siteFK below
-- rspPerformanceTargetReportSummary 1 ,'10/01/2012' ,'12/31/2012', null,1
-- mods by jrobohn 20130222 - clean up names, code and layout
-- =============================================
CREATE procedure [dbo].[rspPerformanceTargetHD1]
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
			inner join TCID t WITH (NOLOCK) on t.HVCaseFK = h.HVCasePK
			-- h.hvcasePK = cp.HVCaseFK and cp.ProgramFK = ptc.ProgramFK -- AND cp.DischargeDate IS NULL
		where t.NoImmunization is null or t.NoImmunization <> 1
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
		where datediff(day,tcdob,@StartDate) <= 548
			 and datediff(day,tcdob,lastdate) >= 365
	)
	,
	cteImmunizationsPolio
	as
	(
	select coh.HVCaseFK
			, coh.TCIDPK
			, MedicalItemTitle
			, count(coh.TCIDPK) as ImmunizationCountPolio
			, count(case when dbo.IsFormReviewed(TCItemDate,'TM',TCMedicalPK) = 1 
					then 1 
					else 0 
					end) as FormReviewedCountPolio
		from cteCohort coh
			left join TCMedical WITH (NOLOCK) on TCMedical.hvcasefk = coh.hvcaseFK and TCMedical.TCIDFK = coh.TCIDPK
			inner join codeMedicalItem cmi on cmi.MedicalItemCode = TCMedical.TCMedicalItem
		where TCItemDate between TCDOB and dateadd(dd,365,TCDOB)
				and MedicalItemTitle = 'Polio'
		group by coh.HVCaseFK
				, coh.TCIDPK
				, MedicalItemTitle
				
	)
	,
	cteImmunizationsDTaP
	as
	(
	select coh.HVCaseFK
			, coh.TCIDPK
			, MedicalItemTitle
			, count(coh.TCIDPK) as ImmunizationCountDTaP
			, count(case when dbo.IsFormReviewed(TCItemDate,'TM',TCMedicalPK) = 1 
					then 1 
					else 0 
					end) as FormReviewedCountDTaP
		from cteCohort coh
			left join TCMedical WITH (NOLOCK) on TCMedical.hvcasefk = coh.hvcaseFK and TCMedical.TCIDFK = coh.TCIDPK
			inner join codeMedicalItem cmi on cmi.MedicalItemCode = TCMedical.TCMedicalItem
		where TCItemDate between TCDOB and dateadd(dd,365,TCDOB)
				and MedicalItemTitle = 'DTaP'
				 group by coh.HVCaseFK
				, coh.TCIDPK
				, MedicalItemTitle
				
	)	
	,
	cteImmunizationCounts
	as
	(
		select 'HD1' as PTCode
			  , coh.HVCaseFK
			  , PC1ID
			  , OldID
			  , TCDOB
			  , PC1FullName
			  , CurrentWorkerFullName
			  , CurrentLevelName
			  , 'TC Medical' as FormName
			  , NULL as FormDate	
			  -- check that # of shots = # of forms reviewed
			  , case when ( (ImmunizationCountPolio is null or ImmunizationCountPolio = FormReviewedCountPolio) 
						AND (ImmunizationCountDTaP IS NULL OR ImmunizationCountDTaP = FormReviewedCountDTaP))
					then 1 
					else 0 
					end as FormReviewed				
			, 0 as FormOutOfWindow -- not out of window
			, 0 as FormMissing
			, case when ((ImmunizationCountDTaP >= 3) AND (ImmunizationCountPolio >= 2)) then 1 
					else 0 end as FormMeetsTarget
			, case when ((ImmunizationCountDTaP >= 3) AND (ImmunizationCountPolio >= 2)) then '' 
					else 'Missing Shots or Not on Time' end as NotMeetingReason
	 from cteCohort coh
	 left join cteImmunizationsPolio immPolio on immPolio.HVCaseFK = coh.HVCaseFK and coh.TCIDPK = immPolio.TCIDPK 
	 left join cteImmunizationsDTaP immDTaP on immDTaP.HVCaseFK = coh.HVCaseFK and coh.TCIDPK = immDTaP.TCIDPK 
	)

	select * from cteImmunizationCounts 

end
GO
