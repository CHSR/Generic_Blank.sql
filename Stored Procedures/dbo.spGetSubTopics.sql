SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 8-6-2012
-- Description:	Get all subtopics for a specific TopicFK and Program
-- =============================================
CREATE PROCEDURE [dbo].[spGetSubTopics]-- Add the parameters for the stored procedure here
    @ProgramFK AS INT,
    @topicFK   AS INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here
	SELECT DISTINCT TopicFK, SubTopicPK , [SubTopicCode], [SubTopicName], [SubTopicCode] + '. ' + [SubTopicName] AS 'SubTopicCodeName'
	FROM SubTopic t
	WHERE
		(programfk IS NULL
		OR ProgramFK = @ProgramFK)
		AND topicfk = @topicfk
	ORDER BY SubTopicCode
END
GO
