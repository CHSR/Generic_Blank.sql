SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Stored Procedure

-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <July 16th, 2012>
-- Description:	<gets you data for Pre-Intake Engagement Quarterly and Contract Period>
-- exec [rspPreIntakeEngagement_bak20140602] ',1,','09/01/2010','11/30/2010',null,0
-- exec [rspPreIntakeEngagement_bak20140602] ',1,','09/01/2010','11/30/2010',null,1
-- exec [rspPreIntakeEngagement_bak20140602] ',2,','04/01/2013' , '06/30/2013',null,0


-- exec [rspPreIntakeEngagement_bak20140602] ',14,','10/01/2013' , '12/31/2013',null,0
-- exec [rspPreIntakeEngagement_bak20140602] ',8,','10/01/2013' , '12/31/2013',null,0

-- exec [rspPreIntakeEngagement_bak20140602] ',16,','09/01/2013' , '5/31/2014',null,0

-- =============================================
CREATE procedure [dbo].[rspPreIntakeEngagement_bak20140602](@programfk    varchar(max)    = null,
                                                        @sdate        datetime,
                                                        @edate        datetime,                                                        
                                                        @sitefk int             = NULL,
                                                        @CustomQuarterlyDates bit                                                         
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

--SELECT @ContractStartDate, @ContractEndDate

-- Let us declare few table variables so that we can manipulate the rows at our will
-- Note: Table variables are a superior alternative to using temporary tables 

---------------------------------------------
-- Initially, get the subset of data that we are interested in ... Good Practice ... Khalsa 
-- table variable for holding Init Required Data
DECLARE @tblInitRequiredData TABLE(
	[HVCasePK] [int],
	[IntakeDate] [datetime],
	[TCDOB] [datetime],
	[DischargeDate] [datetime],
	[DischargeReason] [char](2),
	[KempeDate] [datetime],
	[KempeResult] [BIT],
	[CaseStartDate] [datetime],	
	[MomScore] INT,
	[DadScore] INT,				
	[SiteFK] [int],
	[ProgramFK][int]

)


DECLARE @tblInitRequiredDataTemp TABLE(
	[HVCasePK] [int],
	[IntakeDate] [datetime],
	[TCDOB] [datetime],
	[DischargeDate] [datetime],
	[DischargeReason] [char](2),
	[KempeDate] [datetime],
	[KempeResult] [BIT],
	[CaseStartDate] [datetime],	
	[MomScore] INT,
	[DadScore] INT,	
	[SiteFK] [int],
	[ProgramFK][int]
)

-- Fill this table i.e. @tblInitRequiredData as below
INSERT INTO @tblInitRequiredDataTemp(
	[HVCasePK],
	[IntakeDate],
	[TCDOB],
	[DischargeDate],
	[DischargeReason],
	[KempeDate],
	[KempeResult],
	[CaseStartDate],
	[MomScore],
	[DadScore],			
	[SiteFK],
	[ProgramFK]
)
SELECT 
h.HVCasePK,h.IntakeDate,

case
   when h.tcdob is not null then
	   h.tcdob
   else
	   h.edc
end as tcdob
,cp.DischargeDate, cp.DischargeReason,k.KempeDate,k.KempeResult,cp.CaseStartDate
,case when MomScore = 'U' then 0 else cast(MomScore as int) end as MomScore
,case when DadScore = 'U' then 0 else cast(DadScore as int) end as DadScore
,CASE WHEN wp.SiteFK IS NULL THEN 0 ELSE wp.SiteFK END AS SiteFK
,cp.programfk
FROM HVCase h 
INNER JOIN Kempe k ON k.HVCaseFK = h.HVCasePK
INNER JOIN CaseProgram cp ON h.HVCasePK = cp.HVCaseFK 
left JOIN Worker w ON w.WorkerPK = cp.CurrentFSWFK
left JOIN WorkerProgram wp ON wp.WorkerFK = w.WorkerPK -- get SiteFK
inner join dbo.SplitString(@programfk,',') on cp.programfk = listitem

-- SiteFK = isnull(@sitefk,SiteFK) does not work because column SiteFK may be null itself 
-- so to solve this problem we make use of @tblInitRequiredDataTemp
INSERT INTO @tblInitRequiredData( 
	[HVCasePK],
	[IntakeDate],
	[TCDOB],
	[DischargeDate],
	[DischargeReason],
	[KempeDate],
	[KempeResult],
	[CaseStartDate],
	[MomScore],
	[DadScore],						
	[SiteFK],
	[ProgramFK])
SELECT * FROM @tblInitRequiredDataTemp
WHERE SiteFK = isnull(@sitefk,SiteFK)


---------------------------------------------

---------------------------------------------
--- **************************************** ---
-- Part #1:Pre-Intake Cases at the beginning of the period	(QUARTERLY STATS)

DECLARE @TotalNumberOfPreIntakeCasesQuarterly INT 

SET @TotalNumberOfPreIntakeCasesQuarterly = 
(
SELECT count(DISTINCT irq.HVCasePK)
FROM @tblInitRequiredData irq
INNER JOIN Preassessment p ON irq.HVCasePK = p.HVCaseFK AND p.ProgramFK = irq.ProgramFK 
WHERE 
CaseStartDate <= @edate
AND p.FSWAssignDate <= @sdate 
AND p.CaseStatus = '02'
AND irq.KempeResult = '1'
AND (IntakeDate IS NULL OR IntakeDate >= @sdate)
AND (DischargeDate IS NULL OR DischargeDate >= @sdate)	
)

-- Part #1:Pre-Intake Cases at the beginning of the period	(Contract Period STATS)
IF (@CustomQuarterlyDates = 0)
	BEGIN 
		DECLARE @TotalNumberOfPreIntakeCasesContractPeriod INT 

		SET @TotalNumberOfPreIntakeCasesContractPeriod = 
		(
		SELECT count(DISTINCT irq.HVCasePK)
		FROM @tblInitRequiredData irq
		INNER JOIN Preassessment p ON irq.HVCasePK = p.HVCaseFK AND p.ProgramFK = irq.ProgramFK
		WHERE 
		CaseStartDate <= @edate
		AND p.FSWAssignDate <= @ContractStartDate 
		AND p.CaseStatus = '02'
		AND irq.KempeResult = '1'
		AND (IntakeDate IS NULL OR IntakeDate >= @ContractStartDate)
		AND (DischargeDate IS NULL OR DischargeDate >= @ContractStartDate)	
		)

END 
--SELECT @TotalNumberOfPreIntakeCasesQuarterly, @TotalNumberOfPreIntakeCasesContractPeriod

-- exec [rspPreIntakeEngagement_bak20140602] ',16,','09/01/2013' , '5/31/2014',null,0

	select @ContractStartDate , @TotalNumberOfPreIntakeCasesContractPeriod


		SELECT DISTINCT irq.HVCasePK
		FROM @tblInitRequiredData irq
		INNER JOIN Preassessment p ON irq.HVCasePK = p.HVCaseFK AND p.ProgramFK = irq.ProgramFK
		WHERE 
		CaseStartDate <= @edate
		AND p.FSWAssignDate <= @ContractStartDate 
		AND p.CaseStatus = '02'
		AND irq.KempeResult = '1'
		AND (IntakeDate IS NULL OR IntakeDate >= @ContractStartDate)
		AND (DischargeDate IS NULL OR DischargeDate >= @ContractStartDate)	
		order by irq.HVCasePK 
		






---------------------------------------------

--- **************************************** ---
--  #2---Kempes this period== Kempes this quarter or by dates

DECLARE @TotalNumberOfKempesThisPeriodQuarterly INT 
DECLARE @nQ2a INT 
DECLARE @nQ2b INT 
DECLARE @nQ2c INT 
DECLARE @nQ2d INT 
DECLARE @nQ2e INT 
DECLARE @nQ2f INT 
DECLARE @nQ2g INT 
DECLARE @nQ2h INT 
DECLARE @nQ2i INT 
DECLARE @nQ2j INT 




SET @TotalNumberOfKempesThisPeriodQuarterly = 
(
	SELECT count(irq.HVCasePK)
	FROM @tblInitRequiredData irq
	--INNER JOIN Preassessment p ON irq.HVCasePK = p.HVCaseFK
	WHERE 
	irq.KempeDate BETWEEN @sDate AND @edate
	--AND p.CaseStatus = '02'

)

SET @nQ2a = 
(
	SELECT count(irq.HVCasePK)
	FROM @tblInitRequiredData irq
	INNER JOIN Preassessment p ON irq.HVCasePK = p.HVCaseFK
	WHERE 
	irq.KempeDate BETWEEN @sDate AND @edate
	AND p.CaseStatus = '02'
	AND	(p.FSWAssignDate IS NOT NULL AND p.FSWAssignDate <= @eDate)	
	AND irq.KempeResult = '1'

)

-- Positive not assigned to FSW
SET @nQ2b = 
(
	SELECT count(irq.HVCasePK)
	FROM @tblInitRequiredData irq
	INNER JOIN Preassessment p ON irq.HVCasePK = p.HVCaseFK
	WHERE 
	irq.KempeDate BETWEEN @sDate AND @edate
	AND p.CaseStatus = '02'
	AND	(p.FSWAssignDate IS NULL)	
	AND irq.KempeResult = '1'

)

SET @nQ2c = 
(
	SELECT count(irq.HVCasePK)
	FROM @tblInitRequiredData irq
	INNER JOIN Preassessment p ON irq.HVCasePK = p.HVCaseFK
	WHERE 
	irq.KempeDate BETWEEN @sDate AND @edate
	AND p.CaseStatus in ('02','04')
	AND	(p.FSWAssignDate IS NULL Or p.FSWAssignDate > @eDate)		
	AND irq.KempeResult = '1'

)

SET @nQ2d = 
(
	SELECT count(irq.HVCasePK)
	FROM @tblInitRequiredData irq
	INNER JOIN Preassessment p ON irq.HVCasePK = p.HVCaseFK
	WHERE 
	irq.KempeDate BETWEEN @sDate AND @edate
	AND p.CaseStatus = '02'
	--AND	(p.FSWAssignDate IS NOT NULL AND p.FSWAssignDate <= @eDate)	
	AND irq.KempeResult = '0'

)


SET @nQ2e = 
(
	SELECT avg(MomScore)
	FROM @tblInitRequiredData irq
	WHERE 
	irq.KempeDate BETWEEN @sDate AND @edate
)

SET @nQ2f = 
(
	SELECT avg(DadScore)
	FROM @tblInitRequiredData irq
	WHERE 
	irq.KempeDate BETWEEN @sDate AND @edate
)

SET @nQ2g = 
(
	SELECT
			sum(case
			   when (MomScore > 40) then
				   1
				   else
					   0
			   end) as MomScoreOver40

	FROM @tblInitRequiredData irq
	WHERE 
	irq.KempeDate BETWEEN @sDate AND @edate
)

SET @nQ2h = 
(
	SELECT
			sum(case
			   when (DadScore > 40) then
				   1
				   else
					   0
			   end) as DadScoreOver40

	FROM @tblInitRequiredData irq
	WHERE 
	irq.KempeDate BETWEEN @sDate AND @edate

)

SET @nQ2i = 
(
	SELECT
			sum(case
			   when (TCDOB > KempeDate) then
				   1
				   else
					   0
			   end) as Prenatal

	FROM @tblInitRequiredData irq
	WHERE 
	irq.KempeDate BETWEEN @sDate AND @edate

)

SET @nQ2j = 
(
	SELECT
			sum(case
			   when (TCDOB <= KempeDate) then
				   1
				   else
					   0
			   end) as Postnatal

	FROM @tblInitRequiredData irq
	WHERE 
	irq.KempeDate BETWEEN @sDate AND @edate

)


--  #2---Kempes this period - Conttract Period
IF (@CustomQuarterlyDates = 0)
	BEGIN 
		DECLARE @TotalNumberOfKempesContractPeriod INT 
		DECLARE @nQ2CPa INT 
		DECLARE @nQ2CPb INT 
		DECLARE @nQ2CPc INT 
		DECLARE @nQ2CPd INT 
		DECLARE @nQ2CPe INT 
		DECLARE @nQ2CPf INT 
		DECLARE @nQ2CPg INT 
		DECLARE @nQ2CPh INT 
		DECLARE @nQ2CPi INT 
		DECLARE @nQ2CPj INT 


		SET @TotalNumberOfKempesContractPeriod = 
		(
			SELECT count(irq.HVCasePK)
			FROM @tblInitRequiredData irq
			inner join Kempe k on k.HVCaseFK = irq.HVCasePK	
			WHERE 
			k.KempeDate BETWEEN @ContractStartDate AND @edate

		)


		SET @nQ2CPa = 
		(
			SELECT count(irq.HVCasePK)
			FROM @tblInitRequiredData irq
			INNER JOIN Preassessment p ON irq.HVCasePK = p.HVCaseFK
			WHERE 
			irq.KempeDate BETWEEN @ContractStartDate AND @edate
			AND p.CaseStatus = '02'
			AND	(p.FSWAssignDate IS NOT NULL AND p.FSWAssignDate <= @eDate)	
			AND irq.KempeResult = '1'

		)

		-- Positive not assigned to FSW
		SET @nQ2CPb = 
		(
			SELECT count(irq.HVCasePK)
			FROM @tblInitRequiredData irq
			INNER JOIN Preassessment p ON irq.HVCasePK = p.HVCaseFK
			WHERE 
			irq.KempeDate BETWEEN @ContractStartDate AND @edate
			AND p.CaseStatus in ('02','04')
			AND	(p.FSWAssignDate IS NULL)	
			AND irq.KempeResult = '1'

		)

		SET @nQ2CPc = 
		(
			SELECT count(irq.HVCasePK)
			FROM @tblInitRequiredData irq
			INNER JOIN Preassessment p ON irq.HVCasePK = p.HVCaseFK
			WHERE 
			irq.KempeDate BETWEEN @ContractStartDate AND @edate
			AND p.CaseStatus in ('02','04')
			AND	(p.FSWAssignDate IS NULL Or p.FSWAssignDate > @eDate)		
			AND irq.KempeResult = '1'

		)

		SET @nQ2CPd = 
		(
			SELECT count(irq.HVCasePK)
			FROM @tblInitRequiredData irq
			INNER JOIN Preassessment p ON irq.HVCasePK = p.HVCaseFK
			WHERE 
			irq.KempeDate BETWEEN @ContractStartDate AND @edate
			AND p.CaseStatus = '02'
			--AND	(p.FSWAssignDate IS NOT NULL AND p.FSWAssignDate <= @eDate)	
			AND irq.KempeResult = '0'

		)


		SET @nQ2CPe = 
		(
			SELECT avg(MomScore)
			FROM @tblInitRequiredData irq
			WHERE 
			irq.KempeDate BETWEEN @ContractStartDate AND @edate
		)

		SET @nQ2CPf = 
		(
			SELECT avg(DadScore)
			FROM @tblInitRequiredData irq
			WHERE 
			irq.KempeDate BETWEEN @ContractStartDate AND @edate
		)

		SET @nQ2CPg = 
		(
			SELECT
					sum(case
					   when (MomScore > 40) then
						   1
						   else
							   0
					   end) as MomScoreOver40

			FROM @tblInitRequiredData irq
			WHERE 
			irq.KempeDate BETWEEN @ContractStartDate AND @edate
		)

		SET @nQ2CPh = 
		(
			SELECT
					sum(case
					   when (DadScore > 40) then
						   1
						   else
							   0
					   end) as DadScoreOver40

			FROM @tblInitRequiredData irq
			WHERE 
			irq.KempeDate BETWEEN @ContractStartDate AND @edate

		)

		SET @nQ2CPi = 
		(
			SELECT
					sum(case
					   when (TCDOB > KempeDate) then
						   1
						   else
							   0
					   end) as Prenatal

			FROM @tblInitRequiredData irq
			WHERE 
			irq.KempeDate BETWEEN @ContractStartDate AND @edate

		)

		SET @nQ2CPj = 
		(
			SELECT
					sum(case
					   when (TCDOB <= KempeDate) then
						   1
						   else
							   0
					   end) as Postnatal

			FROM @tblInitRequiredData irq
			WHERE 
			irq.KempeDate BETWEEN @ContractStartDate AND @edate

		)


			--SELECT @TotalNumberOfKempesContractPeriod,@nQ2CPa,@nQ2CPb,@nQ2CPc,@nQ2CPd,@nQ2CPe,@nQ2CPf,@nQ2CPg,@nQ2CPh,@nQ2CPi,@nQ2CPj		
	END


-- #3 Previous Kempes ====Quarterly or By Dates
	DECLARE @nQ3 INT 

	SET @nQ3 =
	(
		SELECT count(irq.HVCasePK)
		FROM @tblInitRequiredData irq
		INNER JOIN Preassessment p ON irq.HVCasePK = p.HVCaseFK
		WHERE 
		(irq.KempeDate < @sDate AND irq.KempeDate IS NOT NULL)
		AND	(p.FSWAssignDate IS NOT NULL AND p.FSWAssignDate >= @sDate)	
	)

-- #3 Previous Kempes ==== Contract Period
IF (@CustomQuarterlyDates = 0)
	BEGIN 

		DECLARE @nQCP3 INT 

		SET @nQCP3 =
		(
			SELECT count(irq.HVCasePK)
			FROM @tblInitRequiredData irq
			INNER JOIN Preassessment p ON irq.HVCasePK = p.HVCaseFK
			WHERE 
			(irq.KempeDate < @ContractStartDate AND irq.KempeDate IS NOT NULL)
			AND	(p.FSWAssignDate IS NOT NULL AND p.FSWAssignDate >= @ContractStartDate)	
		)

	END

-- #5 Outcomes -- Quarterlies
	DECLARE @nQ5a INT 
	DECLARE @nQ5b INT 
	DECLARE @nQ5c INT 
	DECLARE @nQ5d INT 

DECLARE @tblEngage TABLE(
	[HVCasePK] [int],
	[PIDate] [datetime]
)

INSERT INTO @tblEngage
(
	[HVCasePK],
	[PIDate]
)
(SELECT HVCaseFK, max(PIDate) [LastPreIntakeDate] 
		FROM @tblInitRequiredData irq
			Left JOIN Preintake p ON HVCasePK = p.HVCaseFK
			WHERE 
			 PIDate BETWEEN @sDate AND @edate
			AND month(PIDate) = month(@edate)
			AND p.CaseStatus = '01'
			AND KempeResult = '1'
			GROUP BY HVCaseFK
)

SET @nQ5a =
(	
		SELECT count(HVCasePK) AS count1
		FROM @tblEngage	

)

SET @nQ5b =
(	
		SELECT count(HVCaseFK)
		FROM @tblInitRequiredData irq
			Left JOIN Preintake p ON HVCasePK = p.HVCaseFK
			WHERE 
			 PIDate BETWEEN @sDate AND @edate
			 AND KempeResult = '1'    	
			AND p.CaseStatus = '02'
)

SET @nQ5c =
(	
		SELECT count(HVCaseFK)
		FROM @tblInitRequiredData irq
			Left JOIN Preintake p ON HVCasePK = p.HVCaseFK
			WHERE 
			 PIDate BETWEEN @sDate AND @edate	
			 AND KempeResult = '1'    
			AND p.CaseStatus = '03'
)

-- Original
-- SET @nQ5d =(@TotalNumberOfPreIntakeCasesQuarterly + @nQ2a + @nQ3) - (@nQ5a + @nQ5b + @nQ5c) 

-- Note: added @nQ2c -  Positive Pending Assignment to FSW
 --SET @nQ5d =(@TotalNumberOfPreIntakeCasesQuarterly + @nQ2a +      @nQ2c      + @nQ3) - (@nQ5a + @nQ5b + @nQ5c) 
 SET @nQ5d =(@TotalNumberOfPreIntakeCasesQuarterly +  @nQ2c      + @nQ3) - (@nQ5a + @nQ5b + @nQ5c) 

-- Note: Taken out @nQ5a - because Data report considers only Enrolled and Terminated
--SET @nQ5d =(@TotalNumberOfPreIntakeCasesQuarterly + @nQ2a + @nQ2c + @nQ3) - ( @nQ5b + @nQ5c) 
--select @TotalNumberOfPreIntakeCasesQuarterly

-- exec [rspPreIntakeEngagement_bak20140602] ',8,','10/01/2013' , '12/31/2013',null,0



-- #5 Outcomes -- Contract Period
IF (@CustomQuarterlyDates = 0)
	BEGIN 

			DECLARE @nQ5CPa INT 
			DECLARE @nQ5CPb INT 
			DECLARE @nQ5CPc INT 
			DECLARE @nQ5CPd INT 

			DECLARE @tblEngageCP TABLE(
				[HVCasePK] [int],
				[PIDate] [datetime]
			)

			INSERT INTO @tblEngageCP
			(
				[HVCasePK],
				[PIDate]
			)
			(SELECT HVCaseFK, max(PIDate) [LastPreIntakeDate] 
					FROM @tblInitRequiredData irq
						Left JOIN Preintake p ON HVCasePK = p.HVCaseFK
						WHERE 
						 PIDate BETWEEN @ContractStartDate AND @edate
						AND month(PIDate) = month(@edate)
						AND p.CaseStatus = '01'
						AND KempeResult = '1'	
						GROUP BY HVCaseFK
			)

			SET @nQ5CPa =
			(	
					SELECT count(HVCasePK) AS count1
					FROM @tblEngage	

			)

			SET @nQ5CPb =
			(	
					SELECT count(HVCaseFK)
					FROM @tblInitRequiredData irq
						Left JOIN Preintake p ON HVCasePK = p.HVCaseFK
						WHERE 
						 PIDate BETWEEN @ContractStartDate AND @edate
						 AND KempeResult = '1'    		
						AND p.CaseStatus = '02'
			)


			SET @nQ5CPc =
			(	
					SELECT count(HVCaseFK)
					FROM @tblInitRequiredData irq
						Left JOIN Preintake p ON HVCasePK = p.HVCaseFK
						WHERE 
						 PIDate BETWEEN @ContractStartDate AND @edate
						 AND KempeResult = '1'    		
						AND p.CaseStatus = '03'
			)

			SET @nQ5CPd =(@TotalNumberOfPreIntakeCasesContractPeriod +  @nQ2CPc + @nQCP3) - (@nQ5CPa + @nQ5CPb + @nQ5CPc) 
			--SET @nQ5CPd =(@TotalNumberOfPreIntakeCasesContractPeriod + @nQ2CPa + @nQ2CPc + @nQCP3) - (@nQ5CPa + @nQ5CPb + @nQ5CPc) 



END



-- #6 Activities for Period - Quarterly
DECLARE @tblnQ6Q TABLE(
 nQ6a [INT] 
,nQ6b [INT] 
,nQ6c [INT] 
,nQ6d [INT] 
,nQ6e [INT] 
,nQ6f [INT] 
,nQ6g [INT] 
,nQ6h [INT] 
,nQ6i [INT] 
,nQ6j [INT] 
,nQ6k [INT] 
)
INSERT INTO @tblnQ6Q
(
 nQ6a
,nQ6b
,nQ6c
,nQ6d
,nQ6e
,nQ6f
,nQ6g
,nQ6h
,nQ6i
,nQ6j
,nQ6k
)
(SELECT 
sum(PIParentLetter) AS nQ6a
,sum(PICall2Parent) AS nQ6b
,sum(PICallFromParent) AS nQ6c
,sum(PIVisitAttempt) AS nQ6d
,sum(PIVisitMade) AS nQ6e
,sum(PIOtherHVProgram) AS nQ6f
,sum(PIParent2Office) AS nQ6g
,sum(PIProgramMaterial) AS nQ6h
,sum(PIGift) AS nQ6i
,sum(PICaseReview) AS nQ6j
,sum(PIOtherActivity) AS nQ6k	

FROM @tblInitRequiredData irq
	Left JOIN Preintake p ON HVCasePK = p.HVCaseFK
	WHERE 
	 PIDate BETWEEN @sDate AND @edate
)

-- #6 Activities for Period - Contract Period
IF (@CustomQuarterlyDates = 0)
	BEGIN 

		DECLARE @tblnQ6CP TABLE(
		 nQ6CPa [INT] 
		,nQ6CPb [INT] 
		,nQ6CPc [INT] 
		,nQ6CPd [INT] 
		,nQ6CPe [INT] 
		,nQ6CPf [INT] 
		,nQ6CPg [INT] 
		,nQ6CPh [INT] 
		,nQ6CPi [INT] 
		,nQ6CPj [INT] 
		,nQ6CPk [INT] 
		)

		INSERT INTO @tblnQ6CP
		(
		 nQ6CPa
		,nQ6CPb
		,nQ6CPc
		,nQ6CPd
		,nQ6CPe
		,nQ6CPf
		,nQ6CPg
		,nQ6CPh
		,nQ6CPi
		,nQ6CPj
		,nQ6CPk
		)
		(SELECT 
		sum(PIParentLetter) AS nQ6CPa
		,sum(PICall2Parent) AS nQ6CPb
		,sum(PICallFromParent) AS nQ6CPc
		,sum(PIVisitAttempt) AS nQ6CPd
		,sum(PIVisitMade) AS nQ6CPe
		,sum(PIOtherHVProgram) AS nQ6CPf
		,sum(PIParent2Office) AS nQ6CPg
		,sum(PIProgramMaterial) AS nQ6CPh
		,sum(PIGift) AS nQ6CPi
		,sum(PICaseReview) AS nQ6CPj
		,sum(PIOtherActivity) AS nQ6CPk	

		FROM @tblInitRequiredData irq
			Left JOIN Preintake p ON HVCasePK = p.HVCaseFK
			WHERE 
			 PIDate BETWEEN @ContractStartDate AND @edate	 
		)			
END



DECLARE @tblMainResult TABLE(
	[Text] VARCHAR(500),
	[QuarterlyData] VARCHAR(50),
	[ContractPeriodData] VARCHAR(50)
)

IF (@CustomQuarterlyDates = 0)
	BEGIN 

			-- Q1
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('1. Pre-Intake Cases at the beginning of period', @TotalNumberOfPreIntakeCasesQuarterly, @TotalNumberOfPreIntakeCasesContractPeriod)
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('','', '') --insert empty row

			-- Q2			
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('2. Kempes this period', @TotalNumberOfKempesThisPeriodQuarterly, @TotalNumberOfKempesContractPeriod)
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('    a. Positive Assigned to FSW', @nQ2a, @nQ2CPa)
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('    b. Positive Not Assigned to FSW', @nQ2b, @nQ2CPb)
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('    c. Positive Pending Assignment to FSW', @nQ2c, @nQ2CPc)
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('    d. Negative', @nQ2d, @nQ2CPd)
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('    e. Positive average score - Mother', @nQ2e, @nQ2CPe)
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('    f. Positive average score - Father', @nQ2f, @nQ2CPf)
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('    g. Score over 40 - Mother', @nQ2g, @nQ2CPg)
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('    h. Score over 40 - Father', @nQ2h, @nQ2CPh)
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('    i. Prenatal', @nQ2i, @nQ2CPi)
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('    j. Postnatal', @nQ2j, @nQ2CPj)

			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('','', '') --insert empty row

			-- Q3
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('3. Kempe Assessments from previous periods assigned this period', @nQ3, @nQCP3)
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('','', '') --insert empty row

			-- Q4
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('4. Pre-Intake Cases this period(1+2a+3)', 
			@TotalNumberOfPreIntakeCasesQuarterly + @nQ2a + @nQ3 ,
			@TotalNumberOfPreIntakeCasesContractPeriod + @nQ2CPa + @nQCP3
			)
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('','', '') --insert empty row

			-- Q5
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('5. Outcomes for Pre-Intake Cases this period(1+2a+3)', '', '')
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('    a. Engagement Efforts contiue', @nQ5a, @nQ5CPa)
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('    b. Enrolled', @nQ5b, @nQ5CPb)
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('    c. Terminated', @nQ5c, @nQ5CPc)
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('    d. No Status for last month of period', @nQ5d, @nQ5CPd)

			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('','', '') --insert empty row

			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('6. Activities for Period', '', '')
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('    a. Letters mailed to parent',(SELECT nQ6a FROM @tblnQ6Q), (SELECT nQ6CPa FROM @tblnQ6CP))
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('    b. Phone calls made to parent',(SELECT nQ6b FROM @tblnQ6Q), (SELECT nQ6CPb FROM @tblnQ6CP))
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('    c. Phone calls received from parent',(SELECT nQ6c FROM @tblnQ6Q), (SELECT nQ6CPc FROM @tblnQ6CP))
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('    d. Visits conducted to asses parent (unavailable)',(SELECT nQ6d FROM @tblnQ6Q), (SELECT nQ6CPd FROM @tblnQ6CP))
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('    e. Visits conducted to asses parent',(SELECT nQ6e FROM @tblnQ6Q), (SELECT nQ6CPe FROM @tblnQ6CP))
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('    f. Referrals made to service other than home visiting',(SELECT nQ6f FROM @tblnQ6Q), (SELECT nQ6CPf FROM @tblnQ6CP))
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('    g. Parent came to office',(SELECT nQ6g FROM @tblnQ6Q), (SELECT nQ6CPg FROM @tblnQ6CP))
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('    h. Program material provided/sent to parent',(SELECT nQ6h FROM @tblnQ6Q), (SELECT nQ6CPh FROM @tblnQ6CP))
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('    i. Gift provided to parent',(SELECT nQ6i FROM @tblnQ6Q), (SELECT nQ6CPi FROM @tblnQ6CP))
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('    j. Case Conference/review',(SELECT nQ6j FROM @tblnQ6Q), (SELECT nQ6CPj FROM @tblnQ6CP))
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('    k. Other',(SELECT nQ6k FROM @tblnQ6Q), (SELECT nQ6CPk FROM @tblnQ6CP))

			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('','', '') --insert empty row


	END 
	ELSE 
	BEGIN 

			-- Q1
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('1. Pre-Intake Cases at the beginning of period', @TotalNumberOfPreIntakeCasesQuarterly, '')
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('','', '') --insert empty row

			-- Q2			
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('2. Kempes this period', @TotalNumberOfKempesThisPeriodQuarterly, '')
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('    a. Positive Assigned to FSW', @nQ2a, '')
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('    b. Positive Not Assigned to FSW', @nQ2b, '')
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('    c. Positive Pending Assignment to FSW', @nQ2c, '')
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('    d. Negative', @nQ2d, '')
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('    e. Positive average score - Mother', @nQ2e, '')
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('    f. Positive average score - Father', @nQ2f, '')
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('    g. Score over 40 - Mother', @nQ2g, '')
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('    h. Score over 40 - Father', @nQ2h, '')
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('    i. Prenatal', @nQ2i, '')
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('    j. Postnatal', @nQ2j, '')

			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('','', '') --insert empty row

			-- Q3
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('3. Kempe Assessments from previous periods assigned this period', @nQ3, '')
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('','', '') --insert empty row

			-- Q4
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('4. Pre-Intake Cases this period(1+2a+3)', 
			@TotalNumberOfPreIntakeCasesQuarterly + @nQ2a + @nQ3 , '')
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('','', '') --insert empty row

			-- Q5
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('5. Outcomes for Pre-Intake Cases this period(1+2a+3)', '', '')
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('    a. Engagement Efforts contiue', @nQ5a, '')
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('    b. Enrolled', @nQ5b, '')
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('    c. Terminated', @nQ5c, '')
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('    d. No Status for last month of period', @nQ5d, '')

			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('','', '') --insert empty row

			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('6. Activities for Period', '', '')
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('    a. Letters mailed to parent',(SELECT nQ6a FROM @tblnQ6Q), '')
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('    b. Phone calls made to parent',(SELECT nQ6b FROM @tblnQ6Q), '')
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('    c. Phone calls received from parent',(SELECT nQ6c FROM @tblnQ6Q), '')
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('    d. Visits conducted to asses parent (unavailable)',(SELECT nQ6d FROM @tblnQ6Q), '')
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('    e. Visits conducted to asses parent',(SELECT nQ6e FROM @tblnQ6Q), '')
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('    f. Referrals made to service other than home visiting',(SELECT nQ6f FROM @tblnQ6Q), '')
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('    g. Parent came to office',(SELECT nQ6g FROM @tblnQ6Q), '')
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('    h. Program material provided/sent to parent',(SELECT nQ6h FROM @tblnQ6Q), '')
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('    i. Gift provided to parent',(SELECT nQ6i FROM @tblnQ6Q), '')
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('    j. Case Conference/review',(SELECT nQ6j FROM @tblnQ6Q), '')
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('    k. Other',(SELECT nQ6k FROM @tblnQ6Q), '')

			INSERT INTO @tblMainResult([Text],[QuarterlyData],[ContractPeriodData])VALUES('','', '') --insert empty row



	END 

	SELECT * FROM @tblMainResult




















	--SELECT * FROM @tblPreIntakeEngagement

END
GO
