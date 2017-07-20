SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddTrainingMethod](@TrainingCode char(2)=NULL,
@MethodName varchar(75)=NULL,
@ProgramFK int=NULL,
@OldTMethodPK int=NULL)
AS
INSERT INTO TrainingMethod(
TrainingCode,
MethodName,
ProgramFK,
OldTMethodPK
)
VALUES(
@TrainingCode,
@MethodName,
@ProgramFK,
@OldTMethodPK
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
