SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <January 4th, 2013>
-- Description:	<gets you data for Quarterly report i.e. J. Program Information for 8 Quarters>
-- exec [rspProgramInformationFor8Quarters] '5','03/31/13'
-- exec [rspProgramInformationFor8Quarters] '2','06/30/12'
-- exec [rspProgramInformationFor8Quarters] '5','06/30/12'
-- exec dbo.rspProgramInformationFor8Quarters @programfk=',13,',@edate='2013-03-31 00:00:00',@sitefk=NULL,@casefilterspositive=NULL
-- exec dbo.rspProgramInformationFor8Quarters @programfk=',19,',@edate='2013-03-31 00:00:00',@sitefk=NULL,@casefilterspositive=NULL

-- exec [rspProgramInformationFor8Quarters] '39','12/31/13'
-- exec [rspProgramInformationFor8Quarters] '19','06/30/13'

-- 02/02/2013 
-- handling when there is no data available e.g. for a new program that just joins hfny like Dominican Womens

-- exec [rspProgramInformationFor8Quarters] '31','2012-06-30'
-- =============================================
CREATE procedure [dbo].[rspProgramInformationFor8Quarters] (@programfk varchar(300) = null
														 , @edate datetime
														 , @sitefk int = 0
														 , @casefilterspositive varchar(100) = ''  
														  )
as
	begin




		if @programfk is null
			begin
				select	@programfk = substring((select	',' + ltrim(rtrim(str(HVProgramPK)))
												from	HVProgram
											   for
												xml	path('')
											   ), 2, 8000)
			end
		set @programfk = replace(@programfk, '"', '')	




		set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0
						   else @SiteFK
					  end
		set @casefilterspositive = case	when @casefilterspositive = '' then null
										else @casefilterspositive
								   end


---- create a table that will be filled in with data at the end
		create table #tblQ8ReportMain (QuarterNumber [varchar](10)
									 , QuarterEndDate [varchar](200) null
									 , numberOfScreens [varchar](200) null
									 , numberOfKempAssessments [varchar](200) null
									 , KempPositivePercentage [varchar](200) null
									 , KempPositiveEnrolled [varchar](200) null
									 , KempPositivePending [varchar](200) null
									 , KempPositiveTerminated [varchar](200) null
									 , AvgPositiveMotherScore [varchar](200) null
									 , EnrolledAtBeginningOfQrtr [varchar](200) null
									 , NewEnrollmentsThisQuarter [varchar](200) null
									 , NewEnrollmentsPrenatal [varchar](200) null
									 , TANFServicesEligible [varchar](200) null
									 , FamiliesDischargedThisQuarter [varchar](200) null
									 , FamiliesCompletingProgramThisQuarter [varchar](200) null
									 , FamiliesActiveAtEndOfThisQuarter [varchar](200) null
									 , FamiliesActiveAtEndOfThisQuarterOnLevel1 [varchar](200) null
									 , FamiliesActiveAtEndOfThisQuarterOnLevelX [varchar](200) null
									 , FamiliesWithNoServiceReferrals [varchar](200) null
									 , AverageVisitsPerMonthPerCase [varchar](200) null
									 , TotalServedInQuarterIncludesClosedCases [varchar](200) null
									 , AverageVisitsPerFamily [varchar](200) null
									 , TANFServicesEligibleAtEnrollment [varchar](200) null
									 , rowBlankforItem9 [varchar](200) null
									 , LengthInProgramUnder6Months [varchar](200) null
									 , LengthInProgramUnder6MonthsTo1Year [varchar](200) null
									 , LengthInProgramUnder1YearTo2Year [varchar](200) null
									 , LengthInProgramUnder2YearsAndOver [varchar](200) null
									  )	





-- Create 8 quarters given a starting quarter end date
-- 02/02/2013 
-- handling when there is no data available. In order to handle, I added the following columns i.e. col1-col26
		create table #tblMake8Quarter ([QuarterNumber] [int]
									 , [QuarterStartDate] [date]
									 , [QuarterEndDate] [date]
									 , [Col1] [varchar](200) default ' '
									 , [Col2] [varchar](200) default ' '
									 , [Col3] [varchar](200) default ' '
									 , [Col4] [varchar](200) default ' '
									 , [Col5] [varchar](200) default ' '
									 , [Col6] [varchar](200) default ' '
									 , [Col7] [varchar](200) default ' '
									 , [Col8] [varchar](200) default ' '
									 , [Col9] [varchar](200) default ' '
									 , [Col10] [varchar](200) default ' '
									 , [Col11] [varchar](200) default ' '
									 , [Col12] [varchar](200) default ' '
									 , [Col13] [varchar](200) default ' '
									 , [Col14] [varchar](200) default ' '
									 , [Col15] [varchar](200) default ' '
									 , [Col16] [varchar](200) default ' '
									 , [Col17] [varchar](200) default ' '
									 , [Col18] [varchar](200) default ' '
									 , [Col19] [varchar](200) default ' '
									 , [Col20] [varchar](200) default ' '
									 , [Col21] [varchar](200) default ' '
									 , [Col22] [varchar](200) default ' '
									 , [Col23] [varchar](200) default ' '
									 , [Col24] [varchar](200) default ' '
									 , [Col25] [varchar](200) default ' '
									 , [Col26] [varchar](200) default ' '
									  )

		insert	into #tblMake8Quarter
				([QuarterNumber]
			   , [QuarterStartDate]
			   , [QuarterEndDate]
				)
				select	8
					  , dateadd(dd, 1, dateadd(s, -1, dateadd(mm, datediff(m, 0, dateadd(mm, -3, @edate)) + 1, 0)))
					  , @edate as QuarterEndDate
		insert	into #tblMake8Quarter
				([QuarterNumber]
			   , [QuarterStartDate]
			   , [QuarterEndDate]
				)
				select	7
					  , dateadd(dd, 1, dateadd(s, -1, dateadd(mm, datediff(m, 0, dateadd(mm, -6, @edate)) + 1, 0)))
					  , dateadd(s, -1, dateadd(mm, datediff(m, 0, dateadd(mm, -3, @edate)) + 1, 0)) as QuarterEndDate
		insert	into #tblMake8Quarter
				([QuarterNumber]
			   , [QuarterStartDate]
			   , [QuarterEndDate]
				)
				select	6
					  , dateadd(dd, 1, dateadd(s, -1, dateadd(mm, datediff(m, 0, dateadd(mm, -9, @edate)) + 1, 0)))
					  , dateadd(s, -1, dateadd(mm, datediff(m, 0, dateadd(mm, -6, @edate)) + 1, 0)) as QuarterEndDate
		insert	into #tblMake8Quarter
				([QuarterNumber]
			   , [QuarterStartDate]
			   , [QuarterEndDate]
				)
				select	5
					  , dateadd(dd, 1, dateadd(s, -1, dateadd(mm, datediff(m, 0, dateadd(mm, -12, @edate)) + 1, 0)))
					  , dateadd(s, -1, dateadd(mm, datediff(m, 0, dateadd(mm, -9, @edate)) + 1, 0)) as QuarterEndDate
		insert	into #tblMake8Quarter
				([QuarterNumber]
			   , [QuarterStartDate]
			   , [QuarterEndDate]
				)
				select	4
					  , dateadd(dd, 1, dateadd(s, -1, dateadd(mm, datediff(m, 0, dateadd(mm, -15, @edate)) + 1, 0)))
					  , dateadd(s, -1, dateadd(mm, datediff(m, 0, dateadd(mm, -12, @edate)) + 1, 0)) as QuarterEndDate
		insert	into #tblMake8Quarter
				([QuarterNumber]
			   , [QuarterStartDate]
			   , [QuarterEndDate]
				)
				select	3
					  , dateadd(dd, 1, dateadd(s, -1, dateadd(mm, datediff(m, 0, dateadd(mm, -18, @edate)) + 1, 0)))
					  , dateadd(s, -1, dateadd(mm, datediff(m, 0, dateadd(mm, -15, @edate)) + 1, 0)) as QuarterEndDate
		insert	into #tblMake8Quarter
				([QuarterNumber]
			   , [QuarterStartDate]
			   , [QuarterEndDate]
				)
				select	2
					  , dateadd(dd, 1, dateadd(s, -1, dateadd(mm, datediff(m, 0, dateadd(mm, -21, @edate)) + 1, 0)))
					  , dateadd(s, -1, dateadd(mm, datediff(m, 0, dateadd(mm, -18, @edate)) + 1, 0)) as QuarterEndDate
		insert	into #tblMake8Quarter
				([QuarterNumber]
			   , [QuarterStartDate]
			   , [QuarterEndDate]
				)
				select	1
					  , dateadd(dd, 1, dateadd(s, -1, dateadd(mm, datediff(m, 0, dateadd(mm, -24, @edate)) + 1, 0)))
					  , dateadd(s, -1, dateadd(mm, datediff(m, 0, dateadd(mm, -21, @edate)) + 1, 0)) as QuarterEndDate


-- SELECT * FROM #tblMake8Quarter  -- equivalent to csr8q cursor
-- exec [rspProgramInformationFor8Quarters] '5','06/30/2012'


---- ***************** ----
-- Please use Pivot to change columns to rows (hint Pivoted on RowNumber) --- .... khalsa
---- ***************** ----

-- Create a Summary table, where we will store values of all 8 quarters
--create table #tblMain8Quarters(
--	[RowNumber] [int],
--	[Title] VARCHAR(250),
--	[LastDayOfQuarter1] VARCHAR(10),
--	[LastDayOfQuarter2] VARCHAR(10),
--	[LastDayOfQuarter3] VARCHAR(10),
--	[LastDayOfQuarter4] VARCHAR(10),
--	[LastDayOfQuarter5] VARCHAR(10),
--	[LastDayOfQuarter6] VARCHAR(10),
--	[LastDayOfQuarter7] VARCHAR(10),
--	[LastDayOfQuarter8] VARCHAR(10)	
--)


-- Initially, get the subset of data that we are interested in ... Good Practice ... Khalsa 
-- We will use this cohort starting item # 3
		create table #tblInitial_cohort ([HVCasePK] [int]
									   , [CaseProgress] [numeric](3, 1) null
									   , [Confidentiality] [bit] null
									   , [CPFK] [int] null
									   , [DateOBPAdded] [datetime] null
									   , [EDC] [datetime] null
									   , [FFFK] [int] null
									   , [FirstChildDOB] [datetime] null
									   , [FirstPrenatalCareVisit] [datetime] null
									   , [FirstPrenatalCareVisitUnknown] [bit] null
									   , [HVCaseCreateDate] [datetime] not null
									   , [HVCaseCreator] [char](10) not null
									   , [HVCaseEditDate] [datetime] null
									   , [HVCaseEditor] [char](10) null
									   , [InitialZip] [char](10) null
									   , [IntakeDate] [datetime] null
									   , [IntakeLevel] [char](1) null
									   , [IntakeWorkerFK] [int] null
									   , [KempeDate] [datetime] null
									   , [OBPInformationAvailable] [bit] null
									   , [OBPFK] [int] null
									   , [OBPinHomeIntake] [bit] null
									   , [OBPRelation2TC] [char](2) null
									   , [PC1FK] [int] not null
									   , [PC1Relation2TC] [char](2) null
									   , [PC1Relation2TCSpecify] [varchar](30) null
									   , [PC2FK] [int] null
									   , [PC2inHomeIntake] [bit] null
									   , [PC2Relation2TC] [char](2) null
									   , [PC2Relation2TCSpecify] [varchar](30) null
									   , [PrenatalCheckupsB4] [int] null
									   , [ScreenDate] [datetime] not null
									   , [TCDOB] [datetime] null
									   , [TCDOD] [datetime] null
									   , [TCNumber] [int] null
									   , [CaseProgramPK] [int]
									   , [CaseProgramCreateDate] [datetime] not null
									   , [CaseProgramCreator] [char](10) not null
									   , [CaseProgramEditDate] [datetime] null
									   , [CaseProgramEditor] [char](10) null
									   , [CaseStartDate] [datetime] not null
									   , [CurrentFAFK] [int] null
									   , [CurrentFAWFK] [int] null
									   , [CurrentFSWFK] [int] null
									   , [CurrentLevelDate] [datetime] not null
									   , [CurrentLevelFK] [int] not null
									   , [DischargeDate] [datetime] null
									   , [DischargeReason] [char](2) null
									   , [DischargeReasonSpecify] [varchar](500) null
									   , [ExtraField1] [char](30) null
									   , [ExtraField2] [char](30) null
									   , [ExtraField3] [char](30) null
									   , [ExtraField4] [char](30) null
									   , [ExtraField5] [char](30) null
									   , [ExtraField6] [char](30) null
									   , [ExtraField7] [char](30) null
									   , [ExtraField8] [char](30) null
									   , [ExtraField9] [char](30) null
									   , [HVCaseFK] [int] not null
									   , [HVCaseFK_old] [int] not null
									   , [OldID] [char](23) null
									   , [PC1ID] [char](13) not null
									   , [ProgramFK] [int] not null
									   , [TransferredtoProgram] [varchar](50) null
									   , [TransferredtoProgramFK] [int] null
									   , [CalcTCDOB] [datetime] null
										)


		insert	into #tblInitial_cohort
				select	[HVCasePK]
					  , [CaseProgress]
					  , [Confidentiality]
					  , [CPFK]
					  , [DateOBPAdded]
					  , [EDC]
					  , [FFFK]
					  , [FirstChildDOB]
					  , [FirstPrenatalCareVisit]
					  , [FirstPrenatalCareVisitUnknown]
					  , [HVCaseCreateDate]
					  , [HVCaseCreator]
					  , [HVCaseEditDate]
					  , [HVCaseEditor]
					  , [InitialZip]
					  , [IntakeDate]
					  , [IntakeLevel]
					  , [IntakeWorkerFK]
					  , [KempeDate]
					  , [OBPInformationAvailable]
					  , [OBPFK]
					  , [OBPinHomeIntake]
					  , [OBPRelation2TC]
					  , [PC1FK]
					  , [PC1Relation2TC]
					  , [PC1Relation2TCSpecify]
					  , [PC2FK]
					  , [PC2inHomeIntake]
					  , [PC2Relation2TC]
					  , [PC2Relation2TCSpecify]
					  , [PrenatalCheckupsB4]
					  , [ScreenDate]
					  , [TCDOB]
					  , [TCDOD]
					  , [TCNumber]
					  , [CaseProgramPK]
					  , [CaseProgramCreateDate]
					  , [CaseProgramCreator]
					  , [CaseProgramEditDate]
					  , [CaseProgramEditor]
					  , [CaseStartDate]
					  , [CurrentFAFK]
					  , [CurrentFAWFK]
					  , [CurrentFSWFK]
					  , [CurrentLevelDate]
					  , [CurrentLevelFK]
					  , [DischargeDate]
					  , [DischargeReason]
					  , [DischargeReasonSpecify]
					  , [ExtraField1]
					  , [ExtraField2]
					  , [ExtraField3]
					  , [ExtraField4]
					  , [ExtraField5]
					  , [ExtraField6]
					  , [ExtraField7]
					  , [ExtraField8]
					  , [ExtraField9]
					  , cp.[HVCaseFK]
					  , [HVCaseFK_old]
					  , [OldID]
					  , [PC1ID]
					  , cp.[ProgramFK]
					  , [TransferredtoProgram]
					  , [TransferredtoProgramFK]
					  , case when h.tcdob is not null then h.tcdob
							 else h.edc
						end as [CalcTCDOB]
				from	HVCase h
				inner join CaseProgram cp on h.HVCasePK = cp.HVCaseFK
				inner join dbo.SplitString(@programfk, ',') on cp.programfk = listitem
				left outer join Worker w on w.WorkerPK = cp.CurrentFSWFK
				left outer join WorkerProgram wp on wp.WorkerFK = w.WorkerPK and wp.ProgramFK = cp.ProgramFK
				inner join dbo.udfCaseFilters(@casefilterspositive, '', @programfk) cf on cf.HVCaseFK = h.HVCasePK
				where	case when @SiteFK = 0 then 1
							 when wp.SiteFK = @SiteFK then 1
							 else 0
						end = 1
						and cp.CaseStartDate < @edate  -- handling transfer cases
						and (DischargeDate is null
							 or DischargeDate >= dateadd(mm, -27, @edate)
							);
	-- 1
		with	cteScreensFor1Cohort
				  as (	-- "1. Total Screens"
		-- Screens Row 1
					  select distinct
								--Chris Papas
								CONVERT(varchar(10), QuarterNumber) as QuarterNumber
							  , count(*) over (partition by [QuarterNumber]) as 'numberOfScreens'
					  from		#tblInitial_cohort h
					  inner join #tblMake8Quarter q8 on h.screendate between [QuarterStartDate] and [QuarterEndDate]
					 ) ,
				cteScreensFor1
				  as (	-- "1. Total Screens"
		-- Screens Row 1
					  select	isnull(s1.QuarterNumber, q8.QuarterNumber) as QuarterNumber
							  , isnull(numberOfScreens, 0) as numberOfScreens
					  from		cteScreensFor1Cohort s1
					  right join #tblMake8Quarter q8 on q8.QuarterNumber = s1.QuarterNumber
					 ) ,		

	-- 2
				cteKempAssessmentsFor2Cohort
				  as (	-- "2. Total Kempe Assessments"
		-- Kempe Assessment Row 2
					  select distinct
								QuarterNumber
							  , count(*) over (partition by [QuarterNumber]) as 'numberOfKempAssessments'
					  from		#tblInitial_cohort h
					  inner join Kempe k on k.HVCaseFK = h.HVCaseFK
					  inner join #tblMake8Quarter q8 on k.KempeDate between [QuarterStartDate] and [QuarterEndDate]
					 ) ,
				cteKempAssessmentsFor2
				  as (	-- "2. Total Kempe Assessments"
		-- Kempe Assessment Row 2		
					  select	isnull(s1.QuarterNumber, q8.QuarterNumber) as QuarterNumber
							  , isnull(numberOfKempAssessments, 0) as numberOfKempAssessments
					  from		cteKempAssessmentsFor2Cohort s1
					  right join #tblMake8Quarter q8 on q8.QuarterNumber = s1.QuarterNumber
					 ) ,		

	-- 2a
				cteKempAssessments_For2aCohort
				  as ( 	
	-- Kempe Assessment Percentage
	-- It will be done in two steps i.e. 1. Get numbers like KempPositive and TotalKemp 2. Then calc Percentage from them in cteKempAssessments_For2a_Calc_Percentage ... khalsa
					  select distinct
								q8.QuarterNumber
							  , count(h.HVCasePK) over (partition by [QuarterNumber]) as 'TotalKemp'
							  , sum(case when k.KempeResult = 1 then 1
										 else 0
									end) over (partition by [QuarterNumber]) as 'KempPositive'
					  from		#tblInitial_cohort h
					  left join Kempe k on k.HVCaseFK = h.HVCasePK
					  inner join #tblMake8Quarter q8 on k.KempeDate between [QuarterStartDate] and [QuarterEndDate]
					 ) ,
				cteKempAssessments_For2a
				  as ( 	
	-- Kempe Assessment Percentage
	-- It will be done in two steps i.e. 1. Get numbers like KempPositive and TotalKemp 2. Then calc Percentage from them in cteKempAssessments_For2a_Calc_Percentage ... khalsa
					  select	isnull(s1.QuarterNumber, q8.QuarterNumber) as QuarterNumber
							  , isnull(TotalKemp, 0) as TotalKemp
							  , isnull(KempPositive, 0) as KempPositive
					  from		cteKempAssessments_For2aCohort s1
					  right join #tblMake8Quarter q8 on q8.QuarterNumber = s1.QuarterNumber
					 ) ,
				cteKempAssessments_For2a_Calc_Percentage
				  as (	-- "    a. % Positive" 
				-- Kempe Assessment Percentage Row 3				
					  select	QuarterNumber
							  , convert(varchar, KempPositive) + ' ('
								+ convert(varchar, round(coalesce(cast(KempPositive as float) * 100 / nullif(TotalKemp,
																										0), 0), 0))
								+ '%)' as KempPositivePercentage
					  from		cteKempAssessments_For2a
					 ) ,		

	-- 2a1
				cteKempAssessments_For2a_1Cohort
				  as ( 
	-- Kempe Assessment Percentage - Positive Enrolled
	-- It will be done in two steps i.e. 1. Get numbers like KempPositiveEnrolled and KempPositive 2. Then calc Percentage from them in cteKempAssessments_For2a_1_Calc_Percentage ... khalsa
					  select distinct
								q8.QuarterNumber
							  , sum(case when ((k.KempeResult = 1)
											   and (h.IntakeDate is not null
													and h.IntakeDate <> ''
												   )
											  ) then 1
										 else 0
									end) over (partition by [QuarterNumber]) as 'KempPositiveEnrolled'
							  , sum(case when k.KempeResult = 1 then 1
										 else 0
									end) over (partition by [QuarterNumber]) as 'KempPositive'
					  from		#tblInitial_cohort h
					  left join Kempe k on k.HVCaseFK = h.HVCasePK
					  inner join #tblMake8Quarter q8 on k.KempeDate between [QuarterStartDate] and [QuarterEndDate]
					 ) ,
				cteKempAssessments_For2a_1
				  as ( 
	-- Kempe Assessment Percentage - Positive Enrolled
	-- It will be done in two steps i.e. 1. Get numbers like KempPositiveEnrolled and KempPositive 2. Then calc Percentage from them in cteKempAssessments_For2a_1_Calc_Percentage ... khalsa
					  select	isnull(s1.QuarterNumber, q8.QuarterNumber) as QuarterNumber
							  , isnull(KempPositiveEnrolled, 0) as KempPositiveEnrolled
							  , isnull(KempPositive, 0) as KempPositive
					  from		cteKempAssessments_For2a_1Cohort s1
					  right join #tblMake8Quarter q8 on q8.QuarterNumber = s1.QuarterNumber
					 ) ,
				cteKempAssessments_For2a_1_Calc_Percentage
				  as (	-- "        1. % Positive Enrolled" 
				-- Kempe Assessment Percentage Row 3				
					  select	QuarterNumber
							  , convert(varchar, KempPositiveEnrolled) + ' ('
								+ convert(varchar, round(coalesce(cast(KempPositiveEnrolled as float) * 100
																  / nullif(KempPositive, 0), 0), 0)) + '%)' as KempPositiveEnrolled
					  from		cteKempAssessments_For2a_1
					 ) ,		

	-- 2a2
				cteKempAssessments_For2a_2Cohort
				  as ( 
	-- Kempe Assessment Percentage - Positive Pending Enrollment
	-- It will be done in two steps i.e. 1. Get numbers like KempPositivePending and KempPositive 2. Then calc Percentage from them in cteKempAssessments_For2a_2_Calc_Percentage ... khalsa
					  select distinct
								q8.QuarterNumber
							  , sum(case when ((k.KempeResult = 1)
											   and (h.DischargeDate is null
													and h.IntakeDate is null
												   )
											  ) then 1
										 else 0
									end) over (partition by [QuarterNumber]) as 'KempPositivePending'
							  , sum(case when k.KempeResult = 1 then 1
										 else 0
									end) over (partition by [QuarterNumber]) as 'KempPositive'
					  from		#tblInitial_cohort h
					  left join Kempe k on k.HVCaseFK = h.HVCasePK
					  inner join #tblMake8Quarter q8 on k.KempeDate between [QuarterStartDate] and [QuarterEndDate]
					 ) ,
				cteKempAssessments_For2a_2
				  as ( 
	-- Kempe Assessment Percentage - Positive Pending Enrollment
	-- It will be done in two steps i.e. 1. Get numbers like KempPositivePending and KempPositive 2. Then calc Percentage from them in cteKempAssessments_For2a_2_Calc_Percentage ... khalsa
					  select	isnull(s1.QuarterNumber, q8.QuarterNumber) as QuarterNumber
							  , isnull(KempPositivePending, 0) as KempPositivePending
							  , isnull(KempPositive, 0) as KempPositive
					  from		cteKempAssessments_For2a_2Cohort s1
					  right join #tblMake8Quarter q8 on q8.QuarterNumber = s1.QuarterNumber
					 ) ,
				cteKempAssessments_For2a_2_Calc_Percentage
				  as (	--	"        2. % Positive Pending Enrollment" 
				-- Kempe Assessment Percentage Row 3				
					  select	QuarterNumber
							  , convert(varchar, KempPositivePending) + ' ('
								+ convert(varchar, round(coalesce(cast(KempPositivePending as float) * 100
																  / nullif(KempPositive, 0), 0), 0)) + '%)' as KempPositivePending
					  from		cteKempAssessments_For2a_2
					 ) ,		

	-- 2a3
				cteKempAssessments_For2a_3Cohort
				  as ( 
	-- Kempe Assessment Percentage - Positive Terminated
	-- It will be done in two steps i.e. 1. Get numbers like KempPositivePending and KempPositive 2. Then calc Percentage from them in cteKempAssessments_For2a_3_Calc_Percentage ... khalsa
					  select distinct
								q8.QuarterNumber
							  , sum(case when ((k.KempeResult = 1)
											   and (h.DischargeDate is not null
													and h.IntakeDate is null
												   )
											  ) then 1
										 else 0
									end) over (partition by [QuarterNumber]) as 'KempPositiveTerminated'
							  , sum(case when k.KempeResult = 1 then 1
										 else 0
									end) over (partition by [QuarterNumber]) as 'KempPositive'
					  from		#tblInitial_cohort h
					  left join Kempe k on k.HVCaseFK = h.HVCasePK
					  inner join #tblMake8Quarter q8 on k.KempeDate between [QuarterStartDate] and [QuarterEndDate]
					 ) ,
				cteKempAssessments_For2a_3
				  as ( 
	-- Kempe Assessment Percentage - Positive Terminated
	-- It will be done in two steps i.e. 1. Get numbers like KempPositivePending and KempPositive 2. Then calc Percentage from them in cteKempAssessments_For2a_3_Calc_Percentage ... khalsa
					  select	isnull(s1.QuarterNumber, q8.QuarterNumber) as QuarterNumber
							  , isnull(KempPositiveTerminated, 0) as KempPositiveTerminated
							  , isnull(KempPositive, 0) as KempPositive
					  from		cteKempAssessments_For2a_3Cohort s1
					  right join #tblMake8Quarter q8 on q8.QuarterNumber = s1.QuarterNumber
					 ) ,
				cteKempAssessments_For2a_3_Calc_Percentage
				  as ( --"        3. % Positive Terminated"
			  -- Kempe Assessment Percentage Row 3				
					  select	QuarterNumber
							  , convert(varchar, KempPositiveTerminated) + ' ('
								+ convert(varchar, round(coalesce(cast(KempPositiveTerminated as float) * 100
																  / nullif(KempPositive, 0), 0), 0)) + '%)' as KempPositiveTerminated
					  from		cteKempAssessments_For2a_3
					 ) ,		

	-- 2b
				ctePositiveKempeScore
				  as (  -- find max score of mom/father/partner ... khalsa
					  select distinct
								q8.QuarterNumber
							  , (select	max(thisValue)
								 from	(select	isnull(cast(k.MomScore as decimal), 0) as thisValue
										 union all
										 select	isnull(cast(k.DadScore as decimal), 0) as thisValue
										 union all
										 select	isnull(cast(k.PartnerScore as decimal), 0) as thisValue
										) as khalsaTable
								) as KempeScore
					  from		#tblInitial_cohort h
					  left join Kempe k on k.HVCaseFK = h.HVCasePK
										   and k.KempeResult = 1 -- keeping 'k.KempeResult = 1' it here (not as in where clause down), it saved 3 seconds of execution time ... Khalsa
					  inner join #tblMake8Quarter q8 on k.KempeDate between [QuarterStartDate] and [QuarterEndDate]
					 ) ,
				cteKempAssessments_For2bCohort
				  as ( -- "    b. Average Positive Mother Score"
	-- MomScore
					  select distinct
								QuarterNumber
							  , avg(KempeScore) over (partition by [QuarterNumber]) as 'AvgPositiveMotherScore'
					  from		ctePositiveKempeScore
					 ) ,
				cteKempAssessments_For2b
				  as ( -- "    b. Average Positive Mother Score"
	-- MomScore
					  select	isnull(s1.QuarterNumber, q8.QuarterNumber) as QuarterNumber
							  , isnull(AvgPositiveMotherScore, 0) as AvgPositiveMotherScore
					  from		cteKempAssessments_For2bCohort s1
					  right join #tblMake8Quarter q8 on q8.QuarterNumber = s1.QuarterNumber
					 ) ,	






	-- 3
				cteEnrolledAtBeginingOfQuarter3Cohort
				  as ( -- 3. Families Enrolled at Beginning of quarter
					  select distinct
								QuarterNumber
							  , count(HVCasePK) over (partition by [QuarterNumber]) as 'EnrolledAtBeginningOfQrtr'
					  from		#tblInitial_cohort ic
					  inner join #tblMake8Quarter q8 on ic.IntakeDate <= [QuarterStartDate]
														and ic.IntakeDate is not null
														and (ic.DischargeDate >= [QuarterStartDate]
															 or ic.DischargeDate is null
															)
					 ) ,
				cteEnrolledAtBeginingOfQuarter3
				  as ( -- 3. Families Enrolled at Beginning of quarter
					  select	isnull(s1.QuarterNumber, q8.QuarterNumber) as QuarterNumber
							  , isnull(EnrolledAtBeginningOfQrtr, 0) as EnrolledAtBeginningOfQrtr
					  from		cteEnrolledAtBeginingOfQuarter3Cohort s1
					  right join #tblMake8Quarter q8 on q8.QuarterNumber = s1.QuarterNumber
					 ) ,	

	-- 4
				cteNewEnrollmentsThisQuarter4Cohort
				  as ( -- "4. New Enrollments this quarter"
					  select distinct
								QuarterNumber
							  , count(h.HVCasePK) over (partition by [QuarterNumber]) as 'NewEnrollmentsThisQuarter'
					  from		#tblInitial_cohort h
					  inner join #tblMake8Quarter q8 on h.IntakeDate between [QuarterStartDate] and [QuarterEndDate]
					 ) ,
				cteNewEnrollmentsThisQuarter4
				  as ( -- "4. New Enrollments this quarter"
					  select	isnull(s1.QuarterNumber, q8.QuarterNumber) as QuarterNumber
							  , isnull(NewEnrollmentsThisQuarter, 0) as NewEnrollmentsThisQuarter
					  from		cteNewEnrollmentsThisQuarter4Cohort s1
					  right join #tblMake8Quarter q8 on q8.QuarterNumber = s1.QuarterNumber
					 ) ,	

	--- 4a
				cteNewEnrollmentsThisQuarter4Again
				  as ( -- We will use this one in cteNewEnrollmentsThisQuarter4a. 
	  -- I am repeating it again here for code clarity. I mean that item 4a have its own code, one can see how I did
					  select distinct
								QuarterNumber
							  , count(h.HVCasePK) over (partition by [QuarterNumber]) as 'NewEnrollmentsThisQuarter'
					  from		#tblInitial_cohort h
					  inner join #tblMake8Quarter q8 on h.IntakeDate between [QuarterStartDate] and [QuarterEndDate]
					 ) ,
				cteNewEnrollmentsThisQuarter4aCohort
				  as ( 
	-- "    a. % Prenatal"
	-- It will be done in two steps i.e. 1. Get numbers like cteNewEnrollmentsThisQuarter4 and cteNewEnrollmentsThisQuarter4a 2. Then calc Percentage from them in cteNewEnrollmentsThisQuarter4a_Calc_Percentage ... khalsa
					  select distinct
								q8.QuarterNumber
							  , count(h.HVCasePK) over (partition by q8.[QuarterNumber]) as 'NewEnrollmentsPrenatal'
							  , q8Again.NewEnrollmentsThisQuarter as NewEnrollmentsThisQuarter
					  from		#tblInitial_cohort h
					  inner join #tblMake8Quarter q8 on h.IntakeDate between [QuarterStartDate] and [QuarterEndDate]
					  inner join cteNewEnrollmentsThisQuarter4Again q8Again on q8Again.QuarterNumber = q8.QuarterNumber
					  where		h.[CalcTCDOB] > IntakeDate
					 ) ,
				cteNewEnrollmentsThisQuarter4a
				  as ( 
	-- "    a. % Prenatal"
	-- It will be done in two steps i.e. 1. Get numbers like cteNewEnrollmentsThisQuarter4 and cteNewEnrollmentsThisQuarter4a 2. Then calc Percentage from them in cteNewEnrollmentsThisQuarter4a_Calc_Percentage ... khalsa
					  select	isnull(s1.QuarterNumber, q8.QuarterNumber) as QuarterNumber
							  , isnull(NewEnrollmentsPrenatal, 0) as NewEnrollmentsPrenatal
							  , isnull(NewEnrollmentsThisQuarter, 0) as NewEnrollmentsThisQuarter
					  from		cteNewEnrollmentsThisQuarter4aCohort s1
					  right join #tblMake8Quarter q8 on q8.QuarterNumber = s1.QuarterNumber
					 ) ,
				cteNewEnrollmentsThisQuarter4a_Calc_Percentage
				  as (select	QuarterNumber
							  , convert(varchar, NewEnrollmentsPrenatal) + ' ('
								+ convert(varchar, round(coalesce(cast(NewEnrollmentsPrenatal as float) * 100
																  / nullif(NewEnrollmentsThisQuarter, 0), 0), 0)) + '%)' as NewEnrollmentsPrenatal
					  from		cteNewEnrollmentsThisQuarter4a
					 ) ,	

	--- 4b
				cteNewEnrollmentsThisQuarter4Again2
				  as ( -- We will use this one in cteNewEnrollmentsThisQuarter4b. 
	  -- I am repeating it again here for code clarity. I mean that item 4a have its own code, one can see how I did
					  select distinct
								QuarterNumber
							  , count(h.HVCasePK) over (partition by [QuarterNumber]) as 'NewEnrollmentsThisQuarter'
					  from		#tblInitial_cohort h
					  inner join #tblMake8Quarter q8 on h.IntakeDate between [QuarterStartDate] and [QuarterEndDate]
					 ) ,
				cteNewEnrollmentsThisQuarter4bCohort
				  as ( -- "    b. % TANF Services Eligible at Enrollment**"
					  select distinct
								q8.QuarterNumber
							  , count(*) over (partition by q8.[QuarterNumber]) as 'TANFServicesEligible'
							  , q8Again2.NewEnrollmentsThisQuarter
					  from		#tblInitial_cohort h
					  inner join CommonAttributes ca on ca.HVCaseFK = h.HVCaseFK
					  inner join #tblMake8Quarter q8 on h.IntakeDate between [QuarterStartDate] and [QuarterEndDate]
					  inner join cteNewEnrollmentsThisQuarter4Again2 q8Again2 on q8Again2.QuarterNumber = q8.QuarterNumber
					  where		ca.TANFServices = 1
								and ca.FormType = 'IN'  -- only from Intake form here
								
					 ) ,
				cteNewEnrollmentsThisQuarter4b
				  as ( -- "    b. % TANF Services Eligible at Enrollment**"
					  select	isnull(s1.QuarterNumber, q8.QuarterNumber) as QuarterNumber
							  , isnull(TANFServicesEligible, 0) as TANFServicesEligible
							  , isnull(NewEnrollmentsThisQuarter, 0) as NewEnrollmentsThisQuarter
					  from		cteNewEnrollmentsThisQuarter4bCohort s1
					  right join #tblMake8Quarter q8 on q8.QuarterNumber = s1.QuarterNumber
					 ) ,
				cteNewEnrollmentsThisQuarter4b_Calc_Percentage
				  as (select	QuarterNumber
							  , convert(varchar, TANFServicesEligible) + ' ('
								+ convert(varchar, round(coalesce(cast(TANFServicesEligible as float) * 100
																  / nullif(NewEnrollmentsThisQuarter, 0), 0), 0)) + '%)' as TANFServicesEligible
					  from		cteNewEnrollmentsThisQuarter4b
					 ) ,	



	-- 5
				cteFamiliesDischargedThisQuarter5Cohort
				  as ( -- "5. Families Discharged this quarter"
					  select distinct
								QuarterNumber
							  , count(h.HVCasePK) over (partition by [QuarterNumber]) as 'FamiliesDischargedThisQuarter'
					  from		#tblInitial_cohort h
					  inner join #tblMake8Quarter q8 on h.DischargeDate between [QuarterStartDate] and [QuarterEndDate]
					  where		h.IntakeDate is not null
					 ) ,
				cteFamiliesDischargedThisQuarter5
				  as ( -- "5. Families Discharged this quarter"
					  select	isnull(s1.QuarterNumber, q8.QuarterNumber) as QuarterNumber
							  , isnull(FamiliesDischargedThisQuarter, 0) as FamiliesDischargedThisQuarter
					  from		cteFamiliesDischargedThisQuarter5Cohort s1
					  right join #tblMake8Quarter q8 on q8.QuarterNumber = s1.QuarterNumber
					 ) ,		


	-- 5a
				cteFamiliesCompletingProgramThisQuarter5aCohort
				  as ( -- "    a. Families completing the program"
		-- Discharged after completing the program through Discharge Form
					  select distinct
								QuarterNumber
							  , sum(case when DischargeReason in (27, 29) then 1
										 else 0
									end) over (partition by [QuarterNumber]) as 'FamiliesCompletingProgramThisQuarter'
					  from		#tblInitial_cohort h
					  inner join #tblMake8Quarter q8 on h.DischargeDate between [QuarterStartDate] and [QuarterEndDate]
					  where		h.IntakeDate is not null
					 ) ,
				cteFamiliesCompletingProgramThisQuarter5a
				  as ( -- "    a. Families completing the program"
		-- Discharged after completing the program through Discharge Form
					  select	isnull(s1.QuarterNumber, q8.QuarterNumber) as QuarterNumber
							  , isnull(FamiliesCompletingProgramThisQuarter, 0) as FamiliesCompletingProgramThisQuarter
					  from		cteFamiliesCompletingProgramThisQuarter5aCohort s1
					  right join #tblMake8Quarter q8 on q8.QuarterNumber = s1.QuarterNumber
					 ) ,		

	-- 6
				cteFamiliesActiveAtEndOfThisQuarter6Cohort
				  as ( -- "6. Families Active at end of this Quarter"
					  select distinct
								QuarterNumber
							  , count(h.HVCasePK) over (partition by [QuarterNumber]) as 'FamiliesActiveAtEndOfThisQuarter'
					  from		#tblInitial_cohort h
					  inner join #tblMake8Quarter q8 on h.IntakeDate <= [QuarterEndDate]
					  where		h.IntakeDate is not null
								and (h.DischargeDate is null
									 or h.DischargeDate > QuarterEndDate
									)
					 ) ,
				cteFamiliesActiveAtEndOfThisQuarter6
				  as ( -- "6. Families Active at end of this Quarter"
					  select	isnull(s1.QuarterNumber, q8.QuarterNumber) as QuarterNumber
							  , isnull(FamiliesActiveAtEndOfThisQuarter, 0) as FamiliesActiveAtEndOfThisQuarter
					  from		cteFamiliesActiveAtEndOfThisQuarter6Cohort s1
					  right join #tblMake8Quarter q8 on q8.QuarterNumber = s1.QuarterNumber
					 ) ,		



	-- 6a
				cteFamiliesActiveAtEndOfThisQuarter6Again
				  as ( -- "6. Families Active at end of this Quarter"
					  select distinct
								QuarterNumber
							  , count(h.HVCasePK) over (partition by [QuarterNumber]) as 'FamiliesActiveAtEndOfThisQuarter'
					  from		#tblInitial_cohort h
					  inner join #tblMake8Quarter q8 on h.IntakeDate <= [QuarterEndDate]
					  where		h.IntakeDate is not null
								and (h.DischargeDate is null
									 or h.DischargeDate > QuarterEndDate
									)
					 ) ,
				cteFamiliesActiveAtEndOfThisQuarter6aCohort
				  as ( -- "    a. % on Level 1 at end of Quarter"
					  select distinct
								q8.QuarterNumber
							  , count(h.HVCasePK) over (partition by q8.[QuarterNumber]) as 'FamiliesActiveAtEndOfThisQuarterOnLevel1'
							  , q86a.FamiliesActiveAtEndOfThisQuarter as FamiliesActiveAtEndOfThisQuarter
					  from		#tblInitial_cohort h
					  inner join #tblMake8Quarter q8 on h.IntakeDate <= [QuarterEndDate]
					  inner join cteFamiliesActiveAtEndOfThisQuarter6Again q86a on q86a.QuarterNumber = q8.QuarterNumber
					  left join HVLevelDetail hd on hd.hvcasefk = h.hvcasefk
					  where		h.IntakeDate is not null
								and (h.DischargeDate is null
									 or h.DischargeDate > QuarterEndDate
									)
								and ((q8.QuarterEndDate between hd.StartLevelDate and hd.EndLevelDate)
									 or (q8.QuarterEndDate >= hd.StartLevelDate
										 and hd.EndLevelDate is null
										)
									)  -- note: they still may be on level 1
								and LevelName in ('Level 1', 'Level 1-SS')
					 ) ,
				cteFamiliesActiveAtEndOfThisQuarter6a
				  as ( -- "    a. % on Level 1 at end of Quarter"
					  select	isnull(s1.QuarterNumber, q8.QuarterNumber) as QuarterNumber
							  , isnull(FamiliesActiveAtEndOfThisQuarterOnLevel1, 0) as FamiliesActiveAtEndOfThisQuarterOnLevel1
							  , isnull(FamiliesActiveAtEndOfThisQuarter, 0) as FamiliesActiveAtEndOfThisQuarter
					  from		cteFamiliesActiveAtEndOfThisQuarter6aCohort s1
					  right join #tblMake8Quarter q8 on q8.QuarterNumber = s1.QuarterNumber
					 ) ,
				cteFamiliesActiveAtEndOfThisQuarter6a_Calc_Percentage
				  as (select	QuarterNumber
							  , convert(varchar, FamiliesActiveAtEndOfThisQuarterOnLevel1) + ' ('
								+ convert(varchar, round(coalesce(cast(FamiliesActiveAtEndOfThisQuarterOnLevel1 as float)
																  * 100 / nullif(FamiliesActiveAtEndOfThisQuarter, 0), 0),
														 0)) + '%)' as FamiliesActiveAtEndOfThisQuarterOnLevel1
					  from		cteFamiliesActiveAtEndOfThisQuarter6a
					 ) ,	

	-- 6b
				cteFamiliesActiveAtEndOfThisQuarter6Again2
				  as ( -- "    b. % on Level X at end of Quarter"
					  select distinct
								QuarterNumber
							  , count(h.HVCasePK) over (partition by [QuarterNumber]) as 'FamiliesActiveAtEndOfThisQuarter'
					  from		#tblInitial_cohort h
					  inner join #tblMake8Quarter q8 on h.IntakeDate <= [QuarterEndDate]
					  where		h.IntakeDate is not null
								and (h.DischargeDate is null
									 or h.DischargeDate > QuarterEndDate
									)
					 ) ,
				cteFamiliesActiveAtEndOfThisQuarter6b
				  as ( -- "    b. % on Level X at end of Quarter"
					  select distinct
								q8.QuarterNumber
							  , count(h.HVCasePK) over (partition by q8.[QuarterNumber]) as 'FamiliesActiveAtEndOfThisQuarterOnLevelX'
							  , q86b.FamiliesActiveAtEndOfThisQuarter as FamiliesActiveAtEndOfThisQuarter
					  from		#tblInitial_cohort h
					  inner join #tblMake8Quarter q8 on h.IntakeDate <= [QuarterEndDate]
					  inner join cteFamiliesActiveAtEndOfThisQuarter6Again2 q86b on q86b.QuarterNumber = q8.QuarterNumber	
			--Note: we are making use of operator i.e. 'Outer Apply'
			-- because a columns values cann't be passed to a function in a join without this operator  ... khalsa
					  outer apply [udfHVLevel](@programfk, q8.QuarterEndDate) e3
					  where		h.IntakeDate is not null
								and h.IntakeDate <= q8.QuarterEndDate
								and (h.DischargeDate is null
									 or h.DischargeDate > QuarterEndDate
									)
								and e3.LevelName like 'Level X'
								and e3.hvcasefk = h.hvcasepk
								and e3.programfk = h.programfk
					 ) ,
				cteFamiliesActiveAtEndOfThisQuarter6bHandlingMissingQuarters
				  as ( -- "    b. % on Level X at end of Quarter"
					  select	isnull(f6bmissing.QuarterNumber, q8.QuarterNumber) as QuarterNumber
							  , isnull(FamiliesActiveAtEndOfThisQuarterOnLevelX, 0) as FamiliesActiveAtEndOfThisQuarterOnLevelX
							  , isnull(FamiliesActiveAtEndOfThisQuarter, 0) as FamiliesActiveAtEndOfThisQuarter
					  from		cteFamiliesActiveAtEndOfThisQuarter6b f6bmissing
					  right join #tblMake8Quarter q8 on q8.QuarterNumber = f6bmissing.QuarterNumber
					 ) ,
				cteFamiliesActiveAtEndOfThisQuarter6b_Calc_Percentage
				  as (select	QuarterNumber
							  , convert(varchar, FamiliesActiveAtEndOfThisQuarterOnLevelX) + ' ('
								+ convert(varchar, round(coalesce(cast(FamiliesActiveAtEndOfThisQuarterOnLevelX as float)
																  * 100 / nullif(FamiliesActiveAtEndOfThisQuarter, 0), 0),
														 0)) + '%)' as FamiliesActiveAtEndOfThisQuarterOnLevelX
					  from		cteFamiliesActiveAtEndOfThisQuarter6bHandlingMissingQuarters
					 ) ,	

	-- 6c
				cteFamiliesActiveAtEndOfThisQuarter6Again3
				  as ( -- "6. Families Active at end of this Quarter"
					  select distinct
								QuarterNumber
							  , count(h.HVCasePK) over (partition by [QuarterNumber]) as 'FamiliesActiveAtEndOfThisQuarter'
					  from		#tblInitial_cohort h
					  inner join #tblMake8Quarter q8 on h.IntakeDate <= [QuarterEndDate]
					  where		h.IntakeDate is not null
								and (h.DischargeDate is null
									 or h.DischargeDate > QuarterEndDate
									)
					 ) ,
				cteFamiliesWithNoServiceReferrals6c
				  as ( -- "    c. % Families with no Service Referrals"
	  -- Find those records (hvcasepk) that are in cteFamiliesActiveAtEndOfThisQuarter6 but does not have Service Referral in table i.e.ServiceReferral
					  select distinct
								q8.QuarterNumber
							  , count(h.HVCasePK) over (partition by q8.[QuarterNumber]) as 'FamiliesWithNoServiceReferrals'
					  from		#tblInitial_cohort h
					  inner join #tblMake8Quarter q8 on h.IntakeDate <= [QuarterEndDate]
					  left join ServiceReferral sr on sr.HVCaseFK = h.HVCaseFK
													  and (ReferralDate <= [QuarterEndDate]) -- leave it here the extra condition
					  where		h.IntakeDate is not null
								and h.IntakeDate <= [QuarterEndDate]
								and (h.DischargeDate is null
									 or h.DischargeDate > [QuarterEndDate]
									)
								and ReferralDate is null  -- This is important
								
					 ) ,
				cteFamiliesWithNoServiceReferrals6cMergeCohort
				  as ( -- "    c. % Families with no Service Referrals"
	  -- Note: There are quarters which are missing in cteFamiliesWithNoServiceReferrals6c because all active families have service referrals in those quarters.
	  -- therefore, we need  to merge to bring back missing quarters
					  select	a.QuarterNumber
							  , FamiliesActiveAtEndOfThisQuarter
							  , case when FamiliesWithNoServiceReferrals > 0 then FamiliesWithNoServiceReferrals
									 else 0
								end as FamiliesWithNoServiceReferrals
					  from		cteFamiliesActiveAtEndOfThisQuarter6Again3 a
					  left join cteFamiliesWithNoServiceReferrals6c b on a.QuarterNumber = b.QuarterNumber
					 ) ,
				cteFamiliesWithNoServiceReferrals6cMerge
				  as ( -- "    c. % Families with no Service Referrals"
	  -- Note: There are quarters which are missing in cteFamiliesWithNoServiceReferrals6c because all active families have service referrals in those quarters.
	  -- therefore, we need  to merge to bring back missing quarters
					  select	isnull(s1.QuarterNumber, q8.QuarterNumber) as QuarterNumber
							  , isnull(FamiliesActiveAtEndOfThisQuarter, 0) as FamiliesActiveAtEndOfThisQuarter
							  , isnull(FamiliesWithNoServiceReferrals, 0) as FamiliesWithNoServiceReferrals
					  from		cteFamiliesWithNoServiceReferrals6cMergeCohort s1
					  right join #tblMake8Quarter q8 on q8.QuarterNumber = s1.QuarterNumber
					 ) ,
				cteFamiliesWithNoServiceReferrals6c_Calc_Percentage
				  as (select	QuarterNumber
							  , convert(varchar, FamiliesWithNoServiceReferrals) + ' ('
								+ convert(varchar, round(coalesce(cast(FamiliesWithNoServiceReferrals as float) * 100
																  / nullif(FamiliesActiveAtEndOfThisQuarter, 0), 0), 0))
								+ '%)' as FamiliesWithNoServiceReferrals
					  from		cteFamiliesWithNoServiceReferrals6cMerge
					 ) ,	

	-- 7	
				cteFamiliesActiveAtEndOfThisQuarter7LevelRateCohort
				  as -- calculate level for each case
	( -- "7. Average Visits per Month per Case on Level 1"
	 select distinct
			q8.QuarterNumber
		  , count(h.HVCasePK) over (partition by q8.[QuarterNumber]) as 'FamiliesActiveAtEndOfThisQuarterOnLevel1'
		  , sum(case when hd.StartLevelDate <= q8.QuarterStartDate then 1
					 when hd.StartLevelDate between q8.QuarterStartDate and q8.QuarterEndDate
					 then round(coalesce(cast(datediff(dd, hd.StartLevelDate, q8.QuarterEndDate) as float) * 100
										 / nullif(datediff(dd, q8.QuarterStartDate, q8.QuarterEndDate), 0), 0), 0) / 100
					 else 0
				end) over (partition by q8.[QuarterNumber]) as 'TotalLevelRate'
	 from	#tblInitial_cohort h
	 inner join #tblMake8Quarter q8 on h.IntakeDate <= [QuarterEndDate]
	 left join HVLevelDetail hd on hd.hvcasefk = h.hvcasefk
	 where	h.IntakeDate is not null
			and (h.DischargeDate is null
				 or h.DischargeDate > QuarterEndDate
				)
			and ((q8.QuarterEndDate between hd.StartLevelDate and hd.EndLevelDate)
				 or (q8.QuarterEndDate >= hd.StartLevelDate
					 and hd.EndLevelDate is null
					)
				)  -- note: they still may be on level 1
			and LevelName in ('Level 1', 'Level 1-SS')
	) ,			cteFamiliesActiveAtEndOfThisQuarter7LevelRate
				  as -- calculate level for each case
	( -- "7. Average Visits per Month per Case on Level 1"
	 select	isnull(s1.QuarterNumber, q8.QuarterNumber) as QuarterNumber
		  , isnull(FamiliesActiveAtEndOfThisQuarterOnLevel1, 0) as FamiliesActiveAtEndOfThisQuarterOnLevel1
		  , isnull(TotalLevelRate, 0) as TotalLevelRate
	 from	cteFamiliesActiveAtEndOfThisQuarter7LevelRateCohort s1
	 right join #tblMake8Quarter q8 on q8.QuarterNumber = s1.QuarterNumber
	) ,			cteFamiliesActiveAtEndOfThisQuarter7NumberOfVisitsCohort
				  as -- calculate visits per case
	( -- "7. Average Visits per Month per Case on Level 1"
	 select distinct
			q8.QuarterNumber
		  , count(h.HVCasePK) over (partition by q8.[QuarterNumber]) as 'FamiliesActiveAtEndOfThisQuarterOnLevel1'
		  , sum(case when hd.StartLevelDate <= q8.QuarterStartDate then 1    -- count(hvcasepk) over (partition by q8.QuarterNumber) -- count of num of visits for the entire quarter if he was on level 1 before quarterstart
					 when VisitStartTime between hd.StartLevelDate and q8.QuarterEndDate then 1
					 else 0
				end) over (partition by q8.[QuarterNumber]) as 'TotalVisitRate'
	 from	#tblInitial_cohort h
	 left join HVLevelDetail hd on hd.hvcasefk = h.hvcasefk
	 left outer join hvlog on h.hvcasefk = hvlog.hvcasefk
	 inner join #tblMake8Quarter q8 on hvlog.VisitStartTime between q8.QuarterStartDate and q8.QuarterEndDate
	 where	h.IntakeDate is not null
			and (h.DischargeDate is null
				 or h.DischargeDate > QuarterEndDate
				)
			and ((q8.QuarterEndDate between hd.StartLevelDate and hd.EndLevelDate)
				 or (q8.QuarterEndDate >= hd.StartLevelDate
					 and hd.EndLevelDate is null
					)
				)  -- note: they still may be on level 1
			and LevelName in ('Level 1', 'Level 1-SS')
	) ,			cteFamiliesActiveAtEndOfThisQuarter7NumberOfVisits
				  as -- calculate visits per case
	( -- "7. Average Visits per Month per Case on Level 1"
	 select	isnull(s1.QuarterNumber, q8.QuarterNumber) as QuarterNumber
		  , isnull(FamiliesActiveAtEndOfThisQuarterOnLevel1, 0) as FamiliesActiveAtEndOfThisQuarterOnLevel1
		  , isnull(TotalVisitRate, 0) as TotalVisitRate
	 from	cteFamiliesActiveAtEndOfThisQuarter7NumberOfVisitsCohort s1
	 right join #tblMake8Quarter q8 on q8.QuarterNumber = s1.QuarterNumber
	) ,			cteFamiliesActiveAtEndOfThisQuarter7
				  as -- calculate visits per case
		( -- "7. Average Visits per Month per Case on Level 1"	
		 select	lr.QuarterNumber
			 --, lr.FamiliesActiveAtEndOfThisQuarterOnLevel1
			 --, TotalLevelRate
			 ----, nv.QuarterNumber
			 --, nv.FamiliesActiveAtEndOfThisQuarterOnLevel1
			 --, TotalVisitRate
			 --, ( TotalVisitRate / (3 * TotalLevelRate) ) AS AverageVisitsPerMonthPerCase
			  , round(coalesce(cast(TotalVisitRate as float) * 100 / nullif(3 * TotalLevelRate, 0), 0), 0) / 100 as AverageVisitsPerMonthPerCase
		 from	cteFamiliesActiveAtEndOfThisQuarter7LevelRate lr
		 inner join cteFamiliesActiveAtEndOfThisQuarter7NumberOfVisits nv on nv.QuarterNumber = lr.QuarterNumber
		) ,	

	-- 8
				cteTotalServedInQuarterIncludesClosedCases8Cohort
				  as ( -- "8. Total Served in Quarter(includes closed cases)"
					  select distinct
								QuarterNumber
							  , count(h.HVCasePK) over (partition by [QuarterNumber]) as 'TotalServedInQuarterIncludesClosedCases'
					  from		#tblInitial_cohort h
					  inner join #tblMake8Quarter q8 on h.IntakeDate <= [QuarterEndDate]
					  where		h.IntakeDate is not null
								and (h.DischargeDate is null
									 or h.DischargeDate >= QuarterStartDate
									) -- not discharged or discharged after the quarter start date		
								
					 ) ,
				cteTotalServedInQuarterIncludesClosedCases8
				  as ( -- "8. Total Served in Quarter(includes closed cases)"
					  select	isnull(s1.QuarterNumber, q8.QuarterNumber) as QuarterNumber
							  , isnull(TotalServedInQuarterIncludesClosedCases, 0) as TotalServedInQuarterIncludesClosedCases
					  from		cteTotalServedInQuarterIncludesClosedCases8Cohort s1
					  right join #tblMake8Quarter q8 on q8.QuarterNumber = s1.QuarterNumber
					 ) ,	



	-- 8a
				cteAllFamilies8AgainFor8aCohort
				  as ( -- "8    a. Average Visits per Family"
					  select distinct
								QuarterNumber
							  , count(h.HVCasePK) over (partition by [QuarterNumber]) as 'TotalFamiliesServed'
					  from		#tblInitial_cohort h
					  inner join #tblMake8Quarter q8 on h.IntakeDate <= [QuarterEndDate]
					  where		h.IntakeDate is not null
								and (h.DischargeDate is null
									 or h.DischargeDate >= QuarterStartDate
									) -- not discharged or discharged after the quarter start date		
								
					 ) ,
				cteAllFamilies8AgainFor8a
				  as ( -- "8    a. Average Visits per Family"
					  select	isnull(s1.QuarterNumber, q8.QuarterNumber) as QuarterNumber
							  , isnull(TotalFamiliesServed, 0) as TotalFamiliesServed
					  from		cteAllFamilies8AgainFor8aCohort s1
					  right join #tblMake8Quarter q8 on q8.QuarterNumber = s1.QuarterNumber
					 ) ,
				cteAllFamilies8aVisitsCohort
				  as ( -- "8    a. Average Visits per Family"
					  select  distinct
								QuarterNumber
							  , count(HVLog.HVLogPK) over (partition by [QuarterNumber]) as 'TotalHVlogActivities'
					  from		#tblInitial_cohort h
					  left join HVLevelDetail hd on hd.hvcasefk = h.hvcasefk
					  left outer join hvlog on h.hvcasefk = hvlog.hvcasefk
					  inner join #tblMake8Quarter q8 on hvlog.VisitStartTime between q8.QuarterStartDate and q8.QuarterEndDate
					  where		h.IntakeDate is not null
								and h.IntakeDate <= q8.[QuarterEndDate]
								and (h.DischargeDate is null
									 or h.DischargeDate >= [QuarterStartDate]
									) -- not discharged or discharged after the quarter start date	
								and HVLog.VisitType <> '00010'
					 ) ,
				cteAllFamilies8aVisits
				  as ( -- "8    a. Average Visits per Family"
					  select	isnull(s1.QuarterNumber, q8.QuarterNumber) as QuarterNumber
							  , isnull(TotalHVlogActivities, 0) as TotalHVlogActivities
					  from		cteAllFamilies8aVisitsCohort s1
					  right join #tblMake8Quarter q8 on q8.QuarterNumber = s1.QuarterNumber
					 ) ,
				cteAverageVisitsPerFamily8a
				  as (  -- "8    a. Average Visits per Family"
					  select	lr.QuarterNumber
			 --, TotalFamiliesServed
			 ----, nv.QuarterNumber
			 --, TotalHVlogActivities		
							  , round(coalesce(cast(TotalHVlogActivities as float) * 100 / nullif(3
																								  * TotalFamiliesServed,
																								  0), 0), 0) / 100 as AverageVisitsPerFamily
					  from		cteAllFamilies8AgainFor8a lr
					  inner join cteAllFamilies8aVisits nv on nv.QuarterNumber = lr.QuarterNumber
					 ) ,	

	-- 8b	
				cteAllFamilies8AgainFor8b
				  as ( -- "8    a. Average Visits per Family"
					  select distinct
								QuarterNumber
							  , count(h.HVCasePK) over (partition by [QuarterNumber]) as 'TotalFamiliesServed'
					  from		#tblInitial_cohort h
					  inner join #tblMake8Quarter q8 on h.IntakeDate <= [QuarterEndDate]
					  where		h.IntakeDate is not null
								and (h.DischargeDate is null
									 or h.DischargeDate >= QuarterStartDate
									) -- not discharged or discharged after the quarter start date		
								
					 ) ,	


	-- 8b
				cteAverageVisitsPerFamily8bCohort
				  as (  -- "8    b. % TANF Services Eligible at enrollment**"
					  select distinct
								q8.QuarterNumber
							  , count(*) over (partition by q8.[QuarterNumber]) as 'TANFServicesEligible'
							  , q8b.TotalFamiliesServed
					  from		#tblInitial_cohort h
					  inner join CommonAttributes ca on ca.HVCaseFK = h.HVCaseFK
					  inner join #tblMake8Quarter q8 on h.IntakeDate <= [QuarterEndDate]
					  inner join cteAllFamilies8AgainFor8b q8b on q8b.QuarterNumber = q8.QuarterNumber
					  where		h.IntakeDate is not null
								and (h.DischargeDate is null
									 or h.DischargeDate >= QuarterStartDate
									) -- not discharged or discharged after the quarter start date	
								and ca.TANFServices = 1
								and ca.FormType = 'IN'  -- only from Intake form here	
								
					 ) ,
				cteAverageVisitsPerFamily8b
				  as (  -- "8    b. % TANF Services Eligible at enrollment**"
					  select	isnull(s1.QuarterNumber, q8.QuarterNumber) as QuarterNumber
							  , isnull(TANFServicesEligible, 0) as TANFServicesEligible
							  , isnull(TotalFamiliesServed, 0) as TotalFamiliesServed
					  from		cteAverageVisitsPerFamily8bCohort s1
					  right join #tblMake8Quarter q8 on q8.QuarterNumber = s1.QuarterNumber
					 ) ,	

	-- 8b
				cteAverageVisitsPerFamily8bFinal
				  as (  -- "8    b. % TANF Services Eligible at enrollment**"
					  select	QuarterNumber
							  , convert(varchar, TANFServicesEligible) + ' ('
								+ convert(varchar, round(coalesce(cast(TANFServicesEligible as float) * 100
																  / nullif(TotalFamiliesServed, 0), 0), 0)) + '%)' as TANFServicesEligibleAtEnrollment
					  from		cteAverageVisitsPerFamily8b
					 ) ,	

	-- 9
				cteLengthInProgram9
				  as ( -- "9. Length in Program for Active at End of Quarter"
					  select	q8.QuarterNumber
							  , case when (datediff(dd, h.IntakeDate, q8.[QuarterEndDate]) between 0 and 182) then 1
									 else 0
								end as 'LengthInProgramUnder6Months'
							  , case when (datediff(dd, h.IntakeDate, q8.[QuarterEndDate]) between 183 and 365) then 1
									 else 0
								end as 'LengthInProgramUnder6MonthsTo1Year'
							  , case when (datediff(dd, h.IntakeDate, q8.[QuarterEndDate]) between 366 and 730) then 1
									 else 0
								end as 'LengthInProgramUnder1YearTo2Year'
							  , case when (datediff(dd, h.IntakeDate, q8.[QuarterEndDate]) > 730) then 1
									 else 0
								end as 'LengthInProgramUnder2YearsAndOver'
					  from		#tblInitial_cohort h
					  inner join #tblMake8Quarter q8 on h.IntakeDate <= [QuarterEndDate]
					  where		h.IntakeDate is not null
								and (h.DischargeDate is null
									 or h.DischargeDate > [QuarterEndDate]
									) -- active cases			
								
					 ) ,
				cteLengthInProgram9SumCohort
				  as ( -- "9. Length in Program for Active at End of Quarter"
					  select distinct
								QuarterNumber
							  , sum(LengthInProgramUnder6Months) over (partition by [QuarterNumber]) as 'LengthInProgramUnder6Months'
							  , sum(LengthInProgramUnder6MonthsTo1Year) over (partition by [QuarterNumber]) as 'LengthInProgramUnder6MonthsTo1Year'
							  , sum(LengthInProgramUnder1YearTo2Year) over (partition by [QuarterNumber]) as 'LengthInProgramUnder1YearTo2Year'
							  , sum(LengthInProgramUnder2YearsAndOver) over (partition by [QuarterNumber]) as 'LengthInProgramUnder2YearsAndOver'
					  from		cteLengthInProgram9
					 ) ,
				cteLengthInProgram9Sum
				  as ( -- "9. Length in Program for Active at End of Quarter"
					  select	isnull(s1.QuarterNumber, q8.QuarterNumber) as QuarterNumber
							  , isnull(LengthInProgramUnder6Months, 0) as LengthInProgramUnder6Months
							  , isnull(LengthInProgramUnder6MonthsTo1Year, 0) as LengthInProgramUnder6MonthsTo1Year
							  , isnull(LengthInProgramUnder1YearTo2Year, 0) as LengthInProgramUnder1YearTo2Year
							  , isnull(LengthInProgramUnder2YearsAndOver, 0) as LengthInProgramUnder2YearsAndOver
					  from		cteLengthInProgram9SumCohort s1
					  right join #tblMake8Quarter q8 on q8.QuarterNumber = s1.QuarterNumber
					 ) ,
				cteLengthInProgramAtEndOfThisQuarter9
				  as ( -- "6. Families Active at end of this Quarter"
					  select distinct
								QuarterNumber
							  , count(h.HVCasePK) over (partition by [QuarterNumber]) as 'FamiliesActiveAtEndOfThisQuarter'
					  from		#tblInitial_cohort h
					  inner join #tblMake8Quarter q8 on h.IntakeDate <= [QuarterEndDate]
					  where		h.IntakeDate is not null
								and (h.DischargeDate is null
									 or h.DischargeDate >= QuarterEndDate
									)
					 ) ,
				cteLengthInProgramFinal
				  as (  -- "9. Length in Program for Active at End of Quarter"
					  select	cl.QuarterNumber
							  , convert(varchar, LengthInProgramUnder6Months) + ' ('
								+ convert(varchar, round(coalesce(cast(LengthInProgramUnder6Months as float) * 100
																  / nullif(ct.FamiliesActiveAtEndOfThisQuarter, 0), 0),
														 0)) + '%)' as LengthInProgramUnder6Months
							  , convert(varchar, LengthInProgramUnder6MonthsTo1Year) + ' ('
								+ convert(varchar, round(coalesce(cast(LengthInProgramUnder6MonthsTo1Year as float)
																  * 100 / nullif(ct.FamiliesActiveAtEndOfThisQuarter, 0),
																  0), 0)) + '%)' as LengthInProgramUnder6MonthsTo1Year
							  , convert(varchar, LengthInProgramUnder1YearTo2Year) + ' ('
								+ convert(varchar, round(coalesce(cast(LengthInProgramUnder1YearTo2Year as float) * 100
																  / nullif(ct.FamiliesActiveAtEndOfThisQuarter, 0), 0),
														 0)) + '%)' as LengthInProgramUnder1YearTo2Year
							  , convert(varchar, LengthInProgramUnder2YearsAndOver) + ' ('
								+ convert(varchar, round(coalesce(cast(LengthInProgramUnder2YearsAndOver as float) * 100
																  / nullif(ct.FamiliesActiveAtEndOfThisQuarter, 0), 0),
														 0)) + '%)' as LengthInProgramUnder2YearsAndOver
					  from		cteLengthInProgram9Sum cl
					  inner join cteLengthInProgramAtEndOfThisQuarter9 ct on ct.QuarterNumber = cl.QuarterNumber
					 )
			---- exec [rspProgramInformationFor8Quarters] '2','06/30/2012'


--SELECT * FROM cteLengthInProgramFinal


	-- For report Summary - Just add the new row (add another inner join for a newly created cte for the new row in the report summary) ... Khalsa

	insert	into #tblQ8ReportMain
			(QuarterNumber
		   , QuarterEndDate
		   , numberOfScreens
		   , numberOfKempAssessments
		   , KempPositivePercentage
		   , KempPositiveEnrolled
		   , KempPositivePending
		   , KempPositiveTerminated
		   , AvgPositiveMotherScore
		   , EnrolledAtBeginningOfQrtr
		   , NewEnrollmentsThisQuarter
		   , NewEnrollmentsPrenatal
		   , TANFServicesEligible
		   , FamiliesDischargedThisQuarter
		   , FamiliesCompletingProgramThisQuarter
		   , FamiliesActiveAtEndOfThisQuarter
		   , FamiliesActiveAtEndOfThisQuarterOnLevel1
		   , FamiliesActiveAtEndOfThisQuarterOnLevelX
		   , FamiliesWithNoServiceReferrals
		   , AverageVisitsPerMonthPerCase
		   , TotalServedInQuarterIncludesClosedCases
		   , AverageVisitsPerFamily
		   , TANFServicesEligibleAtEnrollment
		   , rowBlankforItem9
		   , LengthInProgramUnder6Months
		   , LengthInProgramUnder6MonthsTo1Year
		   , LengthInProgramUnder1YearTo2Year
		   , LengthInProgramUnder2YearsAndOver	
			)
			select	scrns.QuarterNumber
				  , left(convert(varchar, q8.QuarterEndDate, 120), 10) as QuarterEndDate -- convert into string
				  , numberOfScreens
				  , numberOfKempAssessments
				  , q82a.KempPositivePercentage
				  , q82a1.KempPositiveEnrolled
				  , q82a2.KempPositivePending
				  , q82a3.KempPositiveTerminated
				  , convert(decimal(4, 1), q82b.AvgPositiveMotherScore) as AvgPositiveMotherScore
				  , q83.EnrolledAtBeginningOfQrtr
				  , q84.NewEnrollmentsThisQuarter
				  , q84a.NewEnrollmentsPrenatal
				  , q84b.TANFServicesEligible
				  , q85.FamiliesDischargedThisQuarter
				  , q85a.FamiliesCompletingProgramThisQuarter
				  , q86.FamiliesActiveAtEndOfThisQuarter
				  , q86a.FamiliesActiveAtEndOfThisQuarterOnLevel1
				  , q86b.FamiliesActiveAtEndOfThisQuarterOnLevelX
				  , q86c.FamiliesWithNoServiceReferrals
				  , q87.AverageVisitsPerMonthPerCase
				  , q88.TotalServedInQuarterIncludesClosedCases
				  , q88a.AverageVisitsPerFamily
				  , q88b.TANFServicesEligibleAtEnrollment
				  , '' as rowBlankforItem9
				  , q9.LengthInProgramUnder6Months
				  , q9.LengthInProgramUnder6MonthsTo1Year
				  , q9.LengthInProgramUnder1YearTo2Year
				  , q9.LengthInProgramUnder2YearsAndOver
			from	cteScreensFor1 scrns
			inner join cteKempAssessmentsFor2 ka on ka.QuarterNumber = scrns.QuarterNumber
			inner join cteKempAssessments_For2a_Calc_Percentage q82a on q82a.QuarterNumber = scrns.QuarterNumber
			inner join cteKempAssessments_For2a_1_Calc_Percentage q82a1 on q82a1.QuarterNumber = scrns.QuarterNumber
			inner join cteKempAssessments_For2a_2_Calc_Percentage q82a2 on q82a2.QuarterNumber = scrns.QuarterNumber
			inner join cteKempAssessments_For2a_3_Calc_Percentage q82a3 on q82a3.QuarterNumber = scrns.QuarterNumber
			inner join cteKempAssessments_For2b q82b on q82b.QuarterNumber = scrns.QuarterNumber
			inner join cteEnrolledAtBeginingOfQuarter3 q83 on q83.QuarterNumber = scrns.QuarterNumber
			inner join cteNewEnrollmentsThisQuarter4 q84 on q84.QuarterNumber = scrns.QuarterNumber
			inner join cteNewEnrollmentsThisQuarter4a_Calc_Percentage q84a on q84a.QuarterNumber = scrns.QuarterNumber
			inner join cteNewEnrollmentsThisQuarter4b_Calc_Percentage q84b on q84b.QuarterNumber = scrns.QuarterNumber
			inner join cteFamiliesDischargedThisQuarter5 q85 on q85.QuarterNumber = scrns.QuarterNumber
			inner join cteFamiliesCompletingProgramThisQuarter5a q85a on q85a.QuarterNumber = scrns.QuarterNumber
			inner join cteFamiliesActiveAtEndOfThisQuarter6 q86 on q86.QuarterNumber = scrns.QuarterNumber
			inner join cteFamiliesActiveAtEndOfThisQuarter6a_Calc_Percentage q86a on q86a.QuarterNumber = scrns.QuarterNumber
			inner join cteFamiliesActiveAtEndOfThisQuarter6b_Calc_Percentage q86b on q86b.QuarterNumber = scrns.QuarterNumber
			inner join cteFamiliesWithNoServiceReferrals6c_Calc_Percentage q86c on q86c.QuarterNumber = scrns.QuarterNumber
			inner join cteFamiliesActiveAtEndOfThisQuarter7 q87 on q87.QuarterNumber = scrns.QuarterNumber
			inner join cteTotalServedInQuarterIncludesClosedCases8 q88 on q88.QuarterNumber = scrns.QuarterNumber
			inner join cteAverageVisitsPerFamily8a q88a on q88a.QuarterNumber = scrns.QuarterNumber
			inner join cteAverageVisitsPerFamily8bFinal q88b on q88b.QuarterNumber = scrns.QuarterNumber
			inner join cteLengthInProgramFinal q9 on q9.QuarterNumber = scrns.QuarterNumber
			inner join #tblMake8Quarter q8 on q8.QuarterNumber = scrns.QuarterNumber
			order by scrns.QuarterNumber 



		insert	into #tblQ8ReportMain
				(QuarterNumber
			   , QuarterEndDate
			   , numberOfScreens
			   , numberOfKempAssessments
			   , KempPositivePercentage
			   , KempPositiveEnrolled
			   , KempPositivePending
			   , KempPositiveTerminated
			   , AvgPositiveMotherScore
			   , EnrolledAtBeginningOfQrtr
			   , NewEnrollmentsThisQuarter
			   , NewEnrollmentsPrenatal
			   , TANFServicesEligible
			   , FamiliesDischargedThisQuarter
			   , FamiliesCompletingProgramThisQuarter
			   , FamiliesActiveAtEndOfThisQuarter
			   , FamiliesActiveAtEndOfThisQuarterOnLevel1
			   , FamiliesActiveAtEndOfThisQuarterOnLevelX
			   , FamiliesWithNoServiceReferrals
			   , AverageVisitsPerMonthPerCase
			   , TotalServedInQuarterIncludesClosedCases
			   , AverageVisitsPerFamily
			   , TANFServicesEligibleAtEnrollment
			   , rowBlankforItem9
			   , LengthInProgramUnder6Months
			   , LengthInProgramUnder6MonthsTo1Year
			   , LengthInProgramUnder1YearTo2Year
			   , LengthInProgramUnder2YearsAndOver	

				)
				select	99
					  , 'Last day of Quarter'
					  , '1. Total Screens'
					  , '2. Total Kempe Assessments'
					  , '    a. % Positive'
					  , '        1. % Positive Enrolled'
					  , '        2. % Positive Pending Enrollment'
					  , '        3. % Positive Terminated'
					  , '    b. Average Positive Score'
					  , '3. Families Enrolled at Beginning of quarter'
					  , '4. New Enrollments this quarter'
					  , '    a. % Prenatal'
					  , '    b. % TANF Services Eligible at Enrollment**'
					  , '5. Families Discharged this quarter'
					  , '    a. Families completing the program'
					  , '6. Families Active at end of this Quarter'
					  , '    a. % on Level 1 at end of Quarter'
					  , '    b. % on Level X at end of Quarter'
					  , '    c. % Families with no Service Referrals'
					  , '7. Average Visits per Month per Case on Level 1 or Level 1-SS'
					  , '8. Total Served in Quarter(includes closed cases)'
					  , '    a. Average Visits per Family'
					  , '    b. % TANF Services Eligible at enrollment**'
					  , '9. Length in Program for Active at End of Quarter'
					  , '    a. Under 6 months'
					  , '    b. 6 months up to 1 year'
					  , '    c. 1 year up to 2 years'
					  , '    d. 2 years and Over'			

-- handling when there is no data available e.g. for a new program that just joins hfny like Dominican Womens
-- add quarters with missing data. just add rows for those quarters with placeholders containing fake/imaginery data
				union all
				select	[QuarterNumber]
					  , left(convert(varchar, QuarterEndDate, 120), 10) as QuarterEndDate
					  , [Col1]
					  , [Col2]
					  , [Col3]
					  , [Col4]
					  , [Col5]
					  , [Col6]
					  , [Col7]
					  , [Col8]
					  , [Col9]
					  , [Col10]
					  , [Col11]
					  , [Col12]
					  , [Col13]
					  , [Col14]
					  , [Col15]
					  , [Col16]
					  , [Col17]
					  , [Col18]
					  , [Col19]
					  , [Col20]
					  , [Col21]
					  , [Col22]
					  , [Col23]
					  , [Col24]
					  , [Col25]
					  , [Col26]
				from	#tblMake8Quarter
				where	QuarterNumber not in (select	QuarterNumber
											  from		#tblQ8ReportMain)

---- exec [rspProgramInformationFor8Quarters] '2','06/30/2012'
--SELECT * from #tblQ8ReportMain

-- Objective: Transpose Rows into Columns - what a pain in the ...
-- Idea: Create 9 variable tables and later join them to get our final result
-- Note: in each variable table, we are using UnPivot method  ... Khalsa


		declare	@tblcol99 table ([Q8Columns] varchar(max)
							   , [Q8LeftNavText] varchar(max)
								)

		declare	@tblcol1 table ([Q8Columns] varchar(max)
							  , [Q8Col1] varchar(max)
							   )

		declare	@tblcol2 table ([Q8Columns] varchar(max)
							  , [Q8Col2] varchar(max)
							   )

		declare	@tblcol3 table ([Q8Columns] varchar(max)
							  , [Q8Col3] varchar(max)
							   )

		declare	@tblcol4 table ([Q8Columns] varchar(max)
							  , [Q8Col4] varchar(max)
							   )

		declare	@tblcol5 table ([Q8Columns] varchar(max)
							  , [Q8Col5] varchar(max)
							   )

		declare	@tblcol6 table ([Q8Columns] varchar(max)
							  , [Q8Col6] varchar(max)
							   )

		declare	@tblcol7 table ([Q8Columns] varchar(max)
							  , [Q8Col7] varchar(max)
							   )

		declare	@tblcol8 table ([Q8Columns] varchar(max)
							  , [Q8Col8] varchar(max)
							   );
		with	cteCol99
				  as (select	*
					  from		#tblQ8ReportMain as Q8Report
					  where		Q8Report.QuarterNumber = 99
					 )
			insert	into @tblcol99
					select	field
						  , value
					from	cteCol99 as col1 unpivot 
( value for field in (QuarterEndDate, numberOfScreens, numberOfKempAssessments, KempPositivePercentage,
					  KempPositiveEnrolled, KempPositivePending, KempPositiveTerminated, AvgPositiveMotherScore,
					  EnrolledAtBeginningOfQrtr, NewEnrollmentsThisQuarter, NewEnrollmentsPrenatal, TANFServicesEligible,
					  FamiliesDischargedThisQuarter, FamiliesCompletingProgramThisQuarter,
					  FamiliesActiveAtEndOfThisQuarter, FamiliesActiveAtEndOfThisQuarterOnLevel1,
					  FamiliesActiveAtEndOfThisQuarterOnLevelX, FamiliesWithNoServiceReferrals,
					  AverageVisitsPerMonthPerCase, TotalServedInQuarterIncludesClosedCases, AverageVisitsPerFamily,
					  TANFServicesEligibleAtEnrollment, rowBlankforItem9, LengthInProgramUnder6Months,
					  LengthInProgramUnder6MonthsTo1Year, LengthInProgramUnder1YearTo2Year,
					  LengthInProgramUnder2YearsAndOver) ) unpvtCol99


-- column1
;

		with	cteCol1
				  as (select	*
					  from		#tblQ8ReportMain as Q8Report
					  where		Q8Report.QuarterNumber = 1
					 )
			insert	into @tblcol1
					select	field
						  , value
					from	cteCol1 as col1 unpivot 
( value for field in (QuarterEndDate, numberOfScreens, numberOfKempAssessments, KempPositivePercentage,
					  KempPositiveEnrolled, KempPositivePending, KempPositiveTerminated, AvgPositiveMotherScore,
					  EnrolledAtBeginningOfQrtr, NewEnrollmentsThisQuarter, NewEnrollmentsPrenatal, TANFServicesEligible,
					  FamiliesDischargedThisQuarter, FamiliesCompletingProgramThisQuarter,
					  FamiliesActiveAtEndOfThisQuarter, FamiliesActiveAtEndOfThisQuarterOnLevel1,
					  FamiliesActiveAtEndOfThisQuarterOnLevelX, FamiliesWithNoServiceReferrals,
					  AverageVisitsPerMonthPerCase, TotalServedInQuarterIncludesClosedCases, AverageVisitsPerFamily,
					  TANFServicesEligibleAtEnrollment, rowBlankforItem9, LengthInProgramUnder6Months,
					  LengthInProgramUnder6MonthsTo1Year, LengthInProgramUnder1YearTo2Year,
					  LengthInProgramUnder2YearsAndOver) ) unpvtCol1


-- column2
;
		with	cteCol2
				  as (select	*
					  from		#tblQ8ReportMain as Q8Report
					  where		Q8Report.QuarterNumber = 2
					 )
			insert	into @tblcol2
					select	field
						  , value
					from	cteCol2 as col2 unpivot 
( value for field in (QuarterEndDate, numberOfScreens, numberOfKempAssessments, KempPositivePercentage,
					  KempPositiveEnrolled, KempPositivePending, KempPositiveTerminated, AvgPositiveMotherScore,
					  EnrolledAtBeginningOfQrtr, NewEnrollmentsThisQuarter, NewEnrollmentsPrenatal, TANFServicesEligible,
					  FamiliesDischargedThisQuarter, FamiliesCompletingProgramThisQuarter,
					  FamiliesActiveAtEndOfThisQuarter, FamiliesActiveAtEndOfThisQuarterOnLevel1,
					  FamiliesActiveAtEndOfThisQuarterOnLevelX, FamiliesWithNoServiceReferrals,
					  AverageVisitsPerMonthPerCase, TotalServedInQuarterIncludesClosedCases, AverageVisitsPerFamily,
					  TANFServicesEligibleAtEnrollment, rowBlankforItem9, LengthInProgramUnder6Months,
					  LengthInProgramUnder6MonthsTo1Year, LengthInProgramUnder1YearTo2Year,
					  LengthInProgramUnder2YearsAndOver) ) unpvtCol2

-- column3
;
		with	cteCol3
				  as (select	*
					  from		#tblQ8ReportMain as Q8Report
					  where		Q8Report.QuarterNumber = 3
					 )
			insert	into @tblcol3
					select	field
						  , value
					from	cteCol3 as col3 unpivot 
( value for field in (QuarterEndDate, numberOfScreens, numberOfKempAssessments, KempPositivePercentage,
					  KempPositiveEnrolled, KempPositivePending, KempPositiveTerminated, AvgPositiveMotherScore,
					  EnrolledAtBeginningOfQrtr, NewEnrollmentsThisQuarter, NewEnrollmentsPrenatal, TANFServicesEligible,
					  FamiliesDischargedThisQuarter, FamiliesCompletingProgramThisQuarter,
					  FamiliesActiveAtEndOfThisQuarter, FamiliesActiveAtEndOfThisQuarterOnLevel1,
					  FamiliesActiveAtEndOfThisQuarterOnLevelX, FamiliesWithNoServiceReferrals,
					  AverageVisitsPerMonthPerCase, TotalServedInQuarterIncludesClosedCases, AverageVisitsPerFamily,
					  TANFServicesEligibleAtEnrollment, rowBlankforItem9, LengthInProgramUnder6Months,
					  LengthInProgramUnder6MonthsTo1Year, LengthInProgramUnder1YearTo2Year,
					  LengthInProgramUnder2YearsAndOver) ) unpvtCol3

-- column4
;
		with	cteCol4
				  as (select	*
					  from		#tblQ8ReportMain as Q8Report
					  where		Q8Report.QuarterNumber = 4
					 )
			insert	into @tblcol4
					select	field
						  , value
					from	cteCol4 as col4 unpivot 
( value for field in (QuarterEndDate, numberOfScreens, numberOfKempAssessments, KempPositivePercentage,
					  KempPositiveEnrolled, KempPositivePending, KempPositiveTerminated, AvgPositiveMotherScore,
					  EnrolledAtBeginningOfQrtr, NewEnrollmentsThisQuarter, NewEnrollmentsPrenatal, TANFServicesEligible,
					  FamiliesDischargedThisQuarter, FamiliesCompletingProgramThisQuarter,
					  FamiliesActiveAtEndOfThisQuarter, FamiliesActiveAtEndOfThisQuarterOnLevel1,
					  FamiliesActiveAtEndOfThisQuarterOnLevelX, FamiliesWithNoServiceReferrals,
					  AverageVisitsPerMonthPerCase, TotalServedInQuarterIncludesClosedCases, AverageVisitsPerFamily,
					  TANFServicesEligibleAtEnrollment, rowBlankforItem9, LengthInProgramUnder6Months,
					  LengthInProgramUnder6MonthsTo1Year, LengthInProgramUnder1YearTo2Year,
					  LengthInProgramUnder2YearsAndOver) ) unpvtCol4

-- column5
;
		with	cteCol5
				  as (select	*
					  from		#tblQ8ReportMain as Q8Report
					  where		Q8Report.QuarterNumber = 5
					 )
			insert	into @tblcol5
					select	field
						  , value
					from	cteCol5 as col5 unpivot 
( value for field in (QuarterEndDate, numberOfScreens, numberOfKempAssessments, KempPositivePercentage,
					  KempPositiveEnrolled, KempPositivePending, KempPositiveTerminated, AvgPositiveMotherScore,
					  EnrolledAtBeginningOfQrtr, NewEnrollmentsThisQuarter, NewEnrollmentsPrenatal, TANFServicesEligible,
					  FamiliesDischargedThisQuarter, FamiliesCompletingProgramThisQuarter,
					  FamiliesActiveAtEndOfThisQuarter, FamiliesActiveAtEndOfThisQuarterOnLevel1,
					  FamiliesActiveAtEndOfThisQuarterOnLevelX, FamiliesWithNoServiceReferrals,
					  AverageVisitsPerMonthPerCase, TotalServedInQuarterIncludesClosedCases, AverageVisitsPerFamily,
					  TANFServicesEligibleAtEnrollment, rowBlankforItem9, LengthInProgramUnder6Months,
					  LengthInProgramUnder6MonthsTo1Year, LengthInProgramUnder1YearTo2Year,
					  LengthInProgramUnder2YearsAndOver) ) unpvtCol5

-- column6
;
		with	cteCol6
				  as (select	*
					  from		#tblQ8ReportMain as Q8Report
					  where		Q8Report.QuarterNumber = 6
					 )
			insert	into @tblcol6
					select	field
						  , value
					from	cteCol6 as col6 unpivot 
( value for field in (QuarterEndDate, numberOfScreens, numberOfKempAssessments, KempPositivePercentage,
					  KempPositiveEnrolled, KempPositivePending, KempPositiveTerminated, AvgPositiveMotherScore,
					  EnrolledAtBeginningOfQrtr, NewEnrollmentsThisQuarter, NewEnrollmentsPrenatal, TANFServicesEligible,
					  FamiliesDischargedThisQuarter, FamiliesCompletingProgramThisQuarter,
					  FamiliesActiveAtEndOfThisQuarter, FamiliesActiveAtEndOfThisQuarterOnLevel1,
					  FamiliesActiveAtEndOfThisQuarterOnLevelX, FamiliesWithNoServiceReferrals,
					  AverageVisitsPerMonthPerCase, TotalServedInQuarterIncludesClosedCases, AverageVisitsPerFamily,
					  TANFServicesEligibleAtEnrollment, rowBlankforItem9, LengthInProgramUnder6Months,
					  LengthInProgramUnder6MonthsTo1Year, LengthInProgramUnder1YearTo2Year,
					  LengthInProgramUnder2YearsAndOver) ) unpvtCol6

-- column7
;
		with	cteCol7
				  as (select	*
					  from		#tblQ8ReportMain as Q8Report
					  where		Q8Report.QuarterNumber = 7
					 )
			insert	into @tblcol7
					select	field
						  , value
					from	cteCol7 as col7 unpivot 



( value for field in (QuarterEndDate, numberOfScreens, numberOfKempAssessments, KempPositivePercentage,
					  KempPositiveEnrolled, KempPositivePending, KempPositiveTerminated, AvgPositiveMotherScore,
					  EnrolledAtBeginningOfQrtr, NewEnrollmentsThisQuarter, NewEnrollmentsPrenatal, TANFServicesEligible,
					  FamiliesDischargedThisQuarter, FamiliesCompletingProgramThisQuarter,
					  FamiliesActiveAtEndOfThisQuarter, FamiliesActiveAtEndOfThisQuarterOnLevel1,
					  FamiliesActiveAtEndOfThisQuarterOnLevelX, FamiliesWithNoServiceReferrals,
					  AverageVisitsPerMonthPerCase, TotalServedInQuarterIncludesClosedCases, AverageVisitsPerFamily,
					  TANFServicesEligibleAtEnrollment, rowBlankforItem9, LengthInProgramUnder6Months,
					  LengthInProgramUnder6MonthsTo1Year, LengthInProgramUnder1YearTo2Year,
					  LengthInProgramUnder2YearsAndOver) ) unpvtCol7

-- column8
;
		with	cteCol8
				  as (select	*
					  from		#tblQ8ReportMain as Q8Report
					  where		Q8Report.QuarterNumber = 8
					 )
			insert	into @tblcol8
					select	field
						  , value
					from	cteCol8 as col8 unpivot 
( value for field in (QuarterEndDate, numberOfScreens, numberOfKempAssessments, KempPositivePercentage,
					  KempPositiveEnrolled, KempPositivePending, KempPositiveTerminated, AvgPositiveMotherScore,
					  EnrolledAtBeginningOfQrtr, NewEnrollmentsThisQuarter, NewEnrollmentsPrenatal, TANFServicesEligible,
					  FamiliesDischargedThisQuarter, FamiliesCompletingProgramThisQuarter,
					  FamiliesActiveAtEndOfThisQuarter, FamiliesActiveAtEndOfThisQuarterOnLevel1,
					  FamiliesActiveAtEndOfThisQuarterOnLevelX, FamiliesWithNoServiceReferrals,
					  AverageVisitsPerMonthPerCase, TotalServedInQuarterIncludesClosedCases, AverageVisitsPerFamily,
					  TANFServicesEligibleAtEnrollment, rowBlankforItem9, LengthInProgramUnder6Months,
					  LengthInProgramUnder6MonthsTo1Year, LengthInProgramUnder1YearTo2Year,
					  LengthInProgramUnder2YearsAndOver) ) unpvtCol8



-- Now get the desired output ... Khalsa
-- get all the columns and put them together now
		select	Q8LeftNavText
			  , c1.Q8Col1
			  , c2.Q8Col2
			  , c3.Q8Col3
			  , c4.Q8Col4
			  , c5.Q8Col5
			  , c6.Q8Col6
			  , c7.Q8Col7
			  , c8.Q8Col8
		from	@tblcol99 c99
		inner join @tblcol1 c1 on c1.Q8Columns = c99.Q8Columns
		inner join @tblcol2 c2 on c2.Q8Columns = c99.Q8Columns
		inner join @tblcol3 c3 on c3.Q8Columns = c99.Q8Columns
		inner join @tblcol4 c4 on c4.Q8Columns = c99.Q8Columns
		inner join @tblcol5 c5 on c5.Q8Columns = c99.Q8Columns
		inner join @tblcol6 c6 on c6.Q8Columns = c99.Q8Columns
		inner join @tblcol7 c7 on c7.Q8Columns = c99.Q8Columns
		inner join @tblcol8 c8 on c8.Q8Columns = c99.Q8Columns


		drop table #tblQ8ReportMain
		drop table #tblMake8Quarter
		drop table #tblInitial_cohort
-- exec [rspProgramInformationFor8Quarters] '5','06/30/2012'
	end
GO
