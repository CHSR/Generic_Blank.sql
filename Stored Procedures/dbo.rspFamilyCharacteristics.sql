SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Stored Procedure

-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <August 2nd, 2012>
-- Description:	<gets you data for Family Characteristics Quarterly and Contract Period>
-- exec [rspFamilyCharacteristics] ',1,','04/01/2016','11/30/2016',null,0
-- exec [rspFamilyCharacteristics] ',1,','09/01/2010','11/30/2010',null,1
-- exec rspFamilyCharacteristics '31','10/01/12','12/31/12',NULL,NULL
-- =============================================
CREATE procedure [dbo].[rspFamilyCharacteristics]
	  (
	   @ProgramFK varchar(max) = null
	 , @StartDate datetime
	 , @EndDate datetime
	 , @SiteFK int = null
	 , @CustomQuarterlyDates bit
	 , @IncludeClosedCases bit = 0
	 , @CaseFiltersPositive varchar(100) = ''
	  )
as
	  begin

	-- if user picks up custom dates ( not specific quarter dates) then Don't show ContractPeriod Column
	--DECLARE @bDontShowContractPeriod BIT
	-- we will be receiving the value of @bDontShowContractPeriod from UI. 
	-- so time being, let us do the following
	--SET @bDontShowContractPeriod = 0

			declare	@ContractStartDate date
			declare	@ContractEndDate date

			if ((@ProgramFK is not null)
				and (@CustomQuarterlyDates = 0)
			   )
			   begin
					 set @ProgramFK = replace(@ProgramFK,
											',', '') -- remove comma's
					 set @ContractStartDate = (select
											ContractStartDate
											from
											HVProgram P
											where
											HVProgramPK = @ProgramFK
											)
					 set @ContractEndDate = (select
											ContractEndDate
											from
											HVProgram P
											where
											HVProgramPK = @ProgramFK
											)
			   end

	--SELECT @ContractStartDate, @ContractEndDate

	-- Let us declare few table variables so that we can manipulate the rows at our will
	-- Note: Table variables are a superior alternative to using temporary tables 

	---------------------------------------------
	-- Initially, get the subset of data that we are interested in ... Good Practice ... Khalsa 
	-- table variable for holding Init Required Data
			declare	@tblInitRequiredData table
					(
					 [HVCasePK] [int]
				   , [IntakeDate] [datetime]
				   , [TCDOB] [datetime]
				   , [TCDOD] [datetime]
				   , [PCDOB] [datetime]
				   , [DischargeDate] [datetime]
				   , [LastDate] [datetime]
				   , [TCAgeDays] [int]
				   , [TCNumber] [int]
				   , [TCGender] [varchar](2)
				   , [TCRace] [varchar] (2)
				   , [PC1Relation2TC] [char](2)
				   , [PC2Relation2TC] [char](2)
				   , [OBPRelation2TC] [char](2)
				   , [PC2inHomeIntake] bit
				   , [Race] [char](2)
				   , [SiteFK] [int]
					)

			declare	@tblInitRequiredData2 table
					(
					 [HVCasePK] [int]
				   , [IntakeDate] [datetime]
				   , [TCDOB] [datetime]
				   , [TCDOD] [datetime]
				   , [PCDOB] [datetime]
				   , [DischargeDate] [datetime]
				   , [LastDate] [datetime]
				   , [TCAgeDays] [int]
				   , [TCNumber] [int]
				   , [TCGender] [varchar](2)
				   , [TCRace] [varchar] (2)
				   , [PC1Relation2TC] [char](2)
				   , [PC2Relation2TC] [char](2)
				   , [OBPRelation2TC] [char](2)
				   , [PC2inHomeIntake] bit
				   , [Race] [char](2)
				   , [SiteFK] [int]
					)

	-- for Q2
			declare	@tblTargetChildren table
					(
					 [HVCasePK] [int]
				   , [IntakeDate] [datetime]
				   , [TCDOB] [datetime]
				   , [TCDOD] [datetime]
				   , [DischargeDate] [datetime]
				   , [LastDate] [datetime]
				   , [TCAgeDays] [int]
				   , [TCNumber] [int]
				   , [TCGender] [varchar](2)
				   , [TCRace] [varchar] (2)
				   , [SiteFK] [int]
					);
			with	cteMain
					  as (select	h.HVCasePK
								  , h.IntakeDate
								  , case when h.tcdob is not null
										 then h.tcdob
										 else h.edc
									end as tcdob
								  , h.TCDOD
								  , P.PCDOB
								  , cp.DischargeDate
								  , case when DischargeDate is not null
											and DischargeDate <> ''
											and DischargeDate < @EndDate
										 then DischargeDate
										 else @EndDate
									end as lastdate
								  , [TCNumber]
								  , TC.TCGender
								  , TC.Race as TCRace
								  , [PC1Relation2TC]
								  , [PC2Relation2TC]
								  , [OBPRelation2TC]
								  , [PC2inHomeIntake]
								  , P.[Race]
								  , case when wp.SiteFK is null
										 then 0
										 else wp.SiteFK
									end as SiteFK
						  from		HVCase h
						  inner join CaseProgram cp on h.HVCasePK = cp.HVCaseFK
						  inner join dbo.SplitString(@ProgramFK,
											',') on cp.programfk = listitem
						  inner join Worker w on w.WorkerPK = cp.CurrentFSWFK
						  inner join WorkerProgram wp on wp.WorkerFK = w.WorkerPK -- get SiteFK
						  inner join PC P on P.PCPK = h.PC1FK
						  left join TCID TC on TC.HVCaseFK = h.HVCasePK
						 )
				 -- SiteFK = isnull(@sitefk,SiteFK) does not work because column SiteFK may be null itself 
	insert	into @tblInitRequiredData
			([HVCasePK]
		   , [IntakeDate]
		   , [TCDOB]
		   , [TCDOD]
		   , [PCDOB]
		   , [DischargeDate]
		   , [LastDate]
		   , [TCAgeDays]
		   , [TCNumber]
		   , [TCGender]
		   , [TCRace]
		   , [PC1Relation2TC]
		   , [PC2Relation2TC]
		   , [OBPRelation2TC]
		   , [PC2inHomeIntake]
		   , [Race]
		   , [SiteFK]
			)
			select	[HVCasePK]
				  , [IntakeDate]
				  , [TCDOB]
				  , [TCDOD]
				  , [PCDOB]
				  , [DischargeDate]
				  , [LastDate]
				  , case when DischargeDate is not null
							  and DischargeDate <> ''
							  and DischargeDate <= @EndDate
						 then datediff(day, tcdob,
									   DischargeDate)
						 else datediff(day, tcdob, @EndDate)
					end as tcAgeDays
				  , case when tcdob <= lastdate
							  and TCNumber = 0 then 1
						 when tcdob > lastdate then 0
						 else TCNumber
					end as TCNumber
				  , [TCGender]
				  , [TCRace]
				  , [PC1Relation2TC]
				  , [PC2Relation2TC]
				  , [OBPRelation2TC]
				  , [PC2inHomeIntake]
				  , [Race]
				  , [SiteFK]
			from	cteMain
			where	SiteFK = isnull(@sitefk, SiteFK)

			insert	into @tblInitRequiredData2
					([HVCasePK]
				   , [IntakeDate]
				   , [TCDOB]
				   , [TCDOD]
				   , [PCDOB]
				   , [DischargeDate]
				   , [LastDate]
				   , [TCAgeDays]
				   , [TCNumber]
				   , [TCGender]
				   , [TCRace]
				   , [PC1Relation2TC]
				   , [PC2Relation2TC]
				   , [OBPRelation2TC]
				   , [PC2inHomeIntake]
				   , [Race]
				   , [SiteFK]
					)
					select	*
					from	@tblInitRequiredData
					where	IntakeDate <= @EndDate
							and (DischargeDate is null
								 or DischargeDate >= @StartDate
								)

	---------------------------------------------
	--- **************************************** ---
	-- Part #1:Families at Intake  --- (QUARTERLY STATS)
	-- Time period is only quarterly, contact dates not involved.

			declare	@TotalNumberOfFamiliesAtIntakeQuarterly int

			set @TotalNumberOfFamiliesAtIntakeQuarterly = (select
											count(distinct HVCasePK)
											from
											@tblInitRequiredData2
											)

	-- Part #1a:prenatal families at intake

			declare	@nPrenatalQuarterly int

			set @nPrenatalQuarterly = (select
											count(distinct HVCasePK)
									   from	@tblInitRequiredData2
									   where
											TCDOB > IntakeDate
									  )

			declare	@nQC1a int

	-- 1 a prenatal currently
			set @nQC1a = (select	count(distinct HVCasePK)
						  from		@tblInitRequiredData2
						  where		TCDOB > LastDate
						 )

	--- **************************************** ---
	-- Part #2: target children  --- (QUARTERLY STATS)
	;
			with	cteFamiliesIntake
					  as (select	*
						  from		@tblInitRequiredData2
						 ) ,
					cteKidsIntake
					  as (select	[HVCasePK]
								  , [IntakeDate]
								  , [TCDOB]
								  , [TCDOD]
								  , [PCDOB]
								  , [DischargeDate]
								  , [LastDate]
								  , [TCAgeDays]
								  , case --substract out the dead tcs	
										 when tcdob > IntakeDate
										 then 0
										 when TCNumber = 0
										 then 1
										 else TCNumber
									end as Kidno2
								  , [TCGender]
								  , [TCRace]
								  , [SiteFK]
						  from		cteFamiliesIntake
						  where		IntakeDate <= @EndDate
									and (DischargeDate is null
										 or DischargeDate >= @StartDate
										)
						 ) ,
					cteDeceasedChildren
					  as (-- gets count of deceased children
						  select	count(*) ngone
								  , T.HVCaseFK
						  from		cteKidsIntake ki
						  inner join TCID T on T.HVCaseFK = ki.HVCasePK
						  where		T.TCDOD is not null
									and T.TCDOD < IntakeDate
						  group by	T.HVCaseFK
						 )
				 -- decrement number of deceased children
	insert	into @tblTargetChildren
			([HVCasePK]
		   , [IntakeDate]
		   , [TCDOB]
		   , [TCDOD]
		   , [DischargeDate]
		   , [LastDate]
		   , [TCAgeDays]
		   , [TCNumber]
		   , [TCGender]
		   , [TCRace]
		   , [SiteFK]
			 )
			select	HVCasePK
				  , IntakeDate
				  , TCDOB
				  , TCDOD
				  , DischargeDate
				  , LastDate
				  , TCAgeDays
				  , (Kidno2 - isnull(s2.ngone, 0)) as Kidno2 -- substract out the dead tcs
				  , TCGender
				  , TCRace	
				  , SiteFK
			from	cteKidsIntake ki
			left join cteDeceasedChildren s2 on s2.HVCaseFK = ki.HVCasePK

	-- Q2 --------------------------
	-- 2 target children
	-- Quarterlies
			declare	@nQ2 int
			declare	@nQ2a int
			declare	@nQ2b int
			declare	@nQ2c int
			declare	@nQ2d int
			declare	@nQ2e int
			declare	@nQ2f int
			declare	@nQ2g int

	-- 2. Total number of children
			set @nQ2 = (select sum (TCNumber)
								from @tblTargetChildren
					   )
	-- 2a. Under 3 months
			set @nQ2a = (select	sum(TCNumber)
						 from	@tblTargetChildren
						 where	(datediff(day, TCDOB,
										  IntakeDate)
								 / 30.44) < 3
						)
			set @nQ2a = isnull(@nQ2a, 0)

	-- 2b. 3 months up to 1 year
			set @nQ2b = (select	sum(TCNumber)
						 from	@tblTargetChildren
						 where	(datediff(day, TCDOB,
										  IntakeDate)
								 / 30.44) between 3
										  and
											11.99
						)
			set @nQ2b = isnull(@nQ2b, 0)

	-- 2c. 1 year up to 2 years
			set @nQ2c = (select	sum(TCNumber)
						 from	@tblTargetChildren
						 where	(datediff(day, TCDOB,
										  IntakeDate)
								 / 30.44) between 12
										  and
											23.99
						)
			set @nQ2c = isnull(@nQ2c, 0)

	-- 2d. 2 years up to 3 years
			set @nQ2d = (select	sum(TCNumber)
						 from	@tblTargetChildren
						 where	(datediff(day, TCDOB,
										  IntakeDate)
								 / 30.44) between 24
										  and
											35.99
						)
			set @nQ2d = isnull(@nQ2d, 0)

	-- 2e. 3 years up to 4 years
			set @nQ2e = (select	sum(TCNumber)
						 from	@tblTargetChildren
						 where	(datediff(day, TCDOB,
										  IntakeDate)
								 / 30.44) between 36
										  and
											47.99
						)
			set @nQ2e = isnull(@nQ2e, 0)

	-- 2f. 4 years up to 5 years
			set @nQ2f = (select	sum(TCNumber)
						 from	@tblTargetChildren
						 where	(datediff(day, TCDOB,
										  IntakeDate)
								 / 30.44) between 48
										  and
											59.99
						)
			set @nQ2f = isnull(@nQ2f, 0)

	-- 2g. Over 5 years
			set @nQ2g = (select	sum(TCNumber)
						 from	@tblTargetChildren
						 where	(datediff(day, TCDOB,
										  IntakeDate)
								 / 30.44) >= 60
						)
			set @nQ2g = isnull(@nQ2g, 0)

	-- Current info
			declare	@nQC2 int
			declare	@nQC2a int
			declare	@nQC2b int
			declare	@nQC2c int
			declare	@nQC2d int
			declare	@nQC2e int
			declare	@nQC2f int
			declare	@nQC2g int
			

			declare	@tblTargetChildrenCurrent table
					(
					 [HVCasePK] [int]
				   , [IntakeDate] [datetime]
				   , [TCDOB] [datetime]
				   , [TCDOD] [datetime]
				   , [PCDOB] [datetime]
				   , [DischargeDate] [datetime]
				   , [LastDate] [datetime]
				   , [TCAgeDays] [int]
				   , [TCNumber] [int]
				   , [TCGender] [varchar](2)
				   , [TCRace] [varchar](2)
				   , [PC1Relation2TC] [char](2)
				   , [PC2Relation2TC] [char](2)
				   , [OBPRelation2TC] [char](2)
				   , [PC2inHomeIntake] bit
				   , [Race] [char](2)
				   , [SiteFK] [int]
					)

	-- Cohort
			insert	into @tblTargetChildrenCurrent
					select	[HVCasePK]
						  , [IntakeDate]
						  , [TCDOB]
						  , [TCDOD]
						  , [PCDOB]
						  , [DischargeDate]
						  , [LastDate]
						  , [TCAgeDays]
						  , TCNumber
						  , TCGender
						  , TCRace
						  , [PC1Relation2TC]
						  , [PC2Relation2TC]
						  , [OBPRelation2TC]
						  , [PC2inHomeIntake]
						  , [Race]
						  , [SiteFK]
					from	@tblInitRequiredData2
					where	IntakeDate <= @EndDate
							and (DischargeDate is null
								 or DischargeDate >= @StartDate
								)
	-- 2. Total number of children
			set @nQC2 = (select sum (TCNumber)
								from
								@tblTargetChildrenCurrent
						)
	-- 2a. Under 3 months
			set @nQC2a = (select	sum(TCNumber)
						  from		@tblTargetChildrenCurrent
						  where		(TCAgeDays / 30.44) < 3
						 )
			set @nQC2a = isnull(@nQC2a, 0)

	-- 2b. 3 months up to 1 year
			set @nQC2b = (select	sum(TCNumber)
						  from		@tblTargetChildrenCurrent
						  where		(TCAgeDays / 30.44) between 3 and 11.99
						 )
			set @nQC2b = isnull(@nQC2b, 0)

	-- 2c. 1 year up to 2 years
			set @nQC2c = (select	sum(TCNumber)
						  from		@tblTargetChildrenCurrent
						  where		(TCAgeDays / 30.44) between 12 and 23.99
						 )
			set @nQC2c = isnull(@nQC2c, 0)

	-- 2d. 2 years up to 3 years
			set @nQC2d = (select	sum(TCNumber)
						  from		@tblTargetChildrenCurrent
						  where		(TCAgeDays / 30.44) between 24 and 35.99
						 )
			set @nQC2d = isnull(@nQC2d, 0)

	-- 2e. 3 years up to 4 years
			set @nQC2e = (select	sum(TCNumber)
						  from		@tblTargetChildrenCurrent
						  where		(TCAgeDays / 30.44) between 36 and 47.99
						 )
			set @nQC2e = isnull(@nQC2e, 0)

	-- 2f. 4 years up to 5 years
			set @nQC2f = (select	sum(TCNumber)
						  from		@tblTargetChildrenCurrent
						  where		(TCAgeDays / 30.44) between 48 and 59.99
						 )
			set @nQC2f = isnull(@nQC2f, 0)

	-- 2g. Over 5 years
			set @nQC2g = (select	sum(TCNumber)
						  from		@tblTargetChildrenCurrent
						  where		(TCAgeDays / 30.44) >= 60
						 )
			set @nQC2g = isnull(@nQC2g, 0)

	
	--2.5 TC Race
			declare @nQ25a int
			declare @nQ25b int
			declare @nQ25c int
			declare @nQ25d int
			declare @nQ25e int
			declare @nQ25f int
			declare @nQ25g int
			declare @nQ25h int
			
			set @nQ25a = isnull((select	sum(TCNumber)
						  from		@tblTargetChildren
						  where 	(TCRace = '01')
						 ), 0)
			set @nQ25b = isnull((select	sum(TCNumber)
						  from		@tblTargetChildren
						  where 	(TCRace = '02')
						 ), 0)
			set @nQ25c = isnull((select	sum(TCNumber)
						  from		@tblTargetChildren
						  where 	(TCRace = '03')
						 ), 0)
			set @nQ25d = isnull((select	sum(TCNumber)
						  from		@tblTargetChildren
						  where 	(TCRace = '04')
						 ), 0)
			set @nQ25e = isnull((select	sum(TCNumber)
						  from		@tblTargetChildren
						  where 	(TCRace = '05')
						 ), 0)
			set @nQ25f = isnull((select	sum(TCNumber)
						  from		@tblTargetChildren
						  where 	(TCRace = '06')
						 ), 0)
			set @nQ25g = isnull((select	sum(TCNumber)
						  from		@tblTargetChildren
						  where 	(TCRace = '07')
						 ), 0)
			set @nQ25h = isnull((select sum(TCNumber) 
						  from		@tblTargetChildren
						  where		(TCRace is null or TCRace = '' or TCRace = ' ')
						  ), 0)

	--Current
			declare @nQC25a int
			declare @nQC25b int
			declare @nQC25c int
			declare @nQC25d int
			declare @nQC25e int
			declare @nQC25f int
			declare @nQC25g int
			declare @nQC25h int
			
			set @nQC25a = isnull((select	sum(TCNumber)
						  from		@tblTargetChildrenCurrent
						  where 	(TCRace = '01')
						 ), 0)
			set @nQC25b = isnull((select	sum(TCNumber)
						  from		@tblTargetChildrenCurrent
						  where 	(TCRace = '02')
						 ), 0)
			set @nQC25c = isnull((select	sum(TCNumber)
						  from		@tblTargetChildrenCurrent
						  where 	(TCRace = '03')
						 ), 0)
			set @nQC25d = isnull((select	sum(TCNumber)
						  from		@tblTargetChildrenCurrent
						  where 	(TCRace = '04')
						 ), 0)
			set @nQC25e = isnull((select	sum(TCNumber)
						  from		@tblTargetChildrenCurrent
						  where 	(TCRace = '05')
						 ), 0)
			set @nQC25f = isnull((select	sum(TCNumber)
						  from		@tblTargetChildrenCurrent
						  where 	(TCRace = '06')
						 ), 0)
			set @nQC25g = isnull((select	sum(TCNumber)
						  from		@tblTargetChildrenCurrent
						  where 	(TCRace = '07')
						 ), 0)
			set @nQC25h = isnull((select sum(TCNumber) 
						  from		@tblTargetChildrenCurrent
						  where		(TCRace is null or TCRace = '' or TCRace = ' ')
						  ), 0)
			

	-- 2.7. Gender
			declare @nQ27a int
			declare @nQ27b int
			declare @nQ27c int
			
			set @nQ27a = isnull((select	sum(TCNumber)
						  from		@tblTargetChildren
						  where 	(TCGender = '01')
						 ), '')
			set @nQ27b = isnull((select	sum(TCNumber)
						  from		@tblTargetChildren
						  where 	(TCGender = '02')
						 ), '')
			set @nQ27c = isnull((select	sum(TCNumber)
						  from		@tblTargetChildren
						  where 	(TCGender <> '01' and TCGender <> '02')
						 ), 0)

	--Current
			declare @nQC27a int
			declare @nQC27b int
			declare @nQC27c int
			
			set @nQC27a = isnull((select	sum(TCNumber)
						  from		@tblTargetChildrenCurrent
						  where 	(TCGender = '01')
						 ), '')
			set @nQC27b = isnull((select	sum(TCNumber)
						  from		@tblTargetChildrenCurrent
						  where 	(TCGender = '02')
						 ), '')
			set @nQC27c = isnull((select	sum(TCNumber)
						  from		@tblTargetChildrenCurrent
						  where 	(TCGender <> '01' and TCGender <> '02')
						 ), 0)

	-- 2i. Race
	-- Q3 --------------------------	
	-- Quarterly
			declare	@nQ3 int
			declare	@nQ3a int
			declare	@nQ3b int
			declare	@nQ3c int
			declare	@nQ3d int

	-- 3. Primary Caretaker 1 Age
			set @nQ3 = @TotalNumberOfFamiliesAtIntakeQuarterly

	--SELECT @nQ3

	-- 3a. Under 18 years
			set @nQ3a = (select	count(*)
						 from	@tblInitRequiredData2
						 where	(datediff(day, PCDOB,
										  IntakeDate) < (18
											* 365.25))
						)

			set @nQ3a = isnull(@nQ3a, 0)

	-- 3b. 18 up to 20
			set @nQ3b = (select	count(*)
						 from	@tblInitRequiredData2
						 where	(datediff(day, PCDOB,
										  IntakeDate) between (18
											* 365.25)
											and
											(20 * 365.25))
						)

			set @nQ3b = isnull(@nQ3b, 0)
	-- 3c. 20 up to 30
			set @nQ3c = (select	count(*)
						 from	@tblInitRequiredData2
						 where	(datediff(day, PCDOB,
										  IntakeDate) between (20
											* 365.25)
											and
											(30 * 365.25))
						)

			set @nQ3c = isnull(@nQ3c, 0)
	-- 3d. Over 30
			set @nQ3d = (select	count(*)
						 from	@tblInitRequiredData2
						 where	(datediff(day, PCDOB,
										  IntakeDate) > (30
											* 365.25))
						)

			set @nQ3d = isnull(@nQ3d, 0)

	-- Current Info
			declare	@nQC3 int
			declare	@nQC3a int
			declare	@nQC3b int
			declare	@nQC3c int
			declare	@nQC3d int

	-- 3. Primary Caretaker 1 Age
			set @nQC3 = @TotalNumberOfFamiliesAtIntakeQuarterly

	--SELECT @nQC3

	-- 3a. Under 18 years
			set @nQC3a = (select	count(*)
						  from		@tblInitRequiredData2
						  where		(datediff(day, PCDOB,
											LastDate) < (18
											* 365.25))
						 )

			set @nQC3a = isnull(@nQC3a, 0)

	-- 3b. 18 up to 20
			set @nQC3b = (select	count(*)
						  from		@tblInitRequiredData2
						  where		(datediff(day, PCDOB,
											LastDate) between (18
											* 365.25)
											and
											(20 * 365.25))
						 )

			set @nQC3b = isnull(@nQC3b, 0)
	-- 3c. 20 up to 30
			set @nQC3c = (select	count(*)
						  from		@tblInitRequiredData2
						  where		(datediff(day, PCDOB,
											LastDate) between (20
											* 365.25)
											and
											(30 * 365.25))
						 )

			set @nQC3c = isnull(@nQC3c, 0)
	-- 3d. Over 30
			set @nQC3d = (select	count(*)
						  from		@tblInitRequiredData2
						  where		(datediff(day, PCDOB,
											LastDate) > (30
											* 365.25))
						 )

			set @nQC3d = isnull(@nQC3d, 0)

	-- Q4 --------------------------	
			declare	@nQ4 int
			declare	@nQ4a int
			declare	@nQ4b int
			declare	@nQ4c int

	-- Bulding cohort for Q4

			declare	@tblPC1Education3 table
					(
					 [HVCasePK] [int]
				   , [IntakeDate] [datetime]
				   , [TCDOB] [datetime]
				   , [TCDOD] [datetime]
				   , [PCDOB] [datetime]
				   , [DischargeDate] [datetime]
				   , [LastDate] [datetime]
				   , [TCAgeDays] [int]
				   , [TCNumber] [int]
				   , [SiteFK] [int]
				   , [PC1Relation2TC] [char](2)
				   , [PC2Relation2TC] [char](2)
				   , [OBPRelation2TC] [char](2)
				   , [PC2inHomeIntake] bit
				   , [OBPinHome] bit
				   , EducationalEnrollment [char](1)
				   , FormFK [int]
				   , HighestGrade [char](2)
				   , HIUnknown [BIT]
				   , IsCurrentlyEmployed [char](1)
				   , MaritalStatus [char](2)
				   , PBFoodStamps [char](1)
				   , PBTANF [char](1)
				   , PC1HasMedicalProvider [char](1)
				   , PC1ReceivingMedicaid [char](1)
				   , TANFServices [BIT]
				   , [FormType] [char](8)
					)

			insert	into @tblPC1Education3
					select	HVCasePK
						  , IntakeDate
						  , TCDOB
						  , TCDOD
						  , PCDOB
						  , DischargeDate
						  , LastDate
						  , TCAgeDays
						  , TCNumber
						  , SiteFK
						  , PC1Relation2TC
						  , PC2Relation2TC
						  , [OBPRelation2TC]
						  , [PC2inHomeIntake]
						  , caIntakeOBP.[OBPinHome]
						  , ca.EducationalEnrollment
						  , ca.FormFK
						  , ca.HighestGrade
						  , ca.HIUnknown
						  , ca.IsCurrentlyEmployed
						  , ca.MaritalStatus
						  , ca.PBFoodStamps
						  , ca.PBTANF
						  , ca.PC1HasMedicalProvider
						  , ca.PC1ReceivingMedicaid
						  , ca.TANFServices
						  , ca.FormType
					from	@tblInitRequiredData pc1edu
					inner join CommonAttributes ca on ca.HVCaseFK = pc1edu.HVCasePK
											and ca.FormType = 'IN-PC1'
					left outer join CommonAttributes caIntakeOBP on caIntakeOBP.HVCaseFK = ca.HVCaseFK
											and caIntakeOBP.FormType = 'IN-OBP'
					where	IntakeDate <= @EndDate
							and (DischargeDate is null
								 or DischargeDate >= @StartDate
								)

			declare	@tblPC1Education table
					(
					 [HVCasePK] [int]
				   , [PC1MaritalStatus] [char](2)
				   , [PC1HighestGrade] [char](2)
				   , [OBPMaritalStatus] [char](2)
				   , [OBPHighestGrade] [char](2)
				   , [OBPinHome] [char](1)
				   , [PC1Relation2TC] [char](2)
				   , [OBPRelation2TC] [char](2)
				   , [PC2inHomeIntake] bit
				   , [PC1FormType] [char](8)
				   , [OBPFormType] [char](8)
					)

			insert	into @tblPC1Education
					select	irq.HVCasePK
						  , caIntakePC1.[MaritalStatus] as PC1MaritalStatus
						  , caIntakePC1.[HighestGrade] as PC1HighestGrade
						  , caIntakeOBP.[MaritalStatus] as OBPMaritalStatus
						  , caIntakeOBP.[HighestGrade] as OBPHighestGrade
						  , caIntakeOBP.[OBPinHome] as OBPinHome
						  , irq.[PC1Relation2TC]
						  , irq.[OBPRelation2TC]
						  , irq.[PC2inHomeIntake]
						  , caIntakePC1.FormType as PC1FormType
						  , caIntakeOBP.FormType as OBPFormType
					from	@tblInitRequiredData irq
					inner join CommonAttributes caIntakePC1 on caIntakePC1.HVCaseFK = irq.HVCasePK
											and caIntakePC1.FormType = 'IN-PC1'
					left outer join CommonAttributes caIntakeOBP on caIntakeOBP.HVCaseFK = irq.HVCasePK
											and caIntakeOBP.FormType = 'ID'
					where	IntakeDate <= @EndDate
							and (DischargeDate is null
								 or DischargeDate >= @StartDate
								)

	-- Let us look into the Kempes
			declare	@tblKempes table
					(
					 [HVCasePK] [int]
				   , PC1MaritalStatus [char](2)
				   , PC1HighestGrade [char](2)
					)

			insert	into @tblKempes
					select	k.HVCaseFK
						  , pc1.PC1MaritalStatus
						  , pc1.PC1HighestGrade
					from	kempe k
					left join @tblPC1Education pc1 on pc1.HVCasePK = k.HVCaseFK
					inner join @tblInitRequiredData2 irq2 on irq2.HVCasePK = k.HVCaseFK
					where	k.HVCaseFK is null

			declare	@nkQ4a int
			declare	@nkQ4b int
			declare	@nkQ4c int

	-- 4. Primary Caretaker 1 Education
			set @nQ4 = @nQ3

	-- 4a. Less than 12 years   --- NOT WORKING
			set @nQ4a = (select	count(*) count1
						 from	@tblPC1Education
						 where	PC1HighestGrade in ('01',
											'02')
						)
			set @nkQ4a = (select	count(*) count2
						  from		@tblKempes
						  where		PC1HighestGrade in ('01',
											'02')
						 )

			set @nQ4a = @nQ4a + @nkQ4a

	-- 4b. High School Graduate / GED
			set @nQ4b = (select	count(*) count1
						 from	@tblPC1Education
						 where	PC1HighestGrade in ('03',
											'04')
						)
			set @nkQ4b = (select	count(*) count2
						  from		@tblKempes
						  where		PC1HighestGrade in ('03',
											'04')
						 )
			set @nQ4b = @nQ4b + @nkQ4b

	-- 4c. Post Secondary
			set @nQ4c = (select	count(*) count1
						 from	@tblPC1Education
						 where	PC1HighestGrade in ('05',
											'06', '07', '08')
						)
			set @nkQ4c = (select	count(*) count2
						  from		@tblKempes
						  where		PC1HighestGrade in ('05',
											'06', '07', '08')
						 )
			set @nQ4c = @nQ4c + @nkQ4c

	-- Q5 --------------------------	
			declare	@nQ5a int
			declare	@nQ5b int
			declare	@nQ5c int
			--declare	@nkQ5 int

	--select HVCasePK
	--	 , caIntakePC1.[MaritalStatus] as PC1MaritalStatus
	--	 , caIntakePC1.[HighestGrade] as PC1HighestGrade
	--	 , caIntakePC1.[PBTANF] as PC1PBTANF
	--	 , caIntakePC1.[PBFoodStamps] as PC1PBFoodStamps
	--	 , caIntakePC1.[TANFServices] as PC1TANFServices
	--	 , caIntakePC1.[PC1ReceivingMedicaid] as PC1ReceivingMedicaid
	--	 , caIntakePC1.[HIUnknown] as PC1HIUnknown
	--	 , caIntakePC2.[MaritalStatus] as PC2MaritalStatus
	--	 , caIntakePC2.[HighestGrade] as PC2HighestGrade
	--	 , caIntakePC2.[PBTANF] as PC2PBTANF
	--	 , caIntakePC2.[PBFoodStamps] as PC2PBFoodStamps
	--	 , caIntakePC2.[TANFServices] as PC2TANFServices
	--	 , caIntakePC2.[PC1ReceivingMedicaid] as PC2ReceivingMedicaid
	--	 , caIntakePC2.[HIUnknown] as PC2HIUnknown
	--	 , caIntakeOBP.[MaritalStatus] as MaritalStatus
	--	 , caIntakeOBP.[HighestGrade] as OBPHighestGrade
	--	 , caIntakeOBP.[PBTANF] as OBPPBTANF
	--	 , caIntakeOBP.[PBFoodStamps] as OBPPBFoodStamps
	--	 , caIntakeOBP.[TANFServices] as OBPTANFServices
	--	 , caIntakeOBP.[PC1ReceivingMedicaid] as OBPReceivingMedicaid
	--	 , caIntakeOBP.[HIUnknown] as OBPHIUnknown
	--	 , caIntakeOBP.[OBPinHome]
	--	 , caIntakePC1.IsCurrentlyEmployed as PC1CurrentEmployment
	--	 , caIntakePC1.EducationalEnrollment as PC1CurrentEducationalEnrollment
	--	 , case when caIntakePC2.IsCurrentlyEmployed = '1' or caIntakeOBP.IsCurrentlyEmployed = '1' then '1' else '0' end as 
	--		 PC2CurrentEmployment -- Combines pc2 and obp because pc2 was split into these two during conversion from FoxPro
	--	 , case when caIntakePC2.EducationalEnrollment = '1' or caIntakeOBP.EducationalEnrollment = '1' then '1' else '0' end as 
	--		 PC2CurrentEducationalEnrollment 
	--		 -- Combines pc2 and obp because pc2 was split into these two during conversion from FoxPro
	--	 , irq2.[PC1Relation2TC]
	--	 , irq2.[PC2Relation2TC]
	--	 , irq2.[OBPRelation2TC]
	--	 , irq2.[PC2inHomeIntake]
	--	from @tblInitRequiredData2 irq2
	--		inner join CommonAttributes caIntakePC1 on caIntakePC1.HVCaseFK = irq2.HVCasePK and caIntakePC1.FormType = 'IN-PC1'
	--		left outer join CommonAttributes caIntakePC2 on caIntakePC2.HVCaseFK = irq2.HVCasePK and caIntakePC2.FormType = 
	--			'IN-PC2'
	--		left outer join CommonAttributes caIntakeOBP on caIntakeOBP.HVCaseFK = irq2.HVCasePK and caIntakeOBP.FormType = 
	--			'IN-OBP'
	--	where IntakeDate <= @EndDate
	--		 and IntakeDate is not null
	--		 and (DischargeDate >= @StartDate
	--		 or DischargeDate is null)

	-- 5. Primary Caretaker 1 Married

			declare @numPC1 int = (select count(HVCasePK)
							   from	  @tblInitRequiredData2)

			set @nQ5a = (select	count(HVCasePK) count1
						from	@tblPC1Education kempe
						where	kempe.PC1MaritalStatus = '01'
					   )

			set @nQ5b = (select	count(HVCasePK) count1
						from	@tblPC1Education kempe
						where	kempe.PC1MaritalStatus = '02'
					   )

			set @nQ5c = (select	count(HVCasePK) count1
						from	@tblPC1Education kempe
						where	kempe.PC1MaritalStatus <> '01' and kempe.PC1MaritalStatus <> '02'
					   )

			--set @nkQ5 = (select	count(*) count2
			--			 from	@tblKempes
			--			 where	PC1MaritalStatus = '01'
			--			)
			--set @nQ5 = @nQ5 + @nkQ5

	-- 6. Primary Caretaker 1 Race
			declare	@nQ6 int
			declare	@nQ6a int
			declare	@nQ6b int
			declare	@nQ6c int
			declare	@nQ6d int
			declare	@nQ6e int
			declare	@nQ6f int

			set @nQ6 = @nQ3
			set @nQ6a = (select	count(*) count1
						 from	@tblInitRequiredData2
						 where	Race = '01'
						)
			set @nQ6b = (select	count(*) count1
						 from	@tblInitRequiredData2
						 where	Race = '02'
						)
			set @nQ6c = (select	count(*) count1
						 from	@tblInitRequiredData2
						 where	Race = '03'
						)
			set @nQ6d = (select	count(*) count1
						 from	@tblInitRequiredData2
						 where	Race = '04'
						)
			set @nQ6e = (select	count(*) count1
						 from	@tblInitRequiredData2
						 where	Race = '05'
						)
			set @nQ6f = (select	count(*) count1
						 from	@tblInitRequiredData2
						 where	Race = '06'
						)

	-- 7. Household Composition
			declare	@nQ7 int
			declare	@nQ7a int
			declare	@nQ7b int
			declare	@nQ7c int
			declare	@nQ7d int

	-- figure out the intake column
			set @nQ7 = @nQ3
	--SELECT * FROM @tblPC1Education

			set @nQ7a = (select	count(*) count1
						 from	@tblPC1Education
						 where	PC1Relation2TC = '01'
								and OBPinHome = 1
						)
	--SET @nQ7a = (SELECT count(*) count1 FROM @tblPC1Education WHERE PC1Relation2TC = '01' AND [OBPRelation2TC] = '01')
			set @nQ7b = (select	count(*) count1
						 from	@tblPC1Education
						 where	[PC2inHomeIntake] = 1
						)

	-- for nQ7c
			declare	@tblOtherChild table
					(
					 [HVCasePK] [int]
				   , [HVCaseFK] [int]
				   , [LivingArrangement] [char](2)
					)

			insert	into @tblOtherChild
					select	HVCasePK
						  , HVCaseFK
						  , LivingArrangement
					from	@tblPC1Education pc1
					inner join OtherChild oc on oc.HVCaseFK = pc1.HVCasePK
					where	pc1.PC1Relation2TC = '01' -- AND pc1.PC1FormType = 'IN' -- filter IN includes kids at Intake not FollowUp
	--ORDER BY hvcasepk

	-- TODO - KHALSA CONTINUE

			declare @tblFirstTimeMothers table
				( 
				 FTMCount [int]
				)
			insert into @tblFirstTimeMothers
			    select	count(HVCasePK) as FirstTimeMothers
						  from		@tblPC1Education pc1e
						  where		HVCasePK not in (
									select	pc1e.HVCasePK
									from	OtherChild oc
									where	oc.HVCaseFK = pc1e.HVCasePK
											and oc.Relation2PC1 = '01')

	--set @nQ7c = (select count(*) ftmcount
	--				 from cteFirstTimeMothers)
	--select	count(*) ftmcount -- @nQ7c
	--from	cteFirstTimeMothers
	
	--select count(*) as @nQ7c
	-- from cteFirstTimeMothers
	
	set @nQ7c = (select FTMCount
					 from @tblFirstTimeMothers)
	
	select *, @nQ7c from @tblFirstTimeMothers tftm
	
	-- select HVCasePK
	--	from @tblPC1Education INT1
	--	where INT1.HVCasePK not in (select [@tblOtherChild].HVCasePK
	--									from @tblOtherChild)

	----SELECT HVCasePK FROM @tblOtherChild
	----ORDER BY hvcasepk

	--SET @nQ7c = (SELECT count(HVCasePK) FROM @tblPC1Education INT1 WHERE INT1.HVCasePK NOT IN (SELECT [@tblOtherChild].HVCasePK FROM @tblOtherChild))

	-- for @nQ7d
			declare	@tblOtherBioChild table ([HVCaseFK]
											[int])

			insert	into @tblOtherBioChild
					select distinct
							HVCaseFK
					from	@tblOtherChild
					where	LivingArrangement = '03' -- removes duplicate

			set @nQ7d = (select count (HVCaseFK)
								from @tblOtherBioChild
						)

	--SELECT * FROM @tblMain

			declare	@tblPC1Employment table
					(
					 [HVCasePK] [int]
				   , [PC1CurrentEmployment] [char](1)
				   , [PC1CurrentEducationEnrollment]
						[char](1)
				   , [PC2CurrentEmployment] [char](1)
				   , [PC2CurrentEducationEnrollment]
						[char](1)
					)
	-- cohort
			insert	into @tblPC1Employment
					select	HVCasePK
						  , caIntakePC1.IsCurrentlyEmployed as PC1CurrentEmployment
						  , caIntakePC1.EducationalEnrollment as PC1CurrentEducationalEnrollment
						  , case when caIntakePC2.IsCurrentlyEmployed = '1'
									  or caIntakeOBP.IsCurrentlyEmployed = '1'
								 then '1'
								 else '0'
							end as PC2CurrentEmployment -- Combines pc2 and obp because pc2 was split into these two during conversion from FoxPro
						  , case when caIntakePC2.EducationalEnrollment = '1'
									  or caIntakeOBP.EducationalEnrollment = '1'
								 then '1'
								 else '0'
							end as PC2CurrentEducationalEnrollment 
				 -- Combines pc2 and obp because pc2 was split into these two during conversion from FoxPro
					from	@tblInitRequiredData2 c
					inner join CommonAttributes caIntakePC1 on caIntakePC1.HVCaseFK = c.HVCasePK
											and caIntakePC1.FormType = 'IN-PC1'
					left outer join CommonAttributes caIntakePC2 on caIntakePC2.HVCaseFK = c.HVCasePK
											and caIntakePC2.FormType = 'IN-PC2'
					left outer join CommonAttributes caIntakeOBP on caIntakeOBP.HVCaseFK = c.HVCasePK
											and caIntakeOBP.FormType = 'IN-OBP'
					where	IntakeDate <= @EndDate
							and IntakeDate is not null
							and (DischargeDate >= @StartDate
								 or DischargeDate is null
								)

	-- 8. Employment, Education and training
			declare	@nQ8 int
			declare	@nQ8a int
			declare	@nQ8b int
			declare	@nQ8c int
			declare	@nQ8d int
			declare	@nQ8e int

			set @nQ8 = (select count (*) count1
								from @tblPC1Employment
					   )

			set @nQ8a = (select	count(*) count1
						 from	@tblPC1Employment
						 where	PC1CurrentEmployment = '1'
						)
			set @nQ8b = (select	count(*) count1
						 from	@tblPC1Employment
						 where	PC2CurrentEmployment = '1'
						)
			set @nQ8c = (select	count(*) count1
						 from	@tblPC1Employment
						 where	PC1CurrentEmployment = '1'
								or PC2CurrentEmployment = '1'
						)
			set @nQ8d = (select	count(*) count1
						 from	@tblPC1Employment
						 where	PC1CurrentEducationEnrollment = '1'
						)
			set @nQ8e = (select	count(*) count1
						 from	@tblPC1Employment
						 where	PC2CurrentEducationEnrollment = '1'
						)

	--SELECT * FROM @tblPC1Education

	-- 9. Benefit Receiving
			declare	@nQ9 int
			declare	@nQ9a int
			declare	@nQ9b int

			declare	@tblBenefitsReceiving table
					(
					 [HVCasePK] [int]
				   , [PBTANF] [char](1)
				   , [PBFoodStamps] [char](1)
					)

	-- Co-hort
			insert	into @tblBenefitsReceiving
					select	HVCasePK
						  , PBTANF
						  , PBFoodStamps
					from	CommonAttributes ca
					inner join @tblInitRequiredData2 tm on tm.HVCasePK = ca.HVCaseFK
					where	ca.FormType = 'IN'

			set @nQ9 = (select count (*) count1
								from @tblBenefitsReceiving
					   )
			set @nQ9a = (select	count(*) count1
						 from	@tblBenefitsReceiving
						 where	PBTANF = '1'
						)
			set @nQ9b = (select	count(*) count1
						 from	@tblBenefitsReceiving
						 where	PBFoodStamps = '1'
						)

	-- 10. Benefit Receiving
			declare	@nQ10 int
			declare	@nQ10a int

			declare	@tblTanfServices table
					(
					 [HVCasePK] [int]
				   , [TANFServices] bit
					)

	-- Co-hort
			insert	into @tblTanfServices
					select	HVCasePK
						  , TANFServices
					from	CommonAttributes ca
					inner join @tblInitRequiredData2 tm on tm.HVCasePK = ca.HVCaseFK
					where	ca.FormType = 'IN'

			set @nQ10 = (select count (*) count1
								from @tblTanfServices
						)
			set @nQ10a = (select	count(*) count1
						  from		@tblTanfServices
						  where		TANFServices = '1'
						 )

	-- 11. PC1 Medical Insurance and Medical Provider
			declare	@nQ11 int
			declare	@nQ11a int
			declare	@nQ11b int
			declare	@nQ11c int

			declare	@tblPC1MedicalInsurance table
					(
					 [HVCasePK] [int]
				   , [PC1ReceivingMedicaid] [char](1)
				   , [HIUnknown] bit
				   , [PC1HasMedicalProvider] [char](1)
					)

	-- Co-hort
			insert	into @tblPC1MedicalInsurance
					select	HVCasePK
						  , PC1ReceivingMedicaid
						  , HIUnknown
						  , PC1HasMedicalProvider
					from	CommonAttributes ca
					inner join @tblInitRequiredData2 tm on tm.HVCasePK = ca.HVCaseFK
					where	ca.FormType = 'IN'

			set @nQ11 = (select count (*) count1
								from @tblPC1MedicalInsurance
						)
			set @nQ11a = (select	count(*) count1
						  from		@tblPC1MedicalInsurance
						  where		PC1ReceivingMedicaid = '1'
						 )
			set @nQ11b = (select	count(*) count1
						  from		@tblPC1MedicalInsurance
						  where		HIUnknown = '1'
						 )
			set @nQ11c = (select	count(*) count1
						  from		@tblPC1MedicalInsurance
						  where		PC1HasMedicalProvider = '1'
						 )

	-- 12. TC Medical Insurance and Medical Provider by case
	-- don't include child that have died after the report end.
			declare	@nQ12 int
			declare	@nQ12a int
			declare	@nQ12b int
			declare	@nQ12c int

	--SELECT * FROM @tblInitRequiredData2

			declare	@tblTCMedical table
					(
					 [HVCasePK] [int]
				   , [TCHasMedicalProvider] [char](1)
				   , [TCHIUnknown] bit
				   , [TCReceivingMedicaid] [char](1)
					)

			insert	into @tblTCMedical
					select	HVCasePK
						  , TCHasMedicalProvider
						  , TCHIUnknown
						  , TCReceivingMedicaid
					from	CommonAttributes ca
					inner join @tblInitRequiredData2 tm on tm.HVCasePK = ca.HVCaseFK
					where	(tm.TCDOD is null
							 or tm.TCDOD >= @EndDate
							)
							and tm.TCDOB <= tm.IntakeDate
							and ca.FormType = 'TC'

	--SELECT * FROM @tblTCMedical

	-- As per John, don't apply Distinct filter. We want to show twins etc as it will match in Q2
			set @nQ12 = (select count (*) count1
								from @tblTCMedical
						)

			set @nQ12a = (select	count(*) count1
						  from		@tblTCMedical
						  where		TCReceivingMedicaid = '1'
						 )
			set @nQ12b = (select	count(*) count1
						  from		@tblTCMedical
						  where		TCHIUnknown = '1'
						 )
			set @nQ12c = (select	count(*) count1
						  from		@tblTCMedical
						  where		TCHasMedicalProvider = '1'
						 )

	-- 13. Length in Program
			declare	@nQ13 int
			declare	@nQ13a int
			declare	@nQ13b int
			declare	@nQ13c int
			declare	@nQ13d int
			declare	@nQ13e int
			declare	@nQ13f int
			declare	@nQ13g int
			declare	@nQ13h int

			set @nQ13 = 0

			set @nQ13a = 0
			set @nQ13b = 0
			set @nQ13c = 0
			set @nQ13d = 0
			set @nQ13e = 0
			set @nQ13f = 0
			set @nQ13g = 0
			set @nQ13h = 0

	--13. Length in Program
	--     a. Less than 3 Months
	--     b. 3 Months up to 6 Months
	--     c. 6 Months up to 1 Year
	--     d. 1 Year up to 2 Years
	--     e. 2 Years up to 3 Years
	--     f. 3 Years up to 4 Year
	--     g. 4 Years up to 5 Years
	--     h. Over 5 Years

			set @nQ13 = (select count (HVCasePK)
								from @tblInitRequiredData2
						)

			set @nQ13a = (select	count(HVCasePK)
						  from		@tblInitRequiredData2
						  where		datediff(month,
											IntakeDate,
											isnull(DischargeDate,
											@EndDate)) < 3
						 )

			set @nQ13b = (select	count(HVCasePK)
						  from		@tblInitRequiredData2
						  where		datediff(month,
											IntakeDate,
											isnull(DischargeDate,
											@EndDate)) between 3
											and
											6
						 )

			set @nQ13d = (select	count(HVCasePK)
						  from		@tblInitRequiredData2
						  where		datediff(month,
											IntakeDate,
											isnull(DischargeDate,
											@EndDate)) between 6
											and
											12
						 )

			set @nQ13d = (select	count(HVCasePK)
						  from		@tblInitRequiredData2
						  where		datediff(month,
											IntakeDate,
											isnull(DischargeDate,
											@EndDate)) between 12
											and
											24
						 )

			set @nQ13e = (select	count(HVCasePK)
						  from		@tblInitRequiredData2
						  where		datediff(month,
											IntakeDate,
											isnull(DischargeDate,
											@EndDate)) between 24
											and
											36
						 )

			set @nQ13f = (select	count(HVCasePK)
						  from		@tblInitRequiredData2
						  where		datediff(month,
											IntakeDate,
											isnull(DischargeDate,
											@EndDate)) between 36
											and
											48
						 )

			set @nQ13g = (select	count(HVCasePK)
						  from		@tblInitRequiredData2
						  where		datediff(month,
											IntakeDate,
											isnull(DischargeDate,
											@EndDate)) between 48
											and
											60
						 )

			set @nQ13h = (select	count(HVCasePK)
						  from		@tblInitRequiredData2
						  where		datediff(month,
											IntakeDate,
											isnull(DischargeDate,
											@EndDate)) > 60
						 )

			declare	@tblMainResult table
					(
					 iGroup int
				   , [Text] varchar(500)
				   , [QuarterlyData] varchar(50)
				   , [MostCurrentData] varchar(50)
					)

	--IF (@CustomQuarterlyDates = 0)
	--	BEGIN 

	-- Q1
			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(1
				   , '1. Total Families'
				   , @TotalNumberOfFamiliesAtIntakeQuarterly
				   , @TotalNumberOfFamiliesAtIntakeQuarterly
					)
			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(1
				   , '        a. Prenatal'
				   , convert(varchar, @nPrenatalQuarterly)
					 + ' ('
					 + convert(varchar, round(coalesce(cast(@nPrenatalQuarterly as float)
											* 100
											/ nullif(@TotalNumberOfFamiliesAtIntakeQuarterly,
											0), 0), 0))
					 + '%)'
				   , convert(varchar, @nQC1a) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQC1a as float)
											* 100
											/ nullif(@TotalNumberOfFamiliesAtIntakeQuarterly,
											0), 0), 0))
					 + '%)'
					)

	--insert into @tblMainResult (1
	--						  ,	[Text]
	--						  , [QuarterlyData]
	--						  , [MostCurrentData])
	--	values (1,'', '', '') --insert empty row

	-- Q2
			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(2
				   , '2. Target Child(ren)'
				   , @nQ2
				   , @nQC2
					)

			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(2
				   , '        a. Under 3 months'
				   , convert(varchar, @nQ2a) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ2a as float)
											* 100
											/ nullif(@nQ2, 0),
											0), 0)) + '%)'
				   , convert(varchar, @nQC2a) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQC2a as float)
											* 100
											/ nullif(@nQC2,
											0), 0), 0))
					 + '%)'
					)

			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(2
				   , '        b. 3 months up to 1 year'
				   , convert(varchar, @nQ2b) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ2b as float)
											* 100
											/ nullif(@nQ2, 0),
											0), 0)) + '%)'
				   , convert(varchar, @nQC2b) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQC2b as float)
											* 100
											/ nullif(@nQC2,
											0), 0), 0))
					 + '%)'
					)

			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(2
				   , '        c. 1 year up to 2 years'
				   , convert(varchar, @nQ2c) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ2c as float)
											* 100
											/ nullif(@nQ2, 0),
											0), 0)) + '%)'
				   , convert(varchar, @nQC2c) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQC2c as float)
											* 100
											/ nullif(@nQC2,
											0), 0), 0))
					 + '%)'
					)

			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(2
				   , '        d. 2 years up to 3 years'
				   , convert(varchar, @nQ2d) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ2d as float)
											* 100
											/ nullif(@nQ2, 0),
											0), 0)) + '%)'
				   , convert(varchar, @nQC2d) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQC2d as float)
											* 100
											/ nullif(@nQC2,
											0), 0), 0))
					 + '%)'
					)

			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(2
				   , '        e. 3 years up to 4 years'
				   , convert(varchar, @nQ2e) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ2e as float)
											* 100
											/ nullif(@nQ2, 0),
											0), 0)) + '%)'
				   , convert(varchar, @nQC2e) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQC2e as float)
											* 100
											/ nullif(@nQC2,
											0), 0), 0))
					 + '%)'
					)

			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(2
				   , '        f. 4 years up to 5 years'
				   , convert(varchar, @nQ2f) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ2f as float)
											* 100
											/ nullif(@nQ2, 0),
											0), 0)) + '%)'
				   , convert(varchar, @nQC2f) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQC2f as float)
											* 100
											/ nullif(@nQC2,
											0), 0), 0))
					 + '%)'
					)

			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(2
				   , '        g. Over 5 years'
				   , convert(varchar, @nQ2g) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ2g as float)
											* 100
											/ nullif(@nQ2, 0),
											0), 0)) + '%)'
				   , convert(varchar, @nQC2g) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQC2g as float)
											* 100
											/ nullif(@nQC2,
											0), 0), 0))
					 + '%)'
					)


	--Q2.5
	insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(2
				   , '2. Target Children Race'
				   , @nQ2
				   , @nQC2
					)

			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(2
				   , '        a. White, non-Hispanic'
				   , convert(varchar, @nQ25a) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ25a as float)
											* 100
											/ nullif(@nQ2, 0),
											0), 0)) + '%)'
				   , convert(varchar, @nQC25a) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQC25a as float)
											* 100
											/ nullif(@nQC2,
											0), 0), 0))
					 + '%)'
					)

			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(2
				   , '        b. Black, non-Hispanic'
				   , convert(varchar, @nQ25b) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ25b as float)
											* 100
											/ nullif(@nQ2, 0),
											0), 0)) + '%)'
				   , convert(varchar, @nQC25b) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQC25b as float)
											* 100
											/ nullif(@nQC2,
											0), 0), 0))
					 + '%)'
					)
			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(2
				   , '        c. Hispanic/Latina/Latino'
				   , convert(varchar, @nQ25c) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ25c as float)
											* 100
											/ nullif(@nQ2, 0),
											0), 0)) + '%)'
				   , convert(varchar, @nQC25c) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQC25c as float)
											* 100
											/ nullif(@nQC2,
											0), 0), 0))
					 + '%)'
					)

			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(2
				   , '        d. Asian'
				   , convert(varchar, @nQ25d) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ25d as float)
											* 100
											/ nullif(@nQ2, 0),
											0), 0)) + '%)'
				   , convert(varchar, @nQC25d) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQC25d as float)
											* 100
											/ nullif(@nQC2,
											0), 0), 0))
					 + '%)'
					)

			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(2
				   , '        e. Native American'
				   , convert(varchar, @nQ25e) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ25e as float)
											* 100
											/ nullif(@nQ2, 0),
											0), 0)) + '%)'
				   , convert(varchar, @nQC25e) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQC25e as float)
											* 100
											/ nullif(@nQC2,
											0), 0), 0))
					 + '%)'
					)

			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(2
				   , '        f. Multiracial'
				   , convert(varchar, @nQ25f) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ25f as float)
											* 100
											/ nullif(@nQ2, 0),
											0), 0)) + '%)'
				   , convert(varchar, @nQC25f) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQC25f as float)
											* 100
											/ nullif(@nQC2,
											0), 0), 0))
					 + '%)'
					)

			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(2
				   , '        g. Other'
				   , convert(varchar, @nQ25g) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ25g as float)
											* 100
											/ nullif(@nQ2, 0),
											0), 0)) + '%)'
				   , convert(varchar, @nQC25g) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQC25g as float)
											* 100
											/ nullif(@nQC2,
											0), 0), 0))
					 + '%)'
					)

			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(2
				   , '        h. Missing'
				   , convert(varchar, @nQ25h) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ25h as float)
											* 100
											/ nullif(@nQ2, 0),
											0), 0)) + '%)'
				   , convert(varchar, @nQC25h) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQC25h as float)
											* 100
											/ nullif(@nQC2,
											0), 0), 0))
					 + '%)'
					)

	--Q2.7

			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(2
				   , '2. Target Children Gender'
				   , @nQ2
				   , @nQC2
					)

			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(2
				   , '        a. Male'
				   , convert(varchar, @nQ27a) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ27a as float)
											* 100
											/ nullif(@nQ2, 0),
											0), 0)) + '%)'
				   , convert(varchar, @nQC27a) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQC27a as float)
											* 100
											/ nullif(@nQC2,
											0), 0), 0))
					 + '%)'
					)

			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(2
				   , '        b. Female'
				   , convert(varchar, @nQ27b) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ27b as float)
											* 100
											/ nullif(@nQ2, 0),
											0), 0)) + '%)'
				   , convert(varchar, @nQC27b) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQC27b as float)
											* 100
											/ nullif(@nQC2,
											0), 0), 0))
					 + '%)'
					)

			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(2
				   , '        c. Missing'
				   , convert(varchar, @nQ27c) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ27c as float)
											* 100
											/ nullif(@nQ2, 0),
											0), 0)) + '%)'
				   , convert(varchar, @nQC27c) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQC27c as float)
											* 100
											/ nullif(@nQC2,
											0), 0), 0))
					 + '%)'
					)

	--insert into @tblMainResult (iGroup
	--						  ,	[Text]
	--						  , [QuarterlyData]
	--						  , [MostCurrentData])
	--	values (2,'', '', '') --insert empty row

	-- Q3
			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(3
				   , '3. Primary Caretaker 1 Age'
				   , @nQ3
				   , @nQC3
					)
			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(3
				   , '        a. Under 18 years'
				   , convert(varchar, @nQ3a) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ3a as float)
											* 100
											/ nullif(@nQ3, 0),
											0), 0)) + '%)'
				   , convert(varchar, @nQC3a) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQC3a as float)
											* 100
											/ nullif(@nQC3,
											0), 0), 0))
					 + '%)'
					)

			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(3
				   , '        b. 18 up to 20'
				   , convert(varchar, @nQ3b) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ3b as float)
											* 100
											/ nullif(@nQ3, 0),
											0), 0)) + '%)'
				   , convert(varchar, @nQC3b) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQC3b as float)
											* 100
											/ nullif(@nQC3,
											0), 0), 0))
					 + '%)'
					)

			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(3
				   , '        c. 20 up to 30'
				   , convert(varchar, @nQ3c) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ3c as float)
											* 100
											/ nullif(@nQ3, 0),
											0), 0)) + '%)'
				   , convert(varchar, @nQC3c) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQC3c as float)
											* 100
											/ nullif(@nQC3,
											0), 0), 0))
					 + '%)'
					)

			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(3
				   , '        d. Over 30'
				   , convert(varchar, @nQ3d) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ3d as float)
											* 100
											/ nullif(@nQ3, 0),
											0), 0)) + '%)'
				   , convert(varchar, @nQC3d) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQC3d as float)
											* 100
											/ nullif(@nQC3,
											0), 0), 0))
					 + '%)'
					)

	--insert into @tblMainResult (iGroup
	--						  ,	[Text]
	--						  , [QuarterlyData]
	--						  , [MostCurrentData])
	--	values (3,'', '', '') --insert empty row

	-- Q4
			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(4
				   , '4. Primary Caretaker 1 Education'
				   , @nQ3
				   , ''
					)

			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(4
				   , '        a. Less than 12 years'
				   , convert(varchar, @nQ4a) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ4a as float)
											* 100
											/ nullif(@nQ4, 0),
											0), 0)) + '%)'
				   , ''
					)

			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(4
				   , '        b. High School Graduate / GED'
				   , convert(varchar, @nQ4b) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ4b as float)
											* 100
											/ nullif(@nQ4, 0),
											0), 0)) + '%)'
				   , ''
					)

			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(4
				   , '        c. Post Secondary'
				   , convert(varchar, @nQ4c) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ4c as float)
											* 100
											/ nullif(@nQ4, 0),
											0), 0)) + '%)'
				   , ''
					)

	--insert into @tblMainResult (iGroup
	--						  ,	[Text]
	--						  , [QuarterlyData]
	--						  , [MostCurrentData])
	--	values (4,'', '', '') --insert empty row

	-- Q5			
			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(5
				   , '5. Primary Caretaker 1 Marital Status'
				   , convert(varchar, @numPC1)
				   , convert(varchar, @numPC1)
					)

			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(5
				   , '        a. Married'
				   , convert(varchar, @nQ5a) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ5a as float)
											* 100
											/ nullif(@numPC1,
											0), 0), 0))
					 + '%)'
				   , ''
					)

			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(5
				   , '        b. Not Married'
				   , convert(varchar, @nQ5b) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ5b as float)
											* 100
											/ nullif(@numPC1,
											0), 0), 0))
					 + '%)'
				   , ''
					)

			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(5
				   , '        c. Missing'
				   , convert(varchar, @nQ5c) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ5c as float)
											* 100
											/ nullif(@numPC1,
											0), 0), 0))
					 + '%)'
				   , ''
					)

	--insert into @tblMainResult (iGroup
	--						  ,	[Text]
	--						  , [QuarterlyData]
	--						  , [MostCurrentData])
	--	values (5,'', '', '') --insert empty row

	-- Q6				
			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(6
				   , '6. Primary Caretaker 1 Race'
				   , @nQ6
				   , ''
					)

			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(6
				   , '     a. White'
				   , convert(varchar, @nQ6a) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ6a as float)
											* 100
											/ nullif(@nQ6, 0),
											0), 0)) + '%)'
				   , ''
					)
			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(6
				   , '     b. Black'
				   , convert(varchar, @nQ6b) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ6b as float)
											* 100
											/ nullif(@nQ6, 0),
											0), 0)) + '%)'
				   , ''
					)
			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(6
				   , '     c. Hispanic'
				   , convert(varchar, @nQ6c) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ6c as float)
											* 100
											/ nullif(@nQ6, 0),
											0), 0)) + '%)'
				   , ''
					)
			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(6
				   , '     d. Asian'
				   , convert(varchar, @nQ6d) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ6d as float)
											* 100
											/ nullif(@nQ6, 0),
											0), 0)) + '%)'
				   , ''
					)
			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(6
				   , '     e. Native American'
				   , convert(varchar, @nQ6e) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ6e as float)
											* 100
											/ nullif(@nQ6, 0),
											0), 0)) + '%)'
				   , ''
					)
			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(6
				   , '     f. Other race'
				   , convert(varchar, @nQ6f) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ6f as float)
											* 100
											/ nullif(@nQ6, 0),
											0), 0)) + '%)'
				   , ''
					)

	--insert into @tblMainResult (iGroup
	--						  ,	[Text]
	--						  , [QuarterlyData]
	--						  , [MostCurrentData])
	--	values (6,'', '', '') --insert empty row

	-- Q7				
			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(7
				   , '7. Household Composition'
				   , @nQ7
				   , ''
					)

			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(7
				   , '     a. Bio Parents living with TC'
				   , convert(varchar, @nQ7a) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ7a as float)
											* 100
											/ nullif(@nQ7, 0),
											0), 0)) + '%)'
				   , ''
					)

			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(7
				   , '     b. Other Support (OBP/PC2) living in household'
				   , convert(varchar, @nQ7b) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ7b as float)
											* 100
											/ nullif(@nQ7, 0),
											0), 0)) + '%)'
				   , ''
					)

			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(7
				   , '     c. First time mother (No other children)'
				   , convert(varchar, @nQ7c) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ7c as float)
											* 100
											/ nullif(@nQ7, 0),
											0), 0)) + '%)'
				   , ''
					)

			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(7
				   , '     d. Other Bio Children in Foster Care'
				   , convert(varchar, @nQ7d) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ7d as float)
											* 100
											/ nullif(@nQ7, 0),
											0), 0)) + '%)'
				   , ''
					)

	--insert into @tblMainResult (iGroup
	--						  ,	[Text]
	--						  , [QuarterlyData]
	--						  , [MostCurrentData])
	--	values (7,'', '', '') --insert empty row

	-- Q8				
			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(8
				   , '8. Employment, Education and training'
				   , @nQ8
				   , ''
					)

			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(8
				   , '     a. Primary Caretaker 1 Employed'
				   , convert(varchar, @nQ8a) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ8a as float)
											* 100
											/ nullif(@nQ8, 0),
											0), 0)) + '%)'
				   , ''
					)
			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(8
				   , '     b. Other Biological Parent / Primary Caretaker 2 Employed'
				   , convert(varchar, @nQ8b) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ8b as float)
											* 100
											/ nullif(@nQ8, 0),
											0), 0)) + '%)'
				   , ''
					)
			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(8
				   , '     c. Either PC1 or OBP/PC2 Employed'
				   , convert(varchar, @nQ8c) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ8c as float)
											* 100
											/ nullif(@nQ8, 0),
											0), 0)) + '%)'
				   , ''
					)
			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(8
				   , '     d. PC1 in Education / Training Program'
				   , convert(varchar, @nQ8d) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ8d as float)
											* 100
											/ nullif(@nQ8, 0),
											0), 0)) + '%)'
				   , ''
					)
			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(8
				   , '     e. OBP/PC2 in Education / Training Program'
				   , convert(varchar, @nQ8e) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ8e as float)
											* 100
											/ nullif(@nQ8, 0),
											0), 0)) + '%)'
				   , ''
					)

	--insert into @tblMainResult (iGroup
	--						  ,	[Text]
	--						  , [QuarterlyData]
	--						  , [MostCurrentData])
	--	values (8,'', '', '') --insert empty row

	-- Q9				
			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(9
				   , '9. Benefits Receiving'
				   , @nQ9
				   , ''
					)

			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(9
				   , '     a. TANF'
				   , convert(varchar, @nQ9a) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ9a as float)
											* 100
											/ nullif(@nQ9, 0),
											0), 0)) + '%)'
				   , ''
					)
			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(9
				   , '     b. Food Stamps'
				   , convert(varchar, @nQ9b) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ9b as float)
											* 100
											/ nullif(@nQ9, 0),
											0), 0)) + '%)'
				   , ''
					)

	--insert into @tblMainResult (iGroup
	--						  ,	[Text]
	--						  , [QuarterlyData]
	--						  , [MostCurrentData])
	--	values (9,'', '', '') --insert empty row

	-- Q10				
			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(10
				   , '10. TANF Services Eligibility'
				   , @nQ10
				   , ''
					)

			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(10
				   , '     a. % Eligible for TANF Services'
				   , convert(varchar, @nQ10a) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ10a as float)
											* 100
											/ nullif(@nQ10,
											0), 0), 0))
					 + '%)'
				   , ''
					)

	--insert into @tblMainResult (iGroup
	--						  ,	[Text]
	--						  , [QuarterlyData]
	--						  , [MostCurrentData])
	--	values (10,'', '', '') --insert empty row

	-- Q11				
			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(11
				   , '11. PC1 Medical Insurance and Medical Provider'
				   , @nQ11
				   , ''
					)

			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(11
				   , '     a. Primary Caretaker 1 on Medicaid'
				   , convert(varchar, @nQ11a) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ11a as float)
											* 100
											/ nullif(@nQ11,
											0), 0), 0))
					 + '%)'
				   , ''
					)
			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(11
				   , '     b. Primary Caretaker 1 has No Health Insurance'
				   , convert(varchar, @nQ11b) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ11b as float)
											* 100
											/ nullif(@nQ11,
											0), 0), 0))
					 + '%)'
				   , ''
					)
			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(11
				   , '     c. Primary Caretaker 1 has Medical Provider'
				   , convert(varchar, @nQ11c) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ11c as float)
											* 100
											/ nullif(@nQ11,
											0), 0), 0))
					 + '%)'
				   , ''
					)

	--insert into @tblMainResult (iGroup
	--						  ,	[Text]
	--						  , [QuarterlyData]
	--						  , [MostCurrentData])
	--	values (11,'', '', '') --insert empty row

	-- Q12				
			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(12
				   , '12. TC Medical Insurance and Medical Provider by case'
				   , @nQ12
				   , ''
					)

			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(12
				   , '     a. Target Child on Medicaid'
				   , convert(varchar, @nQ12a) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ12a as float)
											* 100
											/ nullif(@nQ12,
											0), 0), 0))
					 + '%)'
				   , ''
					)
			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(12
				   , '     b. Target Child has No Health Insurance'
				   , convert(varchar, @nQ12b) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ12b as float)
											* 100
											/ nullif(@nQ12,
											0), 0), 0))
					 + '%)'
				   , ''
					)
			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(12
				   , '     c. Target Child has Medical Provider'
				   , convert(varchar, @nQ12c) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ12c as float)
											* 100
											/ nullif(@nQ12,
											0), 0), 0))
					 + '%)'
				   , ''
					)

	--insert into @tblMainResult (iGroup
	--						  ,	[Text]
	--						  , [QuarterlyData]
	--						  , [MostCurrentData])
	--	values (12, '', '', '') --insert empty row

	-- Q13				
			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(13
				   , '13. Length in Program'
				   , 'N/A'
				   , @nQ13
					)

			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(13
				   , '     a. Less than 3 Months'
				   , ''
				   , convert(varchar, @nQ13a) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ13a as float)
											* 100
											/ nullif(@nQ13,
											0), 0), 0))
					 + '%)'
					)
			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(13
				   , '     b. 3 Months up to 6 Months'
				   , ''
				   , convert(varchar, @nQ13b) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ13b as float)
											* 100
											/ nullif(@nQ13,
											0), 0), 0))
					 + '%)'
					)
			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(13
				   , '     c. 6 Months up to 1 Year'
				   , ''
				   , convert(varchar, @nQ13c) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ13c as float)
											* 100
											/ nullif(@nQ13,
											0), 0), 0))
					 + '%)'
					)
			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(13
				   , '     d. 1 Year up to 2 Years'
				   , ''
				   , convert(varchar, @nQ13d) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ13d as float)
											* 100
											/ nullif(@nQ13,
											0), 0), 0))
					 + '%)'
					)
			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(13
				   , '     e. 2 Years up to 3 Years'
				   , ''
				   , convert(varchar, @nQ13e) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ13e as float)
											* 100
											/ nullif(@nQ13,
											0), 0), 0))
					 + '%)'
					)
			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(13
				   , '     f. 3 Years up to 4 Year'
				   , ''
				   , convert(varchar, @nQ13f) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ13f as float)
											* 100
											/ nullif(@nQ13,
											0), 0), 0))
					 + '%)'
					)
			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(13
				   , '     g. 4 Years up to 5 Years'
				   , ''
				   , convert(varchar, @nQ13g) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ13g as float)
											* 100
											/ nullif(@nQ13,
											0), 0), 0))
					 + '%)'
					)
			insert	into @tblMainResult
					(iGroup
				   , [Text]
				   , [QuarterlyData]
				   , [MostCurrentData]
					)
			values	(13
				   , '     h. Over 5 Years'
				   , ''
				   , convert(varchar, @nQ13h) + ' ('
					 + convert(varchar, round(coalesce(cast(@nQ13h as float)
											* 100
											/ nullif(@nQ13,
											0), 0), 0))
					 + '%)'
					)

	--insert into @tblMainResult (iGroup
	--						  ,	[Text]
	--						  , [QuarterlyData]
	--						  , [MostCurrentData])
	--	values (13,'', '', '') --insert empty row

	--	END

			select	*
			from	@tblMainResult

	  end
GO
