SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:      <Dar Chen>
-- Create date: <Aug 13, 2012>
-- Description: 
-- =============================================
CREATE procedure [dbo].[rspPreAssessEngagement_Part2] (@programfk varchar(max) = null
													, @CustomQuarterlyDates bit = 1
													, @StartDt datetime = null
													, @EndDt datetime = null
													 )
as
	if @programfk is null
		begin
			select	@programfk = substring((select	',' + ltrim(rtrim(str(HVProgramPK)))
											from	HVProgram
										   for
											xml	path('')
										   ), 2, 8000)
		end
	set @programfk = replace(@programfk, '"', '')
	
	declare @ContractStartDate date
	declare @ContractEndDate date

	if ((@ProgramFK is not null) and (@CustomQuarterlyDates = 0))
	begin
		set @ProgramFK = replace(@ProgramFK, ',', '') -- remove comma's
		set @ContractStartDate = (select ContractStartDate
									  from HVProgram P
									  where HVProgramPK = @ProgramFK)
		set @ContractEndDate = (select ContractEndDate
									from HVProgram P
									where HVProgramPK = @ProgramFK)
	end

-- Pre-Assessment Engagement Quartly Report --
--DECLARE @ContractStartDate DATE = '01/01/2011'
--DECLARE @StartDt DATE = '08/01/2011'
--DECLARE @EndDt DATE = '12/31/2011'
--DECLARE @programfk INT = 6

;
	with	base1
			  as (select	d.DischargeCode
						  , d.DischargeReason
						  , case --when @CustomQuarterlyDates = 1 then null 
								 when xx.TerminatedNotAssigned is null then 0
								 else xx.TerminatedNotAssigned
							end [t1]
						  , case --when @CustomQuarterlyDates = 1 then null 
								 when xxx.SSTerminatedNotAssigned is null then 0
								 else xxx.SSTerminatedNotAssigned
							end [t2]
						  , case --when @CustomQuarterlyDates = 1 then null 
								 when yy.PositiveNotAssigned is null then 0
								 else yy.PositiveNotAssigned
							end [t3]
						  , case --when @CustomQuarterlyDates = 1 then null 
								 when yyy.SSPositiveNotAssigned is null then 0
								 else yyy.SSPositiveNotAssigned
							end [t4]
				  from		codeDischarge as d
				  left outer join (select	x.DischargeReason
										  , count(*) [TerminatedNotAssigned]
								   from		Preassessment x
								   join		(select	p.HVCaseFK
												  , max(p.PADate) [max_PADATE]
											 from	Preassessment as p
											 join	dbo.SplitString(@programfk, ',') on p.ProgramFK = ListItem
											 where	p.PADate between @StartDt and @EndDt --AND p.ProgramFK = @programfk
													and p.CaseStatus = '03'
											 group by p.HVCaseFK
											) as y on x.HVCaseFK = y.HVCaseFK
													  and x.PADate = y.max_PADATE
								   group by	x.DischargeReason
								  ) as xx on xx.DischargeReason = d.DischargeCode
--
				  left outer join (select	x.DischargeReason
										  , count(*) [PositiveNotAssigned]
								   from		Preassessment x
								   join		(select	p.HVCaseFK
												  , max(p.PADate) [max_PADATE]
											 from	Preassessment as p
											 join	dbo.SplitString(@programfk, ',') on p.ProgramFK = ListItem
											 where	p.PADate between @StartDt and @EndDt --AND p.ProgramFK = @programfk
													and p.CaseStatus = '04'
											 group by p.HVCaseFK
											) as y on x.HVCaseFK = y.HVCaseFK
													  and x.PADate = y.max_PADATE
								   group by	x.DischargeReason
								  ) as yy on yy.DischargeReason = d.DischargeCode
--
				  left outer join (select	x.DischargeReason
										  , count(*) [SSTerminatedNotAssigned]
								   from		Preassessment x
								   join		(select	p.HVCaseFK
												  , max(p.PADate) [max_PADATE]
											 from	Preassessment as p
											 join	dbo.SplitString(@programfk, ',') on p.ProgramFK = ListItem
											 where	p.PADate between @ContractStartDate and @ContractEndDate --AND p.ProgramFK = @programfk
													and p.CaseStatus = '03'
											 group by p.HVCaseFK
											) as y on x.HVCaseFK = y.HVCaseFK
													  and x.PADate = y.max_PADATE
								   group by	x.DischargeReason
								  ) as xxx on xxx.DischargeReason = d.DischargeCode
--
				  left outer join (select	x.DischargeReason
										  , count(*) [SSPositiveNotAssigned]
								   from		Preassessment x
								   join		(select	p.HVCaseFK
												  , max(p.PADate) [max_PADATE]
											 from	Preassessment as p
											 join	dbo.SplitString(@programfk, ',') on p.ProgramFK = ListItem
											 where	p.PADate between @ContractStartDate and @ContractEndDate --AND p.ProgramFK = @programfk
													and p.CaseStatus = '04'
											 group by p.HVCaseFK
											) as y on x.HVCaseFK = y.HVCaseFK
													  and x.PADate = y.max_PADATE
								   group by	x.DischargeReason
								  ) as yyy on yyy.DischargeReason = d.DischargeCode
				  where		d.DischargeUsedWhere like '%PA%'
				 ) ,
			base2
			  as (select	case when b.s1 = 0 then 1
								 else b.s1
							end s1
						  , case when b.s2 = 0 then 1
								 else b.s2
							end s2
						  , case when b.s3 = 0 then 1
								 else b.s3
							end s3
						  , case when b.s4 = 0 then 1
								 else b.s4
							end s4
				  from		(select	sum(a.t1) [s1]
								  , sum(a.t2) [s2]
								  , sum(a.t3) [s3]
								  , sum(a.t4) [s4]
							 from	base1 as a
							) as b
				 )
		select	a.DischargeReason
			  , a.t1
			  , cast(cast(case when b.s1 > 0 then round(100.0 * a.t1 / b.s1, 0)
							   else 0
						  end as int) as varchar(20)) + '%' p1
			  , a.t2
			  , cast(cast(case when b.s2 > 0 then round(100.0 * a.t2 / b.s2, 0)
							   else 0
						  end as int) as varchar(20)) + '%' p2
			  , a.t3
			  , cast(cast(case when b.s3 > 0 then round(100.0 * a.t3 / b.s3, 0)
							   else 0
						  end as int) as varchar(20)) + '%' p3
			  , a.t4
			  , cast(cast(case when b.s4 > 0 then round(100.0 * a.t4 / b.s4, 0)
							   else 0
						  end as int) as varchar(20)) + '%' p4
			  , s1
			  , s2
			  , s3
			  , s4
		from	base1 as a
		cross join base2 as b
		order by a.DischargeCode
GO
