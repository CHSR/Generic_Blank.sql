SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:	  <jrobohn>
-- Create date: <Feb. 17, 2016>
-- Description: <report: Credentialing 7-5 B. Administration of the Depression Screen (PHQ-2/9) - Summary>
-- Edit date: 
-- exec rspDepressionScreening 1, '2014-07-01', null, null, null, null, ''
-- =============================================
CREATE procedure [dbo].[rspDepressionScreening] (@ProgramFK varchar(max) = null
									, @CutoffDate date = null
									, @SupervisorFK int = null
									, @WorkerFK int = null
									, @PC1ID varchar(13) = ''
									, @SiteFK int = null
									, @CaseFiltersPositive varchar(100) = ''
									 )
with recompile
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
					  , cp.CaseStartDate
					  , supervisor.FirstName as SupervisorFirstName
					  , supervisor.LastName as SupervisorLastName
					  , fsw.FirstName as WorkerFirstName
					  , fsw.LastName as WorkerLastname
					  , ltrim(rtrim(tc.TCFirstName)) + ' ' + ltrim(rtrim(tc.TCLastName)) as TCName
					  , tc.GestationalAge
					  , hc.KempeDate
					  , hc.IntakeDate
					  , hc.TCDOB
					  , hc.EDC
					  , case when hc.TCDOB > hc.IntakeDate then 'Pre-natal'
							 else 'Post-natal'
						end as CaseTiming
			  from		CaseProgram cp
			  inner join HVCase hc on hc.HVCasePK = cp.HVCaseFK
			  --inner join dbo.SplitString(@ProgramFK, ',') on cp.ProgramFK = ListItem
			  --inner join dbo.udfCaseFilters(@CaseFiltersPositive, '', @ProgramFK) cf on cf.HVCaseFK = cp.HVCaseFK
			  inner join Worker fsw on cp.CurrentFSWFK = fsw.WorkerPK
			  inner join WorkerProgram wp on wp.WorkerFK = fsw.WorkerPK
											 and wp.ProgramFK = @ProgramFK
			  inner join Worker supervisor on wp.SupervisorFK = supervisor.WorkerPK
			  inner join TCID tc on tc.HVCaseFK = cp.HVCaseFK
			  where		cp.DischargeDate is null
						and hc.IntakeDate >= @CutoffDate
						and cp.ProgramFK = @ProgramFK
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
		  as (select distinct	
						m.PC1ID
					  , convert(varchar(12), p.DateAdministered, 101) as DateAdministered
					  , p.ParticipantRefused
					  , p.DepressionReferralMade
					  , p.Positive
					  , CaseTiming
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
			  left outer join PHQ9 p on p.HVCaseFK = m.HVCaseFK
			  where		p.Invalid = 0
					and p.DateAdministered <= dateadd(month, 3, TCDOB)
			 ) 
		--select * from ctePHQ

		, ctePHQPrePost
		  as (select distinct 
						m.WorkerFirstName
					  , m.WorkerLastname
					  , m.SupervisorFirstName
					  , m.SupervisorLastName
					  , m.PC1ID
					  , m.TCDOB
					  , m.IntakeDate
					  , m.CaseTiming as 'Status at Enrollment'
					  , case when pre.DateAdministered is not null
								  and pre.ParticipantRefused = 1 then 'Refused'
							 else pre.DateAdministered
						end as 'Date of Prenatal Screen'
					  , case when post.DateAdministered is not null
								  and post.ParticipantRefused = 1 then 'Refused'
							 else post.DateAdministered
						end as 'Date of Postnatal Screen'
					  , pre.FormType as [Prenatal FormType]
					  , post.FormType as [Postnatal FormType]
					  , pre.ParticipantRefused as ParticipantRefusedPrenatal
					  , post.ParticipantRefused as ParticipantRefusedPostnatal
			  from cteMain m
			  inner join ctePHQ p on m.PC1ID = p.PC1ID
			  --left outer join ctePHQ pre on pre.PC1ID = p.PC1ID and pre.VisitTiming = 'Prenatal Screen'
			  --left outer join ctePHQ post on post.PC1ID = p.PC1ID and post.VisitTiming = 'Prenatal Screen'
			  outer apply (select top 1
									DateAdministered
								  , b.ParticipantRefused
								  , b.FormType
						   from		ctePHQ as b
						   where	p.PC1ID = b.PC1ID
									and b.VisitTiming = 'Prenatal Screen'
						   order by	b.DateAdministered
						  ) as pre
			  outer apply (select top 1
									DateAdministered
								  , c.ParticipantRefused
								  , c.FormType
						   from		ctePHQ as c
						   where	p.PC1ID = c.PC1ID
									and c.VisitTiming = 'Postnatal Screen'
						   order by	c.DateAdministered
						  ) as post
			 )
		--select * from ctePHQPrePost
		--order by WorkerLastName
		--			, WorkerFirstName
		--			, PC1ID

		, ctePHQPreFinal 
		  as (select ltrim(rtrim(WorkerLastName)) + ', ' + ltrim(rtrim(WorkerFirstName)) as WorkerName
						, ltrim(rtrim(SupervisorLastName)) + ', ' + ltrim(rtrim(SupervisorFirstName)) as SupervisorName
						, PC1ID
						, TCDOB
						, IntakeDate
						, [Status at Enrollment]
						, case when [Status at Enrollment] = 'Post-natal' then 'N/A'
								else [Date of Prenatal Screen]
						end [Date of Prenatal Screen]
						, [Prenatal FormType]
						, [Date of Postnatal Screen]
						, [Postnatal FormType]
						, case when [Date of Postnatal Screen] is not null then datediff(month, TCDOB, [Date of Postnatal Screen])
								else -1
						end [Month Old for Postnatal Screen]
						, case when [Date of Prenatal Screen] is not null then datediff(month, [Date of Prenatal Screen], TCDOB)
								else -1
						end [Month Old for Prenatal Screen]
						, case when [Status at Enrollment] = 'Pre-natal' and (ParticipantRefusedPrenatal = 1 
																			or ([Date of Prenatal Screen] is not null 
																				and [Date of Postnatal Screen] is not null))
								then 'Y'
							when [Status at Enrollment] = 'Post-natal' and (ParticipantRefusedPostnatal = 1 
																			or [Date of Postnatal Screen] is not null)
								then 'Y'
							else 'N'
						end as MeetsStandard
				from	ctePHQPrePost
			)
		, ctePHQFinal
		  as (select distinct WorkerName
								, SupervisorName
								, [Status at Enrollment]
								, count(PC1ID) as Total
								--, sum(count(PC1ID)) over (partition by WorkerName order by WorkerName) as Total
								, sum(case when MeetsStandard = 'Y' then 1 else 0 end) as Meeting
								, sum(case when MeetsStandard = 'N' then 1 else 0 end) as NotMeeting
				from ctePHQPreFinal
				group by WorkerName
							, SupervisorName
							, [Status at Enrollment]
			)
		select WorkerName
			 , SupervisorName
			 , [Status at Enrollment]
			 , Total
			 --, Total1
			 , Meeting
			 , NotMeeting
			 , case when Total > 0 then round(Meeting / (Total * 1.0000), 2) 
					when Total = 0 then 0.00
				end as MeetingPercentage
			 , @CutoffDate as CutoffDate
			 , '0' as SortOrder
		from ctePHQFinal
		union all
		select '** All program workers' as WorkerName
			 , 'N/A' as SupervisorName
			 , [Status at Enrollment]
			 , sum(Total)
			 --, Total1
			 , sum(Meeting)
			 , sum(NotMeeting)
			 , case when sum(Total) > 0 then round(sum(Meeting) / (sum(Total) * 1.0000), 2) 
					when sum(Total) = 0 then 0.00
				end as MeetingPercentage
			 , @CutoffDate as CutoffDate
			 , '1' as SortOrder
		from ctePHQFinal
		group by [Status at Enrollment]
		order by SortOrder
					, WorkerName
					, [Status at Enrollment]
GO
