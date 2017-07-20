SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Dar Chen
-- Create date: 05/22/2010
-- Description:	Home Visit Log Activity Summary
-- [rspHomeVisitLogActivitySummary] 1,'10/01/2013','04/30/2014',null,'','N','N'
-- [rspHomeVisitLogActivitySummary] 1,'10/01/2013','04/30/2014',null,'','N','N'
-- =============================================
CREATE procedure [dbo].[rspHomeVisitLogActivitySummary] 
	-- Add the parameters for the stored procedure here
	(@ProgramFK int = null
   , @StartDt datetime
   , @EndDt datetime
   , @workerfk int = null
   , @pc1id varchar(13) = ''
   , @showWorkerDetail char(1) = 'N'
   , @showPC1IDDetail char(1) = 'N'
   , @SiteFK int = null
   , @CaseFiltersPositive varchar(200) = null
	)

--DECLARE	@programfk INT = 6
--DECLARE @StartDt DATETIME = '01/01/2011'
--DECLARE @EndDt DATETIME = '01/01/2012'
--DECLARE @workerfk INT = NULL
--DECLARE @pc1id VARCHAR(13) = NULL
--DECLARE @showWorkerDetail CHAR(1) = 'Y'
--DECLARE @showPC1IDDetail CHAR(1) = 'N'
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

	with	base1
			  as (select	case when @showWorkerDetail = 'N' then 0
								 else a.FSWFK
							end FSWFK
						  , case when @showPC1IDDetail = 'N' then ''
								 else cp.PC1ID
							end PC1ID
						  , x = sum(case substring(VisitType, 4, 1)
									  when '1' then 0
									  else 1
									end)
				  from		HVLog as a
				  inner join CaseProgram cp on cp.HVCaseFK = a.HVCaseFK and cp.ProgramFK = @programfk
				  inner join Worker fsw on a.FSWFK = fsw.workerpk
				  inner join WorkerProgram wp on wp.WorkerFK = fsw.WorkerPK and wp.ProgramFK = cp.ProgramFK
				  inner join dbo.udfCaseFilters(@CaseFiltersPositive, '', @ProgramFK) cf on cf.HVCaseFK = cp.HVCaseFK
				  where		cast(VisitStartTime as date) between @StartDt and @EndDt
							and a.FSWFK = isnull(@workerfk, a.FSWFK)
							and cp.PC1ID = case	when @pc1ID = '' then cp.PC1ID
												else @pc1ID
										   end
							-- and cp.ProgramFK = @programfk
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
						  , case when x = 0 then 1
								 else x
							end x
				  from		base1
				 ) ,
			base2
			  as (select	case when @showWorkerDetail = 'N' then 0
								 else a.FSWFK
							end FSWFK
						  , case when @showPC1IDDetail = 'N' then ''
								 else cp.PC1ID
							end PC1ID
--,count(DISTINCT a.HVCaseFK) [UniqueFamilies],
						  , count(distinct (case when substring(VisitType, 4, 1) != '1' then a.HVCaseFK
												 else null
											end)) [UniqueFamilies]
						  , sum(case substring(VisitType, 4, 1)
								  when '1' then 1
								  else 0
								end) [Attempted]
						  , sum(case substring(VisitType, 4, 1)
								  when '1' then 0
								  else 1
								end) [CompletedVisit]
						  , sum(case when substring(VisitType, 4, 1) != '1'
										  and isnull(h.TCDOB, h.EDC) > a.VisitStartTime then 1
									 else 0
								end) [CompletedPenatalVisit]
						  , sum(case when substring(VisitType, 1, 3) in ('100', '110', '010') then 1
									 else 0
								end) [InHome]
						  , sum(case when substring(VisitType, 1, 3) = '001' then 1
									 else 0
								end) [OutOfHome]
						  , sum(case when substring(VisitType, 1, 3) in ('101', '111', '011') then 1
									 else 0
								end) [BothInAndOutHome]
						  , sum(VisitLengthHour * 60 + VisitLengthMinute) [AvgMinuteForCompletedVisit]
						  , sum(case when PC1Participated = 1 then 1
									 else 0
								end) * 100 [PC1Participated]
						  , sum(case when PC2Participated = 1 then 1
									 else 0
								end) * 100 [PC2Participated]
						  , sum(case when OBPParticipated = 1 then 1
									 else 0
								end) * 100 [OBPParticipated]
						  , sum(case when FatherFigureParticipated = 1 then 1
									 else 0
								end) * 100 [FatherFigureParticipated]
						  , sum(case when FatherAdvocateParticipated > 0 then 1
									 else 0
								end) [FatherAdvocateParticipated]
						  , sum(case when TCParticipated = 1 then 1
									 else 0
								end) * 100 [TCParticipated]
						  , sum(case when GrandParentParticipated = 1 then 1
									 else 0
								end) * 100 [GrandParentParticipated]
						  , sum(case when SiblingParticipated = 1 then 1
									 else 0
								end) * 100 [SiblingParticipated]
						  , sum(case when NonPrimaryFSWParticipated = 1 then 1
									 else 0
								end) * 100 [NonPrimaryFSWParticipated]
						  , sum(case when HVSupervisorParticipated = 1 then 1
									 else 0
								end) * 100 [HVSupervisorParticipated]
						  , sum(case when SupervisorObservation = 1 then 1
									 else 0
								end) * 100 [SupervisorObservation]
						  , sum(case when OtherParticipated = 1 then 1
									 else 0
								end) * 100 [OtherParticipated]
						  ,

-- child development
							sum(case when substring(CDChildDevelopment, 1, 1) = '1' then 1
									 else 0
								end) * 100 [CDChildDevelopment]
						  , sum(case when substring(CDChildDevelopment, 2, 1) = '1' then 1
									 else 0
								end) * 100 [CDChildDevelopmentNon]
						  , sum(case when substring(CDToys, 1, 1) = '1' then 1
									 else 0
								end) * 100 [CDToys]
						  , sum(case when substring(CDToys, 2, 1) = '1' then 1
									 else 0
								end) * 100 [CDToysNon]
						  , sum(case when substring(CDOther, 1, 1) = '1' then 1
									 else 0
								end) * 100 [CDOther]
						  , sum(case when substring(CDOther, 2, 1) = '1' then 1
									 else 0
								end) * 100 [CDOtherNon]
						  , sum(case when substring(CDChildDevelopment, 1, 1) = '1'
										  or substring(CDToys, 1, 1) = '1'
										  or substring(CDOther, 1, 1) = '1' then 1
									 else 0
								end) * 100 [CD1]
						  , sum(case when substring(CDChildDevelopment, 2, 1) = '1'
										  or substring(CDToys, 2, 1) = '1'
										  or substring(CDOther, 2, 1) = '1' then 1
									 else 0
								end) * 100 [CD2]
						  ,

-- parent/child interaction
							sum(case when substring(PCChildInteraction, 1, 1) = '1' then 1
									 else 0
								end) * 100 [PCChildInteraction]
						  , sum(case when substring(PCChildInteraction, 2, 1) = '1' then 1
									 else 0
								end) * 100 [PCChildInteractionNon]
						  , sum(case when substring(PCChildManagement, 1, 1) = '1' then 1
									 else 0
								end) * 100 [PCChildManagement]
						  , sum(case when substring(PCChildManagement, 2, 1) = '1' then 1
									 else 0
								end) * 100 [PCChildManagementNon]
						  , sum(case when substring(PCFeelings, 1, 1) = '1' then 1
									 else 0
								end) * 100 [PCFeelings]
						  , sum(case when substring(PCFeelings, 2, 1) = '1' then 1
									 else 0
								end) * 100 [PCFeelingsNon]
						  , sum(case when substring(PCStress, 1, 1) = '1' then 1
									 else 0
								end) * 100 [PCStress]
						  , sum(case when substring(PCStress, 2, 1) = '1' then 1
									 else 0
								end) * 100 [PCStressNon]
						  , sum(case when substring(PCBasicNeeds, 1, 1) = '1' then 1
									 else 0
								end) * 100 [PCBasicNeeds]
						  , sum(case when substring(PCBasicNeeds, 2, 1) = '1' then 1
									 else 0
								end) * 100 [PCBasicNeedsNon]
						  , sum(case when substring(PCShakenBaby, 1, 1) = '1' then 1
									 else 0
								end) * 100 [PCShakenBaby]
						  , sum(case when substring(PCShakenBaby, 2, 1) = '1' then 1
									 else 0
								end) * 100 [PCShakenBabyNon]
						  , sum(case when substring(PCShakenBabyVideo, 1, 1) = '1' then 1
									 else 0
								end) * 100 [PCShakenBabyVideo]
						  , sum(case when substring(PCShakenBabyVideo, 2, 1) = '1' then 1
									 else 0
								end) * 100 [PCShakenBabyVideoNon]
						  , sum(case when substring(PCOther, 1, 1) = '1' then 1
									 else 0
								end) * 100 [PCOther]
						  , sum(case when substring(PCOther, 2, 1) = '1' then 1
									 else 0
								end) * 100 [PCOtherNon]
						  , sum(case when substring(PCChildInteraction, 1, 1) = '1'
										  or substring(PCChildManagement, 1, 1) = '1'
										  or substring(PCFeelings, 1, 1) = '1'
										  or substring(PCStress, 1, 1) = '1'
										  or substring(PCBasicNeeds, 1, 1) = '1'
										  or substring(PCShakenBaby, 1, 1) = '1'
										  or substring(PCShakenBabyVideo, 1, 1) = '1'
										  or substring(PCOther, 1, 1) = '1' then 1
									 else 0
								end) * 100 [PC1]
						  , sum(case when substring(PCChildInteraction, 2, 1) = '1'
										  or substring(PCChildManagement, 2, 1) = '1'
										  or substring(PCFeelings, 2, 1) = '1'
										  or substring(PCStress, 2, 1) = '1'
										  or substring(PCBasicNeeds, 2, 1) = '1'
										  or substring(PCShakenBaby, 2, 1) = '1'
										  or substring(PCShakenBabyVideo, 2, 1) = '1'
										  or substring(PCOther, 2, 1) = '1' then 1
									 else 0
								end) * 100 [PC2]
						  ,

-- Health care
							sum(case when substring(HCGeneral, 1, 1) = '1' then 1
									 else 0
								end) * 100 [HCGeneral]
						  , sum(case when substring(HCGeneral, 2, 1) = '1' then 1
									 else 0
								end) * 100 [HCGeneralNon]
						  , sum(case when substring(HCChild, 1, 1) = '1' then 1
									 else 0
								end) * 100 [HCChild]
						  , sum(case when substring(HCChild, 2, 1) = '1' then 1
									 else 0
								end) * 100 [HCChildNon]
						  , sum(case when substring(HCDental, 1, 1) = '1' then 1
									 else 0
								end) * 100 [HCDental]
						  , sum(case when substring(HCDental, 2, 1) = '1' then 1
									 else 0
								end) * 100 [HCDentalNon]
						  , sum(case when substring(HCFeeding, 1, 1) = '1' then 1
									 else 0
								end) * 100 [HCFeeding]
						  , sum(case when substring(HCFeeding, 2, 1) = '1' then 1
									 else 0
								end) * 100 [HCFeedingNon]
						  , sum(case when substring(HCBreastFeeding, 1, 1) = '1' then 1
									 else 0
								end) * 100 [HCBreastFeeding]
						  , sum(case when substring(HCBreastFeeding, 2, 1) = '1' then 1
									 else 0
								end) * 100 [HCBreastFeedingNon]
						  , sum(case when substring(HCNutrition, 1, 1) = '1' then 1
									 else 0
								end) * 100 [HCNutrition]
						  , sum(case when substring(HCNutrition, 2, 1) = '1' then 1
									 else 0
								end) * 100 [HCNutritionNon]
						  , sum(case when substring(HCFamilyPlanning, 1, 1) = '1' then 1
									 else 0
								end) * 100 [HCFamilyPlanning]
						  , sum(case when substring(HCFamilyPlanning, 2, 1) = '1' then 1
									 else 0
								end) * 100 [HCFamilyPlanningNon]
						  , sum(case when substring(HCProviders, 1, 1) = '1' then 1
									 else 0
								end) * 100 [HCProviders]
						  , sum(case when substring(HCProviders, 2, 1) = '1' then 1
									 else 0
								end) * 100 [HCProvidersNon]
						  , sum(case when substring(HCFASD, 1, 1) = '1' then 1
									 else 0
								end) * 100 [HCFASD]
						  , sum(case when substring(HCFASD, 2, 1) = '1' then 1
									 else 0
								end) * 100 [HCFASDNon]
						  , sum(case when substring(HCSexEducation, 1, 1) = '1' then 1
									 else 0
								end) * 100 [HCSexEducation]
						  , sum(case when substring(HCSexEducation, 2, 1) = '1' then 1
									 else 0
								end) * 100 [HCSexEducationNon]
						  , sum(case when substring(HCPrenatalCare, 1, 1) = '1' then 1
									 else 0
								end) * 100 [HCPrenatalCare]
						  , sum(case when substring(HCPrenatalCare, 2, 1) = '1' then 1
									 else 0
								end) * 100 [HCPrenatalCareNon]
						  , sum(case when substring(HCMedicalAdvocacy, 1, 1) = '1' then 1
									 else 0
								end) * 100 [HCMedicalAdvocacy]
						  , sum(case when substring(HCMedicalAdvocacy, 2, 1) = '1' then 1
									 else 0
								end) * 100 [HCMedicalAdvocacyNon]
						  , sum(case when substring(HCSafety, 1, 1) = '1' then 1
									 else 0
								end) * 100 [HCSafety]
						  , sum(case when substring(HCSafety, 2, 1) = '1' then 1
									 else 0
								end) * 100 [HCSafetyNon]
						  , sum(case when substring(HCSmoking, 1, 1) = '1' then 1
									 else 0
								end) * 100 [HCSmoking]
						  , sum(case when substring(HCSmoking, 2, 1) = '1' then 1
									 else 0
								end) * 100 [HCSmokingNon]
						  , sum(case when substring(HCSIDS, 1, 1) = '1' then 1
									 else 0
								end) * 100 [HCSIDS]
						  , sum(case when substring(HCSIDS, 2, 1) = '1' then 1
									 else 0
								end) * 100 [HCSIDSNon]
						  , sum(case when substring(HCOther, 1, 1) = '1' then 1
									 else 0
								end) * 100 [HCOther]
						  , sum(case when substring(HCOther, 2, 1) = '1' then 1
									 else 0
								end) * 100 [HCOtherNon]
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
								end) * 100 [HC1]
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
								end) * 100 [HC2]
						  ,

-- family functioning
							sum(case when substring(FFDomesticViolence, 1, 1) = '1' then 1
									 else 0
								end) * 100 [FFDomesticViolence]
						  , sum(case when substring(FFDomesticViolence, 2, 1) = '1' then 1
									 else 0
								end) * 100 [FFDomesticViolenceNon]
						  , sum(case when substring(FFFamilyRelations, 1, 1) = '1' then 1
									 else 0
								end) * 100 [FFFamilyRelations]
						  , sum(case when substring(FFFamilyRelations, 2, 1) = '1' then 1
									 else 0
								end) * 100 [FFFamilyRelationsNon]
						  , sum(case when substring(FFSubstanceAbuse, 1, 1) = '1' then 1
									 else 0
								end) * 100 [FFSubstanceAbuse]
						  , sum(case when substring(FFSubstanceAbuse, 2, 1) = '1' then 1
									 else 0
								end) * 100 [FFSubstanceAbuseNon]
						  , sum(case when substring(FFMentalHealth, 1, 1) = '1' then 1
									 else 0
								end) * 100 [FFMentalHealth]
						  , sum(case when substring(FFMentalHealth, 2, 1) = '1' then 1
									 else 0
								end) * 100 [FFMentalHealthNon]
						  , sum(case when substring(FFCommunication, 1, 1) = '1' then 1
									 else 0
								end) * 100 [FFCommunication]
						  , sum(case when substring(FFCommunication, 2, 1) = '1' then 1
									 else 0
								end) * 100 [FFCommunicationNon]
						  , sum(case when substring(FFOther, 1, 1) = '1' then 1
									 else 0
								end) * 100 [FFOther]
						  , sum(case when substring(FFOther, 2, 1) = '1' then 1
									 else 0
								end) * 100 [FFOtherNon]
						  , sum(case when substring(FFDomesticViolence, 1, 1) = '1'
										  or substring(FFFamilyRelations, 1, 1) = '1'
										  or substring(FFSubstanceAbuse, 1, 1) = '1'
										  or substring(FFMentalHealth, 1, 1) = '1'
										  or substring(FFCommunication, 1, 1) = '1'
										  or substring(FFOther, 1, 1) = '1' then 1
									 else 0
								end) * 100 [FF1]
						  , sum(case when substring(FFDomesticViolence, 2, 1) = '1'
										  or substring(FFFamilyRelations, 2, 1) = '1'
										  or substring(FFSubstanceAbuse, 2, 1) = '1'
										  or substring(FFMentalHealth, 2, 1) = '1'
										  or substring(FFCommunication, 2, 1) = '1'
										  or substring(FFOther, 2, 1) = '1' then 1
									 else 0
								end) * 100 [FF2]
						  ,

-- self sufficiency
							sum(case when substring(SSCalendar, 1, 1) = '1' then 1
									 else 0
								end) * 100 [SSCalendar]
						  , sum(case when substring(SSCalendar, 2, 1) = '1' then 1
									 else 0
								end) * 100 [SSCalendarNon]
						  , sum(case when substring(SSHousekeeping, 1, 1) = '1' then 1
									 else 0
								end) * 100 [SSHousekeeping]
						  , sum(case when substring(SSHousekeeping, 2, 1) = '1' then 1
									 else 0
								end) * 100 [SSHousekeepingNon]
						  , sum(case when substring(SSTransportation, 1, 1) = '1' then 1
									 else 0
								end) * 100 [SSTransportation]
						  , sum(case when substring(SSTransportation, 2, 1) = '1' then 1
									 else 0
								end) * 100 [SSTransportationNon]
						  , sum(case when substring(SSEmployment, 1, 1) = '1' then 1
									 else 0
								end) * 100 [SSEmployment]
						  , sum(case when substring(SSEmployment, 2, 1) = '1' then 1
									 else 0
								end) * 100 [SSEmploymentNon]
						  , sum(case when substring(SSMoneyManagement, 1, 1) = '1' then 1
									 else 0
								end) * 100 [SSMoneyManagement]
						  , sum(case when substring(SSMoneyManagement, 2, 1) = '1' then 1
									 else 0
								end) * 100 [SSMoneyManagementNon]
						  , sum(case when substring(SSChildCare, 1, 1) = '1' then 1
									 else 0
								end) * 100 [SSChildCare]
						  , sum(case when substring(SSChildCare, 2, 1) = '1' then 1
									 else 0
								end) * 100 [SSChildCareNon]
						  , sum(case when substring(SSProblemSolving, 1, 1) = '1' then 1
									 else 0
								end) * 100 [SSProblemSolving]
						  , sum(case when substring(SSProblemSolving, 2, 1) = '1' then 1
									 else 0
								end) * 100 [SSProblemSolvingNon]
						  , sum(case when substring(SSEducation, 1, 1) = '1' then 1
									 else 0
								end) * 100 [SSEducation]
						  , sum(case when substring(SSEducation, 2, 1) = '1' then 1
									 else 0
								end) * 100 [SSEducationNon]
						  , sum(case when substring(SSJob, 1, 1) = '1' then 1
									 else 0
								end) * 100 [SSJob]
						  , sum(case when substring(SSJob, 2, 1) = '1' then 1
									 else 0
								end) * 100 [SSJobNon]
						  , sum(case when substring(SSOther, 1, 1) = '1' then 1
									 else 0
								end) * 100 [SSOther]
						  , sum(case when substring(SSOther, 2, 1) = '1' then 1
									 else 0
								end) * 100 [SSOtherNon]
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
								end) * 100 [SS1]
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
								end) * 100 [SS2]
						  ,

-- crisis intervention
							sum(case when substring(CIProblems, 1, 1) = '1' then 1
									 else 0
								end) * 100 [CIProblems]
						  , sum(case when substring(CIProblems, 2, 1) = '1' then 1
									 else 0
								end) * 100 [CIProblemsNon]
						  , sum(case when substring(CIOther, 1, 1) = '1' then 1
									 else 0
								end) * 100 [CIOther]
						  , sum(case when substring(CIOther, 2, 1) = '1' then 1
									 else 0
								end) * 100 [CIOtherNon]
						  , sum(case when substring(CIProblems, 1, 1) = '1'
										  or substring(CIOther, 1, 1) = '1' then 1
									 else 0
								end) * 100 [CI1]
						  , sum(case when substring(CIProblems, 2, 1) = '1'
										  or substring(CIOther, 2, 1) = '1' then 1
									 else 0
								end) * 100 [CI2]
						  ,

-- program activities
							sum(case when substring(PAForms, 1, 1) = '1' then 1
									 else 0
								end) * 100 [PAForms]
						  , sum(case when substring(PAForms, 2, 1) = '1' then 1
									 else 0
								end) * 100 [PAFormsNon]
						  , sum(case when substring(PAVideo, 1, 1) = '1' then 1
									 else 0
								end) * 100 [PAVideo]
						  , sum(case when substring(PAVideo, 2, 1) = '1' then 1
									 else 0
								end) * 100 [PAVideoNon]
						  , sum(case when substring(PAGroups, 1, 1) = '1' then 1
									 else 0
								end) * 100 [PAGroups]
						  , sum(case when substring(PAGroups, 2, 1) = '1' then 1
									 else 0
								end) * 100 [PAGroupsNon]
						  , sum(case when substring(PAIFSP, 1, 1) = '1' then 1
									 else 0
								end) * 100 [PAIFSP]
						  , sum(case when substring(PAIFSP, 2, 1) = '1' then 1
									 else 0
								end) * 100 [PAIFSPNon]
						  , sum(case when substring(PARecreation, 1, 1) = '1' then 1
									 else 0
								end) * 100 [PARecreation]
						  , sum(case when substring(PARecreation, 2, 1) = '1' then 1
									 else 0
								end) * 100 [PARecreationNon]
						  , sum(case when substring(PAOther, 1, 1) = '1' then 1
									 else 0
								end) * 100 [PAOther]
						  , sum(case when substring(PAOther, 2, 1) = '1' then 1
									 else 0
								end) * 100 [PAOtherNon]
						  , sum(case when substring(PAForms, 1, 1) = '1'
										  or substring(PAVideo, 1, 1) = '1'
										  or substring(PAGroups, 1, 1) = '1'
										  or substring(PAIFSP, 1, 1) = '1'
										  or substring(PARecreation, 1, 1) = '1'
										  or substring(PAOther, 1, 1) = '1' then 1
									 else 0
								end) * 100 [PA1]
						  , sum(case when substring(PAForms, 2, 1) = '1'
										  or substring(PAVideo, 2, 1) = '1'
										  or substring(PAGroups, 2, 1) = '1'
										  or substring(PAIFSP, 2, 1) = '1'
										  or substring(PARecreation, 2, 1) = '1'
										  or substring(PAOther, 2, 1) = '1' then 1
									 else 0
								end) * 100 [PA2]
						  ,

-- concrete activities
							sum(case when substring(CATransportation, 1, 1) = '1' then 1
									 else 0
								end) * 100 [CATransportation]
						  , sum(case when substring(CATransportation, 2, 1) = '1' then 1
									 else 0
								end) * 100 [CATransportationNon]
						  , sum(case when substring(CAGoods, 1, 1) = '1' then 1
									 else 0
								end) * 100 [CAGoods]
						  , sum(case when substring(CAGoods, 2, 1) = '1' then 1
									 else 0
								end) * 100 [CAGoodsNon]
						  , sum(case when substring(CALegal, 1, 1) = '1' then 1
									 else 0
								end) * 100 [CALegal]
						  , sum(case when substring(CALegal, 2, 1) = '1' then 1
									 else 0
								end) * 100 [CALegalNon]
						  , sum(case when substring(CAHousing, 1, 1) = '1' then 1
									 else 0
								end) * 100 [CAHousing]
						  , sum(case when substring(CAHousing, 2, 1) = '1' then 1
									 else 0
								end) * 100 [CAHousingNon]
						  , sum(case when substring(CAAdvocacy, 1, 1) = '1' then 1
									 else 0
								end) * 100 [CAAdvocacy]
						  , sum(case when substring(CAAdvocacy, 2, 1) = '1' then 1
									 else 0
								end) * 100 [CAAdvocacyNon]
						  , sum(case when substring(CATranslation, 1, 1) = '1' then 1
									 else 0
								end) * 100 [CATranslation]
						  , sum(case when substring(CATranslation, 2, 1) = '1' then 1
									 else 0
								end) * 100 [CATranslationNon]
						  , sum(case when substring(CALaborSupport, 1, 1) = '1' then 1
									 else 0
								end) * 100 [CALaborSupport]
						  , sum(case when substring(CALaborSupport, 2, 1) = '1' then 1
									 else 0
								end) * 100 [CALaborSupportNon]
						  , sum(case when substring(CAChildSupport, 1, 1) = '1' then 1
									 else 0
								end) * 100 [CAChildSupport]
						  , sum(case when substring(CAChildSupport, 2, 1) = '1' then 1
									 else 0
								end) * 100 [CAChildSupportNon]
						  , sum(case when substring(CAParentRights, 1, 1) = '1' then 1
									 else 0
								end) * 100 [CAParentRights]
						  , sum(case when substring(CAParentRights, 2, 1) = '1' then 1
									 else 0
								end) * 100 [CAParentRightsNon]
						  , sum(case when substring(CAVisitation, 1, 1) = '1' then 1
									 else 0
								end) * 100 [CAVisitation]
						  , sum(case when substring(CAVisitation, 2, 1) = '1' then 1
									 else 0
								end) * 100 [CAVisitationNon]
						  , sum(case when substring(CAOther, 1, 1) = '1' then 1
									 else 0
								end) * 100 [CAOther]
						  , sum(case when substring(CAOther, 2, 1) = '1' then 1
									 else 0
								end) * 100 [CAOtherNon]
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
								end) * 100 [CA1]
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
								end) * 100 [CA2]
						  , count(*) [Total]
				  from		HVLog as a
				  inner join CaseProgram cp on cp.HVCaseFK = a.HVCaseFK and cp.ProgramFK = @programfk
				  inner join Worker fsw on a.FSWFK = fsw.workerpk
				  inner join WorkerProgram wp on wp.WorkerFK = fsw.WorkerPK and wp.ProgramFK = cp.ProgramFK
				  inner join HVCase as h on h.HVCasePK = a.HVCaseFK
				  inner join dbo.udfCaseFilters(@CaseFiltersPositive, '', @ProgramFK) cf on cf.HVCaseFK = cp.HVCaseFK
				  where		
							cast(VisitStartTime as date) between @StartDt and @EndDt
							and a.FSWFK = isnull(@workerfk, a.FSWFK)
							and cp.PC1ID = case	when @pc1ID = '' then cp.PC1ID
												else @pc1ID
										   end
							-- and cp.ProgramFK = @programfk
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
				 )
		select	a.*
			  , [UniqueFamilies]
			  , [Attempted]
			  , [CompletedVisit]
			  , [CompletedPenatalVisit]
			  , [InHome]
			  , [OutOfHome]
			  , [BothInAndOutHome]
			  , ([AvgMinuteForCompletedVisit] / x) [AvgMinuteForCompletedVisit]
			  , [PC1Participated] / x [PC1Participated]
			  , [PC2Participated] / x [PC2Participated]
			  , [OBPParticipated] / x [OBPParticipated]
			  , [FatherFigureParticipated] / x [FatherFigureParticipated]
			  , [FatherAdvocateParticipated] / x [FatherAdvocateParticipated]
			  , case when (x - [CompletedPenatalVisit]) > 0
						then [TCParticipated] / (x - [CompletedPenatalVisit]) 
						else 0 end as [TCParticipated]
			  , [GrandParentParticipated] / x [GrandParentParticipated]
			  , [SiblingParticipated] / x [SiblingParticipated]
			  , [NonPrimaryFSWParticipated] / x [NonPrimaryFSWParticipated]
			  , [HVSupervisorParticipated] / x [HVSupervisorParticipated]
			  , [SupervisorObservation] / x [SupervisorObservation]
			  , [OtherParticipated] / x [OtherParticipated]
			  ,

-- child development
				[CDChildDevelopment] / x [CDChildDevelopment]
			  , [CDChildDevelopmentNon] / x [CDChildDevelopmentNon]
			  , [CDToys] / x [CDToys]
			  , [CDToysNon] / x [CDToysNon]
			  , [CDOther] / x [CDOther]
			  , [CDOtherNon] / x [CDOtherNon]
			  , [CD1] / x [CD1]
			  , [CD2] / x [CD2]
			  ,

-- parent/child interaction
				[PCChildInteraction] / x [PCChildInteraction]
			  , [PCChildInteractionNon] / x [PCChildInteractionNon]
			  , [PCChildManagement] / x [PCChildManagement]
			  , [PCChildManagementNon] / x [PCChildManagementNon]
			  , [PCFeelings] / x [PCFeelings]
			  , [PCFeelingsNon] / x [PCFeelingsNon]
			  , [PCStress] / x [PCStress]
			  , [PCStressNon] / x [PCStressNon]
			  , [PCBasicNeeds] / x [PCBasicNeeds]
			  , [PCBasicNeedsNon] / x [PCBasicNeedsNon]
			  , [PCShakenBaby] / x [PCShakenBaby]
			  , [PCShakenBabyNon] / x [PCShakenBabyNon]
			  , [PCShakenBabyVideo] / x [PCShakenBabyVideo]
			  , [PCShakenBabyVideoNon] / x [PCShakenBabyVideoNon]
			  , [PCOther] / x [PCOther]
			  , [PCOtherNon] / x [PCOtherNon]
			  , [PC1] / x [PC1]
			  , [PC2] / x [PC2]
			  ,

-- Health care
				[HCGeneral] / x [HCGeneral]
			  , [HCGeneralNon] / x [HCGeneralNon]
			  , [HCChild] / x [HCChild]
			  , [HCChildNon] / x [HCChildNon]
			  , [HCDental] / x [HCDental]
			  , [HCDentalNon] / x [HCDentalNon]
			  , [HCFeeding] / x [HCFeeding]
			  , [HCFeedingNon] / x [HCFeedingNon]
			  , [HCBreastFeeding] / x [HCBreastFeeding]
			  , [HCBreastFeedingNon] / x [HCBreastFeedingNon]
			  , [HCNutrition] / x [HCNutrition]
			  , [HCNutritionNon] / x [HCNutritionNon]
			  , [HCFamilyPlanning] / x [HCFamilyPlanning]
			  , [HCFamilyPlanningNon] / x [HCFamilyPlanningNon]
			  , [HCProviders] / x [HCProviders]
			  , [HCProvidersNon] / x [HCProvidersNon]
			  , [HCFASD] / x [HCFASD]
			  , [HCFASDNon] / x [HCFASDNon]
			  , [HCSexEducation] / x [HCSexEducation]
			  , [HCSexEducationNon] / x [HCSexEducationNon]
			  , [HCPrenatalCare] / x [HCPrenatalCare]
			  , [HCPrenatalCareNon] / x [HCPrenatalCareNon]
			  , [HCMedicalAdvocacy] / x [HCMedicalAdvocacy]
			  , [HCMedicalAdvocacyNon] / x [HCMedicalAdvocacyNon]
			  , [HCSafety] / x [HCSafety]
			  , [HCSafetyNon] / x [HCSafetyNon]
			  , [HCSmoking] / x [HCSmoking]
			  , [HCSmokingNon] / x [HCSmokingNon]
			  , [HCSIDS] / x [HCSIDS]
			  , [HCSIDSNon] / x [HCSIDSNon]
			  , [HCOther] / x [HCOther]
			  , [HCOther] / x [HCOther]
			  , [HCOtherNon] / x [HCOtherNon]
			  , [HC1] / x [HC1]
			  , [HC2] / x [HC2]
			  ,

-- family functioning
				[FFDomesticViolence] / x [FFDomesticViolence]
			  , [FFDomesticViolenceNon] / x [FFDomesticViolenceNon]
			  , [FFFamilyRelations] / x [FFFamilyRelations]
			  , [FFFamilyRelationsNon] / x [FFFamilyRelationsNon]
			  , [FFSubstanceAbuse] / x [FFSubstanceAbuse]
			  , [FFSubstanceAbuseNon] / x [FFSubstanceAbuseNon]
			  , [FFMentalHealth] / x [FFMentalHealth]
			  , [FFMentalHealthNon] / x [FFMentalHealthNon]
			  , [FFCommunication] / x [FFCommunication]
			  , [FFCommunicationNon] / x [FFCommunicationNon]
			  , [FFOther] / x [FFOther]
			  , [FFOtherNon] / x [FFOtherNon]
			  , [FF1] / x [FF1]
			  , [FF2] / x [FF2]
			  ,

-- self sufficiency
				[SSCalendar] / x [SSCalendar]
			  , [SSCalendarNon] / x [SSCalendarNon]
			  , [SSHousekeeping] / x [SSHousekeeping]
			  , [SSHousekeepingNon] / x [SSHousekeepingNon]
			  , [SSTransportation] / x [SSTransportation]
			  , [SSTransportationNon] / x [SSTransportationNon]
			  , [SSEmployment] / x [SSEmployment]
			  , [SSEmploymentNon] / x [SSEmploymentNon]
			  , [SSMoneyManagement] / x [SSMoneyManagement]
			  , [SSMoneyManagementNon] / x [SSMoneyManagementNon]
			  , [SSChildCare] / x [SSChildCare]
			  , [SSChildCareNon] / x [SSChildCareNon]
			  , [SSProblemSolving] / x [SSProblemSolving]
			  , [SSProblemSolvingNon] / x [SSProblemSolvingNon]
			  , [SSEducation] / x [SSEducation]
			  , [SSEducationNon] / x [SSEducationNon]
			  , [SSJob] / x [SSJob]
			  , [SSJobNon] / x [SSJobNon]
			  , [SSOther] / x [SSOther]
			  , [SSOtherNon] / x [SSOtherNon]
			  , [SS1] / x [SS1]
			  , [SS2] / x [SS2]
			  ,

-- crisis intervention
				[CIProblems] / x [CIProblems]
			  , [CIProblemsNon] / x [CIProblemsNon]
			  , [CIOther] / x [CIOther]
			  , [CIOtherNon] / x [CIOtherNon]
			  , [CI1] / x [CI1]
			  , [CI2] / x [CI2]
			  ,

-- program activities
				[PAForms] / x [PAForms]
			  , [PAFormsNon] / x [PAFormsNon]
			  , [PAVideo] / x [PAVideo]
			  , [PAVideoNon] / x [PAVideoNon]
			  , [PAGroups] / x [PAGroups]
			  , [PAGroupsNon] / x [PAGroupsNon]
			  , [PAIFSP] / x [PAIFSP]
			  , [PAIFSPNon] / x [PAIFSPNon]
			  , [PARecreation] / x [PARecreation]
			  , [PARecreationNon] / x [PARecreationNon]
			  , [PAOther] / x [PAOther]
			  , [PAOtherNon] / x [PAOtherNon]
			  , [PA1] / x [PA1]
			  , [PA2] / x [PA2]
			  ,

-- concrete activities
				[CATransportation] / x [CATransportation]
			  , [CATransportationNon] / x [CATransportationNon]
			  , [CAGoods] / x [CAGoods]
			  , [CAGoodsNon] / x [CAGoodsNon]
			  , [CALegal] / x [CALegal]
			  , [CALegalNon] / x [CALegalNon]
			  , [CAHousing] / x [CAHousing]
			  , [CAHousingNon] / x [CAHousingNon]
			  , [CAAdvocacy] / x [CAAdvocacy]
			  , [CAAdvocacyNon] / x [CAAdvocacyNon]
			  , [CATranslation] / x [CATranslation]
			  , [CATranslationNon] / x [CATranslationNon]
			  , [CALaborSupport] / x [CALaborSupport]
			  , [CALaborSupportNon] / x [CALaborSupportNon]
			  , [CAChildSupport] / x [CAChildSupport]
			  , [CAChildSupportNon] / x [CAChildSupportNon]
			  , [CAParentRights] / x [CAParentRights]
			  , [CAParentRightsNon] / x [CAParentRightsNon]
			  , [CAVisitation] / x [CAVisitation]
			  , [CAVisitationNon] / x [CAVisitationNon]
			  , [CAOther] / x [CAOther]
			  , [CAOtherNon] / x [CAOtherNon]
			  , [CA1] / x [CA1]
			  , [CA2] / x [CA2]
			  , [Total]
			  , case when c.WorkerPK is null then 'All Workers'
					 else rtrim(c.LastName) + ', ' + rtrim(c.FirstName)
				end WorkerName
		from	base11 as a
		join	base2 as b on a.FSWFK = b.FSWFK
							  and a.PC1ID = b.PC1ID
		left outer join Worker as c on case	when (@showWorkerDetail = 'N'
												  and @workerfk is not null
												 ) then @workerfk
											else a.FSWFK
									   end = c.WorkerPK
		order by WorkerName
			  , a.PC1ID
GO
