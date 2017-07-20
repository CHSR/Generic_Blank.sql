SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Modified date: 10-2-2012
-- Description:	Gets topics and the associated topic code for Exempt Topics only
-- =============================================
CREATE PROCEDURE [dbo].[spGetTopicsExempt] 
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT DISTINCT codetopicPK, cast([TopicCode] AS VARCHAR(MAX)) + ' ' + [TopicName] AS TopicCodeName FROM codeTopic t
	WHERE SATInterval LIKE '%Wrap-Around%'
END
GO
