SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 7/11/2012
-- Description:	Gets Training List by worker for the Training Exemption form
-- =============================================
CREATE PROCEDURE [dbo].[spGetTrainingsbyWorkerFK]
	-- Add the parameters for the stored procedure here
	@WorkerFK AS int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT DISTINCT 
		  tr.[TrainingPK]
		  ,tr.[ProgramFK]
		  ,tr.[TrainingDate]
		  ,tr.[TrainingDays]
		  ,tr.[TrainingDescription]
		  ,tr.[TrainingTitle]
		  ,td.TrainingDetailPK
		  ,td.[CulturalCompetency]
      ,td.[ProgramFK]
      ,td.[SubTopicFK]
      ,td.[SubTopicTime]
      ,td.[TopicFK]
      ,td.[ExemptDescription]
      ,td.[ExemptType]
      ,ta.[TrainingattendeePK]
      , cast([TopicCode] AS VARCHAR(MAX)) + ' ' + cT.TopicName AS 'Topic'
      , cast(st.[SubTopicCode] AS VARCHAR(2)) + ' ' +  st.SubTopicName AS 'SubTopicName'
      , TopicCode
      , st.SubTopicCode
      , t1.TrainingCodeDescription AS 'ExemptTypeName'
	  FROM [dbo].[Trainingattendee] ta
		INNER JOIN Training tr ON tr.TrainingPK=ta.TrainingFK
		INNER JOIN TrainingDetail td ON td.TrainingFK=ta.TrainingFK
		INNER JOIN codeTopic cT ON cT.codeTopicPK = td.TopicFK	
		INNER JOIN codeTraining t1 ON t1.TrainingCode = td.ExemptType
		LEFT JOIN SubTopic st ON st.SubTopicPK = td.SubTopicFK
	  WHERE ta.WorkerFK=@WorkerFK
	  AND tr.IsExempt=1
	  ORDER BY TopicCode, st.SubTopicCode ASC
END
GO
