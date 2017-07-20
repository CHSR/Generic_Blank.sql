SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditSubTopic](@SubTopicPK int=NULL,
@ProgramFK int=NULL,
@RequiredBy char(4)=NULL,
@SATFK money=NULL,
@SubTopicCode char(1)=NULL,
@SubTopicEditor char(10)=NULL,
@SubTopicName char(100)=NULL,
@SubTopicPK_old int=NULL,
@TopicFK int=NULL,
@TrainingTickler nchar(3)=NULL)
AS
UPDATE SubTopic
SET 
ProgramFK = @ProgramFK, 
RequiredBy = @RequiredBy, 
SATFK = @SATFK, 
SubTopicCode = @SubTopicCode, 
SubTopicEditor = @SubTopicEditor, 
SubTopicName = @SubTopicName, 
SubTopicPK_old = @SubTopicPK_old, 
TopicFK = @TopicFK, 
TrainingTickler = @TrainingTickler
WHERE SubTopicPK = @SubTopicPK
GO
