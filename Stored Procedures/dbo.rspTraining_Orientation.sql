SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 05/03/2013
-- Description:	Training [NYS 3 IFSP] New York State Required Trainings
-- EXEC rspTraining_10_2_Orientation @progfk = 30, @sdate = '07/01/2008'
-- Edit date: 10/11/2013 CP - workerprogram was duplicating cases when worker transferred
-- Edit date: 10/11/2013 CP - the bit values in workerprogram table (FSW, FAW, Supervisor, FatherAdvocate, Program Manager)
--				are no longer being populated based on the latest workerform changes by Dar, so I've modified this report.
-- =============================================
CREATE PROCEDURE [dbo].[rspTraining_Orientation]
	-- Add the parameters for the stored procedure here
	@progfk AS INT,
	@sdate AS DATE
	
	WITH RECOMPILE
AS


BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

;WITH  cteMain AS (
	SELECT g.WorkerPK, g.WrkrLName, g.FirstHomeVisitDate
	, g.FirstKempeDate, g.SupervisorFirstEvent
	, g.FirstEvent
		, RTRIM(w.FirstName) + ' ' + RTRIM(w.LastName) AS WorkerName
		, case when wp.SupervisorStartDate is not null then 1 end as Supervisor
		, case when wp.FSWStartDate is not null then 1 end as FSW
		, case when wp.FAWStartDate is not null then 1 end as FAW
		, ROW_NUMBER() OVER(ORDER BY g.workerpk DESC) AS 'RowNumber'
	FROM dbo.fnGetWorkerEventDatesALL(@progfk, NULL, NULL) g
	INNER JOIN Worker w ON w.WorkerPK = g.WorkerPK
	INNER JOIN WorkerProgram wp ON g.WorkerPK = wp.WorkerFK AND wp.ProgramFK=@progfk
	WHERE g.FirstEvent > @sdate
	AND ((wp.FAWStartDate > @sdate AND wp.FAWEndDate IS NULL)
	OR (wp.FSWStartDate > @sdate AND wp.FSWEndDate IS NULL)
	OR (wp.SupervisorStartDate  > @sdate AND wp.SupervisorEndDate IS NULL))
	AND wp.TerminationDate IS NULL
	AND wp.HireDate > @sdate
)

 
--Now we get the trainings (or lack thereof) for topic code 1.0
, cte10_2a AS (
	SELECT RowNumber
		, cteMain.workerpk
		, t1.TopicCode
		, t1.topicname
		, MIN(t.TrainingDate) AS TrainingDate
		, FirstHomeVisitDate
		, FirstKempeDate
		, SupervisorFirstEvent
		, FirstEvent
		, WorkerName
		, Supervisor
		, FSW
		, FAW
	FROM cteMain
			LEFT JOIN TrainingAttendee ta ON ta.WorkerFK = cteMain.WorkerPK
			LEFT JOIN Training t ON t.TrainingPK = ta.TrainingFK
			LEFT JOIN TrainingDetail td ON td.TrainingFK = t.TrainingPK
			RIGHT JOIN codeTopic t1 ON td.TopicFK=t1.codeTopicPK
	WHERE (t1.TopicCode BETWEEN 1.0 AND 5.5)
	GROUP BY WorkerPK, WrkrLName, FirstHomeVisitDate
	, FirstKempeDate, SupervisorFirstEvent, FirstEvent
			, t1.TopicCode
			, t1.topicname
			, WorkerName
			, Supervisor
			, FSW
			, FAW
			, rownumber
)



, cteAddMissingWorkers_cte10_2a AS (
	--if a worker has NO trainings, they won't appear at all, so add them back
	SELECT WorkerPK
	, codeTopic.TopicCode
	, WorkerName
	, Supervisor
	, FSW
	, FAW
	, FirstEvent
	, FirstHomeVisitDate
	, FirstKempeDate
	, SupervisorFirstEvent
	FROM cteMain, codetopic
	WHERE (codetopic.TopicCode BETWEEN 1.0 AND 5.5)
)


--Now we get the trainings (or lack thereof) for topic code 2.0
, cte10_2b AS (

	--if a worker has NO trainings, they won't appear at all, so add them back

	SELECT case when RowNumber is null then 1 else RowNumber end as RowNumber
		, b.TopicCode
		, b.WorkerPK
		, t.topicname
		, TrainingDate
		, b.FirstHomeVisitDate
		, b.FirstKempeDate
		, b.SupervisorFirstEvent
		, b.FirstEvent
		, b.WorkerName
		, b.Supervisor
		, b.FSW
		, b.FAW
	FROM cte10_2a t
	RIGHT JOIN cteAddMissingWorkers_cte10_2a b
	ON b.WorkerPK = t.WorkerPK
	AND b.TopicCode = t.TopicCode


)

--Now we get the trainings (or lack thereof) for topic code 23 (Staff Related Issues)
, cte10_23 AS (
	--if a worker has NO trainings, they won't appear at all, so add them back
	SELECT case when RowNumber is null then 1 else RowNumber end as RowNumber
		, b.TopicCode
		, b.WorkerPK
		, t.topicname
		, TrainingDate
		, b.FirstHomeVisitDate
		, b.FirstKempeDate
		, b.SupervisorFirstEvent
		, b.FirstEvent
		, b.WorkerName
		, b.Supervisor
		, b.FSW
		, b.FAW
	FROM cte10_2a t
	RIGHT JOIN cteAddMissingWorkers_cte10_2a b
	ON b.WorkerPK = t.WorkerPK
	AND b.TopicCode = t.TopicCode


)


, cteMeetTarget1 AS (
	SELECT RowNumber
	, cte10_2b.WorkerPK
	, WorkerName
	, Supervisor
	, FSW
	, FAW
	, TopicCode
	, TopicName
	, TrainingDate
	, FirstHomeVisitDate
	, FirstKempeDate
	, cte10_2b.SupervisorFirstEvent
	, FirstEvent
	, CASE WHEN FirstEvent <= '07/01/2014' AND TrainingDate IS NOT NULL THEN 'T'
		-- OLD CODE Orientation MUST HAPPEN PRIOR TO FIRSTEVENT , NOT SURE WHY 6 month given: WHEN TrainingDate <= dateadd(day, 183, FirstEvent) THEN 'T' 
		WHEN TrainingDate < FirstEvent THEN 'T' 
		WHEN FirstEvent <= '07/01/2014' AND TopicCode = 5.5 THEN 'T'
		else 'F' END AS 'Meets Target'
	FROM cte10_2b
	--WHERE not (cte10_2b.FirstEvent< '07/01/2014' and cte10_2b.TrainingDate is null and cte10_2b.TopicCode='5.5')
	GROUP BY cte10_2b.WorkerPK
	, WorkerName
	, Supervisor
	, FSW
	, FAW
	, TopicCode
	, TopicName
	, TrainingDate
	, FirstHomeVisitDate
	, FirstKempeDate
	, cte10_2b.SupervisorFirstEvent
	, FirstEvent
	, rownumber
)

, cteMeetTarget AS (
	SELECT COUNT(RowNumber) over (PARTITION BY TopicCode) as TotalWorkers
	, WorkerPK
	, WorkerName
	, Supervisor
	, FSW
	, FAW
	, TopicCode
	, TopicName
	, TrainingDate
	, FirstHomeVisitDate
	, FirstKempeDate
	, SupervisorFirstEvent
	, FirstEvent
	, [Meets Target]
	FROM cteMeetTarget1	

)

--Now calculate the number meeting count, by currentrole
, cteCountMeeting AS (
		SELECT TopicCode, count(*) AS totalmeetingcount
		FROM cteMeetTarget
		WHERE [Meets Target]='T'
		GROUP BY TopicCode
)


SELECT 
 case when TotalWorkers is null then 0 else TotalWorkers end as TotalWorkers
, WorkerPK
, WorkerName
, Supervisor
, FSW
, FAW
, cteMeetTarget.topiccode
, cteCountMeeting.TopicCode
, CASE WHEN cteMeetTarget.topiccode = 1.0 THEN '10-1a. Staff (assessment workers, home visitors and supervisors) are oriented to their roles as they relate to the programs goals, services policies and operating procedures and philosophy of home visiting/family support prior to direct work with children and families' 
	WHEN cteMeetTarget.topiccode = 2.0 THEN '10-1b. Staff (assessment workers, home visitors and supervisors) are oriented to the programs relationship with other community resources prior to direct work with children and families'  
	WHEN cteMeetTarget.topiccode = 3.0 THEN '10-1c. Staff (assessment workers, home visitors and supervisors) are oriented to child abuse and neglect indicators and reporting requirements prior to direct work with children and families' 
	WHEN cteMeetTarget.topiccode = 4.0 THEN '10-1d. Staff (assessment workers, home visitors and supervisors) are oriented to issues of confidentiality prior to direct work with children and families' 
	WHEN cteMeetTarget.topiccode = 5.0 THEN '10-1e. Staff (assessment workers, home visitors and supervisors) are oriented to issues related to boundaries prior to direct work with children and families' 
	WHEN ctemeettarget.topiccode = 5.5 THEN '10-1f. Staff (assessment workers, home visitors and supervisors) are oriented to issues related to the personal safety of staff' 
	END AS TopicName
, TrainingDate
, FirstHomeVisitDate
, FirstKempeDate
, SupervisorFirstEvent
, FirstEvent
, [Meets Target]
, case when totalmeetingcount is null then 0 else totalmeetingcount end as totalmeetingcount
, case when totalmeetingcount is null then '0%'
  ELSE CONVERT(VARCHAR(MAX), CONVERT(INT,100*(CAST(totalmeetingcount AS decimal(10,2)) / CAST(TotalWorkers AS decimal(10,2)))))+ '%'  
  end as MeetingPercent
,	CASE WHEN totalmeetingcount is null then '1'
	when cast(totalmeetingcount AS DECIMAL(10,2)) / cast(TotalWorkers AS DECIMAL(10,2)) = 1 THEN '3' 
	WHEN cast(totalmeetingcount AS DECIMAL(10,2)) / cast(TotalWorkers AS DECIMAL(10,2)) >= .9 THEN '2'
	WHEN cast(totalmeetingcount AS DECIMAL(10,2)) / cast(TotalWorkers AS DECIMAL(10,2)) < .9 THEN '1'
	END AS Rating
FROM cteMeetTarget
LEFT JOIN cteCountMeeting ON cteCountMeeting.TopicCode = cteMeetTarget.TopicCode
ORDER BY cteMeetTarget.topiccode
END
GO
