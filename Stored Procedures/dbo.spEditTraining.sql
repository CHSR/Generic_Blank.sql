SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditTraining](@TrainingPK int=NULL,
@ProgramFK int=NULL,
@TrainerFK int=NULL,
@TrainingMethodFK int=NULL,
@TrainingDate datetime=NULL,
@TrainingDays int=NULL,
@TrainingDescription varchar(500)=NULL,
@TrainingDuration int=NULL,
@TrainingEditor char(10)=NULL,
@TrainingHours int=NULL,
@TrainingMinutes int=NULL,
@TrainingTitle char(70)=NULL,
@IsExempt bit=NULL)
AS
UPDATE Training
SET 
ProgramFK = @ProgramFK, 
TrainerFK = @TrainerFK, 
TrainingMethodFK = @TrainingMethodFK, 
TrainingDate = @TrainingDate, 
TrainingDays = @TrainingDays, 
TrainingDescription = @TrainingDescription, 
TrainingDuration = @TrainingDuration, 
TrainingEditor = @TrainingEditor, 
TrainingHours = @TrainingHours, 
TrainingMinutes = @TrainingMinutes, 
TrainingTitle = @TrainingTitle, 
IsExempt = @IsExempt
WHERE TrainingPK = @TrainingPK
GO
