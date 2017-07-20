SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		jrobohn
-- Create date: 2013Mar05
-- Description:	this returns the details for the selected performance target criteria
-- rspPerformanceTargetReportDetails 5 ,'10/01/2012' ,'12/31/2012'
-- Edit date: 10/11/2013 CP - workerprogram was NOT duplicating cases when worker transferred
-- =============================================
CREATE procedure [dbo].[rspPerformanceTargetReportDetails]
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
			from HVCase h  WITH (NOLOCK)
				inner join CaseProgram cp  WITH (NOLOCK) on cp.HVCaseFK = h.HVCasePK 
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

	declare @tblPTSummary table(
		[ReportTitleText] varchar(max),
		[PercentageMeetingPT] [varchar](50),
		[NumberMeetingPT] [varchar](50),
		[TotalValidCases] [varchar](50),
		[TotalCases] [varchar](50)
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
		)
	
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetHD1]') and type in (N'P', N'PC'))
		insert into @tblPTDetails
			exec rspPerformanceTargetHD1 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetHD2]') and type in (N'P', N'PC'))
		insert into @tblPTDetails
			exec rspPerformanceTargetHD2 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetHD3]') and type in (N'P', N'PC'))
		insert into @tblPTDetails
			exec rspPerformanceTargetHD3 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetHD4]') and type in (N'P', N'PC'))
		insert into @tblPTDetails
			exec rspPerformanceTargetHD4 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetHD5]') and type in (N'P', N'PC'))
		insert into @tblPTDetails
			exec rspPerformanceTargetHD5 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetHD6]') and type in (N'P', N'PC'))
		insert into @tblPTDetails
			exec rspPerformanceTargetHD6 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetHD7]') and type in (N'P', N'PC'))
		insert into @tblPTDetails
			exec rspPerformanceTargetHD7 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetHD8]') and type in (N'P', N'PC'))
		insert into @tblPTDetails
			exec rspPerformanceTargetHD8 @StartDate,@EndDate,@tblPTCohort 

	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetPCI1]') and type in (N'P', N'PC'))
		insert into @tblPTDetails
			exec rspPerformanceTargetPCI1 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetPCI2]') and type in (N'P', N'PC'))
		insert into @tblPTDetails
			exec rspPerformanceTargetPCI2 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetPCI3]') and type in (N'P', N'PC'))
		insert into @tblPTDetails
			exec rspPerformanceTargetPCI3 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetPCI4]') and type in (N'P', N'PC'))
		insert into @tblPTDetails
			exec rspPerformanceTargetPCI4 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetPCI5]') and type in (N'P', N'PC'))
		insert into @tblPTDetails
			exec rspPerformanceTargetPCI5 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetPCI6]') and type in (N'P', N'PC'))
		insert into @tblPTDetails
			exec rspPerformanceTargetPCI6 @StartDate,@EndDate,@tblPTCohort 

	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetFLC1]') and type in (N'P', N'PC'))
		insert into @tblPTDetails
			exec rspPerformanceTargetFLC1 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetFLC2]') and type in (N'P', N'PC'))
		insert into @tblPTDetails
			exec rspPerformanceTargetFLC2 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetFLC3]') and type in (N'P', N'PC'))
		insert into @tblPTDetails
			exec rspPerformanceTargetFLC3 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetFLC4]') and type in (N'P', N'PC'))
		insert into @tblPTDetails
			exec rspPerformanceTargetFLC4 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetFLC5]') and type in (N'P', N'PC'))
		insert into @tblPTDetails
			exec rspPerformanceTargetFLC5 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetFLC6]') and type in (N'P', N'PC'))
		insert into @tblPTDetails
			exec rspPerformanceTargetFLC6 @StartDate,@EndDate,@tblPTCohort 
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspPerformanceTargetFLC7]') and type in (N'P', N'PC'))
		insert into @tblPTDetails
			exec rspPerformanceTargetFLC7 @StartDate,@EndDate,@tblPTCohort 

	select * 
			, case when FormReviewed = 0 or FormOutOfWindow = 1 or FormMissing = 1 then 1 -- Invalid / Missing Cases
					when FormReviewed = 1 and FormOutOfWindow = 0 and FormMissing = 0 and FormMeetsTarget = 0 then 2 -- Cases Not Meeting
					else 3
				end as PrimarySort
			, case when left(PTCode,2) = 'HD' then 1
					when left(PTCode,3) = 'PCI' then 2
					else 3
				end as SecondarySort
			, case when FormReviewed = 0 or FormOutOfWindow = 1 or FormMissing = 1 then 'Invalid / Missing Cases'
					when FormReviewed = 1 and FormOutOfWindow = 0 and FormMissing = 0 and FormMeetsTarget = 0 then 'Cases Not Meeting'
					else 'Cases Meeting'
				end as GroupHeader
		from @tblPTDetails
		order by PrimarySort
					, SecondarySort
					, PTCode
					, PC1ID
							
-- rspPerformanceTargetReportDetails 19, '07/01/2012', '09/30/2012'
end
GO
