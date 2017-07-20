SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelTopicInterval](@TopicIntervalPK int)

AS


DELETE 
FROM TopicInterval
WHERE TopicIntervalPK = @TopicIntervalPK
GO
