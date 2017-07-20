SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditcodeTopic](@codeTopicPK int=NULL,
@TopicName char(150)=NULL,
@TopicCode numeric(4, 1)=NULL,
@TopicPK_old int=NULL,
@SATCompareDateField nvarchar(50)=NULL,
@SATInterval nvarchar(50)=NULL,
@SATName nvarchar(10)=NULL,
@SATReqBy nvarchar(50)=NULL,
@DaysAfter int=NULL)
AS
UPDATE codeTopic
SET 
TopicName = @TopicName, 
TopicCode = @TopicCode, 
TopicPK_old = @TopicPK_old, 
SATCompareDateField = @SATCompareDateField, 
SATInterval = @SATInterval, 
SATName = @SATName, 
SATReqBy = @SATReqBy, 
DaysAfter = @DaysAfter
WHERE codeTopicPK = @codeTopicPK
GO
