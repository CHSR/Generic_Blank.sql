SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:	  <jrobohn>
-- Create date: <Feb. 17, 2016>
-- Description: <report: Credentialing 7-5 B. Administration of the Depression Screen (PHQ-2/9)>
-- Edit date: 
-- exec rspDepressionScreeningReferral 1, '2014-07-01', null, null, null, null, ''
-- =============================================
CREATE procedure [dbo].[rspDepressionScreeningReferral] (@ProgramFK varchar(max) = null
									, @CutoffDate date = null
									, @SupervisorFK int = null
									, @WorkerFK int = null
									, @PC1ID varchar(13) = ''
									, @SiteFK int = null
									, @CaseFiltersPositive varchar(100) = ''
									 )
as

if @ProgramFK is null
	begin
		select	@ProgramFK = substring((select	',' + ltrim(rtrim(str(HVProgramPK)))
										from	HVProgram
									   for
										xml	path('')
									   ), 2, 8000);
	end;
set @ProgramFK = replace(@ProgramFK, '"', '');
set @SiteFK = isnull(@SiteFK, 0);
set @PC1ID = isnull(@PC1ID, '');
set @CaseFiltersPositive = case	when @CaseFiltersPositive = '' then null
								else @CaseFiltersPositive
						   end;

with	cteMain
		  as (select	cp.HVCaseFK
					  , cp.PC1ID
					  , supervisor.FirstName as SupervisorFirstName
					  , supervisor.LastName as SupervisorLastName
					  , fsw.FirstName as WorkerFirstName
					  , fsw.LastName as WorkerLastname
					  , cp.CaseStartDate
					  , hc.KempeDate
					  , hc.IntakeDate
					  , hc.TCDOB
					  , hc.EDC
			  from		CaseProgram cp
			  inner join HVCase hc on hc.HVCasePK = cp.HVCaseFK
			  inner join dbo.SplitString(@ProgramFK, ',') on cp.ProgramFK = ListItem
			  inner join dbo.udfCaseFilters(@CaseFiltersPositive, '', @ProgramFK) cf on cf.HVCaseFK = cp.HVCaseFK
			  inner join Worker fsw on cp.CurrentFSWFK = fsw.WorkerPK
			  inner join WorkerProgram wp on wp.WorkerFK = fsw.WorkerPK
											 and wp.ProgramFK = ListItem
			  inner join Worker supervisor on wp.SupervisorFK = supervisor.WorkerPK
			  where		cp.DischargeDate is null
						and hc.IntakeDate >= @CutoffDate
						and datediff(month, hc.TCDOB, current_timestamp) >= 3 
					    and datediff(month, hc.TCDOB, hc.IntakeDate) <= 3 
						and cp.CurrentFSWFK = isnull(@WorkerFK, cp.CurrentFSWFK)
						and wp.SupervisorFK = isnull(@SupervisorFK, wp.SupervisorFK)
						and cp.PC1ID = case	when @PC1ID = '' then cp.PC1ID
											else @PC1ID
									   end
						and (case when @SiteFK = 0 then 1
								  when wp.SiteFK = @SiteFK then 1
								  else 0
							 end = 1)
			 ) 
		, ctePHQ
		  as (select	m.HVCaseFK
					  , m.PC1ID
					  , ltrim(rtrim(m.WorkerLastName)) + ', ' + ltrim(rtrim(m.WorkerFirstName)) as WorkerName
					  , ltrim(rtrim(m.SupervisorLastName)) + ', ' + ltrim(rtrim(m.SupervisorFirstName)) as SupervisorName
					  , ltrim(rtrim(tc.TCFirstName)) + ' ' + ltrim(rtrim(tc.TCLastName)) as TCName
					  , convert(varchar(12), tc.TCDOB, 101) as TCDOB
					  , convert(varchar(12), m.IntakeDate, 101) as IntakeDate
					  , tc.GestationalAge
					  , convert(varchar(12), p.DateAdministered, 101) as DateAdministered
					  , p.ParticipantRefused
					  , p.DepressionReferralMade
					  , p.Positive
					  , p.TotalScore
					  , p.FormInterval
					  , p.FormType
					  , case when p.Invalid = 1 then 'Invalid'
							 when p.Invalid = 0 then 'Valid'
							 else 'Unknown'
						end Validity
					  , case when m.TCDOB > p.DateAdministered then 'Prenatal Screen'
							 else 'Postnatal Screen'
						end as VisitTiming
			  from		cteMain m
			  inner join PHQ9 p on p.HVCaseFK = m.HVCaseFK
			  inner join TCID tc on tc.HVCaseFK = p.HVCaseFK
			  where		p.Invalid = 0
						and p.Positive = 1
			 ) 
		, ctePHQFinal
		  as (select distinct
					  p.WorkerName
					  , p.SupervisorName
					  , p.HVCaseFK
					  , p.PC1ID
					  , p.TCDOB
					  , p.IntakeDate
					  , p.FormType
					  , p.TotalScore
					  , p.DateAdministered
					  , p.DepressionReferralMade
					  , srm.ReferralDate
					  , srm.ServiceReceived
					  , srm.StartDate
			  from		ctePHQ as p
			  outer apply (select top 1 HVCaseFK
										, ReferralDate	
										, ServiceReceived
										, StartDate 
							from ServiceReferral sr 
							where sr.HVCaseFK = p.HVCaseFK and sr.ServiceCode in (49, 50)) srm
			 )
	, cteFinal 
	as (select distinct	WorkerName
				, SupervisorName
				, PC1ID
				, @CutoffDate as CutoffDate
				, case when sum(convert(int, DepressionReferralMade)) = 0 then 0 else 1 end as ReferralMade
				, case when sum(convert(int, DepressionReferralMade)) >= 1 or max(ReferralDate) is not null then 'Y' else 'N' end as MeetsStandard
				, max(ReferralDate) as ReferralDate
	from	ctePHQFinal
	group by WorkerName
				, SupervisorName
				, PC1ID
	)

	select	WorkerName
			, SupervisorName
			, @CutoffDate as CutoffDate
			, count(PC1ID) as TotalParticipants
			, sum(case when MeetsStandard = 'Y' then 1 else 0 end) as MeetingStandard
			, sum(case when MeetsStandard = 'N' then 1 else 0 end) as NotMeetingStandard
			, '0' as SortOrder
	from	cteFinal
	group by WorkerName
				, SupervisorName
	union all
	select '** All program workers' as WorkerName
			, 'N/A' as SupervisorName
			, @CutoffDate as CutoffDate
			, count(PC1ID) as TotalParticipants
			, sum(case when MeetsStandard = 'Y' then 1 else 0 end) as MeetingStandard
			, sum(case when MeetsStandard = 'N' then 1 else 0 end) as NotMeetingStandard
			, '1' as SortOrder
	from cteFinal
	order by SortOrder
				, WorkerName
	
GO
