SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDellistFrequentlyAskedQuestion](@listFrequentlyAskedQuestionPK int)

AS


DELETE 
FROM listFrequentlyAskedQuestion
WHERE listFrequentlyAskedQuestionPK = @listFrequentlyAskedQuestionPK
GO
