SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddTraining](@ProgramFK int=NULL,
@TrainerFK int=NULL,
@TrainingMethodFK int=NULL,
@TrainingCreator char(10)=NULL,
@TrainingDate datetime=NULL,
@TrainingDays int=NULL,
@TrainingDescription varchar(500)=NULL,
@TrainingDuration int=NULL,
@TrainingHours int=NULL,
@TrainingMinutes int=NULL,
@TrainingTitle char(70)=NULL,
@IsExempt bit=NULL)
AS
INSERT INTO Training(
ProgramFK,
TrainerFK,
TrainingMethodFK,
TrainingCreator,
TrainingDate,
TrainingDays,
TrainingDescription,
TrainingDuration,
TrainingHours,
TrainingMinutes,
TrainingTitle,
IsExempt
)
VALUES(
@ProgramFK,
@TrainerFK,
@TrainingMethodFK,
@TrainingCreator,
@TrainingDate,
@TrainingDays,
@TrainingDescription,
@TrainingDuration,
@TrainingHours,
@TrainingMinutes,
@TrainingTitle,
@IsExempt
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
