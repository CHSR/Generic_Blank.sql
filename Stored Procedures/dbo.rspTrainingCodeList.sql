SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 5/2/2013
-- Description:	Report: Training Topics by Program
-- EXEC rspTrainingCodeList 1
-- =============================================
CREATE PROCEDURE [dbo].[rspTrainingCodeList]
	-- Add the parameters for the stored procedure here
	@progfk AS INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

     
; WITH cteCodeTopics AS (
	SELECT '1' AS NewOrder, codetopicpk, TopicCode, TopicName, SATName
	, t.SATReqBy, '' AS SubTopicCode, '' AS SubTopicName, '' AS RequiredBy
	FROM codeTopic t
)

, cteSubTopics AS (
	SELECT '2' AS NewOrder,  TopicFK AS codetopicpk, TopicCode, '' AS TopicName, '' AS SATName
	, '' AS SATReqBy,  st.subtopiccode, SubTopicName
	, CASE WHEN RequiredBy = 'SITE' THEN '11-5a     (' + RequiredBy + ')'
	ELSE t.SATName + '   (' + RequiredBy + ')'
	END AS RequiredBy 
	FROM SubTopic st 
	INNER JOIN codeTopic t ON t.codeTopicPK = st.TopicFK
	WHERE (ProgramFK=@progfk OR ProgramFK IS NULL)
)
      
    SELECT * FROM cteCodeTopics
    UNION
    SELECT * FROM cteSubTopics
    ORDER BY TopicCode, NewOrder


END
GO
