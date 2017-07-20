SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelcodeTopic](@codeTopicPK int)

AS


DELETE 
FROM codeTopic
WHERE codeTopicPK = @codeTopicPK
GO
