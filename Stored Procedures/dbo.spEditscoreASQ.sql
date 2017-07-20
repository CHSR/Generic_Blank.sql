SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditscoreASQ](@scoreASQPK int=NULL,
@ASQVersion varchar(10)=NULL,
@CommunicationScore numeric(4, 2)=NULL,
@FineMotorScore numeric(4, 2)=NULL,
@GrossMotorScore numeric(4, 2)=NULL,
@MaximumASQScore numeric(3, 0)=NULL,
@PersonalScore numeric(4, 2)=NULL,
@ProblemSolvingScore numeric(4, 2)=NULL,
@TCAge char(4)=NULL)
AS
UPDATE scoreASQ
SET 
ASQVersion = @ASQVersion, 
CommunicationScore = @CommunicationScore, 
FineMotorScore = @FineMotorScore, 
GrossMotorScore = @GrossMotorScore, 
MaximumASQScore = @MaximumASQScore, 
PersonalScore = @PersonalScore, 
ProblemSolvingScore = @ProblemSolvingScore, 
TCAge = @TCAge
WHERE scoreASQPK = @scoreASQPK
GO
