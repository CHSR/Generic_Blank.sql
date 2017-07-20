SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <October 1st, 2012>
-- Description:	<This QA report gets you 'PSIs for Active Cases '>
-- rspQAReport9 31, 'summary'	--- for summary page
-- rspQAReport9 20			--- for main report - location = 2
-- rspQAReport9 null			--- for main report for all locations
-- =============================================


CREATE procedure [dbo].[rspQAReport9](
@programfk    varchar(max)    = NULL,
@ReportType char(7) = NULL 

)with recompile
AS
	if @programfk is null
	BEGIN
		select @programfk = substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end

	set @programfk = REPLACE(@programfk,'"','')

-- Last Day of Previous Month 
Declare @LastDayofPreviousMonth DateTime 
Set @LastDayofPreviousMonth = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE()),0)) -- analysis point

--Set @LastDayofPreviousMonth = '05/31/2012'

-- table variable for holding Init Required Data
DECLARE @tbl4QAReport9Coheart TABLE(
OldID [char](23),	
	HVCasePK INT, 
	[PC1ID] [char](13),	
	TCDOB [datetime],
	Worker [varchar](200),
	currentLevel [varchar](50),
	IntakeDate [datetime],
	DischargeDate [datetime],
	CaseProgress [NUMERIC] (3),
	XDateAge INT,	
	TCNumber INT,
	MultipleBirth [char](3),
	Missing BIT,
	OutOfWindow BIT,
	RecOK BIT,
	PSIInterval [char](2),
	HVCaseCreator [char](10),
	HVCaseEditor [char](10)
)

INSERT INTO @tbl4QAReport9Coheart(
	OldID,
	HVCasePK,
	[PC1ID],
	TCDOB,
	Worker,
	currentLevel,
	IntakeDate,
	DischargeDate,
	CaseProgress,
	XDateAge,
	TCNumber,
	MultipleBirth,
	Missing,
	OutOfWindow,
	RecOK,
	PSIInterval,
	HVCaseCreator,
	HVCaseEditor
)
select cp.OldID,
	 h.HVCasePK, 
	cp.PC1ID,
	case
	   when h.tcdob is not null then
		   h.tcdob
	   else
		   h.edc
	end as tcdob,
	
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
	0 AS  	Missing ,
	0 AS 	OutOfWindow,
	0 AS 	RecOK,
	'' AS PSIInterval,
	h.HVCaseCreator,
	h.HVCaseEditor
	
	
	from dbo.CaseProgram cp
	inner join dbo.SplitString(@programfk,',') on cp.programfk = listitem
	left join codeLevel on cp.CurrentLevelFK = codeLevel.codeLevelPK
	inner join dbo.HVCase h ON cp.HVCaseFK = h.HVCasePK	
	inner join worker fsw on cp.CurrentFSWFK = fsw.workerpk
	

	where   ((h.IntakeDate <= dateadd(M, -1, @LastDayofPreviousMonth)) AND (h.IntakeDate IS NOT NULL))	-- enrolled atleast 30 days as of analysis point		  
			AND (cp.DischargeDate IS NULL OR cp.DischargeDate > @LastDayofPreviousMonth)  --- case not closed as of analysis point
			AND (( (@LastDayofPreviousMonth > dateadd(d, 30, h.edc)) AND (h.tcdob IS NULL) ) OR ( (@LastDayofPreviousMonth > dateadd(d, 30, h.tcdob)) AND (h.edc IS NULL) ) )  -- baby is atleast 30 days old as of analysis point




 
-- to get accurate count of case
UPDATE @tbl4QAReport9Coheart
SET TCNumber = 1
WHERE TCNumber = 0 


--SELECT * FROM @tbl4QAReport9Coheart
--ORDER BY OldID


-- Equivelent to csrForm6 in foxpro	
--SELECT DISTINCT HVCasePK  FROM @tbl4QAReport9Coheart
----------SELECT * FROM @tbl4QAReport9Coheart  -- Equivelent to csrForm6 in foxpro
----------ORDER BY HVCasePK
 
 ---***********************************************************************************************
 --*************************************************************************************************
--- rspQAReport9 8 ,'summary'

DECLARE @tbl4QAReport9 TABLE(
	HVCasePK INT,
	[PC1ID] [char](13),
	TCDOB [datetime],
	Worker [varchar](200),
	currentLevel [varchar](50),
	IntakeDate [datetime],
	DischargeDate [datetime],
	CaseProgress [NUMERIC](3),
	XDateAge INT,
	TCNumber INT,
	MultipleBirth [char](3),
	Missing BIT,
	OutOfWindow BIT,
	RecOK BIT,
	[DueBy] [int] NOT NULL,
	[Interval] [char](2) NOT NULL,
	[MaximumDue] [int] NOT NULL,
	[MinimumDue] [int] NOT NULL,	
	FormDoneDateCompleted [datetime],
	FormNotReviewed BIT 
)

DECLARE @tbl4QAReport9Expected TABLE(
	HVCasePK INT,
	[PC1ID] [char](13),
	TCDOB [datetime],
	Worker [varchar](200),
	currentLevel [varchar](50),
	IntakeDate [datetime],
	DischargeDate [datetime],
	CaseProgress [NUMERIC](3),
	XDateAge INT,
	TCNumber INT,
	MultipleBirth [char](3),	
	Missing BIT,
	OutOfWindow BIT,
	RecOK BIT,
	[DueBy] [int] NOT NULL,
	[Interval] [char](2) NOT NULL,
	[MaximumDue] [int] NOT NULL,
	[MinimumDue] [int] NOT NULL,	
	FormDoneDateCompleted [datetime],
	FormNotReviewed BIT 
)

DECLARE @tbl4QAReport9NotExpected TABLE(
	HVCasePK INT,
	[PC1ID] [char](13),
	TCDOB [datetime],
	Worker [varchar](200),
	currentLevel [varchar](50),
	IntakeDate [datetime],
	DischargeDate [datetime],
	CaseProgress [NUMERIC](3),
	XDateAge INT,
	TCNumber INT,
	MultipleBirth [char](3),	
	Missing BIT,
	OutOfWindow BIT,
	RecOK BIT,
	[DueBy] [int] NOT NULL,
	[Interval] [char](2) NOT NULL,
	[MaximumDue] [int] NOT NULL,
	[MinimumDue] [int] NOT NULL,	
	FormDoneDateCompleted [datetime],
	FormNotReviewed BIT 
)


DECLARE @tbl4QAReport9Interval TABLE(
	HVCasePK INT,
	Interval CHAR (2)
)


INSERT INTO @tbl4QAReport9Interval
(
HVCasePK,
Interval
)
SELECT 
		qa1.HVCasePK	 
	  , max(Interval) AS Interval
 
 FROM @tbl4QAReport9Coheart qa1
 inner join codeduebydates on scheduledevent = 'PSI' AND XDateAge >= DueBy  
 GROUP BY HVCasePK 


--SELECT * FROM @tbl4QAReport9Interval


-- get expected records that are due for the Interval
INSERT INTO @tbl4QAReport9Expected(
	HVCasePK,
	[PC1ID],
	TCDOB,
	Worker,
	currentLevel,
	IntakeDate,
	DischargeDate,
	CaseProgress,
	XDateAge,
	TCNumber,
	MultipleBirth,	
	Missing,
	OutOfWindow,
	RecOK,
	[DueBy],
	[Interval],
	[MaximumDue],
	[MinimumDue],	
	FormDoneDateCompleted,
	FormNotReviewed
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
	  , qa1.TCNumber
	  , qa1.MultipleBirth
	  , 0 AS Missing
	  , CASE WHEN (PSIInWindow = 1) THEN 0 ELSE 1 END AS OutOfWindow
	  , CASE WHEN (PSIInWindow = 1) THEN 1 ELSE 0 END AS RecOK 
	  , cd.[DueBy]
	  , cd.[Interval]
	  , cd.[MaximumDue]
	  , cd.[MinimumDue]		  
	  , PSIDateComplete  AS FormDoneDateCompleted
	  , CASE WHEN dbo.IsFormReviewed(PSIDateComplete, 'PS', PSIPK)=1 THEN 0 ELSE 1 END AS FormNotReviewed 

 
 FROM @tbl4QAReport9Coheart qa1 
 INNER JOIN @tbl4QAReport9Interval cteIn ON qa1.HVCasePK = cteIn.HVCasePK -- we will use column 'Interval' next, which we just added
 inner join codeduebydates cd on scheduledevent = 'PSI' AND cteIn.[Interval] = cd.Interval -- to get dueby, max, min (given interval)
 -- The following line gets those tcid's with PSI's that are due for the Interval
 INNER JOIN PSI P ON P.HVCaseFK = qa1.HVCasePK AND P.PSIInterval = cteIn.Interval -- note 'Interval' is the minimum interval 
 ORDER BY HVCasePK 
 
 --- rspQAReport9 8 ,'summary'
 --SELECT * FROM @tbl4QAReport9Expected
 
-------- -- The following records, We did find ASQs for the proper interval
-- missing psi cases
-- get expected records that are due for the Interval
INSERT INTO @tbl4QAReport9NotExpected(
	HVCasePK,
	[PC1ID],
	TCDOB,
	Worker,
	currentLevel,
	IntakeDate,
	DischargeDate,
	CaseProgress,
	XDateAge,
  	TCNumber,
  	MultipleBirth,	  	
	Missing,
	OutOfWindow,
	RecOK,
	[DueBy],
	[Interval],
	[MaximumDue],
	[MinimumDue],	
	FormDoneDateCompleted,
	FormNotReviewed
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
	 , qa2.TCNumber
	 , qa2.MultipleBirth 
	 , 1 AS Missing
	 , qa2.OutOfWindow
	 , qa2.RecOK
	  , cd.[DueBy]
	  , cteIn.[Interval]
	  , cd.[MaximumDue]
	  , cd.[MinimumDue]		  	
	 , FormDoneDateCompleted
	 , NULL AS FormNotReviewed
	 
	  FROM @tbl4QAReport9Coheart qa2
	 
	 Left JOIN @tbl4QAReport9Interval cteIn ON qa2.HVCasePK = cteIn.HVCasePK -- we will use column 'Interval' next		
     LEFT JOIN @tbl4QAReport9Expected epsi on epsi.hvcasepk = qa2.HVCasePK 
     inner join codeduebydates cd on scheduledevent = 'PSI' AND cteIn.[Interval] = cd.Interval  -- to get dueby, max, min
WHERE epsi.hvcasepk IS NULL 

--------------- rspQAReport9 8 ,'summary'

INSERT INTO @tbl4QAReport9
SELECT * FROM @tbl4QAReport9Expected
Union
SELECT * FROM @tbl4QAReport9NotExpected  



DECLARE @tbl4QAReport9Main TABLE(
	HVCasePK INT,
	[PC1ID] [char](13),
	TCDOB [datetime],
	Worker [varchar](200),
	currentLevel [varchar](50),
	IntakeDate [datetime],
	DischargeDate [datetime],
	CaseProgress [NUMERIC](3),
	XDateAge INT,
	TCNumber INT,
	MultipleBirth [char](3),
	Missing BIT,
	OutOfWindow BIT,
	RecOK BIT,
	[DueBy] [int] NOT NULL,
	[Interval] [char](2) NOT NULL,
	[MaximumDue] [int] NOT NULL,
	[MinimumDue] [int] NOT NULL,	
	FormDoneDateCompleted [datetime],	
	FormNotReviewed BIT,
	FormDue [datetime]	 
)


INSERT INTO @tbl4QAReport9Main
(
        HVCasePK
	  , PC1ID
	  , TCDOB
	  , Worker
	  , currentLevel
	  , IntakeDate
	  , DischargeDate
	  , CaseProgress
	  , XDateAge
	  , TCNumber
	  , MultipleBirth
	  , Missing
	  , OutOfWindow
	  , RecOK
	  , [DueBy]
	  , [Interval]
	  , [MaximumDue]
	  , [MinimumDue]	
	  , FormDoneDateCompleted
	  , FormNotReviewed
	  , FormDue
)
 SELECT HVCasePK
	  , PC1ID
	  , TCDOB
	  , Worker
	  , currentLevel
	  , IntakeDate
	  , DischargeDate
	  , CaseProgress
	  , XDateAge
	  , TCNumber
	  , MultipleBirth
	  , Missing
	  , OutOfWindow
	  , RecOK
	  , [DueBy]
	  , [Interval]
	  , [MaximumDue]
	  , [MinimumDue]	
	  , FormDoneDateCompleted
	  , FormNotReviewed
	  , CASE WHEN ( Interval='00' AND ((IntakeDate >TCDOB) AND (TCDOB IS NOT null)) ) 
		THEN  dateadd(dd,DueBy,IntakeDate) ELSE dateadd(dd,DueBy,TCDOB) END AS FormDue
	  FROM @tbl4QAReport9

--SELECT * FROM @tbl4QAReport9Main
--ORDER BY HVCasePK 

	
--- rspQAReport9 8 ,'summary'



IF @ReportType = 'summary'

	BEGIN 

	DECLARE @numOfALLScreens INT = 0
	SET @numOfALLScreens = (SELECT count(HVCasePK) FROM @tbl4QAReport9Main)


	DECLARE @numOfMissingCases INT = 0
	SET @numOfMissingCases = (SELECT count(HVCasePK) FROM @tbl4QAReport9Main WHERE Missing = 1)
	
	DECLARE @numOfOutOfWindowsORNotReviewedCases INT = 0
	SET @numOfOutOfWindowsORNotReviewedCases = (SELECT count(HVCasePK) FROM @tbl4QAReport9Main WHERE OutOfWindow = 1 OR FormNotReviewed=1)	
	
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
VALUES(9 ,'PSIs for Active Cases (N=' + CONVERT(VARCHAR,@numOfALLScreens) + ')' 
	,CONVERT(VARCHAR,@numOfMissingCases) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfMissingCases AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
	,CONVERT(VARCHAR,@numOfOutOfWindowsORNotReviewedCases) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfOutOfWindowsORNotReviewedCases AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
	,CONVERT(VARCHAR,@numOfMissingAndOutOfWindowsCases) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfMissingAndOutOfWindowsCases AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'

	)

	SELECT * FROM @tbl4QAReport9Summary	

	END
ELSE
	BEGIN
	

	SELECT 
		   PC1ID
		 , EventDescription AS IntervalDue
		 --, qam.Interval		 
		 , convert(varchar(10),FormDue,101) AS FormDue
		 , convert(varchar(10),FormDoneDateCompleted,101) AS FormDoneDateCompleted		 	
		 , convert(varchar(10),TCDOB,101) AS TCDOB		 
		 , Worker
		 , FormNotReviewed
		 , Missing
		 , OutOfWindow		 		 
		 , currentLevel
	 
		 --, IntakeDate
		 --, DischargeDate
		 --, CaseProgress
		 --, XDateAge
		 --, TCNumber
		 --, MultipleBirth
		 --, RecOK
		 --, DueBy		 
		 --, MaximumDue
		 --, MinimumDue
		 
		 
		 		
	 FROM @tbl4QAReport9Main qam
	 inner join codeduebydates cdd on scheduledevent = 'PSI' AND cdd.Interval = qam.Interval 
		WHERE (Missing = 1 or OutOfWindow = 1 OR FormNotReviewed = 1)
	ORDER BY Worker, PC1ID 	


	END	
	
	--- rspQAReport9 1 ,'summary'
GO
