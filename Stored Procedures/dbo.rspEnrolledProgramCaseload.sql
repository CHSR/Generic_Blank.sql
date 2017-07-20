SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <July 16th, 2012>
-- Description:	<gets you data for Enrolled Program Caseload Quarterly and Contract Period>
-- exec [rspEnrolledProgramCaseload] ',19,','07/01/2012','09/30/2012',null,0, null,1
-- exec [rspEnrolledProgramCaseload] ',1,','06/01/2010','08/31/2011',null,0, null,0
-- exec [rspEnrolledProgramCaseload] ',1,','06/01/2012','08/31/2012',null,0,1,1
-- Edit date: 10/11/2013 CP - workerprogram was duplicating cases when worker transferred
--            added this code to the workerprogram join condition: AND wp.programfk = listitem
--			  01/07/15 jr - remove double tabs in output strings and replace with single tabs
-- =============================================
CREATE procedure [dbo].[rspEnrolledProgramCaseload](@programfk    varchar(max)    = null,
                                                        @sdate        datetime,
                                                        @edate        datetime,                                                        
                                                        @sitefk int             = NULL,
                                                        @CustomQuarterlyDates BIT,
                                                        @casefilterspositive varchar(200)                                                       
                                                        )

as
BEGIN

	-- if user picks up custom dates ( not specific quarter dates) then Don't show ContractPeriod Column
	--DECLARE @bDontShowContractPeriod BIT
	-- we will be receiving the value of @bDontShowContractPeriod from UI. 
	-- so time being, let us do the following
	--SET @bDontShowContractPeriod = 0
	


    declare @ContractStartDate DATE
    declare @ContractEndDate DATE
    
    if ((@ProgramFK IS not NULL) AND (@CustomQuarterlyDates = 0))
    BEGIN 
		set @ProgramFK = REPLACE(@ProgramFK,',','') -- remove comma's
		set @ContractStartDate = (select ContractStartDate FROM HVProgram P where HVProgramPK=@ProgramFK)
		set @ContractEndDate = (select ContractEndDate FROM HVProgram P where HVProgramPK=@ProgramFK)		
	END 

	set @ProgramFK = REPLACE(@ProgramFK,'"','')	
	set @casefilterspositive = case when @casefilterspositive = '' then null else @casefilterspositive end

-- Let us declare few table variables so that we can manipulate the rows at our will
-- Note: Table variables are a superior alternative to using temporary tables 

---------------------------------------------
-- Initially, get the subset of data that we are interested in ... Good Practice ... Khalsa 
-- table variable for holding Init Required Data
DECLARE @tblInitRequiredData TABLE(
	[HVCasePK] [int],
	[IntakeDate] [datetime],
	[TCDOB] [datetime],
	[TCDOD] [datetime],
	[TCNumber] [int],
	[DischargeDate] [datetime],
	[DischargeReason] [char](2),
	[SiteFK] [int]

)


DECLARE @tblInitRequiredDataTemp TABLE(
	[HVCasePK] [int],
	[IntakeDate] [datetime],
	[TCDOB] [datetime],
	[TCDOD] [datetime],	
	[TCNumber] [int],
	[DischargeDate] [datetime],
	[DischargeReason] [char](2),
	[SiteFK] [int]

)

-- Fill this table i.e. @tblInitRequiredData as below
INSERT INTO @tblInitRequiredDataTemp(
	[HVCasePK],
	[IntakeDate],
	[TCDOB],
	[TCDOD],
	[TCNumber],
	[DischargeDate],
	[DischargeReason],
	[SiteFK]
)
SELECT 
h.HVCasePK,h.IntakeDate,

case
   when h.tcdob is not null then
	   h.tcdob
   else
	   h.edc
end as tcdob
,h.TCDOD 
,h.TCNumber,cp.DischargeDate, cp.DischargeReason,CASE WHEN wp.SiteFK IS NULL THEN 0 ELSE wp.SiteFK END AS SiteFK
FROM HVCase h 
INNER JOIN CaseProgram cp ON h.HVCasePK = cp.HVCaseFK 
inner join dbo.SplitString(@programfk,',') on cp.programfk = listitem	
inner join dbo.udfCaseFilters(@casefilterspositive, '', @programfk) cf on cf.HVCaseFK = h.HVCasePK
INNER JOIN Worker w ON w.WorkerPK = cp.CurrentFSWFK
INNER JOIN WorkerProgram wp ON wp.WorkerFK = w.WorkerPK AND wp.programfk = listitem

-- SiteFK = isnull(@sitefk,SiteFK) does not work because column SiteFK may be null itself 
-- so to solve this problem we make use of @tblInitRequiredDataTemp
INSERT INTO @tblInitRequiredData( 
	[HVCasePK],
	[IntakeDate],
	[TCDOB],
	[TCDOD],
	[TCNumber],
	[DischargeDate],
	[DischargeReason],
	[SiteFK])
SELECT * FROM @tblInitRequiredDataTemp
WHERE SiteFK = isnull(@sitefk,SiteFK)


---------------------------------------------

---------------------------------------------
--- **************************************** ---
-- Part 1: Families Enrolled at the beginning of the period	(QUARTERLY STATS)

DECLARE @TotalNumberOfFamiliesEnrolledQuarterly INT 
DECLARE @TotalTCNumberQuarterly INT

-- exclude any twin that dies before period, and babies that should have been born 
SET @TotalTCNumberQuarterly = (
SELECT sum(
CASE WHEN (irq.TCDOB IS NOT NULL AND (irq.TCDOD >=  @edate OR irq.TCDOD IS NULL)) THEN 1
 ELSE 
	CASE WHEN (irq.TCDOB <=  @sdate) THEN 1 ELSE 0 END
 END
) AS TotalTCNumber
FROM @tblInitRequiredData irq
LEFT JOIN TCID T ON irq.HVCasePK = T.HVCaseFK 
WHERE IntakeDate IS NOT NULL 
AND IntakeDate < @sdate
AND (DischargeDate IS NULL OR DischargeDate >= @sdate)	
and irq.tcdob <=  @edate -- as per JH - take our babies who are born after the end period of the report		
)



SET @TotalNumberOfFamiliesEnrolledQuarterly = (
SELECT count(DISTINCT HVCasePK)
 FROM @tblInitRequiredData irq
LEFT JOIN TCID T ON irq.HVCasePK = T.HVCaseFK 
WHERE IntakeDate IS NOT NULL 
AND IntakeDate < @sdate
AND (DischargeDate IS NULL OR DischargeDate >= @sdate)
)


--- **************************************** ---
-- Part 1a: Families Enrolled at the beginning of the period (CONTRACT PERIOD STATS)	
-- NOTE: For contract period, our sdate is @ContractStartDate

IF (@CustomQuarterlyDates = 0)
	BEGIN 

			DECLARE @NumberOfFamiliesEnrolled4ContractPeriod INT 
			DECLARE @TCNumber4ContractPeriod INT 


			-- exclude any twin that dies before period, and babies that should have been born 
			SET @TCNumber4ContractPeriod = (
			SELECT sum(
			CASE WHEN (irq.TCDOB IS NOT NULL AND (irq.TCDOD >=  @edate OR irq.TCDOD IS NULL)) THEN 1
			 ELSE 
				CASE WHEN (irq.TCDOB <=  @sdate) THEN 1 ELSE 0 END
			 END
			) AS TotalTCNumber
			FROM @tblInitRequiredData irq
			LEFT JOIN TCID T ON irq.HVCasePK = T.HVCaseFK 
			WHERE IntakeDate IS NOT NULL 
			AND IntakeDate < @ContractStartDate
			AND (DischargeDate IS NULL OR DischargeDate >= @ContractStartDate)	
			and irq.tcdob <=  @edate -- as per JH - take our babies who are born after the end period of the report		
			)



			SET @NumberOfFamiliesEnrolled4ContractPeriod = (
			SELECT count(DISTINCT HVCasePK)
			 FROM @tblInitRequiredData irq
			LEFT JOIN TCID T ON irq.HVCasePK = T.HVCaseFK 
			WHERE IntakeDate IS NOT NULL 
			AND IntakeDate < @ContractStartDate
			AND (DischargeDate IS NULL OR DischargeDate >= @ContractStartDate)	
			)

	END	

---------------------------------------------
--- **************************************** ---
-- Part 2: New families Prenatal v/s Postnatal at intake
-- Quarterly figures
DECLARE @TotalNumOfFamiliesEnrolledThisPeriodQuarterly INT 
DECLARE @TotalPrenatalFamiliesQuarterly INT 
DECLARE @TotalPostnatalFamiliesQuarterly INT 

-- table variable for holding Init Required Data
DECLARE @tblNewFamiliesThisPeriod TABLE(
	[NumOfFamiliesEnrolledQuarterly] [int],
	[PrenatalEnrollmentQuarterly] [int],
	[PostnatalEnrollmentQuarterly] [int]

)

-- Fill this table i.e. @tblFamiliesEnrolled as below
INSERT INTO @tblNewFamiliesThisPeriod(
	[NumOfFamiliesEnrolledQuarterly],
	[PrenatalEnrollmentQuarterly],
	[PostnatalEnrollmentQuarterly]
)

SELECT 
	count(HVCasePK) AS NumOfFamiliesEnrolledThisPeriod
	,	
	sum(case
		when TCDOB is not null and TCDOB > IntakeDate then 
		   1
		 else
		   0		
	end) as PrenatalEnrollment
	,
	sum(case
		when TCDOB is not null and TCDOB <= IntakeDate THEN
		   1
		 else
		   0
		end) as PostnatalEnrollment	
	
 FROM @tblInitRequiredData
WHERE IntakeDate IS NOT NULL 
AND IntakeDate BETWEEN @sdate AND @edate

Set @TotalNumOfFamiliesEnrolledThisPeriodQuarterly = (SELECT NumOfFamiliesEnrolledQuarterly FROM @tblNewFamiliesThisPeriod)
Set @TotalPrenatalFamiliesQuarterly = (SELECT PrenatalEnrollmentQuarterly FROM @tblNewFamiliesThisPeriod)
Set @TotalPostnatalFamiliesQuarterly = (SELECT PostnatalEnrollmentQuarterly FROM @tblNewFamiliesThisPeriod)

-- Add percentage to the numbers
DECLARE @TotalPrenatalFamiliesQuarterlyPCT VARCHAR(50)
DECLARE @TotalPostnatalFamiliesQuarterlyPCT VARCHAR(50)

-- Avoid divide by zero i.e.
-- Use Coalesce as in example: SELECT COALESCE(dividend / NULLIF(divisor,0), 0) FROM sometable 
-- for every divisor that is zero, you will get a zero in the result set  
-- ... Devinder Singh Khalsa
Set @TotalPrenatalFamiliesQuarterlyPCT = CONVERT(VARCHAR,@TotalPrenatalFamiliesQuarterly) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@TotalPrenatalFamiliesQuarterly AS FLOAT) * 100/ NULLIF(@TotalNumOfFamiliesEnrolledThisPeriodQuarterly,0), 0), 0))  + '%)'
Set @TotalPostnatalFamiliesQuarterlyPCT = CONVERT(VARCHAR,@TotalPostnatalFamiliesQuarterly) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@TotalPostnatalFamiliesQuarterly AS FLOAT) * 100/ NULLIF(@TotalNumOfFamiliesEnrolledThisPeriodQuarterly,0), 0), 0))  + '%)'


-- Part 2a: New families Prenatal v/s Postnatal at intake
-- ContractPeriod figures

IF (@CustomQuarterlyDates = 0)
	BEGIN 
			DECLARE @TotalNumOfFamiliesEnrolledThisPeriodContractPeriod INT 
			DECLARE @TotalPrenatalFamiliesContractPeriod INT 
			DECLARE @TotalPostnatalFamiliesContractPeriod INT 

			-- table variable for holding Init Required Data
			DECLARE @tblNewFamiliesThisPeriodContractPeriod TABLE(
				[NumOfFamiliesEnrolledContractPeriod] [int],
				[PrenatalEnrollmentContractPeriod] [int],
				[PostnatalEnrollmentContractPeriod] [int]

			)

			-- Fill this table i.e. @tblFamiliesEnrolled as below
			INSERT INTO @tblNewFamiliesThisPeriodContractPeriod(
				[NumOfFamiliesEnrolledContractPeriod],
				[PrenatalEnrollmentContractPeriod],
				[PostnatalEnrollmentContractPeriod]
			)

			SELECT 
				count(HVCasePK) AS NumOfFamiliesEnrolledThisPeriod
				,	
				sum(case
					when TCDOB is not null and TCDOB > IntakeDate then 
					   1
					 else
					   0		
				end) as PrenatalEnrollment
				,
				sum(case
					when TCDOB is not null and TCDOB <= IntakeDate THEN
					   1
					 else
					   0
					end) as PostnatalEnrollment	
				
			 FROM @tblInitRequiredData
			WHERE IntakeDate IS NOT NULL 
			AND IntakeDate BETWEEN @ContractStartDate AND @edate  -- make a note of @ContractStartDate field

			Set @TotalNumOfFamiliesEnrolledThisPeriodContractPeriod = (SELECT NumOfFamiliesEnrolledContractPeriod FROM @tblNewFamiliesThisPeriodContractPeriod)
			Set @TotalPrenatalFamiliesContractPeriod = (SELECT PrenatalEnrollmentContractPeriod FROM @tblNewFamiliesThisPeriodContractPeriod)
			Set @TotalPostnatalFamiliesContractPeriod = (SELECT PostnatalEnrollmentContractPeriod FROM @tblNewFamiliesThisPeriodContractPeriod)

			-- Add percentage to the numbers
			DECLARE @TotalPrenatalFamiliesContractPeriodPCT VARCHAR(50)
			DECLARE @TotalPostnatalFamiliesContractPeriodPCT VARCHAR(50)

			-- Avoid divide by zero i.e.
			-- Use Coalesce as in example: SELECT COALESCE(dividend / NULLIF(divisor,0), 0) FROM sometable 
			-- for every divisor that is zero, you will get a zero in the result set  
			-- ... Devinder Singh Khalsa
			Set @TotalPrenatalFamiliesContractPeriodPCT = CONVERT(VARCHAR,@TotalPrenatalFamiliesContractPeriod) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@TotalPrenatalFamiliesContractPeriod AS FLOAT) * 100/ NULLIF(@TotalNumOfFamiliesEnrolledThisPeriodContractPeriod,0), 0), 0))  + '%)'
			Set @TotalPostnatalFamiliesContractPeriodPCT = CONVERT(VARCHAR,@TotalPostnatalFamiliesContractPeriod) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@TotalPostnatalFamiliesContractPeriod AS FLOAT) * 100/ NULLIF(@TotalNumOfFamiliesEnrolledThisPeriodContractPeriod,0), 0), 0))  + '%)'
	END
	
--- **************************************** ---

--- **************************************** ---
-- Part 3: Families discharged this period Quarterly
DECLARE @TotalNumOfFamiliesDischargedThisPeriodQuarterly INT 
DECLARE @TotalFamiliesCompletedProgramQuarterly INT 
DECLARE @TotalFamiliesNOTCompletedProgramQuarterly INT 

-- table variable for holding Init Required Data
DECLARE @tblNewFamiliesDischargedThisPeriodQuarterly TABLE(
	[NumOfFamiliesDischargedThisPeriodQuarterly] [int],
	[FamiliesCompletedProgramQuarterly] [int],
	[FamiliesNOTCompletedProgramQuarterly] [int]

)

-- Fill this table i.e. @tblFamiliesEnrolled as below
INSERT INTO @tblNewFamiliesDischargedThisPeriodQuarterly(
	[NumOfFamiliesDischargedThisPeriodQuarterly],
	[FamiliesCompletedProgramQuarterly],
	[FamiliesNOTCompletedProgramQuarterly]
)

SELECT 
	count(HVCasePK) AS NumOfFamiliesDischargedThisPeriod
	,	
	sum(case
		when DischargeDate is not null and DischargeReason IN (27,29) then 
		   1
		 else
		   0		
	end) as NumOfFamiliesCompletedProgram
	,
	sum(case
		when DischargeDate is not null and DischargeReason NOT IN (27,29) then 
		   1
		 else
		   0	
	end) as NumOfFamiliesNOTCompletedProgram
	
 FROM @tblInitRequiredData
WHERE IntakeDate IS NOT NULL 
AND DischargeDate BETWEEN @sdate AND @edate

Set @TotalNumOfFamiliesDischargedThisPeriodQuarterly = (SELECT NumOfFamiliesDischargedThisPeriodQuarterly FROM @tblNewFamiliesDischargedThisPeriodQuarterly)
Set @TotalFamiliesCompletedProgramQuarterly = (SELECT FamiliesCompletedProgramQuarterly FROM @tblNewFamiliesDischargedThisPeriodQuarterly)
Set @TotalFamiliesNOTCompletedProgramQuarterly = (SELECT FamiliesNOTCompletedProgramQuarterly FROM @tblNewFamiliesDischargedThisPeriodQuarterly)

--SELECT @TotalFamiliesCompletedProgramQuarterly, @TotalFamiliesNOTCompletedProgramQuarterly

-- Add percentage to the numbers
DECLARE @TotalFamiliesCompletedProgramQuarterlyPCT VARCHAR(50)
DECLARE @TotalFamiliesNOTCompletedProgramQuarterlyPCT VARCHAR(50)

-- Avoid divide by zero i.e.
-- Use Coalesce as in example: SELECT COALESCE(dividend / NULLIF(divisor,0), 0) FROM sometable 
-- for every divisor that is zero, you will get a zero in the result set  
-- ... Devinder Singh Khalsa
Set @TotalFamiliesCompletedProgramQuarterlyPCT = CONVERT(VARCHAR,@TotalFamiliesCompletedProgramQuarterly) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@TotalFamiliesCompletedProgramQuarterly AS FLOAT) * 100/ NULLIF(@TotalNumOfFamiliesDischargedThisPeriodQuarterly,0), 0), 0))  + '%)'
Set @TotalFamiliesNOTCompletedProgramQuarterlyPCT = CONVERT(VARCHAR,@TotalFamiliesNOTCompletedProgramQuarterly) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@TotalFamiliesNOTCompletedProgramQuarterly AS FLOAT) * 100/ NULLIF(@TotalNumOfFamiliesDischargedThisPeriodQuarterly,0), 0), 0))  + '%)'


--- **************************************** ---
-- Part 3: Families discharged during contract period

IF (@CustomQuarterlyDates = 0)
	BEGIN 
			DECLARE @TotalNumOfFamiliesDischargedContractPeriod INT 
			DECLARE @TotalFamiliesCompletedProgramContractPeriod INT 
			DECLARE @TotalFamiliesNOTCompletedProgramContractPeriod INT 


			DECLARE @tblNewFamiliesDischargedContractPeriod TABLE(
				[NumOfFamiliesDischargedContractPeriod] [int],
				[FamiliesCompletedProgramContractPeriod] [int],
				[FamiliesNOTCompletedProgramContractPeriod] [int]

			)


			INSERT INTO @tblNewFamiliesDischargedContractPeriod(
				[NumOfFamiliesDischargedContractPeriod],
				[FamiliesCompletedProgramContractPeriod],
				[FamiliesNOTCompletedProgramContractPeriod]
			)

			SELECT 
				count(HVCasePK) AS NumOfFamiliesDischargedThisPeriod
				,	
				sum(case
					when DischargeDate is not null and DischargeReason IN (27,29) then 
					   1
					 else
					   0		
				end) as NumOfFamiliesCompletedProgram
				,
				sum(case
					when DischargeDate is not null and DischargeReason NOT IN (27,29) then 
					   1
					 else
					   0	
				end) as NumOfFamiliesNOTCompletedProgram
				
			 FROM @tblInitRequiredData
			WHERE IntakeDate IS NOT NULL 
			AND DischargeDate BETWEEN @ContractStartDate AND @edate  -- note we have repalce @sdate with @ContractStartDate

			Set @TotalNumOfFamiliesDischargedContractPeriod = (SELECT NumOfFamiliesDischargedContractPeriod FROM @tblNewFamiliesDischargedContractPeriod)
			Set @TotalFamiliesCompletedProgramContractPeriod = (SELECT FamiliesCompletedProgramContractPeriod FROM @tblNewFamiliesDischargedContractPeriod)
			Set @TotalFamiliesNOTCompletedProgramContractPeriod = (SELECT FamiliesNOTCompletedProgramContractPeriod FROM @tblNewFamiliesDischargedContractPeriod)

			--SELECT @TotalFamiliesCompletedProgramQuarterly, @TotalFamiliesNOTCompletedProgramQuarterly

			-- Add percentage to the numbers
			DECLARE @TotalFamiliesCompletedProgramContractPeriodPCT VARCHAR(50)
			DECLARE @TotalFamiliesNOTCompletedProgramContractPeriodPCT VARCHAR(50)

			-- Avoid divide by zero i.e.
			-- Use Coalesce as in example: SELECT COALESCE(dividend / NULLIF(divisor,0), 0) FROM sometable 
			-- for every divisor that is zero, you will get a zero in the result set  
			-- ... Devinder Singh Khalsa
			Set @TotalFamiliesCompletedProgramContractPeriodPCT = CONVERT(VARCHAR,@TotalFamiliesCompletedProgramContractPeriod) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@TotalFamiliesCompletedProgramContractPeriod AS FLOAT) * 100/ NULLIF(@TotalNumOfFamiliesDischargedContractPeriod,0), 0), 0))  + '%)'
			Set @TotalFamiliesNOTCompletedProgramContractPeriodPCT = CONVERT(VARCHAR,@TotalFamiliesNOTCompletedProgramContractPeriod) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@TotalFamiliesNOTCompletedProgramContractPeriod AS FLOAT) * 100/ NULLIF(@TotalNumOfFamiliesDischargedContractPeriod,0), 0), 0))  + '%)'
	END 


--- **************************************** ---
--- **************************************** ---
-- Part 4: Families discharged detail reports follow

-- Quartery detail report
DECLARE @countFamilyDischarged INT

-- Idea: Create two tables, one for each i.e. Quarterly and ContractPeriod
-- and then join them together to get 3 required columns, we are interested in

-- table for Quarterly
declare @tblFamilyDischargedQuarterly table (
 DischargeReasonText varchar(500) NULL 
,NumberOfFamiliesQTRLY varchar(50) NULL 
)

-- table for ContractPeriod
-- CP = Contract Period
declare @tblFamilyDischargedCP table (
 DischargeReasonText varchar(500) NULL 
,NumberOfFamiliesCP varchar(50) NULL 
)


declare @tblFamilyDischarged table (
 DischargeReasonText varchar(500) NULL 
,NumberOfFamilies INT
)
;

	WITH cteCodeDischarge
	AS
	(		
				
				SELECT 	d.DischargeReason,d.DischargeCode FROM codeDischarge d  				
						WHERE DischargeUsedWhere LIKE '%DS%'	
	)	
	,

	cteMain 
			as (			
				
				SELECT 
					DischargeReason
					,
					case
						when DischargeDate is not null then 
						   1
						 else
						   0		
					end as NumOfFamiliesCompletedProgramOrNot

					
				 FROM @tblInitRequiredData
				WHERE IntakeDate IS NOT NULL 
				AND DischargeDate BETWEEN @sDate AND @edate	
				--AND DischargeDate BETWEEN @ContractStartDate AND @edate				
			
			)
			
	INSERT INTO @tblFamilyDischarged		
				SELECT cd.DischargeReason
				,isnull(cm.NumOfFamiliesCompletedProgramOrNot,0) AS NumOfFamiliesCompletedProgramOrNot				
				 FROM cteCodeDischarge cd
				LEFT JOIN cteMain cm ON cd.DischargeCode = cm.DischargeReason



--calculate the totals that will we use to caclualte percentages
Set @countFamilyDischarged = (SELECT sum(NumberOfFamilies) FROM @tblFamilyDischarged )		

INSERT INTO @tblFamilyDischargedQuarterly			
SELECT DischargeReasonText
 ,CONVERT(VARCHAR,sum(NumberOfFamilies)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(sum(NumberOfFamilies) AS FLOAT) * 100/ NULLIF(@countFamilyDischarged,0), 0), 0))  + '%)' AS TotalFamilyDischarged
 FROM @tblFamilyDischarged	
GROUP BY DischargeReasonText


-- *********************************
-- Contract Period detail report

IF (@CustomQuarterlyDates = 0)
	BEGIN 

			DECLARE @countFamilyDischargedContractPeriod INT

			declare @tblFamilyDischargedContractPeriod table (
			 DischargeReasonText varchar(500) NULL 
			,NumberOfFamilies INT
			)
			;

				WITH cteCodeDischargeContractPeriod
				AS
				(		
							
							SELECT 	d.DischargeReason,d.DischargeCode FROM codeDischarge d  				
									WHERE DischargeUsedWhere LIKE '%DS%'	
				)	
				,

				cteMainContractPeriod 
						as (			
							
							SELECT 
								DischargeReason
								,
								case
									when DischargeDate is not null then 
									   1
									 else
									   0		
								end as NumOfFamiliesCompletedProgramOrNot

								
							 FROM @tblInitRequiredData
							WHERE IntakeDate IS NOT NULL 				
							AND DischargeDate BETWEEN @ContractStartDate AND @edate				
						
						)
						
				INSERT INTO @tblFamilyDischargedContractPeriod		
							SELECT cd.DischargeReason
							,isnull(cm.NumOfFamiliesCompletedProgramOrNot,0) AS NumOfFamiliesCompletedProgramOrNot				
							 FROM cteCodeDischargeContractPeriod cd
							LEFT JOIN cteMainContractPeriod cm ON cd.DischargeCode = cm.DischargeReason
									
						



			--INSERT INTO @tblFamilyDischarged SELECT DischargeReason, codeDischargePK FROM cteFamilyDischarged

			--calculate the totals that will we use to caclualte percentages
			Set @countFamilyDischargedContractPeriod = (SELECT sum(NumberOfFamilies) FROM @tblFamilyDischargedContractPeriod )		

			INSERT INTO @tblFamilyDischargedCP				
			SELECT DischargeReasonText
			 ,CONVERT(VARCHAR,sum(NumberOfFamilies)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(sum(NumberOfFamilies) AS FLOAT) * 100/ NULLIF(@countFamilyDischargedContractPeriod,0), 0), 0))  + '%)' AS TotalFamilyDischargedContractPeriod
			 FROM @tblFamilyDischargedContractPeriod	
			GROUP BY DischargeReasonText

	END 
	
	
--- **************************************** ---
--- **************************************** ---
-- End Of Part 4: Families discharged detail reports follow
--- **************************************** ---
--- **************************************** ---




DECLARE @tblEnrolledProgramCaseload TABLE(
	[CaseLoadText] VARCHAR(500),
	[CaseLoadQuarterlyData] VARCHAR(50),
	[CaseLoadContractPeriodData] VARCHAR(50)
)

IF (@CustomQuarterlyDates = 0)
	BEGIN 

			INSERT INTO @tblEnrolledProgramCaseload([CaseLoadText],[CaseLoadQuarterlyData],[CaseLoadContractPeriodData])VALUES('1. Families Active at the beginning of period', @TotalNumberOfFamiliesEnrolledQuarterly, @NumberOfFamiliesEnrolled4ContractPeriod)
			INSERT INTO @tblEnrolledProgramCaseload([CaseLoadText],[CaseLoadQuarterlyData],[CaseLoadContractPeriodData])VALUES('	a. Target Children', @TotalTCNumberQuarterly, @TCNumber4ContractPeriod)

			INSERT INTO @tblEnrolledProgramCaseload([CaseLoadText],[CaseLoadQuarterlyData],[CaseLoadContractPeriodData])VALUES('','', '') --insert empty row

			INSERT INTO @tblEnrolledProgramCaseload([CaseLoadText],[CaseLoadQuarterlyData],[CaseLoadContractPeriodData])VALUES('2. New Families enrolled in the Home Visiting program this period', @TotalNumOfFamiliesEnrolledThisPeriodQuarterly, @TotalNumOfFamiliesEnrolledThisPeriodContractPeriod)
			INSERT INTO @tblEnrolledProgramCaseload([CaseLoadText],[CaseLoadQuarterlyData],[CaseLoadContractPeriodData])VALUES('	a. Prenatal at intake', @TotalPrenatalFamiliesQuarterlyPCT, @TotalPrenatalFamiliesContractPeriodPCT)
			INSERT INTO @tblEnrolledProgramCaseload([CaseLoadText],[CaseLoadQuarterlyData],[CaseLoadContractPeriodData])VALUES('	b. Postnatal at intake', @TotalPostnatalFamiliesQuarterlyPCT, @TotalPostnatalFamiliesContractPeriodPCT)

			INSERT INTO @tblEnrolledProgramCaseload([CaseLoadText],[CaseLoadQuarterlyData],[CaseLoadContractPeriodData])VALUES('','', '') --insert empty row

			INSERT INTO @tblEnrolledProgramCaseload([CaseLoadText],[CaseLoadQuarterlyData],[CaseLoadContractPeriodData])VALUES('3. Families Discharged this period', @TotalNumOfFamiliesDischargedThisPeriodQuarterly, @TotalNumOfFamiliesDischargedContractPeriod)
			INSERT INTO @tblEnrolledProgramCaseload([CaseLoadText],[CaseLoadQuarterlyData],[CaseLoadContractPeriodData])VALUES('	a. Completed Program', @TotalFamiliesCompletedProgramQuarterlyPCT, @TotalFamiliesCompletedProgramContractPeriodPCT)
			INSERT INTO @tblEnrolledProgramCaseload([CaseLoadText],[CaseLoadQuarterlyData],[CaseLoadContractPeriodData])VALUES('	b. Did not Complete Program', @TotalFamiliesNOTCompletedProgramQuarterlyPCT, @TotalFamiliesNOTCompletedProgramContractPeriodPCT)

			INSERT INTO @tblEnrolledProgramCaseload([CaseLoadText],[CaseLoadQuarterlyData],[CaseLoadContractPeriodData])VALUES('','', '') --insert empty row


			-- insert Part4 - Family discharged reasons
			INSERT INTO @tblEnrolledProgramCaseload
			SELECT tblQ.DischargeReasonText, tblQ.NumberOfFamiliesQTRLY, tblCP.NumberOfFamiliesCP  FROM @tblFamilyDischargedQuarterly tblQ
			INNER JOIN @tblFamilyDischargedCP tblCP ON tblQ.DischargeReasonText = tblCP.DischargeReasonText

			INSERT INTO @tblEnrolledProgramCaseload([CaseLoadText],[CaseLoadQuarterlyData],[CaseLoadContractPeriodData])VALUES('','', '') --insert empty row

			-- Calculate totals (last row)
			INSERT INTO @tblEnrolledProgramCaseload([CaseLoadText],[CaseLoadQuarterlyData],[CaseLoadContractPeriodData])VALUES('Families enrolled at the end of period',
			@TotalNumberOfFamiliesEnrolledQuarterly + @TotalNumOfFamiliesEnrolledThisPeriodQuarterly - @TotalNumOfFamiliesDischargedThisPeriodQuarterly,
			 @NumberOfFamiliesEnrolled4ContractPeriod + @TotalNumOfFamiliesEnrolledThisPeriodContractPeriod - @TotalNumOfFamiliesDischargedContractPeriod) 
	END 
	ELSE 
	BEGIN 
			INSERT INTO @tblEnrolledProgramCaseload([CaseLoadText],[CaseLoadQuarterlyData],[CaseLoadContractPeriodData])VALUES('1. Families Active at the beginning of period', @TotalNumberOfFamiliesEnrolledQuarterly, '')
			INSERT INTO @tblEnrolledProgramCaseload([CaseLoadText],[CaseLoadQuarterlyData],[CaseLoadContractPeriodData])VALUES('	a. Target Children', @TotalTCNumberQuarterly, '')

			INSERT INTO @tblEnrolledProgramCaseload([CaseLoadText],[CaseLoadQuarterlyData],[CaseLoadContractPeriodData])VALUES('','', '') --insert empty row

			INSERT INTO @tblEnrolledProgramCaseload([CaseLoadText],[CaseLoadQuarterlyData],[CaseLoadContractPeriodData])VALUES('2. New Families enrolled in the Home Visiting program this period', @TotalNumOfFamiliesEnrolledThisPeriodQuarterly,  '')
			INSERT INTO @tblEnrolledProgramCaseload([CaseLoadText],[CaseLoadQuarterlyData],[CaseLoadContractPeriodData])VALUES('	a. Prenatal at intake', @TotalPrenatalFamiliesQuarterlyPCT,  '')
			INSERT INTO @tblEnrolledProgramCaseload([CaseLoadText],[CaseLoadQuarterlyData],[CaseLoadContractPeriodData])VALUES('	b. Postnatal at intake', @TotalPostnatalFamiliesQuarterlyPCT,  '')

			INSERT INTO @tblEnrolledProgramCaseload([CaseLoadText],[CaseLoadQuarterlyData],[CaseLoadContractPeriodData])VALUES('','', '') --insert empty row

			INSERT INTO @tblEnrolledProgramCaseload([CaseLoadText],[CaseLoadQuarterlyData],[CaseLoadContractPeriodData])VALUES('3. Families Discharged this period', @TotalNumOfFamiliesDischargedThisPeriodQuarterly,  '')
			INSERT INTO @tblEnrolledProgramCaseload([CaseLoadText],[CaseLoadQuarterlyData],[CaseLoadContractPeriodData])VALUES('	a. Completed Program', @TotalFamiliesCompletedProgramQuarterlyPCT,  '')
			INSERT INTO @tblEnrolledProgramCaseload([CaseLoadText],[CaseLoadQuarterlyData],[CaseLoadContractPeriodData])VALUES('	b. Did not Complete Program', @TotalFamiliesNOTCompletedProgramQuarterlyPCT,  '')

			INSERT INTO @tblEnrolledProgramCaseload([CaseLoadText],[CaseLoadQuarterlyData],[CaseLoadContractPeriodData])VALUES('','', '') --insert empty row


			-- insert Part4 - Family discharged reasons (only interested in quarterly, ignore contractperiod because user pick up custom dates for quarters)
			INSERT INTO @tblEnrolledProgramCaseload
			SELECT tblQ.DischargeReasonText, tblQ.NumberOfFamiliesQTRLY,''  FROM @tblFamilyDischargedQuarterly tblQ

			INSERT INTO @tblEnrolledProgramCaseload([CaseLoadText],[CaseLoadQuarterlyData],[CaseLoadContractPeriodData])VALUES('','', '') --insert empty row

			-- Calculate totals (last row)
			INSERT INTO @tblEnrolledProgramCaseload([CaseLoadText],[CaseLoadQuarterlyData],[CaseLoadContractPeriodData])VALUES('Families enrolled at the end of period',
			@TotalNumberOfFamiliesEnrolledQuarterly + @TotalNumOfFamiliesEnrolledThisPeriodQuarterly - @TotalNumOfFamiliesDischargedThisPeriodQuarterly, '') 
	
	
	
	
	END 

	SELECT * FROM @tblEnrolledProgramCaseload
	
END
GO
