SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 7/18/2012
-- Edit date: 12/13/12
-- Edited by: Chris Papas
-- Reason: Needed addition data for Training form (used previously in Exempt form only)
-- Description:	Get all workers who participated in a specific training
-- =============================================
CREATE PROCEDURE [dbo].[spGetAllDetailsByTrainingFK]
	-- Add the parameters for the stored procedure here
	@TrainingFK AS INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	SELECT Distinct td.topicfk, subtopicfk, CulturalCompetency, convert(VARCHAR(5),TopicCode) + ' ' + TopicName AS TopicName
	, TopicCode, td.TrainingDetailPK
	, SubTopicCode + '. ' + st.SubTopicName AS SubTopicName, td.ProgramFK
	FROM TrainingDetail td
	INNER JOIN codeTopic t ON codeTopicPK=TopicFK
	LEFT JOIN SubTopic st ON st.SubTopicPK = td.SubTopicFK
	WHERE TrainingFK=@TrainingFK
	ORDER BY td.TopicFK, SubTopicFK

END
GO
