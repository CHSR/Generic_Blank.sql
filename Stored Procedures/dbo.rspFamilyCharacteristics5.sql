SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Stored Procedure

-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <August 2nd, 2012>
-- Description:	<gets you data for Family Characteristics Quarterly and Contract Period>
-- exec [rspFamilyCharacteristics5] ',1,','09/01/2010','11/30/2010',null,0
-- exec [rspFamilyCharacteristics5] ',1,','09/01/2010','11/30/2010',null,1
-- exec rspFamilyCharacteristics5 '32','01/01/13','06/30/13',NULL,NULL
-- =============================================
CREATE procedure [dbo].[rspFamilyCharacteristics5](@programfk    varchar(max)    = null,
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
	[TCDOD] [datetime],
	[PCDOB] [datetime],
	[DischargeDate] [datetime],	
	[LastDate] [datetime],
	[TCAgeDays] [int],
	[TCNumber] [int],
	[PC1Relation2TC] [char](2),	
	[PC2Relation2TC] [char](2),	
	[OBPRelation2TC] [char](2),	
	[PC2inHomeIntake] BIT, 
	[Race] [char](2),	
	[SiteFK] [int]

)

DECLARE @tblInitRequiredData2 TABLE(
	[HVCasePK] [int],
	[IntakeDate] [datetime],
	[TCDOB] [datetime],
	[TCDOD] [datetime],
	[PCDOB] [datetime],
	[DischargeDate] [datetime],	
	[LastDate] [datetime],
	[TCAgeDays] [int],
	[TCNumber] [int],
	[PC1Relation2TC] [char](2),
	[PC2Relation2TC] [char](2),
	[OBPRelation2TC] [char](2),
	[PC2inHomeIntake] BIT,		
	[Race] [char](2),			
	[SiteFK] [int]

)

-- for Q2
DECLARE @tblTargetChildrens TABLE(
	[HVCasePK] [int],
	[IntakeDate] [datetime],
	[TCDOB] [datetime],
	[TCDOD] [datetime],
	[DischargeDate] [datetime],	
	[LastDate] [datetime],
	[TCAgeDays] [int],
	[TCNumber] [int],		
	[SiteFK] [int]

)	

;

	with cteMain
	as
	(
		SELECT 
		h.HVCasePK,h.IntakeDate,

		case
		   when h.tcdob is not null then
			   h.tcdob
		   else
			   h.edc
		end as tcdob,
		h.TCDOD,
		P.PCDOB,
		cp.DischargeDate,

		case
		   when DischargeDate is not null and DischargeDate <> '' and DischargeDate < @eDate then
			   DischargeDate
		   else
			   @eDate
		end as lastdate,
		[TCNumber],
		[PC1Relation2TC],
		[PC2Relation2TC],
		[OBPRelation2TC],
		[PC2inHomeIntake],
		P.[Race],	
		CASE WHEN wp.SiteFK IS NULL THEN 0 ELSE wp.SiteFK END AS SiteFK
		FROM HVCase h 
		INNER JOIN CaseProgram cp ON h.HVCasePK = cp.HVCaseFK 
		INNER JOIN Worker w ON w.WorkerPK = cp.CurrentFSWFK
		INNER JOIN WorkerProgram wp ON wp.WorkerFK = w.WorkerPK -- get SiteFK
		INNER JOIN PC P ON P.PCPK = h.PC1FK
		inner join dbo.SplitString(@programfk,',') on cp.programfk = listitem
	)

-- SiteFK = isnull(@sitefk,SiteFK) does not work because column SiteFK may be null itself 
INSERT INTO @tblInitRequiredData( 
	[HVCasePK],
	[IntakeDate],
	[TCDOB],
	[TCDOD],
	[PCDOB],
	[DischargeDate],
	[LastDate],
	[TCAgeDays],
	[TCNumber],
	[PC1Relation2TC],	
	[PC2Relation2TC],
	[OBPRelation2TC],
	[PC2inHomeIntake],
	[Race],		
	[SiteFK])
SELECT 
	[HVCasePK],
	[IntakeDate],
	[TCDOB],
	[TCDOD],
	[PCDOB],
	[DischargeDate],
	[LastDate],

	case
	   when DischargeDate is not null and DischargeDate <> '' and DischargeDate <= @eDate then
		   datediff(day,tcdob, DischargeDate)	   
	   ELSE
		   datediff(day,tcdob, @eDate)	   
	end as tcAgeDays,

	case
	   when tcdob <= lastdate AND TCNumber = 0 then
		   1
	   when tcdob > lastdate then
		   0	   	   
	   ELSE
		   TCNumber   
	end as TCNumber,

	[PC1Relation2TC],
	[PC2Relation2TC],
	[OBPRelation2TC],
	[PC2inHomeIntake],
	[Race],
	[SiteFK]


 FROM cteMain
WHERE SiteFK = isnull(@sitefk,SiteFK)





INSERT INTO @tblInitRequiredData2( 
	[HVCasePK],
	[IntakeDate],
	[TCDOB],
	[TCDOD],
	[PCDOB],
	[DischargeDate],
	[LastDate],
	[TCAgeDays],
	[TCNumber],
	[PC1Relation2TC],
	[PC2Relation2TC],
	[OBPRelation2TC],
	[PC2inHomeIntake],
	[Race],		
	[SiteFK])

SELECT *
FROM @tblInitRequiredData
WHERE 
IntakeDate <= @edate 
AND 
(DischargeDate IS NULL OR DischargeDate >= @sdate)



---------------------------------------------

---------------------------------------------
--- **************************************** ---
-- Part #1:Families at Intake  --- (QUARTERLY STATS)
-- Time period is only quarterly, contact dates not involved.

DECLARE @TotalNumberOfFamiliesAtIntakeQuarterly INT 

SET @TotalNumberOfFamiliesAtIntakeQuarterly = 
(
	SELECT count(DISTINCT HVCasePK)
	FROM @tblInitRequiredData2


)

-- Part #1a:prenatal families at intake

DECLARE @nPrenatalQuarterly INT 

SET @nPrenatalQuarterly = 
(
	SELECT count(DISTINCT HVCasePK)
	FROM @tblInitRequiredData2
	WHERE TCDOB > IntakeDate 

)

DECLARE @nQC1a INT

-- 1 a prenatal currently
SET @nQC1a = 
(
	SELECT count(DISTINCT HVCasePK)
	FROM @tblInitRequiredData2
	WHERE TCDOB > LastDate  

)
 

--- **************************************** ---
-- Part #2: target children  --- (QUARTERLY STATS)
-- exec [rspFamilyCharacteristics5] ',1,','09/01/2010','11/30/2010',null,0
;
	with cteFAmiliesIntake
	as
	(
		SELECT *
		FROM @tblInitRequiredData2

	)
	
	
,

cteKidsIntake
	as
	(
		SELECT 
		
			[HVCasePK],
			[IntakeDate],
			[TCDOB],
			[TCDOD],
			[PCDOB],
			[DischargeDate],
			[LastDate],
			[TCAgeDays],
				
			CASE --substract out the dead tcs	
			   when tcdob > IntakeDate then
				   0
			   when TCNumber = 0 then
				   1	   	   
			   ELSE
				   TCNumber   
			end as Kidno2,	
			
			[SiteFK]				
		
		
		FROM cteFAmiliesIntake
		WHERE 
		IntakeDate <= @edate 
		AND 
		(DischargeDate IS NULL OR DischargeDate >= @sdate)

	)
	
,
cteDeceasedChildrens
	as
	( -- gets count of deceased childrens

		SELECT  count(*) ngone, T.HVCaseFK FROM cteKidsIntake ki	
		INNER JOIN TCID T ON T.HVCaseFK	= ki.HVCasePK 
		WHERE 
		T.TCDOD IS NOT NULL 
		AND 
		T.TCDOD < IntakeDate 
		GROUP BY T.HVCaseFK

	)



-- decreament number of deceased childrens
INSERT INTO @tblTargetChildrens( 
	[HVCasePK],
	[IntakeDate],
	[TCDOB],
	[TCDOD],
	[DischargeDate],
	[LastDate],
	[TCAgeDays],
	[TCNumber],		
	[SiteFK]
	)	

	SELECT  	
			HVCasePK
		  , IntakeDate
		  , TCDOB
		  , TCDOD
		  , DischargeDate
		  , LastDate
		  , TCAgeDays
		  , (Kidno2 - isnull(s2.ngone,0)) AS Kidno2 -- substract out the dead tcs	
		  , SiteFK
		   FROM cteKidsIntake ki
	Left JOIN cteDeceasedChildrens s2 ON s2.HVCaseFK = ki.HVCasePK 


	
-- Q2 --------------------------
-- 2 target children
-- Quarterlies
DECLARE @nQ2 INT 
DECLARE @nQ2a INT 
DECLARE @nQ2b INT 
DECLARE @nQ2c INT 
DECLARE @nQ2d INT 
DECLARE @nQ2e INT 
DECLARE @nQ2f INT 
DECLARE @nQ2g INT 

-- 2. Total number of childrens
SET @nQ2 = (SELECT sum(TCNumber) FROM @tblTargetChildrens)
-- 2a. Under 3 months
SET @nQ2a = (SELECT sum(TCNumber) FROM @tblTargetChildrens
				WHERE (datediff(day,TCDOB, IntakeDate) / 30.44) < 3	)				
SET @nQ2a = isnull(@nQ2a, 0)
				
-- 2b. 3 months up to 1 year
SET @nQ2b = (SELECT sum(TCNumber) FROM @tblTargetChildrens
				WHERE (datediff(day,TCDOB, IntakeDate) / 30.44) BETWEEN 3 AND 11.99 
			)
SET @nQ2b = isnull(@nQ2b, 0)

-- 2c. 1 year up to 2 years
SET @nQ2c = (SELECT sum(TCNumber) FROM @tblTargetChildrens
				WHERE (datediff(day,TCDOB, IntakeDate) / 30.44) BETWEEN 12 AND 23.99 
			)
SET @nQ2c = isnull(@nQ2c, 0)	

-- 2d. 2 years up to 3 years
SET @nQ2d = (SELECT sum(TCNumber) FROM @tblTargetChildrens
				WHERE (datediff(day,TCDOB, IntakeDate) / 30.44) BETWEEN 24 AND 35.99 
			)
SET @nQ2d = isnull(@nQ2d, 0)

-- 2e. 3 years up to 4 years
SET @nQ2e = (SELECT sum(TCNumber) FROM @tblTargetChildrens
				WHERE (datediff(day,TCDOB, IntakeDate) / 30.44) BETWEEN 36 AND 47.99 
			)
SET @nQ2e = isnull(@nQ2e, 0)	

-- 2f. 4 years up to 5 years
SET @nQ2f = (SELECT sum(TCNumber) FROM @tblTargetChildrens
				WHERE (datediff(day,TCDOB, IntakeDate) / 30.44) BETWEEN 48 AND 59.99 
			)
SET @nQ2f = isnull(@nQ2f, 0)	

-- 2g. Over 5 years
SET @nQ2g = (SELECT sum(TCNumber) FROM @tblTargetChildrens
				WHERE (datediff(day,TCDOB, IntakeDate) / 30.44) >= 60
			)
SET @nQ2g = isnull(@nQ2g, 0)	


-- Current info
DECLARE @nQC2 INT 
DECLARE @nQC2a INT 
DECLARE @nQC2b INT 
DECLARE @nQC2c INT 
DECLARE @nQC2d INT 
DECLARE @nQC2e INT 
DECLARE @nQC2f INT 
DECLARE @nQC2g INT 

DECLARE @tblTargetChildrensCurrent TABLE(
	[HVCasePK] [int],
	[IntakeDate] [datetime],
	[TCDOB] [datetime],
	[TCDOD] [datetime],
	[PCDOB] [datetime],
	[DischargeDate] [datetime],	
	[LastDate] [datetime],
	[TCAgeDays] [int],
	[TCNumber] [int],
	[PC1Relation2TC] [char](2),
	[PC2Relation2TC] [char](2),
	[OBPRelation2TC] [char](2),
	[PC2inHomeIntake] BIT,		
	[Race] [char](2),			
	[SiteFK] [int]

)

-- Cohort
INSERT INTO @tblTargetChildrensCurrent
		SELECT 
		
			[HVCasePK],
			[IntakeDate],
			[TCDOB],
			[TCDOD],
			[PCDOB],
			[DischargeDate],
			[LastDate],
			[TCAgeDays],				
			TCNumber,				
			[PC1Relation2TC],
			[PC2Relation2TC],
			[OBPRelation2TC],
			[PC2inHomeIntake],
			[Race],		
			[SiteFK]		
		
		FROM @tblInitRequiredData2
		WHERE 
		IntakeDate <= @edate 
		AND 
		(DischargeDate IS NULL OR DischargeDate >= @sdate)
-- exec [rspFamilyCharacteristics5] ',1,','09/01/2010','11/30/2010',null,0

-- 2. Total number of childrens
SET @nQC2 = (SELECT sum(TCNumber) FROM @tblTargetChildrensCurrent)
-- 2a. Under 3 months
SET @nQC2a = (SELECT sum(TCNumber) FROM @tblTargetChildrensCurrent
				WHERE (TCAgeDays / 30.44) < 3	)				
SET @nQC2a = isnull(@nQC2a, 0)
				
-- 2b. 3 months up to 1 year
SET @nQC2b = (SELECT sum(TCNumber) FROM @tblTargetChildrensCurrent
				WHERE (TCAgeDays / 30.44) BETWEEN 3 AND 11.99 
			)
SET @nQC2b = isnull(@nQC2b, 0)

-- 2c. 1 year up to 2 years
SET @nQC2c = (SELECT sum(TCNumber) FROM @tblTargetChildrensCurrent
				WHERE (TCAgeDays / 30.44) BETWEEN 12 AND 23.99 
			)
SET @nQC2c = isnull(@nQC2c, 0)	

-- 2d. 2 years up to 3 years
SET @nQC2d = (SELECT sum(TCNumber) FROM @tblTargetChildrensCurrent
				WHERE (TCAgeDays / 30.44) BETWEEN 24 AND 35.99 
			)
SET @nQC2d = isnull(@nQC2d, 0)

-- 2e. 3 years up to 4 years
SET @nQC2e = (SELECT sum(TCNumber) FROM @tblTargetChildrensCurrent
				WHERE (TCAgeDays / 30.44) BETWEEN 36 AND 47.99 
			)
SET @nQC2e = isnull(@nQC2e, 0)	

-- 2f. 4 years up to 5 years
SET @nQC2f = (SELECT sum(TCNumber) FROM @tblTargetChildrensCurrent
				WHERE (TCAgeDays / 30.44) BETWEEN 48 AND 59.99 
			)
SET @nQC2f = isnull(@nQC2f, 0)	

-- 2g. Over 5 years
SET @nQC2g = (SELECT sum(TCNumber) FROM @tblTargetChildrensCurrent
				WHERE (TCAgeDays / 30.44) >= 60
			)
SET @nQC2g = isnull(@nQC2g, 0)	




-- Q3 --------------------------	
-- Quarterly

DECLARE @nQ3 INT 
DECLARE @nQ3a INT 
DECLARE @nQ3b INT 
DECLARE @nQ3c INT 
DECLARE @nQ3d INT 

-- 3. Primary Caretaker 1 Age
SET @nQ3 = @TotalNumberOfFamiliesAtIntakeQuarterly

--SELECT @nQ3

-- 3a. Under 18 years
SET @nQ3a = (
		SELECT count(*) FROM @tblInitRequiredData2		
		WHERE (datediff(day,PCDOB, IntakeDate) < (18*365.25))
		)
						
SET @nQ3a = isnull(@nQ3a, 0)

-- 3b. 18 up to 20
SET @nQ3b = (
		SELECT count(*) FROM @tblInitRequiredData2		
		WHERE (datediff(day,PCDOB, IntakeDate) BETWEEN (18*365.25) AND (20*365.25))
		)
						
SET @nQ3b = isnull(@nQ3b, 0)
-- 3c. 20 up to 30
SET @nQ3c = (
		SELECT count(*) FROM @tblInitRequiredData2		
		WHERE (datediff(day,PCDOB, IntakeDate) BETWEEN (20*365.25) AND (30*365.25))
		)
						
SET @nQ3c = isnull(@nQ3c, 0)
-- 3d. Over 30
SET @nQ3d = (
		SELECT count(*) FROM @tblInitRequiredData2		
		WHERE (datediff(day,PCDOB, IntakeDate) > (30*365.25))
		)
						
SET @nQ3d = isnull(@nQ3d, 0)


-- Current Info

DECLARE @nQC3 INT 
DECLARE @nQC3a INT 
DECLARE @nQC3b INT 
DECLARE @nQC3c INT 
DECLARE @nQC3d INT 

-- 3. Primary Caretaker 1 Age
SET @nQC3 = @TotalNumberOfFamiliesAtIntakeQuarterly

--SELECT @nQC3

-- 3a. Under 18 years
SET @nQC3a = (
		SELECT count(*) FROM @tblInitRequiredData2		
		WHERE (datediff(day,PCDOB, LastDate) < (18*365.25))
		)
						
SET @nQC3a = isnull(@nQC3a, 0)

-- 3b. 18 up to 20
SET @nQC3b = (
		SELECT count(*) FROM @tblInitRequiredData2		
		WHERE (datediff(day,PCDOB, LastDate) BETWEEN (18*365.25) AND (20*365.25))
		)
						
SET @nQC3b = isnull(@nQC3b, 0)
-- 3c. 20 up to 30
SET @nQC3c = (
		SELECT count(*) FROM @tblInitRequiredData2		
		WHERE (datediff(day,PCDOB, LastDate) BETWEEN (20*365.25) AND (30*365.25))
		)
						
SET @nQC3c = isnull(@nQC3c, 0)
-- 3d. Over 30
SET @nQC3d = (
		SELECT count(*) FROM @tblInitRequiredData2		
		WHERE (datediff(day,PCDOB, LastDate) > (30*365.25))
		)
						
SET @nQC3d = isnull(@nQC3d, 0)






-- Q4 --------------------------	
DECLARE @nQ4 INT 
DECLARE @nQ4a INT 
DECLARE @nQ4b INT 
DECLARE @nQ4c INT 

-- Bulding cohort for Q4

DECLARE @tblPC1Education3 TABLE(
	[HVCasePK] [int],
	[IntakeDate] [datetime],
	[TCDOB] [datetime],
	[TCDOD] [datetime],
	[PCDOB] [datetime],
	[DischargeDate] [datetime],	
	[LastDate] [datetime],
	[TCAgeDays] [int],
	[TCNumber] [int],
	[SiteFK] [int],
	[PC1Relation2TC] [char](2),
	[PC2Relation2TC] [char](2)	
	,[OBPRelation2TC] [char](2)
	,[PC2inHomeIntake] BIT
	,[OBPinHome] BIT
	,EducationalEnrollment [char](1)
	,FormFK [int]		
	, HighestGrade [char](2)
	, HIUnknown	[BIT]			 
	, IsCurrentlyEmployed [char](1)				 
	, MaritalStatus [char](2)				 
	, PBFoodStamps [char](1)				
	, PBTANF [char](1)				 
	, PC1HasMedicalProvider [char](1)				 
	 , PC1ReceivingMedicaid [char](1)				 
	, TANFServices	[BIT],
	[FormType] [char](8)

)



	INSERT INTO @tblPC1Education3	
			SELECT HVCasePK
				 , IntakeDate
				 , TCDOB
				 , TCDOD
				 , PCDOB
				 , DischargeDate
				 , LastDate
				 , TCAgeDays
				 , TCNumber
				 , SiteFK				
				 ,PC1Relation2TC
				 ,PC2Relation2TC
				 ,[OBPRelation2TC]
				 ,[PC2inHomeIntake]
				 ,caIntakeOBP.[OBPinHome]
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
				 FROM @tblInitRequiredData pc1edu
			INNER JOIN CommonAttributes ca ON ca.HVCaseFK = pc1edu.HVCasePK and ca.FormType = 'IN-PC1' 
			left outer join CommonAttributes caIntakeOBP on caIntakeOBP.HVCaseFK = ca.HVCaseFK and caIntakeOBP.FormType = 'IN-OBP'
			WHERE 
			IntakeDate <= @edate 
			AND 
			(DischargeDate IS NULL OR DischargeDate >= @sdate)
	

DECLARE @tblPC1Education TABLE(
		[HVCasePK] [int],
		[PC1MaritalStatus] [char](2),
		[PC1HighestGrade] [char](2),
		
		[OBPMaritalStatus] [char](2),
		[OBPHighestGrade] [char](2),		
		
		[OBPinHome] [char](1),
		
		[PC1Relation2TC] [char](2),	
		[OBPRelation2TC] [char](2),		
		[PC2inHomeIntake] BIT,
		
		[PC1FormType] [char](8),
		[OBPFormType] [char](8)
)

INSERT INTO @tblPC1Education
SELECT irq.HVCasePK
				,caIntakePC1.[MaritalStatus] AS PC1MaritalStatus
				,caIntakePC1.[HighestGrade] AS PC1HighestGrade
							
				,caIntakeOBP.[MaritalStatus] AS OBPMaritalStatus
				,caIntakeOBP.[HighestGrade] AS OBPHighestGrade
				
				,caIntakeOBP.[OBPinHome] AS OBPinHome

		,irq.[PC1Relation2TC]
		,irq.[OBPRelation2TC]
		,irq.[PC2inHomeIntake]
		
		,caIntakePC1.FormType AS PC1FormType
		,caIntakeOBP.FormType AS OBPFormType
		
		
	 FROM @tblInitRequiredData irq
	 inner join CommonAttributes caIntakePC1 on caIntakePC1.HVCaseFK = irq.HVCasePK and caIntakePC1.FormType = 'IN-PC1'	 
	 left outer join CommonAttributes caIntakeOBP on caIntakeOBP.HVCaseFK = irq.HVCasePK and caIntakeOBP.FormType = 'ID'	 
	WHERE
	IntakeDate <= @edate 
	AND 
	(DischargeDate IS NULL OR DischargeDate >= @sdate)


-- exec [rspFamilyCharacteristics5] ',1,','09/01/2010','11/30/2010',null,0


-- Let us look into the Kempes
DECLARE @tblKempes TABLE(
	[HVCasePK] [int]
	, PC1MaritalStatus [char](2)
	, PC1HighestGrade [char](2)

)


INSERT INTO @tblKempes
	SELECT k.HVCaseFK, pc1.PC1MaritalStatus, pc1.PC1HighestGrade  FROM kempe k
	LEFT JOIN @tblPC1Education pc1 ON pc1.HVCasePK = k.HVCaseFK 
	INNER JOIN @tblInitRequiredData2 irq2 ON irq2.HVCasePK = k.HVCaseFK 
	WHERE k.HVCaseFK IS NULL 



DECLARE @nkQ4a INT 
DECLARE @nkQ4b INT 
DECLARE @nkQ4c INT 




-- 4. Primary Caretaker 1 Education
SET @nQ4 = @nQ3


-- 4a. Less than 12 years   --- NOT WORKING
SET @nQ4a = (SELECT count(*) count1 FROM @tblPC1Education WHERE PC1HighestGrade IN ('01','02'))
SET @nkQ4a = (SELECT count(*) count2 FROM @tblKempes WHERE PC1HighestGrade IN ('01','02'))

SET @nQ4a = @nQ4a + @nkQ4a

-- 4b. High School Graduate / GED
SET @nQ4b = (SELECT count(*) count1 FROM @tblPC1Education WHERE PC1HighestGrade IN ('03','04'))
SET @nkQ4b = (SELECT count(*) count2 FROM @tblKempes WHERE PC1HighestGrade IN ('03','04'))
SET @nQ4b = @nQ4b + @nkQ4b


-- 4c. Post Secondary
SET @nQ4c = (SELECT count(*) count1 FROM @tblPC1Education WHERE PC1HighestGrade IN ('05','06','07','08'))
SET @nkQ4c = (SELECT count(*) count2 FROM @tblKempes WHERE PC1HighestGrade IN ('05','06','07','08'))
SET @nQ4c = @nQ4c + @nkQ4c

-- Q5 --------------------------	
DECLARE @nQ5 INT 
DECLARE @nkQ5 INT 


select HVCasePK
				,caIntakePC1.[MaritalStatus] AS PC1MaritalStatus
				,caIntakePC1.[HighestGrade] AS PC1HighestGrade
				,caIntakePC1.[PBTANF] AS PC1PBTANF
				,caIntakePC1.[PBFoodStamps] AS PC1PBFoodStamps
				,caIntakePC1.[TANFServices] AS PC1TANFServices
				,caIntakePC1.[PC1ReceivingMedicaid] AS PC1ReceivingMedicaid
				,caIntakePC1.[HIUnknown] AS PC1HIUnknown
				
				
					
				,caIntakePC2.[MaritalStatus] AS PC2MaritalStatus
				,caIntakePC2.[HighestGrade] AS PC2HighestGrade
				,caIntakePC2.[PBTANF] AS PC2PBTANF
				,caIntakePC2.[PBFoodStamps] AS PC2PBFoodStamps
				,caIntakePC2.[TANFServices] AS PC2TANFServices
				,caIntakePC2.[PC1ReceivingMedicaid] AS PC2ReceivingMedicaid
				,caIntakePC2.[HIUnknown] AS PC2HIUnknown
								
				,caIntakeOBP.[MaritalStatus] AS MaritalStatus
				,caIntakeOBP.[HighestGrade] AS OBPHighestGrade
				,caIntakeOBP.[PBTANF] AS OBPPBTANF
				,caIntakeOBP.[PBFoodStamps] AS OBPPBFoodStamps
				,caIntakeOBP.[TANFServices] AS OBPTANFServices
				,caIntakeOBP.[PC1ReceivingMedicaid] AS OBPReceivingMedicaid
				,caIntakeOBP.[HIUnknown] AS OBPHIUnknown
				
				
						
				,caIntakeOBP.[OBPinHome]		
			    ,caIntakePC1.IsCurrentlyEmployed as PC1CurrentEmployment
			    ,caIntakePC1.EducationalEnrollment as PC1CurrentEducationalEnrollment
			    ,CASE WHEN caIntakePC2.IsCurrentlyEmployed = '1' OR caIntakeOBP.IsCurrentlyEmployed = '1' THEN '1' ELSE '0' END as PC2CurrentEmployment -- Combines pc2 and obp because pc2 was split into these two during conversion from FoxPro
			    ,CASE WHEN caIntakePC2.EducationalEnrollment = '1' OR caIntakeOBP.EducationalEnrollment = '1' THEN '1' ELSE '0' END as PC2CurrentEducationalEnrollment -- Combines pc2 and obp because pc2 was split into these two during conversion from FoxPro
				,irq2.[PC1Relation2TC]		
				,irq2.[PC2Relation2TC]		
				,irq2.[OBPRelation2TC]
				,irq2.[PC2inHomeIntake]

			
			from @tblInitRequiredData2 irq2				
				inner join CommonAttributes caIntakePC1 on caIntakePC1.HVCaseFK = irq2.HVCasePK and caIntakePC1.FormType = 'IN-PC1'
				left outer join CommonAttributes caIntakePC2 on caIntakePC2.HVCaseFK = irq2.HVCasePK and caIntakePC2.FormType = 'IN-PC2'	
				left outer join CommonAttributes caIntakeOBP on caIntakeOBP.HVCaseFK = irq2.HVCasePK and caIntakeOBP.FormType = 'IN-OBP'		
			where IntakeDate <= @eDate				
				 and IntakeDate is not null
				 and (DischargeDate >= @sDate
				 or DischargeDate is null)












-- 5. Primary Caretaker 1 Married
SET @nQ5 = (SELECT count(*) count1 FROM @tblPC1Education WHERE PC1MaritalStatus = '01')
SET @nkQ5 = (SELECT count(*) count2 FROM @tblKempes WHERE PC1MaritalStatus = '01')
SET @nQ5 = @nQ5 + @nkQ5

-- 6. Primary Caretaker 1 Race
DECLARE @nQ6 INT 
DECLARE @nQ6a INT 
DECLARE @nQ6b INT 
DECLARE @nQ6c INT 
DECLARE @nQ6d INT 
DECLARE @nQ6e INT 
DECLARE @nQ6f INT 

SET @nQ6 = @nQ3
SET @nQ6a = (SELECT count(*) count1 FROM @tblInitRequiredData2 WHERE Race = '01')
SET @nQ6b = (SELECT count(*) count1 FROM @tblInitRequiredData2 WHERE Race = '02')
SET @nQ6c = (SELECT count(*) count1 FROM @tblInitRequiredData2 WHERE Race = '03')
SET @nQ6d = (SELECT count(*) count1 FROM @tblInitRequiredData2 WHERE Race = '04')
SET @nQ6e = (SELECT count(*) count1 FROM @tblInitRequiredData2 WHERE Race = '05')
SET @nQ6f = (SELECT count(*) count1 FROM @tblInitRequiredData2 WHERE Race = '06')


-- 7. Household Composition
DECLARE @nQ7 INT 
DECLARE @nQ7a INT 
DECLARE @nQ7b INT 
DECLARE @nQ7c INT 
DECLARE @nQ7d INT 

-- figure out the intake column
SET @nQ7 = @nQ3
--SELECT * FROM @tblPC1Education

SET @nQ7a = (SELECT count(*) count1 FROM @tblPC1Education WHERE PC1Relation2TC = '01' AND  OBPinHome = 1)
--SET @nQ7a = (SELECT count(*) count1 FROM @tblPC1Education WHERE PC1Relation2TC = '01' AND [OBPRelation2TC] = '01')
SET @nQ7b = (SELECT count(*) count1 FROM @tblPC1Education WHERE [PC2inHomeIntake] = 1)


-- for nQ7c
DECLARE @tblOtherChild TABLE(
	[HVCasePK] [int],
	[HVCaseFK] [int],
	[LivingArrangement] [char](2)
)

INSERT INTO @tblOtherChild
SELECT HVCasePK,HVCaseFK,LivingArrangement FROM @tblPC1Education pc1
INNER JOIN OtherChild oc ON oc.HVCaseFK = pc1.HVCasePK 
WHERE pc1.PC1Relation2TC = '01' -- AND pc1.PC1FormType = 'IN' -- filter IN includes kids at Intake not FollowUp
--ORDER BY hvcasepk


-- TODO - KHALSA CONTINUE

;
	WITH cteFirstTimeMothers
	as (select count(HVCasePK) as FirstTimeMothers
			from @tblPC1Education pc1e
			where HVCasePK not in (select pc1e.HVCasePK
									   from OtherChild oc
									   where oc.HVCaseFK = pc1e.HVCasePK
											and oc.Relation2PC1 = '01')
)

SELECT * FROM cteFirstTimeMothers


SELECT HVCasePK FROM @tblPC1Education INT1
 WHERE INT1.HVCasePK NOT IN (SELECT [@tblOtherChild].HVCasePK FROM @tblOtherChild)
----SELECT HVCasePK FROM @tblOtherChild
----ORDER BY hvcasepk

--SET @nQ7c = (SELECT count(HVCasePK) FROM @tblPC1Education INT1 WHERE INT1.HVCasePK NOT IN (SELECT [@tblOtherChild].HVCasePK FROM @tblOtherChild))

-- for @nQ7d
DECLARE @tblOtherBioChild TABLE(
	[HVCaseFK] [int]

)

INSERT INTO @tblOtherBioChild
SELECT DISTINCT HVCaseFK FROM @tblOtherChild WHERE LivingArrangement= '03' -- removes duplicate

SET @nQ7d = (SELECT count(HVCaseFK) FROM @tblOtherBioChild )

--SELECT * FROM @tblMain
-- exec [rspFamilyCharacteristics5] ',1,','09/01/2010','11/30/2010',null,0

DECLARE @tblPC1Employment TABLE(
		[HVCasePK] [int],
		[PC1CurrentEmployment] [char](1),	
		[PC1CurrentEducationEnrollment] [char](1),	
		[PC2CurrentEmployment] [char](1),	
		[PC2CurrentEducationEnrollment] [char](1)			

)
-- cohort
INSERT INTO @tblPC1Employment
select HVCasePK
			  ,caIntakePC1.IsCurrentlyEmployed as PC1CurrentEmployment
			  ,caIntakePC1.EducationalEnrollment as PC1CurrentEducationalEnrollment
			  ,CASE WHEN caIntakePC2.IsCurrentlyEmployed = '1' OR caIntakeOBP.IsCurrentlyEmployed = '1' THEN '1' ELSE '0' END as PC2CurrentEmployment -- Combines pc2 and obp because pc2 was split into these two during conversion from FoxPro
			  ,CASE WHEN caIntakePC2.EducationalEnrollment = '1' OR caIntakeOBP.EducationalEnrollment = '1' THEN '1' ELSE '0' END as PC2CurrentEducationalEnrollment -- Combines pc2 and obp because pc2 was split into these two during conversion from FoxPro
			from @tblInitRequiredData2 c				
				inner join CommonAttributes caIntakePC1 on caIntakePC1.HVCaseFK = c.HVCasePK and caIntakePC1.FormType = 'IN-PC1'
				left outer join CommonAttributes caIntakePC2 on caIntakePC2.HVCaseFK = c.HVCasePK and caIntakePC2.FormType = 'IN-PC2'	
				left outer join CommonAttributes caIntakeOBP on caIntakeOBP.HVCaseFK = c.HVCasePK and caIntakeOBP.FormType = 'IN-OBP'		
			where IntakeDate <= @eDate				
				 and IntakeDate is not null
				 and (DischargeDate >= @sDate
				 or DischargeDate is null)




-- 8. Employment, Education and training
DECLARE @nQ8 INT 
DECLARE @nQ8a INT 
DECLARE @nQ8b INT 
DECLARE @nQ8c INT 
DECLARE @nQ8d INT 
DECLARE @nQ8e INT 

SET @nQ8 = (SELECT count(*) count1 FROM @tblPC1Employment)

SET @nQ8a = (SELECT count(*) count1 FROM @tblPC1Employment WHERE PC1CurrentEmployment = '1')
SET @nQ8b = (SELECT count(*) count1 FROM @tblPC1Employment WHERE PC2CurrentEmployment = '1')
SET @nQ8c = (SELECT count(*) count1 FROM @tblPC1Employment WHERE PC1CurrentEmployment = '1' OR PC2CurrentEmployment = '1')
SET @nQ8d = (SELECT count(*) count1 FROM @tblPC1Employment WHERE PC1CurrentEducationEnrollment = '1')
SET @nQ8e = (SELECT count(*) count1 FROM @tblPC1Employment WHERE PC2CurrentEducationEnrollment = '1')

-- exec [rspFamilyCharacteristics5] ',1,','09/01/2010','11/30/2010',null,0

--SELECT * FROM @tblPC1Education

-- 9. Benefit Receiving
DECLARE @nQ9 INT 
DECLARE @nQ9a INT 
DECLARE @nQ9b INT 


DECLARE @tblBenefitsReceiving TABLE(
		[HVCasePK] [int],
		[PBTANF] [char](1),		
		[PBFoodStamps] [char](1)
)


-- Co-hort
INSERT INTO @tblBenefitsReceiving
SELECT HVCasePK
	  ,PBTANF  
	 , PBFoodStamps
	 FROM CommonAttributes ca 
	 inner join @tblInitRequiredData2 tm on tm.HVCasePK = ca.HVCaseFK
			where 
			 ca.FormType = 'IN'



SET @nQ9 = (SELECT count(*) count1 FROM @tblBenefitsReceiving)
SET @nQ9a = (SELECT count(*) count1 FROM @tblBenefitsReceiving WHERE PBTANF = '1')
SET @nQ9b = (SELECT count(*) count1 FROM @tblBenefitsReceiving WHERE PBFoodStamps = '1')


-- 10. Benefit Receiving
DECLARE @nQ10 INT 
DECLARE @nQ10a INT 

DECLARE @tblTanfServices TABLE(
		[HVCasePK] [int],
		[TANFServices] BIT
)


-- Co-hort
INSERT INTO @tblTanfServices
SELECT HVCasePK
	  ,TANFServices
	 FROM CommonAttributes ca 
	 inner join @tblInitRequiredData2 tm on tm.HVCasePK = ca.HVCaseFK
			where 
			 ca.FormType = 'IN'


SET @nQ10 = (SELECT count(*) count1 FROM @tblTanfServices)
SET @nQ10a = (SELECT count(*) count1 FROM @tblTanfServices WHERE TANFServices = '1')


-- 11. PC1 Medical Insurance and Medical Provider
DECLARE @nQ11 INT 
DECLARE @nQ11a INT 
DECLARE @nQ11b INT 
DECLARE @nQ11c INT 

DECLARE @tblPC1MedicalInsurance TABLE(
		[HVCasePK] [int],
		[PC1ReceivingMedicaid] [char](1),		
		[HIUnknown] BIT,
		[PC1HasMedicalProvider] [char](1)
)


-- Co-hort
INSERT INTO @tblPC1MedicalInsurance
SELECT HVCasePK
	  ,PC1ReceivingMedicaid 
	  ,HIUnknown
	 , PC1HasMedicalProvider
	 FROM CommonAttributes ca 
	 inner join @tblInitRequiredData2 tm on tm.HVCasePK = ca.HVCaseFK
			where 
			 ca.FormType = 'IN'



SET @nQ11 = (SELECT count(*) count1 FROM @tblPC1MedicalInsurance)
SET @nQ11a = (SELECT count(*) count1 FROM @tblPC1MedicalInsurance WHERE PC1ReceivingMedicaid = '1')
SET @nQ11b = (SELECT count(*) count1 FROM @tblPC1MedicalInsurance WHERE HIUnknown = '1')
SET @nQ11c = (SELECT count(*) count1 FROM @tblPC1MedicalInsurance WHERE PC1HasMedicalProvider = '1')

-- exec [rspFamilyCharacteristics5] ',1,','09/01/2010','11/30/2010',null,0

-- 12. TC Medical Insurance and Medical Provider by case
-- don't include child that have died after the report end.
DECLARE @nQ12 INT 
DECLARE @nQ12a INT 
DECLARE @nQ12b INT 
DECLARE @nQ12c INT 


 --SELECT * FROM @tblInitRequiredData2

DECLARE @tblTCMedical TABLE(
		[HVCasePK] [int],
		[TCHasMedicalProvider] [char](1),
		[TCHIUnknown] BIT,
		[TCReceivingMedicaid] [char](1)
)

INSERT INTO @tblTCMedical
SELECT HVCasePK
	  ,TCHasMedicalProvider	 
	 , TCHIUnknown
	 , TCReceivingMedicaid
	 FROM CommonAttributes ca 
	 inner join @tblInitRequiredData2 tm on tm.HVCasePK = ca.HVCaseFK
			where 
			(tm.TCDOD IS NULL OR tm.TCDOD  > = @edate) 
			AND tm.TCDOB <= tm.IntakeDate 
			AND ca.FormType = 'TC'	 
	 

--SELECT * FROM @tblTCMedical

-- exec [rspFamilyCharacteristics5] ',1,','09/01/2010','11/30/2010',null,0

-- As per John, don't apply Distinct filter. We want to show twins etc as it will match in Q2
SET @nQ12 = (SELECT count(*) count1 FROM @tblTCMedical)

SET @nQ12a = (SELECT count(*) count1 FROM @tblTCMedical WHERE TCReceivingMedicaid = '1')
SET @nQ12b = (SELECT count(*) count1 FROM @tblTCMedical WHERE TCHIUnknown = '1')
SET @nQ12c = (SELECT count(*) count1 FROM @tblTCMedical WHERE TCHasMedicalProvider = '1')




-- 13. Length in Program
DECLARE @nQ13 INT 
DECLARE @nQ13a INT 
DECLARE @nQ13b INT 
DECLARE @nQ13c INT 
DECLARE @nQ13d INT 
DECLARE @nQ13e INT 
DECLARE @nQ13f INT 
DECLARE @nQ13g INT 
DECLARE @nQ13h INT 

SET @nQ13 = 0

SET @nQ13a = 0
SET @nQ13b = 0
SET @nQ13c = 0
SET @nQ13d = 0
SET @nQ13e = 0
SET @nQ13f = 0
SET @nQ13g = 0
SET @nQ13h = 0



















DECLARE @tblMainResult TABLE(
	[Text] VARCHAR(500),
	[QuarterlyData] VARCHAR(50),
	[MostCurrentData] VARCHAR(50)
)

IF (@CustomQuarterlyDates = 0)
	BEGIN 

			-- Q1
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('1. Total Families', @TotalNumberOfFamiliesAtIntakeQuarterly, @TotalNumberOfFamiliesAtIntakeQuarterly)
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('		a. Prenatal' 
			,CONVERT(VARCHAR,@nPrenatalQuarterly) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@nPrenatalQuarterly AS FLOAT) * 100/ NULLIF(@TotalNumberOfFamiliesAtIntakeQuarterly,0), 0), 0))  + '%)', 
			CONVERT(VARCHAR,@nQC1a) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@nQC1a AS FLOAT) * 100/ NULLIF(@TotalNumberOfFamiliesAtIntakeQuarterly,0), 0), 0))  + '%)' )
						
			
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('','', '') --insert empty row

			-- Q2
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('2. Target Child(ren)', @nQ2, @nQC2)
			
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('		a. Under 3 months'
			,CONVERT(VARCHAR,@nQ2a) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@nQ2a AS FLOAT) * 100/ NULLIF(@nQ2,0), 0), 0))  + '%)',
			CONVERT(VARCHAR,@nQC2a) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@nQC2a AS FLOAT) * 100/ NULLIF(@nQC2,0), 0), 0))  + '%)' )
						
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('		b. 3 months up to 1 year'		
			,CONVERT(VARCHAR,@nQ2b) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@nQ2b AS FLOAT) * 100/ NULLIF(@nQ2,0), 0), 0))  + '%)',		
			CONVERT(VARCHAR,@nQC2b) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@nQC2b AS FLOAT) * 100/ NULLIF(@nQC2,0), 0), 0))  + '%)' )
			
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('		c. 1 year up to 2 years'
			,CONVERT(VARCHAR,@nQ2c) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@nQ2c AS FLOAT) * 100/ NULLIF(@nQ2,0), 0), 0))  + '%)',		
			CONVERT(VARCHAR,@nQC2c) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@nQC2c AS FLOAT) * 100/ NULLIF(@nQC2,0), 0), 0))  + '%)' )
			 
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('		d. 2 years up to 3 years'
			,CONVERT(VARCHAR,@nQ2d) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@nQ2d AS FLOAT) * 100/ NULLIF(@nQ2,0), 0), 0))  + '%)',		
			CONVERT(VARCHAR,@nQC2d) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@nQC2d AS FLOAT) * 100/ NULLIF(@nQC2,0), 0), 0))  + '%)' )
			
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('		e. 3 years up to 4 years'
			,CONVERT(VARCHAR,@nQ2e) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@nQ2e AS FLOAT) * 100/ NULLIF(@nQ2,0), 0), 0))  + '%)',		
			CONVERT(VARCHAR,@nQC2e) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@nQC2e AS FLOAT) * 100/ NULLIF(@nQC2,0), 0), 0))  + '%)' )
			
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('		f. 4 years up to 5 years'
			,CONVERT(VARCHAR,@nQ2f) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@nQ2f AS FLOAT) * 100/ NULLIF(@nQ2,0), 0), 0))  + '%)',	
			CONVERT(VARCHAR,@nQC2f) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@nQC2f AS FLOAT) * 100/ NULLIF(@nQC2,0), 0), 0))  + '%)' )
			
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('		g. Over 5 years'
			,CONVERT(VARCHAR,@nQ2g) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@nQ2g AS FLOAT) * 100/ NULLIF(@nQ2,0), 0), 0))  + '%)',		
			CONVERT(VARCHAR,@nQC2g) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@nQC2g AS FLOAT) * 100/ NULLIF(@nQC2,0), 0), 0))  + '%)' )
	
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('','', '') --insert empty row
	
	
			-- Q3
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('3. Primary Caretaker 1 Age', @nQ3, @nQC3)
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('		a. Under 18 years'
			,CONVERT(VARCHAR,@nQ3a) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@nQ3a AS FLOAT) * 100/ NULLIF(@nQ3,0), 0), 0))  + '%)',
			CONVERT(VARCHAR,@nQC3a) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@nQC3a AS FLOAT) * 100/ NULLIF(@nQC3,0), 0), 0))  + '%)' )
			
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('		b. 18 up to 20'
			,CONVERT(VARCHAR,@nQ3b) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@nQ3b AS FLOAT) * 100/ NULLIF(@nQ3,0), 0), 0))  + '%)',
			CONVERT(VARCHAR,@nQC3b) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@nQC3b AS FLOAT) * 100/ NULLIF(@nQC3,0), 0), 0))  + '%)' )
			
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('		c. 20 up to 30'
			,CONVERT(VARCHAR,@nQ3c) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@nQ3c AS FLOAT) * 100/ NULLIF(@nQ3,0), 0), 0))  + '%)',
			CONVERT(VARCHAR,@nQC3c) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@nQC3c AS FLOAT) * 100/ NULLIF(@nQC3,0), 0), 0))  + '%)' )
			
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('		d. Over 30'
			,CONVERT(VARCHAR,@nQ3d) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@nQ3d AS FLOAT) * 100/ NULLIF(@nQ3,0), 0), 0))  + '%)',
			CONVERT(VARCHAR,@nQC3d) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@nQC3d AS FLOAT) * 100/ NULLIF(@nQC3,0), 0), 0))  + '%)' )


			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('','', '') --insert empty row
	
			-- Q4
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('4. Primary Caretaker 1 Education', @nQ3, '')
			
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('		a. Less than 12 years'
			,CONVERT(VARCHAR,@nQ4a) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@nQ4a AS FLOAT) * 100/ NULLIF(@nQ4,0), 0), 0))  + '%)', '')
	
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('		b. High School Graduate / GED'
			,CONVERT(VARCHAR,@nQ4b) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@nQ4b AS FLOAT) * 100/ NULLIF(@nQ4,0), 0), 0))  + '%)', '')

			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('		c. Post Secondary'
			,CONVERT(VARCHAR,@nQ4c) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@nQ4c AS FLOAT) * 100/ NULLIF(@nQ4,0), 0), 0))  + '%)', '')	
	
	
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('','', '') --insert empty row

			-- Q5			
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('5. Primary Caretaker 1 Married'
			,CONVERT(VARCHAR,@nQ5) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@nQ5 AS FLOAT) * 100/ NULLIF(@TotalNumberOfFamiliesAtIntakeQuarterly,0), 0), 0))  + '%)', '')
			

			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('','', '') --insert empty row

	
			-- Q6				
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('6. Primary Caretaker 1 Race', @nQ6, '')	
				
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('     a. White'
			,CONVERT(VARCHAR,@nQ6a) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@nQ6a AS FLOAT) * 100/ NULLIF(@nQ6,0), 0), 0))  + '%)', '')
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('     b. Black'
			,CONVERT(VARCHAR,@nQ6b) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@nQ6b AS FLOAT) * 100/ NULLIF(@nQ6,0), 0), 0))  + '%)', '')
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('     c. Hispanic'
			,CONVERT(VARCHAR,@nQ6c) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@nQ6c AS FLOAT) * 100/ NULLIF(@nQ6,0), 0), 0))  + '%)', '')
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('     d. Asian'
			,CONVERT(VARCHAR,@nQ6d) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@nQ6d AS FLOAT) * 100/ NULLIF(@nQ6,0), 0), 0))  + '%)', '')
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('     e. Native American'
			,CONVERT(VARCHAR,@nQ6e) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@nQ6e AS FLOAT) * 100/ NULLIF(@nQ6,0), 0), 0))  + '%)', '')
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('     f. Other race'
			,CONVERT(VARCHAR,@nQ6f) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@nQ6f AS FLOAT) * 100/ NULLIF(@nQ6,0), 0), 0))  + '%)', '')
			

			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('','', '') --insert empty row
	
			-- Q7				
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('7. Household Composition', @nQ7, '')	
				
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('     a. Bio Parents living with TC'
			,CONVERT(VARCHAR,@nQ7a) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@nQ7a AS FLOAT) * 100/ NULLIF(@nQ7,0), 0), 0))  + '%)', '')
	
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('     b. Other Support (OBP/PC2) living in household'
			,CONVERT(VARCHAR,@nQ7b) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@nQ7b AS FLOAT) * 100/ NULLIF(@nQ7,0), 0), 0))  + '%)', '')

			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('     c. First time mother (No other children)'
			,CONVERT(VARCHAR,@nQ7c) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@nQ7c AS FLOAT) * 100/ NULLIF(@nQ7,0), 0), 0))  + '%)', '')

			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('     d. Other Bio Children in Foster Care'
			,CONVERT(VARCHAR,@nQ7d) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@nQ7d AS FLOAT) * 100/ NULLIF(@nQ7,0), 0), 0))  + '%)', '')

			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('','', '') --insert empty row


			-- Q8				
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('8. Employment, Education and training', @nQ8, '')	
				
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('     a. Primary Caretaker 1 Employed'
			,CONVERT(VARCHAR,@nQ8a) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@nQ8a AS FLOAT) * 100/ NULLIF(@nQ8,0), 0), 0))  + '%)', '')
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('     b. Other Biological Parent / Primary Caretaker 2 Employed'
			,CONVERT(VARCHAR,@nQ8b) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@nQ8b AS FLOAT) * 100/ NULLIF(@nQ8,0), 0), 0))  + '%)', '')
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('     c. Either PC1 or OBP/PC2 Employed'
			,CONVERT(VARCHAR,@nQ8c) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@nQ8c AS FLOAT) * 100/ NULLIF(@nQ8,0), 0), 0))  + '%)', '')
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('     d. PC1 in Education / Training Program'
			,CONVERT(VARCHAR,@nQ8d) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@nQ8d AS FLOAT) * 100/ NULLIF(@nQ8,0), 0), 0))  + '%)', '')
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('     e. OBP/PC2 in Education / Training Program'
			,CONVERT(VARCHAR,@nQ8e) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@nQ8e AS FLOAT) * 100/ NULLIF(@nQ8,0), 0), 0))  + '%)', '')

			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('','', '') --insert empty row

			-- Q9				
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('9. Benefits Receiving', @nQ9, '')	
				
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('     a. TANF'
			,CONVERT(VARCHAR,@nQ9a) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@nQ9a AS FLOAT) * 100/ NULLIF(@nQ9,0), 0), 0))  + '%)', '')
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('     b. Food Stamps'
			,CONVERT(VARCHAR,@nQ9b) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@nQ9b AS FLOAT) * 100/ NULLIF(@nQ9,0), 0), 0))  + '%)', '')

			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('','', '') --insert empty row

			-- Q10				
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('10. TANF Services Eligibility', @nQ10, '')	
				
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('     a. % Eligible for TANF Services'
			,CONVERT(VARCHAR,@nQ10a) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@nQ10a AS FLOAT) * 100/ NULLIF(@nQ10,0), 0), 0))  + '%)', '')

			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('','', '') --insert empty row
	
			-- Q11				
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('11. PC1 Medical Insurance and Medical Provider', @nQ11, '')	
				
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('     a. Primary Caretaker 1 on Medicaid'
			,CONVERT(VARCHAR,@nQ11a) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@nQ11a AS FLOAT) * 100/ NULLIF(@nQ11,0), 0), 0))  + '%)', '')
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('     b. Primary Caretaker 1 has No Health Insurance'
			,CONVERT(VARCHAR,@nQ11b) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@nQ11b AS FLOAT) * 100/ NULLIF(@nQ11,0), 0), 0))  + '%)', '')
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('     c. Primary Caretaker 1 has Medical Provider'
			,CONVERT(VARCHAR,@nQ11c) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@nQ11c AS FLOAT) * 100/ NULLIF(@nQ11,0), 0), 0))  + '%)', '')

			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('','', '') --insert empty row

			-- Q12				
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('12. TC Medical Insurance and Medical Provider by case', @nQ12, '')	
				
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('     a. Target Child on Medicaid'
			,CONVERT(VARCHAR,@nQ12a) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@nQ12a AS FLOAT) * 100/ NULLIF(@nQ12,0), 0), 0))  + '%)', '')
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('     b. Target Child has No Health Insurance'
			,CONVERT(VARCHAR,@nQ12b) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@nQ12b AS FLOAT) * 100/ NULLIF(@nQ12,0), 0), 0))  + '%)', '')
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('     c. Target Child has Medical Provider'
			,CONVERT(VARCHAR,@nQ12c) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@nQ12c AS FLOAT) * 100/ NULLIF(@nQ12,0), 0), 0))  + '%)', '')

			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('','', '') --insert empty row

			-- Q13				
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('13. Length in Program', 'N/A', '')	
				
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('     a. Less than 3 Months'
			,'', '')
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('     b. 3 Months up to 6 Months'
			,'', '')
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('     c. 6 Months up to 1 Year'
			,'', '')
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('     d. 1 Year up to 2 Years'
			,'', '')
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('     e. 2 Years up to 3 Years'
			,'', '')
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('     f. 3 Years up to 4 Year'
			,'', '')
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('     g. 4 Years up to 5 Years'
			,'', '')
			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('     h. Over 5 Years'
			,'', '')

			INSERT INTO @tblMainResult([Text],[QuarterlyData],[MostCurrentData])VALUES('','', '') --insert empty row

	
	
	END
	
SELECT * FROM @tblMainResult	
	
END

GO
