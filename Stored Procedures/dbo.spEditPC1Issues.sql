SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditPC1Issues](@PC1IssuesPK int=NULL,
@AlcoholAbuse char(1)=NULL,
@CriminalActivity char(1)=NULL,
@Depression char(1)=NULL,
@DevelopmentalDisability char(1)=NULL,
@DomesticViolence char(1)=NULL,
@FinancialDifficulty char(1)=NULL,
@Homeless char(1)=NULL,
@HVCaseFK int=NULL,
@InadequateBasics char(1)=NULL,
@Interval char(2)=NULL,
@MaritalProblems char(1)=NULL,
@MentalIllness char(1)=NULL,
@OtherIssue char(1)=NULL,
@OtherIssueSpecify varchar(500)=NULL,
@OtherLegalProblems char(1)=NULL,
@PC1IssuesDate datetime=NULL,
@PC1IssuesEditor char(10)=NULL,
@PC1IssuesPK_old int=NULL,
@PhysicalDisability char(1)=NULL,
@ProgramFK int=NULL,
@Smoking char(1)=NULL,
@SocialIsolation char(1)=NULL,
@Stress char(1)=NULL,
@SubstanceAbuse char(1)=NULL)
AS
UPDATE PC1Issues
SET 
AlcoholAbuse = @AlcoholAbuse, 
CriminalActivity = @CriminalActivity, 
Depression = @Depression, 
DevelopmentalDisability = @DevelopmentalDisability, 
DomesticViolence = @DomesticViolence, 
FinancialDifficulty = @FinancialDifficulty, 
Homeless = @Homeless, 
HVCaseFK = @HVCaseFK, 
InadequateBasics = @InadequateBasics, 
Interval = @Interval, 
MaritalProblems = @MaritalProblems, 
MentalIllness = @MentalIllness, 
OtherIssue = @OtherIssue, 
OtherIssueSpecify = @OtherIssueSpecify, 
OtherLegalProblems = @OtherLegalProblems, 
PC1IssuesDate = @PC1IssuesDate, 
PC1IssuesEditor = @PC1IssuesEditor, 
PC1IssuesPK_old = @PC1IssuesPK_old, 
PhysicalDisability = @PhysicalDisability, 
ProgramFK = @ProgramFK, 
Smoking = @Smoking, 
SocialIsolation = @SocialIsolation, 
Stress = @Stress, 
SubstanceAbuse = @SubstanceAbuse
WHERE PC1IssuesPK = @PC1IssuesPK
GO
