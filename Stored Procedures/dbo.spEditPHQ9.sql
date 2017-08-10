SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditPHQ9](@PHQ9PK int=NULL,
@Appetite char(2)=NULL,
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
@PHQ9Editor char(10)=NULL,
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
UPDATE PHQ9
SET 
Appetite = @Appetite, 
BadSelf = @BadSelf, 
BetterOffDead = @BetterOffDead, 
Concentration = @Concentration, 
Difficulty = @Difficulty, 
Down = @Down, 
FormFK = @FormFK, 
FormInterval = @FormInterval, 
FormType = @FormType, 
HVCaseFK = @HVCaseFK, 
Interest = @Interest, 
Invalid = @Invalid, 
PHQ9Editor = @PHQ9Editor, 
Positive = @Positive, 
ProgramFK = @ProgramFK, 
Sleep = @Sleep, 
SlowOrFast = @SlowOrFast, 
Tired = @Tired, 
TotalScore = @TotalScore, 
DateAdministered = @DateAdministered, 
DepressionReferralMade = @DepressionReferralMade, 
ParticipantRefused = @ParticipantRefused
WHERE PHQ9PK = @PHQ9PK
GO
