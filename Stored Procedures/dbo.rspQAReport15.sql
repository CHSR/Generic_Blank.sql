SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <October 24, 2012>
-- Description:	<This QA report gets you '15. Cases on Level X for more than 93 days '>
-- rspQAReport15 34, 'summary'	--- for summary page
-- rspQAReport15 34			--- for main report - location = 2
-- rspQAReport15 null			--- for main report for all locations
-- =============================================


CREATE procedure [dbo].[rspQAReport15](
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

DECLARE @Back2MonthsFromAnalysisPoint DateTime
SET @Back2MonthsFromAnalysisPoint = dateadd(m,-2,@LastDayofPreviousMonth)

-- table variable for holding Init Required Data
DECLARE @tbl4QAReport15Detail TABLE(
	HVCasePK INT, 
	[PC1ID] [char](13),	
	TCDOB [datetime],
	FormDueDate [datetime],	
	Worker [varchar](200),
	currentLevel [varchar](50),
	IntakeDate [datetime],
	DischargeDate [datetime],
	CaseProgress [NUMERIC] (3),
	IntakeLevel [char](1),
	TCNumber INT,
	MultipleBirth [char](3),
	XDateAge INT,
	TCName [varchar](200),
	DaysSinceLastMedicalFormEdit INT,
	LengthInProgress INT,
	CurrentLevelDate [datetime]  
	)

INSERT INTO @tbl4QAReport15Detail(
	HVCasePK,
	[PC1ID],
	TCDOB,
	FormDueDate,
	Worker,
	currentLevel,
	IntakeDate,
	DischargeDate,
	CaseProgress,
	IntakeLevel,
	TCNumber,
	MultipleBirth,
	XDateAge,
	TCName,
	DaysSinceLastMedicalFormEdit,
	LengthInProgress,
	CurrentLevelDate	
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
	
	--	Form due date is 30.44 days after intake if postnatal at intake or 30.44 days after TC DOB if prenatal at intake
	case
	   when (h.tcdob is not NULL AND h.tcdob <= h.IntakeDate) THEN -- postnatal
		   dateadd(mm,1,h.IntakeDate) 
	   when (h.tcdob is not NULL AND h.tcdob > h.IntakeDate) THEN -- pretnatal
					dateadd(mm,1,h.tcdob) 
	   when (h.tcdob is NULL AND h.edc > h.IntakeDate) THEN -- pretnatal
					dateadd(mm,1,h.edc) 					
	end as FormDueDate,
	
	LTRIM(RTRIM(fsw.firstname))+' '+LTRIM(RTRIM(fsw.lastname)) as worker,

	codeLevel.LevelName,
	h.IntakeDate,
	cp.DischargeDate,
	h.CaseProgress,
	h.IntakeLevel,
	h.TCNumber,
	CASE WHEN h.TCNumber > 1 THEN 'Yes' ELSE 'No' End
	as [MultipleBirth],
		case
	   when h.tcdob is not null then
		 datediff(dd, h.tcdob,  @LastDayofPreviousMonth)
	   else
		   datediff(dd, h.edc, @LastDayofPreviousMonth)
	end as XDateAge,
	'' AS TCName,
	''  AS DaysSinceLastMedicalFormEdit,
	datediff(dd, h.IntakeDate,  @LastDayofPreviousMonth)  AS LengthInProgress,
	cp.CurrentLevelDate
		
	from dbo.CaseProgram cp
	inner join dbo.SplitString(@programfk,',') on cp.programfk = listitem
	left join codeLevel on cp.CurrentLevelFK = codeLevel.codeLevelPK
	inner join dbo.HVCase h ON cp.HVCaseFK = h.HVCasePK	
	inner join worker fsw on cp.CurrentFSWFK = fsw.workerpk
	
	
	where   ((h.IntakeDate <= dateadd(M, -1, @LastDayofPreviousMonth)) AND (h.IntakeDate IS NOT NULL))	 		  
			AND (cp.DischargeDate IS NULL OR cp.DischargeDate > @LastDayofPreviousMonth)
			AND codeLevel.LevelName IN ('Level X')			
			order by h.HVCasePK
	
-- rspQAReport15 34 ,'summary'

--SELECT * FROM @tbl4QAReport15Detail



-- rspQAReport15 34 ,'summary'

if @ReportType='summary'
BEGIN 

DECLARE @numOfALLScreens INT = 0
SET @numOfALLScreens = (SELECT count(HVCasePK) FROM @tbl4QAReport15Detail)  

DECLARE @numOfCasesOnLevelX INT = 0
SET @numOfCasesOnLevelX = (SELECT count(HVCasePK) FROM @tbl4QAReport15Detail WHERE datediff(dd, CurrentLevelDate, @LastDayofPreviousMonth) > 93)  

-- leave the following here
if @numOfALLScreens is null
SET @numOfALLScreens = 0

if @numOfCasesOnLevelX is null
SET @numOfCasesOnLevelX = 0

DECLARE @tbl4QAReport15Summary TABLE(
	[SummaryId] INT,
	[SummaryText] [varchar](200),
	[SummaryTotal] [varchar](100)
)

INSERT INTO @tbl4QAReport15Summary([SummaryId],[SummaryText],[SummaryTotal])
VALUES(15 ,'Cases on Level X for more than 91 days (N=' + CONVERT(VARCHAR,@numOfALLScreens) + ')' 
,CONVERT(VARCHAR,@numOfCasesOnLevelX) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfCasesOnLevelX AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
)

SELECT * FROM @tbl4QAReport15Summary	

END
ELSE
BEGIN

SELECT 	
    PC1ID,
		case
		   when CurrentLevelDate is not null then
			   convert(varchar(10),CurrentLevelDate,101)
		   else
			   ''
		end as StartDateOfLevelX  
    
  , datediff(dd, CurrentLevelDate, @LastDayofPreviousMonth) AS NumberOfDaysOnLevelX
  , Worker
  , currentLevel  
 FROM @tbl4QAReport15Detail
 WHERE datediff(dd, CurrentLevelDate, @LastDayofPreviousMonth) > 93
 ORDER BY Worker, PC1ID 
 
 


--- rspQAReport15 34 ,'summary'

END
GO
