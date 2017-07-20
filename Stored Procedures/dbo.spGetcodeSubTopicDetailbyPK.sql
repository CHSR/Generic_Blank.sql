SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetcodeSubTopicDetailbyPK]

(@codeSubTopicDetailPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM codeSubTopicDetail
WHERE codeSubTopicDetailPK = @codeSubTopicDetailPK
GO
