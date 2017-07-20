SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 04/15/2013
-- Description:	Training [NYS 3 IFSP] New York State Required Trainings
-- Edited On:		10/15/2013 - as per JH, this report should only look at hire date, not First Event Date
-- Edited By:	Chris Papas
-- Edit:		10/23/2013 - only FSW and Supervisors on this report. And use there respective start dates NOT hire date
-- =============================================
CREATE procedure [dbo].[rspTraining_NYS3IFSP]
	-- Add the parameters for the stored procedure here
	@sdate AS DATETIME,
	@progfk AS INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

;WITH  cteEventDates AS (
	SELECT workerpk, wrkrLName
	, rtrim(wrkrFname) + ' ' + rtrim(wrkrLName) as WorkerName
	, FSWInitialStart, SupervisorInitialStart 
	, CASE 
		WHEN FSWInitialStart IS NULL THEN SupervisorInitialStart
		WHEN SupervisorInitialStart IS NULL THEN FSWInitialStart
		WHEN SupervisorInitialStart>=FSWInitialStart THEN FSWInitialStart
		WHEN FSWInitialStart>SupervisorInitialStart THEN SupervisorInitialStart
	END AS DateStartedPos
	, '1' AS MyWrkrCount
	FROM [dbo].[fnGetWorkerEventDates](@progfk, NULL, NULL)
	WHERE (FSWInitialStart >=  @sdate and FSWInitialStart < DATEADD(d, -91, GETDATE())
	OR SupervisorInitialStart >=  @sdate and SupervisorInitialStart < DATEADD(d, -91, GETDATE())
	)
)
	

, cteGetShadowDate AS (
		select WorkerPK, WrkrLName, WorkerName
		, COUNT(workerpk) OVER (PARTITION BY MyWrkrCount) AS WorkerCount
		, DateStartedPos
		, (Select MIN(trainingdate) as TrainingDate 
									from TrainingAttendee ta
									LEFT JOIN Training t on ta.TrainingFK = t.TrainingPK
									LEFT JOIN TrainingDetail td on td.TrainingFK=t.TrainingPK
									LEFT join codeTopic cdT on cdT.codeTopicPK=td.TopicFK
									where ((TopicCode = 7.0 OR TopicCode = 7.1) and ta.WorkerFK=cteEventDates.WorkerPK)
									)
			AS FirstIFSPDate
		 from cteEventDates
		 group by WorkerPK, WrkrLName, WorkerName, DateStartedPos, MyWrkrCount
)

, cteFinal as (
	SELECT WorkerPK, workername, FirstIFSPDate, workercount
		, DateStartedPos
		,CASE WHEN FirstIFSPDate Is Null THEN 'F'
		WHEN dateadd(dd, 91, DateStartedPos) < FirstIFSPDate THEN 'F'		
		ELSE 'T' END AS MeetsTarget
		, '1' AS GenericColumn --used for next cte cteCountMeeting
	From cteGetShadowDate
 )
 
 
--Now calculate the number meeting count, by currentrole
, cteCountMeeting AS (
		SELECT GenericColumn, count(*) AS totalmeetingcount
		FROM cteFinal
		WHERE MeetsTarget='T'
		GROUP BY GenericColumn
)

 SELECT cteFinal.workername, DateStartedPos as FirstEventDate, FirstIFSPDate, MeetsTarget, workercount, totalmeetingcount
 ,  CASE WHEN cast(totalmeetingcount AS DECIMAL) / cast(workercount AS DECIMAL) = 1 THEN '3' 
	WHEN cast(totalmeetingcount AS DECIMAL) / cast(workercount AS DECIMAL) BETWEEN .9 AND .99 THEN '2'
	WHEN cast(totalmeetingcount AS DECIMAL) / cast(workercount AS DECIMAL) < .9 THEN '1'
	END AS Rating
,	'NYS3. Staff (Supervisors and Home Visitors) receive FGP/IFSP training within three months of hire to a HFNY position.' AS CSST
, cast(totalmeetingcount AS DECIMAL) / cast(workercount AS DECIMAL) AS PercentMeeting
FROM cteFinal
INNER JOIN cteCountMeeting ON cteCountMeeting.GenericColumn = cteFinal.GenericColumn
ORDER BY cteFinal.workername

END
GO
