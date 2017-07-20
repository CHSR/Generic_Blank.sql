SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddTopicInterval](@CompareEventName char(10)=NULL,
@DaysReferrence int=NULL,
@ProgramFK int=NULL,
@RequiredBy char(4)=NULL,
@SATFK int=NULL,
@SubTopicFK int=NULL,
@SubtopicName varchar(150)=NULL,
@TopicFK int=NULL,
@TopicIntervalPK_old int=NULL,
@TopicName varchar(150)=NULL,
@TrainingInterval char(41)=NULL)
AS
INSERT INTO TopicInterval(
CompareEventName,
DaysReferrence,
ProgramFK,
RequiredBy,
SATFK,
SubTopicFK,
SubtopicName,
TopicFK,
TopicIntervalPK_old,
TopicName,
TrainingInterval
)
VALUES(
@CompareEventName,
@DaysReferrence,
@ProgramFK,
@RequiredBy,
@SATFK,
@SubTopicFK,
@SubtopicName,
@TopicFK,
@TopicIntervalPK_old,
@TopicName,
@TrainingInterval
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
