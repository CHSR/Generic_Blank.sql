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
CREATE procedure [dbo].[rspRetentionRatesByDischargeReason_MIECHV]
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
		, RetentionRateThreeMonths decimal(5,3)
		, RetentionRateSixMonths decimal(5,3)
		, RetentionRateNineMonths decimal(5,3)
		, RetentionRateOneYear decimal(5,3)
		, EnrolledParticipantsThreeMonths int
		, EnrolledParticipantsSixMonths int
		, EnrolledParticipantsNineMonths int
		, EnrolledParticipantsOneYear int
		, RunningTotalDischargedThreeMonths int
		, RunningTotalDischargedSixMonths int
		, RunningTotalDischargedNineMonths int
		, RunningTotalDischargedOneYear int
		, TotalNThreeMonths int
		, TotalNSixMonths int
		, TotalNNineMonths int
		, TotalNOneYear int
		, AllParticipants int
		, ThreeMonthsIntake int
		, ThreeMonthsDischarge int
		, SixMonthsIntake int
		, SixMonthsDischarge int
		, NineMonthsIntake int
		, NineMonthsDischarge int
		, OneYearIntake int
		, OneYearDischarge int);
	
	declare @tblPC1WithStats table (
		PC1ID char(13)
		, IntakeDate datetime
		, DischargeDate datetime
		, ReportDischargeText char(80)
		, LastHomeVisit datetime
		, RetentionMonths int
		, ActiveAt3Months int
		, ActiveAt6Months int
		, ActiveAt9Months int
		, ActiveAt12Months int);
	
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
			from HVLog vl WITH (NOLOCK)
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
			when DischargeDate is null and datediff(month, IntakeDate, current_timestamp) > 3 then 1
			when DischargeDate is not null and datediff(month, IntakeDate, LastHomeVisit) > 3 then 1
				else 0
			end	as ActiveAt3Months
		   ,case
			when DischargeDate is null and datediff(month, IntakeDate, current_timestamp) > 6 then 1
			when DischargeDate is not null and datediff(month, IntakeDate, LastHomeVisit) > 6 then 1
				else 0
			end	as ActiveAt6Months
			,case
			when DischargeDate is null and datediff(month, IntakeDate, current_timestamp) > 9 then 1
			when DischargeDate is not null and datediff(month, IntakeDate, LastHomeVisit) > 9 then 1
				else 0
			end as ActiveAt9Months
			,case
			when DischargeDate is null and datediff(month, IntakeDate, current_timestamp) > 12 then 1
			when DischargeDate is not null and datediff(month, IntakeDate, LastHomeVisit) > 12 then 1
				else 0
			end as ActiveAt12Months
	 from HVCase c
		inner join cteCaseLastHomeVisit lhv on lhv.HVCaseFK = c.HVCasePK
		inner join CaseProgram cp on cp.HVCaseFK = c.HVCasePK
		inner join dbo.SplitString(@ProgramFK, ',') ss on ss.ListItem = cp.ProgramFK
		 left outer join dbo.codeDischarge cd on cd.DischargeCode = cp.DischargeReason and DischargeUsedWhere like '%DS%'
	 where (IntakeDate is not null
		  and IntakeDate between @StartDate and @EndDate)
		  --and cp.ProgramFK = @ProgramFK
	)

--with cteMain as
--	(select PC1ID
--		  , IntakeDate
--		  , LastHomeVisit
--		  , DischargeDate
--		  , tt.DischargeReasonCode
--		  , cd.ReportDischargeText
--		  , PC1AgeAtIntake
--		  , ActiveAt3Months
--		  , ActiveAt6Months
--		  , ActiveAt9Months
--		  , ActiveAt12Months
--		from [HFNY-MIHCOE].[dbo].[temptable2] tt
--		left outer join dbo.codeDischarge cd on cd.DischargeCode = tt.DischargeReason and DischargeUsedWhere like '%DS%'
--		inner join HVProgram hp on ProgramCode = substring(PC1ID, 5, 3)
--		inner join SplitString(@ProgramFK, ',') ss on ss.ListItem = HVProgramPK
--		-- substring(PC1ID, 5, 3) in ('130', '140', '420', '701', '702', '703', '710', '713', '715')
				
--	)
--select *
--from cteMain
--where DischargeReasonCode is NULL or DischargeReasonCode not in ('07', '17', '18', '20', '21', '23', '25', '37') 
--order by DischargeReasonCode, PC1ID

--#endregion
--#region Add rows to @tblPC1WithStats for each case/pc1id in the cohort, which will create the basis for the final stats
insert into @tblPC1WithStats
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
					
				   ,ActiveAt3Months
				   ,ActiveAt6Months
				   ,ActiveAt9Months
				   ,ActiveAt12Months
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

-- now we have all the rows from the cohort in @tblPC1WithStats
-- get the total count
select @TotalCohortCount = COUNT(*) 
  FROM @tblPC1WithStats

--#region declare vars to collect counts for final stats
declare @LineGroupingLevel int
		, @TotalEnrolledParticipants int
		, @RetentionRateThreeMonths decimal(5,3)
		, @RetentionRateSixMonths decimal(5,3)
		, @RetentionRateNineMonths decimal(5,3)
		, @RetentionRateOneYear decimal(5,3)
		, @EnrolledParticipantsThreeMonths int
		, @EnrolledParticipantsSixMonths int
		, @EnrolledParticipantsNineMonths int
		, @EnrolledParticipantsOneYear int
		, @RunningTotalDischargedThreeMonths int
		, @RunningTotalDischargedSixMonths int
		, @RunningTotalDischargedNineMonths int
		, @RunningTotalDischargedOneYear int
		, @TotalNThreeMonths int
		, @TotalNSixMonths int
		, @TotalNNineMonths int
		, @TotalNOneYear int

declare @AllEnrolledParticipants int
		, @ThreeMonthsTotal int
		, @SixMonthsTotal int
		, @NineMonthsTotal int
		, @TwelveMonthsTotal int
		, @ThreeMonthsAtDischarge int
		, @SixMonthsAtDischarge int
		, @NineMonthsAtDischarge int
		, @TwelveMonthsAtDischarge int
--#endregion
--#region Retention Rate %
select @ThreeMonthsTotal = count(PC1ID)
from @tblPC1WithStats
where ActiveAt3Months=1

select @SixMonthsTotal = count(PC1ID)
from @tblPC1WithStats
where ActiveAt6Months=1

select @NineMonthsTotal = count(PC1ID)
from @tblPC1WithStats
where ActiveAt9Months=1

select @TwelveMonthsTotal = count(PC1ID)
from @tblPC1WithStats
where ActiveAt12Months=1

set @RetentionRateThreeMonths = case when @TotalCohortCount=0 then 0.0000 else round((@ThreeMonthsTotal / (@TotalCohortCount * 1.0000)),4) end
set @RetentionRateSixMonths = case when @TotalCohortCount=0 then 0.0000 else round((@SixMonthsTotal / (@TotalCohortCount * 1.0000)),4) end
set @RetentionRateNineMonths = case when @TotalCohortCount=0 then 0.0000 else round((@NineMonthsTotal / (@TotalCohortCount * 1.0000)),4) end
set @RetentionRateOneYear = case when @TotalCohortCount=0 then 0.0000 else round((@TwelveMonthsTotal / (@TotalCohortCount * 1.0000)),4) end
--#endregion
--#region Enrolled Participants
select @EnrolledParticipantsThreeMonths = count(*)
from @tblPC1WithStats
where ActiveAt3Months = 1

select @EnrolledParticipantsSixMonths = count(*)
from @tblPC1WithStats
where ActiveAt6Months = 1

select @EnrolledParticipantsNineMonths = count(*)
from @tblPC1WithStats
where ActiveAt9Months = 1

select @EnrolledParticipantsOneYear = count(*)
from @tblPC1WithStats
where ActiveAt12Months = 1
--select @EnrolledParticipantsThreeMonths = count(*)
--from @tblPC1WithStats
--where ActiveAt3Months=1 and DischargeDate between dateadd(day, 6*30.44, IntakeDate) and dateadd(day, 12*30.44, IntakeDate)

--select @EnrolledParticipantsSixMonths = count(*)
--from @tblPC1WithStats
--where ActiveAt6Months=1 and DischargeDate between dateadd(day, 12*30.44, IntakeDate) and dateadd(day, 18*30.44, IntakeDate)

--select @EnrolledParticipantsNineMonths = count(*)
--from @tblPC1WithStats
--where ActiveAt9Months=1 and DischargeDate between dateadd(day, 18*30.44, IntakeDate) and dateadd(day, 24*30.44, IntakeDate)

--select @EnrolledParticipantsOneYear = count(*)
--from @tblPC1WithStats
--where ActiveAt12Months=1 and DischargeDate > dateadd(day, 24*30.44, IntakeDate)
--#endregion
--#region Running Total Discharged
select @RunningTotalDischargedThreeMonths = count(*)
from @tblPC1WithStats
where ActiveAt3Months = 0 and LastHomeVisit is not null

select @RunningTotalDischargedSixMonths = count(*) + @RunningTotalDischargedThreeMonths
from @tblPC1WithStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and LastHomeVisit is not null

select @RunningTotalDischargedNineMonths = count(*) + @RunningTotalDischargedSixMonths
from @tblPC1WithStats
where ActiveAt6Months = 1 and ActiveAt9Months = 0 and LastHomeVisit is not null

select @RunningTotalDischargedOneYear = count(*) + @RunningTotalDischargedNineMonths
from @tblPC1WithStats
where ActiveAt9Months = 1 and ActiveAt12Months = 0 and LastHomeVisit is not null
-----------------------------------------------------------
--select @RunningTotalDischargedThreeMonths = count(*)
--from @tblPC1WithStats
--where ActiveAt3Months=1 and DischargeDate is not null

--select @RunningTotalDischargedSixMonths = count(*) + @RunningTotalDischargedThreeMonths
--from @tblPC1WithStats
--where ActiveAt6Months=1 and DischargeDate is not null

--select @RunningTotalDischargedNineMonths = count(*) + @RunningTotalDischargedSixMonths
--from @tblPC1WithStats
--where ActiveAt9Months=1 and DischargeDate is not null

--select @RunningTotalDischargedOneYear = count(*) + @RunningTotalDischargedNineMonths
--from @tblPC1WithStats
--where ActiveAt12Months=1 and DischargeDate is not null
-----------------------------------------------------------
--select @RunningTotalDischargedThreeMonths = count(*)
--from @tblPC1WithStats
--where ActiveAt3Months = 0 and LastHomeVisit between IntakeDate and dateadd(day, 6*30.44, IntakeDate)
--
--select @RunningTotalDischargedSixMonths = count(*) + @RunningTotalDischargedThreeMonths
--from @tblPC1WithStats
--where ActiveAt6Months = 0 and LastHomeVisit between dateadd(day, (6*30.44)+1, IntakeDate) and dateadd(day, 12*30.44, IntakeDate)
--
--select @RunningTotalDischargedNineMonths = count(*) + @RunningTotalDischargedSixMonths
--from @tblPC1WithStats
--where ActiveAt9Months = 0 and LastHomeVisit between dateadd(day, (12*30.44)+1, IntakeDate) and dateadd(day, 18*30.44, IntakeDate)
--
--select @RunningTotalDischargedOneYear = count(*) + @RunningTotalDischargedNineMonths
--from @tblPC1WithStats
--where ActiveAt12Months = 0 and LastHomeVisit between dateadd(day, (18*30.44)+1, IntakeDate) and dateadd(day, 24*30.44, IntakeDate)
--#endregion
--#region Total (N) - (Discharged)
select @TotalNThreeMonths = count(*)
from @tblPC1WithStats
where ActiveAt3Months = 0 and LastHomeVisit is not null

select @TotalNSixMonths = count(*)
from @tblPC1WithStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and LastHomeVisit is not null

select @TotalNNineMonths = count(*)
from @tblPC1WithStats
where ActiveAt6Months = 1 and ActiveAt9Months = 0 and LastHomeVisit is not null

select @TotalNOneYear = count(*)
from @tblPC1WithStats
where ActiveAt9Months = 1 and ActiveAt12Months = 0 and LastHomeVisit is not null
--#endregion

--select *
--from @tblPC1WithStats
;
with cteLast as
(
select @LineGroupingLevel as LineGroupingLevel
		,case when datediff(ww,@enddate,getdate()) >= 13 then @TotalCohortCount else null end as TotalEnrolledParticipants
		
		,case when datediff(ww,@enddate,getdate()) >= 13 then @RetentionRateThreeMonths else null end as RetentionRateThreeMonths
		,case when datediff(ww,@enddate,getdate()) >= 26 then @RetentionRateSixMonths else null end as RetentionRateSixMonths
		,case when datediff(ww,@enddate,getdate()) >= 39 then @RetentionRateNineMonths else null end as RetentionRateNineMonths
		,case when datediff(ww,@enddate,getdate()) >= 52 then @RetentionRateOneYear else null end as RetentionRateOneYear
		
		,case when datediff(ww,@enddate,getdate()) >= 13 then @EnrolledParticipantsThreeMonths else null end as EnrolledParticipantsThreeMonths
		,case when datediff(ww,@enddate,getdate()) >= 26 then @EnrolledParticipantsSixMonths else null end as EnrolledParticipantsSixMonths
		,case when datediff(ww,@enddate,getdate()) >= 39 then @EnrolledParticipantsNineMonths else null end as EnrolledParticipantsNineMonths
		,case when datediff(ww,@enddate,getdate()) >= 52 then @EnrolledParticipantsOneYear else null end as EnrolledParticipantsOneYear
		
		,case when datediff(ww,@enddate,getdate()) >= 13 then @RunningTotalDischargedThreeMonths else null end as RunningTotalDischargedThreeMonths
		,case when datediff(ww,@enddate,getdate()) >= 26 then @RunningTotalDischargedSixMonths else null end as RunningTotalDischargedSixMonths
		,case when datediff(ww,@enddate,getdate()) >= 39 then @RunningTotalDischargedNineMonths else null end as RunningTotalDischargedNineMonths
	    ,case when datediff(ww,@enddate,getdate()) >= 52 then @RunningTotalDischargedOneYear else null end as RunningTotalDischargedOneYear
		
		
		,case when datediff(ww,@enddate,getdate()) >= 13 then @TotalNThreeMonths else null end as TotalNThreeMonths
		,case when datediff(ww,@enddate,getdate()) >= 26 then @TotalNSixMonths else null end as TotalNSixMonths
		,case when datediff(ww,@enddate,getdate()) >= 39 then @TotalNNineMonths else null end as TotalNNineMonths
		,case when datediff(ww,@enddate,getdate()) >= 52 then @TotalNOneYear else null end as TotalNOneYear
		
		
		
		,case when datediff(ww,@enddate,getdate()) >= 13 then @ThreeMonthsTotal else null end as ThreeMonthsTotal
		,case when datediff(ww,@enddate,getdate()) >= 26 then @SixMonthsTotal else null end as SixMonthsTotal
		,case when datediff(ww,@enddate,getdate()) >= 39 then @NineMonthsTotal else null end as NineMonthsTotal
		,case when datediff(ww,@enddate,getdate()) >= 52 then @TwelveMonthsTotal else null end as TwelveMonthsTotal
		
		,case when datediff(ww,@enddate,getdate()) >= 13 then @ThreeMonthsAtDischarge else null end as ThreeMonthsAtDischarge
		,case when datediff(ww,@enddate,getdate()) >= 26 then @SixMonthsAtDischarge else null end as SixMonthsAtDischarge
		,case when datediff(ww,@enddate,getdate()) >= 39 then @NineMonthsAtDischarge else null end as NineMonthsAtDischarge
		,case when datediff(ww,@enddate,getdate()) >= 52 then @TwelveMonthsAtDischarge else null end as TwelveMonthsAtDischarge
		, ReportDischargeText
		
		
		,
		sum(case when ActiveAt3Months = 0 or ActiveAt6Months = 0 
						or ActiveAt9Months = 0 or ActiveAt12Months = 0 
					then 1 else 0 end)
		 as SumDischargedBefore12Months
					
		
		,case when datediff(ww,@enddate,getdate()) >= 13 then 
			sum(case when ActiveAt3Months = 0 then 1 else 0 end) 
		 else null end as SumDischargedBefore3Months
			
		
		,case when datediff(ww,@enddate,getdate()) >= 26 then 
			sum(case when ActiveAt3Months = 1 and ActiveAt6Months = 0 then 1 else 0 end) 
		 else null end as SumDischargedBetween3And6Months
		
		,case when datediff(ww,@enddate,getdate()) >= 39 then 
			sum(case when ActiveAt6Months = 1 and ActiveAt9Months = 0 then 1 else 0 end) 
		else null end as SumDischargedBetween6And9Months
		
		,case when datediff(ww,@enddate,getdate()) >= 52 then 
			sum(case when ActiveAt9Months = 1 and ActiveAt12Months = 0 then 1 else 0 end) 
		else null end as SumDischargedBetween9And12Months
		
from @tblPC1WithStats
where ReportDischargeText is not null
		and case when ActiveAt3Months = 0 or ActiveAt6Months = 0 
						or ActiveAt9Months = 0 or ActiveAt12Months = 0 
					then 1 else 0 end > 0
group by ReportDischargeText
)

select LineGroupingLevel
	  ,1 as DisplayPercentages
	  ,TotalEnrolledParticipants
	  ,RetentionRateThreeMonths as RetentionRateSixMonths
	  ,RetentionRateSixMonths as RetentionRateOneYear
	  ,RetentionRateNineMonths as RetentionRateEighteenMonths
	  ,RetentionRateOneYear as RetentionRateTwoYears
	  ,EnrolledParticipantsThreeMonths as EnrolledParticipantsSixMonths
	  ,EnrolledParticipantsSixMonths as EnrolledParticipantsOneYear
	  ,EnrolledParticipantsNineMonths as EnrolledParticipantsEighteenMonths
	  ,EnrolledParticipantsOneYear as EnrolledParticipantsTwoYears
	  ,RunningTotalDischargedThreeMonths as RunningTotalDischargedSixMonths
	  ,RunningTotalDischargedSixMonths as RunningTotalDischargedOneYear
	  ,RunningTotalDischargedNineMonths as RunningTotalDischargedEighteenMonths
	  ,RunningTotalDischargedOneYear as RunningTotalDischargedTwoYears
	  ,(isnull(TotalNThreeMonths,0) + isnull(TotalNSixMonths,0) + isnull(TotalNNineMonths,0) + isnull(TotalNOneYear,0)) as RunningTotalDischarged
	  ,TotalNThreeMonths as TotalNSixMonths
	  ,TotalNSixMonths as TotalNOneYear
	  ,TotalNNineMonths as TotalNEighteenMonths
	  ,TotalNOneYear as TotalNTwoyears
	  ,ThreeMonthsTotal as SixMonthsTotal
	  ,SixMonthsTotal as TwelveMonthsTotal
	  ,NineMonthsTotal as EighteenMonthsTotal
	  ,TwelveMonthsTotal as TwentyFourMonthsTotal
	  ,ThreeMonthsAtDischarge as SixMonthsAtDischarge
	  ,SixMonthsAtDischarge as SixMonthsAtDischarge
	  ,NineMonthsAtDischarge as EighteenMonthsAtDischarge
	  ,TwelveMonthsAtDischarge as TwelveMonthsAtDischarge
	  ,ReportDischargeText
	  ,SumDischargedBefore12Months as SumDischargedBefore24Months
	  ,SumDischargedBefore3Months as SumDischargedBefore6Months
	  ,SumDischargedBetween3And6Months as SumDischargedBetween6And12Months
	  ,SumDischargedBetween6And9Months as SumDischargedBetween12And18Months
	  ,SumDischargedBetween9And12Months as SumDischargedBetween18And24Months
      from cteLast

--select @LineGroupingLevel as LineGroupingLevel
--		,@TotalCohortCount as TotalEnrolledParticipants
--		,@RetentionRateThreeMonths as RetentionRateThreeMonths
--		,@RetentionRateSixMonths as RetentionRateSixMonths
--		,@RetentionRateNineMonths as RetentionRateNineMonths
--		,@RetentionRateOneYear as RetentionRateOneYear
--		,@EnrolledParticipantsThreeMonths as EnrolledParticipantsThreeMonths
--		,@EnrolledParticipantsSixMonths as EnrolledParticipantsSixMonths
--		,@EnrolledParticipantsNineMonths as EnrolledParticipantsNineMonths
--		,@EnrolledParticipantsOneYear as EnrolledParticipantsOneYear
--		,@RunningTotalDischargedThreeMonths as RunningTotalDischargedThreeMonths
--		,@RunningTotalDischargedSixMonths as RunningTotalDischargedSixMonths
--		,@RunningTotalDischargedNineMonths as RunningTotalDischargedNineMonths
--		,@RunningTotalDischargedOneYear as RunningTotalDischargedOneYear
--		,@TotalNThreeMonths as TotalNThreeMonths
--		,@TotalNSixMonths as TotalNSixMonths
--		,@TotalNNineMonths as TotalNNineMonths
--		,@TotalNOneYear as TotalNOneYear
--		,@ThreeMonthsTotal as ThreeMonthsTotal
--		,@TwelveMonthsTotal as TwelveMonthsTotal
--		,@NineMonthsTotal as NineMonthsTotal
--		,@TwelveMonthsTotal as TwelveMonthsTotal
--		,@ThreeMonthsAtDischarge as ThreeMonthsAtDischarge
--		,@SixMonthsAtDischarge as SixMonthsAtDischarge
--		,@NineMonthsAtDischarge as NineMonthsAtDischarge
--		,@TwelveMonthsAtDischarge as TwelveMonthsAtDischarge
		
--select ReportDischargeText
--	  ,sum(ActiveAt3Months) as SumActiveAt3Months
--	  ,sum(ActiveAt6Months) as SumActiveAt6Months
--	  ,sum(ActiveAt9Months) as SumActiveAt9Months
--	  ,sum(ActiveAt12Months) as SumActiveAt12Months
--from @tblPC1WithStats
--group by ReportDischargeText

--select *
--from @tblResults

end
GO
