SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditCommonAttributes](@CommonAttributesPK int=NULL,
@AvailableMonthlyBenefits numeric(4, 0)=NULL,
@AvailableMonthlyBenefitsUnknown bit=NULL,
@AvailableMonthlyIncome numeric(5, 0)=NULL,
@CommonAttributesEditor char(10)=NULL,
@EducationalEnrollment char(1)=NULL,
@FormDate datetime=NULL,
@FormFK int=NULL,
@FormInterval char(2)=NULL,
@FormType char(8)=NULL,
@Gravida char(2)=NULL,
@HIFamilyChildHealthPlus bit=NULL,
@HighestGrade char(2)=NULL,
@HIMedicaidCaseNumber varchar(20)=NULL,
@HIOther bit=NULL,
@HIOtherSpecify varchar(100)=NULL,
@HIPCAP bit=NULL,
@HIPCAPCaseNumber varchar(20)=NULL,
@HIPrivate bit=NULL,
@HIUninsured bit=NULL,
@HIUnknown bit=NULL,
@HoursPerMonth int=NULL,
@HVCaseFK int=NULL,
@IsCurrentlyEmployed char(1)=NULL,
@LanguageSpecify varchar(100)=NULL,
@LivingArrangement char(2)=NULL,
@LivingArrangementSpecific char(2)=NULL,
@Looked4Employment char(1)=NULL,
@MaritalStatus char(2)=NULL,
@MonthlyIncomeUnknown bit=NULL,
@NumberEmployed int=NULL,
@NumberInHouse int=NULL,
@OBPInHome char(1)=NULL,
@OBPInvolvement char(2)=NULL,
@OBPInvolvementSpecify varchar(500)=NULL,
@Parity char(2)=NULL,
@PBEmergencyAssistance char(1)=NULL,
@PBEmergencyAssistanceAmount numeric(4, 0)=NULL,
@PBFoodStamps char(1)=NULL,
@PBFoodStampsAmount numeric(4, 0)=NULL,
@PBSSI char(1)=NULL,
@PBSSIAmount numeric(4, 0)=NULL,
@PBTANF char(1)=NULL,
@PBTANFAmount numeric(4, 0)=NULL,
@PBWIC char(1)=NULL,
@PBWICAmount numeric(4, 0)=NULL,
@PC1HasMedicalProvider char(1)=NULL,
@PC1MedicalFacilityFK int=NULL,
@PC1MedicalProviderFK int=NULL,
@PC1ReceivingMedicaid char(1)=NULL,
@PCFK int=NULL,
@PreviouslyEmployed char(1)=NULL,
@PrimaryLanguage char(2)=NULL,
@ProgramFK int=NULL,
@ReceivingPreNatalCare char(1)=NULL,
@ReceivingPublicBenefits char(1)=NULL,
@SIDomesticViolence char(1)=NULL,
@SICPSACS char(1)=NULL,
@SIMentalHealth char(1)=NULL,
@SISubstanceAbuse char(1)=NULL,
@TANFServices bit=NULL,
@TANFServicesNo char(2)=NULL,
@TANFServicesNoSpecify varchar(100)=NULL,
@TCHasMedicalProvider char(1)=NULL,
@TCHIFamilyChildHealthPlus bit=NULL,
@TCHIMedicaidCaseNumber varchar(20)=NULL,
@TCHIPrivateInsurance bit=NULL,
@TCHIOther bit=NULL,
@TCHIOtherSpecify varchar(100)=NULL,
@TCHIUninsured bit=NULL,
@TCHIUnknown bit=NULL,
@TCMedicalCareSource char(2)=NULL,
@TCMedicalCareSourceOtherSpecify varchar(100)=NULL,
@TCMedicalFacilityFK int=NULL,
@TCMedicalProviderFK int=NULL,
@TCReceivingMedicaid char(1)=NULL,
@TimeBreastFed char(2)=NULL,
@WasBreastFed bit=NULL,
@WhyNotBreastFed char(2)=NULL)
AS
UPDATE CommonAttributes
SET 
AvailableMonthlyBenefits = @AvailableMonthlyBenefits, 
AvailableMonthlyBenefitsUnknown = @AvailableMonthlyBenefitsUnknown, 
AvailableMonthlyIncome = @AvailableMonthlyIncome, 
CommonAttributesEditor = @CommonAttributesEditor, 
EducationalEnrollment = @EducationalEnrollment, 
FormDate = @FormDate, 
FormFK = @FormFK, 
FormInterval = @FormInterval, 
FormType = @FormType, 
Gravida = @Gravida, 
HIFamilyChildHealthPlus = @HIFamilyChildHealthPlus, 
HighestGrade = @HighestGrade, 
HIMedicaidCaseNumber = @HIMedicaidCaseNumber, 
HIOther = @HIOther, 
HIOtherSpecify = @HIOtherSpecify, 
HIPCAP = @HIPCAP, 
HIPCAPCaseNumber = @HIPCAPCaseNumber, 
HIPrivate = @HIPrivate, 
HIUninsured = @HIUninsured, 
HIUnknown = @HIUnknown, 
HoursPerMonth = @HoursPerMonth, 
HVCaseFK = @HVCaseFK, 
IsCurrentlyEmployed = @IsCurrentlyEmployed, 
LanguageSpecify = @LanguageSpecify, 
LivingArrangement = @LivingArrangement, 
LivingArrangementSpecific = @LivingArrangementSpecific, 
Looked4Employment = @Looked4Employment, 
MaritalStatus = @MaritalStatus, 
MonthlyIncomeUnknown = @MonthlyIncomeUnknown, 
NumberEmployed = @NumberEmployed, 
NumberInHouse = @NumberInHouse, 
OBPInHome = @OBPInHome, 
OBPInvolvement = @OBPInvolvement, 
OBPInvolvementSpecify = @OBPInvolvementSpecify, 
Parity = @Parity, 
PBEmergencyAssistance = @PBEmergencyAssistance, 
PBEmergencyAssistanceAmount = @PBEmergencyAssistanceAmount, 
PBFoodStamps = @PBFoodStamps, 
PBFoodStampsAmount = @PBFoodStampsAmount, 
PBSSI = @PBSSI, 
PBSSIAmount = @PBSSIAmount, 
PBTANF = @PBTANF, 
PBTANFAmount = @PBTANFAmount, 
PBWIC = @PBWIC, 
PBWICAmount = @PBWICAmount, 
PC1HasMedicalProvider = @PC1HasMedicalProvider, 
PC1MedicalFacilityFK = @PC1MedicalFacilityFK, 
PC1MedicalProviderFK = @PC1MedicalProviderFK, 
PC1ReceivingMedicaid = @PC1ReceivingMedicaid, 
PCFK = @PCFK, 
PreviouslyEmployed = @PreviouslyEmployed, 
PrimaryLanguage = @PrimaryLanguage, 
ProgramFK = @ProgramFK, 
ReceivingPreNatalCare = @ReceivingPreNatalCare, 
ReceivingPublicBenefits = @ReceivingPublicBenefits, 
SIDomesticViolence = @SIDomesticViolence, 
SICPSACS = @SICPSACS, 
SIMentalHealth = @SIMentalHealth, 
SISubstanceAbuse = @SISubstanceAbuse, 
TANFServices = @TANFServices, 
TANFServicesNo = @TANFServicesNo, 
TANFServicesNoSpecify = @TANFServicesNoSpecify, 
TCHasMedicalProvider = @TCHasMedicalProvider, 
TCHIFamilyChildHealthPlus = @TCHIFamilyChildHealthPlus, 
TCHIMedicaidCaseNumber = @TCHIMedicaidCaseNumber, 
TCHIPrivateInsurance = @TCHIPrivateInsurance, 
TCHIOther = @TCHIOther, 
TCHIOtherSpecify = @TCHIOtherSpecify, 
TCHIUninsured = @TCHIUninsured, 
TCHIUnknown = @TCHIUnknown, 
TCMedicalCareSource = @TCMedicalCareSource, 
TCMedicalCareSourceOtherSpecify = @TCMedicalCareSourceOtherSpecify, 
TCMedicalFacilityFK = @TCMedicalFacilityFK, 
TCMedicalProviderFK = @TCMedicalProviderFK, 
TCReceivingMedicaid = @TCReceivingMedicaid, 
TimeBreastFed = @TimeBreastFed, 
WasBreastFed = @WasBreastFed, 
WhyNotBreastFed = @WhyNotBreastFed
WHERE CommonAttributesPK = @CommonAttributesPK
GO
