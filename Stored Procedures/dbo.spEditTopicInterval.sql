SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditTopicInterval](@TopicIntervalPK int=NULL,
@CompareEventName char(10)=NULL,
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
UPDATE TopicInterval
SET 
CompareEventName = @CompareEventName, 
DaysReferrence = @DaysReferrence, 
ProgramFK = @ProgramFK, 
RequiredBy = @RequiredBy, 
SATFK = @SATFK, 
SubTopicFK = @SubTopicFK, 
SubtopicName = @SubtopicName, 
TopicFK = @TopicFK, 
TopicIntervalPK_old = @TopicIntervalPK_old, 
TopicName = @TopicName, 
TrainingInterval = @TrainingInterval
WHERE TopicIntervalPK = @TopicIntervalPK
GO
