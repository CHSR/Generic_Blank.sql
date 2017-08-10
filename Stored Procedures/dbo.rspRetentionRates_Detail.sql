SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jrobohn
-- Create date: 03/31/11
-- Description:	Derived from main storedproc for Retention Rate report - this is the details
-- =============================================
-- Author:    <Jay Robohn>
-- Description: <copied from FamSys Feb 20, 2012 - see header below>
-- exec rspRetentionRates_Detail 1, '20090501', '20110430'
-- exec rspRetentionRates_Detail 37, '20090401', '20110331'
-- exec rspRetentionRates_Detail 13, '20090401', '20110331'

-- exec rspRetentionRatesByDischargeReason 1, '03/01/10', '02/29/12'
-- Fixed Bug HW963 - Retention Rage Report ... Khalsa 3/20/2014
-- =============================================
CREATE PROCEDURE [dbo].[rspRetentionRates_Detail]
	-- Add the parameters for the stored procedure here
	@ProgramFK varchar(max), @StartDate DATETIME, @EndDate DATETIME
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--#region declarations
	declare @tblResults table (
		LineDescription varchar(50)
		, LineGroupingLevel int
		, DisplayPercentages bit
		, TotalEnrolledParticipants int
		, RetentionRateSixMonths decimal(5,3)
		, RetentionRateOneYear decimal(5,3)
		, RetentionRateEighteenMonths decimal(5,3)
		, RetentionRateTwoYears decimal(5,3)
		, EnrolledParticipantsSixMonths int
		, EnrolledParticipantsOneYear int
		, EnrolledParticipantsEighteenMonths int
		, EnrolledParticipantsTwoYears int
		, RunningTotalDischargedSixMonths int
		, RunningTotalDischargedOneYear int
		, RunningTotalDischargedEighteenMonths int
		, RunningTotalDischargedTwoYears int
		, TotalNSixMonths int
		, TotalNOneYear int
		, TotalNEighteenMonths int
		, TotalNTwoYears int
		, AllParticipants int
		, SixMonthsIntake int
		, SixMonthsDischarge int
		, OneYearIntake int 
		, OneYearDischarge int
		, EighteenMonthsIntake int
		, EighteenMonthsDischarge int
		, TwoYearsIntake int
		, TwoYearsDischarge int);
	
	declare @tblPC1withStats table (
		PC1ID char(13)
		, HVCaseFK int
		, OldID char(23)
		, HVCaseFK_old int
		, IntakeDate datetime
		, DischargeDate datetime
		, DischargeReasonCode char(3)
		, DischargeReason char(100)
		, LastHomeVisit datetime
		, RetentionMonths int
		, ActiveAt6Months int
		, ActiveAt12Months int
		, ActiveAt18Months int
		, ActiveAt24Months int
		, AgeAtIntake_Under18 int
		, AgeAtIntake_18UpTo20 int
		, AgeAtIntake_20UpTo30 int
		, AgeAtIntake_Over30 int
		, RaceWhite int
		, RaceBlack int
		, RaceHispanic int
		, RaceOther int
		, RaceUnknownMissing int
		, MarriedAtIntake int
		, MarriedAtDischarge int
		, NotMarriedAtIntake int
		, NotMarriedAtDischarge int
		, MarriedUnknownMissingAtIntake int
		, MarriedUnknownMissingAtDischarge int
		, OtherChildrenInHouseholdAtIntake int
		, OtherChildrenInHouseholdAtDischarge int
		, NoOtherChildrenInHouseholdAtIntake int
		, NoOtherChildrenInHouseholdAtDischarge int
		, ReceivingTANFAtIntake int
		, ReceivingTANFAtDischarge int
		, NotReceivingTANFAtIntake int
		, NotReceivingTANFAtDischarge int
		, MomScore int
		, DadScore int
		, PartnerScore int
		, PC1EducationAtIntakeLessThan12 int
		, PC1EducationAtDischargeLessThan12 int
		, PC1EducationAtIntakeHSGED int
		, PC1EducationAtDischargeHSGED int
		, PC1EducationAtIntakeMoreThan12 int
		, PC1EducationAtDischargeMoreThan12 int
		, PC1EducationAtIntakeUnknownMissing int
		, PC1EducationAtDischargeUnknownMissing int
		, PC1EducationalEnrollmentAtIntakeYes int
		, PC1EducationalEnrollmentAtDischargeYes int
		, PC1EducationalEnrollmentAtIntakeNo int
		, PC1EducationalEnrollmentAtDischargeNo int
		, PC1EducationalEnrollmentAtIntakeUnknownMissing int
		, PC1EducationalEnrollmentAtDischargeUnknownMissing int
		, PC1EmploymentAtIntakeYes int
		, PC1EmploymentAtDischargeYes int
		, PC1EmploymentAtIntakeNo int
		, PC1EmploymentAtDischargeNo int
		, PC1EmploymentAtIntakeUnknownMissing int
		, PC1EmploymentAtDischargeUnknownMissing int
		, OBPInHouseholdAtIntake int
		, OBPInHouseholdAtDischarge int
		, OBPEmploymentAtIntakeYes int
		, OBPEmploymentAtDischargeYes int
		, OBPEmploymentAtIntakeNo int
		, OBPEmploymentAtDischargeNo int
		, OBPEmploymentAtIntakeNoOBP int
		, OBPEmploymentAtDischargeNoOBP int
		, OBPEmploymentAtIntakeUnknownMissing int
		, OBPEmploymentAtDischargeUnknownMissing int
		, PC2InHouseholdAtIntake int
		, PC2InHouseholdAtDischarge int
		, PC2EmploymentAtIntakeYes int
		, PC2EmploymentAtDischargeYes int
		, PC2EmploymentAtIntakeNo int
		, PC2EmploymentAtDischargeNo int
		, PC2EmploymentAtIntakeNoPC2 int
		, PC2EmploymentAtDischargeNoPC2 int
		, PC2EmploymentAtIntakeUnknownMissing int
		, PC2EmploymentAtDischargeUnknownMissing int
		, PC1OrPC2OrOBPEmployedAtIntakeYes int
		, PC1OrPC2OrOBPEmployedAtDischargeYes int
		, PC1OrPC2OrOBPEmployedAtIntakeNo int
		, PC1OrPC2OrOBPEmployedAtDischargeNo int
		, PC1OrPC2OrOBPEmployedAtIntakeUnknownMissing int
		, PC1OrPC2OrOBPEmployedAtDischargeUnknownMissing int
		, CountOfHomeVisits int
		, DischargedOnLevelX int
		, PC1DVAtIntake int
		, PC1DVAtDischarge int
		, PC1MHAtIntake int
		, PC1MHAtDischarge int
		, PC1SAAtIntake int
		, PC1SAAtDischarge int
		, PC1PrimaryLanguageAtIntakeEnglish int
		, PC1PrimaryLanguageAtIntakeSpanish int
		, PC1PrimaryLanguageAtIntakeOtherUnknown int
		, TrimesterAtIntakePostnatal int
		, TrimesterAtIntake3rd int
		, TrimesterAtIntake2nd int
		, TrimesterAtIntake1st int
		, CountOfFSWs int
		, TotalDaysEnrolled int);
--#endregion
--#region cteCohort - Get the cohort for the report
	with cteCohort as
	-----------------------
		(select HVCasePK
			from HVCase h 
			inner join CaseProgram cp on cp.HVCaseFK = h.HVCasePK
			inner join dbo.SplitString(@ProgramFK, ',') ss on ss.ListItem = cp.ProgramFK
			where (IntakeDate is not null and IntakeDate between @StartDate and @EndDate)
				  -- and cp.ProgramFK=@ProgramFK
		)	

	--select * 
	--from cteCohort
	--order by HVCasePK

	--select HVCasePK, count(HVCasePK)
	--from cteCohort
	--group by HVCasePK
	--having count(HVCasePK) > 1
	
--#endregion
--#region cteLastFollowUp - Get last follow up completed for all cases in cohort
	, cteLastFollowUp as 
	-----------------------
		(select max(FollowUpPK) as FollowUpPK
			   , max(FollowUpDate) as FollowUpDate
			   , fu.HVCaseFK
			from FollowUp fu
			inner join cteCohort c on c.HVCasePK = fu.HVCaseFK
			group by fu.HVCaseFK
		)
	
	--select * 
	--from cteLastFollowUp 
	--order by HVCaseFK

--#endregion
--#region cteFollowUp* - get follow up common attribute rows and columns that we need for each person from the last follow up
	, cteFollowUpPC1 as
	-------------------
		(select MaritalStatus
				, PBTANF as PC1TANFAtDischarge
				, cappmarital.AppCodeText as MaritalStatusAtDischarge
				, cappgrade.AppCodeText as PC1EducationAtDischarge
				, IsCurrentlyEmployed AS PC1EmploymentAtDischarge
				, EducationalEnrollment AS EducationalEnrollmentAtDischarge
				, ca.HVCaseFK 
		   from CommonAttributes ca
		   left outer join codeApp cappmarital ON cappmarital.AppCode=MaritalStatus and cappmarital.AppCodeGroup='MaritalStatus'
		   left outer join codeApp cappgrade ON cappgrade.AppCode=HighestGrade and cappgrade.AppCodeGroup='Education'
		   inner join cteLastFollowUp fu on FollowUpPK = FormFK
		  where FormType='FU-PC1'
		)
	, cteFollowUpOBP as
	-------------------
		(select IsCurrentlyEmployed as OBPEmploymentAtDischarge
				, OBPInHome as OBPInHomeAtDischarge
				, ca.HVCaseFK 
		   from CommonAttributes ca
		   left outer join codeApp capp ON capp.AppCode=MaritalStatus and AppCodeGroup='MaritalStatus'
		   inner join cteLastFollowUp fu on FollowUpPK = FormFK
		  where FormType='FU-OBP'
		)
	, cteFollowUpPC2 as
	-------------------
		(select IsCurrentlyEmployed AS PC2EmploymentAtDischarge
				, ca.HVCaseFK 
		   from CommonAttributes ca
		   left outer join codeApp capp ON capp.AppCode=MaritalStatus and AppCodeGroup='MaritalStatus'
		   inner join cteLastFollowUp fu on FollowUpPK = FormFK
		  where FormType='FU-PC2'
		)
--#endregion
--#region cteDischargeData - Get all discharge related data
    , cteDischargeData as 
	------------------------
		(select h.HVCasePK as HVCaseFK
			    ,cd.DischargeCode as DischargeCode
			    ,cd.DischargeReason as DischargeReason
				,PC1TANFAtDischarge
				,MaritalStatusAtDischarge
				,PC1EducationAtDischarge
				,PC1EmploymentAtDischarge
				,EducationalEnrollmentAtDischarge
			   	,case
					when cp.HVCaseFK IN (SELECT oc.HVCaseFK FROM OtherChild oc WHERE oc.HVCaseFK=cp.HVCaseFK AND oc.FormType='FU') 
						then 1
					else 0
				end as OtherChildrenInHouseholdAtDischarge
				,case 
					when pc1is.AlcoholAbuse = '1'
						then 1
					else 0
				end as AlcoholAbuseAtDischarge
				,case
					when pc1is.SubstanceAbuse = '1' 
						then 1
					else 0
				end as SubstanceAbuseAtDischarge
				,case 
					when pc1is.DomesticViolence = '1' 
						then 1
					else 0
				end as DomesticViolenceAtDischarge
				,case 
					when pc1is.MentalIllness = '1'
						then 1
					else 0
				end as MentalIllnessAtDischarge
				,case 
					when pc1is.Depression = '1'
						then 1
					else 0
				end as DepressionAtDischarge
				,OBPInHomeAtDischarge
				,PC2inHome as PC2InHomeAtDischarge
				,PC2EmploymentAtDischarge
				,OBPEmploymentAtDischarge
		from HVCase h
		inner join CaseProgram cp on cp.HVCaseFK=h.HVCasePK
		inner join Kempe k on k.HVCaseFK=h.HVCasePK
		inner join codeLevel cl ON cl.codeLevelPK=CurrentLevelFK
		inner join codeDischarge cd on cd.DischargeCode=cp.DischargeReason 
		inner join cteCohort c on h.HVCasePK = c.HVCasePK
		inner join cteLastFollowUp lfu on lfu.HVCaseFK = c.HVCasePK
		left outer join FollowUp fu ON fu.FollowUpPK = lfu.FollowUpPK
		left outer join PC1Issues pc1is ON pc1is.PC1IssuesPK=fu.PC1IssuesFK
		left outer join cteFollowUpPC1 pc1fuca ON pc1fuca.HVCaseFK=c.HVCasePK
		left outer join cteFollowUpOBP obpfuca ON obpfuca.HVCaseFK=c.HVCasePK
		left outer join cteFollowUpPC2 pc2fuca ON pc2fuca.HVCaseFK=c.HVCasePK
			  -- and Fu.FollowUpInterval IN (98,99))
		--where DischargeDate <= @EndDate
		)

	--select * from cteDischargeData
	--order by HVCaseFK

--#endregion
--#region cteCaseLastHomeVisit - get the last home visit for each case in the cohort 
	, cteCaseLastHomeVisit AS 
	------------------------
		(select HVCaseFK
				  , max(vl.VisitStartTime) as LastHomeVisit
				  , count(vl.VisitStartTime) as CountOfHomeVisits
			from HVLog  vl WITH (NOLOCK)
			inner join hvcase c ON c.HVCasePK=vl.HVCaseFK 
			inner join dbo.SplitString(@ProgramFK, ',') ss on ss.ListItem = vl.ProgramFK
			where VisitType <> '0001' and 
					(IntakeDate is not null and IntakeDate between @StartDate and @EndDate)
						-- and vl.ProgramFK=@ProgramFK
			group by HVCaseFK
		)
--#endregion
--#region cteCaseFSWCount - get the count of FSWs for each case in the cohort, i.e. how many times it's changed
	, cteCaseFSWCount AS 
	------------------------
		 (SELECT HVCaseFK, COUNT(wa.WorkerAssignmentPK) AS CountOfFSWs
		   FROM dbo.WorkerAssignment wa
			INNER JOIN hvcase c ON c.HVCasePK=wa.HVCaseFK 
			inner join dbo.SplitString(@ProgramFK, ',') ss on ss.ListItem = wa.ProgramFK
			WHERE (IntakeDate is not null and IntakeDate between @StartDate and @EndDate)
				-- and wa.ProgramFK=@ProgramFK
			group by HVCaseFK)
--#endregion
--#region ctePC1AgeAtIntake - get the PC1's age at intake
	, ctePC1AgeAtIntake as
	------------------------
		(select HVCasePK as HVCaseFK
				,round(datediff(day,PCDOB,IntakeDate)/365.25,0) as PC1AgeAtIntake
			from PC 
			inner join PCProgram pcp on pcp.PCFK=PCPK
			inner join HVCase c on c.PC1FK=PCPK
			inner join dbo.SplitString(@ProgramFK, ',') ss on ss.ListItem = pcp.ProgramFK
			WHERE (IntakeDate is not null and IntakeDate between @StartDate and @EndDate)
				-- and pcp.ProgramFK=@ProgramFK
		)
--#endregion
--#region cteMain - main select for the report sproc, gets data at intake and joins to data at discharge
	, cteMain as
	------------------------
		(select PC1ID
			   ,HVCasePK as HVCaseFK
			   ,OldID
			   ,HVCaseFK_old
			   ,IntakeDate
			   ,LastHomeVisit
			   ,CountOfFSWs
			   ,CountOfHomeVisits
			   ,DischargeDate
			   ,LevelName
			   ,cp.DischargeReason as DischargeReasonCode
               ,dd.DischargeReason
			   ,PC1AgeAtIntake
			   ,case 
				when dischargedate is null and current_timestamp-IntakeDate > 182.125 then 1
				when dischargedate is not null and LastHomeVisit-IntakeDate > 182.125 then 1
					else 0
				end	as ActiveAt6Months
			   ,case
				when dischargedate is null and current_timestamp-IntakeDate > 365.25 then 1
				when dischargedate is not null and LastHomeVisit-IntakeDate > 365.25 then 1
					else 0
				end as ActiveAt12Months
			   ,case
				when dischargedate is null and current_timestamp-IntakeDate > 547.375 then 1
				when dischargedate is not null and LastHomeVisit-IntakeDate > 547.375 then 1
					else 0
				end as ActiveAt18Months
			   ,case
				when dischargedate is null and current_timestamp-IntakeDate > 730.50 then 1
				when dischargedate is not null and LastHomeVisit-IntakeDate > 730.50 then 1
					else 0
				end as ActiveAt24Months
			   ,Race
			   ,carace.AppCodeText as RaceText
			   ,MaritalStatus
			   ,MaritalStatusAtIntake
			   ,case when MomScore = 'U' then 0 else cast(MomScore as int) end as MomScore
			   ,case when DadScore = 'U' then 0 else cast(DadScore as int) end as DadScore
			   ,case when PartnerScore = 'U' then 0 else cast(PartnerScore as int) end as PartnerScore
			   ,HighestGrade
			   ,PC1EducationAtIntake
			   ,PC1EmploymentAtIntake
			   ,EducationalEnrollment AS EducationalEnrollmentAtIntake
			   ,PrimaryLanguage as PC1PrimaryLanguageAtIntake
			   ,case 
			   		when TCDOB is NULL then EDC
					else TCDOB
				end as TCDOB
			   ,case 
					when TCDOB is null and EDC is not null then 1
					when TCDOB is not null and TCDOB > IntakeDate then 1
					when TCDOB is not null and TCDOB <= IntakeDate then 0
				end
				as PrenatalEnrollment
				,case
					when cp.HVCaseFK IN (SELECT oc.HVCaseFK FROM OtherChild oc WHERE oc.HVCaseFK=cp.HVCaseFK AND oc.FormType='IN') 
						then 1
					else 0
				end as OtherChildrenInHouseholdAtIntake
				,case 
					when pc1i.AlcoholAbuse = '1'
						then 1
					else 0
				end as AlcoholAbuseAtIntake
				,case 
					when pc1i.SubstanceAbuse = '1'
						then 1
					else 0
				end as SubstanceAbuseAtIntake
				,case 
					when pc1i.DomesticViolence = '1'
						then 1
					else 0
				end as DomesticViolenceAtIntake
				,case 
					when pc1i.MentalIllness = '1'
						then 1
					else 0
				end as MentalIllnessAtIntake
				,case 
					when pc1i.Depression = '1'
						then 1
					else 0
				end as DepressionAtIntake
				,OBPInHomeIntake as OBPInHomeAtIntake
				,PC2InHomeIntake as PC2InHomeAtIntake
				,MaritalStatusAtDischarge
				,PC1EducationAtDischarge
				,PC1EmploymentAtDischarge
				,EducationalEnrollmentAtDischarge
		   		,OtherChildrenInHouseholdAtDischarge
				,AlcoholAbuseAtDischarge
				,SubstanceAbuseAtDischarge
				,DomesticViolenceAtDischarge
				,MentalIllnessAtDischarge
				,DepressionAtDischarge
				,OBPInHomeAtDischarge
				,OBPEmploymentAtDischarge
				,OBPEmploymentAtIntake
				,PC2InHomeAtDischarge
				,PC2EmploymentAtIntake
				,PC2EmploymentAtDischarge
				,PC1TANFAtDischarge
				,PC1TANFAtIntake
		FROM HVCase c
		left outer join cteDischargeData dd ON dd.hvcasefk=c.HVCasePK
		inner join cteCaseLastHomeVisit lhv ON lhv.HVCaseFK=c.HVCasePK
		inner join cteCaseFSWCount fc ON fc.HVCaseFK=c.HVCasePK
		inner join ctePC1AgeAtIntake aai on aai.HVCaseFK=c.HVCasePK
		inner join CaseProgram cp on cp.HVCaseFK=c.HVCasePK
		inner join PC on PC.PCPK=c.PC1FK
		inner join Kempe k on k.HVCaseFK=c.HVCasePK
		inner join PC1Issues pc1i ON pc1i.HVCaseFK=k.HVCaseFK AND pc1i.PC1IssuesPK=k.PC1IssuesFK
		inner join codeLevel cl ON cl.codeLevelPK=CurrentLevelFK
		inner join dbo.SplitString(@ProgramFK, ',') ss on ss.ListItem = cp.ProgramFK
		left outer join codeApp carace on carace.AppCode=Race and AppCodeGroup='Race'
		left outer join (select MaritalStatus, PBTANF as PC1TANFAtIntake
								,AppCodeText as MaritalStatusAtIntake
								,IsCurrentlyEmployed AS PC1EmploymentAtIntake
								,EducationalEnrollment
								,PrimaryLanguage
								,HVCaseFK 
						   from CommonAttributes ca
						   left outer join codeApp capp ON capp.AppCode=MaritalStatus and AppCodeGroup='MaritalStatus'
						  where FormType='IN-PC1') pc1ca ON pc1ca.HVCaseFK=c.HVCasePK
		left outer join (SELECT IsCurrentlyEmployed AS OBPEmploymentAtIntake
								,HVCaseFK 
						   FROM CommonAttributes ca
						  WHERE FormType='IN-OBP') obpca ON obpca.HVCaseFK=c.HVCasePK
		left outer join (SELECT HVCaseFK
								, IsCurrentlyEmployed AS PC2EmploymentAtIntake
						   FROM CommonAttributes ca
						  WHERE FormType='IN-PC2') pc2ca ON pc2ca.HVCaseFK=c.HVCasePK
		left outer join (SELECT AppCodeText as PC1EducationAtIntake,HighestGrade,HVCaseFK 
						   FROM CommonAttributes ca
						   LEFT OUTER JOIN codeApp capp ON capp.AppCode=HighestGrade and AppCodeGroup='Education'
						  WHERE FormType='IN-PC1') pc1eduai ON pc1eduai.HVCaseFK=c.HVCasePK
		where (IntakeDate is not null and IntakeDate between @StartDate and @EndDate)
				  -- and cp.ProgramFK=@ProgramFK
		)
--#endregion
--select *
--from cteDischargeData

--select *
--from cteMain
--where DischargeReasonCode is NULL or DischargeReasonCode not in ('07', '17', '18', '20', '21', '23', '25', '37') 
--order by DischargeReasonCode, PC1ID

--#region Add rows to @tblPC1withStats for each case/pc1id in the cohort, which will create the basis for the final stats
insert into @tblPC1withStats 
		(PC1ID
		, HVCaseFK
		, OldID
		, HVCaseFK_old
		, IntakeDate
		, DischargeDate
		, DischargeReasonCode
		, DischargeReason
		, LastHomeVisit
		, RetentionMonths
		, ActiveAt6Months
		, ActiveAt12Months
		, ActiveAt18Months
		, ActiveAt24Months
		, AgeAtIntake_Under18
		, AgeAtIntake_18UpTo20
		, AgeAtIntake_20UpTo30
		, AgeAtIntake_Over30
		, RaceWhite
		, RaceBlack
		, RaceHispanic
		, RaceOther
		, RaceUnknownMissing
		, MarriedAtIntake
		, MarriedAtDischarge
		, NotMarriedAtIntake
		, NotMarriedAtDischarge
		, MarriedUnknownMissingAtIntake
		, MarriedUnknownMissingAtDischarge
		, OtherChildrenInHouseholdAtIntake
		, OtherChildrenInHouseholdAtDischarge
		, NoOtherChildrenInHouseholdAtIntake
		, NoOtherChildrenInHouseholdAtDischarge
		, ReceivingTANFAtIntake
		, ReceivingTANFAtDischarge
		, NotReceivingTANFAtIntake
		, NotReceivingTANFAtDischarge
		, MomScore
		, DadScore
		, PartnerScore
		, PC1EducationAtIntakeLessThan12
		, PC1EducationAtDischargeLessThan12
		, PC1EducationAtIntakeHSGED
		, PC1EducationAtDischargeHSGED
		, PC1EducationAtIntakeMoreThan12
		, PC1EducationAtDischargeMoreThan12
		, PC1EducationAtIntakeUnknownMissing
		, PC1EducationAtDischargeUnknownMissing
		, PC1EducationalEnrollmentAtIntakeYes
		, PC1EducationalEnrollmentAtDischargeYes
		, PC1EducationalEnrollmentAtIntakeNo
		, PC1EducationalEnrollmentAtDischargeNo
		, PC1EducationalEnrollmentAtIntakeUnknownMissing
		, PC1EducationalEnrollmentAtDischargeUnknownMissing
		, PC1EmploymentAtIntakeYes
		, PC1EmploymentAtDischargeYes
		, PC1EmploymentAtIntakeNo
		, PC1EmploymentAtDischargeNo
		, PC1EmploymentAtIntakeUnknownMissing
		, PC1EmploymentAtDischargeUnknownMissing
		, OBPInHouseholdAtIntake
		, OBPInHouseholdAtDischarge
		, OBPEmploymentAtIntakeYes
		, OBPEmploymentAtDischargeYes
		, OBPEmploymentAtIntakeNo
		, OBPEmploymentAtDischargeNo
		, OBPEmploymentAtIntakeNoOBP
		, OBPEmploymentAtDischargeNoOBP
		, OBPEmploymentAtIntakeUnknownMissing
		, OBPEmploymentAtDischargeUnknownMissing
		, PC2InHouseholdAtIntake
		, PC2InHouseholdAtDischarge
		, PC2EmploymentAtIntakeYes
		, PC2EmploymentAtDischargeYes
		, PC2EmploymentAtIntakeNo
		, PC2EmploymentAtDischargeNo
		, PC2EmploymentAtIntakeNoPC2
		, PC2EmploymentAtDischargeNoPC2
		, PC2EmploymentAtIntakeUnknownMissing
		, PC2EmploymentAtDischargeUnknownMissing
		, PC1OrPC2OrOBPEmployedAtIntakeYes
		, PC1OrPC2OrOBPEmployedAtDischargeYes
		, PC1OrPC2OrOBPEmployedAtIntakeNo
		, PC1OrPC2OrOBPEmployedAtDischargeNo
		, PC1OrPC2OrOBPEmployedAtIntakeUnknownMissing
		, PC1OrPC2OrOBPEmployedAtDischargeUnknownMissing
		, CountOfHomeVisits
		, DischargedOnLevelX
		, PC1DVAtIntake
		, PC1DVAtDischarge
		, PC1MHAtIntake
		, PC1MHAtDischarge
		, PC1SAAtIntake
		, PC1SAAtDischarge
		, PC1PrimaryLanguageAtIntakeEnglish
		, PC1PrimaryLanguageAtIntakeSpanish
		, PC1PrimaryLanguageAtIntakeOtherUnknown
		, TrimesterAtIntakePostnatal
		, TrimesterAtIntake3rd
		, TrimesterAtIntake2nd
		, TrimesterAtIntake1st
		, CountOfFSWs
		, TotalDaysEnrolled)
select distinct pc1id
		, HVCaseFK
		, OldID
		, HVCaseFK_old
		, IntakeDate
		, DischargeDate
		, DischargeReasonCode
		, DischargeReason
		, LastHomeVisit
				   ,case when DischargeDate is not null then 
						datediff(mm,IntakeDate,LastHomeVisit)
					else
						datediff(mm,IntakeDate,current_timestamp)
					end as RetentionMonths
					
		, ActiveAt6Months
		, ActiveAt12Months
		, ActiveAt18Months
		, ActiveAt24Months
		, case when PC1AgeAtIntake < 18 then 1 else 0 end as AgeAtIntake_Under18
		, case when PC1AgeAtIntake between 18 and 19 then 1 else 0 end as AgeAtIntake_18UpTo20
		, case when PC1AgeAtIntake between 20 and 29 then 1 else 0 end as AgeAtIntake_20UpTo30
		, case when PC1AgeAtIntake >= 30 then 1 else 0 end as AgeAtIntake_Over30
		, case when left(RaceText,5)='White' then 1 else 0 end as RaceWhite
		, case when left(RaceText,5)='Black' then 1 else 0 end as RaceBlack
		, case when left(RaceText,8)='Hispanic' then 1 else 0 end as RaceHispanic
		, case when left(RaceText,5) in('Asian','Nativ','Multi','Other') then 1 else 0 end as RaceOther
		, case when RaceText is null or RaceText='' then 1 else 0 end as RaceUnknownMissing
		, case when MaritalStatusAtIntake = 'Married' then 1 else 0 end as MarriedAtIntake
		, case when MaritalStatusAtDischarge = 'Married' then 1 else 0 end as MarriedAtDischarge
		, case when MaritalStatusAtIntake = 'Not married' then 1 else 0 end as NotMarriedAtIntake
		, case when MaritalStatusAtIntake = 'Not married' then 1 else 0 end as NotMarriedAtDischarge
		, case when MaritalStatusAtIntake is null or MaritalStatusAtIntake='' then 1 else 0 end as MarriedUnknownMissingAtIntake
		, case when MaritalStatusAtDischarge is null or MaritalStatusAtDischarge='' then 1 else 0 end as MarriedUnknownMissingAtDischarge
		, case when OtherChildrenInHouseholdAtIntake > 0 then 1 else 0 end as OtherChildrenInHouseholdAtIntake
		, case when OtherChildrenInHouseholdAtDischarge > 0 then 1 else 0 end as OtherChildrenInHouseholdAtDischarge
		, case when OtherChildrenInHouseholdAtIntake = 0 or OtherChildrenInHouseholdAtIntake is null then 1 else 0 end as NoOtherChildrenInHouseholdAtIntake
		, case when OtherChildrenInHouseholdAtDischarge = 0 or OtherChildrenInHouseholdAtDischarge is null then 1 else 0 end as NoOtherChildrenInHouseholdAtDischarge
		, case when PC1TANFAtIntake = 1 then 1 else 0 end as ReceivingTANFAtIntake
		, case when PC1TANFAtDischarge = 1 then 1 else 0 end as ReceivingTANFAtDischarge
		, case when PC1TANFAtIntake = 0 or PC1TANFAtIntake is null or PC1TANFAtIntake = '' then 1 else 0 end as NotReceivingTANFAtIntake
		, case when PC1TANFAtDischarge = 0 or PC1TANFAtDischarge is null or PC1TANFAtDischarge='' then 1 else 0 end as NotReceivingTANFAtDischarge
		, MomScore
		, DadScore
		, PartnerScore
		, case when PC1EducationAtIntake in ('Less than 8','8-11') then 1 else 0 end as PC1EducationAtIntakeLessThan12
		, case when PC1EducationAtDischarge in ('Less than 8','8-11') then 1 else 0 end as PC1EducationAtDischargeLessThan12
		, case when PC1EducationAtIntake in ('High school grad','GED') then 1 else 0 end as PC1EducationAtIntakeHSGED
		, case when PC1EducationAtDischarge in ('Less than 8','8-11') then 1 else 0 end as PC1EducationAtDischargeHSGED
		, case when PC1EducationAtIntake in ('Vocational school after HS','Some college','Associates Degree','Bachelors degree or higher') then 1 else 0 end as PC1EducationAtIntakeMoreThan12
		, case when PC1EducationAtDischarge in ('Vocational school after HS','Some college','Associates Degree','Bachelors degree or higher') then 1 else 0 end as PC1EducationAtDischargeMoreThan12
		, case when PC1EducationAtIntake is null or PC1EducationAtIntake = '' then 1 else 0 end as PC1EducationAtIntakeUnknownMissing
		, case when PC1EducationAtDischarge is null or PC1EducationAtDischarge = '' then 1 else 0 end as PC1EducationAtDischargeUnknownMissing
		, case when EducationalEnrollmentAtIntake = 1 then 1 else 0 end as PC1EducationalEnrollmentAtIntakeYes
		, case when EducationalEnrollmentAtDischarge = 1 then 1 else 0 end as PC1EducationalEnrollmentAtDischargeYes
		, case when EducationalEnrollmentAtIntake = 0 then 1 else 0 end as PC1EducationalEnrollmentAtIntakeNo
		, case when EducationalEnrollmentAtDischarge = 0 then 1 else 0 end as PC1EducationalEnrollmentAtDischargeNo
		, case when EducationalEnrollmentAtIntake is null or EducationalEnrollmentAtIntake = '' then 1 else 0 end as PC1EducationalEnrollmentAtIntakeUnknownMissing
		, case when EducationalEnrollmentAtDischarge is null or EducationalEnrollmentAtDischarge = '' then 1 else 0 end as PC1EducationalEnrollmentAtDischargeUnknownMissing
		, case when PC1EmploymentAtIntake = 1 then 1 else 0 end as PC1EmploymentAtIntakeYes
		, case when PC1EmploymentAtDischarge = 1 then 1 else 0 end as PC1EmploymentAtDischargeYes
		, case when PC1EmploymentAtIntake = 0 then 1 else 0 end as PC1EmploymentAtIntakeNo
		, case when PC1EmploymentAtDischarge = 0 then 1 else 0 end as PC1EmploymentAtDischargeNo
		, case when PC1EmploymentAtIntake is null or PC1EmploymentAtIntake = '' then 1 else 0 end as PC1EmploymentAtIntakeUnknownMissing
		, case when PC1EmploymentAtDischarge is null or PC1EmploymentAtDischarge = '' then 1 else 0 end as PC1EmploymentAtDischargeUnknownMissing
		, case when OBPInHomeAtIntake = 1 then 1 else 0 end as OBPInHouseholdAtIntake
		, case when OBPInHomeAtDischarge = 1 then 1 else 0 end as OBPInHouseholdAtDischarge
		, case when OBPEmploymentAtIntake = 1 then 1 else 0 end as OBPEmploymentAtIntakeYes
		, case when OBPEmploymentAtDischarge = 1 then 1 else 0 end as OBPEmploymentAtDischargeYes
		, case when OBPEmploymentAtIntake = 0 then 1 else 0 end as OBPEmploymentAtIntakeNo
		, case when OBPEmploymentAtDischarge = 0 then 1 else 0 end as OBPEmploymentAtDischargeNo
		, case when OBPInHomeAtIntake = 0 then 1 else 0 end as OBPEmploymentAtIntakeNoOBP
		, case when OBPinHomeAtDischarge = 0 then 1 else 0 end as OBPEmploymentAtDischargeNoOBP
		, case when OBPInHomeAtIntake = 1 and (OBPEmploymentAtIntake is null or OBPEmploymentAtIntake = '') then 1 else 0 end as OBPEmploymentAtIntakeUnknownMissing
		, case when OBPInHomeAtDischarge = 1 and (OBPEmploymentAtDischarge is null or OBPEmploymentAtDischarge = '') then 1 else 0 end as OBPEmploymentAtDischargeUnknownMissing
		, case when PC2InHomeAtIntake = 1 then 1 else 0 end as PC2InHouseholdAtIntake
		, case when PC2InHomeAtDischarge = 1 then 1 else 0 end as PC2InHouseholdAtDischarge
		, case when PC2EmploymentAtIntake = 1 then 1 else 0 end as PC2EmploymentAtIntakeYes
		, case when PC2EmploymentAtDischarge = 1 then 1 else 0 end as PC2EmploymentAtDischargeYes
		, case when PC2EmploymentAtIntake = 0 then 1 else 0 end as PC2EmploymentAtIntakeNo
		, case when PC2EmploymentAtDischarge = 0 then 1 else 0 end as PC2EmploymentAtDischargeNo
		, case when PC2InHomeAtIntake = 0 then 1 else 0 end as PC2EmploymentAtIntakeNoPC2
		, case when PC2inHomeAtDischarge = 0 then 1 else 0 end as PC2EmploymentAtDischargeNoPC2
		, case when PC2InHomeAtIntake = 1 and (PC2EmploymentAtIntake is null or PC2EmploymentAtIntake = '') then 1 else 0 end as PC2EmploymentAtIntakeUnknownMissing
		, case when PC2InHomeAtDischarge = 1 and (PC2EmploymentAtDischarge is null or PC2EmploymentAtDischarge = '') then 1 else 0 end as PC2EmploymentAtDischargeUnknownMissing
		, case when PC1EmploymentAtIntake = 1 or PC2EmploymentAtIntake = 1 or OBPEmploymentAtIntake = 1 then 1 else 0 end as PC1OrPC2OrOBPEmployedAtIntakeYes
		, case when PC1EmploymentAtDischarge = 1 or PC2EmploymentAtDischarge = 1 or OBPEmploymentAtDischarge = 1 then 1 else 0 end as PC1OrPC2OrOBPEmployedAtDischargeYes
		, case when PC1EmploymentAtIntake = 0 and PC2EmploymentAtIntake = 0 and OBPEmploymentAtIntake = 0 then 1 else 0 end as PC1OrPC2OrOBPEmployedAtIntakeNo
		, case when PC1EmploymentAtDischarge = 0 and PC2EmploymentAtDischarge = 0 and OBPEmploymentAtDischarge = 0 then 1 else 0 end as PC1OrPC2OrOBPEmployedAtDischargeNo
		, case when (PC1EmploymentAtIntake is null or PC1EmploymentAtIntake = '') 
					and (PC2InHomeAtIntake = 1 and (PC2EmploymentAtIntake is null or PC2EmploymentAtIntake = '')) 
					and (OBPInHomeAtIntake = 1 and (OBPEmploymentAtIntake is NULL or OBPEmploymentAtIntake = '')) then 1 else 0 end as PC1OrPC2OrOBPEmployedAtIntakeUnknownMissing
		, case when (PC1EmploymentAtDischarge is null or PC1EmploymentAtDischarge = '') 
					and (PC2InHomeAtIntake = 1 and  (PC2EmploymentAtDischarge is null or PC2EmploymentAtDischarge = ''))
					and (OBPInHomeAtIntake = 1 and (OBPEmploymentAtDischarge is NULL or OBPEmploymentAtDischarge = '')) then 1 else 0 end as PC1OrPC2OrOBPEmployedAtDischargeUnknownMissing
		, CountOfHomeVisits
		, case when left(LevelName,7)='Level X' then 1 else 0 end as DischargedOnLevelX
		, case when DomesticViolenceAtIntake = 1 then 1 else 0 end as PC1DVAtIntake
		, case when DomesticViolenceAtDischarge = 1 then 1 else 0 end as PC1DVAtDischarge
		, case when MentalIllnessAtIntake = 1 or DepressionAtIntake = 1 then 1 else 0 end as PC1MHAtIntake
		, case when MentalIllnessAtDischarge = 1 or DepressionAtDischarge = 1 then 1 else 0 end as PC1MHAtDischarge
		, case when AlcoholAbuseAtIntake = 1 or SubstanceAbuseAtIntake = 1 then 1 else 0 end as PC1SAAtIntake
		, case when AlcoholAbuseAtDischarge = 1 or SubstanceAbuseAtDischarge = 1 then 1 else 0 end as PC1SAAtDischarge
		, case when PC1PrimaryLanguageAtIntake = '01' then 1 else 0 end as PC1PrimaryLanguageAtIntakeEnglish
		, case when PC1PrimaryLanguageAtIntake = '02' then 1 else 0 end as PC1PrimaryLanguageAtIntakeSpanish
		, case when PC1PrimaryLanguageAtIntake = '03' or PC1PrimaryLanguageAtIntake is null or PC1PrimaryLanguageAtIntake = '' then 1 else 0 end as PC1PrimaryLanguageAtIntakeOtherUnknown
		, case when IntakeDate>=TCDOB then 1 else 0 end as TrimesterAtIntakePostnatal
		, case when IntakeDate<TCDOB and datediff(day,IntakeDate,TCDOB) between 1 and round(30.44*3,0) then 1 else 0 end as TrimesterAtIntake3rd
		, case when IntakeDate<TCDOB and datediff(day,IntakeDate,TCDOB) between round(30.44*3,0)+1 and round(30.44*6,0) then 1 else 0 end as TrimesterAtIntake2nd
		, case when IntakeDate<TCDOB and datediff(day,IntakeDate,TCDOB) > round(30.44*6,0) then 1 else 0 end as TrimesterAtIntake1st		
		, CountOfFSWs
		, datediff(day,IntakeDate,LastHomeVisit) as TotalDaysEnrolled
from cteMain
-- where DischargeReason not in ('Out of Geographical Target Area','Miscarriage/Pregnancy Terminated','Target Child Died')
where DischargeReasonCode is NULL or DischargeReasonCode not in ('07', '17', '18', '20', '21', '23', '25', '37') 
		-- (DischargeReasonCode not in ('07', '17', '18', '20', '21', '23', '25', '37') or datediff(day,IntakeDate,DischargeDate)>=(4*6*30.44))
order by PC1ID,IntakeDate
--#endregion

select *
from @tblPC1withStats
-- order by HVCaseFK_old
order by pc1id, dischargereasoncode, RetentionMonths

end


GO
