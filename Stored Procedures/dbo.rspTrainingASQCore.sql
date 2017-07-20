SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 05/22/2013
-- Description:	Training Data Training: New York State Required Trainings
-- =============================================
CREATE PROCEDURE [dbo].[rspTrainingASQCore]
	-- Add the parameters for the stored procedure here
	@sdate AS DATETIME,
	@progfk AS INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Get FAW's in time period

;WITH  cteEventDate AS (
	SELECT workerpk, wrkrLName
	, '1' AS MyWrkrCount
	, rtrim(wrkrFname) + ' ' + rtrim(wrkrLName) as WorkerName
	, FirstASQDate FROM [dbo].[fnGetWorkerEventDates](@progfk, NULL, NULL)
	WHERE TerminationDate IS NULL
	AND FirstASQDate > @sdate
	AND FirstASQDate IS NOT null
)

, cteEventDates AS (
	SELECT WorkerPK
	, wrkrLName
	, MyWrkrCount
	, WorkerName
	, FirstASQDate
	, min(PC1ID) AS PC1ID
	 FROM cteEventDate
	 INNER JOIN ASQ a ON a.FSWFK=WorkerPK
	 INNER JOIN CaseProgram cp ON cp.HVCaseFK=a.HVCaseFK
	 WHERE a.DateCompleted = FirstASQDate AND a.FSWFK=WorkerPK
	 GROUP BY WorkerPK
	, wrkrLName
	, MyWrkrCount
	, WorkerName
	, FirstASQDate
)

, cteASQCore AS (
	select WorkerPK, WorkerName
	, FirstASQDate
	, PC1ID
	, COUNT(workerpk) OVER (PARTITION BY MyWrkrCount) AS WorkerCount
	, (Select MIN(trainingdate) as TrainingDate 
									from TrainingAttendee ta
									LEFT JOIN Training t on ta.TrainingFK = t.TrainingPK
									LEFT JOIN TrainingDetail td on td.TrainingFK=t.TrainingPK
									LEFT join codeTopic cdT on cdT.codeTopicPK=td.TopicFK
									where TopicCode = 13.0 AND ta.WorkerFK=workerpk
									)
		AS ASQCoreDate
	from cteEventDates
	GROUP BY WorkerPK, WorkerName, FirstASQDate, MyWrkrCount, PC1ID
)

, cteFinal as (
	SELECT WorkerPK, workername, FirstASQDate, ASQCoreDate, WorkerCount, PC1ID
		, MeetsTarget =
			CASE 
				WHEN ASQCoreDate Is Null THEN 'F'
				WHEN ASQCoreDate > FirstASQDate THEN 'F'
				ELSE 'T'
			END
	From cteASQCore
 )
 
 --Now calculate the number meeting count, by currentrole
, cteCountMeeting AS (
		SELECT WorkerCount, count(*) AS totalmeetingcount
		FROM cteFinal
		WHERE MeetsTarget='T'
		GROUP BY WorkerCount
)

 SELECT cteFinal.workername, FirstASQDate, ASQCoreDate, MeetsTarget, cteFinal.workercount, totalmeetingcount
 ,  CASE WHEN cast(totalmeetingcount AS DECIMAL) / cast(cteFinal.workercount AS DECIMAL) = 1 THEN '3' 
	WHEN cast(totalmeetingcount AS DECIMAL) / cast(cteFinal.workercount AS DECIMAL) BETWEEN .9 AND .99 THEN '2'
	WHEN cast(totalmeetingcount AS DECIMAL) / cast(cteFinal.workercount AS DECIMAL) < .9 THEN '1'
	END AS Rating
,	'6-6 Those who administer developmental screenings have been trained in the use of the tool before administering it.' AS CSST
, cast(totalmeetingcount AS DECIMAL) / cast(cteFinal.workercount AS DECIMAL) AS PercentMeeting
, PC1ID
FROM cteFinal
INNER JOIN cteCountMeeting ON cteCountMeeting.WorkerCount = cteFinal.WorkerCount
ORDER BY cteFinal.workername


END
GO
