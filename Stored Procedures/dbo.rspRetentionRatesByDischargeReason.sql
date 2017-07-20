SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jrobohn
-- Create date: 03/31/11
-- Description:	Main storedproc for Retention Rate report
-- exec rspRetentionRatesByDischargeReason 19, '04/01/09', '03/31/11'

-- exec rspRetentionRatesByDischargeReason 1, '03/01/10', '02/29/12'
-- exec rspRetentionRatesByDischargeReason 1, '10/01/12', '02/28/13'


-- Fixed Bug HW963 - Retention Rage Report ... Khalsa 3/20/2014
-- =============================================
-- Author:    <Jay Robohn>
-- Description: <copied from FamSys Feb 20, 2012 - see header below>
-- =============================================
CREATE procedure [dbo].[rspRetentionRatesByDischargeReason]
	-- Add the parameters for the stored procedure here
	@ProgramFK varchar(max)
	, @StartDate datetime
	, @EndDate datetime
    , @WorkerFK int = null
	, @SiteFK int = null
	, @CaseFiltersPositive varchar(100) = ''
as
begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set nocount on;
--region declarations
print @programfk
print @startdate
print @enddate

	set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0
					   else @SiteFK
				  end
	set @casefilterspositive = case	when @casefilterspositive = '' then null
									else @casefilterspositive
							   end

	declare @tblResults table (
		LineDescription varchar(50)
		, LineGroupingLevel int
		, DisplayPercentages bit
		, TotalEnrolledParticipants int
		, RetentionRateSixMonths decimal(5,3)
		, RetentionRateOneYear decimal(5,3)
		, RetentionRateEighteenMonths decimal(5,3)
		, RetentionRateTwoYears decimal(5,3)
		, EnrolledParticipantsSixMonths int
		, EnrolledParticipantsOneYear int
		, EnrolledParticipantsEighteenMonths int
		, EnrolledParticipantsTwoYears int
		, RunningTotalDischargedSixMonths int
		, RunningTotalDischargedOneYear int
		, RunningTotalDischargedEighteenMonths int
		, RunningTotalDischargedTwoYears int
		, TotalNSixMonths int
		, TotalNOneYear int
		, TotalNEighteenMonths int
		, TotalNTwoYears int
		, AllParticipants int
		, SixMonthsDischarge int
		, OneYearDischarge int
		, EighteenMonthsDischarge int
		, TwoYearsDischarge int);
	
	declare @tblPC1withStats table (
		PC1ID char(13)
		, IntakeDate datetime
		, DischargeDate datetime
		, ReportDischargeText char(80)
		, LastHomeVisit datetime
		, RetentionMonths int
		, ActiveAt6Months int
		, ActiveAt12Months int
		, ActiveAt18Months int
		, ActiveAt24Months int);
	
--#endregion
--#region cteCohort - Get the cohort for the report
	with cteCohort as
	-----------------------
		(select HVCasePK
			from HVCase h 
			inner join CaseProgram cp on cp.HVCaseFK = h.HVCasePK
			inner join dbo.SplitString(@ProgramFK, ',') ss on ss.ListItem = cp.ProgramFK
			inner join dbo.udfCaseFilters(@casefilterspositive, '', @programfk) cf on cf.HVCaseFK = h.HVCasePK
			left outer join Worker w on w.WorkerPK = cp.CurrentFSWFK
			left outer join WorkerProgram wp on wp.WorkerFK = w.WorkerPK and wp.ProgramFK = cp.ProgramFK
			where case when @SiteFK = 0 then 1
							 when wp.SiteFK = @SiteFK then 1
							 else 0
						end = 1
				and (IntakeDate is not null and IntakeDate between @StartDate and @EndDate)
				and  w.WorkerPK = isnull(@WorkerFK, w.WorkerPK)
				-- and cp.ProgramFK=@ProgramFK
		)	

	--select * 
	--from cteCohort
	--order by HVCasePK

	--select HVCasePK, count(HVCasePK)
	--from cteCohort
	--group by HVCasePK
	--having count(HVCasePK) > 1
	
--#endregion
--#region cteCaseLastHomeVisit - get the last home visit for each case in the cohort 
	, cteCaseLastHomeVisit AS 
	-----------------------------
		(select HVCaseFK
				  , max(vl.VisitStartTime) as LastHomeVisit
				  , count(vl.VisitStartTime) as CountOfHomeVisits
			from HVLog vl
			inner join HVCase c on c.HVCasePK = vl.HVCaseFK
			inner join dbo.SplitString(@ProgramFK, ',') ss on ss.ListItem = vl.ProgramFK
			inner join cteCohort co on co.HVCasePK = c.HVCasePK
			where VisitType <> '0001' and 
					(IntakeDate is not null and IntakeDate between @StartDate and @EndDate)
							 -- and vl.ProgramFK = @ProgramFK
			group by HVCaseFK
		)
	
--select * 
--from cteCaseLastHomeVisit

--#endregion
--#region cteMain - main select for the report sproc, gets data at intake and joins to data at discharge
	, cteMain as
	------------------------
	(select PC1ID
		   ,IntakeDate
		   ,LastHomeVisit
		   ,DischargeDate
		   ,cp.DischargeReason as DischargeReasonCode
		   ,cd.ReportDischargeText
			,case
				when DischargeDate is null and datediff(month, IntakeDate, current_timestamp) > 6 then 1
				when DischargeDate is not null and datediff(month, IntakeDate, LastHomeVisit) > 6 then 1
					else 0
				end	as ActiveAt6Months
			,case
				when DischargeDate is null and datediff(month, IntakeDate, current_timestamp) > 12 then 1
				when DischargeDate is not null and datediff(month, IntakeDate, LastHomeVisit) > 12 then 1
					else 0
				end	as ActiveAt12Months
			,case
				when DischargeDate is null and datediff(month, IntakeDate, current_timestamp) > 18 then 1
				when DischargeDate is not null and datediff(month, IntakeDate, LastHomeVisit) > 18 then 1
					else 0
				end as ActiveAt18Months
			,case
				when DischargeDate is null and datediff(month, IntakeDate, current_timestamp) > 24 then 1
				when DischargeDate is not null and datediff(month, IntakeDate, LastHomeVisit) > 24 then 1
					else 0
				end as ActiveAt24Months
	 from HVCase c
		inner join cteCaseLastHomeVisit lhv on lhv.HVCaseFK = c.HVCasePK
		inner join CaseProgram cp on cp.HVCaseFK = c.HVCasePK
		inner join dbo.SplitString(@ProgramFK, ',') ss on ss.ListItem = cp.ProgramFK
		 left outer join dbo.codeDischarge cd on cd.DischargeCode = cp.DischargeReason and DischargeUsedWhere like '%DS%'
	 where (IntakeDate is not null
		  and IntakeDate between @StartDate and @EndDate)
		  --and cp.ProgramFK = @ProgramFK
	)

--select *
--from cteMain
--where DischargeReasonCode is NULL or DischargeReasonCode not in ('07', '17', '18', '20', '21', '23', '25', '37') 
--order by DischargeReasonCode, PC1ID

--#endregion
--#region Add rows to @tblPC1withStats for each case/pc1id in the cohort, which will create the basis for the final stats
insert into @tblPC1withStats
	select distinct pc1id
				   ,IntakeDate
				   ,DischargeDate
				   ,d.ReportDischargeText
				   ,LastHomeVisit
				   ,case when DischargeDate is not null then 
						datediff(mm,IntakeDate,LastHomeVisit)
					else
						datediff(mm,IntakeDate,current_timestamp)
					end as RetentionMonths
					
				   ,ActiveAt6Months
				   ,ActiveAt12Months
				   ,ActiveAt18Months
				   ,ActiveAt24Months
		from cteMain
			left outer join codeDischarge d on cteMain.DischargeReasonCode = DischargeCode -- and 
		-- where DischargeReason not in ('Out of Geographical Target Area','Miscarriage/Pregnancy Terminated','Target Child Died')
		where DischargeReasonCode is null
			 or DischargeReasonCode not in ('07', '17', '18', '20', '21', '23', '25', '37') 
		order by ReportDischargeText
				,PC1ID
				,IntakeDate
--#endregion

DECLARE @TotalCohortCount int

-- now we have all the rows from the cohort in @tblPC1withStats
-- get the total count
select @TotalCohortCount = COUNT(*) 
  FROM @tblPC1withStats

--#region declare vars to collect counts for final stats
declare @LineGroupingLevel int
		, @TotalEnrolledParticipants int
		, @RetentionRateSixMonths decimal(5,3)
		, @RetentionRateOneYear decimal(5,3)
		, @RetentionRateEighteenMonths decimal(5,3)
		, @RetentionRateTwoYears decimal(5,3)
		, @EnrolledParticipantsSixMonths int
		, @EnrolledParticipantsOneYear int
		, @EnrolledParticipantsEighteenMonths int
		, @EnrolledParticipantsTwoYears int
		, @RunningTotalDischargedSixMonths int
		, @RunningTotalDischargedOneYear int
		, @RunningTotalDischargedEighteenMonths int
		, @RunningTotalDischargedTwoYears int
		, @TotalNSixMonths int
		, @TotalNOneYear int
		, @TotalNEighteenMonths int
		, @TotalNTwoYears int

declare @AllEnrolledParticipants int
		, @SixMonthsTotal int
		, @TwelveMonthsTotal int
		, @EighteenMonthsTotal int
		, @TwentyFourMonthsTotal int
		, @SixMonthsAtDischarge int
		, @TwelveMonthsAtDischarge int
		, @EighteenMonthsAtDischarge int
		, @TwentyFourMonthsAtDischarge int
--#endregion
--#region Retention Rate %
select @SixMonthsTotal = count(PC1ID)
from @tblPC1withStats
where ActiveAt6Months=1

select @TwelveMonthsTotal = count(PC1ID)
from @tblPC1withStats
where ActiveAt12Months=1

select @EighteenMonthsTotal = count(PC1ID)
from @tblPC1withStats
where ActiveAt18Months=1

select @TwentyFourMonthsTotal = count(PC1ID)
from @tblPC1withStats
where ActiveAt24Months=1

set @RetentionRateSixMonths = case when @TotalCohortCount=0 then 0.0000 else round((@SixMonthsTotal / (@TotalCohortCount * 1.0000)),4) end
set @RetentionRateOneYear = case when @TotalCohortCount=0 then 0.0000 else round((@TwelveMonthsTotal / (@TotalCohortCount * 1.0000)),4) end
set @RetentionRateEighteenMonths = case when @TotalCohortCount=0 then 0.0000 else round((@EighteenMonthsTotal / (@TotalCohortCount * 1.0000)),4) end
set @RetentionRateTwoYears = case when @TotalCohortCount=0 then 0.0000 else round((@TwentyFourMonthsTotal / (@TotalCohortCount * 1.0000)),4) end
--#endregion
--#region Enrolled Participants
select @EnrolledParticipantsSixMonths = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and (LastHomeVisit is NULL or LastHomeVisit >= dateadd(day, 6*30.44, IntakeDate)) -- and dateadd(day, 12*30.44, IntakeDate)

select @EnrolledParticipantsOneYear = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and (LastHomeVisit is NULL or LastHomeVisit > dateadd(day, 12*30.44, IntakeDate)) -- and dateadd(day, 18*30.44, IntakeDate)

select @EnrolledParticipantsEighteenMonths = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and (LastHomeVisit is NULL or LastHomeVisit > dateadd(day, 18*30.44, IntakeDate)) -- and dateadd(day, 24*30.44, IntakeDate)

select @EnrolledParticipantsTwoYears = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and (LastHomeVisit is NULL or LastHomeVisit > dateadd(day, 24*30.44, IntakeDate))
--select @EnrolledParticipantsSixMonths = count(*)
--from @tblPC1withStats
--where ActiveAt6Months=1 and DischargeDate between dateadd(day, 6*30.44, IntakeDate) and dateadd(day, 12*30.44, IntakeDate)

--select @EnrolledParticipantsOneYear = count(*)
--from @tblPC1withStats
--where ActiveAt12Months=1 and DischargeDate between dateadd(day, 12*30.44, IntakeDate) and dateadd(day, 18*30.44, IntakeDate)

--select @EnrolledParticipantsEighteenMonths = count(*)
--from @tblPC1withStats
--where ActiveAt18Months=1 and DischargeDate between dateadd(day, 18*30.44, IntakeDate) and dateadd(day, 24*30.44, IntakeDate)

--select @EnrolledParticipantsTwoYears = count(*)
--from @tblPC1withStats
--where ActiveAt24Months=1 and DischargeDate > dateadd(day, 24*30.44, IntakeDate)
--#endregion
--#region Running Total Discharged
select @RunningTotalDischargedSixMonths = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and LastHomeVisit is not null

select @RunningTotalDischargedOneYear = count(*) + @RunningTotalDischargedSixMonths
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and LastHomeVisit is not null

select @RunningTotalDischargedEighteenMonths = count(*) + @RunningTotalDischargedOneYear
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and LastHomeVisit is not null

select @RunningTotalDischargedTwoYears = count(*) + @RunningTotalDischargedEighteenMonths
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and LastHomeVisit is not null
-----------------------------------------------------------
--select @RunningTotalDischargedSixMonths = count(*)
--from @tblPC1withStats
--where ActiveAt6Months=1 and DischargeDate is not null

--select @RunningTotalDischargedOneYear = count(*) + @RunningTotalDischargedSixMonths
--from @tblPC1withStats
--where ActiveAt12Months=1 and DischargeDate is not null

--select @RunningTotalDischargedEighteenMonths = count(*) + @RunningTotalDischargedOneYear
--from @tblPC1withStats
--where ActiveAt18Months=1 and DischargeDate is not null

--select @RunningTotalDischargedTwoYears = count(*) + @RunningTotalDischargedEighteenMonths
--from @tblPC1withStats
--where ActiveAt24Months=1 and DischargeDate is not null
-----------------------------------------------------------
--select @RunningTotalDischargedSixMonths = count(*)
--from @tblPC1withStats
--where ActiveAt6Months = 0 and LastHomeVisit between IntakeDate and dateadd(day, 6*30.44, IntakeDate)
--
--select @RunningTotalDischargedOneYear = count(*) + @RunningTotalDischargedSixMonths
--from @tblPC1withStats
--where ActiveAt12Months = 0 and LastHomeVisit between dateadd(day, (6*30.44)+1, IntakeDate) and dateadd(day, 12*30.44, IntakeDate)
--
--select @RunningTotalDischargedEighteenMonths = count(*) + @RunningTotalDischargedOneYear
--from @tblPC1withStats
--where ActiveAt18Months = 0 and LastHomeVisit between dateadd(day, (12*30.44)+1, IntakeDate) and dateadd(day, 18*30.44, IntakeDate)
--
--select @RunningTotalDischargedTwoYears = count(*) + @RunningTotalDischargedEighteenMonths
--from @tblPC1withStats
--where ActiveAt24Months = 0 and LastHomeVisit between dateadd(day, (18*30.44)+1, IntakeDate) and dateadd(day, 24*30.44, IntakeDate)
--#endregion
--#region Total (N) - (Discharged)
select @TotalNSixMonths = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and LastHomeVisit is not null

select @TotalNOneYear = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and LastHomeVisit is not null

select @TotalNEighteenMonths = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and LastHomeVisit is not null

select @TotalNTwoYears = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and LastHomeVisit is not null
--#endregion

--select *
--from @tblPC1withStats
;
with cteLast as
(
select @LineGroupingLevel as LineGroupingLevel
		,case when datediff(ww,@enddate,getdate()) >= 26 then @TotalCohortCount else null end as TotalEnrolledParticipants
		
		,case when datediff(ww,@enddate,getdate()) >= 26 then @RetentionRateSixMonths else null end as RetentionRateSixMonths
		,case when datediff(ww,@enddate,getdate()) >= 52 then @RetentionRateOneYear else null end as RetentionRateOneYear
		,case when datediff(ww,@enddate,getdate()) >= 78 then @RetentionRateEighteenMonths else null end as RetentionRateEighteenMonths
		,case when datediff(ww,@enddate,getdate()) >= 104 then @RetentionRateTwoYears else null end as RetentionRateTwoYears
		
		,case when datediff(ww,@enddate,getdate()) >= 26 then @EnrolledParticipantsSixMonths else null end as EnrolledParticipantsSixMonths
		,case when datediff(ww,@enddate,getdate()) >= 52 then @EnrolledParticipantsOneYear else null end as EnrolledParticipantsOneYear
		,case when datediff(ww,@enddate,getdate()) >= 78 then @EnrolledParticipantsEighteenMonths else null end as EnrolledParticipantsEighteenMonths
		,case when datediff(ww,@enddate,getdate()) >= 104 then @EnrolledParticipantsTwoYears else null end as EnrolledParticipantsTwoYears
		
		,case when datediff(ww,@enddate,getdate()) >= 26 then @RunningTotalDischargedSixMonths else null end as RunningTotalDischargedSixMonths
		,case when datediff(ww,@enddate,getdate()) >= 52 then @RunningTotalDischargedOneYear else null end as RunningTotalDischargedOneYear
		,case when datediff(ww,@enddate,getdate()) >= 78 then @RunningTotalDischargedEighteenMonths else null end as RunningTotalDischargedEighteenMonths
	    ,case when datediff(ww,@enddate,getdate()) >= 104 then @RunningTotalDischargedTwoYears else null end as RunningTotalDischargedTwoYears
		
		
		,case when datediff(ww,@enddate,getdate()) >= 26 then @TotalNSixMonths else null end as TotalNSixMonths
		,case when datediff(ww,@enddate,getdate()) >= 52 then @TotalNOneYear else null end as TotalNOneYear
		,case when datediff(ww,@enddate,getdate()) >= 78 then @TotalNEighteenMonths else null end as TotalNEighteenMonths
		,case when datediff(ww,@enddate,getdate()) >= 104 then @TotalNTwoYears else null end as TotalNTwoYears
		
		
		
		,case when datediff(ww,@enddate,getdate()) >= 26 then @SixMonthsTotal else null end as SixMonthsTotal
		,case when datediff(ww,@enddate,getdate()) >= 52 then @TwelveMonthsTotal else null end as TwelveMonthsTotal
		,case when datediff(ww,@enddate,getdate()) >= 78 then @EighteenMonthsTotal else null end as EighteenMonthsTotal
		,case when datediff(ww,@enddate,getdate()) >= 104 then @TwentyFourMonthsTotal else null end as TwentyFourMonthsTotal
		
		,case when datediff(ww,@enddate,getdate()) >= 26 then @SixMonthsAtDischarge else null end as SixMonthsAtDischarge
		,case when datediff(ww,@enddate,getdate()) >= 52 then @TwelveMonthsAtDischarge else null end as TwelveMonthsAtDischarge
		,case when datediff(ww,@enddate,getdate()) >= 78 then @EighteenMonthsAtDischarge else null end as EighteenMonthsAtDischarge
		,case when datediff(ww,@enddate,getdate()) >= 104 then @TwentyFourMonthsAtDischarge else null end as TwentyFourMonthsAtDischarge
		, ReportDischargeText
		
		
		,
		sum(case when ActiveAt6Months = 0 or ActiveAt12Months = 0 
						or ActiveAt18Months = 0 or ActiveAt24Months = 0 
					then 1 else 0 end)
		 as SumDischargedBefore24Months
					
		
		,case when datediff(ww,@enddate,getdate()) >= 26 then 
			sum(case when ActiveAt6Months = 0 then 1 else 0 end) 
		 else null end as SumDischargedBefore6Months
			
		
		,case when datediff(ww,@enddate,getdate()) >= 52 then 
			sum(case when ActiveAt6Months = 1 and ActiveAt12Months = 0 then 1 else 0 end) 
		 else null end as SumDischargedBetween6And12Months
		
		,case when datediff(ww,@enddate,getdate()) >= 78 then 
			sum(case when ActiveAt12Months = 1 and ActiveAt18Months = 0 then 1 else 0 end) 
		else null end as SumDischargedBetween12And18Months
		
		,case when datediff(ww,@enddate,getdate()) >= 104 then 
			sum(case when ActiveAt18Months = 1 and ActiveAt24Months = 0 then 1 else 0 end) 
		else null end as SumDischargedBetween18And24Months
		
from @tblPC1withStats
where ReportDischargeText is not null
		and case when ActiveAt6Months = 0 or ActiveAt12Months = 0 
						or ActiveAt18Months = 0 or ActiveAt24Months = 0 
					then 1 else 0 end > 0
group by ReportDischargeText
)

select LineGroupingLevel
	  ,TotalEnrolledParticipants
	  ,RetentionRateSixMonths
	  ,RetentionRateOneYear
	  ,RetentionRateEighteenMonths
	  ,RetentionRateTwoYears
	  ,EnrolledParticipantsSixMonths
	  ,EnrolledParticipantsOneYear
	  ,EnrolledParticipantsEighteenMonths
	  ,EnrolledParticipantsTwoYears
	  ,RunningTotalDischargedSixMonths
	  ,RunningTotalDischargedOneYear
	  ,RunningTotalDischargedEighteenMonths
	  ,RunningTotalDischargedTwoYears
	  ,(isnull(TotalNSixMonths,0) + isnull(TotalNOneYear,0) + isnull(TotalNEighteenMonths,0) + isnull(TotalNTwoYears,0)) as RunningTotalDischarged

	  ,TotalNSixMonths
	  ,TotalNOneYear
	  ,TotalNEighteenMonths
	  ,TotalNTwoYears
	  ,SixMonthsTotal
	  ,TwelveMonthsTotal
	  ,EighteenMonthsTotal
	  ,TwentyFourMonthsTotal
	  ,SixMonthsAtDischarge
	  ,TwelveMonthsAtDischarge
	  ,EighteenMonthsAtDischarge
	  ,TwentyFourMonthsAtDischarge
	  ,ReportDischargeText
	  ,SumDischargedBefore24Months
	  ,SumDischargedBefore6Months
	  ,SumDischargedBetween6And12Months
	  ,SumDischargedBetween12And18Months
	  ,SumDischargedBetween18And24Months FROM cteLast

--select @LineGroupingLevel as LineGroupingLevel
--		,@TotalCohortCount as TotalEnrolledParticipants
--		,@RetentionRateSixMonths as RetentionRateSixMonths
--		,@RetentionRateOneYear as RetentionRateOneYear
--		,@RetentionRateEighteenMonths as RetentionRateEighteenMonths
--		,@RetentionRateTwoYears as RetentionRateTwoYears
--		,@EnrolledParticipantsSixMonths as EnrolledParticipantsSixMonths
--		,@EnrolledParticipantsOneYear as EnrolledParticipantsOneYear
--		,@EnrolledParticipantsEighteenMonths as EnrolledParticipantsEighteenMonths
--		,@EnrolledParticipantsTwoYears as EnrolledParticipantsTwoYears
--		,@RunningTotalDischargedSixMonths as RunningTotalDischargedSixMonths
--		,@RunningTotalDischargedOneYear as RunningTotalDischargedOneYear
--		,@RunningTotalDischargedEighteenMonths as RunningTotalDischargedEighteenMonths
--		,@RunningTotalDischargedTwoYears as RunningTotalDischargedTwoYears
--		,@TotalNSixMonths as TotalNSixMonths
--		,@TotalNOneYear as TotalNOneYear
--		,@TotalNEighteenMonths as TotalNEighteenMonths
--		,@TotalNTwoYears as TotalNTwoYears
--		,@SixMonthsTotal as SixMonthsTotal
--		,@TwelveMonthsTotal as TwelveMonthsTotal
--		,@EighteenMonthsTotal as EighteenMonthsTotal
--		,@TwentyFourMonthsTotal as TwentyFourMonthsTotal
--		,@SixMonthsAtDischarge as SixMonthsAtDischarge
--		,@TwelveMonthsAtDischarge as TwelveMonthsAtDischarge
--		,@EighteenMonthsAtDischarge as EighteenMonthsAtDischarge
--		,@TwentyFourMonthsAtDischarge as TwentyFourMonthsAtDischarge
		
--select ReportDischargeText
--	  ,sum(ActiveAt6Months) as SumActiveAt6Months
--	  ,sum(ActiveAt12Months) as SumActiveAt12Months
--	  ,sum(ActiveAt18Months) as SumActiveAt18Months
--	  ,sum(ActiveAt24Months) as SumActiveAt24Months
--from @tblPC1withStats
--group by ReportDischargeText

--select *
--from @tblResults

END
GO
