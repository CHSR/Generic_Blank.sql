SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditHVScreen](@HVScreenPK int=NULL,
@DischargeReason char(2)=NULL,
@DischargeReasonSpecify varchar(500)=NULL,
@FAWFK int=NULL,
@HVCaseFK int=NULL,
@ProgramFK int=NULL,
@ReferralMade char(1)=NULL,
@ReferralSource char(2)=NULL,
@ReferralSourceFK int=NULL,
@ReferralSourceSpecify varchar(500)=NULL,
@Relation2TC char(2)=NULL,
@Relation2TCSpecify varchar(100)=NULL,
@RiskAbortionHistory char(1)=NULL,
@RiskAbortionTry char(1)=NULL,
@RiskAdoption char(1)=NULL,
@RiskDepressionHistory char(1)=NULL,
@RiskEducation char(1)=NULL,
@RiskInadequateSupports char(1)=NULL,
@RiskMaritalProblems char(1)=NULL,
@RiskNoPhone char(1)=NULL,
@RiskNoPrenatalCare char(1)=NULL,
@RiskNotMarried char(1)=NULL,
@RiskPartnerJobless char(1)=NULL,
@RiskPoor char(1)=NULL,
@RiskPsychiatricHistory char(1)=NULL,
@RiskSubstanceAbuseHistory char(1)=NULL,
@RiskUnder21 char(1)=NULL,
@RiskUnstableHousing char(1)=NULL,
@ScreenDate datetime=NULL,
@ScreenEditor char(10)=NULL,
@ScreenerFirstName varchar(200)=NULL,
@ScreenerLastName varchar(200)=NULL,
@ScreenerMiddleInitial char(1)=NULL,
@ScreenerPhone char(12)=NULL,
@ScreenResult char(1)=NULL,
@ScreenVersion char(2)=NULL,
@TargetArea char(1)=NULL,
@TransferredtoProgram varchar(50)=NULL)
AS
UPDATE HVScreen
SET 
DischargeReason = @DischargeReason, 
DischargeReasonSpecify = @DischargeReasonSpecify, 
FAWFK = @FAWFK, 
HVCaseFK = @HVCaseFK, 
ProgramFK = @ProgramFK, 
ReferralMade = @ReferralMade, 
ReferralSource = @ReferralSource, 
ReferralSourceFK = @ReferralSourceFK, 
ReferralSourceSpecify = @ReferralSourceSpecify, 
Relation2TC = @Relation2TC, 
Relation2TCSpecify = @Relation2TCSpecify, 
RiskAbortionHistory = @RiskAbortionHistory, 
RiskAbortionTry = @RiskAbortionTry, 
RiskAdoption = @RiskAdoption, 
RiskDepressionHistory = @RiskDepressionHistory, 
RiskEducation = @RiskEducation, 
RiskInadequateSupports = @RiskInadequateSupports, 
RiskMaritalProblems = @RiskMaritalProblems, 
RiskNoPhone = @RiskNoPhone, 
RiskNoPrenatalCare = @RiskNoPrenatalCare, 
RiskNotMarried = @RiskNotMarried, 
RiskPartnerJobless = @RiskPartnerJobless, 
RiskPoor = @RiskPoor, 
RiskPsychiatricHistory = @RiskPsychiatricHistory, 
RiskSubstanceAbuseHistory = @RiskSubstanceAbuseHistory, 
RiskUnder21 = @RiskUnder21, 
RiskUnstableHousing = @RiskUnstableHousing, 
ScreenDate = @ScreenDate, 
ScreenEditor = @ScreenEditor, 
ScreenerFirstName = @ScreenerFirstName, 
ScreenerLastName = @ScreenerLastName, 
ScreenerMiddleInitial = @ScreenerMiddleInitial, 
ScreenerPhone = @ScreenerPhone, 
ScreenResult = @ScreenResult, 
ScreenVersion = @ScreenVersion, 
TargetArea = @TargetArea, 
TransferredtoProgram = @TransferredtoProgram
WHERE HVScreenPK = @HVScreenPK
GO
