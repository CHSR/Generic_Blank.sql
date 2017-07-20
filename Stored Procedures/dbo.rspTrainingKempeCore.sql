SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 05/22/2013
-- Description:	Training Data Training: New York State Required Trainings
-- =============================================
CREATE PROCEDURE [dbo].[rspTrainingKempeCore]
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
	, FirstKempeDate FROM [dbo].[fnGetWorkerEventDates](@progfk, NULL, NULL)
	WHERE TerminationDate IS NULL
	AND FirstKempeDate > @sdate
	AND FirstKempeDate IS NOT null
)

, cteEventDates AS (
	SELECT WorkerPK
	, wrkrLName
	, MyWrkrCount
	, WorkerName
	, FirstKempeDate
	, min(PC1ID) AS PC1ID
	 FROM cteEventDate
	 INNER JOIN dbo.Kempe k ON k.FAWFK=WorkerPK
	 INNER JOIN CaseProgram cp ON cp.HVCaseFK=k.HVCaseFK
	 WHERE k.KempeDate = FirstKempeDate AND k.FAWFK=WorkerPK
	 GROUP BY WorkerPK
	, wrkrLName
	, MyWrkrCount
	, WorkerName
	, FirstKempeDate
)

, cteKempeCore AS (
	select WorkerPK, WorkerName
	, FirstKempeDate
	, PC1ID
	, COUNT(workerpk) OVER (PARTITION BY MyWrkrCount) AS WorkerCount
	, (Select MIN(trainingdate) as TrainingDate 
									from TrainingAttendee ta
									LEFT JOIN Training t on ta.TrainingFK = t.TrainingPK
									LEFT JOIN TrainingDetail td on td.TrainingFK=t.TrainingPK
									LEFT join codeTopic cdT on cdT.codeTopicPK=td.TopicFK
									where TopicCode = 10.0 AND ta.WorkerFK=workerpk
									)
		AS KempCoreDate
	from cteEventDates
	GROUP BY WorkerPK, WorkerName, FirstKempeDate, MyWrkrCount, PC1ID
)

, cteFinal as (
	SELECT WorkerPK, workername, FirstKempeDate, KempCoreDate, WorkerCount, PC1ID
		, MeetsTarget =
			CASE 
				WHEN KempCoreDate Is Null THEN 'F'
				WHEN KempCoreDate > FirstKempeDate THEN 'F'
				ELSE 'T'
			END
	From cteKempeCore
 )
 
 --Now calculate the number meeting count, by currentrole
, cteCountMeeting AS (
		SELECT WorkerCount, count(*) AS totalmeetingcount
		FROM cteFinal
		WHERE MeetsTarget='T'
		GROUP BY WorkerCount
)

 SELECT cteFinal.workername, FirstKempeDate, KempCoreDate, MeetsTarget, cteFinal.workercount, totalmeetingcount
 ,  CASE WHEN cast(totalmeetingcount AS DECIMAL) / cast(cteFinal.workercount AS DECIMAL) = 1 THEN '3' 
	WHEN cast(totalmeetingcount AS DECIMAL) / cast(cteFinal.workercount AS DECIMAL) BETWEEN .9 AND .99 THEN '2'
	WHEN cast(totalmeetingcount AS DECIMAL) / cast(cteFinal.workercount AS DECIMAL) < .9 THEN '1'
	END AS Rating
,	'2.3C. Staff and volunteers who use the assessment tool(s) have been trained in its/their use prior to administering it/them.' AS CSST
, cast(totalmeetingcount AS DECIMAL) / cast(cteFinal.workercount AS DECIMAL) AS PercentMeeting
, PC1ID
FROM cteFinal
INNER JOIN cteCountMeeting ON cteCountMeeting.WorkerCount = cteFinal.WorkerCount
ORDER BY cteFinal.workername


END
GO
