SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		hfnymis team
-- Create date: a long, long time ago
-- Description:	Gets all the columns from the CommonAttributes 
--				table given a FormFK and a FormType	
-- exec spGetCommonAttributesbyForm 41004, 'FU'
-- =============================================

CREATE procedure [dbo].[spGetCommonAttributesbyForm]
(
	@FormFK [int]
	, @FormType [char](8)
)
as
	set nocount on;

	select CommonAttributesPK
			, AvailableMonthlyBenefits
			, AvailableMonthlyBenefitsUnknown
			, AvailableMonthlyIncome
			, CommonAttributesCreateDate
			, CommonAttributesCreator
			, CommonAttributesEditDate
			, CommonAttributesEditor
			, EducationalEnrollment
			, FormDate
			, FormFK
			, FormInterval
			, FormType
			, Gravida
			, HIFamilyChildHealthPlus
			, HighestGrade
			, HIMedicaidCaseNumber
			, HIOther
			, HIOtherSpecify
			, HIPCAP
			, HIPCAPCaseNumber
			, HIPrivate
			, HIUninsured
			, HIUnknown
			, HoursPerMonth
			, HVCaseFK
			, IsCurrentlyEmployed
			, LanguageSpecify
			, LivingArrangement
			, LivingArrangementSpecific
			, Looked4Employment
			, MaritalStatus
			, MonthlyIncomeUnknown
			, NumberEmployed
			, NumberInHouse
			, OBPInHome
			, OBPInvolvement
			, OBPInvolvementSpecify
			, Parity
			, PBEmergencyAssistance
			, PBEmergencyAssistanceAmount
			, PBFoodStamps
			, PBFoodStampsAmount
			, PBSSI
			, PBSSIAmount
			, PBTANF
			, PBTANFAmount
			, PBWIC
			, PBWICAmount
			, PC1HasMedicalProvider
			, PC1MedicalFacilityFK
			, PC1MedicalProviderFK
			, PC1ReceivingMedicaid
			, PCFK
			, PreviouslyEmployed
			, PrimaryLanguage
			, ProgramFK
			, ReceivingPreNatalCare
			, ReceivingPublicBenefits
			, SIDomesticViolence
			, SICPSACS
			, SIMentalHealth
			, SISubstanceAbuse
			, TANFServices
			, TANFServicesNo
			, TANFServicesNoSpecify
			, TCHasMedicalProvider
			, TCHIFamilyChildHealthPlus
			, TCHIMedicaidCaseNumber
			, TCHIPrivateInsurance
			, TCHIOther
			, TCHIOtherSpecify
			, TCHIUninsured
			, TCHIUnknown
			, TCMedicalCareSource
			, TCMedicalCareSourceOtherSpecify 
			, TCMedicalFacilityFK
			, TCMedicalProviderFK
			, TCReceivingMedicaid
			, TimeBreastFed
			, WasBreastFed
			, WhyNotBreastFed
	from  CommonAttributes ca
		where FormFK = @FormFK
				and FormType = @FormType

GO
