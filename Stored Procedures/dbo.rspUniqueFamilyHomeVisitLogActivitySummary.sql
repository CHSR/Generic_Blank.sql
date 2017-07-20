SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Dar Chen
-- Create date: 04/30/2013
-- Description:	Unique Family Home Visit Log Activity Summary
-- =============================================
CREATE procedure [dbo].[rspUniqueFamilyHomeVisitLogActivitySummary] 
	-- Add the parameters for the stored procedure here
	(@programfk int = null
   , @StartDt datetime
   , @EndDt datetime
   , @workerfk int = null
   , @pc1id varchar(13) = ''
   , @showWorkerDetail char(1) = 'N'
   , @showPC1IDDetail char(1) = 'N'
   , @SiteFK int = null
   , @CaseFiltersPositive varchar(200) = null
	)
as --DECLARE	@programfk INT = 1
--DECLARE @StartDt DATETIME = '04/01/2012'
--DECLARE @EndDt DATETIME = '09/30/2012'
--DECLARE @workerfk INT = NULL
--DECLARE @pc1id VARCHAR(13) = ''
--DECLARE @showWorkerDetail CHAR(1) = 'N'
--DECLARE @showPC1IDDetail CHAR(1) = 'N'

	set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0
						else @SiteFK
					end
	set @CaseFiltersPositive = case	when @CaseFiltersPositive = '' then null
									else @CaseFiltersPositive
							   end;
;
	with	base1
			  as (select	case when @showWorkerDetail = 'N' then 0
								 else a.FSWFK
							end FSWFK
						  , case when @showPC1IDDetail = 'N' then ''
								 else cp.PC1ID
							end PC1ID
						  , x = count(distinct a.HVCaseFK)
						  , CompletedVisit = count(*)
				  from		HVLog as a
				  inner join CaseProgram cp on cp.HVCaseFK = a.HVCaseFK and cp.ProgramFK = @programfk
				  inner join Worker fsw on a.FSWFK = fsw.workerpk
				  inner join WorkerProgram wp on wp.WorkerFK = fsw.WorkerPK and wp.ProgramFK = cp.ProgramFK
				  inner join dbo.udfCaseFilters(@CaseFiltersPositive, '', @ProgramFK) cf on cf.HVCaseFK = cp.HVCaseFK
				  where		cast(VisitStartTime as date) between @StartDt and @EndDt
							and substring(a.VisitType, 4, 1) <> '1'
							and a.FSWFK = isnull(@workerfk, a.FSWFK)
							and cp.PC1ID = case	when @pc1id = '' then cp.PC1ID
												else @pc1id
										   end
							and case when @SiteFK = 0 then 1
									 when wp.SiteFK = @SiteFK then 1
									 else 0
								end = 1
				  group by	case when @showWorkerDetail = 'N' then 0
								 else a.FSWFK
							end
						  , case when @showPC1IDDetail = 'N' then ''
								 else cp.PC1ID
							end
				 ) ,
			base11
			  as (select	FSWFK
						  , PC1ID
						  , CompletedVisit
						  , x [UniqueFamilies]
						  , case when x = 0 then 1
								 else x
							end x
				  from		base1
				 ) ,
			base0
			  as (select	case when @showWorkerDetail = 'N' then 0
								 else a.FSWFK
							end FSWFK
						  , case when @showPC1IDDetail = 'N' then ''
								 else cp.PC1ID
							end PC1ID
						  , AttemptedFamily = count(distinct a.HVCaseFK)
						  , Attempted = count(*)
				  from		HVLog as a
				  inner join CaseProgram cp on cp.HVCaseFK = a.HVCaseFK and cp.ProgramFK = @programfk
				  inner join Worker fsw on a.FSWFK = fsw.workerpk
				  inner join WorkerProgram wp on wp.WorkerFK = fsw.WorkerPK and wp.ProgramFK = cp.ProgramFK
				  inner join dbo.udfCaseFilters(@CaseFiltersPositive, '', @ProgramFK) cf on cf.HVCaseFK = cp.HVCaseFK
				  where		cast(VisitStartTime as date) between @StartDt and @EndDt
							and substring(a.VisitType, 4, 1) = '1'
							and a.FSWFK = isnull(@workerfk, a.FSWFK)
							and cp.PC1ID = case	when @pc1id = '' then cp.PC1ID
												else @pc1id
										   end
							and case when @SiteFK = 0 then 1
									 when wp.SiteFK = @SiteFK then 1
									 else 0
								end = 1
				  group by	case when @showWorkerDetail = 'N' then 0
								 else a.FSWFK
							end
						  , case when @showPC1IDDetail = 'N' then ''
								 else cp.PC1ID
							end
				 ) ,
			base2
			  as (select	FSWFK
						  , PC1ID
						  , avg([AvgMinuteForCompletedVisit]) [AvgMinuteForCompletedVisit]
						  , sum(case when x.[InHome] > 0 then 1
									 else 0
								end) [InHome]
						  , sum(case when x.[OutOfHome] > 0 then 1
									 else 0
								end) [OutOfHome]
						  , sum(case when x.[BothInAndOutHome] > 0 then 1
									 else 0
								end) [BothInAndOutHome]
						  , sum(case when PC1Participated > 0 then 1
									 else 0
								end) [PC1Participated]
						  , sum(case when PC2Participated > 0 then 1
									 else 0
								end) [PC2Participated]
						  , sum(case when OBPParticipated > 0 then 1
									 else 0
								end) [OBPParticipated]
						  , sum(case when FatherFigureParticipated > 0 then 1
									 else 0
								end) [FatherFigureParticipated]
						  , sum(case when FatherAdvocateParticipated > 0 then 1
									 else 0
								end) [FatherAdvocateParticipated]
						  , sum(case when TCParticipated > 0 then 1
									 else 0
								end) [TCParticipated]
						  , sum(case when GrandParentParticipated > 0 then 1
									 else 0
								end) [GrandParentParticipated]
						  , sum(case when SiblingParticipated > 0 then 1
									 else 0
								end) [SiblingParticipated]
						  , sum(case when NonPrimaryFSWParticipated > 0 then 1
									 else 0
								end) [NonPrimaryFSWParticipated]
						  , sum(case when HVSupervisorParticipated > 0 then 1
									 else 0
								end) [HVSupervisorParticipated]
						  , sum(case when SupervisorObservation > 0 then 1
									 else 0
								end) [SupervisorObservation]
						  , sum(case when OtherParticipated > 0 then 1
									 else 0
								end) [OtherParticipated]


-- child development
						  , sum(case when CDChildDevelopment > 0 then 1
									 else 0
								end) [CDChildDevelopment]
						  , sum(case when CDChildDevelopmentNon > 0 then 1
									 else 0
								end) [CDChildDevelopmentNon]
						  , sum(case when CDToys > 0 then 1
									 else 0
								end) [CDToys]
						  , sum(case when CDToysNon > 0 then 1
									 else 0
								end) [CDToysNon]
						  , sum(case when CDOther > 0 then 1
									 else 0
								end) [CDOther]
						  , sum(case when CDOtherNon > 0 then 1
									 else 0
								end) [CDOtherNon]
						  , sum(case when CD1 > 0 then 1
									 else 0
								end) [CD1]
						  , sum(case when CD2 > 0 then 1
									 else 0
								end) [CD2]
-- parent child interaction
						  , sum(case when PCChildInteraction > 0 then 1
									 else 0
								end) [PCChildInteraction]
						  , sum(case when PCChildInteractionNon > 0 then 1
									 else 0
								end) [PCChildInteractionNon]
						  , sum(case when PCChildManagement > 0 then 1
									 else 0
								end) [PCChildManagement]
						  , sum(case when PCChildManagementNon > 0 then 1
									 else 0
								end) [PCChildManagementNon]
						  , sum(case when PCFeelings > 0 then 1
									 else 0
								end) [PCFeelings]
						  , sum(case when PCFeelingsNon > 0 then 1
									 else 0
								end) [PCFeelingsNon]
						  , sum(case when PCStress > 0 then 1
									 else 0
								end) [PCStress]
						  , sum(case when PCStressNon > 0 then 1
									 else 0
								end) [PCStressNon]
						  , sum(case when PCBasicNeeds > 0 then 1
									 else 0
								end) [PCBasicNeeds]
						  , sum(case when PCBasicNeedsNon > 0 then 1
									 else 0
								end) [PCBasicNeedsNon]
						  , sum(case when PCShakenBaby > 0 then 1
									 else 0
								end) [PCShakenBaby]
						  , sum(case when PCShakenBabyNon > 0 then 1
									 else 0
								end) [PCShakenBabyNon]
						  , sum(case when PCShakenBabyVideo > 0 then 1
									 else 0
								end) [PCShakenBabyVideo]
						  , sum(case when PCShakenBabyVideoNon > 0 then 1
									 else 0
								end) [PCShakenBabyVideoNon]
						  , sum(case when PCOther > 0 then 1
									 else 0
								end) [PCOther]
						  , sum(case when PCOtherNon > 0 then 1
									 else 0
								end) [PCOtherNon]
						  , sum(case when PC1 > 0 then 1
									 else 0
								end) [PC1]
						  , sum(case when PC2 > 0 then 1
									 else 0
								end) [PC2]
-- health care
						  , sum(case when HCGeneral > 0 then 1
									 else 0
								end) [HCGeneral]
						  , sum(case when HCGeneralNon > 0 then 1
									 else 0
								end) [HCGeneralNon]
						  , sum(case when HCChild > 0 then 1
									 else 0
								end) [HCChild]
						  , sum(case when HCChildNon > 0 then 1
									 else 0
								end) [HCChildNon]
						  , sum(case when HCDental > 0 then 1
									 else 0
								end) [HCDental]
						  , sum(case when HCDentalNon > 0 then 1
									 else 0
								end) [HCDentalNon]
						  , sum(case when HCFeeding > 0 then 1
									 else 0
								end) [HCFeeding]
						  , sum(case when HCFeedingNon > 0 then 1
									 else 0
								end) [HCFeedingNon]
						  , sum(case when HCBreastFeeding > 0 then 1
									 else 0
								end) [HCBreastFeeding]
						  , sum(case when HCBreastFeedingNon > 0 then 1
									 else 0
								end) [HCBreastFeedingNon]
						  , sum(case when HCNutrition > 0 then 1
									 else 0
								end) [HCNutrition]
						  , sum(case when HCNutritionNon > 0 then 1
									 else 0
								end) [HCNutritionNon]
						  , sum(case when HCFamilyPlanning > 0 then 1
									 else 0
								end) [HCFamilyPlanning]
						  , sum(case when HCFamilyPlanningNon > 0 then 1
									 else 0
								end) [HCFamilyPlanningNon]
						  , sum(case when HCProviders > 0 then 1
									 else 0
								end) [HCProviders]
						  , sum(case when HCProvidersNon > 0 then 1
									 else 0
								end) [HCProvidersNon]
						  , sum(case when HCFASD > 0 then 1
									 else 0
								end) [HCFASD]
						  , sum(case when HCFASDNon > 0 then 1
									 else 0
								end) [HCFASDNon]
						  , sum(case when HCSexEducation > 0 then 1
									 else 0
								end) [HCSexEducation]
						  , sum(case when HCSexEducationNon > 0 then 1
									 else 0
								end) [HCSexEducationNon]
						  , sum(case when HCPrenatalCare > 0 then 1
									 else 0
								end) [HCPrenatalCare]
						  , sum(case when HCPrenatalCareNon > 0 then 1
									 else 0
								end) [HCPrenatalCareNon]
						  , sum(case when HCMedicalAdvocacy > 0 then 1
									 else 0
								end) [HCMedicalAdvocacy]
						  , sum(case when HCMedicalAdvocacyNon > 0 then 1
									 else 0
								end) [HCMedicalAdvocacyNon]
						  , sum(case when HCSafety > 0 then 1
									 else 0
								end) [HCSafety]
						  , sum(case when HCSafetyNon > 0 then 1
									 else 0
								end) [HCSafetyNon]
						  , sum(case when HCSmoking > 0 then 1
									 else 0
								end) [HCSmoking]
						  , sum(case when HCSmokingNon > 0 then 1
									 else 0
								end) [HCSmokingNon]
						  , sum(case when HCSIDS > 0 then 1
									 else 0
								end) [HCSIDS]
						  , sum(case when HCSIDSNon > 0 then 1
									 else 0
								end) [HCSIDSNon]
						  , sum(case when HCOther > 0 then 1
									 else 0
								end) [HCOther]
						  , sum(case when HCOtherNon > 0 then 1
									 else 0
								end) [HCOtherNon]
						  , sum(case when HC1 > 0 then 1
									 else 0
								end) [HC1]
						  , sum(case when HC2 > 0 then 1
									 else 0
								end) [HC2]
-- family functioning
						  , sum(case when FFDomesticViolence > 0 then 1
									 else 0
								end) [FFDomesticViolence]
						  , sum(case when FFDomesticViolenceNon > 0 then 1
									 else 0
								end) [FFDomesticViolenceNon]
						  , sum(case when FFFamilyRelations > 0 then 1
									 else 0
								end) [FFFamilyRelations]
						  , sum(case when FFFamilyRelationsNon > 0 then 1
									 else 0
								end) [FFFamilyRelationsNon]
						  , sum(case when FFSubstanceAbuse > 0 then 1
									 else 0
								end) [FFSubstanceAbuse]
						  , sum(case when FFSubstanceAbuseNon > 0 then 1
									 else 0
								end) [FFSubstanceAbuseNon]
						  , sum(case when FFMentalHealth > 0 then 1
									 else 0
								end) [FFMentalHealth]
						  , sum(case when FFMentalHealthNon > 0 then 1
									 else 0
								end) [FFMentalHealthNon]
						  , sum(case when FFCommunication > 0 then 1
									 else 0
								end) [FFCommunication]
						  , sum(case when FFCommunicationNon > 0 then 1
									 else 0
								end) [FFCommunicationNon]
						  , sum(case when FFOther > 0 then 1
									 else 0
								end) [FFOther]
						  , sum(case when FFOtherNon > 0 then 1
									 else 0
								end) [FFOtherNon]
						  , sum(case when FF1 > 0 then 1
									 else 0
								end) [FF1]
						  , sum(case when FF2 > 0 then 1
									 else 0
								end) [FF2]
-- self sufficiency
						  , sum(case when SSCalendar > 0 then 1
									 else 0
								end) [SSCalendar]
						  , sum(case when SSCalendarNon > 0 then 1
									 else 0
								end) [SSCalendarNon]
						  , sum(case when SSHousekeeping > 0 then 1
									 else 0
								end) [SSHousekeeping]
						  , sum(case when SSHousekeepingNon > 0 then 1
									 else 0
								end) [SSHousekeepingNon]
						  , sum(case when SSTransportation > 0 then 1
									 else 0
								end) [SSTransportation]
						  , sum(case when SSTransportationNon > 0 then 1
									 else 0
								end) [SSTransportationNon]
						  , sum(case when SSEmployment > 0 then 1
									 else 0
								end) [SSEmployment]
						  , sum(case when SSEmploymentNon > 0 then 1
									 else 0
								end) [SSEmploymentNon]
						  , sum(case when SSMoneyManagement > 0 then 1
									 else 0
								end) [SSMoneyManagement]
						  , sum(case when SSMoneyManagementNon > 0 then 1
									 else 0
								end) [SSMoneyManagementNon]
						  , sum(case when SSChildCare > 0 then 1
									 else 0
								end) [SSChildCare]
						  , sum(case when SSChildCareNon > 0 then 1
									 else 0
								end) [SSChildCareNon]
						  , sum(case when SSProblemSolving > 0 then 1
									 else 0
								end) [SSProblemSolving]
						  , sum(case when SSProblemSolvingNon > 0 then 1
									 else 0
								end) [SSProblemSolvingNon]
						  , sum(case when SSEducation > 0 then 1
									 else 0
								end) [SSEducation]
						  , sum(case when SSEducationNon > 0 then 1
									 else 0
								end) [SSEducationNon]
						  , sum(case when SSJob > 0 then 1
									 else 0
								end) [SSJob]
						  , sum(case when SSJobNon > 0 then 1
									 else 0
								end) [SSJobNon]
						  , sum(case when SSOther > 0 then 1
									 else 0
								end) [SSOther]
						  , sum(case when SSOtherNon > 0 then 1
									 else 0
								end) [SSOtherNon]
						  , sum(case when SS1 > 0 then 1
									 else 0
								end) [SS1]
						  , sum(case when SS2 > 0 then 1
									 else 0
								end) [SS2]
-- crisis intervention
						  , sum(case when CIProblems > 0 then 1
									 else 0
								end) [CIProblems]
						  , sum(case when CIProblemsNon > 0 then 1
									 else 0
								end) [CIProblemsNon]
						  , sum(case when CIOther > 0 then 1
									 else 0
								end) [CIOther]
						  , sum(case when CIOtherNon > 0 then 1
									 else 0
								end) [CIOtherNon]
						  , sum(case when CI1 > 0 then 1
									 else 0
								end) [CI1]
						  , sum(case when CI2 > 0 then 1
									 else 0
								end) [CI2]
-- program activities
						  , sum(case when PAForms > 0 then 1
									 else 0
								end) [PAForms]
						  , sum(case when PAFormsNon > 0 then 1
									 else 0
								end) [PAFormsNon]
						  , sum(case when PAVideo > 0 then 1
									 else 0
								end) [PAVideo]
						  , sum(case when PAVideoNon > 0 then 1
									 else 0
								end) [PAVideoNon]
						  , sum(case when PAGroups > 0 then 1
									 else 0
								end) [PAGroups]
						  , sum(case when PAGroupsNon > 0 then 1
									 else 0
								end) [PAGroupsNon]
						  , sum(case when PAIFSP > 0 then 1
									 else 0
								end) [PAIFSP]
						  , sum(case when PAIFSPNon > 0 then 1
									 else 0
								end) [PAIFSPNon]
						  , sum(case when PARecreation > 0 then 1
									 else 0
								end) [PARecreation]
						  , sum(case when PARecreationNon > 0 then 1
									 else 0
								end) [PARecreationNon]
						  , sum(case when PAOther > 0 then 1
									 else 0
								end) [PAOther]
						  , sum(case when PAOtherNon > 0 then 1
									 else 0
								end) [PAOtherNon]
						  , sum(case when PA1 > 0 then 1
									 else 0
								end) [PA1]
						  , sum(case when PA2 > 0 then 1
									 else 0
								end) [PA2]
-- concrete activities
						  , sum(case when CATransportation > 0 then 1
									 else 0
								end) [CATransportation]
						  , sum(case when CATransportationNon > 0 then 1
									 else 0
								end) [CATransportationNon]
						  , sum(case when CAGoods > 0 then 1
									 else 0
								end) [CAGoods]
						  , sum(case when CAGoodsNon > 0 then 1
									 else 0
								end) [CAGoodsNon]
						  , sum(case when CALegal > 0 then 1
									 else 0
								end) [CALegal]
						  , sum(case when CALegalNon > 0 then 1
									 else 0
								end) [CALegalNon]
						  , sum(case when CAHousing > 0 then 1
									 else 0
								end) [CAHousing]
						  , sum(case when CAHousingNon > 0 then 1
									 else 0
								end) [CAHousingNon]
						  , sum(case when CAAdvocacy > 0 then 1
									 else 0
								end) [CAAdvocacy]
						  , sum(case when CAAdvocacyNon > 0 then 1
									 else 0
								end) [CAAdvocacyNon]
						  , sum(case when CATranslation > 0 then 1
									 else 0
								end) [CATranslation]
						  , sum(case when CATranslationNon > 0 then 1
									 else 0
								end) [CATranslationNon]
						  , sum(case when CALaborSupport > 0 then 1
									 else 0
								end) [CALaborSupport]
						  , sum(case when CALaborSupportNon > 0 then 1
									 else 0
								end) [CALaborSupportNon]
						  , sum(case when CAChildSupport > 0 then 1
									 else 0
								end) [CAChildSupport]
						  , sum(case when CAChildSupportNon > 0 then 1
									 else 0
								end) [CAChildSupportNon]
						  , sum(case when CAParentRights > 0 then 1
									 else 0
								end) [CAParentRights]
						  , sum(case when CAParentRightsNon > 0 then 1
									 else 0
								end) [CAParentRightsNon]
						  , sum(case when CAVisitation > 0 then 1
									 else 0
								end) [CAVisitation]
						  , sum(case when CAVisitationNon > 0 then 1
									 else 0
								end) [CAVisitationNon]
						  , sum(case when CAOther > 0 then 1
									 else 0
								end) [CAOther]
						  , sum(case when CAOtherNon > 0 then 1
									 else 0
								end) [CAOtherNon]
						  , sum(case when CA1 > 0 then 1
									 else 0
								end) [CA1]
						  , sum(case when CA2 > 0 then 1
									 else 0
								end) [CA2]
						  , sum([Total]) [Total]
				  from		(select	a.HVCaseFK
								  , case when @showWorkerDetail = 'N' then 0
										 else a.FSWFK
									end [FSWFK]
								  , case when @showPC1IDDetail = 'N' then ''
										 else cp.PC1ID
									end [PC1ID]
								  , avg(a.VisitLengthHour * 60 + a.VisitLengthMinute) [AvgMinuteForCompletedVisit]
								  , sum(case when substring(a.VisitType, 1, 3) in ('100', '110', '010') then 1
											 else 0
										end) [InHome]
								  , sum(case when substring(a.VisitType, 1, 3) = '001' then 1
											 else 0
										end) [OutOfHome]
								  , sum(case when substring(a.VisitType, 1, 3) in ('101', '111', '011') then 1
											 else 0
										end) [BothInAndOutHome]
								  , sum(case when PC1Participated = 1 then 1
											 else 0
										end) [PC1Participated]
								  , sum(case when PC2Participated = 1 then 1
											 else 0
										end) [PC2Participated]
								  , sum(case when OBPParticipated = 1 then 1
											 else 0
										end) [OBPParticipated]
								  , sum(case when FatherFigureParticipated = 1 then 1
											 else 0
										end) [FatherFigureParticipated]
								  , sum(case when FatherAdvocateParticipated = 1 then 1
											 else 0
										end) [FatherAdvocateParticipated]
								  , sum(case when TCParticipated = 1 then 1
											 else 0
										end) [TCParticipated]
								  , sum(case when GrandParentParticipated = 1 then 1
											 else 0
										end) [GrandParentParticipated]
								  , sum(case when SiblingParticipated = 1 then 1
											 else 0
										end) [SiblingParticipated]
								  , sum(case when NonPrimaryFSWParticipated = 1 then 1
											 else 0
										end) [NonPrimaryFSWParticipated]
								  , sum(case when HVSupervisorParticipated = 1 then 1
											 else 0
										end) [HVSupervisorParticipated]
								  , sum(case when SupervisorObservation = 1 then 1
											 else 0
										end) [SupervisorObservation]
								  , sum(case when OtherParticipated = 1 then 1
											 else 0
										end) [OtherParticipated]
-- child development
								  , sum(case when substring(CDChildDevelopment, 1, 1) = '1' then 1
											 else 0
										end) [CDChildDevelopment]
								  , sum(case when substring(CDChildDevelopment, 2, 1) = '1' then 1
											 else 0
										end) [CDChildDevelopmentNon]
								  , sum(case when substring(CDToys, 1, 1) = '1' then 1
											 else 0
										end) [CDToys]
								  , sum(case when substring(CDToys, 2, 1) = '1' then 1
											 else 0
										end) [CDToysNon]
								  , sum(case when substring(CDOther, 1, 1) = '1' then 1
											 else 0
										end) [CDOther]
								  , sum(case when substring(CDOther, 2, 1) = '1' then 1
											 else 0
										end) [CDOtherNon]
								  , sum(case when substring(CDChildDevelopment, 1, 1) = '1'
												  or substring(CDToys, 1, 1) = '1'
												  or substring(CDOther, 1, 1) = '1' then 1
											 else 0
										end) [CD1]
								  , sum(case when substring(CDChildDevelopment, 2, 1) = '1'
												  or substring(CDToys, 2, 1) = '1'
												  or substring(CDOther, 2, 1) = '1' then 1
											 else 0
										end) [CD2]
-- parent child interaction
								  , sum(case when substring(PCChildInteraction, 1, 1) = '1' then 1
											 else 0
										end) [PCChildInteraction]
								  , sum(case when substring(PCChildInteraction, 2, 1) = '1' then 1
											 else 0
										end) [PCChildInteractionNon]
								  , sum(case when substring(PCChildManagement, 1, 1) = '1' then 1
											 else 0
										end) [PCChildManagement]
								  , sum(case when substring(PCChildManagement, 2, 1) = '1' then 1
											 else 0
										end) [PCChildManagementNon]
								  , sum(case when substring(PCFeelings, 1, 1) = '1' then 1
											 else 0
										end) [PCFeelings]
								  , sum(case when substring(PCFeelings, 2, 1) = '1' then 1
											 else 0
										end) [PCFeelingsNon]
								  , sum(case when substring(PCStress, 1, 1) = '1' then 1
											 else 0
										end) [PCStress]
								  , sum(case when substring(PCStress, 2, 1) = '1' then 1
											 else 0
										end) [PCStressNon]
								  , sum(case when substring(PCBasicNeeds, 1, 1) = '1' then 1
											 else 0
										end) [PCBasicNeeds]
								  , sum(case when substring(PCBasicNeeds, 2, 1) = '1' then 1
											 else 0
										end) [PCBasicNeedsNon]
								  , sum(case when substring(PCShakenBaby, 1, 1) = '1' then 1
											 else 0
										end) [PCShakenBaby]
								  , sum(case when substring(PCShakenBaby, 2, 1) = '1' then 1
											 else 0
										end) [PCShakenBabyNon]
								  , sum(case when substring(PCShakenBabyVideo, 1, 1) = '1' then 1
											 else 0
										end) [PCShakenBabyVideo]
								  , sum(case when substring(PCShakenBabyVideo, 2, 1) = '1' then 1
											 else 0
										end) [PCShakenBabyVideoNon]
								  , sum(case when substring(PCOther, 1, 1) = '1' then 1
											 else 0
										end) [PCOther]
								  , sum(case when substring(PCOther, 2, 1) = '1' then 1
											 else 0
										end) [PCOtherNon]
								  , sum(case when substring(PCChildInteraction, 1, 1) = '1'
												  or substring(PCChildManagement, 1, 1) = '1'
												  or substring(PCFeelings, 1, 1) = '1'
												  or substring(PCStress, 1, 1) = '1'
												  or substring(PCBasicNeeds, 1, 1) = '1'
												  or substring(PCShakenBaby, 1, 1) = '1'
												  or substring(PCShakenBabyVideo, 1, 1) = '1'
												  or substring(PCOther, 1, 1) = '1' then 1
											 else 0
										end) [PC1]
								  , sum(case when substring(PCChildInteraction, 2, 1) = '1'
												  or substring(PCChildManagement, 2, 1) = '1'
												  or substring(PCFeelings, 2, 1) = '1'
												  or substring(PCStress, 2, 1) = '1'
												  or substring(PCBasicNeeds, 2, 1) = '1'
												  or substring(PCShakenBaby, 2, 1) = '1'
												  or substring(PCShakenBabyVideo, 2, 1) = '1'
												  or substring(PCOther, 2, 1) = '1' then 1
											 else 0
										end) [PC2]
-- health care
								  , sum(case when substring(HCGeneral, 1, 1) = '1' then 1
											 else 0
										end) [HCGeneral]
								  , sum(case when substring(HCGeneral, 2, 1) = '1' then 1
											 else 0
										end) [HCGeneralNon]
								  , sum(case when substring(HCChild, 1, 1) = '1' then 1
											 else 0
										end) [HCChild]
								  , sum(case when substring(HCChild, 2, 1) = '1' then 1
											 else 0
										end) [HCChildNon]
								  , sum(case when substring(HCDental, 1, 1) = '1' then 1
											 else 0
										end) [HCDental]
								  , sum(case when substring(HCDental, 2, 1) = '1' then 1
											 else 0
										end) [HCDentalNon]
								  , sum(case when substring(HCFeeding, 1, 1) = '1' then 1
											 else 0
										end) [HCFeeding]
								  , sum(case when substring(HCFeeding, 2, 1) = '1' then 1
											 else 0
										end) [HCFeedingNon]
								  , sum(case when substring(HCBreastFeeding, 1, 1) = '1' then 1
											 else 0
										end) [HCBreastFeeding]
								  , sum(case when substring(HCBreastFeeding, 2, 1) = '1' then 1
											 else 0
										end) [HCBreastFeedingNon]
								  , sum(case when substring(HCNutrition, 1, 1) = '1' then 1
											 else 0
										end) [HCNutrition]
								  , sum(case when substring(HCNutrition, 2, 1) = '1' then 1
											 else 0
										end) [HCNutritionNon]
								  , sum(case when substring(HCFamilyPlanning, 1, 1) = '1' then 1
											 else 0
										end) [HCFamilyPlanning]
								  , sum(case when substring(HCFamilyPlanning, 2, 1) = '1' then 1
											 else 0
										end) [HCFamilyPlanningNon]
								  , sum(case when substring(HCProviders, 1, 1) = '1' then 1
											 else 0
										end) [HCProviders]
								  , sum(case when substring(HCProviders, 2, 1) = '1' then 1
											 else 0
										end) [HCProvidersNon]
								  , sum(case when substring(HCFASD, 1, 1) = '1' then 1
											 else 0
										end) [HCFASD]
								  , sum(case when substring(HCFASD, 2, 1) = '1' then 1
											 else 0
										end) [HCFASDNon]
								  , sum(case when substring(HCSexEducation, 1, 1) = '1' then 1
											 else 0
										end) [HCSexEducation]
								  , sum(case when substring(HCSexEducation, 2, 1) = '1' then 1
											 else 0
										end) [HCSexEducationNon]
								  , sum(case when substring(HCPrenatalCare, 1, 1) = '1' then 1
											 else 0
										end) [HCPrenatalCare]
								  , sum(case when substring(HCPrenatalCare, 2, 1) = '1' then 1
											 else 0
										end) [HCPrenatalCareNon]
								  , sum(case when substring(HCMedicalAdvocacy, 1, 1) = '1' then 1
											 else 0
										end) [HCMedicalAdvocacy]
								  , sum(case when substring(HCMedicalAdvocacy, 2, 1) = '1' then 1
											 else 0
										end) [HCMedicalAdvocacyNon]
								  , sum(case when substring(HCSafety, 1, 1) = '1' then 1
											 else 0
										end) [HCSafety]
								  , sum(case when substring(HCSafety, 2, 1) = '1' then 1
											 else 0
										end) [HCSafetyNon]
								  , sum(case when substring(HCSmoking, 1, 1) = '1' then 1
											 else 0
										end) [HCSmoking]
								  , sum(case when substring(HCSmoking, 2, 1) = '1' then 1
											 else 0
										end) [HCSmokingNon]
								  , sum(case when substring(HCSIDS, 1, 1) = '1' then 1
											 else 0
										end) [HCSIDS]
								  , sum(case when substring(HCSIDS, 2, 1) = '1' then 1
											 else 0
										end) [HCSIDSNon]
								  , sum(case when substring(HCOther, 1, 1) = '1' then 1
											 else 0
										end) [HCOther]
								  , sum(case when substring(HCOther, 2, 1) = '1' then 1
											 else 0
										end) [HCOtherNon]
								  , sum(case when substring(HCGeneral, 1, 1) = '1'
												  or substring(HCChild, 1, 1) = '1'
												  or substring(HCDental, 1, 1) = '1'
												  or substring(HCFeeding, 1, 1) = '1'
												  or substring(HCBreastFeeding, 1, 1) = '1'
												  or substring(HCNutrition, 1, 1) = '1'
												  or substring(HCFamilyPlanning, 1, 1) = '1'
												  or substring(HCProviders, 1, 1) = '1'
												  or substring(HCFASD, 1, 1) = '1'
												  or substring(HCSexEducation, 1, 1) = '1'
												  or substring(HCPrenatalCare, 1, 1) = '1'
												  or substring(HCMedicalAdvocacy, 1, 1) = '1'
												  or substring(HCSafety, 1, 1) = '1'
												  or substring(HCSmoking, 1, 1) = '1'
												  or substring(HCSIDS, 1, 1) = '1'
												  or substring(HCOther, 1, 1) = '1' then 1
											 else 0
										end) [HC1]
								  , sum(case when substring(HCGeneral, 2, 1) = '1'
												  or substring(HCChild, 2, 1) = '1'
												  or substring(HCDental, 2, 1) = '1'
												  or substring(HCFeeding, 2, 1) = '1'
												  or substring(HCBreastFeeding, 2, 1) = '1'
												  or substring(HCNutrition, 2, 1) = '1'
												  or substring(HCFamilyPlanning, 2, 1) = '1'
												  or substring(HCProviders, 2, 1) = '1'
												  or substring(HCFASD, 2, 1) = '1'
												  or substring(HCSexEducation, 2, 1) = '1'
												  or substring(HCPrenatalCare, 2, 1) = '1'
												  or substring(HCMedicalAdvocacy, 2, 1) = '1'
												  or substring(HCSafety, 2, 1) = '1'
												  or substring(HCSmoking, 2, 1) = '1'
												  or substring(HCSIDS, 2, 1) = '1'
												  or substring(HCOther, 2, 1) = '1' then 1
											 else 0
										end) [HC2]
-- family funvtioning
								  , sum(case when substring(FFDomesticViolence, 1, 1) = '1' then 1
											 else 0
										end) [FFDomesticViolence]
								  , sum(case when substring(FFDomesticViolence, 2, 1) = '1' then 1
											 else 0
										end) [FFDomesticViolenceNon]
								  , sum(case when substring(FFFamilyRelations, 1, 1) = '1' then 1
											 else 0
										end) [FFFamilyRelations]
								  , sum(case when substring(FFFamilyRelations, 2, 1) = '1' then 1
											 else 0
										end) [FFFamilyRelationsNon]
								  , sum(case when substring(FFSubstanceAbuse, 1, 1) = '1' then 1
											 else 0
										end) [FFSubstanceAbuse]
								  , sum(case when substring(FFSubstanceAbuse, 2, 1) = '1' then 1
											 else 0
										end) [FFSubstanceAbuseNon]
								  , sum(case when substring(FFMentalHealth, 1, 1) = '1' then 1
											 else 0
										end) [FFMentalHealth]
								  , sum(case when substring(FFMentalHealth, 2, 1) = '1' then 1
											 else 0
										end) [FFMentalHealthNon]
								  , sum(case when substring(FFCommunication, 1, 1) = '1' then 1
											 else 0
										end) [FFCommunication]
								  , sum(case when substring(FFCommunication, 2, 1) = '1' then 1
											 else 0
										end) [FFCommunicationNon]
								  , sum(case when substring(FFOther, 1, 1) = '1' then 1
											 else 0
										end) [FFOther]
								  , sum(case when substring(FFOther, 2, 1) = '1' then 1
											 else 0
										end) [FFOtherNon]
								  , sum(case when substring(FFDomesticViolence, 1, 1) = '1'
												  or substring(FFFamilyRelations, 1, 1) = '1'
												  or substring(FFSubstanceAbuse, 1, 1) = '1'
												  or substring(FFMentalHealth, 1, 1) = '1'
												  or substring(FFCommunication, 1, 1) = '1'
												  or substring(FFOther, 1, 1) = '1' then 1
											 else 0
										end) [FF1]
								  , sum(case when substring(FFDomesticViolence, 2, 1) = '1'
												  or substring(FFFamilyRelations, 2, 1) = '1'
												  or substring(FFSubstanceAbuse, 2, 1) = '1'
												  or substring(FFMentalHealth, 2, 1) = '1'
												  or substring(FFCommunication, 2, 1) = '1'
												  or substring(FFOther, 2, 1) = '1' then 1
											 else 0
										end) [FF2]
-- self sufficiency
								  , sum(case when substring(SSCalendar, 1, 1) = '1' then 1
											 else 0
										end) [SSCalendar]
								  , sum(case when substring(SSCalendar, 2, 1) = '1' then 1
											 else 0
										end) [SSCalendarNon]
								  , sum(case when substring(SSHousekeeping, 1, 1) = '1' then 1
											 else 0
										end) [SSHousekeeping]
								  , sum(case when substring(SSHousekeeping, 2, 1) = '1' then 1
											 else 0
										end) [SSHousekeepingNon]
								  , sum(case when substring(SSTransportation, 1, 1) = '1' then 1
											 else 0
										end) [SSTransportation]
								  , sum(case when substring(SSTransportation, 2, 1) = '1' then 1
											 else 0
										end) [SSTransportationNon]
								  , sum(case when substring(SSEmployment, 1, 1) = '1' then 1
											 else 0
										end) [SSEmployment]
								  , sum(case when substring(SSEmployment, 2, 1) = '1' then 1
											 else 0
										end) [SSEmploymentNon]
								  , sum(case when substring(SSMoneyManagement, 1, 1) = '1' then 1
											 else 0
										end) [SSMoneyManagement]
								  , sum(case when substring(SSMoneyManagement, 2, 1) = '1' then 1
											 else 0
										end) [SSMoneyManagementNon]
								  , sum(case when substring(SSChildCare, 1, 1) = '1' then 1
											 else 0
										end) [SSChildCare]
								  , sum(case when substring(SSChildCare, 2, 1) = '1' then 1
											 else 0
										end) [SSChildCareNon]
								  , sum(case when substring(SSProblemSolving, 1, 1) = '1' then 1
											 else 0
										end) [SSProblemSolving]
								  , sum(case when substring(SSProblemSolving, 2, 1) = '1' then 1
											 else 0
										end) [SSProblemSolvingNon]
								  , sum(case when substring(SSEducation, 1, 1) = '1' then 1
											 else 0
										end) [SSEducation]
								  , sum(case when substring(SSEducation, 2, 1) = '1' then 1
											 else 0
										end) [SSEducationNon]
								  , sum(case when substring(SSJob, 1, 1) = '1' then 1
											 else 0
										end) [SSJob]
								  , sum(case when substring(SSJob, 2, 1) = '1' then 1
											 else 0
										end) [SSJobNon]
								  , sum(case when substring(SSOther, 1, 1) = '1' then 1
											 else 0
										end) [SSOther]
								  , sum(case when substring(SSOther, 2, 1) = '1' then 1
											 else 0
										end) [SSOtherNon]
								  , sum(case when substring(SSCalendar, 1, 1) = '1'
												  or substring(SSHousekeeping, 1, 1) = '1'
												  or substring(SSTransportation, 1, 1) = '1'
												  or substring(SSEmployment, 1, 1) = '1'
												  or substring(SSMoneyManagement, 1, 1) = '1'
												  or substring(SSChildCare, 1, 1) = '1'
												  or substring(SSProblemSolving, 1, 1) = '1'
												  or substring(SSEducation, 1, 1) = '1'
												  or substring(SSJob, 1, 1) = '1'
												  or substring(SSOther, 1, 1) = '1' then 1
											 else 0
										end) [SS1]
								  , sum(case when substring(SSCalendar, 2, 1) = '1'
												  or substring(SSHousekeeping, 2, 1) = '1'
												  or substring(SSTransportation, 2, 1) = '1'
												  or substring(SSEmployment, 2, 1) = '1'
												  or substring(SSMoneyManagement, 2, 1) = '1'
												  or substring(SSChildCare, 2, 1) = '1'
												  or substring(SSProblemSolving, 2, 1) = '1'
												  or substring(SSEducation, 2, 1) = '1'
												  or substring(SSJob, 2, 1) = '1'
												  or substring(SSOther, 2, 1) = '1' then 1
											 else 0
										end) [SS2]
-- crisis intervention
								  , sum(case when substring(CIProblems, 1, 1) = '1' then 1
											 else 0
										end) [CIProblems]
								  , sum(case when substring(CIProblems, 2, 1) = '1' then 1
											 else 0
										end) [CIProblemsNon]
								  , sum(case when substring(CIOther, 1, 1) = '1' then 1
											 else 0
										end) [CIOther]
								  , sum(case when substring(CIOther, 2, 1) = '1' then 1
											 else 0
										end) [CIOtherNon]
								  , sum(case when substring(CIProblems, 1, 1) = '1'
												  or substring(CIOther, 1, 1) = '1' then 1
											 else 0
										end) [CI1]
								  , sum(case when substring(CIProblems, 2, 1) = '1'
												  or substring(CIOther, 2, 1) = '1' then 1
											 else 0
										end) [CI2]
-- program activities
								  , sum(case when substring(PAForms, 1, 1) = '1' then 1
											 else 0
										end) [PAForms]
								  , sum(case when substring(PAForms, 2, 1) = '1' then 1
											 else 0
										end) [PAFormsNon]
								  , sum(case when substring(PAVideo, 1, 1) = '1' then 1
											 else 0
										end) [PAVideo]
								  , sum(case when substring(PAVideo, 2, 1) = '1' then 1
											 else 0
										end) [PAVideoNon]
								  , sum(case when substring(PAGroups, 1, 1) = '1' then 1
											 else 0
										end) [PAGroups]
								  , sum(case when substring(PAGroups, 2, 1) = '1' then 1
											 else 0
										end) [PAGroupsNon]
								  , sum(case when substring(PAIFSP, 1, 1) = '1' then 1
											 else 0
										end) [PAIFSP]
								  , sum(case when substring(PAIFSP, 2, 1) = '1' then 1
											 else 0
										end) [PAIFSPNon]
								  , sum(case when substring(PARecreation, 1, 1) = '1' then 1
											 else 0
										end) [PARecreation]
								  , sum(case when substring(PARecreation, 2, 1) = '1' then 1
											 else 0
										end) [PARecreationNon]
								  , sum(case when substring(PAOther, 1, 1) = '1' then 1
											 else 0
										end) [PAOther]
								  , sum(case when substring(PAOther, 2, 1) = '1' then 1
											 else 0
										end) [PAOtherNon]
								  , sum(case when substring(PAForms, 1, 1) = '1'
												  or substring(PAVideo, 1, 1) = '1'
												  or substring(PAGroups, 1, 1) = '1'
												  or substring(PAIFSP, 1, 1) = '1'
												  or substring(PARecreation, 1, 1) = '1'
												  or substring(PAOther, 1, 1) = '1' then 1
											 else 0
										end) [PA1]
								  , sum(case when substring(PAForms, 2, 1) = '1'
												  or substring(PAVideo, 2, 1) = '1'
												  or substring(PAGroups, 2, 1) = '1'
												  or substring(PAIFSP, 2, 1) = '1'
												  or substring(PARecreation, 2, 1) = '1'
												  or substring(PAOther, 2, 1) = '1' then 1
											 else 0
										end) [PA2]
-- concrete activities
								  , sum(case when substring(CATransportation, 1, 1) = '1' then 1
											 else 0
										end) [CATransportation]
								  , sum(case when substring(CATransportation, 2, 1) = '1' then 1
											 else 0
										end) [CATransportationNon]
								  , sum(case when substring(CAGoods, 1, 1) = '1' then 1
											 else 0
										end) [CAGoods]
								  , sum(case when substring(CAGoods, 2, 1) = '1' then 1
											 else 0
										end) [CAGoodsNon]
								  , sum(case when substring(CALegal, 1, 1) = '1' then 1
											 else 0
										end) [CALegal]
								  , sum(case when substring(CALegal, 2, 1) = '1' then 1
											 else 0
										end) [CALegalNon]
								  , sum(case when substring(CAHousing, 1, 1) = '1' then 1
											 else 0
										end) [CAHousing]
								  , sum(case when substring(CAHousing, 2, 1) = '1' then 1
											 else 0
										end) [CAHousingNon]
								  , sum(case when substring(CAAdvocacy, 1, 1) = '1' then 1
											 else 0
										end) [CAAdvocacy]
								  , sum(case when substring(CAAdvocacy, 2, 1) = '1' then 1
											 else 0
										end) [CAAdvocacyNon]
								  , sum(case when substring(CATranslation, 1, 1) = '1' then 1
											 else 0
										end) [CATranslation]
								  , sum(case when substring(CATranslation, 2, 1) = '1' then 1
											 else 0
										end) [CATranslationNon]
								  , sum(case when substring(CALaborSupport, 1, 1) = '1' then 1
											 else 0
										end) [CALaborSupport]
								  , sum(case when substring(CALaborSupport, 2, 1) = '1' then 1
											 else 0
										end) [CALaborSupportNon]
								  , sum(case when substring(CAChildSupport, 1, 1) = '1' then 1
											 else 0
										end) [CAChildSupport]
								  , sum(case when substring(CAChildSupport, 2, 1) = '1' then 1
											 else 0
										end) [CAChildSupportNon]
								  , sum(case when substring(CAParentRights, 1, 1) = '1' then 1
											 else 0
										end) [CAParentRights]
								  , sum(case when substring(CAParentRights, 2, 1) = '1' then 1
											 else 0
										end) [CAParentRightsNon]
								  , sum(case when substring(CAVisitation, 1, 1) = '1' then 1
											 else 0
										end) [CAVisitation]
								  , sum(case when substring(CAVisitation, 2, 1) = '1' then 1
											 else 0
										end) [CAVisitationNon]
								  , sum(case when substring(CAOther, 1, 1) = '1' then 1
											 else 0
										end) [CAOther]
								  , sum(case when substring(CAOther, 2, 1) = '1' then 1
											 else 0
										end) [CAOtherNon]
								  , sum(case when substring(CATransportation, 1, 1) = '1'
												  or substring(CAGoods, 1, 1) = '1'
												  or substring(CALegal, 1, 1) = '1'
												  or substring(CALegal, 1, 1) = '1'
												  or substring(CAHousing, 1, 1) = '1'
												  or substring(CAAdvocacy, 1, 1) = '1'
												  or substring(CATranslation, 1, 1) = '1'
												  or substring(CALaborSupport, 1, 1) = '1'
												  or substring(CAChildSupport, 1, 1) = '1'
												  or substring(CAVisitation, 1, 1) = '1'
												  or substring(CAOther, 1, 1) = '1' then 1
											 else 0
										end) [CA1]
								  , sum(case when substring(CATransportation, 2, 1) = '1'
												  or substring(CAGoods, 2, 1) = '1'
												  or substring(CALegal, 2, 1) = '1'
												  or substring(CALegal, 2, 1) = '1'
												  or substring(CAHousing, 2, 1) = '1'
												  or substring(CAAdvocacy, 2, 1) = '1'
												  or substring(CATranslation, 2, 1) = '1'
												  or substring(CALaborSupport, 2, 1) = '1'
												  or substring(CAChildSupport, 2, 1) = '1'
												  or substring(CAVisitation, 2, 1) = '1'
												  or substring(CAOther, 2, 1) = '1' then 1
											 else 0
										end) [CA2]
								  , count(*) [Total]
							 from	HVLog as a
							 inner join CaseProgram cp on cp.HVCaseFK = a.HVCaseFK and cp.ProgramFK = @programfk
							 inner join Worker fsw on a.FSWFK = fsw.workerpk
							 inner join WorkerProgram wp on wp.WorkerFK = fsw.WorkerPK and wp.ProgramFK = cp.ProgramFK
							 inner join dbo.udfCaseFilters(@CaseFiltersPositive, '', @ProgramFK) cf on cf.HVCaseFK = cp.HVCaseFK
							 where	substring(a.VisitType, 4, 1) <> '1'
									and cast(a.VisitStartTime as date) between @StartDt and @EndDt
									and a.FSWFK = isnull(@workerfk, a.FSWFK)
									and cp.PC1ID = case	when @pc1id = '' then cp.PC1ID
														else @pc1id
												   end
									and case when @SiteFK = 0 then 1
											 when wp.SiteFK = @SiteFK then 1
											 else 0
										end = 1
							 group by a.HVCaseFK
								  , case when @showWorkerDetail = 'N' then 0
										 else a.FSWFK
									end
								  , case when @showPC1IDDetail = 'N' then ''
										 else cp.PC1ID
									end
							) as x
				  group by	FSWFK
						  , PC1ID
				 )
		select	a.*
			  , d.AttemptedFamily
			  , d.Attempted
			  , [AvgMinuteForCompletedVisit]
			  , [InHome]
			  , [OutOfHome]
			  , [BothInAndOutHome]
			  , [PC1Participated]
			  , [PC2Participated]
			  , [OBPParticipated]
			  , [FatherFigureParticipated]
			  , [FatherAdvocateParticipated]
			  , [TCParticipated]
			  , [GrandParentParticipated]
			  , [SiblingParticipated]
			  , [NonPrimaryFSWParticipated]
			  , [HVSupervisorParticipated]
			  , [SupervisorObservation]
			  , [OtherParticipated]
			  ,

-- child development
				[CDChildDevelopment] [CDChildDevelopment]
			  , [CDChildDevelopmentNon] [CDChildDevelopmentNon]
			  , [CDToys] [CDToys]
			  , [CDToysNon] [CDToysNon]
			  , [CDOther] [CDOther]
			  , [CDOtherNon] [CDOtherNon]
			  , [CD1] [CD1]
			  , [CD2] [CD2]
			  ,

-- parent/child interaction
				[PCChildInteraction] [PCChildInteraction]
			  , [PCChildInteractionNon] [PCChildInteractionNon]
			  , [PCChildManagement] [PCChildManagement]
			  , [PCChildManagementNon] [PCChildManagementNon]
			  , [PCFeelings] [PCFeelings]
			  , [PCFeelingsNon] [PCFeelingsNon]
			  , [PCStress] [PCStress]
			  , [PCStressNon] [PCStressNon]
			  , [PCBasicNeeds] [PCBasicNeeds]
			  , [PCBasicNeedsNon] [PCBasicNeedsNon]
			  , [PCShakenBaby] [PCShakenBaby]
			  , [PCShakenBabyNon] [PCShakenBabyNon]
			  , [PCShakenBabyVideo] [PCShakenBabyVideo]
			  , [PCShakenBabyVideoNon] [PCShakenBabyVideoNon]
			  , [PCOther] [PCOther]
			  , [PCOtherNon] [PCOtherNon]
			  , [PC1] [PC1]
			  , [PC2] [PC2]
			  ,

-- Health care
				[HCGeneral] [HCGeneral]
			  , [HCGeneralNon] [HCGeneralNon]
			  , [HCChild] [HCChild]
			  , [HCChildNon] [HCChildNon]
			  , [HCDental] [HCDental]
			  , [HCDentalNon] [HCDentalNon]
			  , [HCFeeding] [HCFeeding]
			  , [HCFeedingNon] [HCFeedingNon]
			  , [HCBreastFeeding] [HCBreastFeeding]
			  , [HCBreastFeedingNon] [HCBreastFeedingNon]
			  , [HCNutrition] [HCNutrition]
			  , [HCNutritionNon] [HCNutritionNon]
			  , [HCFamilyPlanning] [HCFamilyPlanning]
			  , [HCFamilyPlanningNon] [HCFamilyPlanningNon]
			  , [HCProviders] [HCProviders]
			  , [HCProvidersNon] [HCProvidersNon]
			  , [HCFASD] [HCFASD]
			  , [HCFASDNon] [HCFASDNon]
			  , [HCSexEducation] [HCSexEducation]
			  , [HCSexEducationNon] [HCSexEducationNon]
			  , [HCPrenatalCare] [HCPrenatalCare]
			  , [HCPrenatalCareNon] [HCPrenatalCareNon]
			  , [HCMedicalAdvocacy] [HCMedicalAdvocacy]
			  , [HCMedicalAdvocacyNon] [HCMedicalAdvocacyNon]
			  , [HCSafety] [HCSafety]
			  , [HCSafetyNon] [HCSafetyNon]
			  , [HCSmoking] [HCSmoking]
			  , [HCSmokingNon] [HCSmokingNon]
			  , [HCSIDS] [HCSIDS]
			  , [HCSIDSNon] [HCSIDSNon]
			  , [HCOther] [HCOther]
			  , [HCOther] [HCOther]
			  , [HCOtherNon] [HCOtherNon]
			  , [HC1] [HC1]
			  , [HC2] [HC2]
			  ,

-- family functioning
				[FFDomesticViolence] [FFDomesticViolence]
			  , [FFDomesticViolenceNon] [FFDomesticViolenceNon]
			  , [FFFamilyRelations] [FFFamilyRelations]
			  , [FFFamilyRelationsNon] [FFFamilyRelationsNon]
			  , [FFSubstanceAbuse] [FFSubstanceAbuse]
			  , [FFSubstanceAbuseNon] [FFSubstanceAbuseNon]
			  , [FFMentalHealth] [FFMentalHealth]
			  , [FFMentalHealthNon] [FFMentalHealthNon]
			  , [FFCommunication] [FFCommunication]
			  , [FFCommunicationNon] [FFCommunicationNon]
			  , [FFOther] [FFOther]
			  , [FFOtherNon] [FFOtherNon]
			  , [FF1] [FF1]
			  , [FF2] [FF2]
			  ,

-- self sufficiency
				[SSCalendar] [SSCalendar]
			  , [SSCalendarNon] [SSCalendarNon]
			  , [SSHousekeeping] [SSHousekeeping]
			  , [SSHousekeepingNon] [SSHousekeepingNon]
			  , [SSTransportation] [SSTransportation]
			  , [SSTransportationNon] [SSTransportationNon]
			  , [SSEmployment] [SSEmployment]
			  , [SSEmploymentNon] [SSEmploymentNon]
			  , [SSMoneyManagement] [SSMoneyManagement]
			  , [SSMoneyManagementNon] [SSMoneyManagementNon]
			  , [SSChildCare] [SSChildCare]
			  , [SSChildCareNon] [SSChildCareNon]
			  , [SSProblemSolving] [SSProblemSolving]
			  , [SSProblemSolvingNon] [SSProblemSolvingNon]
			  , [SSEducation] [SSEducation]
			  , [SSEducationNon] [SSEducationNon]
			  , [SSJob] [SSJob]
			  , [SSJobNon] [SSJobNon]
			  , [SSOther] [SSOther]
			  , [SSOtherNon] [SSOtherNon]
			  , [SS1] [SS1]
			  , [SS2] [SS2]
			  ,

-- crisis intervention
				[CIProblems] [CIProblems]
			  , [CIProblemsNon] [CIProblemsNon]
			  , [CIOther] [CIOther]
			  , [CIOtherNon] [CIOtherNon]
			  , [CI1] [CI1]
			  , [CI2] [CI2]
			  ,

-- program activities
				[PAForms] [PAForms]
			  , [PAFormsNon] [PAFormsNon]
			  , [PAVideo] [PAVideo]
			  , [PAVideoNon] [PAVideoNon]
			  , [PAGroups] [PAGroups]
			  , [PAGroupsNon] [PAGroupsNon]
			  , [PAIFSP] [PAIFSP]
			  , [PAIFSPNon] [PAIFSPNon]
			  , [PARecreation] [PARecreation]
			  , [PARecreationNon] [PARecreationNon]
			  , [PAOther] [PAOther]
			  , [PAOtherNon] [PAOtherNon]
			  , [PA1] [PA1]
			  , [PA2] [PA2]
			  ,

-- concrete activities
				[CATransportation] [CATransportation]
			  , [CATransportationNon] [CATransportationNon]
			  , [CAGoods] [CAGoods]
			  , [CAGoodsNon] [CAGoodsNon]
			  , [CALegal] [CALegal]
			  , [CALegalNon] [CALegalNon]
			  , [CAHousing] [CAHousing]
			  , [CAHousingNon] [CAHousingNon]
			  , [CAAdvocacy] [CAAdvocacy]
			  , [CAAdvocacyNon] [CAAdvocacyNon]
			  , [CATranslation] [CATranslation]
			  , [CATranslationNon] [CATranslationNon]
			  , [CALaborSupport] [CALaborSupport]
			  , [CALaborSupportNon] [CALaborSupportNon]
			  , [CAChildSupport] [CAChildSupport]
			  , [CAChildSupportNon] [CAChildSupportNon]
			  , [CAParentRights] [CAParentRights]
			  , [CAParentRightsNon] [CAParentRightsNon]
			  , [CAVisitation] [CAVisitation]
			  , [CAVisitationNon] [CAVisitationNon]
			  , [CAOther] [CAOther]
			  , [CAOtherNon] [CAOtherNon]
			  , [CA1] [CA1]
			  , [CA2] [CA2]
			  , [Total]
			  , case when c.WorkerPK is null then 'All Workers'
					 else rtrim(c.LastName) + ', ' + rtrim(c.FirstName)
				end WorkerName
		from	base11 as a
		full outer join base2 as b on a.FSWFK = b.FSWFK
									  and a.PC1ID = b.PC1ID
		full outer join base0 as d on a.FSWFK = d.FSWFK
									  and a.PC1ID = d.PC1ID
		left outer join Worker as c on case	when (@showWorkerDetail = 'N'
												  and @workerfk is not null
												 ) then @workerfk
											else a.FSWFK
									   end = c.WorkerPK
		order by WorkerName
			  , a.PC1ID
GO
