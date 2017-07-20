SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditOtherChild](@OtherChildPK int=NULL,
@BirthTerm char(2)=NULL,
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
@OtherChildEditor char(10)=NULL,
@PregnancyOutcome char(2)=NULL,
@PrenatalCare char(1)=NULL,
@ProgramFK int=NULL,
@Relation2PC1 char(2)=NULL,
@Relation2PC1Specify varchar(500)=NULL)
AS
UPDATE OtherChild
SET 
BirthTerm = @BirthTerm, 
BirthWtLbs = @BirthWtLbs, 
BirthWtOz = @BirthWtOz, 
DOB = @DOB, 
FirstName = @FirstName, 
FormFK = @FormFK, 
FormType = @FormType, 
GestationalWeeks = @GestationalWeeks, 
HVCaseFK = @HVCaseFK, 
LastName = @LastName, 
LivingArrangement = @LivingArrangement, 
LivingArrangementSpecify = @LivingArrangementSpecify, 
MultiBirth = @MultiBirth, 
OtherChildEditor = @OtherChildEditor, 
PregnancyOutcome = @PregnancyOutcome, 
PrenatalCare = @PrenatalCare, 
ProgramFK = @ProgramFK, 
Relation2PC1 = @Relation2PC1, 
Relation2PC1Specify = @Relation2PC1Specify
WHERE OtherChildPK = @OtherChildPK
GO
