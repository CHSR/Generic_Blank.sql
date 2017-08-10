SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <Febu. 11, 2013>
-- Description:	<This report gets you 'A. Data report '>
-- rspDataReport_bak20140602 22, '03/01/2013', '05/31/2013'		

-- Fix: Pre-Intake Enroll completed 03/27/13
-- Added ability to run report for all the HFNY Programs  02/20/2014

-- exec [rspDataReport_bak20140602] ',8,','09/01/2013' , '12/31/2013'

-- exec [rspDataReport_bak20140602] ',16,','09/01/2013' , '5/31/2014'

-- =============================================

CREATE procedure [dbo].[rspDataReport_bak20140602]
(
    @ProgramFKs				varchar(max)    = null,
    @StartDate				datetime,
    @EndDate				datetime

)
as
begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set nocount on;
	
	if @ProgramFKs is null
	begin
		select @ProgramFKs = substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end

	set @ProgramFKs = REPLACE(@ProgramFKs,'"','')	
	


	-- main report
	declare @tbl4DataReport table(	
		ReportTitle [varchar](500),
		Total [varchar](10)
	)


-- SCREEN------1 @ BEGINNING OF MONTH

	declare @tbl4DataReportRow1 table(
	HVCasePK INT
	)

	INSERT INTO @tbl4DataReportRow1
	(
		HVCasePK

	)
	SELECT h.HVCasePK FROM HVCase h
	INNER JOIN CaseProgram cp ON cp.HVCaseFK = h.HVCasePK
	inner join dbo.SplitString(@ProgramFKs,',') on cp.programfk = listitem
	INNER JOIN HVScreen h1 ON h1.HVCaseFK = cp.HVCaseFK AND h1.ProgramFK = cp.ProgramFK
	
	WHERE h1.ScreenDate < @StartDate
	AND (h.KempeDate >= @StartDate OR h.KempeDate IS NULL)
	AND (cp.DischargeDate >= @StartDate OR cp.DischargeDate IS NULL)

	DECLARE @nposScreens INT 
	SET @nposScreens = (SELECT count(HVCasePK) FROM @tbl4DataReportRow1)


	-- Start of SCREEN-----2 @ NEW DURING MONTH  ----------
	declare @tbl4DataReportRow2 table(
	HVCasePK INT,
	ReferralMade [varchar](1),
	ScreenResult [varchar](1)
	)

	INSERT INTO @tbl4DataReportRow2
	(
		HVCasePK,
		ReferralMade,
		ScreenResult
	)
	SELECT h.HVCasePK,H1.ReferralMade,h1.ScreenResult FROM HVCase h
	INNER JOIN CaseProgram cp ON cp.HVCaseFK = h.HVCasePK
	inner join dbo.SplitString(@ProgramFKs,',') on cp.programfk = listitem
	INNER JOIN HVScreen h1 ON h1.HVCaseFK = h.HVCasePK AND h1.ProgramFK = cp.ProgramFK
	WHERE h1.ScreenDate >= @StartDate AND h1.ScreenDate <= @EndDate
	--AND cp.ProgramFK = @ProgramFKs
	
	
	DECLARE @n2a INT 
	SET @n2a = (SELECT count(HVCasePK) FROM @tbl4DataReportRow2 WHERE ReferralMade = '1')
	

	-- Start-----3 @ Kempes this month  ----------
	declare @tbl4DataReportRow3 table(
	HVCasePK INT,
	KempeResult BIT,
	CaseStatus [varchar](2)
	)

	INSERT INTO @tbl4DataReportRow3
	(
		HVCasePK,
		KempeResult,
		CaseStatus
	)
	SELECT h.HVCasePK,p.KempeResult, p.CaseStatus FROM HVCase h		  
	inner join CaseProgram cp on cp.HVCaseFK = h.HVCasePK	
	inner join dbo.SplitString(@ProgramFKs,',') on cp.programfk = listitem
	INNER JOIN Preassessment p ON p.HVCaseFK = h.HVCasePK AND p.ProgramFK = cp.ProgramFK
	LEFT JOIN Kempe k ON k.HVCaseFK = h.HVCasePK
	WHERE k.KempeDate BETWEEN @StartDate AND @EndDate	
	and p.KempeResult = 1
	AND cp.CaseStartDate <= @EndDate	
	AND p.CaseStatus IN ('02')	



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
	
	DECLARE @n3 INT 
	SET @n3 = (SELECT count(HVCasePK) FROM @tbl4DataReportRow3)
	
	DECLARE @n3a INT 
	SET @n3a = (SELECT count(HVCasePK) FROM @tbl4DataReportRow3)


	-- Start -----4 @ Screens Terminated this month  ----------
	
	declare @tbl4DataReportRow4 table(
	HVCasePK INT
	)

	INSERT INTO @tbl4DataReportRow4
	(
		HVCasePK
	)
	SELECT h.HVCasePK FROM HVCase h
	INNER JOIN CaseProgram cp ON cp.HVCaseFK = h.HVCasePK
	inner join dbo.SplitString(@ProgramFKs,',') on cp.programfk = listitem
	INNER JOIN Preassessment p ON p.HVCaseFK = h.HVCasePK AND p.ProgramFK = cp.ProgramFK
	WHERE p.PADate >= @StartDate AND p.PADate <= @EndDate
	--AND cp.ProgramFK = @ProgramFKs
	AND p.CaseStatus = '03'	

	DECLARE @n4 INT 
	SET @n4 = (SELECT count(HVCasePK) FROM @tbl4DataReportRow4)


	-- Start -----PRE-INTAKE-------6 @ BEGINNING OF MONTH  ----------
	declare @tbl4DataReportRow6 table(
	HVCasePK INT
	)

	INSERT INTO @tbl4DataReportRow6
	(
		HVCasePK
	)
	SELECT h.HVCasePK FROM HVCase h
	INNER JOIN CaseProgram cp ON cp.HVCaseFK = h.HVCasePK
	inner join dbo.SplitString(@ProgramFKs,',') on cp.programfk = listitem
	INNER JOIN Preassessment p ON p.HVCaseFK = h.HVCasePK AND p.ProgramFK = cp.ProgramFK
	WHERE p.FSWAssignDate <= @StartDate
	AND p.CaseStatus = '02'	
	AND KempeResult = 1
	AND (h.IntakeDate  >= @StartDate OR h.IntakeDate IS NULL)
	AND cp.CaseStartDate <= @EndDate  -- handling transfer cases
	AND (cp.DischargeDate >= @StartDate OR cp.DischargeDate IS NULL)	

	DECLARE @n6 INT 
	SET @n6 = (SELECT count(HVCasePK) FROM @tbl4DataReportRow6)	
	
	
	
	SELECT * FROM HVCase h
	INNER JOIN CaseProgram cp ON cp.HVCaseFK = h.HVCasePK
	inner join dbo.SplitString(@ProgramFKs,',') on cp.programfk = listitem
	INNER JOIN Preassessment p ON p.HVCaseFK = h.HVCasePK AND p.ProgramFK = cp.ProgramFK
	WHERE p.FSWAssignDate <= @StartDate
	AND p.CaseStatus = '02'	
	AND KempeResult = 1
	AND (h.IntakeDate  >= @StartDate OR h.IntakeDate IS NULL)
	AND cp.CaseStartDate <= @EndDate  -- handling transfer cases
	AND (cp.DischargeDate >= @StartDate OR cp.DischargeDate IS NULL)
	order by h.HVCasePK 
	
	
	-- exec [rspDataReport_bak20140602] ',16,','09/01/2013' , '5/31/2014'
	
	
	
	
	
	
	
	---- Start -----PRE-INTAKE-------8 TERM DURING MONTH	
	declare @tbl4DataReportRow8 table(
	HVCasePK INT
	)

	INSERT INTO @tbl4DataReportRow8
	(
		HVCasePK
	)
	SELECT h.HVCasePK FROM HVCase h
	INNER JOIN CaseProgram cp ON cp.HVCaseFK = h.HVCasePK
	inner join dbo.SplitString(@ProgramFKs,',') on cp.programfk = listitem
	--INNER JOIN Preintake pre ON pre.HVCaseFK = h.HVCasePK
	left join codeLevel on cp.CurrentLevelFK = codeLevel.codeLevelPK
	WHERE 
	--cp.ProgramFK = @ProgramFKs
	--AND pre.CaseStatus = '03'
	--and 
	codeLevel.LevelName = 'Preintake-term'
	AND cp.CaseStartDate < @EndDate  -- handling transfer cases	
	AND (cp.DischargeDate >= @StartDate AND cp.DischargeDate <= @EndDate AND cp.DischargeDate IS NOT NULL)

	DECLARE @n8 INT 
	SET @n8 = (SELECT count(HVCasePK) FROM @tbl4DataReportRow8)		
	
	---- Start -----PRE-INTAKE------9 ENROLLED DURING MONTH
	declare @tbl4DataReportRow9 table(
	HVCasePK INT
	)

	INSERT INTO @tbl4DataReportRow9
	(
		HVCasePK
	)
	SELECT h.HVCasePK FROM HVCase h
	INNER JOIN CaseProgram cp ON cp.HVCaseFK = h.HVCasePK
	inner join dbo.SplitString(@ProgramFKs,',') on cp.programfk = listitem
	WHERE 
	--cp.ProgramFK = @ProgramFKs
	--AND 
	(h.IntakeDate >= @StartDate AND h.IntakeDate <= @EndDate)
	AND cp.CaseStartDate < @EndDate  -- handling transfer cases
	

	DECLARE @n9 INT 
	SET @n9 = (SELECT count(HVCasePK) FROM @tbl4DataReportRow9)		
	
	
	---- Start -----Active Families-------11 at beginning
	declare @tbl4DataReportRow11 table(
	HVCasePK INT
	)

	INSERT INTO @tbl4DataReportRow11
	(
		HVCasePK
	)
	SELECT h.HVCasePK  FROM HVCase h
	INNER JOIN CaseProgram cp ON cp.HVCaseFK = h.HVCasePK
	inner join dbo.SplitString(@ProgramFKs,',') on cp.programfk = listitem
	WHERE 
	--cp.ProgramFK = @ProgramFKs
	--AND 
	h.IntakeDate < @StartDate 
	AND h.IntakeDate IS NOT NULL
	AND cp.CaseStartDate < @EndDate  -- handling transfer cases
	AND (cp.DischargeDate >= @StartDate OR cp.DischargeDate IS NULL)
	

	DECLARE @n11 INT 
	SET @n11 = (SELECT count(HVCasePK) FROM @tbl4DataReportRow11)	

-- rspDataReport_bak20140602 5, '06/01/2012', '09/30/2012'		

	---- Start -----Active  Families--------12a/b enrolled this month
	declare @tbl4DataReportRow12 table(
		HVCasePK INT,
		Prenatal INT,
		Postnatal INT,
		ProgramFK INT
	)

	INSERT INTO @tbl4DataReportRow12
	(
		HVCasePK,
		Prenatal,
		Postnatal,
		ProgramFK
	)
	SELECT h.HVCasePK,	 
	   CASE WHEN ((h.tcdob is not NULL AND h.tcdob > h.IntakeDate) OR (h.tcdob is NULL AND h.edc > h.IntakeDate)) THEN 1 ELSE 0 END AS Prenatal
	 , CASE WHEN (h.tcdob is not NULL AND h.tcdob <= h.IntakeDate) THEN 1 ELSE 0 END AS Postnatal	 
	 
	 , cp.ProgramFK

	
	 FROM HVCase h
	INNER JOIN CaseProgram cp ON cp.HVCaseFK = h.HVCasePK
	inner join dbo.SplitString(@ProgramFKs,',') on cp.programfk = listitem
	WHERE 	
 --   cp.ProgramFK = @ProgramFKs
	--AND 
	h.IntakeDate >= @StartDate 
	AND h.IntakeDate <= @EndDate 	
	AND cp.CaseStartDate < @EndDate  -- handling transfer cases
	

	

	DECLARE @n12 INT 
	SET @n12 = (SELECT count(HVCasePK) AS count1  FROM @tbl4DataReportRow12)	

	DECLARE @n12a INT 
	SET @n12a = (SELECT sum(Prenatal) AS Prenatal  FROM @tbl4DataReportRow12)	
	DECLARE @n12b INT 
	SET @n12b = (SELECT sum(Postnatal) AS Postnatal FROM @tbl4DataReportRow12)	



	---- Start -----Active Families--------13
	declare @tbl4DataReportRow13 table(
	HVCasePK INT
	)

	INSERT INTO @tbl4DataReportRow13
	(
		HVCasePK
	)
	SELECT h.HVCasePK FROM HVCase h
	INNER JOIN CaseProgram cp ON cp.HVCaseFK = h.HVCasePK
	inner join dbo.SplitString(@ProgramFKs,',') on cp.programfk = listitem
	WHERE 
	--cp.ProgramFK = @ProgramFKs
	--and
	 cp.DischargeDate >= @StartDate 
	AND cp.DischargeDate <= @EndDate 	
	AND h.IntakeDate IS NOT null
	AND cp.CaseStartDate < @EndDate  -- handling transfer cases
	

	DECLARE @n13 INT 
	SET @n13 = (SELECT count(HVCasePK) FROM @tbl4DataReportRow13)	


	------ Start -----Active Families-----14 at end of month
	declare @tbl4DataReportRow14 table(
	HVCasePK INT,
	IntakePK INT,
	ProgramFK INT, 
	PBTANF [char](1),
	CurrentLevelFK INT 
	)

	INSERT INTO @tbl4DataReportRow14
	(
		HVCasePK,
		IntakePK,
		ProgramFK,
		PBTANF,
		CurrentLevelFK
		
	)	
	SELECT HVCasePK, IntakePK, cp.ProgramFK, PBTANF, CurrentLevelFK  FROM HVCase h
	INNER JOIN CaseProgram cp ON cp.HVCaseFK = h.HVCasePK
	inner join dbo.SplitString(@ProgramFKs,',') on cp.programfk = listitem
	LEFT JOIN Intake i ON i.HVCaseFK = h.HVCasePK
	LEFT JOIN CommonAttributes ca ON ca.FormFK = i.IntakePK and ca.FormType = 'IN'  -- to get PBTANF, item 26 on the intake form
	
	WHERE 
	--cp.ProgramFK = @ProgramFKs
	--AND 
	(
	(h.IntakeDate IS NOT NULL AND h.IntakeDate <= @EndDate)
	AND (cp.DischargeDate IS NULL OR cp.DischargeDate > @EndDate)
	AND cp.CaseStartDate < @EndDate  -- handling transfer cases	
	)
	OR 
	(CurrentLevelFK = 8 AND h.IntakeDate BETWEEN @StartDate AND @EndDate)



	DECLARE @n14a INT 
	SET @n14a = (SELECT sum(CASE WHEN PBTANF = '1' THEN 1 ELSE 0 END) AS PBTANF FROM @tbl4DataReportRow14)	

	DECLARE @n14a1 INT 
	SET @n14a1 = (SELECT sum(CASE WHEN IntakePK IS NOT NULL THEN 1 ELSE 0 END) AS totalIntakesCompleted FROM @tbl4DataReportRow14)	

	------ Start -----Active Families---figure out levels 
	
	declare @tbl4DataReportRow14RestOfIt table(
	LevelName [char](50),
	levelCount INT
	)	
	
	
	;
	
	WITH cteDataReportRow14RestOfIt AS
	(
	SELECT 
	CASE WHEN CurrentLevelFK = 8 THEN 'Preintake-enroll' ELSE LevelName END AS LevelName, 	
	CASE WHEN hvlevelpk IS NOT NULL OR CurrentLevelFK = 8 THEN 1 ELSE 0 END AS levelcount
	
	FROM @tbl4DataReportRow14 t14
			left join (select hvlevel.hvlevelpk
							 ,hvlevel.hvcasefk
							 ,hvlevel.programfk
							 ,hvlevel.levelassigndate
							 ,levelname
							 ,caseweight							 
						   from hvlevel
							   inner join codelevel on codelevelpk = levelfk
							   inner join (select hvcasefk
												 ,programfk
												 ,max(levelassigndate) as levelassigndate
											   from hvlevel h2
											   where levelassigndate <= @EndDate
											   group by hvcasefk
													   ,programfk) e2 on e2.hvcasefk = hvlevel.hvcasefk and e2.programfk = hvlevel.programfk and e2.levelassigndate = hvlevel.levelassigndate)
													    e3 on e3.hvcasefk = t14.hvcasepk and e3.programfk = t14.programfk
				
	)

	INSERT INTO @tbl4DataReportRow14RestOfIt
	(
	LevelName,
	levelCount
	)	
	SELECT 
		   lr.LevelName
		  ,CASE when levelCount IS NOT NULL THEN 1 ELSE 0 END AS levelCount
		  FROM cteDataReportRow14RestOfIt	t14Rest
	RIGHT JOIN (SELECT [LevelName] FROM [codeLevel] WHERE ((LevelName LIKE 'level%' AND Enrolled = 1) OR LevelName LIKE 'Preintake-enroll'))  lr ON lr.LevelName = t14Rest.LevelName  -- add missing levelnames
	ORDER BY LevelName 
	
	DECLARE @n14b INT 
	SET @n14b = (SELECT sum(CASE when levelCount IS NOT NULL THEN 1 ELSE 0 END) AS tlevelCount FROM @tbl4DataReportRow14RestOfIt WHERE LevelName = 'Preintake-enroll')	
	IF @n14b IS NULL BEGIN SET @n14b = 0 END 


	DECLARE @n14c INT 
	SET @n14c = (SELECT sum(levelCount) AS tlevelCount FROM @tbl4DataReportRow14RestOfIt WHERE LevelName = 'Level 1-Prenatal')	
	DECLARE @n14d INT 
	SET @n14d = (SELECT sum(levelCount) AS tlevelCount FROM @tbl4DataReportRow14RestOfIt WHERE LevelName = 'Level 1-SS')	
	DECLARE @n14e INT 
	SET @n14e = (SELECT sum(levelCount) AS tlevelCount FROM @tbl4DataReportRow14RestOfIt WHERE LevelName = 'Level 1')	
	DECLARE @n14f INT 
	SET @n14f = (SELECT sum(levelCount) AS tlevelCount FROM @tbl4DataReportRow14RestOfIt WHERE LevelName = 'Level 2')	
	DECLARE @n14g INT 
	SET @n14g = (SELECT sum(levelCount) AS tlevelCount FROM @tbl4DataReportRow14RestOfIt WHERE LevelName = 'Level 3')	
	DECLARE @n14h INT 
	SET @n14h = (SELECT sum(levelCount) AS tlevelCount FROM @tbl4DataReportRow14RestOfIt WHERE LevelName = 'Level 4')	
	DECLARE @n14i INT 
	SET @n14i = (SELECT sum(levelCount) AS tlevelCount FROM @tbl4DataReportRow14RestOfIt WHERE LevelName = 'Level X')	

	



--SELECT * FROM  @tbl4DataReportRow14RestOfIt
-- rspDataReport_bak20140602 2, '02/01/2013', '02/28/2013'			

INSERT INTO @tbl4DataReport(ReportTitle,Total)
VALUES('SCREEN (PRE-ASSESSMENT) AND ASSESSMENT SUMMARY', '')
	
INSERT INTO @tbl4DataReport(ReportTitle,Total)
VALUES ('1.  Positive Screens Pending Assessment at Beginning of this Period', @nposScreens)



INSERT INTO @tbl4DataReport(ReportTitle,Total)
VALUES('2.  New Screens this Period', (SELECT count(HVCasePK) FROM @tbl4DataReportRow2))

INSERT INTO @tbl4DataReport(ReportTitle,Total)
VALUES('    2a. Positive Screens Referred for Assessment', @n2a)
INSERT INTO @tbl4DataReport(ReportTitle,Total)
VALUES('    2b. Positive Screens Not Referred for Assessment', (SELECT count(HVCasePK) FROM @tbl4DataReportRow2 WHERE ReferralMade = '0' AND ScreenResult = '1'))
INSERT INTO @tbl4DataReport(ReportTitle,Total)
VALUES('    2c. Negative Screens', (SELECT count(HVCasePK) FROM @tbl4DataReportRow2 WHERE ScreenResult = '0'))

INSERT INTO @tbl4DataReport(ReportTitle,Total)
VALUES('3.  Kempe Assessments this Period', @n3)
INSERT INTO @tbl4DataReport(ReportTitle,Total)
VALUES('    3a. Positive Kempe Assigned ( or Pending Assignment) to FSW', @n3a)
INSERT INTO @tbl4DataReport(ReportTitle,Total)
VALUES('    3b. Positive Kempe Assessments Not Assigned to FSW - Terminated', (SELECT count(HVCasePK) FROM @tbl4DataReportRow3 WHERE CaseStatus = '04'))
INSERT INTO @tbl4DataReport(ReportTitle,Total)
VALUES('    3c. Negative Kempe Assessment', (SELECT count(HVCasePK) FROM @tbl4DataReportRow3 WHERE CaseStatus = '02' AND KempeResult = 0))


INSERT INTO @tbl4DataReport(ReportTitle,Total)
VALUES('4.  Screens Terminated on Pre-Assessment Form this Period', @n4)

INSERT INTO @tbl4DataReport(ReportTitle,Total)
VALUES('5.  Screens Pending Assessment at End of this Period ([(1+2a) - (3+4)])', (@nposScreens + @n2a) - (@n3 + @n4))


INSERT INTO @tbl4DataReport(ReportTitle,Total)
VALUES('', '')
INSERT INTO @tbl4DataReport(ReportTitle,Total)
VALUES('PRE-INTAKE (POST-ASSESSMENT) SUMMARY', '')



INSERT INTO @tbl4DataReport(ReportTitle,Total)
VALUES('6.  Pre-Intake Families at Beginning of this Period (Participants Pending Enrollment at Beginning of this Period)', @n6)

INSERT INTO @tbl4DataReport(ReportTitle,Total)
VALUES('7.  New Pre-Intake Families this Period (Same as 3a above)', @n3a)

INSERT INTO @tbl4DataReport(ReportTitle,Total)
VALUES('8.  Families Terminated on Pre-Intake Form this Period', @n8)

INSERT INTO @tbl4DataReport(ReportTitle,Total)
VALUES('9.  Families Enrolled on Pre-Intake Form this Period', @n9)

INSERT INTO @tbl4DataReport(ReportTitle,Total)
VALUES('10.  Pre-Intake Families at the End of this Period ([(6+7) - (8+9)])', (@n6 + @n3a) - (@n8 + @n9))

INSERT INTO @tbl4DataReport(ReportTitle,Total)
VALUES('', '')
INSERT INTO @tbl4DataReport(ReportTitle,Total)
VALUES('ENROLLED FAMILIES', '')


-- Enrolled Families
INSERT INTO @tbl4DataReport(ReportTitle,Total)
VALUES('11.  Enrolled Families at the Beginning of this Period', @n11)

INSERT INTO @tbl4DataReport(ReportTitle,Total)
VALUES('12.  Families Enrolled this Period', @n12)
INSERT INTO @tbl4DataReport(ReportTitle,Total)
VALUES('    12a. Prenatal at Enrollment*', @n12a)
INSERT INTO @tbl4DataReport(ReportTitle,Total)
VALUES('    12b. Postnatal at Enrollment*', @n12b)

INSERT INTO @tbl4DataReport(ReportTitle,Total)
VALUES('13. Enrolled Families Discharged this Period', @n13)

INSERT INTO @tbl4DataReport(ReportTitle,Total)
VALUES('14.  Enrolled Families at the End of this Period ([(11+12) - 13])', (@n11 + @n12) - @n13)

INSERT INTO @tbl4DataReport(ReportTitle,Total)
VALUES('     a. Receiving TANF at Enrollment (Item 26 on the Intake Form)', @n14a)
INSERT INTO @tbl4DataReport(ReportTitle,Total)
VALUES('       a1. Active Families with Intake Form Completed', @n14a1)

INSERT INTO @tbl4DataReport(ReportTitle,Total)
VALUES('       b. Pre-Intake Enroll', @n14b)

INSERT INTO @tbl4DataReport(ReportTitle,Total)VALUES('       c. Level 1-Prenatal', @n14c)
INSERT INTO @tbl4DataReport(ReportTitle,Total)VALUES('       d. Level 1-SS', @n14d)
INSERT INTO @tbl4DataReport(ReportTitle,Total)VALUES('       e. Level 1', @n14e)
INSERT INTO @tbl4DataReport(ReportTitle,Total)VALUES('       f. Level 2', @n14f)
INSERT INTO @tbl4DataReport(ReportTitle,Total)VALUES('       g. Level 3', @n14g)
INSERT INTO @tbl4DataReport(ReportTitle,Total)VALUES('       h. Level 4', @n14h)
INSERT INTO @tbl4DataReport(ReportTitle,Total)VALUES('       i. Level X', @n14i)

INSERT INTO @tbl4DataReport(ReportTitle,Total)
VALUES('15.  Pre-Intake and Enrolled Families at the End of this Period (10+14)', (@n6 + @n3a) - (@n8 + @n9) + (@n11 + @n12) - @n13 )


-- rspDataReport_bak20140602 5, '06/01/2012', '09/30/2012'			


	SELECT * FROM @tbl4DataReport	
	



	


end
GO
