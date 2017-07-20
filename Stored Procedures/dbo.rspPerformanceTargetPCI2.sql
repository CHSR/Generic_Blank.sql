SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jrobohn
-- Create date: 20130226
-- Description:	gets data for Performance Target report - PCI2. Valid PSI assessments
-- rspPerformanceTargetReportSummary 19, '07/01/2012', '09/30/2012', null, null, 0, null
-- =============================================
CREATE procedure [dbo].[rspPerformanceTargetPCI2]
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
			from cteTotalCases tc
			inner join HVCase c WITH (NOLOCK) on c.HVCasePK = tc.HVCaseFK
			where dateadd(day, 30, case when IntakeDate > tc.tcdob then IntakeDate else tc.tcdob end) 
					between @StartDate and @EndDate -- dateadd(day,-29,@StartDate) and dateadd(day,62,@StartDate)
					and (DischargeDate > tc.TCDOB or DischargeDate is null or DischargeDate = '')
		)
	,
	--cteExpectedForm
	--as
	--	(
	--	select coh.HVCaseFK
	--			, PSIPK
	--		from cteCohort coh
	--		left outer join PSI P on coh.hvcaseFK = P.HVCaseFK 
	--		where PSIInterval = '00' -- in ('00','01','02')
	--	)
	--,
	cteMain
	as
		(select distinct 'PCI2' as PTCode
			  , coh.HVCaseFK
			  , PC1ID
			  , OldID
			  , TCDOB
			  , PC1FullName
			  , CurrentWorkerFullName
			  , CurrentLevelName
			  , 'Birth/Intake PSI' as FormName
			  , PSIDateComplete as FormDate		
			  , case when (PSIPK is not null and dbo.IsFormReviewed(PSIDateComplete,'PS',PSIPK) = 1) then 1 else 0 end as FormReviewed
			  , case when (PSIPK is not null and PSIInWindow = 1) then 0 else 1 end as FormOutOfWindow
			  , case when PSIPK is null then 1 else 0 end as FormMissing
			  --, case when PSIPK is not null then 1 else 0 end as FormMeetsTarget
			  from cteCohort coh
			  left outer join PSI P WITH (NOLOCK) on coh.HVCaseFK = P.HVCaseFK and PSIInterval = '00'
		)
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
			  , case when FormMissing = 0 
							and FormOutOfWindow = 0 
							and FormReviewed = 1 then 1 
						else 0 
				end as FormMeetsTarget
			  , case when FormMissing = 1 then 'Form missing'
						when FormOutOfWindow = 1 then 'Form out of window'
						when FormReviewed = 0 then 'Form not reviewed by supervisor'
						else '' end as ReasonNotMeeting
	from cteMain
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
