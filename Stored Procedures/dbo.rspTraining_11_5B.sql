SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 04/07/2016
-- Description:	Training 11-5B Prenatal Training
-- Edited by:   
-- Edit date:   
-- EXEC rspTraining_11_5B @progfk = 1, @sdate = '07/01/2012'
-- =============================================
CREATE PROCEDURE [dbo].[rspTraining_11_5B]
	-- Add the parameters for the stored procedure here
	@progfk AS INT,
	@sdate AS date
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

DECLARE @edate AS DATE = GETDATE()

--Get Workers in time period
;WITH  cteEventDates AS (
	SELECT workerpk, wrkrLName
	, rtrim(wrkrFname) + ' ' + rtrim(wrkrLName) as WorkerName, hiredate
	, FirstKempeDate, FirstHomeVisitDate, SupervisorFirstEvent 
	, '1' AS TotalCounter --used to get a count of all workers in this report towards the end
	FROM [dbo].[fnGetWorkerEventDates](@progfk, NULL, NULL)
	WHERE (HireDate BETWEEN @sdate and DATEADD(DAY, -182, @edate))
	
)

, cteFormal AS (
Select MIN(TrainingDate) AS [FormalTrainingDt] , workerpk, cteEventDates.HireDate, t.IsExempt AS [FormalTrainingExempt]
from cteEventDates
INNER JOIN TrainingAttendee ta ON ta.WorkerFK=cteEventDates.WorkerPK
LEFT JOIN Training t on ta.TrainingFK = t.TrainingPK
LEFT JOIN TrainingDetail td on td.TrainingFK=t.TrainingPK
LEFT join codeTopic cdT on cdT.codeTopicPK=td.TopicFK
where (cdT.TopicCode = 40.0) 
GROUP BY workerpk, cteEventDates.HireDate, t.IsExempt
)

, cteStopGap AS (
Select MIN(TrainingDate) AS [StopGapTrainingDt] , workerpk, cteEventDates.HireDate, t.IsExempt AS [StopGapExempt]
from cteEventDates
INNER JOIN TrainingAttendee ta ON ta.WorkerFK=cteEventDates.WorkerPK
LEFT JOIN Training t on ta.TrainingFK = t.TrainingPK
LEFT JOIN TrainingDetail td on td.TrainingFK=t.TrainingPK
LEFT join codeTopic cdT on cdT.codeTopicPK=td.TopicFK
where (cdT.TopicCode = 41.0) 
GROUP BY workerpk, cteEventDates.HireDate, t.IsExempt
)

, cteFinal AS (

		SELECT DISTINCT WorkerName, cteEventDates.workerpk, cteEventDates.HireDate, [cteStopGap].[StopGapTrainingDt], [cteFormal].[FormalTrainingDt]
			, CASE WHEN [StopGapTrainingDt] IS NOT NULL THEN 1 
				WHEN [FormalTrainingDt] IS NOT NULL THEN 1
				END AS ContentCompleted
			, CASE WHEN [StopGapTrainingDt] <= dateadd(day, 182, cteEventDates.HireDate) THEN 1 
					WHEN [FormalTrainingDt] <= dateadd(day, 182, cteEventDates.HireDate) THEN 1 
					WHEN [StopGapExempt]='1' then '1'
					WHEN [FormalTrainingExempt]='1' then '1'
					ELSE 0 END AS [Meets Target]
					, TotalCounter
		FROM cteEventDates 
		LEFT JOIN cteFormal ON cteFormal.WorkerPK = cteEventDates.WorkerPK
		LEFT Join cteStopGap ON cteStopGap.WorkerPK = cteEventDates.WorkerPK
		GROUP BY cteEventDates.WorkerName, cteEventDates.HireDate, [cteStopGap].[StopGapTrainingDt], [cteFormal].[FormalTrainingDt], cteEventDates.workerpk
		, [StopGapExempt], [cteFormal].[FormalTrainingExempt], TotalCounter
)


	SELECT WorkerName, workerpk, HireDate, [StopGapTrainingDt], [FormalTrainingDt]
			, ContentCompleted
			,  CASE [cteFinal].[Meets Target]
				WHEN '1' THEN 'T'
				ELSE 'F'
				END AS [Meets Target]
	, count([TotalCounter]) OVER(PARTITION BY TotalCounter) AS TotalWorkers
	, SUM([cteFinal].[ContentCompleted]) OVER(PARTITION BY TotalCounter) AS MeetTarget
	, SUM([Meets Target]) OVER(PARTITION BY TotalCounter) AS MeetTargetOnTime
	,	CASE WHEN count([TotalCounter]) OVER(PARTITION BY TotalCounter) = SUM([Meets Target]) OVER(PARTITION BY TotalCounter) THEN '3' 
			WHEN count([TotalCounter]) OVER(PARTITION BY TotalCounter) = SUM([cteFinal].[ContentCompleted]) OVER(PARTITION BY TotalCounter) THEN '2'
			ELSE '1'
			END AS Rating
	FROM cteFinal
	GROUP BY WorkerName, workerpk, HireDate, [StopGapTrainingDt], [FormalTrainingDt]
			, ContentCompleted
			, [Meets Target], TotalCounter
	
END
GO
