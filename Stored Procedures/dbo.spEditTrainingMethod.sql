SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditTrainingMethod](@TrainingMethodPK int=NULL,
@TrainingCode char(2)=NULL,
@MethodName varchar(75)=NULL,
@ProgramFK int=NULL,
@OldTMethodPK int=NULL)
AS
UPDATE TrainingMethod
SET 
TrainingCode = @TrainingCode, 
MethodName = @MethodName, 
ProgramFK = @ProgramFK, 
OldTMethodPK = @OldTMethodPK
WHERE TrainingMethodPK = @TrainingMethodPK
GO
