SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 05/22/2013
-- Description:	Annual Child Abuse & Neglect
-- =============================================
CREATE PROCEDURE [dbo].[rspTraining11-5D_Abuse]
	
	-- Add the parameters for the stored procedure here
	@sdate AS DATETIME,
	@edate AS DATETIME,
	@progfk AS int
	
	with recompile
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


--Get Workers in time period
;WITH  cteEventDates AS (
	SELECT workerpk, wrkrLName
	, rtrim(wrkrFname) + ' ' + rtrim(wrkrLName) as WorkerName, hiredate
	, FirstKempeDate, FirstHomeVisitDate, SupervisorFirstEvent 
	, '1' AS TotalCounter --used to get a count of all workers in this report towards the end
	FROM [dbo].[fnGetWorkerEventDates](@progfk, NULL, NULL)
	WHERE (HireDate < DATEADD(DAY, -365, @edate))
	
)

, cteAbuseTraining AS (
--this is an annual requirement.  
Select t.TrainingDate AS [AbuseTrainingDt], ROW_NUMBER() OVER (PARTITION BY workerpk ORDER BY t.TrainingDate DESC) as Corr
, workerpk, cteEventDates.HireDate, t.IsExempt AS [TrainingExempt] , t.TrainingPK, t.TrainingTitle
from cteEventDates
INNER JOIN TrainingAttendee ta ON ta.WorkerFK=cteEventDates.WorkerPK
LEFT JOIN Training t on ta.TrainingFK = t.TrainingPK
LEFT JOIN TrainingDetail td on td.TrainingFK=t.TrainingPK
LEFT join codeTopic cdT on cdT.codeTopicPK=td.TopicFK
where (cdT.TopicCode = 42.0)
AND t.TrainingDate BETWEEN @sdate AND @edate
)

, cteFinal AS (

		SELECT DISTINCT WorkerName, cteEventDates.workerpk, cteEventDates.HireDate, [AbuseTrainingDt]
			, CASE WHEN [AbuseTrainingDt] IS NOT NULL THEN 1 
				END AS ContentCompleted
			, CASE WHEN [AbuseTrainingDt] >= dateadd(day, -365, @edate) THEN 1 
					WHEN [TrainingExempt]='1' then '1'
					ELSE 0 END AS [Meets Target]
			, TotalCounter
			, cteAbuseTraining.TrainingTitle
		FROM cteEventDates 
		LEFT JOIN cteAbuseTraining ON cteAbuseTraining.WorkerPK = cteEventDates.WorkerPK
		GROUP BY cteEventDates.WorkerName, cteEventDates.HireDate, [AbuseTrainingDt], cteEventDates.workerpk
		,  [TrainingExempt], TotalCounter, cteAbuseTraining.TrainingTitle
)

 --Now calculate the number meeting count, by currentrole
, cteCountMeeting AS (
		SELECT  count(*) AS totalmeetingcount
		FROM cteFinal
		WHERE [Meets Target] = 1
)

	SELECT WorkerName, workerpk, HireDate, [AbuseTrainingDt]
			, ContentCompleted, totalmeetingcount, cteFinal.TotalCounter
			,  CASE [cteFinal].[Meets Target]
				WHEN '1' THEN 'T'
				ELSE 'F'
				END AS [Meets Target]
	, count([TotalCounter]) OVER(PARTITION BY TotalCounter) AS TotalWorkers
	, SUM([cteFinal].[ContentCompleted]) OVER(PARTITION BY TotalCounter) AS MeetTarget
	, SUM([Meets Target]) OVER(PARTITION BY TotalCounter) AS MeetTargetOnTime
	,	CASE WHEN count([TotalCounter]) OVER(PARTITION BY TotalCounter) = SUM([Meets Target]) OVER(PARTITION BY TotalCounter) THEN '3' 
			WHEN cast(totalmeetingcount AS DECIMAL) / CAST(COUNT([TotalCounter]) OVER(PARTITION BY TotalCounter) AS DECIMAL) BETWEEN .9 AND .99 THEN '2' 
			ELSE '1'
			END AS Rating
	, TrainingTitle
	FROM cteFinal, cteCountMeeting
	GROUP BY WorkerName, workerpk, HireDate, [AbuseTrainingDt]
			, ContentCompleted
			, [Meets Target], TotalCounter,totalmeetingcount, TrainingTitle
		
END
GO
