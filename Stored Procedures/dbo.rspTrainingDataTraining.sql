SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 05/22/2013
-- Description:	Training Data Training: New York State Required Trainings
-- Edit date: 10/11/2013 CP - workerprogram was NOT duplicating cases when worker transferred
-- =============================================
CREATE PROCEDURE [dbo].[rspTrainingDataTraining]
	-- Add the parameters for the stored procedure here
	@sdate AS DATETIME,
	@progfk AS INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Get FAW's in time period

;WITH  cteEventDates AS (
	SELECT workerpk, RTRIM(Worker.FirstName) + ' ' + RTRIM(Worker.LastName) AS WorkerName
	, HireDate, '1' AS MyWrkrCount
	FROM Worker
	INNER JOIN WorkerProgram wp ON dbo.Worker.WorkerPK = wp.WorkerFK
	WHERE wp.ProgramFK=@progfk
	AND (wp.HireDate >=  @sdate and wp.HireDate < DATEADD(d, -181, GETDATE()))
	AND TerminationDate IS NULL
	
)

, cteFirstHireDate AS(
	SELECT workerpk, WorkerName
	, COUNT(workerpk) OVER (PARTITION BY MyWrkrCount) AS WorkerCount
	, MIN(wp.HireDate) AS FirstHireDate
	FROM cteEventDates
	INNER JOIN WorkerProgram wp ON cteEventDates.WorkerPK = wp.workerfk
	GROUP BY WorkerPK, WorkerName, MyWrkrCount
	HAVING MIN(wp.HireDate) > @sdate
)


, cteDataTrainingDt AS (
		select WorkerPK, WorkerName
		, FirstHireDate
		, (Select MIN(trainingdate) as TrainingDate 
									from TrainingAttendee ta
									LEFT JOIN Training t on ta.TrainingFK = t.TrainingPK
									LEFT JOIN TrainingDetail td on td.TrainingFK=t.TrainingPK
									LEFT join codeTopic cdT on cdT.codeTopicPK=td.TopicFK
									where TopicCode = 6.0 AND ta.WorkerFK=workerpk
									)
			AS DataEntryDate
		, WorkerCount
		 from cteFirstHireDate
		 GROUP BY WorkerPK, WorkerName, FirstHireDate, WorkerCount
)


, cteFinal as (
	SELECT WorkerPK, workername, FirstHireDate, DataEntryDate, WorkerCount
		, MeetsTarget =
			CASE 
				WHEN DataEntryDate Is Null THEN 'F'
				WHEN dateadd(dd, 182, FirstHireDate) < DataEntryDate THEN 'F'
				ELSE 'T'
			END
	From cteDataTrainingDt
 )
 
 --Now calculate the number meeting count, by currentrole
, cteCountMeeting AS (
		SELECT WorkerCount, count(*) AS totalmeetingcount
		FROM cteFinal
		WHERE MeetsTarget='T'
		GROUP BY WorkerCount
)

 SELECT cteFinal.workername, FirstHireDate, DataEntryDate, MeetsTarget, cteFinal.workercount, totalmeetingcount
 ,  CASE WHEN cast(totalmeetingcount AS DECIMAL) / cast(cteFinal.workercount AS DECIMAL) = 1 THEN '3' 
	WHEN cast(totalmeetingcount AS DECIMAL) / cast(cteFinal.workercount AS DECIMAL) BETWEEN .8 AND .99 THEN '2'
	WHEN cast(totalmeetingcount AS DECIMAL) / cast(cteFinal.workercount AS DECIMAL) < .8 THEN '1'
	END AS Rating
,	'NYS2. Staff (Supervisors, assessment workers, home visitors) receive data forms training within six months of hire to a HFNY position.' AS CSST
, cast(totalmeetingcount AS DECIMAL) / cast(cteFinal.workercount AS DECIMAL) AS PercentMeeting
FROM cteFinal
INNER JOIN cteCountMeeting ON cteCountMeeting.WorkerCount = cteFinal.WorkerCount
ORDER BY cteFinal.workername


END
GO
