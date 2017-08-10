SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddPHQ9](@Appetite char(2)=NULL,
@BadSelf char(2)=NULL,
@BetterOffDead char(2)=NULL,
@Concentration char(2)=NULL,
@Difficulty char(2)=NULL,
@Down char(2)=NULL,
@FormFK int=NULL,
@FormInterval char(2)=NULL,
@FormType char(2)=NULL,
@HVCaseFK int=NULL,
@Interest char(2)=NULL,
@Invalid bit=NULL,
@PHQ9Creator char(10)=NULL,
@Positive bit=NULL,
@ProgramFK int=NULL,
@Sleep char(2)=NULL,
@SlowOrFast char(2)=NULL,
@Tired char(2)=NULL,
@TotalScore int=NULL,
@DateAdministered datetime=NULL,
@DepressionReferralMade bit=NULL,
@ParticipantRefused bit=NULL)
AS
INSERT INTO PHQ9(
Appetite,
BadSelf,
BetterOffDead,
Concentration,
Difficulty,
Down,
FormFK,
FormInterval,
FormType,
HVCaseFK,
Interest,
Invalid,
PHQ9Creator,
Positive,
ProgramFK,
Sleep,
SlowOrFast,
Tired,
TotalScore,
DateAdministered,
DepressionReferralMade,
ParticipantRefused
)
VALUES(
@Appetite,
@BadSelf,
@BetterOffDead,
@Concentration,
@Difficulty,
@Down,
@FormFK,
@FormInterval,
@FormType,
@HVCaseFK,
@Interest,
@Invalid,
@PHQ9Creator,
@Positive,
@ProgramFK,
@Sleep,
@SlowOrFast,
@Tired,
@TotalScore,
@DateAdministered,
@DepressionReferralMade,
@ParticipantRefused
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
