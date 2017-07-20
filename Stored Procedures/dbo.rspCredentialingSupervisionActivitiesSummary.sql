SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Devinder Singh Khalsa
-- Create date: January 9th, 2014
-- Description:	Credentialing report for Supervisions Activities Summary

-- All --  rspCredentialingSupervisionActivitiesSummary 1, '06/01/2013', '08/31/2013'
-- By worker -- rspCredentialingSupervisionActivitiesSummary 1, '06/01/2013', '08/31/2013',null,152,null
-- By Supervisor -- rspCredentialingSupervisionActivitiesSummary 1, '06/01/2013', '08/31/2013',15,null,null
-- By Supervisor and worker -- rspCredentialingSupervisionActivitiesSummary 1, '06/01/2013', '08/31/2013',15,132,null

-- rspCredentialingSupervisionActivitiesSummary 1, '06/01/2013', '08/31/2013',null,152,null,2


-- rspCredentialingSupervisionActivitiesSummary 1, '06/01/2013', '08/31/2013',null,null,5
-- Edit date: 10/11/2013 CP - workerprogram was duplicating cases when worker transferred
--            added this code to the workerprogram join condition: AND wp.programfk = listitem

-- =============================================
CREATE procedure [dbo].[rspCredentialingSupervisionActivitiesSummary]
	@ProgramFK  int           = null,
    @sDate  datetime      =   null,
    @eDate  datetime      =  null,
    @supervisorfk int             = null,
    @workerfk     int             = null,
	@sitefk		 int			 = null
    
as


set nocount on

IF 1=0 BEGIN
    SET FMTONLY OFF
END


	set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0 else @SiteFK end	
	
	
	--Step#: 1
	-- Get list of all FAW and FSW that belong to the given program
	create table #tblFAWFSWWorkers(
			WorkerName varchar(100)
			,LastName		varchar(50)
			,FirstName		varchar(50)
			,TerminationDate datetime
			,WorkerPK int
			,SortOrder int
		
		)
		
	insert into #tblFAWFSWWorkers
			exec spGetAllWorkersbyProgram @ProgramFK,null,'FAW,FSW', null
	
	---- Exclude Worker who are SUP and PM from the above list of workers
	--	create table #tblSUPPMWorkers(
	--		WorkerName varchar(100)
	--		,LastName		varchar(50)
	--		,FirstName		varchar(50)
	--		,TerminationDate datetime
	--		,WorkerPK int
	--		,SortOrder int
		
	--	)
		
	--insert into #tblSUPPMWorkers
	--		exec spGetAllWorkersbyProgram @ProgramFK,null,'SUP,PM', null		


		-- List of workers i.e. FAW, FSW minus 	SUP,PM
		-- List of workers who are not supervisor or program manager
		create table #tblWorkers(
			 WorkerName varchar(100)
			 , LastName		varchar(50)
			 , FirstName		varchar(50)
			 , TerminationDate datetime
			 , WorkerPK int
			 , SortOrder int
			
			 , WorkerFKFn int
			 , WrkrLName varchar(50)
			 , FAWInitialStart datetime
			 , SupervisorInitialStart datetime
			 , FSWInitialStart datetime
			 , TerminationDateFn datetime
			 , HireDate datetime
			 , SupervisorFirstEvent datetime
			 , FirstASQDate datetime
			 , FirstHomeVisitDate datetime
			 , FirstKempeDate datetime
			 , FirstEvent	datetime		
			 , SupervisorFK int
		
		)	
	
	insert into #tblWorkers	
	SELECT 
			 w.WorkerName
			 , w.LastName
			 , w.FirstName
			 , w.TerminationDate
			 , w.WorkerPK
			 , w.SortOrder
			 
			 , fn.WorkerPK
			 , WrkrLName
			 , FAWInitialStart
			 , SupervisorInitialStart
			 , FSWInitialStart
			 , fn.TerminationDate 
			 , fn.HireDate
			 , SupervisorFirstEvent
			 , FirstASQDate
			 , FirstHomeVisitDate
			 , FirstKempeDate
		     , fn.FirstEvent
		     , wp.SupervisorFK
		  
		   FROM #tblFAWFSWWorkers w 
		   inner join workerprogram wp on wp.workerfk = w.workerpk 
		   --AND wp.programfk = @ProgramFK
	INNER JOIN dbo.fnGetWorkerEventDatesALL(@ProgramFK, NULL, NULL) fn ON fn.workerpk = w.workerpk
	where 
	--w.workerpk not in (SELECT workerpk FROM #tblSUPPMWorkers)
	--and
	fn.FirstEvent <= @eDate -- exclude workers who are probably new and have not activity (visits) yet ... khalsa
	
	and  w.workerpk = isnull(@workerfk,w.workerpk)
    and wp.supervisorfk = isnull(@supervisorfk,wp.supervisorfk)
    --and startdate < enddate --Chris Papas 05/25/2011 due to problem with pc1id='IW8601030812'
    and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)	
	
	
	order by w.workername	
	
	
	--SELECT * FROM #tblWorkers
	
	-- rspCredentialingSupervisionActivitiesSummary 1, '06/01/2013', '08/31/2013',15,132,null

	
	
-- getting workername and supervisorname
-- we need them for the report	
declare @WorkerName varchar(100) = null 
declare @SupervisorName varchar(100) = null

set @WorkerName = (SELECT WorkerName FROM #tblWorkers where WorkerPK = @workerfk)
set @SupervisorName = (select ltrim(rtrim(LastName)) + ', ' + ltrim(rtrim(FirstName)) as SupervisorName 
		from Worker w
		inner join WorkerProgram wp on wp.WorkerFK = w.WorkerPK
		where programfk = @ProgramFK 
				and current_timestamp between SupervisorStartDate AND isnull(SupervisorEndDate,dateadd(dd,1,datediff(dd,0,getdate())))
	and	WorkerPK = @supervisorfk)	
	
--if (@SupervisorName is null and @workerfk is not null)

--begin
--set @SupervisorName = (select ltrim(rtrim(LastName)) + ', ' + ltrim(rtrim(FirstName)) as SupervisorName 
--		from Worker w
--		inner join WorkerProgram wp on wp.WorkerFK = w.WorkerPK
--		where programfk = @ProgramFK 
--				and current_timestamp between SupervisorStartDate AND isnull(SupervisorEndDate,dateadd(dd,1,datediff(dd,0,getdate())))
--	and	WorkerPK = (select SupervisorFK from WorkerProgram where WorkerFK = @workerfk))	
--end

--select @SupervisorName, @WorkerName

-- set them blank if null ( our report ui does like nulls)	
if @SupervisorName is null 
begin 
	set @SupervisorName = ''	
end
else
begin 
	set @SupervisorName = 'Supervisor Name: ' + @SupervisorName
end	



if @WorkerName is null 
begin 
	set @WorkerName = ''	
end	
else
begin 
	set @WorkerName = 'Worker Name: ' + @WorkerName
	set @SupervisorName = '' -- There may be more than one supervisor for a worker, so no sup name
end	

	
-- for display in the same field, @SupervisorName and @WorkerName are Mutually Exclusive
if @SupervisorName = '' AND  @WorkerName <> ''
begin 
	set @SupervisorName = @WorkerName
	set @WorkerName = ''
end
	
	
	
	
	
	create table #tblWorkerAndSupName(
			WorkerName varchar(100)
			,SupervisorName varchar(100)
		
		)
			
insert into #tblWorkerAndSupName	
		SELECT  @WorkerName, @SupervisorName	
	
	--SELECT workerpk FROM #tblSUPPMWorkers
	--SELECT * FROM #tblWorkers
	

	-- rspCredentialingSupervisionActivitiesSummary 1, '01/06/2013', '02/02/2013',15,152		
	-- rspCredentialingSupervisionActivitiesSummary 1, '03/01/2013', '03/31/2013'		
			
	--Step#: 2
	-- use a recursive CTE to generate the list of dates  ... Khalsa
	-- Given any startdate, find all week dates starting with that date and less then the end date
	-- We need these dates to figure out if a given worker was supervised in each of the week within startdate and enddate for credentialing purposes

	
	create table #tblWeekPeriods(
			WeekNumber int			
			,StartDate datetime
			,EndDate datetime
		
		)	
	
	
	;with cteGenerateWeeksGiven2Dates as
	(
	  select 1 as WeekNumber,
	    @sDate StartDate, 
		dateadd(d,6,@sDate) EndDate
		
	  union all
	  
	  select 
	  WeekNumber + 1 as WeekNumber,
	   dateadd(d,7, StartDate) as StartDate,
	   dateadd(d,7, EndDate) as EndDate
	   
	   
	  from cteGenerateWeeksGiven2Dates
	  
	  
	  where dateadd(d,6, StartDate)<=  @eDate	  
	  
	)	
	
	
	
	insert into #tblWeekPeriods	
		select *
		from cteGenerateWeeksGiven2Dates
	

	
	------ We are only interested in each week's start date
	------ These are all the weeks between given two dates but at the end we added user given @eDate ... khalsa
		
	
	-- insert user's enddate at the end for the last period
		update #tblWeekPeriods
		set EndDate = @eDate
		where WeekNumber = (select top 1 WeekNumber from #tblWeekPeriods order by WeekNumber desc)


		--Note: Don't delete the following SELECT
		--SELECT 
		--	WeekNumber
		--	,StartDate
		--	,EndDate
		--	,datediff(day, StartDate,EndDate) as DaysInTheCurrentWeek			
		--FROM #tblWeekPeriods	

	

--	 rspCredentialingSupervisionActivitiesSummary 1, '04/01/2013', '04/30/2013'		
		
--		SELECT * FROM #tblWorkers
--		where WorkerPK = 152  -- worker: Burdick, Catherine


	-- Let us make sure that if a worker's firstevent date falls between @sdate and @edate then 
	-- adjust number of weeks for that worker. It will be less because he did not do anything till firstevent
	create table #tblWeekPeriodsAdjusted(
			WeekNumber int			
			,StartDate datetime
			,EndDate datetime
			,FirstEvent datetime
			,WorkerPK int	
		)	
	

	insert into #tblWeekPeriodsAdjusted	
		SELECT 
			WeekNumber
			,StartDate
			,EndDate		
			,FirstEvent
			,WorkerPK
		 FROM #tblWeekPeriods
		 inner join #tblWorkers w on FirstEvent < StartDate



----		-- Step#: 3
----		-- Now let us develop the report. We will use the above 2 temp tables now
		
		;

-- Part 1: Supervision sessions that did not take place with a reason	

	-- Supervision sessions that took place
	with cteSupervisionsThatTookPlace
	as
	(
				SELECT 
		
				 wp.WeekNumber
				,wp.StartDate
				,wp.EndDate		
				,wp.FirstEvent
				,wp.WorkerPK
						
				,isnull(SupervisionHours * 60,0) + isnull(SupervisionMinutes,0) as Duration
				,case when (isnull(SupervisionHours * 60,0) + isnull(SupervisionMinutes,0)) >= 90 then 1
				else 0 end as SupTimeGreaterThan90Mins
				
		
				
								
			 , WorkerName
			 , LastName
			 , FirstName
			 , TerminationDate
			 --, WorkerPK
			 , SortOrder
			
			 , WorkerFKFn
			 , WrkrLName
			 , FAWInitialStart
			 , SupervisorInitialStart 
			 , FSWInitialStart 
			 , TerminationDateFn 
			 , HireDate 
			 , SupervisorFirstEvent 
			 , FirstASQDate 
			 , FirstHomeVisitDate 
			 , FirstKempeDate 
			 --, FirstEvent			
				
				
				
				
		
			  ,SupervisionPK
			  --,ActivitiesOther
			  ,ActivitiesOtherSpecify
			  --,AreasGrowth
			  --,AssessmentIssues
			  --,AssessmentRate
			  --,Boundaries
			  --,Caseload
			  --,Coaching
			  --,CommunityResources
			  --,CulturalSensitivity
			  --,Curriculum
			  --,FamilyProgress
			  --,HomeVisitLogActivities
			  --,HomeVisitRate
			  --,IFSP
			  --,ImplementTraining
			  --,LevelChange
			  --,Outreach
			  ,ParticipantEmergency
			  --,PersonalGrowth
			  --,ProfessionalGrowth
			  ,ReasonOther
			  ,ReasonOtherSpecify
			  ,RecordDocumentation
			  --,Referrals
			  --,Retention
			  --,RolePlaying
			  --,Safety
			  ,ShortWeek
			  ,StaffCourt
			  ,StaffFamilyEmergency
			  ,StaffForgot
			  ,StaffIll
			  ,StaffTraining
			  ,StaffVacation
			  ,StaffOutAllWeek
			  --,StrengthBasedApproach
			  --,Strengths
			  ,SupervisionCreateDate
			  ,SupervisionCreator
			  ,SupervisionDate
			  ,SupervisionEditDate
			  ,SupervisionEditor
			  ,SupervisionEndTime
			  ,SupervisionHours
			  ,SupervisionMinutes
			  ,SupervisionNotes
			  ,SupervisionStartTime
			  ,SupervisorFamilyEmergency
			  --,SupervisorFK
			  ,SupervisorForgot
			  ,SupervisorHoliday
			  ,SupervisorIll
			  --,SupervisorObservationAssessment
			  --,SupervisorObservationHomeVisit
			  ,SupervisorTraining
			  ,SupervisorVacation
			  ,TakePlace
			  --,TechniquesApproaches
			  --,Tools
			  --,TrainingNeeds
			  ,Weather
			  ,WorkerFK	
			-- note: we added 1 in datediff(d, StartDate,EndDate) because substraction gives one day less. e.g. 7-1 = 6			
			, datediff(d, StartDate,EndDate) + 1 as DaysInTheCurrentWeek	-- null means that there was no supervision record found for that week  ... khalsa		  
			--,case when WorkerFK is null and SupervisionPK is null then null else datediff(d, StartDate,EndDate) end as DaysInTheCurrentWeek	-- null means that there was no supervision record found for that week  ... khalsa		  
			  
			   FROM #tblWeekPeriodsAdjusted wp 		
		--left join #tblWorkers w on 1=1  -- We need to know if supervision event in any week is missing
		left join #tblWorkers w on w.workerpk = wp.workerpk  -- include only those weeks where worker performed supervisions. 
		left join Supervision s on s.WorkerFK = w.WorkerPK and SupervisionDate between StartDate and EndDate
		where SupervisionPK is not null
		and TakePlace = 1
	)
	


--SELECT * FROM cteSupervisionsThatTookPlace
--SELECT * FROM cteSupervisionsThatDidNotTakePlace

	-- Supervision sessions that took place
	,cteSupervisionsThatTookPlaceActivities
	as
	(
				SELECT 

		count(*) as NumOfTotalSupervisions
		
		
				
	  ,sum(convert(int,AssessmentIssues)) as AssessmentIssues	
	  ,sum(convert(int,IFSP)) as IFSP
	  ,sum(convert(int,FamilyProgress)) as FamilyProgress
	  ,sum(convert(int,Tools)) as Tools
	  
	  ,sum(convert(int,Referrals)) as Referrals
	  ,sum(convert(int,CommunityResources)) as CommunityResources
	  ,sum(convert(int,Coaching)) as Coaching
	  ,sum(convert(int,StrengthBasedApproach)) as StrengthBasedApproach
	  ,sum(convert(int,LevelChange)) as LevelChange
	  ,sum(convert(int,Caseload)) as Caseload
	  ,sum(convert(int,HomeVisitRate)) as HomeVisitRate
	  ,sum(convert(int,AssessmentRate)) as AssessmentRate
	  ,sum(convert(int,Retention)) as Retention
	  ,sum(convert(int,HomeVisitLogActivities)) as HomeVisitLogActivities
	  ,sum(convert(int,RecordDocumentation)) as RecordDocumentation
	  ,sum(convert(int,Outreach)) as Outreach
	  
	  ,sum(convert(int,Safety)) as Safety	
	  ,sum(convert(int,SupervisorObservationHomeVisit)) as SupervisorObservationHomeVisit	
	  ,sum(convert(int,SupervisorObservationAssessment)) as SupervisorObservationAssessment	
	  ,sum(convert(int,ImplementTraining)) as ImplementTraining	
	  ,sum(convert(int,CulturalSensitivity)) as CulturalSensitivity	
	  ,sum(convert(int,Curriculum)) as Curriculum	
	  ,sum(convert(int,TechniquesApproaches)) as TechniquesApproaches	
	  ,sum(convert(int,AreasGrowth)) as AreasGrowth	
	  ,sum(convert(int,Strengths)) as Strengths	
	  ,sum(convert(int,Boundaries)) as Boundaries	
	  ,sum(convert(int,ProfessionalGrowth)) as ProfessionalGrowth	
	  ,sum(convert(int,PersonalGrowth)) as PersonalGrowth	
	  ,sum(convert(int,TrainingNeeds)) as TrainingNeeds	
	  ,sum(convert(int,RolePlaying)) as RolePlaying	
	  ,sum(convert(int,ActivitiesOther)) as ActivitiesOther					
				
			  
			   FROM #tblWeekPeriodsAdjusted wp 		
		--left join #tblWorkers w on 1=1  -- We need to know if supervision event in any week is missing
		left join #tblWorkers w on w.workerpk = wp.workerpk  -- include only those weeks where worker performed supervisions. 
		left join Supervision s on s.WorkerFK = w.WorkerPK and SupervisionDate between StartDate and EndDate
		where SupervisionPK is not null
		and TakePlace = 1
	)
	
	
	,cteSupervisionsThatTookPlacePercActivities
	as
	(
		SELECT 
		NumOfTotalSupervisions		
		,CONVERT(VARCHAR,AssessmentIssues) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(AssessmentIssues AS FLOAT) * 100/ NULLIF(NumOfTotalSupervisions,0), 0), 0))  + '%)' as PercOfAssessmentIssues
		,CONVERT(VARCHAR,IFSP) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(IFSP AS FLOAT) * 100/ NULLIF(NumOfTotalSupervisions,0), 0), 0))  + '%)' as PercOfIFSP
		,CONVERT(VARCHAR,FamilyProgress) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(FamilyProgress AS FLOAT) * 100/ NULLIF(NumOfTotalSupervisions,0), 0), 0))  + '%)' as PercOfFamilyProgress
		,CONVERT(VARCHAR,Tools) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(Tools AS FLOAT) * 100/ NULLIF(NumOfTotalSupervisions,0), 0), 0))  + '%)' as PercOfTools
		,CONVERT(VARCHAR,Referrals) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(Referrals AS FLOAT) * 100/ NULLIF(NumOfTotalSupervisions,0), 0), 0))  + '%)' as PercOfReferrals
		,CONVERT(VARCHAR,CommunityResources) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(CommunityResources AS FLOAT) * 100/ NULLIF(NumOfTotalSupervisions,0), 0), 0))  + '%)' as PercOfCommunityResources
		,CONVERT(VARCHAR,Coaching) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(Coaching AS FLOAT) * 100/ NULLIF(NumOfTotalSupervisions,0), 0), 0))  + '%)' as PercOfCoaching
		,CONVERT(VARCHAR,StrengthBasedApproach) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(StrengthBasedApproach AS FLOAT) * 100/ NULLIF(NumOfTotalSupervisions,0), 0), 0))  + '%)' as PercOfStrengthBasedApproach
		,CONVERT(VARCHAR,LevelChange) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(LevelChange AS FLOAT) * 100/ NULLIF(NumOfTotalSupervisions,0), 0), 0))  + '%)' as PercOfLevelChange
		,CONVERT(VARCHAR,Caseload) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(Caseload AS FLOAT) * 100/ NULLIF(NumOfTotalSupervisions,0), 0), 0))  + '%)' as PercOfCaseload
		,CONVERT(VARCHAR,HomeVisitRate) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(HomeVisitRate AS FLOAT) * 100/ NULLIF(NumOfTotalSupervisions,0), 0), 0))  + '%)' as PercOfHomeVisitRate
		,CONVERT(VARCHAR,AssessmentRate) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(AssessmentRate AS FLOAT) * 100/ NULLIF(NumOfTotalSupervisions,0), 0), 0))  + '%)' as PercOfAssessmentRate
		,CONVERT(VARCHAR,Retention) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(Retention AS FLOAT) * 100/ NULLIF(NumOfTotalSupervisions,0), 0), 0))  + '%)' as PercOfRetention
		,CONVERT(VARCHAR,HomeVisitLogActivities) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(HomeVisitLogActivities AS FLOAT) * 100/ NULLIF(NumOfTotalSupervisions,0), 0), 0))  + '%)' as PercOfHomeVisitLogActivities
		,CONVERT(VARCHAR,RecordDocumentation) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(RecordDocumentation AS FLOAT) * 100/ NULLIF(NumOfTotalSupervisions,0), 0), 0))  + '%)' as PercOfRecordDocumentation
		,CONVERT(VARCHAR,Outreach) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(Outreach AS FLOAT) * 100/ NULLIF(NumOfTotalSupervisions,0), 0), 0))  + '%)' as PercOfOutreach

		,CONVERT(VARCHAR,Safety) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(Safety AS FLOAT) * 100/ NULLIF(NumOfTotalSupervisions,0), 0), 0))  + '%)' as PercOfSafety
		,CONVERT(VARCHAR,SupervisorObservationHomeVisit) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(SupervisorObservationHomeVisit AS FLOAT) * 100/ NULLIF(NumOfTotalSupervisions,0), 0), 0))  + '%)' as PercOfSupervisorObservationHomeVisit
		,CONVERT(VARCHAR,SupervisorObservationAssessment) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(SupervisorObservationAssessment AS FLOAT) * 100/ NULLIF(NumOfTotalSupervisions,0), 0), 0))  + '%)' as PercOfSupervisorObservationAssessment
		,CONVERT(VARCHAR,ImplementTraining) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(ImplementTraining AS FLOAT) * 100/ NULLIF(NumOfTotalSupervisions,0), 0), 0))  + '%)' as PercOfImplementTraining
		,CONVERT(VARCHAR,CulturalSensitivity) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(CulturalSensitivity AS FLOAT) * 100/ NULLIF(NumOfTotalSupervisions,0), 0), 0))  + '%)' as PercOfCulturalSensitivity
		,CONVERT(VARCHAR,Curriculum) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(Curriculum AS FLOAT) * 100/ NULLIF(NumOfTotalSupervisions,0), 0), 0))  + '%)' as PercOfCurriculum
		,CONVERT(VARCHAR,TechniquesApproaches) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(TechniquesApproaches AS FLOAT) * 100/ NULLIF(NumOfTotalSupervisions,0), 0), 0))  + '%)' as PercOfTechniquesApproaches
		,CONVERT(VARCHAR,AreasGrowth) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(AreasGrowth AS FLOAT) * 100/ NULLIF(NumOfTotalSupervisions,0), 0), 0))  + '%)' as PercOfAreasGrowth
		,CONVERT(VARCHAR,Strengths) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(Strengths AS FLOAT) * 100/ NULLIF(NumOfTotalSupervisions,0), 0), 0))  + '%)' as PercOfStrengths
		,CONVERT(VARCHAR,Boundaries) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(Boundaries AS FLOAT) * 100/ NULLIF(NumOfTotalSupervisions,0), 0), 0))  + '%)' as PercOfBoundaries
		,CONVERT(VARCHAR,ProfessionalGrowth) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(ProfessionalGrowth AS FLOAT) * 100/ NULLIF(NumOfTotalSupervisions,0), 0), 0))  + '%)' as PercOfProfessionalGrowth
		,CONVERT(VARCHAR,PersonalGrowth) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(PersonalGrowth AS FLOAT) * 100/ NULLIF(NumOfTotalSupervisions,0), 0), 0))  + '%)' as PercOfPersonalGrowth
		,CONVERT(VARCHAR,TrainingNeeds) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(TrainingNeeds AS FLOAT) * 100/ NULLIF(NumOfTotalSupervisions,0), 0), 0))  + '%)' as PercOfTrainingNeeds
		,CONVERT(VARCHAR,RolePlaying) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(RolePlaying AS FLOAT) * 100/ NULLIF(NumOfTotalSupervisions,0), 0), 0))  + '%)' as PercOfRolePlaying
		,CONVERT(VARCHAR,ActivitiesOther) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(ActivitiesOther AS FLOAT) * 100/ NULLIF(NumOfTotalSupervisions,0), 0), 0))  + '%)' as PercOfActivitiesOther		
		
						
				
			  
		FROM cteSupervisionsThatTookPlaceActivities	

	)	
	
	-- to show list of the other activities
	,cteSupervisionsThatTookPlaceActivitiesOther
	as
	(
				SELECT 

					ActivitiesOtherSpecify 				
				
			  
			   FROM #tblWeekPeriodsAdjusted wp 		
		--left join #tblWorkers w on 1=1  -- We need to know if supervision event in any week is missing
		left join #tblWorkers w on w.workerpk = wp.workerpk  -- include only those weeks where worker performed supervisions. 
		left join Supervision s on s.WorkerFK = w.WorkerPK and SupervisionDate between StartDate and EndDate
		where SupervisionPK is not null
		and TakePlace = 1
		and ActivitiesOther = 1
	)
	
	
	--SELECT * FROM cteSupervisionsThatTookPlaceActivitiesOther
	

,cteReportHeaderStatistics
as
(
SELECT 
		 
		CONVERT(VARCHAR,sum(SupTimeGreaterThan90Mins)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(sum(SupTimeGreaterThan90Mins) AS FLOAT) * 100/ NULLIF(count(*),0), 0), 0))  + '%)' as PerCOfSupGreaterThanEQTo90Mins
		,CONVERT(VARCHAR,count(*) - sum(SupTimeGreaterThan90Mins)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(count(*) - sum(SupTimeGreaterThan90Mins) AS FLOAT) * 100/ NULLIF(count(*),0), 0), 0))  + '%)' as PerCOfSupLessThan90Mins


		--,sum(Duration) / count(*)  as AverageDuration
		,'H:' +CAST(((sum(Duration) / count(*)) / 60) AS VARCHAR(8)) + '   M:' + RIGHT('0' + CAST(((sum(Duration) / count(*)) % 60) AS VARCHAR(2)), 2) as AverageLenOfSupervision
		

 FROM cteSupervisionsThatTookPlace s
)

 --SELECT * FROM cteReportHeaderStatistics, cteSupervisionsThatTookPlacePercActivities
--SELECT * FROM cteSupervisionsThatTookPlacePercActivities


-- rspCredentialingSupervisionActivitiesSummary 1, '06/01/2013', '08/31/2013'

	
-- Part 2: Supervision sessions that did not take place with a reason	
	
	-- Supervision sessions that did not take place with a reason
	,cteSupervisionsThatDidNotTakePlace
	as
	(
				SELECT 
		
				 wp.WeekNumber
				,wp.StartDate
				,wp.EndDate		
				,wp.FirstEvent
				,wp.WorkerPK	
					
				,isnull(SupervisionHours * 60,0) + isnull(SupervisionMinutes,0) as Duration
				,case when (isnull(SupervisionHours * 60,0) + isnull(SupervisionMinutes,0)) >= 90 then 1
				else 0 end as SupTimeGreaterThan90Mins
								
			 , WorkerName
			 , LastName
			 , FirstName
			 , TerminationDate
			 --, WorkerPK
			 , SortOrder
			
			 , WorkerFKFn
			 , WrkrLName
			 , FAWInitialStart
			 , SupervisorInitialStart 
			 , FSWInitialStart 
			 , TerminationDateFn 
			 , HireDate 
			 , SupervisorFirstEvent 
			 , FirstASQDate 
			 , FirstHomeVisitDate 
			 , FirstKempeDate 
			 --, FirstEvent			
				
				
				
				
		
			  ,SupervisionPK
			  ,ActivitiesOther
			  ,ActivitiesOtherSpecify
			  ,AreasGrowth
			  ,AssessmentIssues
			  ,AssessmentRate
			  ,Boundaries
			  ,Caseload
			  ,Coaching
			  ,CommunityResources
			  ,CulturalSensitivity
			  ,Curriculum
			  ,FamilyProgress
			  ,HomeVisitLogActivities
			  ,HomeVisitRate
			  ,IFSP
			  ,ImplementTraining
			  ,LevelChange
			  ,Outreach
			  ,ParticipantEmergency
			  ,PersonalGrowth
			  ,ProfessionalGrowth
			  ,ReasonOther
			  ,ReasonOtherSpecify
			  --,RecordDocumentation
			  ,Referrals
			  ,Retention
			  ,RolePlaying
			  ,Safety
			  ,ShortWeek
			  ,StaffCourt
			  ,StaffFamilyEmergency
			  ,StaffForgot
			  ,StaffIll
			  ,StaffTraining
			  ,StaffVacation
			  ,StaffOutAllWeek
			  ,StrengthBasedApproach
			  ,Strengths
			  ,SupervisionCreateDate
			  ,SupervisionCreator
			  ,SupervisionDate
			  ,SupervisionEditDate
			  ,SupervisionEditor
			  ,SupervisionEndTime
			  ,SupervisionHours
			  ,SupervisionMinutes
			  ,SupervisionNotes
			  ,SupervisionStartTime
			  ,SupervisorFamilyEmergency
			  --,SupervisorFK
			  ,SupervisorForgot
			  ,SupervisorHoliday
			  ,SupervisorIll
			  ,SupervisorObservationAssessment
			  ,SupervisorObservationHomeVisit
			  ,SupervisorTraining
			  ,SupervisorVacation
			  ,TakePlace
			  ,TechniquesApproaches
			  ,Tools
			  ,TrainingNeeds
			  ,Weather
			  ,WorkerFK	
			-- note: we added 1 in datediff(d, StartDate,EndDate) because substraction gives one day less. e.g. 7-1 = 6			
			, datediff(d, StartDate,EndDate) + 1 as DaysInTheCurrentWeek	-- null means that there was no supervision record found for that week  ... khalsa		  
			--,case when WorkerFK is null and SupervisionPK is null then null else datediff(d, StartDate,EndDate) end as DaysInTheCurrentWeek	-- null means that there was no supervision record found for that week  ... khalsa		  
			  
			   FROM #tblWeekPeriodsAdjusted wp 		
		--left join #tblWorkers w on 1=1  -- We need to know if supervision event in any week is missing
		left join #tblWorkers w on w.workerpk = wp.workerpk  -- include only those weeks where worker performed supervisions. 
		left join Supervision s on s.WorkerFK = w.WorkerPK and SupervisionDate between StartDate and EndDate
		where SupervisionPK is not null
		and TakePlace = 0
	)		



	-- Supervision sessions that took place
	,cteSupervisionsThatDidNotTakePlaceWithReason
	as
	(
				SELECT 

		count(*) as NumOfTotalSupervisionsNotTookPlace
		
				
						
		,sum(convert(int,ParticipantEmergency)) as ParticipantEmergency				
		,sum(convert(int,ShortWeek)) as ShortWeek
		,sum(convert(int,StaffCourt)) as StaffCourt
		,sum(convert(int,StaffFamilyEmergency)) as StaffFamilyEmergency
		,sum(convert(int,StaffForgot)) as StaffForgot
		,sum(convert(int,StaffIll)) as StaffIll
		,sum(convert(int,StaffTraining)) as StaffTraining
		,sum(convert(int,StaffVacation)) as StaffVacation
		,sum(convert(int,StaffOutAllWeek)) as StaffOutAllWeek
		,sum(convert(int,SupervisorFamilyEmergency)) as SupervisorFamilyEmergency
		,sum(convert(int,SupervisorForgot)) as SupervisorForgot
		,sum(convert(int,SupervisorHoliday)) as SupervisorHoliday
		,sum(convert(int,SupervisorIll)) as SupervisorIll
		,sum(convert(int,SupervisorTraining)) as SupervisorTraining
		,sum(convert(int,SupervisorVacation)) as SupervisorVacation
		,sum(convert(int,ReasonOther  )) as ReasonOther
		,sum(convert(int,Weather)) as Weather				
						
			  
			   FROM #tblWeekPeriodsAdjusted wp 		
		--left join #tblWorkers w on 1=1  -- We need to know if supervision event in any week is missing
		left join #tblWorkers w on w.workerpk = wp.workerpk  -- include only those weeks where worker performed supervisions. 
		left join Supervision s on s.WorkerFK = w.WorkerPK and SupervisionDate between StartDate and EndDate
		where SupervisionPK is not null
		and TakePlace = 0
	)
	
	
	,cteSupervisionsThatDidNotTakePlacePercActivities
	as
	(
		SELECT 
		NumOfTotalSupervisionsNotTookPlace	as OtherNumOfTotalSupervisionsNotTookPlace	
			,CONVERT(VARCHAR,ParticipantEmergency) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(ParticipantEmergency AS FLOAT) * 100/ NULLIF(NumOfTotalSupervisionsNotTookPlace,0), 0), 0))  + '%)' as OtherPercOfParticipantEmergency
			,CONVERT(VARCHAR,ShortWeek) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(ShortWeek AS FLOAT) * 100/ NULLIF(NumOfTotalSupervisionsNotTookPlace,0), 0), 0))  + '%)' as OtherPercOfShortWeek
			,CONVERT(VARCHAR,StaffCourt) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(StaffCourt AS FLOAT) * 100/ NULLIF(NumOfTotalSupervisionsNotTookPlace,0), 0), 0))  + '%)' as OtherPercOfStaffCourt
			,CONVERT(VARCHAR,StaffFamilyEmergency) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(StaffFamilyEmergency AS FLOAT) * 100/ NULLIF(NumOfTotalSupervisionsNotTookPlace,0), 0), 0))  + '%)' as OtherPercOfStaffFamilyEmergency
			,CONVERT(VARCHAR,StaffForgot) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(StaffForgot AS FLOAT) * 100/ NULLIF(NumOfTotalSupervisionsNotTookPlace,0), 0), 0))  + '%)' as OtherPercOfStaffForgot
			,CONVERT(VARCHAR,StaffIll) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(StaffIll AS FLOAT) * 100/ NULLIF(NumOfTotalSupervisionsNotTookPlace,0), 0), 0))  + '%)' as OtherPercOfStaffIll
			,CONVERT(VARCHAR,StaffTraining) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(StaffTraining AS FLOAT) * 100/ NULLIF(NumOfTotalSupervisionsNotTookPlace,0), 0), 0))  + '%)' as OtherPercOfStaffTraining
			,CONVERT(VARCHAR,StaffVacation) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(StaffVacation AS FLOAT) * 100/ NULLIF(NumOfTotalSupervisionsNotTookPlace,0), 0), 0))  + '%)' as OtherPercOfStaffVacation
			,CONVERT(VARCHAR,StaffOutAllWeek) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(StaffOutAllWeek AS FLOAT) * 100/ NULLIF(NumOfTotalSupervisionsNotTookPlace,0), 0), 0))  + '%)' as OtherPercOfStaffOutAllWeek
			,CONVERT(VARCHAR,SupervisorFamilyEmergency) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(SupervisorFamilyEmergency AS FLOAT) * 100/ NULLIF(NumOfTotalSupervisionsNotTookPlace,0), 0), 0))  + '%)' as OtherPercOfSupervisorFamilyEmergency
			,CONVERT(VARCHAR,SupervisorForgot) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(SupervisorForgot AS FLOAT) * 100/ NULLIF(NumOfTotalSupervisionsNotTookPlace,0), 0), 0))  + '%)' as OtherPercOfSupervisorForgot
			,CONVERT(VARCHAR,SupervisorHoliday) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(SupervisorHoliday AS FLOAT) * 100/ NULLIF(NumOfTotalSupervisionsNotTookPlace,0), 0), 0))  + '%)' as OtherPercOfSupervisorHoliday
			,CONVERT(VARCHAR,SupervisorIll) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(SupervisorIll AS FLOAT) * 100/ NULLIF(NumOfTotalSupervisionsNotTookPlace,0), 0), 0))  + '%)' as OtherPercOfSupervisorIll
			,CONVERT(VARCHAR,SupervisorTraining) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(SupervisorTraining AS FLOAT) * 100/ NULLIF(NumOfTotalSupervisionsNotTookPlace,0), 0), 0))  + '%)' as OtherPercOfSupervisorTraining
			,CONVERT(VARCHAR,SupervisorVacation) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(SupervisorVacation AS FLOAT) * 100/ NULLIF(NumOfTotalSupervisionsNotTookPlace,0), 0), 0))  + '%)' as OtherPercOfSupervisorVacation
			,CONVERT(VARCHAR,ReasonOther) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(ReasonOther AS FLOAT) * 100/ NULLIF(NumOfTotalSupervisionsNotTookPlace,0), 0), 0))  + '%)' as OtherPercOfReasonOther
			,CONVERT(VARCHAR,Weather) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(Weather AS FLOAT) * 100/ NULLIF(NumOfTotalSupervisionsNotTookPlace,0), 0), 0))  + '%)' as OtherPercOfWeather	
									
							
			  
		FROM cteSupervisionsThatDidNotTakePlaceWithReason	

	)	
	

	-- to show list of the other reasons
	,cteSupervisionsThatDidNotTakePlaceWithReasonOther
	as
	(
				SELECT 

					ReasonOtherSpecify			
				
			  
			   FROM #tblWeekPeriodsAdjusted wp 		
		--left join #tblWorkers w on 1=1  -- We need to know if supervision event in any week is missing
		left join #tblWorkers w on w.workerpk = wp.workerpk  -- include only those weeks where worker performed supervisions. 
		left join Supervision s on s.WorkerFK = w.WorkerPK and SupervisionDate between StartDate and EndDate
		where SupervisionPK is not null
		and TakePlace = 0
		and ReasonOther = 1
	)
	
	
	--SELECT * FROM cteSupervisionsThatDidNotTakePlaceWithReasonOther


----SELECT * FROM cteSupervisionsThatDidNotTakePlacePercActivities
----SELECT workerpk FROM #tblSUPPMWorkers


SELECT * FROM cteReportHeaderStatistics, cteSupervisionsThatTookPlacePercActivities, cteSupervisionsThatDidNotTakePlacePercActivities, #tblWorkerAndSupName
--left join cteSupervisionsThatTookPlaceActivitiesOther ss on 1=1

--SELECT * FROM cteSupervisionsThatDidNotTakePlacePercActivities

--ToDo: Also print out the other activities and reasons ... Khalsa

---- rspCredentialingSupervisionActivitiesSummary 1, '06/01/2013', '08/31/2013',15,null,null
---- rspCredentialingSupervisionActivitiesSummary 31, '06/01/2013', '08/31/2013'

---- rspCredentialingSupervisionActivitiesSummary 1, '10/01/2013', '12/31/2013',null,152,null,2


	drop table #tblFAWFSWWorkers
	--drop table #tblSUPPMWorkers
	drop table #tblWorkers
	drop table #tblWeekPeriods
	drop table #tblWorkerAndSupName
GO
