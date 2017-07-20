SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Jay Robohn
-- Create date: Sept. 19, 2013
-- Description:	The Performance Target Summary report modified to do the Performance Targets For 4 Quarters report
-- rspPerformanceTargetReport4Quarters 4 ,'06/01/2013' ,'08/31/2013'
-- rspPerformanceTargetReport4Quarters 2 ,'10/01/2012' ,'12/31/2012'
-- rspPerformanceTargetReport4Quarters 2 ,'04/01/2012' ,'06/30/2012'
-- rspPerformanceTargetReport4Quarters 24,'10/01/2012' ,'12/31/2012'
-- rspPerformanceTargetReport4Quarters 9, '07/01/2013', '09/30/2013', 471
-- rspPerformanceTargetReport4Quarters 39, '10/01/2013', '12/31/2013'
-- mods by jrobohn 20130222 - clean up names, code and layoutset
-- mods by jrobohn 20130223 - added PCI1 report
-- =============================================

CREATE procedure [dbo].[rspPerformanceTargetReport4Quarters]
(
    @ProgramFKs				varchar(max)    = null,
    @StartQuarterDate		datetime,
    @EndQuarterDate			datetime,
    @FSWFK					int             = null,
    @SiteFK					int             = null,
    @IncludeClosedCases		bit             = 0,
    @CaseFiltersPositive	varchar(100)    = ''
) 
as
begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set nocount on;

	set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0 else @SiteFK end
	set @CaseFiltersPositive = case when @CaseFiltersPositive = '' then null else @CaseFiltersPositive end

	declare @LastRowCount int
	declare @RowCount varchar(30)
	
	--/* declare a table to store the results of the GetAllQuarters proc */
	--declare @tblQuarters as table (QuarterTitle varchar(15)
	--								, QuarterStartDate date
	--								, QuarterEndDate date
	--								, QuarterDates varchar(20)
	--								, QuarterData varchar(100)
	--		 						)
	--insert into @tblQuarters
	--	exec rspGetAllQuarters @ProgramFKs
	
	--declare @StartDate date
	--declare @EndDate date
	--set @StartDate = (select QuarterStartDate from @tblQuarters where QuarterTitle = '1st Quarter')
	--set @EndDate = (select QuarterEndDate from @tblQuarters where QuarterTitle = '1st Quarter')

	declare @StartDate date
	declare @EndDate date
	set @StartDate = (select dateadd(month, -9, @StartQuarterDate))
	set @EndDate = (select dateadd(day, -1, dateadd(month, -6, @StartQuarterDate)))
	print 'Quarter 1; ' + convert(varchar(10), @StartDate) + ' - ' + convert(varchar(10), @EndDate)
		
	/* declare a table to store the output summary */
	declare @tblPTSummary table(
		[PTCode] char(5)
		, Qtr1TotalCases int
		, Qtr1ValidCases int
		, Qtr1CasesMeetingTarget int
		, [Qtr1PercentageMeetingPT] varchar(10)
		, Qtr2TotalCases int
		, Qtr2ValidCases int
		, Qtr2CasesMeetingTarget int
		, [Qtr2PercentageMeetingPT] varchar(10)
		, Qtr3TotalCases int
		, Qtr3ValidCases int
		, Qtr3CasesMeetingTarget int
		, [Qtr3PercentageMeetingPT] varchar(10)
		, Qtr4TotalCases int
		, Qtr4ValidCases int
		, Qtr4CasesMeetingTarget int
		, [Qtr4PercentageMeetingPT] varchar(10)
	)

	/** For performance reasons, get the active cases that belong to the cohort now **/
	/* Declare a variable that references the type. */
	declare @tblPTCohort as PTCases; -- PTCases is a user defined type

	/* Add data to the table variable for quarter 1*/
	insert into @tblPTCohort (HVCaseFK
							 , CaseProgramPK
 							 , PC1ID
							 , OldID
							 , PC1FullName
							 , CurrentWorkerFK
							 , CurrentWorkerFullName
							 , CurrentLevelName
							 , ProgramFK
							 , TCIDPK
							 , TCDOB
							)
		select distinct
			  HVCasePK
			 , CaseProgramPK
			 , PC1ID
			 , OldID
			 , rtrim(P.PCFirstName) + ' ' + rtrim(P.PCLastName) as PC1FullName
			 , cp.CurrentFSWFK
			 , rtrim(w.FirstName) + ' ' + rtrim(w.LastName) as CurrentWorkerFullName
			 -- , dbo.udfLevelOnDate(cp.ProgramFK, HVCasePK, @EndDate) as CurrentLevelName
			 , hvl.levelname as CurrentLevelName
			 , cp.ProgramFK
			 , tcid.TCIDPK
			 , case
				  when h.tcdob is not null then
					  h.tcdob
				  else
					  h.edc
			  end as TCDOB
			from HVCase h
				inner join CaseProgram cp on cp.HVCaseFK = h.HVCasePK
				inner join PC P on P.PCPK = h.PC1FK
				inner join Worker w on w.WorkerPK = cp.CurrentFSWFK
				inner join WorkerProgram wp on wp.WorkerFK = w.WorkerPK
				-- inner join codeLevel l on l.codeLevelPK = cp.CurrentLevelFK
				inner join dbo.udfHVLevel(@ProgramFKs, @EndDate) hvl on hvl.hvcasefk = cp.HVCaseFK
				inner join dbo.udfCaseFilters(@CaseFiltersPositive,'',@ProgramFKs) cf on cf.HVCaseFK = h.HVCasePK
				inner join dbo.SplitString(@ProgramFKs, ',') ss on ss.ListItem = cp.ProgramFK
				left join tcid on tcid.hvcasefk = h.hvcasepk -- for dead babies dod
			where
				--cp.ProgramFK = @ProgramFKs and 
				CurrentFSWFK = isnull(@FSWFK, CurrentFSWFK)
				and h.CaseProgress >= 9
				-- dead babies
				 and (h.IntakeDate is not null
					and h.IntakeDate <= @EndDate
					and h.TCDOD is null)
				and (tcid.TCDOD is null
					or tcid.TCDOD > @EndDate) -- 5/23/05 JH/DB if all children are dead don't include in performance target (FoxPro)
				-- inclusion / exclusion of closed case
				and (cp.DischargeDate is null
					or case -- closed cases are not included
						 when @IncludeClosedCases = 0 or @IncludeClosedCases is null then
							 (case
								 when cp.DischargeDate > @EndDate then
									 1
								 else
									 0
							 end)
						 else -- include closed cases
							 (case
								 when cp.DischargeDate >= @StartDate then
									 1
								 else
									 0
							 end)
					 end = 1)
				--siteFK
				and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)

	--SELECT * FROM @tblPTCohort

	declare @tblPTDetailsTemp table
		(
		PTCode			char(5)
		, HVCaseFK			int
		, PC1ID				varchar(20)
		, OldID				varchar(30)
		, TCDOB				datetime
		, PC1Fullname		varchar(50)
		, WorkerFullName	varchar(50)
		, CurrentLevelName	varchar(30)
		, FormName			varchar(50)
		, FormDate			datetime
		, FormReviewed		int
		, FormOutOfWindow	int
		, FormMissing		int
		, FormMeetsTarget	int
		, ReasonNotMeeting	varchar(50)
		)

	declare @tblPTDetails table
		(
		QuarterText			char(1)
		, PTCode			char(5)
		, HVCaseFK			int
		, PC1ID				varchar(20)
		, OldID				varchar(30)
		, TCDOB				datetime
		, PC1Fullname		varchar(50)
		, WorkerFullName	varchar(50)
		, CurrentLevelName	varchar(30)
		, FormName			varchar(50)
		, FormDate			datetime
		, FormReviewed		int
		, FormOutOfWindow	int
		, FormMissing		int
		, FormMeetsTarget	int
		, ReasonNotMeeting	varchar(50)
		)

	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetHD1]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetHD1 @StartDate,@EndDate,@tblPTCohort
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetHD2]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetHD2 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetHD3]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetHD3 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetHD4]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetHD4 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetHD5]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetHD5 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetHD6]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetHD6 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetHD7]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetHD7 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetHD8]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetHD8 @StartDate,@EndDate,@tblPTCohort 

	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetPCI1]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetPCI1 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetPCI2]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetPCI2 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetPCI3]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetPCI3 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetPCI4]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetPCI4 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetPCI5]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetPCI5 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetPCI6]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetPCI6 @StartDate,@EndDate,@tblPTCohort 

	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetFLC1]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetFLC1 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetFLC2]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetFLC2 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetFLC3]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetFLC3 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetFLC4]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetFLC4 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetFLC5]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetFLC5 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetFLC6]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetFLC6 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetFLC7]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetFLC7 @StartDate,@EndDate,@tblPTCohort 
	
	;
	with cteSummaryQtr1
	as
	(
	select PTCode
			, count(PTCode) as TotalCases
			, sum(case when FormReviewed = 1 and FormMissing = 0 and FormOutOfWindow = 0 
					then 1
					else 0
					end) as ValidCases
			, sum(case when FormMeetsTarget = 1 then 1 else 0 end) as FormMeetsTarget
		from @tblPTDetailsTemp
		group by PTCode
	)
	
	insert into @tblPTSummary (PTCode
								, Qtr1TotalCases
								, Qtr1ValidCases
								, Qtr1CasesMeetingTarget
								, Qtr1PercentageMeetingPT)
		select PTCode
				, TotalCases
				, ValidCases
				, FormMeetsTarget
				, case when ValidCases = 0 then '**        '
						when (cast(ValidCases as float)/ cast(TotalCases as float)) < .75 then '*         ' 
						-- else convert(varchar(10), round((FormMeetsTarget / (ValidCases * 100.0000)), 0)) + '%'
						else cast(round(cast(FormMeetsTarget as float) / cast(ValidCases as float), 2) * 100 as varchar(10)) + '%'
					end as Qtr1PercentageMeetingTarget
				--, case when sum(case when FormReviewed = 1 and FormMissing = 0 and FormOutOfWindow = 0 then 1 else 0 end) = 0 then 0 else 
				--			round(sum(case when FormMeetsTarget = 1 then 1 else 0 end) / 
				--					(sum(case when FormReviewed = 1 and FormMissing = 0 and FormOutOfWindow = 0 then 1 else 0 end) * 1.00), 2) 
				--	end
				--	as Qtr1PercentageMeetingTarget
				--, sum(case when FormMeetsTarget = 1 then 1 else 0 end)  as Sum_FormMeetsTarget
				--, count(PTCode) as Count_PTCode				
		from cteSummaryQtr1
		-- group by PTCode
		union 
		select PerformanceTargetCode
				, 0
				, 0
				, 0
				, '**        ' as Qtr1PercentageMeetingTarget
		from codePerformanceTargetTitle ptt
		where PerformanceTargetCode not in (select PTCode from @tblPTDetailsTemp)
		
	-- select * from @tblPTSummary
	insert into @tblPTDetails
		select '1',* from @tblPTDetailsTemp
		 
	delete from @tblPTDetailsTemp
	delete from @tblPTCohort
	
	--set @LastRowCount = (select count(*) from @tblPTDetailsTemp) - @LastRowCount
	--set @RowCount += ',' + convert(char(10), @LastRowCount)

	set @StartDate = (select dateadd(month, -6, @StartQuarterDate))
	set @EndDate = (select dateadd(day, -1, dateadd(month, -3, @StartQuarterDate)))
	print 'Quarter 2; ' + convert(varchar(10), @StartDate) + ' - ' + convert(varchar(10), @EndDate)
	/* Add data to the table variable for quarter 1*/
	insert into @tblPTCohort (HVCaseFK
							 , CaseProgramPK
 							 , PC1ID
							 , OldID
							 , PC1FullName
							 , CurrentWorkerFK
							 , CurrentWorkerFullName
							 , CurrentLevelName
							 , ProgramFK
							 , TCIDPK
							 , TCDOB
							)
		select distinct
			  HVCasePK
			 , CaseProgramPK
			 , PC1ID
			 , OldID
			 , rtrim(P.PCFirstName) + ' ' + rtrim(P.PCLastName) as PC1FullName
			 , cp.CurrentFSWFK
			 , rtrim(w.FirstName) + ' ' + rtrim(w.LastName) as CurrentWorkerFullName
			 -- , dbo.udfLevelOnDate(cp.ProgramFK, HVCasePK, @EndDate) as CurrentLevelName
			 , hvl.levelname as CurrentLevelName
			 , cp.ProgramFK
			 , tcid.TCIDPK
			 , case
				  when h.tcdob is not null then
					  h.tcdob
				  else
					  h.edc
			  end as TCDOB
			from HVCase h
				inner join CaseProgram cp on cp.HVCaseFK = h.HVCasePK
				inner join PC P on P.PCPK = h.PC1FK
				inner join Worker w on w.WorkerPK = cp.CurrentFSWFK
				inner join WorkerProgram wp on wp.WorkerFK = w.WorkerPK
				-- inner join codeLevel l on l.codeLevelPK = cp.CurrentLevelFK
				inner join dbo.udfHVLevel(@ProgramFKs, @EndDate) hvl on hvl.hvcasefk = cp.HVCaseFK
				inner join dbo.udfCaseFilters(@CaseFiltersPositive,'',@ProgramFKs) cf on cf.HVCaseFK = h.HVCasePK
				inner join dbo.SplitString(@ProgramFKs, ',') ss on ss.ListItem = cp.ProgramFK
				left join tcid on tcid.hvcasefk = h.hvcasepk -- for dead babies dod
			where
				--cp.ProgramFK = @ProgramFKs and 
				CurrentFSWFK = isnull(@FSWFK, CurrentFSWFK)
				and h.CaseProgress >= 9
				-- dead babies
				 and (h.IntakeDate is not null
					and h.IntakeDate <= @EndDate
					and h.TCDOD is null)
				and (tcid.TCDOD is null
					or tcid.TCDOD > @EndDate) -- 5/23/05 JH/DB if all children are dead don't include in performance target (FoxPro)
				-- inclusion / exclusion of closed case
				and (cp.DischargeDate is null
					or case -- closed cases are not included
						 when @IncludeClosedCases = 0 or @IncludeClosedCases is null then
							 (case
								 when cp.DischargeDate > @EndDate then
									 1
								 else
									 0
							 end)
						 else -- include closed cases
							 (case
								 when cp.DischargeDate >= @StartDate then
									 1
								 else
									 0
							 end)
					 end = 1)
				--siteFK
				and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)

	
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetHD1]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetHD1 @StartDate,@EndDate,@tblPTCohort
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetHD2]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetHD2 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetHD3]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetHD3 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetHD4]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetHD4 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetHD5]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetHD5 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetHD6]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetHD6 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetHD7]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetHD7 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetHD8]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetHD8 @StartDate,@EndDate,@tblPTCohort 

	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetPCI1]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetPCI1 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetPCI2]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetPCI2 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetPCI3]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetPCI3 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetPCI4]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetPCI4 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetPCI5]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetPCI5 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetPCI6]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetPCI6 @StartDate,@EndDate,@tblPTCohort 

	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetFLC1]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetFLC1 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetFLC2]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetFLC2 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetFLC3]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetFLC3 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetFLC4]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetFLC4 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetFLC5]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetFLC5 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetFLC6]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetFLC6 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetFLC7]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetFLC7 @StartDate,@EndDate,@tblPTCohort 

	;
	with cteSummaryQtr2
	as
	(
	select PTCode
			, count(PTCode) as TotalCases
			, sum(case when FormReviewed = 1 and FormMissing = 0 and FormOutOfWindow = 0 
					then 1
					else 0
					end) as ValidCases
			, sum(case when FormMeetsTarget = 1 then 1 else 0 end) as FormMeetsTarget
		from @tblPTDetailsTemp
		group by PTCode
	), 
	cteQtr2PercentageMeeting as
	(
	select PTCode
			, TotalCases
			, ValidCases as TotalValidCases
			, FormMeetsTarget as TotalCasesMeetingTarget
			, case when ValidCases = 0 then '**        '
					when (cast(ValidCases as float)/ cast(TotalCases as float)) < .75 then '*         ' 
					-- else convert(varchar(10), round((FormMeetsTarget / (ValidCases * 100.0000)), 0)) + '%'
					else cast(round(cast(FormMeetsTarget as float) / cast(ValidCases as float), 2) * 100 as varchar(10)) + '%'
				end as PercentageMeetingTarget
		from cteSummaryQtr2
		union 
		select PerformanceTargetCode
				, 0
				, 0
				, 0
				, '**        '
		from codePerformanceTargetTitle ptt
		where PerformanceTargetCode not in (select PTCode from cteSummaryQtr2)
	)
	
	update @tblPTSummary
		set Qtr2PercentageMeetingPT = isnull(PercentageMeetingTarget, 0)
			, Qtr2TotalCases = TotalCases
			, Qtr2ValidCases = TotalValidCases
			, Qtr2CasesMeetingTarget = TotalCasesMeetingTarget
		from cteQtr2PercentageMeeting q2
		where q2.PTCode = [@tblPTSummary].PTCode

	insert into @tblPTDetails
		select '2',* from @tblPTDetailsTemp
		 
	delete from @tblPTDetailsTemp
	delete from @tblPTCohort

	set @StartDate = (select dateadd(month, -3, @StartQuarterDate))
	set @EndDate = (select dateadd(day, -1, @StartQuarterDate))
	print 'Quarter 3; ' + convert(varchar(10), @StartDate) + ' - ' + convert(varchar(10), @EndDate)

	/* Add data to the table variable for quarter 1*/
	insert into @tblPTCohort (HVCaseFK
							 , CaseProgramPK
 							 , PC1ID
							 , OldID
							 , PC1FullName
							 , CurrentWorkerFK
							 , CurrentWorkerFullName
							 , CurrentLevelName
							 , ProgramFK
							 , TCIDPK
							 , TCDOB
							)
		select distinct
			  HVCasePK
			 , CaseProgramPK
			 , PC1ID
			 , OldID
			 , rtrim(P.PCFirstName) + ' ' + rtrim(P.PCLastName) as PC1FullName
			 , cp.CurrentFSWFK
			 , rtrim(w.FirstName) + ' ' + rtrim(w.LastName) as CurrentWorkerFullName
			 -- , dbo.udfLevelOnDate(cp.ProgramFK, HVCasePK, @EndDate) as CurrentLevelName
			 , hvl.levelname as CurrentLevelName
			 , cp.ProgramFK
			 , tcid.TCIDPK
			 , case
				  when h.tcdob is not null then
					  h.tcdob
				  else
					  h.edc
			  end as TCDOB
			from HVCase h
				inner join CaseProgram cp on cp.HVCaseFK = h.HVCasePK
				inner join PC P on P.PCPK = h.PC1FK
				inner join Worker w on w.WorkerPK = cp.CurrentFSWFK
				inner join WorkerProgram wp on wp.WorkerFK = w.WorkerPK
				-- inner join codeLevel l on l.codeLevelPK = cp.CurrentLevelFK
				inner join dbo.udfHVLevel(@ProgramFKs, @EndDate) hvl on hvl.hvcasefk = cp.HVCaseFK
				inner join dbo.udfCaseFilters(@CaseFiltersPositive,'',@ProgramFKs) cf on cf.HVCaseFK = h.HVCasePK
				inner join dbo.SplitString(@ProgramFKs, ',') ss on ss.ListItem = cp.ProgramFK
				left join tcid on tcid.hvcasefk = h.hvcasepk -- for dead babies dod
			where
				--cp.ProgramFK = @ProgramFKs and 
				CurrentFSWFK = isnull(@FSWFK, CurrentFSWFK)
				and h.CaseProgress >= 9
				-- dead babies
				 and (h.IntakeDate is not null
					and h.IntakeDate <= @EndDate
					and h.TCDOD is null)
				and (tcid.TCDOD is null
					or tcid.TCDOD > @EndDate) -- 5/23/05 JH/DB if all children are dead don't include in performance target (FoxPro)
				-- inclusion / exclusion of closed case
				and (cp.DischargeDate is null
					or case -- closed cases are not included
						 when @IncludeClosedCases = 0 or @IncludeClosedCases is null then
							 (case
								 when cp.DischargeDate > @EndDate then
									 1
								 else
									 0
							 end)
						 else -- include closed cases
							 (case
								 when cp.DischargeDate >= @StartDate then
									 1
								 else
									 0
							 end)
					 end = 1)
				--siteFK
				and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)

	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetHD1]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetHD1 @StartDate,@EndDate,@tblPTCohort
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetHD2]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetHD2 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetHD3]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetHD3 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetHD4]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetHD4 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetHD5]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetHD5 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetHD6]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetHD6 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetHD7]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetHD7 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetHD8]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetHD8 @StartDate,@EndDate,@tblPTCohort 

	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetPCI1]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetPCI1 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetPCI2]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetPCI2 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetPCI3]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetPCI3 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetPCI4]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetPCI4 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetPCI5]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetPCI5 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetPCI6]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetPCI6 @StartDate,@EndDate,@tblPTCohort 

	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetFLC1]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetFLC1 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetFLC2]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetFLC2 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetFLC3]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetFLC3 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetFLC4]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetFLC4 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetFLC5]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetFLC5 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetFLC6]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetFLC6 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetFLC7]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetFLC7 @StartDate,@EndDate,@tblPTCohort 

	;
	with cteSummaryQtr3
	as
	(
	select PTCode
			, count(PTCode) as TotalCases
			, sum(case when FormReviewed = 1 and FormMissing = 0 and FormOutOfWindow = 0 
					then 1
					else 0
					end) as ValidCases
			, sum(case when FormMeetsTarget = 1 then 1 else 0 end) as FormMeetsTarget
		from @tblPTDetailsTemp
		group by PTCode
	), 
	cteQtr3PercentageMeeting as
	(
	select PTCode
			, TotalCases
			, ValidCases as TotalValidCases
			, FormMeetsTarget as TotalCasesMeetingTarget
			, case when ValidCases = 0 then '**        '
					when (cast(ValidCases as float)/ cast(TotalCases as float)) < .75 then '*         ' 
					-- else convert(varchar(10), round((FormMeetsTarget / (ValidCases * 100.0000)), 0)) + '%'
					else cast(round(cast(FormMeetsTarget as float) / cast(ValidCases as float), 2) * 100 as varchar(10)) + '%'
				end as PercentageMeetingTarget
		from cteSummaryQtr3
		union 
		select PerformanceTargetCode
				, 0
				, 0
				, 0
				, '**        '
		from codePerformanceTargetTitle ptt
		where PerformanceTargetCode not in (select PTCode from cteSummaryQtr3)
	)
	
	update @tblPTSummary
		set Qtr3PercentageMeetingPT = isnull(PercentageMeetingTarget, 0)
			, Qtr3TotalCases = TotalCases
			, Qtr3ValidCases = TotalValidCases
			, Qtr3CasesMeetingTarget = TotalCasesMeetingTarget
		from cteQtr3PercentageMeeting q3
		where q3.PTCode = [@tblPTSummary].PTCode

	insert into @tblPTDetails
		select '3',* from @tblPTDetailsTemp
		 
	delete from @tblPTDetailsTemp
	delete from @tblPTCohort

	set @StartDate = @StartQuarterDate
	set @EndDate = @EndQuarterDate
	print 'Quarter 4; ' + convert(varchar(10), @StartDate) + ' - ' + convert(varchar(10), @EndDate)
	/* Add data to the table variable for quarter 1*/
	insert into @tblPTCohort (HVCaseFK
							 , CaseProgramPK
 							 , PC1ID
							 , OldID
							 , PC1FullName
							 , CurrentWorkerFK
							 , CurrentWorkerFullName
							 , CurrentLevelName
							 , ProgramFK
							 , TCIDPK
							 , TCDOB
							)
		select distinct
			  HVCasePK
			 , CaseProgramPK
			 , PC1ID
			 , OldID
			 , rtrim(P.PCFirstName) + ' ' + rtrim(P.PCLastName) as PC1FullName
			 , cp.CurrentFSWFK
			 , rtrim(w.FirstName) + ' ' + rtrim(w.LastName) as CurrentWorkerFullName
			 -- , dbo.udfLevelOnDate(cp.ProgramFK, HVCasePK, @EndDate) as CurrentLevelName
			 , hvl.levelname as CurrentLevelName
			 , cp.ProgramFK
			 , tcid.TCIDPK
			 , case
				  when h.tcdob is not null then
					  h.tcdob
				  else
					  h.edc
			  end as TCDOB
			from HVCase h
				inner join CaseProgram cp on cp.HVCaseFK = h.HVCasePK
				inner join PC P on P.PCPK = h.PC1FK
				inner join Worker w on w.WorkerPK = cp.CurrentFSWFK
				inner join WorkerProgram wp on wp.WorkerFK = w.WorkerPK
				-- inner join codeLevel l on l.codeLevelPK = cp.CurrentLevelFK
				inner join dbo.udfHVLevel(@ProgramFKs, @EndDate) hvl on hvl.hvcasefk = cp.HVCaseFK
				inner join dbo.udfCaseFilters(@CaseFiltersPositive,'',@ProgramFKs) cf on cf.HVCaseFK = h.HVCasePK
				inner join dbo.SplitString(@ProgramFKs, ',') ss on ss.ListItem = cp.ProgramFK
				left join tcid on tcid.hvcasefk = h.hvcasepk -- for dead babies dod
			where
				--cp.ProgramFK = @ProgramFKs and 
				CurrentFSWFK = isnull(@FSWFK, CurrentFSWFK)
				and h.CaseProgress >= 9
				-- dead babies
				 and (h.IntakeDate is not null
					and h.IntakeDate <= @EndDate
					and h.TCDOD is null)
				and (tcid.TCDOD is null
					or tcid.TCDOD > @EndDate) -- 5/23/05 JH/DB if all children are dead don't include in performance target (FoxPro)
				-- inclusion / exclusion of closed case
				and (cp.DischargeDate is null
					or case -- closed cases are not included
						 when @IncludeClosedCases = 0 or @IncludeClosedCases is null then
							 (case
								 when cp.DischargeDate > @EndDate then
									 1
								 else
									 0
							 end)
						 else -- include closed cases
							 (case
								 when cp.DischargeDate >= @StartDate then
									 1
								 else
									 0
							 end)
					 end = 1)
				--siteFK
				and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)

	
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetHD1]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetHD1 @StartDate,@EndDate,@tblPTCohort
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetHD2]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetHD2 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetHD3]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetHD3 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetHD4]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetHD4 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetHD5]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetHD5 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetHD6]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetHD6 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetHD7]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetHD7 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetHD8]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetHD8 @StartDate,@EndDate,@tblPTCohort 

	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetPCI1]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetPCI1 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetPCI2]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetPCI2 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetPCI3]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetPCI3 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetPCI4]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetPCI4 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetPCI5]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetPCI5 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetPCI6]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetPCI6 @StartDate,@EndDate,@tblPTCohort 

	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetFLC1]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetFLC1 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetFLC2]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetFLC2 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetFLC3]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetFLC3 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetFLC4]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetFLC4 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetFLC5]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetFLC5 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetFLC6]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetFLC6 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetFLC7]') and type in (N'P', N'PC'))
		insert into @tblPTDetailsTemp
			exec rspPerformanceTargetFLC7 @StartDate,@EndDate,@tblPTCohort 

	;
	with cteSummaryQtr4
	as
	(
	select PTCode
			, count(PTCode) as TotalCases
			, sum(case when FormReviewed = 1 and FormMissing = 0 and FormOutOfWindow = 0 
					then 1
					else 0
					end) as ValidCases
			, sum(case when FormMeetsTarget = 1 then 1 else 0 end) as FormMeetsTarget
		from @tblPTDetailsTemp
		group by PTCode
	), 
	cteQtr4PercentageMeeting as
	(
	select PTCode
			, TotalCases
			, ValidCases as TotalValidCases
			, FormMeetsTarget as TotalCasesMeetingTarget
			, case when ValidCases = 0 then '**        '
					when (cast(ValidCases as float)/ cast(TotalCases as float)) < .75 then '*         ' 
					-- else convert(varchar(10), round((FormMeetsTarget / (ValidCases * 100.0000)), 0)) + '%'
					else cast(round(cast(FormMeetsTarget as float) / cast(ValidCases as float), 2) * 100 as varchar(10)) + '%'
				end as PercentageMeetingTarget
		from cteSummaryQtr4
		union 
		select PerformanceTargetCode
				, 0
				, 0
				, 0
				, '**        '
		from codePerformanceTargetTitle ptt
		where PerformanceTargetCode not in (select PTCode from cteSummaryQtr4)
	)
	
	update @tblPTSummary
		set Qtr4PercentageMeetingPT = isnull(PercentageMeetingTarget, 0)
			, Qtr4TotalCases = TotalCases
			, Qtr4ValidCases = TotalValidCases
			, Qtr4CasesMeetingTarget = TotalCasesMeetingTarget
		from cteQtr4PercentageMeeting q4
		where q4.PTCode = [@tblPTSummary].PTCode

	insert into @tblPTDetails
		select '4',* from @tblPTDetailsTemp
		 
	-- delete from @tblPTDetailsTemp

	-- select @RowCount
	-- select * from @tblPTDetailsTemp
	select PTCode
			, case when left(PTCode,2) = 'HD'
					then 1
					when left(PTCode,3) = 'PCI'
					then 2
					else 3
				end as PTSortOrder
			, ptt.PerformanceTargetCohortDescription
			, ptt.PerformanceTargetDescription
			, ptt.PerformanceTargetSection
			, ptt.PerformanceTargetTitle
			, Qtr1TotalCases
			, Qtr1ValidCases
			, Qtr1CasesMeetingTarget
			, Qtr1PercentageMeetingPT
			, Qtr2TotalCases
			, Qtr2ValidCases
			, Qtr2CasesMeetingTarget
			, Qtr2PercentageMeetingPT
			, Qtr3TotalCases
			, Qtr3ValidCases
			, Qtr3CasesMeetingTarget
			, Qtr3PercentageMeetingPT
			, Qtr4TotalCases
			, Qtr4ValidCases
			, Qtr4CasesMeetingTarget
			, Qtr4PercentageMeetingPT
	from @tblPTSummary
	inner join codePerformanceTargetTitle ptt on PTCode = PerformanceTargetCode
	order by PTSortOrder, PTCode

	select 	case when left(PTCode,2) = 'HD'
					then 1
					when left(PTCode,3) = 'PCI'
					then 2
					else 3
				end as PTSortOrder
			, * 
	from @tblPTDetails
	order by QuarterText
				, PTSortOrder
				, PTCode
				, PC1ID
end
GO
