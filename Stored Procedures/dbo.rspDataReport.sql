SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <Febu. 11, 2013>
-- Description:	<This report gets you 'A. Data report '>
-- rspDataReport 22, '03/01/2013', '05/31/2013'		

-- Fix: Pre-Intake Enroll completed 03/27/13
-- Added ability to run report for all the HFNY Programs  02/20/2014

-- exec [rspDataReport] ',8,','10/01/2013' , '12/31/2013'
-- exec [rspDataReport] ',16,','09/01/2013' , '5/31/2014'
-- =============================================

CREATE procedure [dbo].[rspDataReport] (@ProgramFKs varchar(max) = null
							 , @StartDate datetime
							 , @EndDate datetime

							  )
as
	begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
		set nocount on;
	
		if @ProgramFKs is null
			begin
				select	@ProgramFKs = substring((select	',' + ltrim(rtrim(str(HVProgramPK)))
												 from	HVProgram
												for
												 xml path('')
												), 2, 8000)
			end

		set @ProgramFKs = replace(@ProgramFKs, '"', '')	
	


	-- main report
		declare	@tbl4DataReport table (ReportTitle [varchar](500)
									 , Total [varchar](10)
									  )


-- SCREEN------1 @ BEGINNING OF MONTH

		declare	@tbl4DataReportRow1 table (HVCasePK int)

		insert	into @tbl4DataReportRow1
				(HVCasePK

				)
				select	h.HVCasePK
				from	HVCase h
				inner join CaseProgram cp on cp.HVCaseFK = h.HVCasePK
				inner join dbo.SplitString(@ProgramFKs, ',') on cp.ProgramFK = ListItem
				inner join HVScreen h1 on h1.HVCaseFK = cp.HVCaseFK
										  and h1.ProgramFK = cp.ProgramFK
				where	h1.ScreenDate < @StartDate
						and (h.KempeDate >= @StartDate
							 or h.KempeDate is null
							)
						and (cp.DischargeDate >= @StartDate
							 or cp.DischargeDate is null
							)

		declare	@nposScreens int 
		set @nposScreens = (select	count(HVCasePK)
							from	@tbl4DataReportRow1
						   )


	-- Start of SCREEN-----2 @ NEW DURING MONTH  ----------
		declare	@tbl4DataReportRow2 table (HVCasePK int
										 , ReferralMade [varchar](1)
										 , ScreenResult [varchar](1)
										  )

		insert	into @tbl4DataReportRow2
				(HVCasePK
			   , ReferralMade
			   , ScreenResult
				)
				select	h.HVCasePK
					  , h1.ReferralMade
					  , h1.ScreenResult
				from	HVCase h
				inner join CaseProgram cp on cp.HVCaseFK = h.HVCasePK
				inner join dbo.SplitString(@ProgramFKs, ',') on cp.ProgramFK = ListItem
				inner join HVScreen h1 on h1.HVCaseFK = h.HVCasePK
										  and h1.ProgramFK = cp.ProgramFK
				where	h1.ScreenDate >= @StartDate
						and h1.ScreenDate <= @EndDate
	--AND cp.ProgramFK = @ProgramFKs
	
	
		declare	@n2a int 
		set @n2a = (select	count(HVCasePK)
					from	@tbl4DataReportRow2
					where	ReferralMade = '1'
				   )
	

	-- Start-----3 @ Kempes this month  ----------
		declare	@tbl4DataReportRow3 table (HVCasePK int
										 , KempeResult bit
										 , CaseStatus [varchar](2)
										  )

		insert	into @tbl4DataReportRow3
				(HVCasePK
			   , KempeResult
			   , CaseStatus
				)
				select	h.HVCasePK
					  , p.KempeResult
					  , p.CaseStatus
				from	HVCase h
				inner join CaseProgram cp on cp.HVCaseFK = h.HVCasePK
				inner join dbo.SplitString(@ProgramFKs, ',') on cp.ProgramFK = ListItem
				inner join Preassessment p on p.HVCaseFK = h.HVCasePK
											  and p.ProgramFK = cp.ProgramFK
				left join Kempe k on k.HVCaseFK = h.HVCasePK
				where	h.KempeDate between @StartDate and @EndDate  -- k.KempeDate between @StartDate and @EndDate
						and p.KempeResult is not null
						and cp.CaseStartDate <= @EndDate
						and p.CaseStatus in ('02', '04')	

-- k.KempeDate between @StartDate and @EndDate

	-- Old code for your fyi
	--INSERT INTO @tbl4DataReportRow3
	--(
	--	HVCasePK,
	--	KempeResult,
	--	CaseStatus
	--)
	--SELECT h.HVCasePK,p.KempeResult, p.CaseStatus FROM HVCase h
	--INNER JOIN CaseProgram cp ON cp.HVCaseFK = h.HVCasePK
	--inner join dbo.SplitString(@ProgramFKs,',') on cp.programfk = listitem
	--INNER JOIN Preassessment p ON p.HVCaseFK = h.HVCasePK AND p.ProgramFK = cp.ProgramFK
	--WHERE p.KempeDate >= @StartDate AND p.KempeDate <= @EndDate
	--AND cp.ProgramFK = @ProgramFKs
	--AND p.CaseStatus IN ('02','04')
	
		declare	@n3 int 
		set @n3 = (select	count(HVCasePK)
				   from		@tbl4DataReportRow3
				  )
	
		declare	@n3a int 
		set @n3a = (select	count(HVCasePK)
					from	@tbl4DataReportRow3
					where	CaseStatus = '02'
							and KempeResult = 1
				   )


	-- Start -----4 @ Screens Terminated this month  ----------
	
		declare	@tbl4DataReportRow4 table (HVCasePK int)

		insert	into @tbl4DataReportRow4
				(HVCasePK
				)
				select	h.HVCasePK
				from	HVCase h
				inner join CaseProgram cp on cp.HVCaseFK = h.HVCasePK
				inner join dbo.SplitString(@ProgramFKs, ',') on cp.ProgramFK = ListItem
				inner join Preassessment p on p.HVCaseFK = h.HVCasePK
											  and p.ProgramFK = cp.ProgramFK
				where	p.PADate >= @StartDate
						and p.PADate <= @EndDate
	--AND cp.ProgramFK = @ProgramFKs
						and p.CaseStatus = '03'	

		declare	@n4 int 
		set @n4 = (select	count(HVCasePK)
				   from		@tbl4DataReportRow4
				  )


	-- Start -----PRE-INTAKE-------6 @ BEGINNING OF MONTH  ----------
		declare	@tbl4DataReportRow6 table (HVCasePK int)

		insert	into @tbl4DataReportRow6
				(HVCasePK
				)
				select distinct
						h.HVCasePK
				from	HVCase h
				inner join CaseProgram cp on cp.HVCaseFK = h.HVCasePK
				inner join dbo.SplitString(@ProgramFKs, ',') on cp.ProgramFK = ListItem
				inner join Preassessment p on p.HVCaseFK = h.HVCasePK
											  and p.ProgramFK = cp.ProgramFK
				where	p.PADate < @StartDate
						and p.CaseStatus = '02'
						and KempeResult = 1
						and (h.IntakeDate >= @StartDate
							 or h.IntakeDate is null
							)
						and cp.CaseStartDate < @EndDate  -- handling transfer cases
						and (cp.DischargeDate >= @StartDate
							 or cp.DischargeDate is null
							)	

		declare	@n6 int 
		set @n6 = (select	count(HVCasePK)
				   from		@tbl4DataReportRow6
				  )	
	
	
	---- Start -----PRE-INTAKE-------8 TERM DURING MONTH	
		declare	@tbl4DataReportRow8 table (HVCasePK int)

		insert	into @tbl4DataReportRow8
				(HVCasePK
				)
				select	h.HVCasePK
				from	HVCase h
				inner join CaseProgram cp on cp.HVCaseFK = h.HVCasePK
				inner join dbo.SplitString(@ProgramFKs, ',') on cp.ProgramFK = ListItem
				inner join Preintake pre ON pre.HVCaseFK = h.HVCasePK
				where	pre.CaseStatus = '03'
						and pre.PIDate between @StartDate and @EndDate
						and cp.CaseStartDate < @EndDate  -- handling transfer cases	
						and (cp.DischargeDate >= @StartDate
							 and cp.DischargeDate <= @EndDate
							 and cp.DischargeDate is not null
							)

		declare	@n8 int 
		set @n8 = (select	count(HVCasePK)
				   from		@tbl4DataReportRow8
				  )		
	
	---- Start -----PRE-INTAKE------9 ENROLLED DURING MONTH
		declare	@tbl4DataReportRow9 table (HVCasePK int)

		insert	into @tbl4DataReportRow9
				(HVCasePK
				)
				select	h.HVCasePK
				from	HVCase h
				inner join CaseProgram cp on cp.HVCaseFK = h.HVCasePK
				inner join dbo.SplitString(@ProgramFKs, ',') on cp.ProgramFK = ListItem
				where	--cp.ProgramFK = @ProgramFKs
	--AND 
						(h.IntakeDate >= @StartDate
						 and h.IntakeDate <= @EndDate
						)
						and cp.CaseStartDate < @EndDate  -- handling transfer cases
	

		declare	@n9 int 
		set @n9 = (select	count(HVCasePK)
				   from		@tbl4DataReportRow9
				  )		
	
	
	---- Start -----Active Families-------11 at beginning
		declare	@tbl4DataReportRow11 table (HVCasePK int)

		insert	into @tbl4DataReportRow11
				(HVCasePK
				)
				select	h.HVCasePK
				from	HVCase h
				inner join CaseProgram cp on cp.HVCaseFK = h.HVCasePK
				inner join dbo.SplitString(@ProgramFKs, ',') on cp.ProgramFK = ListItem
				where	--cp.ProgramFK = @ProgramFKs
	--AND 
						h.IntakeDate < @StartDate
						and h.IntakeDate is not null
						and cp.CaseStartDate < @EndDate  -- handling transfer cases
						and (cp.DischargeDate >= @StartDate
							 or cp.DischargeDate is null
							)
	

		declare	@n11 int 
		set @n11 = (select	count(HVCasePK)
					from	@tbl4DataReportRow11
				   )	

-- rspDataReport 5, '06/01/2012', '09/30/2012'		

	---- Start -----Active  Families--------12a/b enrolled this month
		declare	@tbl4DataReportRow12 table (HVCasePK int
										  , Prenatal int
										  , Postnatal int
										  , ProgramFK int
										   )

		insert	into @tbl4DataReportRow12
				(HVCasePK
			   , Prenatal
			   , Postnatal
			   , ProgramFK
				)
				select	h.HVCasePK
					  , case when ((h.TCDOB is not null
									and h.TCDOB > h.IntakeDate
								   )
								   or (h.TCDOB is null
									   and h.EDC > h.IntakeDate
									  )
								  ) then 1
							 else 0
						end as Prenatal
					  , case when (h.TCDOB is not null
								   and h.TCDOB <= h.IntakeDate
								  ) then 1
							 else 0
						end as Postnatal
					  , cp.ProgramFK
				from	HVCase h
				inner join CaseProgram cp on cp.HVCaseFK = h.HVCasePK
				inner join dbo.SplitString(@ProgramFKs, ',') on cp.ProgramFK = ListItem
				where	--   cp.ProgramFK = @ProgramFKs
	--AND 
						h.IntakeDate >= @StartDate
						and h.IntakeDate <= @EndDate
						and cp.CaseStartDate < @EndDate  -- handling transfer cases
	

	

		declare	@n12 int 
		set @n12 = (select	count(HVCasePK) as count1
					from	@tbl4DataReportRow12
				   )	

		declare	@n12a int 
		set @n12a = (select	sum(Prenatal) as Prenatal
					 from	@tbl4DataReportRow12
					)	
		declare	@n12b int 
		set @n12b = (select	sum(Postnatal) as Postnatal
					 from	@tbl4DataReportRow12
					)	



	---- Start -----Active Families--------13
		declare	@tbl4DataReportRow13 table (HVCasePK int)

		insert	into @tbl4DataReportRow13
				(HVCasePK
				)
				select	h.HVCasePK
				from	HVCase h
				inner join CaseProgram cp on cp.HVCaseFK = h.HVCasePK
				inner join dbo.SplitString(@ProgramFKs, ',') on cp.ProgramFK = ListItem
				where	--cp.ProgramFK = @ProgramFKs
	--and
						cp.DischargeDate >= @StartDate
						and cp.DischargeDate <= @EndDate
						and h.IntakeDate is not null
						and cp.CaseStartDate < @EndDate  -- handling transfer cases
	

		declare	@n13 int 
		set @n13 = (select	count(HVCasePK)
					from	@tbl4DataReportRow13
				   )	


	------ Start -----Active Families-----14 at end of month
		declare	@tbl4DataReportRow14 table (HVCasePK int
										  , IntakePK int
										  , ProgramFK int
										  , PBTANF [char](1)
										  , CurrentLevelFK int
										   )

		insert	into @tbl4DataReportRow14
				(HVCasePK
			   , IntakePK
			   , ProgramFK
			   , PBTANF
			   , CurrentLevelFK
		
				)
				select	HVCasePK
					  , IntakePK
					  , cp.ProgramFK
					  , PBTANF
					  , CurrentLevelFK
				from	HVCase h
				inner join CaseProgram cp on cp.HVCaseFK = h.HVCasePK
				inner join dbo.SplitString(@ProgramFKs, ',') on cp.ProgramFK = ListItem
				left join Intake i on i.HVCaseFK = h.HVCasePK
				left join CommonAttributes ca on ca.FormFK = i.IntakePK
												 and ca.FormType = 'IN'  -- to get PBTANF, item 26 on the intake form
				where	--cp.ProgramFK = @ProgramFKs
	--AND 
						((h.IntakeDate is not null
						  and h.IntakeDate <= @EndDate
						 )
						 and (cp.DischargeDate is null
							  or cp.DischargeDate > @EndDate
							 )
						 and cp.CaseStartDate < @EndDate  -- handling transfer cases	
						 )
						or (CurrentLevelFK = 8
							and h.IntakeDate between @StartDate and @EndDate
						   )



		declare	@n14a int 
		set @n14a = (select	sum(case when PBTANF = '1' then 1
									 else 0
								end) as PBTANF
					 from	@tbl4DataReportRow14
					)	

		declare	@n14a1 int 
		set @n14a1 = (select	sum(case when IntakePK is not null then 1
										 else 0
									end) as totalIntakesCompleted
					  from		@tbl4DataReportRow14
					 )	

	------ Start -----Active Families---figure out levels 
	
		declare	@tbl4DataReportRow14RestOfIt table (LevelName [char](50)
												  , levelCount int
												   );
	
		with	cteDataReportRow14RestOfIt
				  as (select	case when CurrentLevelFK = 8 then 'Preintake-enroll'
									 else LevelName
								end as LevelName
							  , case when HVLevelPK is not null
										  or CurrentLevelFK = 8 then 1
									 else 0
								end as levelcount
					  from		@tbl4DataReportRow14 t14
					  left join (select	HVLevel.HVLevelPK
									  , HVLevel.HVCaseFK
									  , HVLevel.ProgramFK
									  , HVLevel.LevelAssignDate
									  , LevelName
									  , CaseWeight
								 from	HVLevel
								 inner join codeLevel on codeLevelPK = LevelFK
								 inner join (select	HVCaseFK
												  , ProgramFK
												  , max(LevelAssignDate) as levelassigndate
											 from	HVLevel h2
											 where	LevelAssignDate <= @EndDate
											 group by HVCaseFK
												  , ProgramFK
											) e2 on e2.HVCaseFK = HVLevel.HVCaseFK
													and e2.ProgramFK = HVLevel.ProgramFK
													and e2.levelassigndate = HVLevel.LevelAssignDate
								) e3 on e3.HVCaseFK = t14.HVCasePK
										and e3.ProgramFK = t14.ProgramFK
					 )
			insert	into @tbl4DataReportRow14RestOfIt
					(LevelName
				   , levelCount
					)
					select	lr.LevelName
						  , case when levelcount is not null then 1
								 else 0
							end as levelCount
					from	cteDataReportRow14RestOfIt t14Rest
					right join (select	[LevelName]
								from	[codeLevel]
								where	((LevelName like 'level%'
										  and Enrolled = 1
										  and LevelGroup <> 'SUB'
										 )
										 or LevelName like 'Preintake-enroll'
										)
							   ) lr on lr.LevelName = t14Rest.LevelName  -- add missing levelnames
					order by LevelName 
	
		declare	@n14b int 
		set @n14b = (select	sum(case when levelCount is not null then 1
									 else 0
								end) as tlevelCount
					 from	@tbl4DataReportRow14RestOfIt
					 where	LevelName = 'Preintake-enroll'
					)	
		if @n14b is null
			begin
				set @n14b = 0
			end 


		declare	@n14c int 
		set @n14c = (select	sum(levelCount) as tlevelCount
					 from	@tbl4DataReportRow14RestOfIt
					 where	LevelName = 'Level 1-Prenatal'
					)	
		declare	@n14d int 
		set @n14d = (select	sum(levelCount) as tlevelCount
					 from	@tbl4DataReportRow14RestOfIt
					 where	LevelName = 'Level 1-SS'
					)	
		declare	@n14e int 
		set @n14e = (select	sum(levelCount) as tlevelCount
					 from	@tbl4DataReportRow14RestOfIt
					 where	LevelName = 'Level 1'
					)	
		declare	@n14f int 
		set @n14f = (select	sum(levelCount) as tlevelCount
					 from	@tbl4DataReportRow14RestOfIt
					 where	LevelName = 'Level 2'
					)	
		declare	@n14g int 
		set @n14g = (select	sum(levelCount) as tlevelCount
					 from	@tbl4DataReportRow14RestOfIt
					 where	LevelName = 'Level 3'
					)	
		declare	@n14h int 
		set @n14h = (select	sum(levelCount) as tlevelCount
					 from	@tbl4DataReportRow14RestOfIt
					 where	LevelName = 'Level 4'
					)	
		declare	@n14i int 
		set @n14i = (select	sum(levelCount) as tlevelCount
					 from	@tbl4DataReportRow14RestOfIt
					 where	LevelName = 'Level X'
					)	

	



--SELECT * FROM  @tbl4DataReportRow14RestOfIt
-- rspDataReport 2, '02/01/2013', '02/28/2013'			

		insert	into @tbl4DataReport
				(ReportTitle
			   , Total
				)
		values	('SCREEN (PRE-ASSESSMENT) AND ASSESSMENT SUMMARY'
			   , ''
				)
	
		insert	into @tbl4DataReport
				(ReportTitle
			   , Total
				)
		values	('1.  Positive Screens Pending Assessment at Beginning of this Period'
			   , @nposScreens
				)



		insert	into @tbl4DataReport
				(ReportTitle
			   , Total
				)
		values	('2.  New Screens this Period'
			   , (select	count(HVCasePK)
				  from		@tbl4DataReportRow2
				 )
				)

		insert	into @tbl4DataReport
				(ReportTitle
			   , Total
				)
		values	('    2a. Positive Screens Referred for Assessment'
			   , @n2a
				)
		insert	into @tbl4DataReport
				(ReportTitle
			   , Total
				)
		values	('    2b. Positive Screens Not Referred for Assessment'
			   , (select	count(HVCasePK)
				  from		@tbl4DataReportRow2
				  where		ReferralMade = '0'
							and ScreenResult = '1'
				 )
				)
		insert	into @tbl4DataReport
				(ReportTitle
			   , Total
				)
		values	('    2c. Negative Screens'
			   , (select	count(HVCasePK)
				  from		@tbl4DataReportRow2
				  where		ScreenResult = '0'
				 )
				)

		insert	into @tbl4DataReport
				(ReportTitle
			   , Total
				)
		values	('3.  Kempe Assessments this Period'
			   , @n3
				)
		insert	into @tbl4DataReport
				(ReportTitle
			   , Total
				)
		values	('    3a. Positive Kempe Assigned ( or Pending Assignment) to FSW'
			   , @n3a
				)
		insert	into @tbl4DataReport
				(ReportTitle
			   , Total
				)
		values	('    3b. Positive Kempe Assessments Not Assigned to FSW - Terminated'
			   , (select	count(HVCasePK)
				  from		@tbl4DataReportRow3
				  where		CaseStatus = '04'
				 )
				)
		insert	into @tbl4DataReport
				(ReportTitle
			   , Total
				)
		values	('    3c. Negative Kempe Assessment'
			   , (select	count(HVCasePK)
				  from		@tbl4DataReportRow3
				  where		CaseStatus = '02'
							and KempeResult = 0
				 )
				)


		insert	into @tbl4DataReport
				(ReportTitle
			   , Total
				)
		values	('4.  Screens Terminated on Pre-Assessment Form this Period'
			   , @n4
				)

		insert	into @tbl4DataReport
				(ReportTitle
			   , Total
				)
		values	('5.  Screens Pending Assessment at End of this Period ([(1+2a) - (3+4)])'
			   , (@nposScreens + @n2a) - (@n3 + @n4)
				)


		insert	into @tbl4DataReport
				(ReportTitle, Total)
		values	('', '')
		insert	into @tbl4DataReport
				(ReportTitle
			   , Total
				)
		values	('PRE-INTAKE (POST-ASSESSMENT) SUMMARY'
			   , ''
				)



		insert	into @tbl4DataReport
				(ReportTitle
			   , Total
				)
		values	('6.  Pre-Intake Families at Beginning of this Period (Participants Pending Enrollment at Beginning of this Period)'
			   , @n6
				)

		insert	into @tbl4DataReport
				(ReportTitle
			   , Total
				)
		values	('7.  New Pre-Intake Families this Period (Same as 3a above)'
			   , @n3a
				)

		insert	into @tbl4DataReport
				(ReportTitle
			   , Total
				)
		values	('8.  Families Terminated on Pre-Intake Form this Period'
			   , @n8
				)

		insert	into @tbl4DataReport
				(ReportTitle
			   , Total
				)
		values	('9.  Families Enrolled on Pre-Intake Form this Period'
			   , @n9
				)

		insert	into @tbl4DataReport
				(ReportTitle
			   , Total
				)
		values	('10.  Pre-Intake Families at the End of this Period ([(6+7) - (8+9)])'
			   , (@n6 + @n3a) - (@n8 + @n9)
				)

		insert	into @tbl4DataReport
				(ReportTitle, Total)
		values	('', '')
		insert	into @tbl4DataReport
				(ReportTitle, Total)
		values	('ENROLLED FAMILIES', '')


-- Enrolled Families
		insert	into @tbl4DataReport
				(ReportTitle
			   , Total
				)
		values	('11.  Enrolled Families at the Beginning of this Period'
			   , @n11
				)

		insert	into @tbl4DataReport
				(ReportTitle
			   , Total
				)
		values	('12.  Families Enrolled this Period'
			   , @n12
				)
		insert	into @tbl4DataReport
				(ReportTitle
			   , Total
				)
		values	('    12a. Prenatal at Enrollment*'
			   , @n12a
				)
		insert	into @tbl4DataReport
				(ReportTitle
			   , Total
				)
		values	('    12b. Postnatal at Enrollment*'
			   , @n12b
				)

		insert	into @tbl4DataReport
				(ReportTitle
			   , Total
				)
		values	('13. Enrolled Families Discharged this Period'
			   , @n13
				)

		insert	into @tbl4DataReport
				(ReportTitle
			   , Total
				)
		values	('14.  Enrolled Families at the End of this Period ([(11+12) - 13])'
			   , (@n11 + @n12) - @n13
				)

		insert	into @tbl4DataReport
				(ReportTitle
			   , Total
				)
		values	('     a. Receiving TANF at Enrollment (Item 26 on the Intake Form)'
			   , @n14a
				)
		insert	into @tbl4DataReport
				(ReportTitle
			   , Total
				)
		values	('       a1. Active Families with Intake Form Completed'
			   , @n14a1
				)

		insert	into @tbl4DataReport
				(ReportTitle
			   , Total
				)
		values	('       b. Pre-Intake Enroll'
			   , @n14b
				)

		insert	into @tbl4DataReport
				(ReportTitle
			   , Total
				)
		values	('       c. Level 1-Prenatal'
			   , @n14c
				)
		insert	into @tbl4DataReport
				(ReportTitle, Total)
		values	('       d. Level 1-SS', @n14d)
		insert	into @tbl4DataReport
				(ReportTitle, Total)
		values	('       e. Level 1', @n14e)
		insert	into @tbl4DataReport
				(ReportTitle, Total)
		values	('       f. Level 2', @n14f)
		insert	into @tbl4DataReport
				(ReportTitle, Total)
		values	('       g. Level 3', @n14g)
		insert	into @tbl4DataReport
				(ReportTitle, Total)
		values	('       h. Level 4', @n14h)
		insert	into @tbl4DataReport
				(ReportTitle, Total)
		values	('       i. Level X', @n14i)

		insert	into @tbl4DataReport
				(ReportTitle
			   , Total
				)
		values	('15.  Pre-Intake and Enrolled Families at the End of this Period (10+14)'
			   , (@n6 + @n3a) - (@n8 + @n9) + (@n11 + @n12) - @n13
				)


-- rspDataReport 5, '06/01/2012', '09/30/2012'			


		select	*
		from	@tbl4DataReport	
	



	


	end
GO
