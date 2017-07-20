SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jrobohn
-- Create date: 20130303
-- Description:	gets data for Performance Target report - FLC7. Referrals for Needed Services
-- rspPerformanceTargetReportSummary 19, '07/01/2012', '09/30/2012', null, null, 0, null
-- rspPerformanceTargetReportSummary 19, '10/01/2012', '12/31/2012'
-- =============================================
CREATE procedure [dbo].[rspPerformanceTargetFLC7]
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
				, pc1i.DomesticViolence
				, pc1i.Depression
				, pc1i.MentalIllness
				, pc1i.AlcoholAbuse
				, pc1i.SubstanceAbuse
				, IntakeDate
			from cteTotalCases tc
			inner join HVCase c WITH (NOLOCK) on c.HVCasePK = tc.HVCaseFK
			inner join Kempe k WITH (NOLOCK) on k.HVCaseFK = c.HVCasePK
			inner join PC1Issues pc1i WITH (NOLOCK) on pc1i.PC1IssuesPK = k.PC1IssuesFK
			where datediff(day,IntakeDate,@StartDate) <= 365
				 and datediff(day,IntakeDate,lastdate) >= 183
				 and (pc1i.DomesticViolence = '1' or pc1i.Depression = '1' or pc1i.MentalIllness = '1' or 
						pc1i.AlcoholAbuse = '1' or pc1i.SubstanceAbuse = '1')
		)
	,
	cteReferrals
	as
		(
		select coh.*
				, ServiceReferralPK
				, ReferralDate
				, ServiceCode
				, ServiceReceived
				, case when dbo.IsFormReviewed(sr.ReferralDate,'SR',ServiceReferralPK) = 1 then 1 else 0 end as FormReviewed
				, 0 as FormOutOfWindow
				, 0 as FormMissing
				--, case when ReferralDate <= dateadd(day,183,IntakeDate) then 0 else 1 end as FormOutOfWindow
				--, case when ServiceReferralPK is null then 1 else 0 end as FormMissing
			from cteCohort coh
			left outer join ServiceReferral sr on sr.HVCaseFK = coh.HVCaseFK
			where DomesticViolence = '1' and ServiceCode = '51' and FamilyCode = '01'
		union 
		select coh.*
				, ServiceReferralPK
				, ReferralDate
				, ServiceCode
				, ServiceReceived
				, case when dbo.IsFormReviewed(sr.ReferralDate,'SR',ServiceReferralPK) = 1 then 1 else 0 end as FormReviewed
				, 0 as FormOutOfWindow
				, 0 as FormMissing
				--, case when ReferralDate <= dateadd(day,183,IntakeDate) then 0 else 1 end as FormOutOfWindow
				--, case when ServiceReferralPK is null then 1 else 0 end as FormMissing
			from cteCohort coh
			left outer join ServiceReferral sr WITH (NOLOCK) on sr.HVCaseFK = coh.HVCaseFK
			where (Depression = '1' or MentalIllness = '1') and (ServiceCode = '49' or ServiceCode = '50') and FamilyCode = '01'
		union 
		select coh.*
				, ServiceReferralPK
				, ReferralDate
				, ServiceCode
				, ServiceReceived
				, case when dbo.IsFormReviewed(sr.ReferralDate,'SR',ServiceReferralPK) = 1 then 1 else 0 end as FormReviewed
				, 0 as FormOutOfWindow
				, 0 as FormMissing
				--, case when ReferralDate <= dateadd(day,183,IntakeDate) then 0 else 1 end as FormOutOfWindow
				--, case when ServiceReferralPK is null then 1 else 0 end as FormMissing
			from cteCohort coh
			left outer join ServiceReferral sr WITH (NOLOCK) on sr.HVCaseFK = coh.HVCaseFK
			where (AlcoholAbuse = '1' or SubstanceAbuse = '1') and ServiceCode = '52' and FamilyCode = '01'
		)
	,
	cteSummarizedReferrals
	as
		(
		select HVCaseFK
				, count(HVCaseFK) as RefCount
				, sum(case when DomesticViolence = '1' and ServiceCode = '51' and FormReviewed = 1 then 1
							when (Depression = '1' or MentalIllness = '1') and (ServiceCode = '49' or ServiceCode = '50') and FormReviewed = 1 then 1
							when (AlcoholAbuse = '1' or SubstanceAbuse = '1') and ServiceCode = '52' and FormReviewed = 1 then 1
							else 0
						end) as GoodRefs
				, sum(FormReviewed) as FormReviewed
				, sum(FormOutOfWindow) as FormOutOfWindow
				, sum(FormMissing) as FormMissing
			from cteReferrals
			group by HVCaseFK
		)

		select distinct 'FLC7' as PTCode
				, c.HVCaseFK
				, PC1ID
				, OldID
				, TCDOB
				, PC1FullName
				, CurrentWorkerFullName
				, CurrentLevelName
				, 'Service Referrals' as FormName
				, null as FormDate -- ReferralDate as FormDate
				, isnull(case when RefCount is null then null when sr.FormReviewed = RefCount then 1 else 0 end, 1) as FormReviewed
				, isnull(sr.FormOutOfWindow, 0) as FormOutOfWindow
				, isnull(sr.FormMissing, 0) as FormMissing
				, case when GoodRefs >= RefCount then 1 else 0 end as FormMeetsTarget
				, case when sr.FormMissing = 1 then 'Form(s) missing'
						when sr.FormOutOfWindow = 1 then 'Form(s) out of window'
						when sr.FormReviewed <> RefCount then 'Form(s) not reviewed by supervisor'
						when GoodRefs is null or RefCount is null then 'Missing required referrals'
						when GoodRefs < RefCount then 'Missing required referrals'
						else '' end as ReasonNotMeeting
			from cteCohort c
			left outer join cteSummarizedReferrals sr on sr.HVCaseFK = c.HVCaseFK
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
