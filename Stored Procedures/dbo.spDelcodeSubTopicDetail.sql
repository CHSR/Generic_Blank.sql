SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelcodeSubTopicDetail](@codeSubTopicDetailPK int)

AS


DELETE 
FROM codeSubTopicDetail
WHERE codeSubTopicDetailPK = @codeSubTopicDetailPK
GO
