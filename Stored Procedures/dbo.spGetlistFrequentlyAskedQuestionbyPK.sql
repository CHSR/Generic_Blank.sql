SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetlistFrequentlyAskedQuestionbyPK]

(@listFrequentlyAskedQuestionPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM listFrequentlyAskedQuestion
WHERE listFrequentlyAskedQuestionPK = @listFrequentlyAskedQuestionPK
GO
