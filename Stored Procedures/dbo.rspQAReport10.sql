SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <November 6th, 2012>
-- Description:	<This QA report gets you 'Follow-Ups for Active Cases with Target Child 6 months or older '>
-- rspQAReport10 4, 'summary'	--- for summary page
-- rspQAReport10 8			--- for main report - location = 2
-- rspQAReport10 null			--- for main report for all locations
-- =============================================


CREATE procedure [dbo].[rspQAReport10](
@programfk    varchar(max)    = NULL,
@ReportType char(7) = NULL 

)
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
--Set @LastDayofPreviousMonth = '05/31/2012'

-------- Hard code date for FollowUpInterval = 18 -----
-- NOTE: Ignore Missing field for the old FoxPro data
Declare @StartFollowUpInterval18AfterThisDate DateTime 
Set @StartFollowUpInterval18AfterThisDate = '07/01/2011'
--Set @StartFollowUpInterval18AfterThisDate = '07/01/1999'
-------------------------------------------------------



-- table variable for holding Init Required Data
DECLARE @tbl4QAReport10Coheart TABLE(
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
	FollowUpInterval [char](2)
)

INSERT INTO @tbl4QAReport10Coheart(
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
	FollowUpInterval 	 
)
select 
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
	'' AS FollowUpInterval
	
	
	from dbo.CaseProgram cp
	inner join dbo.SplitString(@programfk,',') on cp.programfk = listitem
	left join codeLevel on cp.CurrentLevelFK = codeLevel.codeLevelPK
	inner join dbo.HVCase h ON cp.HVCaseFK = h.HVCasePK	
	inner join worker fsw on cp.CurrentFSWFK = fsw.workerpk
	

	where   ((h.IntakeDate <= dateadd(M, -1, @LastDayofPreviousMonth)) AND (h.IntakeDate IS NOT NULL))	-- enrolled atleast 30 days as of analysis point		 		  
			AND (cp.DischargeDate IS NULL OR cp.DischargeDate > @LastDayofPreviousMonth)  --- case not closed as of analysis point
			AND (( (@LastDayofPreviousMonth >= dateadd(dd, 183, h.edc)) AND (h.tcdob IS NULL) ) OR ( (@LastDayofPreviousMonth >= dateadd(dd, 183, h.tcdob)) AND (h.edc IS NULL) ) )    -- baby is atleast 30 days old as of analysis point

 
-- to get accurate count of case
UPDATE @tbl4QAReport10Coheart
SET TCNumber = 1
WHERE TCNumber = 0 


--SELECT * FROM @tbl4QAReport10Coheart
-- Equivelent to csrForm6 in foxpro	

 
 ---***********************************************************************************************
 --*************************************************************************************************
--- rspQAReport10 8 ,'summary'

DECLARE @tbl4QAReport10 TABLE(
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

DECLARE @tbl4QAReport10Expected TABLE(
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

DECLARE @tbl4QAReport10NotExpected TABLE(
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


DECLARE @tbl4QAReport10Interval TABLE(
	HVCasePK INT,
	Interval CHAR (2)
)


INSERT INTO @tbl4QAReport10Interval
(
HVCasePK,
Interval
)
SELECT 
		qa1.HVCasePK	 
	  , max(Interval) AS Interval
 
 FROM @tbl4QAReport10Coheart qa1
 inner join codeduebydates on scheduledevent = 'Follow Up' AND XDateAge >= DueBy  
 GROUP BY HVCasePK 


--SELECT * FROM @tbl4QAReport10Interval
--ORDER BY Interval 
--- rspQAReport10 8 ,'summary'


-- get expected records that are due for the Interval
INSERT INTO @tbl4QAReport10Expected(
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
	  , CASE WHEN (FUPInWindow = 1) THEN 0 ELSE 1 END AS OutOfWindow
	  , CASE WHEN (FUPInWindow = 1) THEN 1 ELSE 0 END AS RecOK 
	  , cd.[DueBy]
	  , cd.[Interval]
	  , cd.[MaximumDue]
	  , cd.[MinimumDue]		  
	  , FollowUpDate  AS FormDoneDateCompleted
	  , CASE WHEN dbo.IsFormReviewed(FollowUpDate, 'FU', FollowUpPK)=1 THEN 0 ELSE 1 END AS FormNotReviewed 
 
 FROM @tbl4QAReport10Coheart qa1 
 INNER JOIN @tbl4QAReport10Interval cteIn ON qa1.HVCasePK = cteIn.HVCasePK -- we will use column 'Interval' next, which we just added
 inner join codeduebydates cd on scheduledevent = 'Follow Up' AND cteIn.[Interval] = cd.Interval -- to get dueby, max, min (given interval)
 -- The following line gets those tcid's with fu's that are due for the Interval
 INNER JOIN FollowUp fu ON fu.HVCaseFK = qa1.HVCasePK AND fu.FollowUpInterval = cteIn.Interval -- note 'Interval' is the minimum interval 
 ORDER BY HVCasePK 	  

 
 --- rspQAReport10 8 ,'summary'
 --SELECT * FROM @tbl4QAReport10Expected
 
-------- -- The following records, We did find ASQs for the proper interval
-- missing fu cases
-- get expected records that are due for the Interval
INSERT INTO @tbl4QAReport10NotExpected(
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
	 ,CASE 
		WHEN (qa2.TCDOB >= @StartFollowUpInterval18AfterThisDate AND cteIn.[Interval] = '18')   THEN 1 -- missing
		WHEN (qa2.TCDOB < @StartFollowUpInterval18AfterThisDate AND cteIn.[Interval] = '18')   THEN 0  --- not missing
		WHEN cteIn.[Interval] <> '18' THEN 1  --- missing
		ELSE 0 END  --- not missing
	   AS Missing
	 , qa2.OutOfWindow
	 , qa2.RecOK
	  , cd.[DueBy]
	  
 	  , CASE WHEN cteIn.[Interval] = '18' THEN 
		
		CASE WHEN qa2.TCDOB >= @StartFollowUpInterval18AfterThisDate THEN 
				'18'
	    ELSE
				'12'
	    END			
	  
	  ELSE
			cteIn.[Interval]
	  END  AS Interval	 
	  
	  --, cteIn.[Interval]
	  , cd.[MaximumDue]
	  , cd.[MinimumDue]		  	
	 , FormDoneDateCompleted
	 , NULL AS FormNotReviewed
	 
	  FROM @tbl4QAReport10Coheart qa2
	 
	 Left JOIN @tbl4QAReport10Interval cteIn ON qa2.HVCasePK = cteIn.HVCasePK -- we will use column 'Interval' next		
     LEFT JOIN @tbl4QAReport10Expected efu on efu.hvcasepk = qa2.HVCasePK 
     inner join codeduebydates cd on scheduledevent = 'Follow Up' AND cteIn.[Interval] = cd.Interval  -- to get dueby, max, min
WHERE efu.hvcasepk IS NULL 

--------------- rspQAReport10 8 ,'summary'

INSERT INTO @tbl4QAReport10
SELECT * FROM @tbl4QAReport10Expected
Union
SELECT * FROM @tbl4QAReport10NotExpected  



DECLARE @tbl4QAReport10Main TABLE(
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


INSERT INTO @tbl4QAReport10Main
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
	  FROM @tbl4QAReport10

--SELECT * FROM @tbl4QAReport10Main
--ORDER BY HVCasePK 

	
--- rspQAReport10 8 ,'summary'



IF @ReportType = 'summary'

	BEGIN 

	DECLARE @numOfALLScreens INT = 0
	SET @numOfALLScreens = (SELECT count(HVCasePK) FROM @tbl4QAReport10Main)


	DECLARE @numOfMissingCases INT = 0
	SET @numOfMissingCases = (SELECT count(HVCasePK) FROM @tbl4QAReport10Main WHERE Missing = 1)
	
	DECLARE @numOfOutOfWindowsORNotReviewedCases INT = 0
	--SET @numOfOutOfWindowsORNotReviewedCases = (SELECT count(HVCasePK) FROM @tbl4QAReport10Main WHERE OutOfWindow = 1)	
	--Use the following when FormNotReviewed is working .... Khalsa
	SET @numOfOutOfWindowsORNotReviewedCases = (SELECT count(HVCasePK) FROM @tbl4QAReport10Main WHERE OutOfWindow = 1 OR FormNotReviewed=1)	
	
	DECLARE @numOfMissingAndOutOfWindowsCases INT = 0	
	SET @numOfMissingAndOutOfWindowsCases = (@numOfMissingCases + @numOfOutOfWindowsORNotReviewedCases)
	

DECLARE @tbl4QAReport10Summary TABLE(
	[SummaryId] INT,
	[SummaryText] [varchar](200),
	[MissingCases] [varchar](200),
	[NotOnTimeCases] [varchar](200),
	[SummaryTotal] [varchar](100)
)

-- ToDo: Work on the following lines

INSERT INTO @tbl4QAReport10Summary([SummaryId],[SummaryText],[MissingCases],[NotOnTimeCases],[SummaryTotal])
VALUES(10 ,'Follow-Ups for Active Cases with Target Child 6 months or older (N=' + CONVERT(VARCHAR,@numOfALLScreens) + ')' 
	,CONVERT(VARCHAR,@numOfMissingCases) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfMissingCases AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
	,CONVERT(VARCHAR,@numOfOutOfWindowsORNotReviewedCases) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfOutOfWindowsORNotReviewedCases AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
	,CONVERT(VARCHAR,@numOfMissingAndOutOfWindowsCases) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfMissingAndOutOfWindowsCases AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'

	)

	SELECT * FROM @tbl4QAReport10Summary	

	END
ELSE
	BEGIN
	

	SELECT 
		   PC1ID
		 , EventDescription AS IntervalDue		   
		 --, qam.Interval	
		 , convert(varchar(10),FormDue,101) AS FormDue
		 , convert(varchar(10),FormDoneDateCompleted,101) AS FormDate		 	
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
		 
		 
		 		
	 FROM @tbl4QAReport10Main qam
	 inner join codeduebydates cdd on scheduledevent = 'Follow Up' AND cdd.Interval = qam.Interval 
		WHERE (Missing = 1 or OutOfWindow = 1 OR FormNotReviewed=1)
	ORDER BY Worker, PC1ID 	


	END	
	
	--- rspQAReport10 8 ,'summary'
GO
