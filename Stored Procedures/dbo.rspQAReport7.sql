SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <November 16th, 2012>
-- Description:	<This QA report gets you 'ASQs for Active Cases with Target Child 4 months or older, calc. DOB '>
-- rspQAReport7 3, 'summary'	--- for summary page
-- rspQAReport7 1			--- for main report - location = 1
-- rspQAReport7 null			--- for main report for all locations
-- =============================================


CREATE procedure [dbo].[rspQAReport7](
@programfk    varchar(max)    = NULL,
@ReportType char(7) = NULL 

)with recompile
AS
	if @programfk is null
	begin
		select @programfk = substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end

	set @programfk = REPLACE(@programfk,'"','')

-- Last Day of Previous Month 
Declare @LastDayofPreviousMonth DateTime 
Set @LastDayofPreviousMonth = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE()),0)) -- analysis point

--Set @LastDayofPreviousMonth = '10/31/2012'

-- table variable for holding Init Required Data
DECLARE @tbl4QAReport7Detail TABLE(
	HVCasePK INT, 
	[PC1ID] [char](13),	
	TCDOB [datetime],
	FormDueDate [datetime],	
	Worker [varchar](200),
	currentLevel [varchar](50),
	IntakeDate [datetime],
	DischargeDate [datetime],
	CaseProgress [NUMERIC] (3),
	XDateAge INT,
	TCNumber INT,
	MultipleBirth [char](3),	
	DevAge INT,
	GestationalAge INT,
	AgeInDays INT,
	TCDOD [datetime],
	TCIDPK INT, 
	TCName [varchar](200),
	Missing BIT,
	OutOfWindow BIT,
	RecOK BIT
)



;
WITH cteMainReport7 AS
(
select 
	 h.HVCasePK, 
	cp.PC1ID,
	case
	   when h.tcdob is not null then
		   h.tcdob
	   else
		   h.edc
	end as tcdob,

	-- Form due date is intake date plus 30.44 days
	dateadd(mm,1,h.IntakeDate) as FormDueDate,
	
	LTRIM(RTRIM(fsw.firstname))+' '+LTRIM(RTRIM(fsw.lastname)) as worker,

	codeLevel.LevelName,
	h.IntakeDate,
	cp.DischargeDate,
	h.CaseProgress,
	case
	   when h.tcdob is not null then
		 datediff(dd, h.tcdob,  @LastDayofPreviousMonth)
	   else
		   datediff(dd, h.edc, @LastDayofPreviousMonth)
	end as XDateAge,
	
	h.TCNumber,
	CASE WHEN h.TCNumber > 1 THEN 'Yes' ELSE 'No' End
	as [MultipleBirth],
	
	0 AS DevAge,
	
	case
	   when T.GestationalAge is null then
		 0
	   else
		   T.GestationalAge
	end as GestationalAge,
	T.TCDOD,
	
	case
	   when T.TCIDPK is null then
		 0
	   else
		   T.TCIDPK
	end as TCIDPK,	

	rtrim(T.TCLastName) + ', ' + rtrim(T.TCFirstName) TCName, 
	0 AS  	Missing ,
	0 AS 	OutOfWindow,
	0 AS 	RecOK
	
	from dbo.CaseProgram cp
	inner join dbo.SplitString(@programfk,',') on cp.programfk = listitem
	left join codeLevel on cp.CurrentLevelFK = codeLevel.codeLevelPK
	inner join dbo.HVCase h ON cp.HVCaseFK = h.HVCasePK	
	inner join worker fsw on cp.CurrentFSWFK = fsw.workerpk
	INNER JOIN TCID T ON T.HVCaseFK = h.HVCasePK 

	where   ((h.IntakeDate <= dateadd(M, -1, @LastDayofPreviousMonth)) AND (h.IntakeDate IS NOT NULL))	-- enrolled atleast 30 days as of analysis point		 		  
			AND (cp.DischargeDate IS NULL OR cp.DischargeDate > @LastDayofPreviousMonth)  --- case not closed as of analysis point

)
,
cteAgeInDays AS
(
select HVCasePK
	 , PC1ID
	 , tcdob
	 , FormDueDate
	 , worker
	 , LevelName
	 , IntakeDate
	 , DischargeDate
	 , CaseProgress
	 , XDateAge
	 , TCNumber
	 , MultipleBirth
	 , DevAge
	 , GestationalAge
	 , 
	case
	   when (XDateAge / 30.44) < 24 then
		 XDateAge - ((40 - GestationalAge) * 7)
	   else
		   XDateAge
	end as AgeInDays,
	TCDOD,
	TCIDPK, 
	TCName,
	Missing,
	OutOfWindow,
	RecOK 	

 FROM cteMainReport7

)




INSERT INTO @tbl4QAReport7Detail(
	HVCasePK,
	[PC1ID],
	TCDOB,
	FormDueDate,
	Worker,
	currentLevel,
	IntakeDate,
	DischargeDate,
	CaseProgress,
	XDateAge,
	TCNumber,
	MultipleBirth,
	DevAge,
	GestationalAge,
	AgeInDays,
	TCDOD,
	TCIDPK, 
	TCName,
	Missing,
	OutOfWindow,
	RecOK 
)
select HVCasePK
	 , PC1ID
	 , tcdob
	 , FormDueDate
	 , worker
	 , LevelName
	 , IntakeDate
	 , DischargeDate
	 , CaseProgress
	 , XDateAge
	 , TCNumber
	 , MultipleBirth
	 , DevAge
	 , GestationalAge
	 , AgeInDays
	 , TCDOD
	 , TCIDPK 
	 , TCName
	 , Missing
	 , OutOfWindow
	 , RecOK 	

 FROM cteAgeInDays
 WHERE AgeInDays > 122 AND (tcdod > @LastDayofPreviousMonth OR tcdod IS NULL)  -- 122 need to be converted later on (Target Child 4 months or older)
 
 
UPDATE @tbl4QAReport7Detail SET TCName = '' WHERE TCName IS NULL



-- Equivelent to csrForm6 in foxpro	
--SELECT DISTINCT HVCasePK  FROM @tbl4QAReport7Detail



--SELECT * FROM @tbl4QAReport7Detail  -- Equivelent to csrForm6 in foxpro
--ORDER BY HVCasePK
--ORDER BY Worker 
 
--- rspQAReport7 1 ,'summary'


 
 DECLARE @tbl4QAReport7Interval TABLE(
	HVCasePK INT,
	TCIDFK INT,
	Interval CHAR (2)
)


INSERT INTO @tbl4QAReport7Interval
(
HVCasePK,
TCIDFK,
Interval
)
SELECT 
		qa1.HVCasePK
	  , qa1.TCIDPK 	 
	  , max(Interval) AS Interval -- given child age, this is the interval that one expect to find ASQ record in the DB
 
 FROM @tbl4QAReport7Detail qa1
 inner join codeduebydates on scheduledevent = 'ASQ' AND AgeInDays >= DueBy  
 GROUP BY HVCasePK, QA1.TCIDPK -- Must 'group by HVCasePK, TCIDPK' to bring in twins etc (twins have same hvcasepks) (not just 'group by HVCasePK')
 
 
 
 
 
 --SELECT * FROM @tbl4QAReport7Interval
 --ORDER BY HVCasePK, TCIDFK
 
 --- rspQAReport7 1 ,'summary'


-- get expected records that are due for the Interval
DECLARE @tbl4QAReport7Expected TABLE(
	HVCasePK INT,
	[PC1ID] [char](13),
	TCDOB [datetime],
	Worker [varchar](200),
	currentLevel [varchar](50),
	IntakeDate [datetime],
	DischargeDate [datetime],
	CaseProgress [NUMERIC](3),
	XDateAge INT,
	AgeInDays INT,
	TCNumber INT,
	MultipleBirth [char](3),	
	Missing BIT,
	OutOfWindow BIT,
	RecOK BIT,
	[DueBy] [int] NOT NULL,
	[Interval] [char](2) NOT NULL,
	[MaximumDue] [int] NOT NULL,
	[MinimumDue] [int] NOT NULL,	
	FormDate [datetime],
	FormNotReviewed BIT,
	TCName [varchar](200),
	FormDueDate [datetime],
	GestationalAge INT,
	CalcDOB [datetime],
	TCIDPK INT,
	TCAge [char](2) NOT NULL,
	cteInterval [char](2) NOT NULL
)

-- get all hvcases that we will exclude because ASQTCReceiving = 1 for them
DECLARE @tblExcludeCases TABLE(
	HVCasePK INT	
) 
 
 ;
 WITH cteLastHighestASQ AS
(
SELECT 
		ra.HVCasePK
		,ra.TCIDPK 			 
	  , max(TCAge) AS Interval
 
  FROM @tbl4QAReport7Detail ra  
  left join tcid on tcid.hvcasefk = ra.hvcasepk     
  LEFT JOIN ASQ A ON ra.HVCasePK = a.HVCaseFK and a.TCIDFK = ra.TCIDPK 
 GROUP BY ra.HVCasePK, ra.TCIDPK 	
 --ORDER BY HVCasePK 
)

INSERT INTO @tblExcludeCases
(
HVCasePK
)
	-- get hvcasepk's that we will exclude because for them ASQTCReceiving = 1 and EventDescription contains optional
SELECT DISTINCT 		
	  cc.HVCasePK		 
	  FROM @tbl4QAReport7Detail cc
INNER  JOIN cteLastHighestASQ cl ON cl.HVCasePK = cc.HVCasePK
LEFT   JOIN ASQ asqq ON cl.HVCasePK = asqq.HVCaseFK -- OR asqq.HVCaseFK IS null
WHERE  
	(asqq.TCAge  = cl.Interval OR cl.Interval IS NULL)
	AND
	(asqq.ASQTCReceiving = 1)


INSERT INTO @tbl4QAReport7Expected(
	HVCasePK,
	[PC1ID],
	TCDOB,
	Worker,
	currentLevel,
	IntakeDate,
	DischargeDate,
	CaseProgress,
	XDateAge,
	AgeInDays,
	TCNumber,
	MultipleBirth,	
	Missing,
	OutOfWindow,
	RecOK,
	[DueBy],
	[Interval],
	[MaximumDue],
	[MinimumDue],	
	FormDate,
	FormNotReviewed,
	TCName,
	FormDueDate,
	GestationalAge,
	CalcDOB,
	TCIDPK,
	TCAge,
	cteInterval
) 
 SELECT qa1.HVCasePK
	  , PC1ID
	  , TCDOB
	  , Worker
	  , currentLevel
	  , IntakeDate
	  , DischargeDate
	  , CaseProgress
	  , XDateAge
	  , AgeInDays
	  , qa1.TCNumber
	  , qa1.MultipleBirth
	  , 0 AS Missing
	  , CASE WHEN (ASQInWindow = 1) THEN 0 ELSE 1 END AS OutOfWindow
	  , CASE WHEN (ASQInWindow = 1) THEN 1 ELSE 0 END AS RecOK 
	  , cd.[DueBy]
	  , cd.[Interval]
	  , cd.[MaximumDue]
	  , cd.[MinimumDue]		  
	  , DateCompleted  AS FormDate
	  , CASE WHEN dbo.IsFormReviewed(DateCompleted, 'AQ', ASQPK)=1 THEN 0 ELSE 1 END AS FormNotReviewed  -- AQ = ASQ FORM
	  , qa1.TCName
	  , CASE WHEN (XDateAge/30.44) < 24  
	  THEN   dateadd(d, ((40 - qa1.GestationalAge) * 7) + cd.[DueBy], TCDOB) 	  
	  ELSE   dateadd(d, cd.[DueBy], TCDOB)
	  END AS FormDueDate
	  , qa1.GestationalAge
	  , CASE WHEN (XDateAge/30.44) < 24  
		  Then
		 dateadd(d, ((40 - qa1.GestationalAge) * 7), TCDOB)
		 ELSE
		 TCDOB
		 END
		  AS CalcDOB
	  , qa1.TCIDPK
	  ,	Q.TCAge
	  , cteIn.Interval  
		  
 FROM @tbl4QAReport7Detail qa1 
 INNER JOIN @tbl4QAReport7Interval cteIn ON qa1.HVCasePK = cteIn.HVCasePK AND qa1.TCIDPK = cteIn.TCIDFK  -- we will use column 'Interval' next, which we just added
 inner join codeduebydates cd on scheduledevent = 'ASQ' AND cteIn.[Interval] = cd.Interval -- to get dueby, max, min (given interval)
 -- The following line gets those tcid's with ASQ's that are due for the Interval
 INNER JOIN ASQ Q ON Q.TCIDFK  = qa1.TCIDPK AND Q.TCAge = cteIn.Interval -- note 'Interval' is the minimum interval 
 where qa1.HVCasePK not in (select HVCasePK from @tblExcludeCases) -- exclude cases that contains ASQTCReceiving = 1 as per John
 ORDER BY HVCasePK 
 
 
 --SELECT * FROM @tbl4QAReport7Expected
 --ORDER BY HVCasePK 
 
 --- rspQAReport7 1 ,'summary'
 
 
 -- Looking into the missing ones
 
 -- Get the the last asq (max TCAge) that was done for each tcid
DECLARE @tbl4QAReport7LastASQIntervalCompleted TABLE(
	HVCasePK INT,
	TCIDFK INT,
	LastASQIntervalCompleted CHAR (2)
)


INSERT INTO @tbl4QAReport7LastASQIntervalCompleted
(
HVCasePK,
TCIDFK,
LastASQIntervalCompleted
)
SELECT 
		qa1.HVCasePK	
		, qa1.TCIDPK 	 
	  , max(TCAge) AS Interval
 
 FROM @tbl4QAReport7Detail qa1
 LEFT JOIN ASQ A ON A.TCIDFK = qa1.TCIDPK  
 GROUP BY HVCasePK,qa1.TCIDPK 
 
 
 
 -- SELECT * FROM @tbl4QAReport7LastASQIntervalCompleted
 --ORDER BY HVCasePK 
 
 
 
 
 -- Get all the ASQs for all TCIDs in our cohort
 DECLARE @tbl4QAReport7Intervals4AllASQsInOurCohort TABLE(
	HVCaseFK INT,
	TCIDFK INT, 
	Interval CHAR (2),
	ASQTCReceiving [char](1),
	DateCompleted [datetime],
	ASQPK INT
)


INSERT INTO @tbl4QAReport7Intervals4AllASQsInOurCohort
(
	HVCaseFK,
	TCIDFK,
	Interval,
	ASQTCReceiving,
	DateCompleted,
	ASQPK
) 
 SELECT qa3.HVCasePK,
		A.TCIDFK,
		A.TCAge,
		A.ASQTCReceiving,
		DateCompleted,
		ASQPK
	 
  FROM @tbl4QAReport7Detail qa3  
 LEFT JOIN ASQ A ON qa3.TCIDPK = A.TCIDFK 


 
 --SELECT * FROM @tbl4QAReport7Intervals4AllASQsInOurCohort
 --ORDER BY TCIDFK 
 
 --- rspQAReport7 1 ,'summary'
 
 
 DECLARE @tbl4QAReport7NotExpected TABLE(
	HVCasePK INT,
	[PC1ID] [char](13),
	TCDOB [datetime],
	Worker [varchar](200),
	currentLevel [varchar](50),
	IntakeDate [datetime],
	DischargeDate [datetime],
	CaseProgress [NUMERIC](3),
	XDateAge INT,
	AgeInDays INT,
	TCNumber INT,
	MultipleBirth [char](3),	
	Missing BIT,
	OutOfWindow BIT,
	RecOK BIT,
	FormDate [datetime],
	FormNotReviewed BIT,
	TCName [varchar](200),
	GestationalAge INT,
	CalcDOB [datetime],
	ASQTCReceiving [char](1),
	TCIDPK INT,
	IntervalExpected [char](2) NULL,
	LastASQIntervalCompleted [char](2) NULL 
)

-- missing ASQ's


INSERT INTO @tbl4QAReport7NotExpected(
	HVCasePK,
	[PC1ID],
	TCDOB,
	Worker,
	currentLevel,
	IntakeDate,
	DischargeDate,
	CaseProgress,
	XDateAge,
	AgeInDays,
	TCNumber,
	MultipleBirth,	
	Missing,
	OutOfWindow,
	RecOK,
	FormDate,
	FormNotReviewed,
	TCName,
	GestationalAge,
	CalcDOB,
	ASQTCReceiving,
	TCIDPK,
	IntervalExpected,
	LastASQIntervalCompleted
) 
 SELECT qa2.HVCasePK
	  , qa2.PC1ID
	  , qa2.TCDOB
	  , qa2.Worker
	  , qa2.currentLevel
	  , qa2.IntakeDate
	  , qa2.DischargeDate
	  , qa2.CaseProgress
	  , qa2.XDateAge
	  , qa2.AgeInDays
	  , qa2.TCNumber
	  , qa2.MultipleBirth
	  , 1 AS Missing
	  , qa2.OutOfWindow	
	  , CASE WHEN (ASQTCReceiving = 1) THEN 1 ELSE 0 END AS RecOK 
	  , easq.FormDate AS FormDate
	  , NULL  AS FormNotReviewed
	  , qa2.TCName
	  , qa2.GestationalAge
	  , CASE WHEN (qa2.XDateAge/30.44) < 24  
		  Then
		 dateadd(d, ((40 - qa2.GestationalAge) * 7), qa2.TCDOB)
		 ELSE
		 qa2.TCDOB
		 END
		  AS CalcDOB
	  , qa4.ASQTCReceiving
	  , qa2.TCIDPK	  
	  ,	cteInExpected.Interval
	  , cteIn2.LastASQIntervalCompleted

	  
 FROM @tbl4QAReport7Detail qa2 
 INNER JOIN @tbl4QAReport7Interval cteInExpected ON qa2.HVCasePK = cteInExpected.HVCasePK AND qa2.TCIDPK = cteInExpected.TCIDFK  -- we will use column 'Interval' next, which we just added
 LEFT JOIN @tbl4QAReport7LastASQIntervalCompleted cteIn2 ON qa2.HVCasePK = cteIn2.HVCasePK -- we will use column 'Interval' next, which we just added
 LEFT JOIN @tbl4QAReport7Expected easq on easq.hvcasepk = qa2.HVCasePK 
 LEFT join codeduebydates cd on scheduledevent = 'ASQ' AND cteIn2.LastASQIntervalCompleted = cd.Interval -- to get dueby, max, min (given interval)
 LEFT JOIN @tbl4QAReport7Intervals4AllASQsInOurCohort qa4 ON qa4.TCIDFK  = qa2.TCIDPK  AND ((cteIn2.LastASQIntervalCompleted = qa4.Interval) OR (cteIn2.LastASQIntervalCompleted IS NULL))  -- in foxpro i.e. LOCATE FOR ALLTRIM(tc_age)=ALLTRIM(STR(aqs.max_tcage,2,0))
WHERE 
easq.hvcasepk IS NULL 
 
 
 --SELECT * FROM @tbl4QAReport7NotExpected 
 --WHERE ASQTCReceiving = 0 
 ------ORDER BY Worker   
 --ORDER BY HVCasePK  
 --- rspQAReport7 1 ,'summary'



-- define a new table variable to store the latest changes
 
 DECLARE @tbl4QAReport7NotExpectedModified TABLE(
	HVCasePK INT,
	[PC1ID] [char](13),
	TCDOB [datetime],
	Worker [varchar](200),
	currentLevel [varchar](50),
	IntakeDate [datetime],
	DischargeDate [datetime],
	CaseProgress [NUMERIC](3),
	XDateAge INT,
	AgeInDays INT,
	TCNumber INT,
	MultipleBirth [char](3),	
	Missing BIT,
	OutOfWindow BIT,
	RecOK BIT,
	FormDate [datetime],
	FormNotReviewed BIT,
	TCName [varchar](200),
	FormDueDate [datetime],
	GestationalAge INT,
	CalcDOB [datetime],
	ASQTCReceiving [char](1),
	TCIDPK INT,
	IntervalExpected [char](2) NULL,
	LastASQIntervalCompleted [char](2) NULL 
)


-- Let us figure our 'MISSING'
;
WITH cteASQMissing AS
(

SELECT HVCasePK
	 , PC1ID
	 , TCDOB
	 , Worker
	 , currentLevel
	 , IntakeDate
	 , DischargeDate
	 , CaseProgress
	 , XDateAge
	 , AgeInDays
	 , TCNumber
	 , MultipleBirth	 
	 , 
	 CASE
	 
	  -- handling optional - 60, 54
	  WHEN((qa04.IntervalExpected = '60' OR qa04.IntervalExpected = '54' OR qa04.IntervalExpected = '48') AND (
		 '60' IN (SELECT interval FROM  @tbl4QAReport7Intervals4AllASQsInOurCohort qa4 WHERE  qa4.TCIDFK  = qa04.TCIDPK)
		  OR
		 '54' IN (SELECT interval FROM  @tbl4QAReport7Intervals4AllASQsInOurCohort qa4 WHERE  qa4.TCIDFK  = qa04.TCIDPK)	  
		 OR
		 '48' IN (SELECT interval FROM  @tbl4QAReport7Intervals4AllASQsInOurCohort qa4 WHERE  qa4.TCIDFK  = qa04.TCIDPK)	  

	  )) THEN 0
	 
	  -- handling optional - 42
	  WHEN((qa04.IntervalExpected = '42' OR qa04.IntervalExpected = '36') AND (
		  '42' IN (SELECT interval FROM  @tbl4QAReport7Intervals4AllASQsInOurCohort qa4 WHERE  qa4.TCIDFK  = qa04.TCIDPK)  	
		  OR
		  '36' IN (SELECT interval FROM  @tbl4QAReport7Intervals4AllASQsInOurCohort qa4 WHERE  qa4.TCIDFK  = qa04.TCIDPK)  		 
	  )) THEN 0
	 
	  -- handling optional - 33
	  WHEN((qa04.IntervalExpected = '33' OR qa04.IntervalExpected = '30') AND (
		  '33' IN (SELECT interval FROM  @tbl4QAReport7Intervals4AllASQsInOurCohort qa4 WHERE  qa4.TCIDFK  = qa04.TCIDPK)  	
		  OR
		  '30' IN (SELECT interval FROM  @tbl4QAReport7Intervals4AllASQsInOurCohort qa4 WHERE  qa4.TCIDFK  = qa04.TCIDPK)  		 
	  )) THEN 0
	 
	  -- handling optional - 27
	  WHEN((qa04.IntervalExpected = '27' OR qa04.IntervalExpected = '24') AND (
		  '27' IN (SELECT interval FROM  @tbl4QAReport7Intervals4AllASQsInOurCohort qa4 WHERE  qa4.TCIDFK  = qa04.TCIDPK)  	
		  OR
		  '24' IN (SELECT interval FROM  @tbl4QAReport7Intervals4AllASQsInOurCohort qa4 WHERE  qa4.TCIDFK  = qa04.TCIDPK)  		 
	  )) THEN 0
	 
	  -- handling optional - 22
	  WHEN((qa04.IntervalExpected = '22' OR qa04.IntervalExpected = '20') AND (
		  '22' IN (SELECT interval FROM  @tbl4QAReport7Intervals4AllASQsInOurCohort qa4 WHERE  qa4.TCIDFK  = qa04.TCIDPK)  	
		  OR
		  '20' IN (SELECT interval FROM  @tbl4QAReport7Intervals4AllASQsInOurCohort qa4 WHERE  qa4.TCIDFK  = qa04.TCIDPK)  		 
	  )) THEN 0
	 
	  -- handling optional - 18
	  WHEN((qa04.IntervalExpected = '18' OR qa04.IntervalExpected = '16') AND (
		  '18' IN (SELECT interval FROM  @tbl4QAReport7Intervals4AllASQsInOurCohort qa4 WHERE  qa4.TCIDFK  = qa04.TCIDPK)  	
		  OR
		  '16' IN (SELECT interval FROM  @tbl4QAReport7Intervals4AllASQsInOurCohort qa4 WHERE  qa4.TCIDFK  = qa04.TCIDPK)  		 
	  )) THEN 0

	 
	  -- handling optional - 14
	  WHEN((qa04.IntervalExpected = '14' OR qa04.IntervalExpected = '12') AND (
		  '14' IN (SELECT interval FROM  @tbl4QAReport7Intervals4AllASQsInOurCohort qa4 WHERE  qa4.TCIDFK  = qa04.TCIDPK)  	
		  OR
		  '12' IN (SELECT interval FROM  @tbl4QAReport7Intervals4AllASQsInOurCohort qa4 WHERE  qa4.TCIDFK  = qa04.TCIDPK)  	
		 	 
	  )) THEN 0	 
	 
	  -- handling optional - 10,09
	  WHEN((qa04.IntervalExpected = '10' OR qa04.IntervalExpected = '09' OR qa04.IntervalExpected = '08') AND (
		  '10' IN (SELECT interval FROM  @tbl4QAReport7Intervals4AllASQsInOurCohort qa4 WHERE  qa4.TCIDFK  = qa04.TCIDPK)  	
		  OR
		  '09' IN (SELECT interval FROM  @tbl4QAReport7Intervals4AllASQsInOurCohort qa4 WHERE  qa4.TCIDFK  = qa04.TCIDPK)  	
		  OR
		  '08' IN (SELECT interval FROM  @tbl4QAReport7Intervals4AllASQsInOurCohort qa4 WHERE  qa4.TCIDFK  = qa04.TCIDPK)  	
		 	 
	  )) THEN 0	 
	 
	  -- handling optional - 06
	  WHEN((qa04.IntervalExpected = '06' OR qa04.IntervalExpected = '04') AND (
		  '06' IN (SELECT interval FROM  @tbl4QAReport7Intervals4AllASQsInOurCohort qa4 WHERE  qa4.TCIDFK  = qa04.TCIDPK)  	
		  OR
		  '04' IN (SELECT interval FROM  @tbl4QAReport7Intervals4AllASQsInOurCohort qa4 WHERE  qa4.TCIDFK  = qa04.TCIDPK)  	
		 	 
	  )) THEN 0	 
	 
	  -- handling optional - 02
	  WHEN((qa04.IntervalExpected = '02') AND (
		  '02' IN (SELECT interval FROM  @tbl4QAReport7Intervals4AllASQsInOurCohort qa4 WHERE  qa4.TCIDFK  = qa04.TCIDPK)  	
		 	 
	  )) THEN 0		  	  	 
	  	  	 

	  
--- rspQAReport7 1 ,'summary'	 
	 

	 
	 
	  ELSE 1 END AS Missing 
	 
	 --- Todo - Continuee Khalsea
	 
	 --Missing
	 , OutOfWindow
	 , 0 as RecOK
	 , FormDate
	 , FormNotReviewed
	 , TCName
	 , GestationalAge
	 , CalcDOB
	 , qa04.ASQTCReceiving
	 , TCIDPK
	 , IntervalExpected
	 , LastASQIntervalCompleted
	 
FROM @tbl4QAReport7NotExpected qa04
where 
qa04.ASQTCReceiving = 0 OR qa04.ASQTCReceiving IS NULL 

)

-- Let us figure out 'IntervalExpected'
INSERT INTO @tbl4QAReport7NotExpectedModified(
	HVCasePK,
	[PC1ID],
	TCDOB,
	Worker,
	currentLevel,
	IntakeDate,
	DischargeDate,
	CaseProgress,
	XDateAge,
	AgeInDays,
	TCNumber,
	MultipleBirth,	
	Missing,
	OutOfWindow,
	RecOK,
	FormDate,
	FormNotReviewed,
	TCName,
	GestationalAge,
	CalcDOB,
	ASQTCReceiving,
	TCIDPK,
	IntervalExpected,
	LastASQIntervalCompleted
) 
SELECT DISTINCT 
		HVCasePK
	 , PC1ID
	 , TCDOB
	 , Worker
	 , currentLevel
	 , IntakeDate
	 , DischargeDate
	 , CaseProgress
	 , XDateAge
	 , AgeInDays
	 , TCNumber
	 , MultipleBirth
	 , Missing
	 , OutOfWindow
	 , RecOK
	 , FormDate
	 , FormNotReviewed
	 , TCName
	 , GestationalAge
	 , CalcDOB
	 , ASQTCReceiving
	 , TCIDPK
	 ,
	 CASE
	  -- if asq is missing then change interval from optional value to Required value e.g. from interval '06' (which is optional) to required value of '04'  ... Khalsa
	  -- handling optional - 60, 54
	  WHEN((IntervalExpected = '60' OR IntervalExpected = '54' OR IntervalExpected = '48') AND (Missing = 1)) THEN '48'
	 
	  -- handling optional - 42
	  WHEN((IntervalExpected = '42' OR IntervalExpected = '36') AND (Missing = 1)) THEN '36'
	 
	  -- handling optional - 33
	  WHEN((IntervalExpected = '33' OR IntervalExpected = '30') AND (Missing = 1)) THEN '30'
	 
	  -- handling optional - 27
	  WHEN((IntervalExpected = '27' OR IntervalExpected = '24') AND (Missing = 1)) THEN '24'
	 
	  -- handling optional - 22
	  WHEN((IntervalExpected = '22' OR IntervalExpected = '20') AND (Missing = 1)) THEN '20'
	 
	  -- handling optional - 18
	  WHEN((IntervalExpected = '18' OR IntervalExpected = '16') AND (Missing = 1)) THEN '16'

	 
	  -- handling optional - 14
	  WHEN((IntervalExpected = '14' OR IntervalExpected = '12') AND (Missing = 1)) THEN '12'
	 
	  -- handling optional - 10,09
	  WHEN((IntervalExpected = '10' OR IntervalExpected = '09' OR IntervalExpected = '08') AND (Missing = 1)) THEN '08'
	 
	  -- handling optional - 06
	  WHEN((IntervalExpected = '06' OR IntervalExpected = '04') AND (Missing = 1)) THEN '04'
	 
	  -- handling optional - 02
	  WHEN((IntervalExpected = '02') AND (Missing = 1)) THEN '02'	 
	 
	  ELSE '' END AS IntervalExpected 		 

	 , LastASQIntervalCompleted
 FROM cteASQMissing
WHERE Missing = 1
ORDER BY Worker
--ORDER BY HVCasePK 



 DECLARE @tbl4QAReport7NotExpectedMain TABLE(
	HVCasePK INT,
	[PC1ID] [char](13),
	TCDOB [datetime],
	Worker [varchar](200),
	currentLevel [varchar](50),
	IntakeDate [datetime],
	DischargeDate [datetime],
	CaseProgress [NUMERIC](3),
	XDateAge INT,
	AgeInDays INT,
	TCNumber INT,
	MultipleBirth [char](3),	
	Missing BIT,
	OutOfWindow BIT,
	RecOK BIT,
	FormDate [datetime],
	FormNotReviewed BIT,
	TCName [varchar](200),	
	FormDueDate [datetime],	
	GestationalAge INT,
	CalcDOB [datetime],
	ASQTCReceiving [char](1),
	TCIDPK INT,
	IntervalExpected [char](2) NULL,
	LastASQIntervalCompleted [char](2) NULL 
)

-- Finally put notExpected in a table (getting ready for the summary)
INSERT INTO @tbl4QAReport7NotExpectedMain(
	HVCasePK,
	[PC1ID],
	TCDOB,
	Worker,
	currentLevel,
	IntakeDate,
	DischargeDate,
	CaseProgress,
	XDateAge,
	AgeInDays,
	TCNumber,
	MultipleBirth,	
	Missing,
	OutOfWindow,
	RecOK,
	FormDate,
	FormNotReviewed,
	TCName,
	FormDueDate,
	GestationalAge,
	CalcDOB,
	ASQTCReceiving,
	TCIDPK,
	IntervalExpected,
	LastASQIntervalCompleted
) 
SELECT 
	  HVCasePK
	 , PC1ID
	 , TCDOB
	 , Worker
	 , currentLevel
	 , IntakeDate
	 , DischargeDate
	 , CaseProgress
	 , XDateAge
	 , AgeInDays
	 , TCNumber
	 , MultipleBirth
	 , Missing
	 , OutOfWindow
	 , RecOK
	 , FormDate
	 , FormNotReviewed
	 , TCName
	 , CASE WHEN (qa5.XDateAge/30.44) < 24  
	  THEN   dateadd(d, ((40 - qa5.GestationalAge) * 7) + cd.[DueBy], qa5.TCDOB) 	  
	  ELSE   dateadd(d, cd.[DueBy], qa5.TCDOB)
	  END AS FormDueDate
	 , GestationalAge
	 , CalcDOB
	 , ASQTCReceiving
	 , TCIDPK
	 , IntervalExpected
	 , LastASQIntervalCompleted
 FROM @tbl4QAReport7NotExpectedModified qa5
LEFT join codeduebydates cd on scheduledevent = 'ASQ' AND qa5.IntervalExpected = cd.Interval -- to get dueby to calculate 'FormDueDate'
where HVCasePK not in (select HVCasePK from @tblExcludeCases) -- exclude cases that contains ASQTCReceiving = 1 as per John
ORDER BY HVCasePK 
--- rspQAReport7 1 ,'summary'

--SELECT * FROM @tbl4QAReport7NotExpectedMain



IF @ReportType = 'summary'

	BEGIN 

	DECLARE @numOfALLScreens INT = 0
	SET @numOfALLScreens = (SELECT count(HVCasePK) FROM @tbl4QAReport7Detail)


	DECLARE @numOfMissingCases INT = 0
	SET @numOfMissingCases = (SELECT count(HVCasePK) FROM @tbl4QAReport7NotExpectedMain WHERE Missing = 1)
	
	DECLARE @numOfOutOfWindowsORNotReviewedCases INT = 0
	SET @numOfOutOfWindowsORNotReviewedCases = (SELECT count(HVCasePK) FROM @tbl4QAReport7Expected WHERE OutOfWindow = 1 OR FormNotReviewed=1)	
	
	DECLARE @numOfMissingAndOutOfWindowsCases INT = 0	
	SET @numOfMissingAndOutOfWindowsCases = (@numOfMissingCases + @numOfOutOfWindowsORNotReviewedCases)
	

DECLARE @tbl4QAReport9Summary TABLE(
	[SummaryId] INT,
	[SummaryText] [varchar](200),
	[MissingCases] [varchar](200),
	[NotOnTimeCases] [varchar](200),
	[SummaryTotal] [varchar](100)
)

INSERT INTO @tbl4QAReport9Summary([SummaryId],[SummaryText],[MissingCases],[NotOnTimeCases],[SummaryTotal])
VALUES(7 ,'ASQs for Active Cases with Target Child 4 months or older, calc. DOB (N=' + CONVERT(VARCHAR,@numOfALLScreens) + ')' 
	,CONVERT(VARCHAR,@numOfMissingCases) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfMissingCases AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
	,CONVERT(VARCHAR,@numOfOutOfWindowsORNotReviewedCases) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfOutOfWindowsORNotReviewedCases AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
	,CONVERT(VARCHAR,@numOfMissingAndOutOfWindowsCases) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfMissingAndOutOfWindowsCases AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'

	)

	SELECT * FROM @tbl4QAReport9Summary	

	END
ELSE
	BEGIN
	
	
	SELECT 
		[PC1ID],
		EventDescription AS IntervalDue,	
		convert(varchar(10),FormDueDate,101) AS FormDueDate,
		convert(varchar(10),FormDate,101) AS FormDate,
		convert(varchar(10),TCDOB,101) AS TCDOB,
		convert(varchar(10),CalcDOB,101) AS CalcDOB,
		TCName,
		Worker,		
		GestationalAge,
		FormNotReviewed,
		Missing,
		OutOfWindow,
		currentLevel	

	FROM @tbl4QAReport7Expected qam2
	inner join codeduebydates cdd2 on scheduledevent = 'ASQ' AND cdd2.Interval = qam2.Interval 
	WHERE OutOfWindow = 1 OR FormNotReviewed=1

UNION 	

	SELECT
		[PC1ID],
		EventDescription AS IntervalDue,		
		convert(varchar(10),FormDueDate,101) AS FormDueDate,
		convert(varchar(10),FormDate,101) AS FormDate,
		convert(varchar(10),TCDOB,101) AS TCDOB,
		convert(varchar(10),CalcDOB,101) AS CalcDOB,
		TCName,
		Worker,		
		GestationalAge,
		FormNotReviewed,
		Missing,
		OutOfWindow,
		currentLevel
		 		
	 FROM @tbl4QAReport7NotExpectedMain qam	 
	 inner join codeduebydates cdd on scheduledevent = 'ASQ' AND cdd.Interval = qam.IntervalExpected 
		WHERE (Missing = 1 or OutOfWindow = 1 OR FormNotReviewed=1)
			ORDER BY Worker, PC1ID 	


	END	
GO
