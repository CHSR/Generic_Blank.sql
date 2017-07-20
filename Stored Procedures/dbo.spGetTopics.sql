SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Crhsi Papas
-- Modified date: 10-2-2012
-- Description:	Gets topics and the associated topic code
-- =============================================
CREATE PROCEDURE [dbo].[spGetTopics] 
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT codetopicPK, cast([TopicCode] AS VARCHAR(MAX)) + ' ' + [TopicName] AS TopicCodeName FROM codeTopic t ORDER BY TopicCode

END
GO
