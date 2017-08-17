SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 11/15/2013
-- Description:	Training Tickler
-- EXEC rspTrainingTickler @progfk = 1, @workerfk = 54, @supervisorfk = 0
-- exec dbo.rspTrainingTickler @progfk=1,@workerfk=85,@supervisorfk=0
-- Edited by: Chris Papas
-- Edit Date: 3-13-2017
-- Edit Reason: Codetopic 12.1 'Stop Gap for Supervisors' was appearing for non-Supervisors
-- Edited by: Benjamin Simmons
-- Edit Date: 08-15-2017
-- Edit Reason: Report was running slowly on Azure.  (Removed unnecessary CTEs and implemented a temp table)
-- =============================================
CREATE PROCEDURE [dbo].[rspTrainingTickler]
	-- Add the parameters for the stored procedure here
	@progfk AS INT,
	@workerfk AS INT,
	@supervisorfk AS int
AS
begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

IF @supervisorfk = 0 SET @supervisorfk = NULL
IF @workerfk = 0 SET @workerfk = NULL

if object_id('tempdb..#cteEverythingRequired') is not null drop table #cteEverythingRequired
create table #cteEverythingRequired (
			workerpk int
			, wrkrLName char(30)
			, WorkerName char(60)
			, hiredate datetime
			, FirstKempeDate datetime
			, FirstHomeVisitDate datetime
			, SupervisorFirstEvent datetime
			, FirstEvent datetime
			, FirstASQDate datetime
			, SupervisorInitialStart datetime
			, FAWInitialStart datetime
			, FSWInitialStart datetime
			, TerminationDate datetime
			, SupervisorFK int
			, TopicFK int
			, TopicName char(150)
			, TopicCode numeric(4, 1)
			, SATCompareDateField nvarchar(50)
			, SATInterval nvarchar(50)
			, satname nvarchar(10)
			, DaysAfter int
			, SubTopicCode char(1)
			, SubTopicName char(100)
			, SubTopicPK int
			, TrainingTickler nchar(3)
)

; WITH cteTopicList AS (
SELECT DISTINCT codeTopicPK as TopicFK, TopicName, TopicCode, SATCompareDateField
, SATInterval, satname, DaysAfter
, null as SubTopicCode , null as SubTopicName, null as TrainingTickler, null as SubTopicPK
FROM dbo.codeTopic 
WHERE (topiccode <=25.0) OR (TopicCode=39.0) OR (TopicCode=40.0) OR (TopicCode=41.0) OR (TopicCode=42.0) OR (TopicCode=43.0)
)


, cteSubtopicList AS(
SELECT TopicFK 
, TopicName, TopicCode, SATCompareDateField, SATInterval, satname, DaysAfter
, SubTopicCode, SubTopicName, TrainingTickler, SubTopicPK 
FROM dbo.SubTopic 
inner join codeTopic t on t.codeTopicPK = SubTopic.TopicFK
WHERE TrainingTickler='YES'
)

, cteCompleteTopicList AS(
	SELECT * FROM cteTopicList 
	UNION
	select * from cteSubtopicList 
)


, cteEventDates AS (
	SELECT workerpk, wrkrLName
	, rtrim(wrkrFname) + ' ' + rtrim(wrkrLName) as WorkerName, hiredate
	, FirstKempeDate, FirstHomeVisitDate, SupervisorFirstEvent
	, SupervisorInitialStart, FAWInitialStart, FSWInitialStart --these are NOT Intitial Start Dates, the function was modified but the name stayed the same
	, FirstASQDate
	, FirstPSIDate
	, TerminationDate
	FROM [dbo].[fnGetWorkerEventDatesAll](@progfk, NULL, NULL)
	WHERE (TerminationDate IS NULL OR TerminationDate >=
		CASE @workerfk
			WHEN NULL THEN GETDATE()
			ELSE 0
		END
		)
)


, cteWorkerList AS (
	SELECT workerpk, wrkrLName
	, WorkerName, cteEventDates.hiredate
	, FirstKempeDate, FirstHomeVisitDate, SupervisorFirstEvent, FirstASQDate
	--Need to find the workers FIRST Event (coalesce is required to deal with NULL date values)
	, CASE WHEN FirstKempeDate < COALESCE(FirstHomeVisitDate, DATEADD(dd, 1, FirstKempeDate)) AND FirstKempeDate < COALESCE(SupervisorFirstEvent, DATEADD(dd, 1, FirstKempeDate)) THEN FirstKempeDate
		   WHEN FirstHomeVisitDate < COALESCE(SupervisorFirstEvent, DATEADD(dd, 1, FirstHomeVisitDate)) THEN FirstHomeVisitDate
		ELSE SupervisorFirstEvent
		END AS FirstEvent
	, SupervisorInitialStart, FAWInitialStart, FSWInitialStart
	, cteEventDates.TerminationDate
	, SupervisorFK
	FROM cteEventDates 
	INNER JOIN workerprogram wp ON wp.WorkerFK = cteEventDates.workerpk AND wp.ProgramFK = @progfk
	WHERE CASE when @workerfk IS NULL AND cteEventDates.TerminationDate IS NULL then 1
			   when workerpk=@workerfk then 1
			   else 0 
			   end = 1
		AND supervisorfk = isnull(@supervisorfk,supervisorfk)
)


insert into #cteEverythingRequired
		SELECT workerpk, wrkrLName
			, WorkerName
			, hiredate
			, FirstKempeDate
			, FirstHomeVisitDate
			, SupervisorFirstEvent
			, FirstEvent
			, FirstASQDate
			, SupervisorInitialStart
			, FAWInitialStart
			, FSWInitialStart
			, TerminationDate
			, SupervisorFK
			, TopicFK
			, TopicName
			, TopicCode
			, SATCompareDateField
			, SATInterval
			, satname, DaysAfter
			, SubTopicCode
			, SubTopicName
			, SubTopicPK
			, TrainingTickler
		FROM cteWorkerList, cteCompleteTopicList 
		WHERE CASE WHEN FAWInitialStart IS NULL AND TopicCode = '9.0' THEN 0 -- Remove topic code 9 if not an FAW
			  WHEN FSWInitialStart IS NULL AND TopicCode = '8.0' THEN 0 -- Remove topic code 8 if not an FSW
			  WHEN SupervisorInitialStart IS NULL AND (TopicCode = '9.1' or TopicCode = '12.1') THEN 0 --Remove if worker is not a Supervisor
			ELSE 1
			END = 1

	
		
; with cteReadyForRemoval AS (
		SELECT DISTINCT workerpk, wrkrLName
			, WorkerName
			, hiredate
			, FirstKempeDate
			, FirstHomeVisitDate
			, SupervisorFirstEvent
			, FirstEvent
			, FirstASQDate
			, SupervisorInitialStart
			, FAWInitialStart
			, FSWInitialStart
			, TerminationDate
			, SupervisorFK
			, TopicName
			, TopicCode
			, SATCompareDateField
			, SATInterval
			, satname, DaysAfter
			, ER.TopicFK
			, SubTopicCode
			, SubTopicName
			, SubTopicPK
			, TrainingTickler
			, (SELECT MIN(TrainingDate) FROM dbo.Training
					INNER JOIN TrainingAttendee ta ON dbo.Training.TrainingPK = ta.TrainingFK
					INNER JOIN TrainingDetail td ON ta.TrainingFK = td.TrainingFK
					WHERE TopicFK = er.TopicFK AND ta.WorkerFK=er.workerpk
								AND (case when er.SubTopicPK IS NULL then 1
								when td.SubTopicFK = ER.SubTopicPK then 1
								else 0 end = 1)
						
					) AS TrainingDate
			--, t.TrainingDate
		FROM #cteEverythingRequired ER
		)
		
	
, cteRemovals AS(		
	SELECT workerpk
			, CASE 
				WHEN [TopicCode] = '14.0' AND [SubTopicCode] IS NULL THEN NULL
				WHEN [TopicCode] = '15.0' AND [SubTopicCode] IS NULL THEN NULL
				WHEN [TopicCode] = '16.0' AND [SubTopicCode] IS NULL THEN NULL
				WHEN [TopicCode] = '17.0' AND [SubTopicCode] IS NULL THEN NULL
				WHEN [TopicCode] = '19.0' AND [SubTopicCode] IS NULL THEN NULL
				WHEN [TopicCode] = '23.0' AND [SubTopicCode] IS NULL THEN NULL
				WHEN [TopicCode] = '25.0' AND [SubTopicCode] IS NULL THEN NULL
				WHEN [TopicCode] = '18.0' AND [SubTopicCode] IS NULL THEN NULL
				WHEN [TopicCode] = '20.0' AND [SubTopicCode] IS NULL THEN NULL
				WHEN [TopicCode] = '21.0' AND [SubTopicCode] IS NULL THEN NULL
				WHEN [TopicCode] = '24.0' AND [SubTopicCode] IS NULL THEN NULL
				ELSE
				WorkerName
				END AS WorkerName
			, hiredate
			, FirstKempeDate
			, FirstHomeVisitDate
			, SupervisorFirstEvent
			, FirstEvent
			, FirstASQDate
			, SupervisorInitialStart
			, FAWInitialStart
			, FSWInitialStart
			, TerminationDate
			, SupervisorFK
			, TopicName
			, TopicCode
			, SATCompareDateField
			, SATInterval
			, CASE 
				WHEN [TopicCode] = '14.0' AND [SubTopicCode] IS NULL THEN NULL
				WHEN [TopicCode] = '15.0' AND [SubTopicCode] IS NULL THEN NULL
				WHEN [TopicCode] = '16.0' AND [SubTopicCode] IS NULL THEN NULL
				WHEN [TopicCode] = '17.0' AND [SubTopicCode] IS NULL THEN NULL
				WHEN [TopicCode] = '19.0' AND [SubTopicCode] IS NULL THEN NULL
				WHEN [TopicCode] = '23.0' AND [SubTopicCode] IS NULL THEN NULL
				WHEN [TopicCode] = '25.0' AND [SubTopicCode] IS NULL THEN NULL
				WHEN [TopicCode] = '18.0' AND [SubTopicCode] IS NULL THEN NULL
				WHEN [TopicCode] = '20.0' AND [SubTopicCode] IS NULL THEN NULL
				WHEN [TopicCode] = '21.0' AND [SubTopicCode] IS NULL THEN NULL
				WHEN [TopicCode] = '24.0' AND [SubTopicCode] IS NULL THEN NULL
				ELSE satname
				END AS satname
			, DaysAfter
			, TopicFK
			, SubTopicCode
			, SubTopicName
			, SubTopicPK
			, TrainingTickler
			, TrainingDate
			--, (SELECT TrainingDate FROM cteReadyForRemoval WHERE Topicfk = 10 AND workerpk=2124) AS testdate
			, CASE WHEN TopicCode<6.0 THEN '      Orientation (Prior to direct work with Families)'
				WHEN TopicCode<10.0 THEN '    Other HFA and State Requirements'
				WHEN TopicCode=13.0 THEN '    Other HFA and State Requirements'
				WHEN TopicCode=39.0 THEN '    Other HFA and State Requirements'
				WHEN TopicCode=40.0 THEN '    Other HFA and State Requirements'
				WHEN TopicCode=41.0 THEN '    Other HFA and State Requirements'
				WHEN TopicCode=43.0 THEN '    Other HFA and State Requirements'
				WHEN TopicCode<13.0 THEN '     Intensive Role Specific Training'
				WHEN TopicCode<17.0 THEN '   Wraparound Trainings by 3 months of hire'
				WHEN TopicCode=17.0 THEN '  Wraparound Trainings by 6 months of hire'
				WHEN TopicCode=19.0 THEN '  Wraparound Trainings by 6 months of hire'
				WHEN TopicCode=23.0 THEN '  Wraparound Trainings by 6 months of hire'
				WHEN TopicCode=25.0 THEN '  Wraparound Trainings by 6 months of hire'
				Else ' Wraparound Trainings by 12 months of hire'
				END AS [theGrouping]
			, CASE  
					--HW997 Training Tickler and Required Topics - Remove Subtopic 82
					--WHEN SubTopicPK = 82 then
					----this first case determines if the initial FAW Core Training is taken, if not then it will simply add the text the training is due 3 months after, otherwise, it adds the 91 days
					--	CASE WHEN (SELECT distinct min(TrainingDate) FROM cteReadyForRemoval WHERE rfr.TopicFK = 10 AND workerpk=rfr.workerpk) IS NULL THEN 'FAW 3 month Follow-up Assessment Review'
					--	ELSE CONVERT(VARCHAR(10)
					--	, DATEADD(dd, 91, (select min(TrainingDate) FROM cteReadyForRemoval WHERE Topicfk = 10 AND workerpk=rfr.workerpk)), 101)
					--	END
					--END HW997
					WHEN [TopicCode] = '14.0' AND [SubTopicCode] IS NULL THEN NULL
					WHEN [TopicCode] = '15.0' AND [SubTopicCode] IS NULL THEN NULL
					WHEN [TopicCode] = '16.0' AND [SubTopicCode] IS NULL THEN NULL
					WHEN [TopicCode] = '17.0' AND [SubTopicCode] IS NULL THEN NULL
					WHEN [TopicCode] = '19.0' AND [SubTopicCode] IS NULL THEN NULL
					WHEN [TopicCode] = '23.0' AND [SubTopicCode] IS NULL THEN NULL
					WHEN [TopicCode] = '25.0' AND [SubTopicCode] IS NULL THEN NULL
					WHEN [TopicCode] = '18.0' AND [SubTopicCode] IS NULL THEN NULL
					WHEN [TopicCode] = '20.0' AND [SubTopicCode] IS NULL THEN NULL
					WHEN [TopicCode] = '21.0' AND [SubTopicCode] IS NULL THEN NULL
					WHEN [TopicCode] = '24.0' AND [SubTopicCode] IS NULL THEN NULL
					WHEN SATCompareDateField = 'firstevent' THEN
						CASE WHEN FirstEvent IS NULL THEN 'First Event'
						ELSE CONVERT(VARCHAR(10), DATEADD(dd, daysafter, FirstEvent), 101)
						END
					WHEN SATCompareDateField = 'firstASQ' THEN
						CASE WHEN FirstASQDate IS NULL THEN 'First ASQ'
						ELSE CONVERT(VARCHAR(10), DATEADD(dd, daysafter, FirstASQDate), 101)
						END
					WHEN SATCompareDateField = 'date_hired' THEN
						CONVERT(VARCHAR(10), DATEADD(dd, daysafter, hiredate), 101)
					WHEN SATCompareDateField = 'faworig' THEN
						CASE WHEN FAWInitialStart IS NULL THEN 'FAW Start'
						ELSE CONVERT(VARCHAR(10), DATEADD(dd, daysafter, FAWInitialStart), 101)
						END
					WHEN SATCompareDateField = 'fsworig' THEN
						CASE WHEN FSWInitialStart IS NULL THEN 'FSW Start'
						ELSE CONVERT(VARCHAR(10), DATEADD(dd, daysafter, FSWInitialStart), 101)
						END
					WHEN SATCompareDateField = 'suporig' THEN
						CASE WHEN SupervisorInitialStart IS NULL THEN 'Supervisor Start'
						ELSE CONVERT(VARCHAR(10), DATEADD(dd, daysafter, SupervisorInitialStart), 101)
						END
					WHEN SATCompareDateField = 'firstPHQ9' THEN 'First PHQ'
					WHEN SATCompareDateField = 'firstPSI' THEN 'First PSI'
			  END AS [DateDue]
			, CASE  
					WHEN SATCompareDateField = 'firstevent' THEN
						CASE WHEN TrainingDate IS NOT NULL THEN 'Remove' 
						WHEN hiredate < '07/01/2014' AND topiccode = '5.5' THEN 'Remove' 
						END
					WHEN SATCompareDateField = 'firstASQ' THEN
						CASE WHEN TrainingDate IS NOT NULL THEN 'Remove' END
					WHEN SATCompareDateField = 'date_hired' THEN
						CASE WHEN TrainingDate IS NOT NULL THEN 'Remove' END
					WHEN SATCompareDateField = 'faworig' THEN
						CASE WHEN FAWInitialStart IS NULL THEN 'Remove'
						WHEN TrainingDate IS NOT NULL THEN 'Remove' END
					WHEN SATCompareDateField = 'fsworig' THEN
						CASE WHEN FSWInitialStart IS NULL THEN 'Remove'
						WHEN TrainingDate IS NOT NULL THEN 'Remove' END
					WHEN SATCompareDateField = 'suporig' THEN
						CASE WHEN SupervisorInitialStart IS NULL THEN 'Remove'
						WHEN TrainingDate IS NOT NULL THEN 'Remove' END
					WHEN SATCompareDateField = 'firstPHQ9' THEN
						CASE WHEN TrainingDate IS NOT NULL THEN 'Remove' END
					WHEN SATCompareDateField = 'firstPSI' THEN
						CASE WHEN TrainingDate IS NOT NULL THEN 'Remove' END
			  END AS 'Removals'
			FROM cteReadyForRemoval rfr
			)


, cteFinal AS (		
SELECT workerpk
			, WorkerName
			, hiredate
			, FirstKempeDate
			, FirstHomeVisitDate
			, SupervisorInitialStart
			, FAWInitialStart
			, FSWInitialStart
			, TopicName
			, TopicCode
			, SubTopicCode
			, satname AS CSST
			, SubTopicName
			, TrainingDate
			, [theGrouping] AS [Grouping]
			, [DateDue]	
			, CASE WHEN TopicCode = '7.1' then
				case when cteRemovals.TrainingDate is null then
						CASE WHEN (SELECT top 1 Removals FROM cteRemovals WHERE TopicCode='7.0' AND workerpk = cteRemovals.WorkerPK) IS not null THEN 'Remove' --If they have 7.0 they don't need 7.1 (7.1 is just a stop gap)
						end
				else [cteRemovals].[Removals] END
			WHEN TopicCode = '7.0' then
				case when cteRemovals.TrainingDate is null then
					case WHEN (SELECT top 1 Removals FROM cteRemovals WHERE TopicCode='7.1' AND workerpk = cteRemovals.WorkerPK) IS not null THEN 'Remove' --If they have 7.0 they don't need 7.1 (7.1 is just a stop gap)
				END
				else [cteRemovals].[Removals] end
			WHEN TopicCode = '41.0' then 
				case when cteRemovals.TrainingDate is null then
					case WHEN (SELECT top 1 Removals FROM cteRemovals WHERE TopicCode='40.0' AND workerpk = cteRemovals.WorkerPK) IS not null THEN 'Remove' --If they have 40.0 they don't need 41 (41 is just a stop gap)
				END
				else [cteRemovals].[Removals] end
			WHEN TopicCode = '12.1' then 
				case when cteRemovals.TrainingDate is null then
					case WHEN (SELECT top 1 Removals FROM cteRemovals WHERE TopicCode='12.0' AND workerpk = cteRemovals.WorkerPK) IS not null THEN 'Remove' --If they have 12.0 they don't need 12.1 (12.1 is just a stop gap)
				END
				else [cteRemovals].[Removals] end
			
			  ELSE [Removals]
			  END AS 'Removals'
FROM cteRemovals)

SELECT workerpk 
			, WorkerName
			, hiredate
			, FirstKempeDate
			, FirstHomeVisitDate
			, SupervisorInitialStart
			, FAWInitialStart
			, FSWInitialStart
			, TopicName
			, TopicCode
			, SubTopicCode
			, CSST
			, SubTopicName
			, TrainingDate
			, [Grouping]
			, [DateDue]	
FROM cteFinal
WHERE TopicCode <> '98' and Removals IS NULL
ORDER BY Workerpk, TopicCode, SubTopicCode

drop table #cteEverythingRequired

END
GO
