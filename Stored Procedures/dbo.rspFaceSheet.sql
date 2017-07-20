SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Jay Robohn> <dar chen>
-- Create date: <Jan 25, 2012>
-- Description:	<Face Sheet report>
-- =============================================
CREATE procedure [dbo].[rspFaceSheet]
(
    @ProgramFK varchar(max) = null,
    @PC1ID char(13) = null,
    @WorkerFK INT = null,
    @FAWFK INT = null, 
    @SupervisorFK INT = null
)
as
begin

--DECLARE @ProgramFK VARCHAR(MAX) = N'1'
--DECLARE @PC1ID CHAR(13) = N'DS83010203701'
--DECLARE @WorkerFK INT = NULL
--DECLARE	@FAWFK INT = NULL
--DECLARE @SupervisorFK INT = NULL


	if @ProgramFK is null
	begin
		select @ProgramFK = substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end;

	if @PC1ID = ''
	begin
		set @PC1ID = null
	end;

	with cteMain
	as (select HVCasePK
			  ,PC1ID
			  ,CurrentFSWFK
			  ,CurrentLevelFK
			  ,LevelName
			  ,CurrentLevelDate
			  ,case
				   when IntakeDate is null then
					   0
				   else
					   case
						   when DischargeDate is null then
							   datediff(day,CurrentLevelDate,getdate())
						   else
							   datediff(day,CurrentLevelDate,DischargeDate)
					   end
			   end as DaysOnCurrentLevel
			  ,isnull(datediff(month,IntakeDate,getdate()),000) as MonthsInProgram
			  ,ScreenDate
			  ,c.KempeDate
			  ,IntakeDate
			  ,DischargeDate
			  ,cd.DischargeReason as DischargeReasonName
			  ,CaseProgress
			  ,isnull(PC1FK,0) as PC1FK
			  ,isnull(OBPFK,0) as OBPFK
			  ,CASE WHEN OBPinHomeIntake = 1 THEN 'Yes' ELSE '' END [OBPinHomeIntake]
			  ,isnull(PC2FK,0) as PC2FK
			  ,CASE WHEN PC2inHomeIntake = 1 THEN 'Yes' ELSE '' END [PC2inHomeIntake]
			  ,c.PC2Relation2TC
			  ,isnull(CPFK,0) as CPFK
			  ,rtrim(PC1.PCFirstName)+' '+rtrim(PC1.PCLastName) as PC1FullName
			  ,rtrim(PC1.PCStreet)+case
									   when PC1.PCApt is null or PC1.PCApt = '' then
										   ''
									   else
										   ' (Apt. '+replace(replace(PC1.PCApt,'Apt.',''),'Apt','')+')'
								   end as PC1Street
			  ,rtrim(PC1.PCCity)+', '+isnull(PC1.PCState,'NY')+'  '+rtrim(PC1.PCZip) as PC1CSZ
			  ,PC1.PCPhone
			  ,PC1.PCCellPhone
			  ,case
				   when PC1.SSNo is null then
					   'Not on file'
				   else
					   'On file'
			   end as SocialSecurityNumberOnFile
			  ,PC1.PCDOB
			  ,floor(datediff(day,PC1.PCDOB,getdate())/365.25) as CurrentAge
			  ,floor(datediff(day,PC1.PCDOB,IntakeDate)/365.25) as AgeAtIntake
			  ,rtrim(w.FirstName)+' '+rtrim(w.LastName) as WorkerName
			  ,rtrim(w.LastName)+', '+rtrim(w.FirstName) as WorkerNameLast
			  ,w.FirstName
			  ,w.LastName
			  ,rtrim(wk.FirstName)+' '+rtrim(wk.Lastname) as FAWName
			  ,rtrim(sup.FirstName)+' '+rtrim(sup.LastName) as SupervisorName
			  ,MomScore
			  ,DadScore
			  ,k.FAWFK
			  ,rtrim(PCOBP.PCFirstName)+' '+rtrim(PCOBP.PCLastName) as OBPFullName
			  ,PCOBP.PCDOB as OBPDOB
			  ,CASE WHEN PCOBP.Gender = '01' THEN 'Female' 
			  WHEN PCOBP.Gender = '02' THEN 'Male' ELSE '' END  as OBPGender
			  ,rtrim(PCPC2.PCFirstName)+' '+rtrim(PCPC2.PCLastName) as PC2FullName
			  ,PCPC2.PCDOB as PC2DOB
	    	   ,CASE WHEN PCPC2.Gender = '01' THEN 'Female' 
			  WHEN PCPC2.Gender = '02' THEN 'Male' ELSE '' END  as PC2Gender
			  ,rtrim(PCCP.PCFirstName)+' '+rtrim(PCCP.PCLastName) as CPFullName
			  ,rtrim(PCCP.PCStreet)+case
										when PCCP.PCApt is null or PCCP.PCApt = '' then
											''
										else
											' (Apt. '+replace(replace(PCCP.PCApt,'Apt.',''),'Apt','')+')'
									end as CPStreet
			  ,rtrim(PCCP.PCCity)+', '+isnull(PCCP.PCState,'NY')+'  '+rtrim(PCCP.PCZip) as CPCSZ
			  ,PCCP.PCDOB as CPDOB
			  ,PCCP.PCPhone as CPPhone
			  ,TCIDPK
			  ,rtrim(TCFirstName)+' '+rtrim(TCLastName) as TCFullName
			  ,t.TCDOB
			  ,case
				   when TCGender = '01' then
					   'Female'
				   when TCGender = '02' then
					   'Male'
			   end as TCGender
			  ,floor((datediff(day,t.TCDOB,getdate()))/30.44) as TCChronologicalAge
			  ,GestationalAge
			  ,floor(((datediff(day,t.TCDOB,getdate()))-((40-GestationalAge)*7))/30.44) as TCDevelopmentalAge
			  ,NumberOfChildren
			  --,IIF(!EMPTY(tc_ssn) and !ISNULL(tc_ssn),"On file    ","Not on file") as tcss_of, ;
			   ,case
					when t.TCDOD is null then
						0
					else
						1
				end as TCDeceased
			from HVCase c
				inner join CaseProgram cp on cp.HVCaseFK = c.HVCasePK
				inner join PC PC1 on PC1.PCPK = c.PC1FK
				inner join dbo.SplitString(@ProgramFK,',') on cp.programfk = listitem
				left outer join PC PCOBP on PCOBP.PCPK = c.OBPFK
				left outer join PC PCPC2 on PCPC2.PCPK = c.PC2FK
				left outer join PC PCCP on PCCP.PCPK = c.CPFK
				left outer join Kempe k on k.HVCaseFK = c.HVCasePK
				left outer join Worker wk on wk.WorkerPK = k.FAWFK
				left outer join Worker w on w.WorkerPK = cp.CurrentFSWFK
				left outer join WorkerProgram wp on wp.WorkerFK = w.WorkerPK
				left outer join Worker sup on sup.WorkerPK = wp.SupervisorFK
				left outer join TCID t on t.HVCaseFK = c.HVCasePK AND t.TCDOD IS NULL
				left outer join codeLevel cl on cl.codeLevelPK = cp.CurrentLevelFK
				left outer join codeDischarge cd on cd.DischargeCode = cp.DischargeReason
	
			where PC1ID = isnull(@PC1ID,PC1ID)
				AND (CASE WHEN @PC1ID IS NOT NULL THEN 1 ELSE 
				CASE WHEN cp.DischargeDate IS NOT NULL THEN 0 ELSE 1 END END = 1)
				 and isnull(CurrentFSWFK,0) = isnull(isnull(@WorkerFK,CurrentFSWFK),0)
				 and isnull(CurrentFAWFK,0) = isnull(isnull(@FAWFK,CurrentFAWFK),0)
				 and isnull(sup.WorkerPK,0) = isnull(isnull(@SupervisorFK,sup.WorkerPK),0)
				 and caseprogress >= 6
				 
	-- and PC1ID='SP80040113929'
	),
	
	
	cteFSWAssignDate
	as (select HVCaseFK
			  ,max(WorkerAssignmentDate) as FSWAssignDate
			from WorkerAssignment wa
				inner join cteMain on HVCaseFK = HVCasePK
			where WorkerFK = CurrentFSWFK
			group by HVCaseFK
	), 
	
	
-- PC1 Medical Insurance, Benefits, TANF service eligible (xx1)
	
-- PC1 Medical Insurance, Benefits, TANF service eligible (xx1)
pc1MedicalInsurance
AS (
SELECT hh.HVCaseFK
, convert(VARCHAR(MAX), ca.FormDate, 101) [PC1FormDate]
, CASE WHEN ca.PC1ReceivingMedicaid = '1' THEN 'MA' 
WHEN ca.HIFamilyChildHealthPlus = 1 THEN 'HealthPlus'
WHEN ca.HIPrivate = 1 THEN 'Private'
WHEN ca.HIUninsured = 1 THEN 'Uninsured'
WHEN ca.HIUnknown = 1 THEN 'Other'
WHEN ca.HIOther = 1 THEN 'Other'
ELSE '' END [PC1MedicalInsurance]
, case when HIMedicaidCaseNumber is not null and HIMedicaidCaseNumber <> '' THEN 'On File' ELSE 'Not on file' END [PC1MAOnFile]
, CASE WHEN ca.PBEmergencyAssistance = '1' THEN 'EA ' ELSE '' END +
CASE WHEN ca.PBFoodStamps = '1' THEN 'FS ' ELSE '' END +
CASE WHEN ca.PBSSI = '1' THEN 'SSI ' ELSE '' END +
Case WHEN ca.PBTANF = '1' THEN 'TANF ' ELSE '' END +
Case WHEN ca.PBWIC = '1' THEN 'WIC' ELSE '' END [PC1Benefits]
, CASE WHEN  ca.TANFServices = 1 THEN 'Yes' 
WHEN ca.TANFServices = 0 THEN (
CASE WHEN ca.TANFServicesNo = '01' THEN 'No-Income above 200% of Poverty'                                                                       
WHEN ca.TANFServicesNo = '02' THEN 'No-Immigration Status'
WHEN ca.TANFServicesNo = '03' THEN 'No-Refused to complete application'
WHEN ca.TANFServicesNo = '04' THEN 'No-' + ca.TANFServicesNoSpecify
ELSE 'No' END
)
ELSE '' END [TANFServiceEligible]
FROM(
SELECT HVCaseFK, cast(substring(maxkey, 9, 10) AS INT) CommonAttributesPK
FROM (SELECT HVCaseFK,
max(convert(VARCHAR(max), FormDate, 112) + cast(CommonAttributesPK AS VARCHAR(max))) [maxkey]
FROM CommonAttributes
WHERE FormType IN ('IN', 'FU')
GROUP BY HVCaseFK) AS xyz) AS hh
LEFT OUTER JOIN CommonAttributes ca ON hh.CommonAttributesPK = ca.CommonAttributesPK 
),

pc1DoctorClinic
AS (
-- PC1 Doctor name/phone and Facility name/phone (xx2)
SELECT hh.HVCaseFK --, ca.PC1MedicalFacilityFK, ca.PC1MedicalProviderFK
,rtrim(lmf.MFName) [PC1Cllinic]
--,rtrim(lmp.MPFirstName) + ' ' + rtrim(lmp.MPLastName) [PC1DoctorName]
,rtrim(isnull(lmp.MPFirstName,'')) + ' ' + rtrim(isnull(lmp.MPLastName,'')) [PC1DoctorName]
,lmp.MPPhone [PC1DoctorPhone]
FROM(
SELECT HVCaseFK, cast(substring(maxkey, 9, 10) AS INT) CommonAttributesPK
FROM (SELECT HVCaseFK,
max(convert(VARCHAR(max), FormDate, 112) + cast(CommonAttributesPK AS VARCHAR(max))) [maxkey]
FROM CommonAttributes
WHERE FormType IN ('IN', 'CH')
GROUP BY HVCaseFK) AS xyz) AS hh --ON	hh.HVCaseFK = c.HVCasePK
LEFT OUTER JOIN CommonAttributes ca ON hh.CommonAttributesPK = ca.CommonAttributesPK 
LEFT OUTER JOIN listMedicalFacility lmf ON ca.PC1MedicalFacilityFK = lmf.listMedicalFacilityPK
LEFT OUTER JOIN listMedicalProvider lmp ON ca.PC1MedicalProviderFK = lmp.listMedicalProviderPK
),


TCDoctorClinic
AS (
-- TC Doctor name/phone and Facility name/phone (xx3)
SELECT hh.HVCaseFK --ca.TCMedicalFacilityFK, ca.TCMedicalProviderFK
,rtrim(lmf.MFName) [TCClinic]
--,rtrim(lmp.MPFirstName) + ' ' + rtrim(lmp.MPLastName) [TCDoctorName]
,rtrim(isnull(lmp.MPFirstName,'')) + ' ' + rtrim(isnull(lmp.MPLastName,'')) [TCDoctorName]
,lmp.MPPhone [TCDoctorPhone]
FROM(
SELECT HVCaseFK, cast(substring(maxkey, 9, 10) AS INT) CommonAttributesPK
FROM (SELECT HVCaseFK,
max(convert(VARCHAR(max), FormDate, 112) + cast(CommonAttributesPK AS VARCHAR(max))) [maxkey]
FROM CommonAttributes
WHERE FormType IN ('CH', 'TC')
GROUP BY HVCaseFK) AS xyz) AS hh
LEFT OUTER JOIN CommonAttributes ca ON hh.CommonAttributesPK = ca.CommonAttributesPK 
LEFT OUTER JOIN listMedicalFacility lmf ON ca.TCMedicalFacilityFK = lmf.listMedicalFacilityPK
LEFT OUTER JOIN listMedicalProvider lmp ON ca.TCMedicalProviderFK = lmp.listMedicalProviderPK
),

TCMedicalInsurance
AS (
-- TC Doctor name/phone and Facility name/phone (xx3)
SELECT hh.HVCaseFK 
, CASE WHEN ca.TCReceivingMedicaid = '1' THEN 'MA' 
WHEN ca.TCHIFamilyChildHealthPlus = 1 THEN 'HealthPlus'
WHEN ca.TCHIPrivateInsurance = 1 THEN 'Private'
WHEN ca.TCHIUninsured = 1 THEN 'Uninsured'
WHEN ca.TCHIUnknown = 1 THEN 'Other'
WHEN ca.TCHIOther = 1 THEN 'Other'
ELSE '' END [TCMedicalInsurance]
, case when ca.TCHIMedicaidCaseNumber is not null and ca.TCHIMedicaidCaseNumber <> '' then 'On File'  ELSE 'Not on file' END [TCMAOnFile]
FROM(
SELECT HVCaseFK, cast(substring(maxkey, 9, 10) AS INT) CommonAttributesPK
FROM (SELECT HVCaseFK,
max(convert(VARCHAR(max), FormDate, 112) + cast(CommonAttributesPK AS VARCHAR(max))) [maxkey]
FROM CommonAttributes
WHERE FormType IN ('FU', 'TC')
GROUP BY HVCaseFK) AS xyz) AS hh
LEFT OUTER JOIN CommonAttributes ca ON hh.CommonAttributesPK = ca.CommonAttributesPK 
),

TCASQ
AS (
-- TC ASQ (xx4)
SELECT hh.HVCaseFK
, cast(cast(ASQ.TCAge AS INT) AS VARCHAR(5)) + ' months' [TCASQMonths]
, convert(VARCHAR(max), ASQ.DateCompleted, 101) [TCASQDate]
, CASE WHEN UnderCommunication = 1 THEN 'COM ' ELSE '' END +
CASE WHEN UnderFineMotor = 1 THEN 'FM ' ELSE '' END +
CASE WHEN UnderGrossMotor = 1 THEN 'GM ' ELSE '' END +
CASE WHEN UnderPersonalSocial = 1 THEN 'PS ' ELSE '' END +
CASE WHEN UnderProblemSolving = 1 THEN 'PBS' ELSE '' END [TCASQAREA]
FROM (SELECT HVCaseFK, cast(substring(maxkey, 9, 10) AS INT) ASQPK
FROM (SELECT HVCaseFK
,max(convert(VARCHAR(max), DateCompleted, 112) + cast(ASQPK AS VARCHAR(max))) [maxkey]
FROM ASQ
WHERE UnderCommunication = 1 or UnderFineMotor = 1 OR
UnderGrossMotor = 1 OR UnderPersonalSocial = 1 OR
UnderProblemSolving = 1
GROUP BY HVCaseFK) xyz ) hh
JOIN ASQ ON ASQ.ASQPK = hh.ASQPK
),

pc1pc2InHome
AS (
-- PC1 and PC2 InHome from FollowUp table (xx5)
SELECT hh.HVCaseFK
, CASE WHEN fu.PC1InHome IS NULL THEN '' 
  WHEN fu.PC1InHome = 1 THEN 'Yes' ELSE 'No' END [PC1InHome]
, CASE WHEN fu.PC2InHome IS NULL THEN ''
  WHEN fu.PC2InHome = 1 THEN 'Yes' ELSE 'No' END [PC2InHome]
FROM (SELECT HVCaseFK, cast(substring(maxkey, 9, 10) AS INT) FollowUpPK
FROM (SELECT HVCaseFK,
max(convert(VARCHAR(max), FollowUpDate, 112) + cast(FollowUpPK AS VARCHAR(max))) [maxkey]
FROM FollowUp 
GROUP BY HVCaseFK) xyz) hh
JOIN FollowUp fu ON fu.FollowUpPK = hh.FollowUpPK
)

select Main.HVCasePK
	  ,Main.PC1ID
	  ,Main.CurrentFSWFK
	  ,Main.CurrentLevelFK
	  ,Main.LevelName
	  ,Main.CurrentLevelDate
	  ,Main.DaysOnCurrentLevel
	  ,Main.MonthsInProgram
	  ,Main.ScreenDate
	  ,Main.KempeDate
	  ,Main.IntakeDate
	  ,Main.DischargeDate
	  ,Main.DischargeReasonName
	  ,Main.CaseProgress
	  ,Main.PC1FK
	  ,Main.OBPFK
	  ,Main.OBPinHomeIntake
	  ,Main.PC2FK
	  ,Main.PC2inHomeIntake
	  ,a1.AppCodeText AS PC2Relation2TC
	  ,Main.CPFK
	  ,Main.PC1FullName
	  ,Main.PC1Street
	  ,Main.PC1CSZ
	  ,Main.PCPhone
	  ,Main.PCCellPhone
	  ,Main.SocialSecurityNumberOnFile
	  ,Main.PCDOB
	  ,Main.CurrentAge
	  ,Main.AgeAtIntake
	  ,Main.WorkerName
	  ,Main.WorkerNameLast
	  ,Main.FirstName
	  ,Main.LastName
	  ,Main.FAWName
	  ,Main.SupervisorName
	  ,Main.MomScore
	  ,Main.DadScore
	  ,Main.FAWFK
	  ,Main.OBPFullName
	  ,Main.OBPDOB
	  ,Main.OBPGender
	  ,Main.PC2FullName
	  ,Main.PC2DOB
	  ,Main.PC2Gender
	  ,Main.CPFullName
	  ,Main.CPStreet
	  ,Main.CPCSZ
	  ,Main.CPDOB
	  ,Main.CPPhone
	  ,Main.TCIDPK
	  ,Main.TCFullName
	  ,Main.TCDOB
	  ,Main.TCGender
	  ,Main.TCChronologicalAge
	  ,Main.GestationalAge
	  ,Main.TCDevelopmentalAge
	  ,Main.NumberofChildren
	  ,Main.TCDeceased
	  ,FSWAssignDate
	  
	  ,xx1.[PC1FormDate]
	  ,xx1.[PC1MedicalInsurance]
	  ,xx1.[PC1MAOnFile]
	  ,xx1.[PC1Benefits]
	  ,xx1.[TANFServiceEligible]
	  
	  ,xx2.[PC1Cllinic]
	  ,xx2.[PC1DoctorName]
	  ,xx2.[PC1DoctorPhone]
	  
	  ,xx3.[TCClinic]
	  ,xx3.[TCDoctorName]
	  ,xx3.[TCDoctorPhone]
	  ,xx31.[TCMedicalInsurance]
	  ,xx31.[TCMAOnFile]
	  
	  ,xx4.[TCASQMonths]
	  ,xx4.[TCASQDate]
	  ,xx4.[TCASQAREA]
	
	  ,xx5.[PC1InHome]
	  ,xx5.[PC2InHome]
	  
	from cteMain Main
		inner join cteFSWAssignDate on HVCaseFK = HVCasePK
		LEFT OUTER JOIN codeApp a1 ON a1.AppCode = Main.PC2Relation2TC AND a1.AppCodeGroup = 'Relation'
		
		LEFT OUTER JOIN pc1MedicalInsurance xx1 ON xx1.HVCaseFK = Main.HVCasePK
		LEFT OUTER JOIN pc1DoctorClinic xx2 ON xx2.HVCaseFK = Main.HVCasePK
		LEFT OUTER JOIN TCDoctorClinic xx3 ON xx3.HVCaseFK = Main.HVCasePK
		LEFT OUTER JOIN TCMedicalInsurance xx31 ON xx31.HVCaseFK = Main.HVCasePK
		LEFT OUTER JOIN TCASQ xx4 ON xx4.HVCaseFK = Main.HVCasePK
		LEFT OUTER JOIN pc1pc2InHome xx5 ON xx5.HVCaseFK = Main.HVCasePK
		
		
	order by LastName
			,FirstName
			,PC1ID
			
			
			
			
			
END;
GO
