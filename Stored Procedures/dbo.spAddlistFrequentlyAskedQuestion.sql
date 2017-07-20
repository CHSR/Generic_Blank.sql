SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddlistFrequentlyAskedQuestion](@Category varchar(50)=NULL,
@Question varchar(max)=NULL,
@Answer varchar(max)=NULL,
@CategoryPosition int=NULL,
@QuestionPosition int=NULL)
AS
INSERT INTO listFrequentlyAskedQuestion(
Category,
Question,
Answer,
CategoryPosition,
QuestionPosition
)
VALUES(
@Category,
@Question,
@Answer,
@CategoryPosition,
@QuestionPosition
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
