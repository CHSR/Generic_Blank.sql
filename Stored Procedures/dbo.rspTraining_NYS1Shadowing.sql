SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 04/15/2013
-- Description:	Training [NYS 3 IFSP] New York State Required Trainings
-- =============================================
CREATE PROCEDURE [dbo].[rspTraining_NYS1Shadowing]
	-- Add the parameters for the stored procedure here
	@sdate AS DATETIME,
	@edate AS DATETIME,
	@progfk AS INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Get FAW's in time period

declare @sdate2 as datetime
declare @progfk2 as int

set @sdate2 = @sdate
set @progfk2 = @progfk

;WITH  cteEventDates AS (
	SELECT workerpk, wrkrLName
	, rtrim(wrkrFname) + ' ' + rtrim(wrkrLName) as WorkerName, hiredate
	, FirstKempeDate, FirstHomeVisitDate, SupervisorFirstEvent FROM [dbo].[fnGetWorkerEventDates](@progfk2, NULL, NULL)
)


, cteFAW as (
	Select workerpk, wrkrLName, WorkerName
	, FirstKempeDate as FirstEventDate
	, 'FAW' as WorkerType
	FROM cteEventDates
	WHERE FirstKempeDate >= @sdate2
)

, cteFSW as (
	Select workerpk, wrkrLName, WorkerName
	, FirstHomeVisitDate as FirstEventDate
	, 'FSW' as WorkerType
	FROM cteEventDates
	WHERE FirstHomeVisitDate >= @sdate2
)

, cteSups as (
	Select workerpk, wrkrLName, WorkerName
	, SupervisorFirstEvent as FirstEventDate
	, 'Supervisor' as WorkerType
	FROM cteEventDates
	WHERE SupervisorFirstEvent >= @sdate2 
)




, ctePutWorkersTogether as (
		Select distinct *, COUNT(workertype) OVER(PARTITION BY workerType) as workercounter FROM cteFAW
	UNION
		Select distinct *, COUNT(workertype) OVER(PARTITION BY workerType) as workercounter FROM cteFSW
		UNION
		Select distinct *, COUNT(workertype) OVER(PARTITION BY workerType) as workercounter FROM cteSups
)


, cteGetShadowDate AS (
		select WorkerPK, WrkrLName, WorkerName
		, FirstEventDate, WorkerType, workercounter
		, Case 
			WHEN WorkerType='FAW' THEN (Select MIN(trainingdate) as TrainingDate 
									from TrainingAttendee ta
									LEFT JOIN Training t on ta.TrainingFK = t.TrainingPK
									LEFT JOIN TrainingDetail td on td.TrainingFK=t.TrainingPK
									LEFT join codeTopic cdT on cdT.codeTopicPK=td.TopicFK
									where (TopicCode = 9.0 and ta.WorkerFK=ctePutWorkersTogether.WorkerPK)
									)
			WHEN WorkerType='FSW' THEN (Select MIN(trainingdate) as TrainingDate 
									from TrainingAttendee ta
									LEFT JOIN Training t on ta.TrainingFK = t.TrainingPK
									LEFT JOIN TrainingDetail td on td.TrainingFK=t.TrainingPK
									LEFT join codeTopic cdT on cdT.codeTopicPK=td.TopicFK
									where (TopicCode = 8.0 and ta.WorkerFK=ctePutWorkersTogether.WorkerPK)
									)
			WHEN WorkerType='Supervisor' THEN (Select MIN(trainingdate) as TrainingDate 
									from TrainingAttendee ta
									LEFT JOIN Training t on ta.TrainingFK = t.TrainingPK
									LEFT JOIN TrainingDetail td on td.TrainingFK=t.TrainingPK
									LEFT join codeTopic cdT on cdT.codeTopicPK=td.TopicFK
									where (TopicCode = 9.1 and ta.WorkerFK=ctePutWorkersTogether.WorkerPK)
									)	
		  END AS FirstShadowDate
		 from ctePutWorkersTogether 
)


, cteFinal as (
	Select Workertype, workername, firsteventdate, FirstShadowDate, workercounter
		,CASE WHEN FirstShadowDate Is Null THEN 'F'
		WHEN FirstEventDate < FirstShadowDate THEN 'F'
		ELSE 'T' END AS MeetsTarget
	From cteGetShadowDate
 )
 

--Now calculate the number meeting count, by currentrole
, cteCountMeeting1 AS (
		SELECT 
		WorkerType,
		CASE WHEN MeetsTarget = 'T' THEN
			 COUNT(*) 
		END AS totalmeetingcount
		FROM cteFinal
		GROUP BY Workertype, MeetsTarget
)

, cteCountMeeting2 AS (
	SELECT WorkerType, SUM(totalmeetingcount) AS totalmeetingcount
	FROM cteCountMeeting1
	GROUP BY WorkerType
)

, cteCountMeeting AS (
	SELECT WorkerType
	, CASE WHEN totalmeetingcount IS NULL THEN '0' ELSE totalmeetingcount END AS totalmeetingcount
	FROM cteCountMeeting2
)

 SELECT cteFinal.Workertype, workername, firsteventdate, FirstShadowDate, MeetsTarget, workercounter, totalmeetingcount
 ,  CASE WHEN cast(totalmeetingcount AS DECIMAL) / cast(workercounter AS DECIMAL) = 1 THEN '3' 
	WHEN cast(totalmeetingcount AS DECIMAL) / cast(workercounter AS DECIMAL) BETWEEN .9 AND .99 THEN '2'
	WHEN cast(totalmeetingcount AS DECIMAL) / cast(workercounter AS DECIMAL) < .9 THEN '1'
	when totalmeetingcount = 0 then '1'
	END AS Rating
,	CASE cteFinal.Workertype 
		WHEN 'FAW' THEN 'NYS1b. Assessment workers shadow experienced staff prior to direct work with families.'
		WHEN 'FSW' THEN 'NYS1a. Home visitors shadow experienced staff prior to direct work with families.'
		WHEN 'Supervisor' THEN 'NYS1c. Supervisors shadow experienced staff prior to direct work with families.'
	END AS CSST
,	CASE cteFinal.Workertype 
		WHEN 'FAW' THEN 'First Kempe Assessment'
		WHEN 'FSW' THEN 'First Home Visit'
		WHEN 'Supervisor' THEN 'First Supervisor Event'
	END AS FirstEventDateType
, cast(totalmeetingcount AS DECIMAL) / cast(workercounter AS DECIMAL) AS PercentMeeting
 FROM cteFinal
INNER JOIN cteCountMeeting ON cteCountMeeting.Workertype = cteFinal.Workertype
ORDER BY cteFinal.Workertype


END
GO
