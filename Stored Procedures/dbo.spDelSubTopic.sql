SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelSubTopic](@SubTopicPK int)

AS


DELETE 
FROM SubTopic
WHERE SubTopicPK = @SubTopicPK
GO
