SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 05/22/2013
-- Description:	Training Data Training: New York State Required Trainings
-- =============================================
CREATE PROCEDURE [dbo].[rspTrainingFSWCore]
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
	, FirstHomeVisitDate FROM [dbo].[fnGetWorkerEventDates](@progfk, NULL, NULL)
	WHERE TerminationDate IS NULL
	AND FirstHomeVisitDate > @sdate
	AND FirstHomeVisitDate IS NOT NULL
)

, cteEventDates AS (
	SELECT WorkerPK
	, wrkrLName
	, MyWrkrCount
	, WorkerName
	, FirstHomeVisitDate
	, min(PC1ID) AS PC1ID
	 FROM cteEventDate
	 INNER JOIN dbo.HVLog h ON h.FSWFK=WorkerPK
	 INNER JOIN CaseProgram cp ON cp.HVCaseFK=h.HVCaseFK
	 WHERE h.VisitStartTime = FirstHomeVisitDate AND h.FSWFK=WorkerPK
	 GROUP BY WorkerPK
	, wrkrLName
	, MyWrkrCount
	, WorkerName
	, FirstHomeVisitDate
)

, cteFSWCore AS (
	select WorkerPK, WorkerName
	, FirstHomeVisitDate
	, COUNT(workerpk) OVER (PARTITION BY MyWrkrCount) AS WorkerCount
	, PC1ID
	, (Select MIN(trainingdate) as TrainingDate 
									from TrainingAttendee ta
									LEFT JOIN Training t on ta.TrainingFK = t.TrainingPK
									LEFT JOIN TrainingDetail td on td.TrainingFK=t.TrainingPK
									LEFT join codeTopic cdT on cdT.codeTopicPK=td.TopicFK
									where TopicCode = 11.0 AND ta.WorkerFK=workerpk
									)
		AS FSWCoreDate
	from cteEventDates
	GROUP BY WorkerPK, WorkerName, FirstHomeVisitDate, MyWrkrCount
	, PC1ID
)

, cteFinal as (
	SELECT WorkerPK, workername, FirstHomeVisitDate, FSWCoreDate, WorkerCount
	, PC1ID
		, MeetsTarget =
			CASE 
				WHEN FSWCoreDate Is Null THEN 'F'
				WHEN FSWCoreDate > FirstHomeVisitDate THEN 'F'
				ELSE 'T'
			END
	From cteFSWCore
 )
 
 --Now calculate the number meeting count, by currentrole
, cteCountMeeting AS (
		SELECT WorkerCount, count(*) AS totalmeetingcount
		FROM cteFinal
		WHERE MeetsTarget='T'
		GROUP BY WorkerCount
)

 SELECT cteFinal.workername, FirstHomeVisitDate, FSWCoreDate, MeetsTarget, cteFinal.workercount, totalmeetingcount
	, PC1ID
 ,  CASE WHEN cast(totalmeetingcount AS DECIMAL) / cast(cteFinal.workercount AS DECIMAL) = 1 THEN '3' 
	WHEN cast(totalmeetingcount AS DECIMAL) / cast(cteFinal.workercount AS DECIMAL) BETWEEN .9 AND .99 THEN '2'
	WHEN cast(totalmeetingcount AS DECIMAL) / cast(cteFinal.workercount AS DECIMAL) < .9 THEN '1'
	END AS Rating
,	'NYS4. Those who visit families will have core training before visiting a family.' AS CSST
, cast(totalmeetingcount AS DECIMAL) / cast(cteFinal.workercount AS DECIMAL) AS PercentMeeting
FROM cteFinal
INNER JOIN cteCountMeeting ON cteCountMeeting.WorkerCount = cteFinal.WorkerCount
ORDER BY cteFinal.workername


END
GO
