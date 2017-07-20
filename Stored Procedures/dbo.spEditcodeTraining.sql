SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditcodeTraining](@codeTrainingPK int=NULL,
@codeTrainingPK_old int=NULL,
@ProgramFK int=NULL,
@TrainingCode char(2)=NULL,
@TrainingCodeDescription char(40)=NULL,
@TrainingCodeGroup char(20)=NULL,
@TrainingCodeUsedWhere varchar(50)=NULL)
AS
UPDATE codeTraining
SET 
codeTrainingPK_old = @codeTrainingPK_old, 
ProgramFK = @ProgramFK, 
TrainingCode = @TrainingCode, 
TrainingCodeDescription = @TrainingCodeDescription, 
TrainingCodeGroup = @TrainingCodeGroup, 
TrainingCodeUsedWhere = @TrainingCodeUsedWhere
WHERE codeTrainingPK = @codeTrainingPK
GO
