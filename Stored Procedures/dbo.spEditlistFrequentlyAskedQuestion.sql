SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditlistFrequentlyAskedQuestion](@listFrequentlyAskedQuestionPK int=NULL,
@Category varchar(50)=NULL,
@Question varchar(max)=NULL,
@Answer varchar(max)=NULL,
@CategoryPosition int=NULL,
@QuestionPosition int=NULL)
AS
UPDATE listFrequentlyAskedQuestion
SET 
Category = @Category, 
Question = @Question, 
Answer = @Answer, 
CategoryPosition = @CategoryPosition, 
QuestionPosition = @QuestionPosition
WHERE listFrequentlyAskedQuestionPK = @listFrequentlyAskedQuestionPK
GO
