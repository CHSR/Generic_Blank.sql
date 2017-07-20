SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddSubTopic](@ProgramFK int=NULL,
@RequiredBy char(4)=NULL,
@SATFK money=NULL,
@SubTopicCode char(1)=NULL,
@SubTopicCreator char(10)=NULL,
@SubTopicName char(100)=NULL,
@SubTopicPK_old int=NULL,
@TopicFK int=NULL,
@TrainingTickler nchar(3)=NULL)
AS
INSERT INTO SubTopic(
ProgramFK,
RequiredBy,
SATFK,
SubTopicCode,
SubTopicCreator,
SubTopicName,
SubTopicPK_old,
TopicFK,
TrainingTickler
)
VALUES(
@ProgramFK,
@RequiredBy,
@SATFK,
@SubTopicCode,
@SubTopicCreator,
@SubTopicName,
@SubTopicPK_old,
@TopicFK,
@TrainingTickler
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
