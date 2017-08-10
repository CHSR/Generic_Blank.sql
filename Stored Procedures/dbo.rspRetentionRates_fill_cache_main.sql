SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jrobohn
-- Create date: 03/31/11
-- Description:	Main storedproc for Retention Rate report
-- Description: <copied from FamSys Feb 20, 2012 - see header below>
-- exec rspRetentionRates 9, '05/01/09', '04/30/11'
-- exec rspRetentionRates 19, '20080101', '20121231'
-- exec rspRetentionRates 37, '20090401', '20110331'
-- exec rspRetentionRates 17, '20090401', '20110331'
-- exec rspRetentionRates 20, '20080401', '20110331'
-- exec rspRetentionRates '15,16', '20091201', '20111130'
-- exec rspRetentionRates 1, '03/01/10', '02/29/12', null, null, ''
-- exec rspRetentionRates 1, '03/01/10', '02/29/12', 85, null, '' 85 = Daisy Flores
-- exec rspRetentionRates 1, '03/01/10', '02/29/12', null, 1, '' 1 = Children Youth & Families
-- exec rspRetentionRates 1, '03/01/10', '02/29/12', null, null, ''
-- Fixed Bug HW963 - Retention Rage Report ... Khalsa 3/20/2014
-- =============================================
-- =============================================
CREATE procedure [dbo].[rspRetentionRates_fill_cache_main]
	-- Add the parameters for the stored procedure here
	@ProgramFK varchar(max)
	, @StartDate datetime
	, @EndDate datetime
    , @WorkerFK int = null
	, @SiteFK int = null
	, @CaseFiltersPositive varchar(100) = ''
as
BEGIN 
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;

--#region declarations
	set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0
					   else @SiteFK
				  end
	set @CaseFiltersPositive = case	when @CaseFiltersPositive = '' then null
									else @CaseFiltersPositive
							   end
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
		, IntakeDate datetime
		, DischargeDate datetime
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
		, NeverMarriedAtIntake int
		, NeverMarriedAtDischarge int
		, SeparatedAtIntake int
		, SeparatedAtDischarge int
		, DivorcedAtIntake int
		, DivorcedAtDischarge int
		, WidowedAtIntake int
		, WidowedAtDischarge int
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
		, CountOfFSWs int);

if exists(select * from tempdb.dbo.sysobjects where id=object_id(N'tempdb..#tmpCohort'))
	-- where charindex('#',name)>0 order by name
	drop table #tmpCohort

create table #tmpCohort
	(HVCasePK int
		, PC1ID char(13)
		, PC1FK int
		, IntakeDate date
		, EDC date
		, TCDOB date
		, OBPInHomeIntake bit
		, PC2InHomeIntake bit);

if exists(select * from tempdb.dbo.sysobjects where id=object_id(N'tempdb..#tmpDischargeData'))
	-- where charindex('#',name)>0 order by name
	drop table #tmpDischargeData

create table #tmpDischargeData
	(HVCaseFK int
	,DischargeReason char(100)
	,PC1TANFAtDischarge char(1)
	,MaritalStatusAtDischarge char(100)
	,PC1EducationAtDischarge char(100)
	,PC1EmploymentAtDischarge char(1)
	,EducationalEnrollmentAtDischarge char(1)
	,OtherChildrenInHouseholdAtDischarge bit
	,AlcoholAbuseAtDischarge bit
	,SubstanceAbuseAtDischarge bit
	,DomesticViolenceAtDischarge bit
	,MentalIllnessAtDischarge bit
	,DepressionAtDischarge bit
	,OBPInHomeAtDischarge char(1)
	,PC2InHomeAtDischarge char(1)
	,PC2EmploymentAtDischarge char(1)
	,OBPEmploymentAtDischarge char(1)
);

--#endregion
--#region tmpCohort - Get the cohort for the report
with cteCohort as
	(select max(CaseProgramPK) as CaseProgramPK
			from CaseProgram cp
			inner join HVCase hc on hc.HVCasePK = cp.HVCaseFK
			inner join SplitString(@ProgramFK, ',') ss on ss.ListItem = cp.ProgramFK
			where IntakeDate is not null and IntakeDate between @StartDate and @EndDate
			group by HVCaseFK
	)
	insert into #tmpCohort 
		select HVCasePK
				, PC1ID
				, PC1FK
				, IntakeDate
				, EDC
				, TCDOB
				, OBPinHomeIntake
				, PC2inHomeIntake
			from cteCohort co
			inner join CaseProgram cp on cp.CaseProgramPK = co.CaseProgramPK
			inner join HVCase hc on hc.HVCasePK = cp.HVCaseFK
			inner join dbo.udfCaseFilters(@CaseFiltersPositive, '', @programfk) cf on cf.HVCaseFK = hc.HVCasePK
			left outer join Worker w on w.WorkerPK = cp.CurrentFSWFK
			left outer join WorkerProgram wp on wp.WorkerFK = w.WorkerPK and wp.ProgramFK = cp.ProgramFK
			where case when @SiteFK = 0 then 1
							 when wp.SiteFK = @SiteFK then 1
							 else 0
						end = 1
					and  w.WorkerPK = isnull(@WorkerFK, w.WorkerPK);
--#endregion
--#region cteLastFollowUp - Get last follow up completed for all cases in cohort
	with cteLastFollowUp as 
	-----------------------
		(select max(FollowUpPK) as FollowUpPK
			   , max(FollowUpDate) as FollowUpDate
			   , fu.HVCaseFK
			from FollowUp fu
			inner join #tmpCohort c on c.HVCasePK = fu.HVCaseFK
			group by fu.HVCaseFK
		)
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
		   --left outer join codeApp capp ON capp.AppCode=MaritalStatus and AppCodeGroup='MaritalStatus'
		   inner join cteLastFollowUp fu on FollowUpPK = FormFK
		  where FormType='FU-OBP'
		)
	, cteFollowUpPC2 as
	-------------------
		(select IsCurrentlyEmployed AS PC2EmploymentAtDischarge
				, ca.HVCaseFK 
		   from CommonAttributes ca
		   --left outer join codeApp capp ON capp.AppCode=MaritalStatus and AppCodeGroup='MaritalStatus'
		   inner join cteLastFollowUp fu on FollowUpPK = FormFK
		  where FormType='FU-PC2'
		)
--#endregion
--#region tmpDischargeData - Get all discharge related data into temp table
    insert into #tmpDischargeData
	------------------------
		select co.HVCasePK as HVCaseFK
			    ,cd.DischargeReason as DischargeReason
				,PC1TANFAtDischarge
				,MaritalStatusAtDischarge
				,PC1EducationAtDischarge
				,PC1EmploymentAtDischarge
				,EducationalEnrollmentAtDischarge
			   	,case

					when cp.HVCaseFK IN (SELECT oc.HVCaseFK FROM OtherChild oc WHERE oc.HVCaseFK=cp.HVCaseFK and 
																						((oc.FormType = 'IN' and oc.LivingArrangement = '01')
																							or oc.FormType = 'FU'))
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
		from #tmpCohort co
		inner join CaseProgram cp on cp.PC1ID = co.PC1ID
		inner join Kempe k on k.HVCaseFK = co.HVCasePK
		inner join codeLevel cl ON cl.codeLevelPK = CurrentLevelFK
		inner join codeDischarge cd on cd.DischargeCode = cp.DischargeReason 
		left outer join cteLastFollowUp lfu on lfu.HVCaseFK = co.HVCasePK
		left outer join FollowUp fu ON fu.FollowUpPK = lfu.FollowUpPK
		left outer join PC1Issues pc1is ON pc1is.PC1IssuesPK = fu.PC1IssuesFK
		left outer join cteFollowUpPC1 pc1fuca ON pc1fuca.HVCaseFK = co.HVCasePK
		left outer join cteFollowUpOBP obpfuca ON obpfuca.HVCaseFK = co.HVCasePK
		left outer join cteFollowUpPC2 pc2fuca ON pc2fuca.HVCaseFK = co.HVCasePK;

--#endregion
--#region cteCaseLastHomeVisit - get the last home visit for each case in the cohort 
	with cteCaseLastHomeVisit AS 
	-----------------------------
		(select HVCaseFK
				  , max(vl.VisitStartTime) as LastHomeVisit
				  , count(vl.VisitStartTime) as CountOfHomeVisits
			from HVLog vl
			inner join #tmpCohort co on co.HVCasePK = vl.HVCaseFK
			inner join HVCase c on c.HVCasePK = co.HVCasePK
			where VisitType <> '00010'
			group by HVCaseFK
		)
--#endregion
--#region cteCaseFSWCount - get the count of FSWs for each case in the cohort, i.e. how many times it's changed
	, cteCaseFSWCount AS 
	------------------------
		(select HVCaseFK
					, count(wa.WorkerAssignmentPK) as CountOfFSWs
			from dbo.WorkerAssignment wa
			inner join #tmpCohort co on co.HVCasePK = wa.HVCaseFK
			inner join HVCase c on c.HVCasePK = co.HVCasePK
			group by HVCaseFK
		)
--#endregion
--#region ctePC1AgeAtIntake - get the PC1's age at intake
	, ctePC1AgeAtIntake as
	------------------------
		(select c.HVCasePK as HVCaseFK
				,datediff(year,PCDOB,co.IntakeDate) as PC1AgeAtIntake
			from PC 
			inner join HVCase c on c.PC1FK=PCPK
			inner join #tmpCohort co on co.HVCasePK = c.HVCasePK
		)
--#endregion
--#region ctePC1AgeAtIntake - get the PC1's age at intake
	, cteTCInformation as
	------------------------
		(select t.HVCaseFK
				, max(t.TCDOB) as TCDOB
				, max(GestationalAge) as GestationalAge
			from TCID t
			inner join #tmpCohort co on co.HVCasePK = t.HVCaseFK
			inner join HVCase c on c.HVCasePK = co.HVCasePK
			group by t.HVCaseFK
		)
--#endregion
--#region cteMain - get data at intake, join to data at discharge and add to report cache table
	insert into __Temp_Retention_Rates_Main
		select @ProgramFK as ProgramFK
			   ,c.PC1ID
			   ,c.HVCasePK as HVCaseFK
			   ,IntakeDate
			   ,LastHomeVisit
			   ,CountOfFSWs
			   ,CountOfHomeVisits
			   ,DischargeDate
			   ,LevelName
			   ,cp.DischargeReason AS DischargeReasonCode
               ,dd.DischargeReason
			   ,PC1AgeAtIntake
			   ,case
				when DischargeDate is null and datediff(month, IntakeDate, current_timestamp) > 6 then 1
				when DischargeDate is not null and datediff(month, IntakeDate, LastHomeVisit) > 6 then 1
					else 0
				end	as ActiveAt6Months
			   ,case
				when DischargeDate is null and datediff(month, IntakeDate, current_timestamp) > 12 then 1
				when DischargeDate is not null and datediff(month, IntakeDate, LastHomeVisit) > 12 then 1
					else 0
				end	as ActiveAt12Months
				,case
				when DischargeDate is null and datediff(month, IntakeDate, current_timestamp) > 18 then 1
				when DischargeDate is not null and datediff(month, IntakeDate, LastHomeVisit) > 18 then 1
					else 0
				end as ActiveAt18Months
				,case
				when DischargeDate is null and datediff(month, IntakeDate, current_timestamp) > 24 then 1
				when DischargeDate is not null and datediff(month, IntakeDate, LastHomeVisit) > 24 then 1
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
			   		when c.TCDOB is NULL then EDC
					else c.TCDOB
				end as TCDOB
			   ,case 
					when c.TCDOB is null and EDC is not null then 1
					when c.TCDOB is not null and c.TCDOB > IntakeDate then 1
					when c.TCDOB is not null and c.TCDOB <= IntakeDate then 0
				end
				as PrenatalEnrollment
				,case
					when cp.HVCaseFK IN (SELECT oc.HVCaseFK FROM OtherChild oc WHERE oc.HVCaseFK=cp.HVCaseFK AND 
																						oc.FormType='IN' and oc.LivingArrangement = '01') 
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
				,c.OBPInHomeIntake as OBPInHomeAtIntake
				,c.PC2InHomeIntake as PC2InHomeAtIntake
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
				, case when c.TCDOB is null then dateadd(week, -40, c.EDC) 
						when tci.HVCaseFK is null and c.TCDOB is not null
							then dateadd(week, -40, c.TCDOB)
						when tci.HVCaseFK is not NULL and c.TCDOB is not null 
							then dateadd(week, -40, dateadd(week, (40 - isnull(GestationalAge, 40)), c.TCDOB) )
					end as ConceptionDate
			FROM #tmpCohort c 
			left outer join #tmpDischargeData dd ON dd.HVCaseFK = c.HVCasePK
			inner join cteCaseLastHomeVisit lhv ON lhv.HVCaseFK = c.HVCasePK
			inner join cteCaseFSWCount fc ON fc.HVCaseFK = c.HVCasePK
			inner join ctePC1AgeAtIntake aai on aai.HVCaseFK = c.HVCasePK
			inner join CaseProgram cp on cp.PC1ID = c.PC1ID
			inner join PC on PC.PCPK = c.PC1FK
			inner join Kempe k on k.HVCaseFK = c.HVCasePK
			inner join PC1Issues pc1i ON pc1i.HVCaseFK = k.HVCaseFK AND pc1i.PC1IssuesPK = k.PC1IssuesFK
			inner join codeLevel cl ON cl.codeLevelPK = CurrentLevelFK
			left outer join cteTCInformation tci on tci.HVCaseFK = c.HVCasePK
			left outer join codeApp carace on carace.AppCode=Race and AppCodeGroup='Race'
			left outer join (select PBTANF as PC1TANFAtIntake
									,HVCaseFK 
							   from CommonAttributes ca
							  where FormType='IN') inca ON inca.HVCaseFK = c.HVCasePK
			left outer join (select MaritalStatus
									,AppCodeText as MaritalStatusAtIntake
									,IsCurrentlyEmployed AS PC1EmploymentAtIntake
									,EducationalEnrollment
									,PrimaryLanguage
									,HVCaseFK 
							   from CommonAttributes ca
							   left outer join codeApp capp ON capp.AppCode = MaritalStatus and AppCodeGroup = 'MaritalStatus'
							  where FormType = 'IN-PC1') pc1ca ON pc1ca.HVCaseFK = c.HVCasePK
			left outer join (SELECT IsCurrentlyEmployed AS OBPEmploymentAtIntake
									,HVCaseFK 
							   FROM CommonAttributes ca
							  WHERE FormType = 'IN-OBP') obpca ON obpca.HVCaseFK = c.HVCasePK
			left outer join (SELECT HVCaseFK
									, IsCurrentlyEmployed AS PC2EmploymentAtIntake
							   FROM CommonAttributes ca
							  WHERE FormType = 'IN-PC2') pc2ca ON pc2ca.HVCaseFK = c.HVCasePK
			left outer join (SELECT AppCodeText as PC1EducationAtIntake,HighestGrade,HVCaseFK 
							   FROM CommonAttributes ca
							   LEFT OUTER JOIN codeApp capp ON capp.AppCode = HighestGrade and AppCodeGroup = 'Education'
							  WHERE FormType = 'IN-PC1') pc1eduai ON pc1eduai.HVCaseFK = c.HVCasePK
			where (IntakeDate is not null and IntakeDate between @StartDate and @EndDate)

--#endregion

end
GO
