SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddcodeTraining](@codeTrainingPK_old int=NULL,
@ProgramFK int=NULL,
@TrainingCode char(2)=NULL,
@TrainingCodeDescription char(40)=NULL,
@TrainingCodeGroup char(20)=NULL,
@TrainingCodeUsedWhere varchar(50)=NULL)
AS
INSERT INTO codeTraining(
codeTrainingPK_old,
ProgramFK,
TrainingCode,
TrainingCodeDescription,
TrainingCodeGroup,
TrainingCodeUsedWhere
)
VALUES(
@codeTrainingPK_old,
@ProgramFK,
@TrainingCode,
@TrainingCodeDescription,
@TrainingCodeGroup,
@TrainingCodeUsedWhere
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
