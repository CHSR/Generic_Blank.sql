SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 03/22/2013
-- Description:	Training [10-3] Credential Evidence (Intensive Role Specific Training)
-- Edit date: 10/11/2013 CP - workerprogram was NOT duplicating cases when worker transferred
-- =============================================
CREATE PROCEDURE [dbo].[rspTrainingRoleSpecific]
	-- Add the parameters for the stored procedure here
	@sdate AS DATETIME,
	@progfk AS INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Get FAW's in time period
;WITH  cteFAWMain AS (
	SELECT DISTINCT wp.workerfk
	, 'FAW' AS CurrentRole
	, FAWInitialStart AS StartDate
	, rtrim(w.FirstName) + ' ' + rtrim(w.LastName) AS WorkerName
    , ROW_NUMBER() OVER(ORDER BY workerfk DESC) AS 'RowNumber'
	FROM WorkerProgram wp
	INNER JOIN Worker w ON w.WorkerPK = wp.WorkerFK
	WHERE FAWInitialStart BETWEEN @sdate AND dateadd(day, -183, GETDATE())
	AND (FAWEndDate IS NULL OR FAWEndDate > dateadd(day, 180, FAWStartDate))
	AND (wp.TerminationDate IS NULL OR wp.TerminationDate > GETDATE())
	AND wp.ProgramFK = @progfk
	GROUP BY wp.WorkerFK, LastName, FirstName, FAWInitialStart
)


--Get FSW's in time period
, cteFSWMain AS (

	SELECT DISTINCT wp.workerfk, 'FSW' AS CurrentRole
	, rtrim(w.FirstName) + ' ' + rtrim(w.LastName) AS WorkerName
    , ROW_NUMBER() OVER(ORDER BY workerfk DESC) AS 'RowNumber'
    , FSWInitialStart  AS StartDate
	FROM WorkerProgram wp
	INNER JOIN Worker w ON w.WorkerPK = wp.WorkerFK
	WHERE FSWInitialStart BETWEEN @sdate AND  dateadd(day, -183, GETDATE())
	AND (FSWEndDate IS NULL OR FSWEndDate > dateadd(day, 180, FSWStartDate))
	AND (wp.TerminationDate IS NULL OR wp.TerminationDate > GETDATE())
	AND wp.ProgramFK = @progfk
	GROUP BY wp.WorkerFK, LastName, FirstName, FSWInitialStart
)

--Get Supervisor's in time period
, cteSupMain AS (

	SELECT DISTINCT wp.workerfk
	, w.SupervisorInitialStart AS StartDate
	, 'Supervisor' AS CurrentRole
	, rtrim(w.FirstName) + ' ' + rtrim(w.LastName) AS WorkerName
    , ROW_NUMBER() OVER(ORDER BY workerfk DESC) AS 'RowNumber'
	FROM WorkerProgram wp
	INNER JOIN Worker w ON w.WorkerPK = wp.WorkerFK
	WHERE SupervisorInitialStart BETWEEN @sdate AND  dateadd(day, -183, GETDATE())
	AND (SupervisorEndDate IS NULL OR SupervisorEndDate > dateadd(day, 180, SupervisorStartDate))
	AND (wp.TerminationDate IS NULL OR wp.TerminationDate > GETDATE())
	AND wp.ProgramFK = @progfk
	GROUP BY wp.WorkerFK, LastName, FirstName, SupervisorInitialStart
)

--Now we get the trainings (or lack thereof)
, cteFAWMainTraining AS (
	SELECT cteFAWMain.workerfk
		, t1.TopicCode
		, t1.topicname
		, MIN(t.TrainingDate) AS TrainingDate
	FROM cteFAWMain
			LEFT JOIN TrainingAttendee ta ON ta.WorkerFK = cteFAWMain.WorkerFK
			LEFT JOIN Training t ON t.TrainingPK = ta.TrainingFK
			LEFT JOIN TrainingDetail td ON td.TrainingFK = t.TrainingPK
			LEFT JOIN codeTopic t1 ON td.TopicFK=t1.codeTopicPK
	WHERE t1.TopicCode=10.0
	GROUP BY RowNumber, CurrentRole, cteFAWMain.workerfk, WorkerName, StartDate
			, t1.TopicCode
			, t1.topicname
)


, cteFSWMainTraining AS (
	SELECT cteFSWMain.workerfk
		, t1.TopicCode
		, t1.topicname
		, MIN(t.TrainingDate) AS TrainingDate
	FROM cteFSWMain
			LEFT JOIN TrainingAttendee ta ON ta.WorkerFK = cteFSWMain.WorkerFK
			LEFT JOIN Training t ON t.TrainingPK = ta.TrainingFK
			LEFT JOIN TrainingDetail td ON td.TrainingFK = t.TrainingPK
			LEFT JOIN codeTopic t1 ON td.TopicFK=t1.codeTopicPK
	WHERE t1.TopicCode=11.0
	GROUP BY RowNumber, CurrentRole, cteFSWMain.workerfk, WorkerName, StartDate
			, t1.TopicCode
			, t1.topicname
)

, cteSuperMainTraining AS (
	SELECT cteSupMain.workerfk
		, t1.TopicCode
		, t1.topicname
		, MIN(t.TrainingDate) AS TrainingDate
	FROM cteSupMain
			LEFT JOIN TrainingAttendee ta ON ta.WorkerFK = cteSupMain.WorkerFK
			LEFT JOIN Training t ON t.TrainingPK = ta.TrainingFK
			LEFT JOIN TrainingDetail td ON td.TrainingFK = t.TrainingPK
			LEFT JOIN codeTopic t1 ON td.TopicFK=t1.codeTopicPK
	WHERE t1.TopicCode=12.0
	GROUP BY RowNumber, CurrentRole, cteSupMain.workerfk, WorkerName, StartDate
			, t1.TopicCode
			, t1.topicname
)

--Put it all together, just before calculating Meeting, %'s and Standard Rating
, cteDetails AS (
		SELECT RowNumber, CurrentRole, cteFAWMain.workerfk, WorkerName, StartDate
				, TopicCode
				, topicname
				, TrainingDate
		FROM cteFAWMain
		LEFT JOIN cteFAWMainTraining ON cteFAWMainTraining.WorkerFK = cteFAWMain.WorkerFK

		UNION

		SELECT RowNumber, CurrentRole, cteFSWMain.workerfk, WorkerName, StartDate
				, TopicCode
				, topicname
				, TrainingDate
		FROM cteFSWMain
		LEFT JOIN cteFSWMainTraining ON cteFSWMainTraining.WorkerFK = cteFSWMain.WorkerFK

		UNION

		SELECT RowNumber, CurrentRole, cteSupMain.workerfk, WorkerName, StartDate
				, TopicCode
				, topicname
				, TrainingDate
		FROM cteSupMain
		LEFT JOIN cteSuperMainTraining ON cteSuperMainTraining.WorkerFK = cteSupMain.WorkerFK
)

--add in the "MEETING" Target and Total workers.  Basically each training must occur within 6 months of start
, cteAggregates AS (
		SELECT RowNumber, CurrentRole, workerfk, WorkerName, StartDate
				, TopicCode
				, topicname
				, TrainingDate
				, CASE WHEN TrainingDate <= dateadd(day, 183, startdate) THEN 'Meeting' ELSE 'Not Meeting' END AS 'Meets Target'
				, MAX(RowNumber) OVER(PARTITION BY CurrentRole) as TotalWorkers
		FROM cteDetails
		GROUP BY RowNumber, CurrentRole, workerfk, WorkerName, StartDate
				, TopicCode
				, topicname
				, TrainingDate
				, StartDate
)

--Now calculate the number meeting count, by currentrole
, cteCountMeeting AS (
		SELECT CurrentRole, count(*) AS totalmeetingcount
		FROM cteAggregates
		WHERE [Meets Target]='Meeting'
		GROUP BY CurrentRole
)

----now put it all together
SELECT *, CAST(totalmeetingcount AS decimal(10,2)) / CAST(TotalWorkers AS decimal(10,2)) AS MeetingPercent
,	CASE WHEN cast(totalmeetingcount AS DECIMAL) / cast(TotalWorkers AS DECIMAL) = 1 THEN '3' 
	WHEN cast(totalmeetingcount AS DECIMAL) / cast(TotalWorkers AS DECIMAL) > .9 THEN '2'
	WHEN cast(totalmeetingcount AS DECIMAL) / cast(TotalWorkers AS DECIMAL) < .9 THEN '1'
	END AS Rating
,	CASE cteCountMeeting.CurrentRole 
		WHEN 'FAW' THEN '10-3a. Staff conducting assessments have received intensive role specific training within six months of date of hire to understand the essential components of family assessment'
		WHEN 'FSW' THEN '10-3b. Home Visitors have received intensive role specific training within six months of date of hire to understand the essential components of home visitation'
		WHEN 'Supervisor' THEN '10-3c. Supervisory staff have received intensive role specific training whithin six months of date of hire to understand the essential components of their role within the home visitation program, as well as the role of the family assessment and home visitation'
	END AS CSST
FROM cteAggregates
INNER JOIN cteCountMeeting ON cteCountMeeting.CurrentRole = cteAggregates.CurrentRole
ORDER BY cteAggregates.CurrentRole, RowNumber

END
GO
