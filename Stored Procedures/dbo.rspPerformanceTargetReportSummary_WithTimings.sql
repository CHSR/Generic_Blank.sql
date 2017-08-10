SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <Febu. 11, 2013>
-- Description:	<This Performance Target report gets you 'Summary for all Performance Target reports '>
-- rspPerformanceTargetReportSummary 5 ,'10/01/2012' ,'12/31/2012'
-- rspPerformanceTargetReportSummary 2 ,'10/01/2012' ,'12/31/2012'
-- rspPerformanceTargetReportSummary 2 ,'04/01/2012' ,'06/30/2012'
-- rspPerformanceTargetReportSummary 24,'10/01/2012' ,'12/31/2012'
-- rspPerformanceTargetReportSummary_WithTimings 9, '04/01/2013', '06/30/2013', 471
-- mods by jrobohn 20130222 - clean up names, code and layout
-- mods by jrobohn 20130223 - added PCI1 report
-- =============================================

CREATE procedure [dbo].[rspPerformanceTargetReportSummary_WithTimings]
(
    @ProgramFKs				varchar(max)    = null,
    @StartDate				datetime,
    @EndDate				datetime,
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

	/** For performance reasons, get the active cases that belong to the cohort now **/
	/* Declare a variable that references the type. */
	declare @tblPTCohort as PTCases; -- PTCases is a user defined type

	/* Add data to the table variable. */
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
		select
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

	/***************************/
	declare @StartTime datetime

	declare @tblPTSummary table(
		[ReportTitleText] varchar(max),
		[PercentageMeetingPT] [varchar](50),
		[NumberMeetingPT] [varchar](50),
		[TotalValidCases] [varchar](50),
		[TotalCases] [varchar](50),
		TimeToRun datetime
	)

	declare @tblPTDetails table
		(
		PTCode				char(5)
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
		, TimeToRun datetime
		)

	set @StartTime = getdate()
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetHD1]') and type in (N'P', N'PC'))
		insert into @tblPTDetails
		(
		PTCode				
		, HVCaseFK			
		, PC1ID				
		, OldID				
		, TCDOB				
		, PC1Fullname		
		, WorkerFullName	
		, CurrentLevelName	
		, FormName			
		, FormDate			
		, FormReviewed		
		, FormOutOfWindow	
		, FormMissing		
		, FormMeetsTarget	
		, ReasonNotMeeting	
		)
			exec rspPerformanceTargetHD1 @StartDate,@EndDate,@tblPTCohort 
	update @tblPTDetails 
	set TimeToRun = CONVERT(DateTime,GETDATE()-@StartTime)
	where PTCode = 'HD1'
	set @StartTime = getdate()
	
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetHD2]') and type in (N'P', N'PC'))
		insert into @tblPTDetails
		(
		PTCode				
		, HVCaseFK			
		, PC1ID				
		, OldID				
		, TCDOB				
		, PC1Fullname		
		, WorkerFullName	
		, CurrentLevelName	
		, FormName			
		, FormDate			
		, FormReviewed		
		, FormOutOfWindow	
		, FormMissing		
		, FormMeetsTarget	
		, ReasonNotMeeting	
		)
			exec rspPerformanceTargetHD2 @StartDate,@EndDate,@tblPTCohort 
	update @tblPTDetails 
	set TimeToRun = CONVERT(DateTime,GETDATE()-@StartTime)
	where PTCode = 'HD2'
	set @StartTime = getdate()

	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetHD3]') and type in (N'P', N'PC'))
		insert into @tblPTDetails
		(
		PTCode				
		, HVCaseFK			
		, PC1ID				
		, OldID				
		, TCDOB				
		, PC1Fullname		
		, WorkerFullName	
		, CurrentLevelName	
		, FormName			
		, FormDate			
		, FormReviewed		
		, FormOutOfWindow	
		, FormMissing		
		, FormMeetsTarget	
		, ReasonNotMeeting	
		)
			exec rspPerformanceTargetHD3 @StartDate,@EndDate,@tblPTCohort 
	update @tblPTDetails 
	set TimeToRun = CONVERT(DateTime,GETDATE()-@StartTime)
	where PTCode = 'HD3'
	set @StartTime = getdate()

	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetHD4]') and type in (N'P', N'PC'))
		insert into @tblPTDetails
		(
		PTCode				
		, HVCaseFK			
		, PC1ID				
		, OldID				
		, TCDOB				
		, PC1Fullname		
		, WorkerFullName	
		, CurrentLevelName	
		, FormName			
		, FormDate			
		, FormReviewed		
		, FormOutOfWindow	
		, FormMissing		
		, FormMeetsTarget	
		, ReasonNotMeeting	
		)
			exec rspPerformanceTargetHD4 @StartDate,@EndDate,@tblPTCohort 
	update @tblPTDetails 
	set TimeToRun = CONVERT(DateTime,GETDATE()-@StartTime)
	where PTCode = 'HD4'
	set @StartTime = getdate()

	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetHD5]') and type in (N'P', N'PC'))
		insert into @tblPTDetails
		(
		PTCode				
		, HVCaseFK			
		, PC1ID				
		, OldID				
		, TCDOB				
		, PC1Fullname		
		, WorkerFullName	
		, CurrentLevelName	
		, FormName			
		, FormDate			
		, FormReviewed		
		, FormOutOfWindow	
		, FormMissing		
		, FormMeetsTarget	
		, ReasonNotMeeting	
		)
			exec rspPerformanceTargetHD5 @StartDate,@EndDate,@tblPTCohort 
	update @tblPTDetails 
	set TimeToRun = CONVERT(DateTime,GETDATE()-@StartTime)
	where PTCode = 'HD5'
	set @StartTime = getdate()

	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetHD6]') and type in (N'P', N'PC'))
		insert into @tblPTDetails
		(
		PTCode				
		, HVCaseFK			
		, PC1ID				
		, OldID				
		, TCDOB				
		, PC1Fullname		
		, WorkerFullName	
		, CurrentLevelName	
		, FormName			
		, FormDate			
		, FormReviewed		
		, FormOutOfWindow	
		, FormMissing		
		, FormMeetsTarget	
		, ReasonNotMeeting	
		)
			exec rspPerformanceTargetHD6 @StartDate,@EndDate,@tblPTCohort 
	update @tblPTDetails 
	set TimeToRun = CONVERT(DateTime,GETDATE()-@StartTime)
	where PTCode = 'HD6'
	set @StartTime = getdate()

	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetHD7]') and type in (N'P', N'PC'))
		insert into @tblPTDetails
		(
		PTCode				
		, HVCaseFK			
		, PC1ID				
		, OldID				
		, TCDOB				
		, PC1Fullname		
		, WorkerFullName	
		, CurrentLevelName	
		, FormName			
		, FormDate			
		, FormReviewed		
		, FormOutOfWindow	
		, FormMissing		
		, FormMeetsTarget	
		, ReasonNotMeeting	
		)
			exec rspPerformanceTargetHD7 @StartDate,@EndDate,@tblPTCohort 
	update @tblPTDetails 
	set TimeToRun = CONVERT(DateTime,GETDATE()-@StartTime)
	where PTCode = 'HD7'
	set @StartTime = getdate()

	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetHD8]') and type in (N'P', N'PC'))
		insert into @tblPTDetails
		(
		PTCode				
		, HVCaseFK			
		, PC1ID				
		, OldID				
		, TCDOB				
		, PC1Fullname		
		, WorkerFullName	
		, CurrentLevelName	
		, FormName			
		, FormDate			
		, FormReviewed		
		, FormOutOfWindow	
		, FormMissing		
		, FormMeetsTarget	
		, ReasonNotMeeting	
		)
			exec rspPerformanceTargetHD8 @StartDate,@EndDate,@tblPTCohort 
	update @tblPTDetails 
	set TimeToRun = CONVERT(DateTime,GETDATE()-@StartTime)
	where PTCode = 'HD8'
	set @StartTime = getdate()

	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetPCI1]') and type in (N'P', N'PC'))
		insert into @tblPTDetails
		(
		PTCode				
		, HVCaseFK			
		, PC1ID				
		, OldID				
		, TCDOB				
		, PC1Fullname		
		, WorkerFullName	
		, CurrentLevelName	
		, FormName			
		, FormDate			
		, FormReviewed		
		, FormOutOfWindow	
		, FormMissing		
		, FormMeetsTarget	
		, ReasonNotMeeting	
		)
			exec rspPerformanceTargetPCI1 @StartDate,@EndDate,@tblPTCohort 
	update @tblPTDetails 
	set TimeToRun = CONVERT(DateTime,GETDATE()-@StartTime)
	where PTCode = 'PCI1'
	set @StartTime = getdate()

	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetPCI2]') and type in (N'P', N'PC'))
		insert into @tblPTDetails
		(
		PTCode				
		, HVCaseFK			
		, PC1ID				
		, OldID				
		, TCDOB				
		, PC1Fullname		
		, WorkerFullName	
		, CurrentLevelName	
		, FormName			
		, FormDate			
		, FormReviewed		
		, FormOutOfWindow	
		, FormMissing		
		, FormMeetsTarget	
		, ReasonNotMeeting	
		)
			exec rspPerformanceTargetPCI2 @StartDate,@EndDate,@tblPTCohort 
	update @tblPTDetails 
	set TimeToRun = CONVERT(DateTime,GETDATE()-@StartTime)
	where PTCode = 'PCI2'
	set @StartTime = getdate()

	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetPCI3]') and type in (N'P', N'PC'))
		insert into @tblPTDetails
		(
		PTCode				
		, HVCaseFK			
		, PC1ID				
		, OldID				
		, TCDOB				
		, PC1Fullname		
		, WorkerFullName	
		, CurrentLevelName	
		, FormName			
		, FormDate			
		, FormReviewed		
		, FormOutOfWindow	
		, FormMissing		
		, FormMeetsTarget	
		, ReasonNotMeeting	
		)
			exec rspPerformanceTargetPCI3 @StartDate,@EndDate,@tblPTCohort 
	update @tblPTDetails 
	set TimeToRun = CONVERT(DateTime,GETDATE()-@StartTime)
	where PTCode = 'PCI3'
	set @StartTime = getdate()

	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetPCI4]') and type in (N'P', N'PC'))
		insert into @tblPTDetails
		(
		PTCode				
		, HVCaseFK			
		, PC1ID				
		, OldID				
		, TCDOB				
		, PC1Fullname		
		, WorkerFullName	
		, CurrentLevelName	
		, FormName			
		, FormDate			
		, FormReviewed		
		, FormOutOfWindow	
		, FormMissing		
		, FormMeetsTarget	
		, ReasonNotMeeting	
		)
			exec rspPerformanceTargetPCI4 @StartDate,@EndDate,@tblPTCohort 
	update @tblPTDetails 
	set TimeToRun = CONVERT(DateTime,GETDATE()-@StartTime)
	where PTCode = 'PCI4'
	set @StartTime = getdate()

	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetPCI5]') and type in (N'P', N'PC'))
		insert into @tblPTDetails
		(
		PTCode				
		, HVCaseFK			
		, PC1ID				
		, OldID				
		, TCDOB				
		, PC1Fullname		
		, WorkerFullName	
		, CurrentLevelName	
		, FormName			
		, FormDate			
		, FormReviewed		
		, FormOutOfWindow	
		, FormMissing		
		, FormMeetsTarget	
		, ReasonNotMeeting	
		)
			exec rspPerformanceTargetPCI5 @StartDate,@EndDate,@tblPTCohort 
	update @tblPTDetails 
	set TimeToRun = CONVERT(DateTime,GETDATE()-@StartTime)
	where PTCode = 'PCI5'
	set @StartTime = getdate()

	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetPCI6]') and type in (N'P', N'PC'))
		insert into @tblPTDetails
		(
		PTCode				
		, HVCaseFK			
		, PC1ID				
		, OldID				
		, TCDOB				
		, PC1Fullname		
		, WorkerFullName	
		, CurrentLevelName	
		, FormName			
		, FormDate			
		, FormReviewed		
		, FormOutOfWindow	
		, FormMissing		
		, FormMeetsTarget	
		, ReasonNotMeeting	
		)
			exec rspPerformanceTargetPCI6 @StartDate,@EndDate,@tblPTCohort 
	update @tblPTDetails 
	set TimeToRun = CONVERT(DateTime,GETDATE()-@StartTime)
	where PTCode = 'PCI6'
	set @StartTime = getdate()


	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetFLC1]') and type in (N'P', N'PC'))
		insert into @tblPTDetails
		(
		PTCode				
		, HVCaseFK			
		, PC1ID				
		, OldID				
		, TCDOB				
		, PC1Fullname		
		, WorkerFullName	
		, CurrentLevelName	
		, FormName			
		, FormDate			
		, FormReviewed		
		, FormOutOfWindow	
		, FormMissing		
		, FormMeetsTarget	
		, ReasonNotMeeting	
		)
			exec rspPerformanceTargetFLC1 @StartDate,@EndDate,@tblPTCohort 
	update @tblPTDetails 
	set TimeToRun = CONVERT(DateTime,GETDATE()-@StartTime)
	where PTCode = 'FLC1'
	set @StartTime = getdate()

	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetFLC2]') and type in (N'P', N'PC'))
		insert into @tblPTDetails
		(
		PTCode				
		, HVCaseFK			
		, PC1ID				
		, OldID				
		, TCDOB				
		, PC1Fullname		
		, WorkerFullName	
		, CurrentLevelName	
		, FormName			
		, FormDate			
		, FormReviewed		
		, FormOutOfWindow	
		, FormMissing		
		, FormMeetsTarget	
		, ReasonNotMeeting	
		)
			exec rspPerformanceTargetFLC2 @StartDate,@EndDate,@tblPTCohort 
	update @tblPTDetails 
	set TimeToRun = CONVERT(DateTime,GETDATE()-@StartTime)
	where PTCode = 'FLC2'
	set @StartTime = getdate()

	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetFLC3]') and type in (N'P', N'PC'))
		insert into @tblPTDetails
		(
		PTCode				
		, HVCaseFK			
		, PC1ID				
		, OldID				
		, TCDOB				
		, PC1Fullname		
		, WorkerFullName	
		, CurrentLevelName	
		, FormName			
		, FormDate			
		, FormReviewed		
		, FormOutOfWindow	
		, FormMissing		
		, FormMeetsTarget	
		, ReasonNotMeeting	
		)
			exec rspPerformanceTargetFLC3 @StartDate,@EndDate,@tblPTCohort 
	update @tblPTDetails 
	set TimeToRun = CONVERT(DateTime,GETDATE()-@StartTime)
	where PTCode = 'FLC3'
	set @StartTime = getdate()

	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetFLC4]') and type in (N'P', N'PC'))
		insert into @tblPTDetails
		(
		PTCode				
		, HVCaseFK			
		, PC1ID				
		, OldID				
		, TCDOB				
		, PC1Fullname		
		, WorkerFullName	
		, CurrentLevelName	
		, FormName			
		, FormDate			
		, FormReviewed		
		, FormOutOfWindow	
		, FormMissing		
		, FormMeetsTarget	
		, ReasonNotMeeting	
		)
			exec rspPerformanceTargetFLC4 @StartDate,@EndDate,@tblPTCohort 
	update @tblPTDetails 
	set TimeToRun = CONVERT(DateTime,GETDATE()-@StartTime)
	where PTCode = 'FLC4'
	set @StartTime = getdate()

	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetFLC5]') and type in (N'P', N'PC'))
		insert into @tblPTDetails
		(
		PTCode				
		, HVCaseFK			
		, PC1ID				
		, OldID				
		, TCDOB				
		, PC1Fullname		
		, WorkerFullName	
		, CurrentLevelName	
		, FormName			
		, FormDate			
		, FormReviewed		
		, FormOutOfWindow	
		, FormMissing		
		, FormMeetsTarget	
		, ReasonNotMeeting	
		)
			exec rspPerformanceTargetFLC5 @StartDate,@EndDate,@tblPTCohort 
	update @tblPTDetails 
	set TimeToRun = CONVERT(DateTime,GETDATE()-@StartTime)
	where PTCode = 'FLC5'
	set @StartTime = getdate()

	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetFLC6]') and type in (N'P', N'PC'))
		insert into @tblPTDetails
		(
		PTCode				
		, HVCaseFK			
		, PC1ID				
		, OldID				
		, TCDOB				
		, PC1Fullname		
		, WorkerFullName	
		, CurrentLevelName	
		, FormName			
		, FormDate			
		, FormReviewed		
		, FormOutOfWindow	
		, FormMissing		
		, FormMeetsTarget	
		, ReasonNotMeeting	
		)
			exec rspPerformanceTargetFLC6 @StartDate,@EndDate,@tblPTCohort 
	update @tblPTDetails 
	set TimeToRun = CONVERT(DateTime,GETDATE()-@StartTime)
	where PTCode = 'FLC6'
	set @StartTime = getdate()

	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetFLC7]') and type in (N'P', N'PC'))
		insert into @tblPTDetails
		(
		PTCode				
		, HVCaseFK			
		, PC1ID				
		, OldID				
		, TCDOB				
		, PC1Fullname		
		, WorkerFullName	
		, CurrentLevelName	
		, FormName			
		, FormDate			
		, FormReviewed		
		, FormOutOfWindow	
		, FormMissing		
		, FormMeetsTarget	
		, ReasonNotMeeting	
		)
			exec rspPerformanceTargetFLC7 @StartDate,@EndDate,@tblPTCohort 
	update @tblPTDetails 
	set TimeToRun = CONVERT(DateTime,GETDATE()-@StartTime)
	where PTCode = 'FLC7'
	set @StartTime = getdate()


	;
	with cteSummary
	as
	(
	select PTCode
			, sum(case when FormReviewed = 1 and FormMissing = 0 and FormOutOfWindow = 0 
					then 1
					else 0
					end) as ValidCases
			, count(PTCode) as TotalCases
			, sum(case when FormMeetsTarget = 1 then 1 else 0 end) as FormMeetsTarget
			, TimeToRun
		from @tblPTDetails
		group by PTCode, TimeToRun
	)
	
	-- select * from cteSummary
		
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
			, ValidCases
			, TotalCases
			, FormMeetsTarget
			, TimeToRun
	from cteSummary s
	inner join codePerformanceTargetTitle ptt on PTCode = PerformanceTargetCode
	union 
	select PerformanceTargetCode as PTCode
			, case when left(PerformanceTargetCode,2) = 'HD'
					then 1
					when left(PerformanceTargetCode,3) = 'PCI'
					then 2
					else 3
				end as PTSortOrder
			, PerformanceTargetCohortDescription
			, PerformanceTargetDescription
			, PerformanceTargetSection
			, PerformanceTargetTitle
			, 0 as ValidCases
			, 0 as TotalCases
			, 0 as FormMeetsTarget 
			, null as TimeToRun
		from codePerformanceTargetTitle ptt
		where PerformanceTargetCode not in (select PTCode from cteSummary sum2) -- missing on missing.PerformanceTargetCode = s.PTCode 
	order by PTSortOrder, PTCode
	
	select *
			, case when left(PTCode,2) = 'HD'
					then 1
					when left(PTCode,3) = 'PCI'
					then 2
					else 3
				end as PTSortOrder
	 from @tblPTDetails
		order by PTSortOrder, PTCode, PC1ID

-- rspPerformanceTargetReportSummary '1,17,19', '07/01/2012', '09/30/2012'
end
GO
