SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditHITS](@HITSPK int=NULL,
@FormFK int=NULL,
@FormInterval char(2)=NULL,
@FormType char(2)=NULL,
@HITSEditor char(10)=NULL,
@Hurt char(2)=NULL,
@HVCaseFK int=NULL,
@Insult char(2)=NULL,
@Invalid bit=NULL,
@NotDoneReason char(2)=NULL,
@Positive bit=NULL,
@ProgramFK int=NULL,
@Scream char(2)=NULL,
@Threaten char(2)=NULL,
@TotalScore int=NULL)
AS
UPDATE HITS
SET 
FormFK = @FormFK, 
FormInterval = @FormInterval, 
FormType = @FormType, 
HITSEditor = @HITSEditor, 
Hurt = @Hurt, 
HVCaseFK = @HVCaseFK, 
Insult = @Insult, 
Invalid = @Invalid, 
NotDoneReason = @NotDoneReason, 
Positive = @Positive, 
ProgramFK = @ProgramFK, 
Scream = @Scream, 
Threaten = @Threaten, 
TotalScore = @TotalScore
WHERE HITSPK = @HITSPK
GO
