SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create Date: 12-16-2012
-- Description:	Gets the topics that sites are allowed to add subtopics to
-- =============================================
CREATE PROCEDURE [dbo].[spGetEditableTopics] 
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    
	SELECT DISTINCT codetopicPK, cast([TopicCode] AS VARCHAR(MAX)) + ' ' + [TopicName] AS TopicCodeName 
	FROM codeTopic t WHERE [TopicCode] > 13

END
GO
