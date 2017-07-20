SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 05/22/2013
-- Description:	Annual Child Abuse & Neglect
-- =============================================
CREATE PROCEDURE [dbo].[rspTraining7-5D_PHQ]
	
	-- Add the parameters for the stored procedure here
	@sdate AS DATETIME,
	@progfk AS int
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


--Get Workers in time period
;WITH  cteEventDates AS (
	SELECT workerpk, wrkrLName
	, rtrim(wrkrFname) + ' ' + rtrim(wrkrLName) as WorkerName, hiredate
	, FirstKempeDate, FirstHomeVisitDate, SupervisorFirstEvent, FirstPHQDate
	, '1' AS TotalCounter --used to get a count of all workers in this report towards the end
	FROM [dbo].[fnGetWorkerEventDates](@progfk, NULL, NULL)
	WHERE FirstPHQDate is not null
	and HireDate >= @sdate
	
)



, ctePHQTrainingAll AS ( 
Select t.TrainingDate AS [PHQTrainingDt]
, workerpk, cteEventDates.FirstPHQDate, t.IsExempt AS [TrainingExempt] , t.TrainingPK, t.TrainingTitle
, workerrownumber = row_number() over(partition by workerpk order by t.TrainingDate asc) 
from cteEventDates
INNER JOIN TrainingAttendee ta ON ta.WorkerFK=cteEventDates.WorkerPK
LEFT JOIN Training t on ta.TrainingFK = t.TrainingPK
LEFT JOIN TrainingDetail td on td.TrainingFK=t.TrainingPK
LEFT join codeTopic cdT on cdT.codeTopicPK=td.TopicFK
where (cdT.TopicCode = 39.0)
)

, ctePHQTraining as (
--get only one training per worker
select [PHQTrainingDt]
, workerpk, FirstPHQDate, [TrainingExempt] , TrainingPK, TrainingTitle
from ctePHQTrainingAll
where workerrownumber = 1 
)


, cteFinal AS (

		SELECT DISTINCT WorkerName, cteEventDates.workerpk, cteEventDates.FirstPHQDate, [PHQTrainingDt]
			, CASE WHEN [PHQTrainingDt] IS NOT NULL THEN 1 
				END AS ContentCompleted
			, CASE WHEN [PHQTrainingDt] <= cteEventDates.FirstPHQDate THEN 1 
					WHEN [TrainingExempt]='1' then '1'
					ELSE 0 END AS [Meets Target]
			, TotalCounter
			, ctePHQTraining.TrainingTitle
			, vPHQ9.HVCaseFK
		FROM cteEventDates 
		LEFT JOIN ctePHQTraining ON ctePHQTraining.WorkerPK = cteEventDates.WorkerPK
		inner join vPHQ9 On cteEventDates.workerpk = vPHQ9.workerfk and cteEventDates.FirstPHQDate = vPHQ9.DateAdministered
		GROUP BY cteEventDates.WorkerName, cteEventDates.FirstPHQDate, [PHQTrainingDt], cteEventDates.workerpk
		,  [TrainingExempt], TotalCounter, ctePHQTraining.TrainingTitle, hvcasefk
)

 --Now calculate the number meeting count, by currentrole
, cteCountMeeting AS (
		SELECT  count(*) AS totalmeetingcount
		FROM cteFinal
		WHERE [Meets Target] = 1
)

, ctePutItAllTogether as (
	SELECT WorkerName, workerpk, FirstPHQDate, [PHQTrainingDt]
			, ContentCompleted
			, totalmeetingcount, cteFinal.TotalCounter
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
	, cast(totalmeetingcount AS DECIMAL) / cast(count([TotalCounter]) OVER(PARTITION BY TotalCounter) AS DECIMAL) AS PercentMeeting
	, HVCASEFK
	FROM cteFinal, cteCountMeeting
	GROUP BY WorkerName, workerpk, FirstPHQDate, [PHQTrainingDt]
			, ContentCompleted
			, [Meets Target], TotalCounter,totalmeetingcount, TrainingTitle, hvcasefk
)


Select WorkerName
		, workerpk
		, FirstPHQDate
		, [PHQTrainingDt]
		, ContentCompleted
		, totalmeetingcount, TotalCounter
		,  [Meets Target]
		, TotalWorkers
		, MeetTarget
		, MeetTargetOnTime
		, Rating
		, TrainingTitle
		, PercentMeeting
		, MAX(pc1id) as PC1ID
From ctePutItAllTogether
Inner Join CaseProgram cp on cp.hvcasefk = ctePutItAllTogether.hvcasefk 
Group By WorkerName
		, workerpk
		, FirstPHQDate
		, [PHQTrainingDt]
		, ContentCompleted
		, totalmeetingcount, TotalCounter
		,  [Meets Target]
		, TotalWorkers
		, MeetTarget
		, MeetTargetOnTime
		, Rating
		, TrainingTitle
		, PercentMeeting
END
GO
