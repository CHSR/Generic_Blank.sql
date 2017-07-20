SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jrobohn
-- Create date: 2014-07-28
-- Description:	Gets all the data needed to display the Case Home Page
-- exec spGetAllDataForCaseHomePage 'CD97050257617' 'VB84010244287' 'EG81010218386' 'DS90010007908' 'AB77050250139' 'MC79140216559' 'JC79010253576'
-- =============================================
CREATE procedure [dbo].[spGetAllDataForCaseHomePage]
(
	@PC1ID char(13),
	@Username varchar(MAX) 
)
as
begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set nocount on;

	-- Record User Access of Case Home Page
	INSERT INTO CaseView VALUES(@PC1ID, @Username, GETDATE()); 

	declare @HVCaseFK int
	set @HVCaseFK = (select HVCaseFK 
						from CaseProgram cp
	 					where PC1ID = @PC1ID
					);

	declare @ProgramFK int
	set @ProgramFK = (select ProgramFK 
						from CaseProgram cp
	 					where PC1ID = @PC1ID
					);
					
	with ctePreAssessmentCount 
	as
		(
		  select count(PreassessmentPK) as CountOfPreassessments
			  from Preassessment pa
			  where HVCaseFK = @HVCaseFK
		)
	, ctePreIntakeCount
	as
		(
		select count(PreintakePK) as CountOfPreintakes
			from Preintake pi
			where HVCaseFK = @HVCaseFK
		)
	, cteServiceReferralCount
	as
		(
		select count(ServiceReferralPK) as CountOfServiceReferrals
			from ServiceReferral sr
			where HVCaseFK = @HVCaseFK
		)
	, cteHomeVisitLogCount
	as
		(
		select count(HVLogPK) as CountOfHomeVisitLogs
			from HVLog hl
			where HVCaseFK = @HVCaseFK
		)
	, ctePC1MedicalCount
	as
		(
		select count(PC1MedicalPK) as CountOfPC1MedicalForms
			from PC1Medical pm
			where HVCaseFK = @HVCaseFK
		)
	, cteFatherFigureCount
	as
		(
		select count(FatherFigurePK) as CountOfFatherFigures
			from FatherFigure ff
			where HVCaseFK = @HVCaseFK
		)
	, cteTCIDCount
	as
		(
		select count(TCIDPK) as CountOfTCIDs
			from TCID t
			where HVCaseFK = @HVCaseFK
		)
	, ctePSICount
	as
		(
		select count(PSIPK) as CountOfPSIs
			from PSI p
			where HVCaseFK = @HVCaseFK
		)
	, cteFollowUpCount
	as
		(
		select count(FollowUpPK) as CountOfFollowUps
			from FollowUp fu
			where HVCaseFK = @HVCaseFK
		)
	, cteTargetChildren
	as
		(
		select TCIDPK, t.HVCaseFK, t.TCFirstName, t.TCLastName, t.TCDOB, t.TCIDFormCompleteDate
		from TCID t
		where t.HVCaseFK = @HVCaseFK
		)
	, cteTargetChildren_Flattened
	as
		(
		select TargetChildName = substring((select ', ' + TCFirstName + ' ' + TCLastName
												from cteTargetChildren tc
												where tc.HVCaseFK = @HVCaseFK
												for xml path ('')), 3, 1000)

		)
	, cteTargetChildFormCompleteDate
	as
		(
		select max(TCIDFormCompleteDate) as TCIDFormCompleteDate
		from TCID t
		where t.HVCaseFK = @HVCaseFK
		)
	, cteASQs
	as
		(
		select TCIDFK, left(t.TCFirstName, 1) + rtrim(ltrim(cast(count(TCIDFK) as char(4)))) as ASQCount
		from ASQ a
		inner join TCID t on t.TCIDPK = a.TCIDFK
		where a.HVCaseFK = @HVCaseFK and t.TCDOD is null
		group by a.TCIDFK, left(t.TCFirstName, 1) 
		)
	, cteASQCount
	as
		(
		select CountOfASQs = substring((select '/' + a.ASQCount
												from cteASQs a
												for xml path ('')), 2, 1000)
		)
	, cteASQSEs
	as
		(
		select TCIDFK, left(t.TCFirstName, 1) + rtrim(ltrim(cast(count(TCIDFK) as char(4)))) as ASQSECount
		from ASQSE ase
		inner join TCID t on t.TCIDPK = ase.TCIDFK
		where ase.HVCaseFK = @HVCaseFK and t.TCDOD is null
		group by ase.TCIDFK, left(t.TCFirstName, 1) 
		)
	, cteASQSECount
	as
		(
		select CountOfASQSEs = substring((select '/' + ase.ASQSECount
												from cteASQSEs ase
												for xml path ('')), 2, 1000)
		)
	, cteTCMedicals
	as
		(
		select TCIDFK, left(t.TCFirstName, 1) + rtrim(ltrim(cast(count(TCIDFK) as char(4)))) as TCMedicalCount
		from TCMedical tm
		inner join TCID t on t.TCIDPK = tm.TCIDFK
		where tm.HVCaseFK = @HVCaseFK and t.TCDOD is null
		group by tm.TCIDFK, left(t.TCFirstName, 1) 
		)
	, cteTCMedicalCount
	as
		(
		select CountOfTCMedicalForms = substring((select '/' + tm.TCMedicalCount
												from cteTCMedicals tm
												for xml path ('')), 2, 1000)
		)
	-- the following 5 CTEs get the medical provider/facility information
	, cteMPFUP
	as 
		(--Step 1 : Get most recent followup data
		  select top 1
					FormDate as FUDate
				  , FormInterval as FUFormInterval
				  , PC1HasMedicalProvider as FUPC1HasMedicalProvider
				  , ca.HVCaseFK as HVCaseFK
				  , CommonAttributesPK
		  from		CommonAttributes ca
		  where	HVCaseFK = @HVCaseFK
				and FormType like 'FU'
		  order by	FormDate desc
				  , CommonAttributesPK desc
		) 
	, cteMPPC
	as 
		(--Step 2: Get most recent medical / facility data for PC1 from change form or intake
		  select top 1
					FormDate as PCDate
				  , FormType as PCFormType
				  , FormInterval as PCFormInterval
				  , PC1HasMedicalProvider as PCPC1HasMedicalProvider
				  , PC1MedicalProviderFK
				  , PC1MedicalFacilityFK
				  , ca.HVCaseFK as HVCaseFK
				  , CommonAttributesPK
		  from		CommonAttributes ca
		  where	HVCaseFK = @HVCaseFK
				and FormType in ('CH', 'IN')
		  order by	FormDate desc
				  , CommonAttributesPK desc
		) 
	, cteMPTCFU
	as 
		(--Step 3 : Get TC Has medical provider
		  select top 1
					FormDate as FUDate
				  , FormInterval as FUFormInterval
				  ,	TCHasMedicalProvider
				  , ca.HVCaseFK as HVCaseFK
				  , CommonAttributesPK
		  from		CommonAttributes ca
		  where	HVCaseFK = @HVCaseFK
				and FormType = 'FU'
		  order by	FormDate desc
				  , CommonAttributesPK desc
		) 
	, cteMPTC
	as 
		(--Step 4: Get most recent medical / facility data from TC
		  select top 1
					FormDate as TCDate
				  , FormType as TCFormType
				  , FormInterval as TCFormInterval
				  , ca.TCHasMedicalProvider
				  , TCMedicalProviderFK
				  , TCMedicalFacilityFK
				  , ca.HVCaseFK as HVCaseFK
				  , CommonAttributesPK
		  from		CommonAttributes ca
		  where	HVCaseFK = @HVCaseFK
				and FormType in ('CH', 'TC')
		  order by	FormDate desc
				  , CommonAttributesPK desc
		)
	, cteMedicalProviders_Facilities
	as
		(-- now bring together all the medical provider/facility info to determine what to display
			select case when mpfup.FUDate is not null and PCDate is not null and mpfup.FUDate >= PCDate
						-- follow-up form date is greater than change form / intake date
						then 
							case when FUPC1HasMedicalProvider is not null and FUPC1HasMedicalProvider = '1' 
										and PC1MedicalProviderFK is not null and PC1MedicalProviderFK > 0
							then case when (lmppc1.MPLastName is null or lmppc1.MPLastName = '')
											and (lmppc1.MPFirstName is null or lmppc1.MPFirstName = '') 
										then 'Name not specified'
										else rtrim(lmppc1.MPLastName) + 
												case when lmppc1.MPFirstName is not null and lmppc1.MPFirstName <> ''
													then ', ' + rtrim(lmppc1.MPFirstName)
													else ''
												end
								end
							else 'None'
							end
						when (mpfup.FUDate is not null and PCDate is not null and mpfup.FUDate < PCDate)
								or  (mpfup.FUDate is null and PCDate is not null)
						-- there is either no follow-up, or the change form / intake date is later so use that data
						then
							case when PCPC1HasMedicalProvider is not null and PCPC1HasMedicalProvider = '1' 
										and PC1MedicalProviderFK is not null and PC1MedicalProviderFK > 0
							then 
								case when lmppc1.MPLastName is not null and lmppc1.MPLastName > ''
										then rtrim(lmppc1.MPLastName) + 
											case when lmppc1.MPFirstName is not null and lmppc1.MPFirstName <> ''
											then ', ' + rtrim(lmppc1.MPFirstName)
											else ''
											end
									when lmppc1.MPLastName is null or lmppc1.MPLastName = ''
										then 
											case when lmppc1.MPAddress is not null and lmppc1.MPAddress > ''
													then rtrim(lmppc1.MPAddress) + ', '
											end
										+ rtrim(lmppc1.MPCity)
								end
							else 'None'
							end
					end as PC1MedicalProviderName
					, lmppc1.MPAddress as PC1MedicalProviderAddress
					, lmppc1.MPCity as PC1MedicalProviderCity
					, lmppc1.MPState as PC1MedicalProviderState
					, lmppc1.MPZip as PC1MedicalProviderZIP
					, lmppc1.MPPhone as PC1MedicalProviderPhone
					, case when mpfup.FUDate is not null and PCDate is not null and mpfup.FUDate >= PCDate
						-- follow-up form date is greater than change form / intake date
						then 
							case when FUPC1HasMedicalProvider is not null and FUPC1HasMedicalProvider = '1' 
										and PC1MedicalFacilityFK is not null and PC1MedicalFacilityFK > 0
								then case when lmfpc1.MFName is not null and lmfpc1.MFName <> ''
											then lmfpc1.MFName
											else 'Name not specified'
										end
							else 'None'
							end
						when (mpfup.FUDate is not null and PCDate is not null and mpfup.FUDate < PCDate)
								or  (mpfup.FUDate is null and PCDate is not null)
						-- there is either no follow-up, or the change form / intake date is later so use that data
						then
							case when PCPC1HasMedicalProvider is not null and PCPC1HasMedicalProvider = '1' 
										and PC1MedicalFacilityFK is not null and PC1MedicalFacilityFK > 0
							then lmfpc1.MFName
							else 'None'
							end
					else 'None'
					end as PC1MedicalFacilityName
					, lmfpc1.MFAddress as PC1MedicalFacilityAddress
					, lmfpc1.MFCity as PC1MedicalFacilityCity
					, lmfpc1.MFState as PC1MedicalFacilityState
					, lmfpc1.MFZip as PC1MedicalFacilityZIP
					, lmfpc1.MFPhone as PC1MedicalFacilityPhone
					, case when mpfup.FUDate is not null and PCDate is not null and mpfup.FUDate >= PCDate
							-- follow-up form date is greater than change form / tcid date
							then case when FUPC1HasMedicalProvider is not null and FUPC1HasMedicalProvider = '1' 
											and PC1MedicalProviderFK is not null and PC1MedicalProviderFK > 0
										then 'FollowUp-' + mpfup.FUFormInterval
										else 'No Provider/Facility: FU-' + mpfup.FUFormInterval
							end
						else
							case when PC1MedicalProviderFK is not null or PC1MedicalFacilityFK is not null
										then 'From: ' + rtrim(mppc.PCFormType) + '-' + convert(varchar(8),mppc.PCDate,1)
										else 'No Provider/Facility: ' + rtrim(mppc.PCFormType) + '-' + convert(varchar(8),mppc.PCDate,1)
							end
						end as PC1MedicalInfoForm
					, case when mptcfu.FUDate is not null and TCDate is not null and mptcfu.FUDate >= TCDate
						then
							case when mptcfu.TCHasMedicalProvider is not null and mptcfu.TCHasMedicalProvider = '1' 
										and TCMedicalProviderFK is not null and TCMedicalProviderFK > 0
								then case when (lmptc.MPLastName is null or lmptc.MPLastName = '')
												and (lmptc.MPFirstName is null or lmptc.MPFirstName = '') 
										then 'Name not specified'
										else rtrim(lmptc.MPLastName) + 
											case when lmptc.MPFirstName is not null and lmptc.MPFirstName <> ''
												then ', ' + rtrim(lmppc1.MPFirstName)
												else ''
											end
									end
							end
						when (mptcfu.FUDate is not null and TCDate is not null and mptcfu.FUDate < TCDate)
								or  (mptcfu.FUDate is null and TCDate is not null)
							-- there is either no follow-up, or the change form / tcid date is later so use that data
							then 
							case when mptc.TCHasMedicalProvider is not null and mptc.TCHasMedicalProvider = '1' 
										and TCMedicalProviderFK is not null and TCMedicalProviderFK > 0
								then case when (lmptc.MPLastName is null or lmptc.MPLastName = '')
												and (lmptc.MPFirstName is null or lmptc.MPFirstName = '') 
										then 'Name not specified'
										else rtrim(lmptc.MPLastName) + 
											case when lmptc.MPFirstName is not null and lmptc.MPFirstName <> ''
												then ', ' + rtrim(lmptc.MPFirstName)
												else ''
											end
									end
								else 'None'
								end
					else 'None'
					end as TCMedicalProviderName
					, lmptc.MPAddress as TCMedicalProviderAddress
					, lmptc.MPCity as TCMedicalProviderCity
					, lmptc.MPState as TCMedicalProviderState
					, lmptc.MPZip as TCMedicalProviderZIP
					, lmptc.MPPhone as TCMedicalProviderPhone
					, case when mptcfu.FUDate is not null and TCDate is not null and mptcfu.FUDate >= TCDate
						then
							case when mptcfu.TCHasMedicalProvider is not null and mptcfu.TCHasMedicalProvider = '1' 
										and TCMedicalFacilityFK is not null and TCMedicalFacilityFK > 0
								then case when (lmftc.MFName is null or lmftc.MFName = '')
										then 'Name not specified'
										else lmftc.MFName
									end
							else 'None'
							end
						when (mptcfu.FUDate is not null and TCDate is not null and mptcfu.FUDate < TCDate)
								or  (mptcfu.FUDate is null and TCDate is not null)
							-- there is either no follow-up, or the change form / tcid date is later so use that data
							then
								case when mptc.TCHasMedicalProvider is not null and mptc.TCHasMedicalProvider = '1' 
										and TCMedicalFacilityFK is not null and TCMedicalFacilityFK > 0
								then case when (lmftc.MFName is null or lmftc.MFName = '')
										then 'Name not specified'
										else lmftc.MFName
									end
								else 'None'
								end
						else 'None'
						end
					as TCMedicalFacilityName
					, lmftc.MFAddress as TCMedicalFacilityAddress
					, lmftc.MFCity as TCMedicalFacilityCity
					, lmftc.MFState as TCMedicalFacilityState
					, lmftc.MFZip as TCMedicalFacilityZIP
					, lmftc.MFPhone as TCMedicalFacilityPhone
					, case when mptcfu.FUDate is not null and TCDate is not null and mptcfu.FUDate >= TCDate
							then case when mptcfu.TCHasMedicalProvider is not null and mptcfu.TCHasMedicalProvider = '1' 
											and TCMedicalProviderFK is not null and TCMedicalProviderFK > 0
										then 'FollowUp-' + mptcfu.FUFormInterval
										else 'No Provider/Facility: FU-' + mptcfu.FUFormInterval
							end
						else
							case when TCMedicalProviderFK is not null or TCMedicalFacilityFK is not null
										then 'From: ' + rtrim(mptc.TCFormType) + '-' + convert(varchar(8),mptc.TCDate,1)
										else 'No Provider/Facility: ' + rtrim(mptc.TCFormType) + '-' + convert(varchar(8),mptc.TCDate,1)
							end
						end as TCMedicalInfoForm
			from cteMPPC mppc
			left outer join cteMPTC mptc on mptc.HVCaseFK = mppc.HVCaseFK
			left outer join cteMPTCFU mptcfu on mptcfu.HVCaseFK = mppc.HVCaseFK
			left outer join cteMPFUP mpfup on mpfup.HVCaseFK = mppc.HVCaseFK
			left outer join listMedicalProvider lmppc1 on lmppc1.listMedicalProviderPK = mppc.PC1MedicalProviderFK
			left outer join listMedicalProvider lmptc on lmptc.listMedicalProviderPK = mptc.TCMedicalProviderFK
			left outer join listMedicalFacility lmfpc1 on lmfpc1.listMedicalFacilityPK = mppc.PC1MedicalFacilityFK
			left outer join listMedicalFacility lmftc on lmftc.listMedicalFacilityPK = mptc.TCMedicalFacilityFK
		)
	, cteFormReview
	as
		(-- get all the data we need to render FormReview info
		select frfl.FormType
			 , frfl.FormFK
			 , frfl.IsReviewRequired
			 , frfl.IsFormReviewed
		from  FormReviewFormList(@HVCaseFK) frfl
		)

--select * from cteFormReview
	, cteRawFormApprovals
	as
		(
			select distinct cf.codeFormAbbreviation as FormType
					, replace(replace(codeFormName, ' ', ''), '-', '') as FormName
					, coalesce(max(IsReviewRequired) over (partition by cf.codeFormAbbreviation), 0) as ReviewOn
					, coalesce(min(IsFormReviewed)  over (partition by cf.codeFormAbbreviation), 1) as FormsReviewed
			from cteFormReview fr
			right outer join codeForm cf on cf.codeFormAbbreviation = fr.FormType
			group by cf.codeFormAbbreviation, replace(replace(codeFormName, ' ', ''), '-', ''), IsReviewRequired, IsFormReviewed
			--select distinct cf.codeFormName
			--		, max(IsReviewRequired) over (partition by cf.codeFormName) as ReviewOn
			--		, min(IsFormReviewed) over (partition by cf.codeFormName) as FormsReviewed
			--from cteFormReview fr
			--inner join codeForm cf on cf.codeFormAbbreviation = fr.FormType
			--group by cf.codeFormName, IsReviewRequired, IsFormReviewed
		)

	--select * from cteRawFormApprovals
	
	, cteFormApprovals	
	as
		(
			select HVScreen_ReviewOn = (select ReviewOn from cteRawFormApprovals where FormType = 'SC')
				, HVScreen_FormsReviewed = (select FormsReviewed from cteRawFormApprovals where FormType = 'SC')
				, Preassessment_ReviewOn = (select ReviewOn from cteRawFormApprovals where FormType = 'PA')
				, Preassessment_FormsReviewed = (select FormsReviewed from cteRawFormApprovals where FormType = 'PA')
				, Kempe_ReviewOn = (select ReviewOn from cteRawFormApprovals where FormType = 'KE')
				, Kempe_FormsReviewed = (select FormsReviewed from cteRawFormApprovals where FormType = 'KE')
				, Preintake_ReviewOn = (select ReviewOn from cteRawFormApprovals where FormType = 'PI')
				, Preintake_FormsReviewed = (select FormsReviewed from cteRawFormApprovals where FormType = 'PI')
				, IDContact_ReviewOn = (select ReviewOn from cteRawFormApprovals where FormType = 'ID')
				, IDContact_FormsReviewed = (select FormsReviewed from cteRawFormApprovals where FormType = 'ID')
				, TCID_ReviewOn = (select ReviewOn from cteRawFormApprovals where FormType = 'TC')
				, TCID_FormsReviewed = (select FormsReviewed from cteRawFormApprovals where FormType = 'TC')
				, Intake_ReviewOn = (select ReviewOn from cteRawFormApprovals where FormType = 'IN')
				, Intake_FormsReviewed = (select FormsReviewed from cteRawFormApprovals where FormType = 'IN')
				, TCMedical_ReviewOn = (select ReviewOn from cteRawFormApprovals where FormType = 'TM')
				, TCMedical_FormsReviewed = (select FormsReviewed from cteRawFormApprovals where FormType = 'TM')
				, HomeVisitLog_ReviewOn = (select ReviewOn from cteRawFormApprovals where FormType = 'VL')
				, HomeVisitLog_FormsReviewed = (select FormsReviewed from cteRawFormApprovals where FormType = 'VL')
				, ServiceReferral_ReviewOn = (select ReviewOn from cteRawFormApprovals where FormType = 'SR')
				, ServiceReferral_FormsReviewed = (select FormsReviewed from cteRawFormApprovals where FormType = 'SR')
				, ASQ_ReviewOn = (select ReviewOn from cteRawFormApprovals where FormType = 'AQ')
				, ASQ_FormsReviewed = (select FormsReviewed from cteRawFormApprovals where FormType = 'AQ')
				, ASQSE_ReviewOn = (select ReviewOn from cteRawFormApprovals where FormType = 'AS')
				, ASQSE_FormsReviewed = (select FormsReviewed from cteRawFormApprovals where FormType = 'AS')
				, FollowUp_ReviewOn = (select ReviewOn from cteRawFormApprovals where FormType = 'FU')
				, FollowUp_FormsReviewed = (select FormsReviewed from cteRawFormApprovals where FormType = 'FU')
				, PC1Medical_ReviewOn = (select ReviewOn from cteRawFormApprovals where FormType = 'PM')
				, PC1Medical_FormsReviewed = (select FormsReviewed from cteRawFormApprovals where FormType = 'PM')
				, Discharge_ReviewOn = (select ReviewOn from cteRawFormApprovals where FormType = 'DS')
				, Discharge_FormsReviewed = (select FormsReviewed from cteRawFormApprovals where FormType = 'DS')
				, LevelForm_ReviewOn = (select ReviewOn from cteRawFormApprovals where FormType = 'LV')
				, LevelForm_FormsReviewed = (select FormsReviewed from cteRawFormApprovals where FormType = 'LV')
				, PSI_ReviewOn = (select ReviewOn from cteRawFormApprovals where FormType = 'PS')
				, PSI_FormsReviewed = (select FormsReviewed from cteRawFormApprovals where FormType = 'PS')
				, FatherFigure_ReviewOn = (select ReviewOn from cteRawFormApprovals where FormType = 'FF')
				, FatherFigure_FormsReviewed = (select FormsReviewed from cteRawFormApprovals where FormType = 'FF')
		)
	
	, cteCaseTransferStatus
	as
		(-- get the data related to whether this case was involved in a transfer
		select 'to' as TransferredToFrom
				, ProgramName
				, case when TransferredStatus = 1 then 'Pending'
						when TransferredStatus = 2 then 'Enrolled'
						when TransferredStatus = 3 then 'Not Enrolled (Rejected)'
					end as TransferStatusText
		from CaseProgram cp
		inner join HVProgram hp on hp.HVProgramPK = cp.TransferredtoProgramFK
		where cp.PC1ID = @PC1ID and cp.TransferredtoProgramFK is not null
		union
		select 'from' as TransferredToFrom
				, ProgramName
				, case when TransferredStatus = 1 then 'Pending'
						when TransferredStatus = 2 then 'Enrolled'
						when TransferredStatus = 3 then 'Not Enrolled (Rejected)'
					end as TransferStatusText
		from CaseProgram cp
		inner join HVProgram hp on hp.HVProgramPK = cp.ProgramFK
		where cp.HVCaseFK = @HVCaseFK and PC1ID <> @PC1ID and cp.TransferredtoProgramFK = @ProgramFK
		union
		select '' as TransferredToFrom
				, '' as ProgramName
				, '' as TransferStatusText
		from CaseProgram cp
		inner join HVProgram hp on hp.HVProgramPK = cp.ProgramFK
		where cp.HVCaseFK = @HVCaseFK and cp.TransferredtoProgramFK is null
				and HVCaseFK not in (select HVCaseFK from CaseProgram cp2 group by HVCaseFK having count(cp2.HVCaseFK) > 1)
		)

	select HVCasePK
			, cp.ProgramFK
			, PC1ID
			, hc.CaseProgress
			, hc.ScreenDate
			, hc.EDC
			, hc.TCDOB
			, rtrim(pc.PCFirstName) + ' ' + rtrim(pc.PCLastName) as PC1Name
			, pc.Gender as PC1Gender
			, rtrim(ec.PCFirstName) + ' ' + rtrim(ec.PCLastName) as EmergencyContactName
			, LevelName as CurrentLevelName
			, CurrentLevelDate
			, hc.KempeDate
			, DischargeDate
			, rtrim(obp.PCFirstName) + ' ' + rtrim(obp.PCLastName) as OBPName
			, hc.TCNumber
			--, rtrim(t.TCFirstName) + ' ' + rtrim(t.TCLastName) as TargetChildName
			, TargetChildName
			, rtrim(faw.FirstName) + ' ' + rtrim(faw.LastName) as CurrentFAWName
			, rtrim(fsw.FirstName) + ' ' + rtrim(fsw.LastName) as CurrentFSWName
			, hc.IntakeDate
			, rtrim(pc2.PCFirstName) + ' ' + rtrim(pc2.PCLastName) as PC2Name
			, s.HVScreenPK
			, k.KempePK
			, a.AttachmentPK
			, i.IntakePK
			, OldID
			, HVCaseFK_old
			, CaseStartDate
			, DateOBPAdded
			, HVCaseCreateDate
			, HVCaseCreator
			, HVCaseEditDate
			, HVCaseEditor
			, cfca.FormDate as ChangeFormCommonAttributesFormDate
			, TCIDFormCompleteDate
			, isnull(CountOfPreassessments, 0) as CountOfPreassessments
			, isnull(CountOfPreintakes, 0) as CountOfPreintakes
			, isnull(CountOfServiceReferrals, 0) as CountOfServiceReferrals
			, isnull(CountOfHomeVisitLogs, 0) as CountOfHomeVisitLogs
			, isnull(CountOfPC1MedicalForms, 0) as CountOfPC1MedicalForms
			, isnull(CountOfFatherFigures, 0) as CountOfFatherFigures
			, isnull(CountOfTCIDs, 0) as CountOfTCIDs
			, isnull(CountOfPSIs, 0) as CountOfPSIs
			, isnull(CountOfFollowUps, 0) as CountOfFollowUps
			, isnull(case when charindex('/', CountOfASQs) > 0 
						then CountOfASQs 
						else substring(CountOfASQs, 2, 10) end, 0) as CountOfASQs
			, isnull(case when charindex('/', CountOfASQSEs) > 0 
						then CountOfASQSEs 
						else substring(CountOfASQSEs, 2, 10) end, 0) as CountOfASQSEs
			, isnull(case when charindex('/', CountOfTCMedicalForms) > 0 
						then CountOfTCMedicalForms 
						else substring(CountOfTCMedicalForms, 2, 10) end, 0) as CountOfTCMedicalForms
			, isnull(mpf.PC1MedicalProviderName, 'None') as PC1MedicalProviderName
			, mpf.PC1MedicalProviderAddress
			, mpf.PC1MedicalProviderCity
			, mpf.PC1MedicalProviderState
			, mpf.PC1MedicalProviderZIP
			, mpf.PC1MedicalProviderPhone
			, isnull(mpf.PC1MedicalFacilityName, 'None') as PC1MedicalFacilityName
			, mpf.PC1MedicalFacilityAddress
			, mpf.PC1MedicalFacilityCity
			, mpf.PC1MedicalFacilityState
			, mpf.PC1MedicalFacilityZIP
			, mpf.PC1MedicalFacilityPhone
			, PC1MedicalInfoForm
			, isnull(mpf.TCMedicalProviderName, 'None') as TCMedicalProviderName
			, mpf.TCMedicalProviderAddress
			, mpf.TCMedicalProviderCity
			, mpf.TCMedicalProviderState
			, mpf.TCMedicalProviderZIP
			, mpf.TCMedicalProviderPhone
			, isnull(mpf.TCMedicalFacilityName, 'None') as TCMedicalFacilityName
			, mpf.TCMedicalFacilityAddress
			, mpf.TCMedicalFacilityCity
			, mpf.TCMedicalFacilityState
			, mpf.TCMedicalFacilityZIP
			, mpf.TCMedicalFacilityPhone
			, TCMedicalInfoForm
			--, cfr.FormType
			--, cfr.FormFK
			--, cfr.IsReviewRequired
			--, cfr.IsFormReviewed
			--, cfr.IsApproved
			, cfa.HVScreen_ReviewOn
			, cfa.HVScreen_FormsReviewed
			, cfa.Preassessment_ReviewOn
			, cfa.Preassessment_FormsReviewed
			, cfa.Kempe_ReviewOn
			, cfa.Kempe_FormsReviewed
			, cfa.Preintake_ReviewOn
			, cfa.Preintake_FormsReviewed
			, cfa.IDContact_ReviewOn
			, cfa.IDContact_FormsReviewed
			, cfa.TCID_ReviewOn
			, cfa.TCID_FormsReviewed
			, cfa.Intake_ReviewOn
			, cfa.Intake_FormsReviewed
			, cfa.TCMedical_ReviewOn
			, cfa.TCMedical_FormsReviewed
			, cfa.HomeVisitLog_ReviewOn
			, cfa.HomeVisitLog_FormsReviewed
			, cfa.ServiceReferral_ReviewOn
			, cfa.ServiceReferral_FormsReviewed
			, cfa.ASQ_ReviewOn
			, cfa.ASQ_FormsReviewed
			, cfa.ASQSE_ReviewOn
			, cfa.ASQSE_FormsReviewed
			, cfa.FollowUp_ReviewOn
			, cfa.FollowUp_FormsReviewed
			, cfa.PC1Medical_ReviewOn
			, cfa.PC1Medical_FormsReviewed
			, cfa.Discharge_ReviewOn
			, cfa.Discharge_FormsReviewed
			, cfa.LevelForm_ReviewOn
			, cfa.LevelForm_FormsReviewed
			, cfa.PSI_ReviewOn
			, cfa.PSI_FormsReviewed
			, cfa.FatherFigure_ReviewOn
			, cfa.FatherFigure_FormsReviewed
			, cts.TransferredToFrom
			, cts.ProgramName
			, cts.TransferStatusText
			, CaseProgramCreator
			, CaseProgramCreateDate
			, CaseProgramEditor
			, CaseProgramEditDate
		from HVCase hc
		inner join CaseProgram cp on cp.HVCaseFK = hc.HVCasePK 
		inner join PC pc on pc.PCPK = hc.PC1FK
		left outer join PC ec on ec.PCPK = hc.CPFK
		left outer join PC obp on obp.PCPK = hc.OBPFK
		left outer join PC pc2 on pc2.PCPK = hc.PC2FK
		inner join codeLevel cl on cl.codeLevelPK = cp.CurrentLevelFK
		left outer join Worker fsw on fsw.WorkerPK = cp.CurrentFSWFK
		left outer join Worker faw on faw.WorkerPK = cp.CurrentFAWFK
		inner join HVScreen s on s.HVCaseFK = hc.HVCasePK
		left outer join Kempe k on k.HVCaseFK = hc.HVCasePK
		left outer join Attachment a on a.HVCaseFK = cp.HVCaseFK and k.KempePK = a.FormFK and a.FormType = 'KE'
		-- left outer join TCID t on t.HVCaseFK = hc.HVCasePK
		left outer join Intake i on i.HVCaseFK = hc.HVCasePK
		left outer join CommonAttributes cfca on cfca.HVCaseFK = hc.HVCasePK and cfca.FormFK = cp.CaseProgramPK and cfca.FormType = 'CH'
		--left outer join CommonAttributes pc1ca on pc1ca.HVCaseFK = hc.HVCasePK and pc1ca.FormFK = i.IntakePK and pc1ca.FormType = 'IN'
		--left outer join CommonAttributes tcca on tcca.HVCaseFK = hc.HVCasePK and tcca.FormFK = t.TCIDPK and tcca.FormType = 'TC'
		left outer join cteMedicalProviders_Facilities mpf on 1 = 1
		inner join ctePreAssessmentCount on 1 = 1
		inner join ctePreIntakeCount on 1 = 1
		inner join cteServiceReferralCount on 1 = 1
		inner join cteHomeVisitLogCount on 1 = 1
		inner join ctePC1MedicalCount on 1 = 1
		inner join cteFatherFigureCount on 1 = 1
		inner join cteTCIDCount on 1 = 1
		inner join ctePSICount on 1 = 1
		inner join cteFollowUpCount on 1 = 1
		inner join cteTargetChildFormCompleteDate on 1=1
		inner join cteTargetChildren_Flattened on 1=1
		inner join cteASQCount on 1 = 1
		inner join cteASQSECount on 1 = 1
		inner join cteTCMedicalCount on 1 = 1
		--inner join cteFormReview cfr on 1 = 1
		--inner join FormReview fr on fr.FormFK = cfr.FormFK and fr.FormType = cfr.FormType
		inner join cteFormApprovals cfa on 1=1
		--left outer join ctePC on ctePC.HVCaseFK = hc.HVCasePK
		--left outer join cteTC on cteTC.HVCaseFK = hc.HVCasePK
		--left outer join cteTCFU on cteTCFU.HVCaseFK = hc.HVCasePK
		--left outer join cteFUP on cteFUP.HVCaseFK = hc.HVCasePK
		inner join cteCaseTransferStatus cts on 1=1 
		where PC1ID = @PC1ID

end
GO
