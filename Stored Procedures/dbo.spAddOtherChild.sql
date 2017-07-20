SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddOtherChild](@BirthTerm char(2)=NULL,
@BirthWtLbs int=NULL,
@BirthWtOz int=NULL,
@DOB datetime=NULL,
@FirstName varchar(200)=NULL,
@FormFK int=NULL,
@FormType char(2)=NULL,
@GestationalWeeks int=NULL,
@HVCaseFK int=NULL,
@LastName varchar(200)=NULL,
@LivingArrangement char(2)=NULL,
@LivingArrangementSpecify char(100)=NULL,
@MultiBirth int=NULL,
@OtherChildCreator char(10)=NULL,
@PregnancyOutcome char(2)=NULL,
@PrenatalCare char(1)=NULL,
@ProgramFK int=NULL,
@Relation2PC1 char(2)=NULL,
@Relation2PC1Specify varchar(500)=NULL)
AS
INSERT INTO OtherChild(
BirthTerm,
BirthWtLbs,
BirthWtOz,
DOB,
FirstName,
FormFK,
FormType,
GestationalWeeks,
HVCaseFK,
LastName,
LivingArrangement,
LivingArrangementSpecify,
MultiBirth,
OtherChildCreator,
PregnancyOutcome,
PrenatalCare,
ProgramFK,
Relation2PC1,
Relation2PC1Specify
)
VALUES(
@BirthTerm,
@BirthWtLbs,
@BirthWtOz,
@DOB,
@FirstName,
@FormFK,
@FormType,
@GestationalWeeks,
@HVCaseFK,
@LastName,
@LivingArrangement,
@LivingArrangementSpecify,
@MultiBirth,
@OtherChildCreator,
@PregnancyOutcome,
@PrenatalCare,
@ProgramFK,
@Relation2PC1,
@Relation2PC1Specify
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
