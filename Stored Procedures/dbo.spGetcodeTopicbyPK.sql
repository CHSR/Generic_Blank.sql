SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetcodeTopicbyPK]

(@codeTopicPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM codeTopic
WHERE codeTopicPK = @codeTopicPK
GO
