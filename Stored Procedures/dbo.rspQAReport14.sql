SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <October 18, 2012>
-- Description:	<This QA report gets you '14. No Home Visits since <xdate-60> for Active Cases Excludes Level X and Level 4 Cases '>
-- Modified: <10-20-15 Fix calc DOB cdc>
-- rspQAReport1-4 31, 'summary'	--- for summary page
-- rspQAReport14 31			--- for main report - location = 2
-- rspQAReport14 null			--- for main report for all locations
-- =============================================


CREATE procedure [dbo].[rspQAReport14](
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

--SELECT @Back2MonthsFromAnalysisPoint	

--DECLARE @tbl4QAReport14 TABLE(
--	HVCasePK INT, 
--	[PC1ID] [char](13),
--	LengthInProgress INT,
--	Worker [varchar](200),	
--	currentLevel [varchar](50)	
--	)

	
DECLARE @tbl4QAReport14Final TABLE(	
	HVCasePK INT, 
	[PC1ID] [char](13),		
	LastVisitAttempted [datetime],
	LastVisitActual [datetime],  	
	Worker [varchar](200),
	currentLevel [varchar](50)	
	)

-- table variable for holding Init Required Data
DECLARE @tbl4QAReport14Detail TABLE(
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
	LengthInProgress INT  
	)

INSERT INTO @tbl4QAReport14Detail(
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
	LengthInProgress	
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
	datediff(dd, h.IntakeDate,  @LastDayofPreviousMonth)  AS LengthInProgress
		
	from dbo.CaseProgram cp
	inner join dbo.SplitString(@programfk,',') on cp.programfk = listitem
	left join codeLevel on cp.CurrentLevelFK = codeLevel.codeLevelPK
	inner join dbo.HVCase h ON cp.HVCaseFK = h.HVCasePK	
	inner join worker fsw on cp.CurrentFSWFK = fsw.workerpk
	
	
	where   ((h.IntakeDate <= dateadd(M, -1, @LastDayofPreviousMonth)) AND (h.IntakeDate IS NOT NULL))	 		  
			AND (cp.DischargeDate IS NULL OR cp.DischargeDate > @LastDayofPreviousMonth)
			AND codeLevel.LevelName NOT IN ('Level 4', 'Level X')
			AND cp.CaseStartDate <= @Back2MonthsFromAnalysisPoint  -- new 			
			order by h.HVCasePK -- h.IntakeDate 

--SELECT * FROM @tbl4QAReport14Detail

;
WITH cteHVLogRegularVisits AS
(

		SELECT HVCaseFK FROM HVLog h 
		inner join dbo.SplitString(@programfk,',') on h.programfk = listitem
		WHERE cast(VisitStartTime AS DATE) BETWEEN @Back2MonthsFromAnalysisPoint AND @LastDayofPreviousMonth
		AND VisitType <> '0001' -- all regular visits
		GROUP BY HVCaseFK
	
)


	SELECT HVCasePK
		 , PC1ID
		 , LengthInProgress
		 , Worker
		 , currentLevel
		INTO #tbl4QAReport14 -- Used temp table, because insert same into a variable table name like @tbl4QAReport14, SQL Server was taking 5 secs to complete ... Khalsa
	 FROM @tbl4QAReport14Detail qa3
	 WHERE HVCasePK NOT IN (SELECT HVCaseFK FROM cteHVLogRegularVisits h)  

 

-- rspQAReport14 31 ,'summary'
---- fill in LastVisit and LastAttempted

;
WITH cteHVLogAttempted AS
(
	SELECT HVCaseFK,max(VisitStartTime) VisitStartTime FROM HVLog h 
	inner join dbo.SplitString(@programfk,',') on h.programfk = listitem
	WHERE VisitType = '0001' -- all attempted visits
	GROUP BY HVCaseFK 
	
)
,
 cteHVLogActualVisits AS
(
	SELECT HVCaseFK,max(VisitStartTime) VisitStartTime FROM HVLog h 
	inner join dbo.SplitString(@programfk,',') on h.programfk = listitem
	WHERE VisitType <> '0001' -- all regular visits
	AND VisitStartTime < @LastDayofPreviousMonth
	GROUP BY HVCaseFK 
	
)

INSERT INTO @tbl4QAReport14Final
(
	   HVCasePK
	 , PC1ID	 
	 , LastVisitAttempted
	 , LastVisitActual
	 , Worker
	 , currentLevel
)
SELECT HVCasePK
	 , PC1ID
	 , att.VisitStartTime AS DateLastAttempted
	 , act.VisitStartTime AS LastHomeVisitDate	 
	 , Worker
	 , currentLevel

 FROM #tbl4QAReport14 qa14
 LEFT JOIN cteHVLogAttempted att ON att.HVCaseFK = qa14.HVCasePK 
 LEFT JOIN cteHVLogActualVisits act ON act.HVCaseFK = qa14.HVCasePK 
 ORDER BY Worker 

DROP TABLE #tbl4QAReport14

-- rspQAReport14 31 ,'summary'

if @ReportType='summary'
BEGIN 

DECLARE @numOfALLScreens INT = 0

-- Note: We using sum on TCNumber to get correct number of cases, as there may be twins etc.
SET @numOfALLScreens = (SELECT count(HVCasePK) FROM @tbl4QAReport14Detail)  

DECLARE @numOfActiveIntakeCases INT = 0
SET @numOfActiveIntakeCases = (SELECT count(HVCasePK) FROM @tbl4QAReport14Final)

-- leave the following here
if @numOfALLScreens is null
SET @numOfALLScreens = 0

if @numOfActiveIntakeCases is null
SET @numOfActiveIntakeCases = 0

DECLARE @tbl4QAReport14Summary TABLE(
	[SummaryId] INT,
	[SummaryText] [varchar](200),
	[SummaryTotal] [varchar](100)
)

INSERT INTO @tbl4QAReport14Summary([SummaryId],[SummaryText],[SummaryTotal])
VALUES(14 ,'No Home Visits since ' + convert(VARCHAR(12),@Back2MonthsFromAnalysisPoint, 101) + ' for Active Cases Excludes Level X and Level 4 Cases (N=' + CONVERT(VARCHAR,@numOfALLScreens) + ')' 
,CONVERT(VARCHAR,@numOfActiveIntakeCases) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfActiveIntakeCases AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
)

SELECT * FROM @tbl4QAReport14Summary	

END
ELSE
BEGIN

SELECT 	
    PC1ID,
    
		case
		   when LastVisitActual is not null then
			   convert(varchar(10),LastVisitActual,101)
		   else
			   ''
		end as LastVisitActual,    

		case
		   when LastVisitAttempted is not null then
			   convert(varchar(10),LastVisitAttempted,101)
		   else
			   ''
		end as LastVisitAttempted        
    

  , Worker
  , currentLevel
 FROM @tbl4QAReport14Final


--- rspQAReport14 31 ,'summary'

END
GO
