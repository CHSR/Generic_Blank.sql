SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 12/18/2012
-- Edit Date: 02/21/2013
-- Edit Reason: John no longer wants Exempt Trainings
-- Edit date: 10/11/2013 CP - workerprogram was duplicating cases when worker transferred, but fixed with change to fnGetWorkerEventDatesALL
-- Description:	Worker Training Resume
-- =============================================
CREATE PROCEDURE [dbo].[rspTrainingResume]
	-- Add the parameters for the stored procedure here
	@sdate AS DATETIME,
	@edate AS DATETIME,
	@workerfk AS INT,
	@prgfk AS INT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

; WITH cteMain AS
(
SELECT firstname + lastname AS Name
, fn.WorkerPK
, fn.FAWInitialStart
, fn.SupervisorInitialStart
, fn.FSWInitialStart
, fn.TerminationDate
, fn.HireDate
, fn.FirstASQDate
, fn.FirstHomeVisitDate
, fn.FirstKempeDate
, fn.FirstEvent
, fn.SupervisorFirstEvent
FROM Worker w
INNER JOIN dbo.fnGetWorkerEventDatesALL(@prgfk, NULL, NULL) fn ON fn.workerpk = w.workerpk
--This where clause eliminates workers terminated after start date if the user selected 'All Workers'
WHERE (fn.TerminationDate IS NULL OR fn.TerminationDate >=
	CASE @workerfk
		WHEN NULL THEN @sdate
		ELSE @edate
	END
	)
)

, cteTrainings AS (
SELECT    cteMain.HireDate
		, cteMain.FirstKempeDate
		, cteMain.FirstHomeVisitDate
		, cteMain.TerminationDate
		, cteMain.SupervisorFirstEvent
		, cteMain.FirstASQDate
		, [TrainingPK]
		,[TrainerFK]
		,[TrainingDate]
		,convert(VARCHAR(MAX), [TrainingDays]) + ' days ' 
					+ convert(VARCHAR(MAX), [TrainingHours]) + ' hours ' 
					+ convert(VARCHAR(MAX), [TrainingMinutes]) + ' mins ' AS 'Time'
		,[TrainingTitle]
		, ta.WorkerFK
		, rtrim(w.FirstName) + ' ' + rtrim(w.LastName) AS 'Worker Name:'
		, rtrim(t1.TrainerFirstName) + ' ' + rtrim(t1.TrainerLastName) AS 'Trainer Name'
		, IsExempt
		, cT.TopicCode
		, td.TopicFK
		, convert(VARCHAR(MAX), cT.TopicCode) + ' ' + cT.TopicName AS TopicName
		, td.SubTopicFK
		, st.SubTopicCode + ' ' + st.SubTopicName AS 'SubTopicName'
		, t.ProgramFK
  FROM [dbo].[Training] t
  INNER JOIN TrainingAttendee ta ON ta.TrainingFK=TrainingPK
  INNER JOIN Worker w ON w.WorkerPK=ta.WorkerFK
  INNER JOIN WorkerProgram wp ON wp.WorkerFK = w.WorkerPK
  INNER JOIN TrainingDetail td ON td.TrainingFK = t.TrainingPK
  INNER JOIN codeTopic cT ON cT.codeTopicPK = td.TopicFK
  INNER JOIN cteMain ON cteMain.WorkerPK = ta.WorkerFK
  LEFT JOIN SubTopic st ON st.SubTopicPK=td.SubTopicFK
  LEFT JOIN Trainer t1 ON t1.TrainerPK = t.TrainerFK
  WHERE ta.workerFK = isnull(@workerfk, ta.WorkerFK)
  AND ((TrainingDate BETWEEN @sdate AND @edate) OR TrainingDate IS NULL)
)

SELECT DISTINCT @sdate AS StartDate
, @edate AS EndDate
,* FROM cteTrainings 
WHERE (IsExempt is null or IsExempt=0)
ORDER BY [TrainingDate], [TopicName]
END
GO
