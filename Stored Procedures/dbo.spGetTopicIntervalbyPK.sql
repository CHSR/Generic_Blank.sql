SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetTopicIntervalbyPK]

(@TopicIntervalPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM TopicInterval
WHERE TopicIntervalPK = @TopicIntervalPK
GO
