SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditTrainingDetail](@TrainingDetailPK int=NULL,
@CulturalCompetency bit=NULL,
@ProgramFK int=NULL,
@SubTopicFK int=NULL,
@SubTopicTime int=NULL,
@TopicFK int=NULL,
@TrainingDetailEditor char(10)=NULL,
@TrainingDetailPK_old int=NULL,
@TrainingFK int=NULL,
@ExemptDescription varchar(500)=NULL,
@ExemptType varchar(2)=NULL)
AS
UPDATE TrainingDetail
SET 
CulturalCompetency = @CulturalCompetency, 
ProgramFK = @ProgramFK, 
SubTopicFK = @SubTopicFK, 
SubTopicTime = @SubTopicTime, 
TopicFK = @TopicFK, 
TrainingDetailEditor = @TrainingDetailEditor, 
TrainingDetailPK_old = @TrainingDetailPK_old, 
TrainingFK = @TrainingFK, 
ExemptDescription = @ExemptDescription, 
ExemptType = @ExemptType
WHERE TrainingDetailPK = @TrainingDetailPK
GO
