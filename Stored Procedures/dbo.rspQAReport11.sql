SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <October 18, 2012>
-- Description:	<This QA report gets you '11. Cases with infrequent entries in Target Child Medical '>
-- rspQAReport11 1, 'summary'	--- for summary page
-- rspQAReport11 31			--- for main report - location = 2
-- rspQAReport11 null			--- for main report for all locations
-- =============================================


CREATE procedure [dbo].[rspQAReport11](
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

DECLARE @tbl4QAReport11 TABLE(
	HVCasePK INT, 
	[PC1ID] [char](13),	
	TCDOB [datetime],
	TCName [varchar](200),
	Worker [varchar](200),
	TCAgeInMonths FLOAT,
	DaysSinceLastMedicalFormEdit INT, 
	currentLevel [varchar](50)
	
	)


-- table variable for holding Init Required Data
DECLARE @tbl4QAReport11Detail TABLE(
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
	DaysSinceLastMedicalFormEdit INT 
	)

INSERT INTO @tbl4QAReport11Detail(
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
	DaysSinceLastMedicalFormEdit	
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
	''  AS DaysSinceLastMedicalFormEdit
		
	from dbo.CaseProgram cp
	inner join dbo.SplitString(@programfk,',') on cp.programfk = listitem
	left join codeLevel on cp.CurrentLevelFK = codeLevel.codeLevelPK
	inner join dbo.HVCase h ON cp.HVCaseFK = h.HVCasePK	
	inner join worker fsw on cp.CurrentFSWFK = fsw.workerpk
	
	
	where   ((h.IntakeDate <= dateadd(M, -1, @LastDayofPreviousMonth)) AND (h.IntakeDate IS NOT NULL))	 		  
			AND (cp.DischargeDate IS NULL OR cp.DischargeDate > @LastDayofPreviousMonth)
			AND (( (@LastDayofPreviousMonth >= dateadd(M, 1, h.edc)) AND (h.tcdob IS NULL) ) OR ( (@LastDayofPreviousMonth >= dateadd(M, 1, h.tcdob)) AND (h.edc IS NULL) ) )  
			order by cp.OldID -- h.IntakeDate 

			-- to get accurate count of case
			UPDATE @tbl4QAReport11Detail
			SET TCNumber = 1
			WHERE TCNumber = 0
	
			-- if you execute the following statement, you may not see all records i.e. two rows for twins etc, there is only one row for twin etc
			-- so number of records in the resultset will be less
			--SELECT * FROM @tbl4QAReport11Detail

	
--- rspQAReport11 1 ,'summary'

-- Get TCMedical records with max date
DECLARE @tbl4TCMedicalRecordsWithMaxDate TABLE(
	HVCaseFK INT,
	TCMedical [datetime]
)

INSERT INTO @tbl4TCMedicalRecordsWithMaxDate
(
	HVCaseFK,
	TCMedical
)
SELECT 
	HVCasePK,
	  max(isnull(t.TCMedicalEditDate,t.TCMedicalCreateDate)) AS TCMedical
 FROM @tbl4QAReport11Detail qa1 
 LEFT JOIN TCMedical t ON qa1.HVCasePK = t.HVCaseFK 
GROUP BY HVCasePK 

;
WITH cteQAReport11 AS 
(
SELECT 
	QA11.HVCasePK, 
	QA11.[PC1ID],
	QA11.TCDOB,
	rtrim(tcfirstname)+' '+rtrim(tclastname) TCName,
	QA11.Worker,
	XDateAge/30.44 AS TCAgeInMonths,	
	datediff(dd, t.TCMedical, @LastDayofPreviousMonth ) AS DaysSinceLastMedicalFormEdit,
	QA11.currentLevel	
	
 FROM @tbl4QAReport11Detail QA11
 INNER JOIN @tbl4TCMedicalRecordsWithMaxDate t ON t.HVCaseFK = QA11.HVCasePK AND datediff(dd, t.TCMedical, @LastDayofPreviousMonth ) > 60
 LEFT JOIN TCID T1 ON t.HVCaseFK = T1.HVCaseFK
WHERE (XDateAge/30.44 < 8) AND (T1.TCDOD > @LastDayofPreviousMonth OR T1.TCDOD IS NULL)

UNION 

SELECT 
	QA11.HVCasePK, 
	QA11.[PC1ID],
	QA11.TCDOB,
	rtrim(tcfirstname)+' '+rtrim(tclastname) TCName,
	QA11.Worker,
	XDateAge/30.44 AS TCAgeInMonths,	
	datediff(dd, t.TCMedical, @LastDayofPreviousMonth ) AS DaysSinceLastMedicalFormEdit,
	QA11.currentLevel	
	
 FROM @tbl4QAReport11Detail QA11
 INNER JOIN @tbl4TCMedicalRecordsWithMaxDate t ON t.HVCaseFK = QA11.HVCasePK AND datediff(dd, t.TCMedical, @LastDayofPreviousMonth ) > 183
 LEFT JOIN TCID T1 ON t.HVCaseFK = T1.HVCaseFK
WHERE (XDateAge/30.44 BETWEEN 8 AND 24) AND (T1.TCDOD > @LastDayofPreviousMonth OR T1.TCDOD IS NULL)

UNION

SELECT 
	QA11.HVCasePK, 
	QA11.[PC1ID],
	QA11.TCDOB,
	rtrim(tcfirstname)+' '+rtrim(tclastname) TCName,
	QA11.Worker,
	XDateAge/30.44 AS TCAgeInMonths,	
	datediff(dd, t.TCMedical, @LastDayofPreviousMonth ) AS DaysSinceLastMedicalFormEdit,
	QA11.currentLevel	
	
 FROM @tbl4QAReport11Detail QA11
 INNER JOIN @tbl4TCMedicalRecordsWithMaxDate t ON t.HVCaseFK = QA11.HVCasePK AND datediff(dd, t.TCMedical, @LastDayofPreviousMonth ) > 365
 LEFT JOIN TCID T1 ON t.HVCaseFK = T1.HVCaseFK
WHERE (XDateAge/30.44 > 24) AND (T1.TCDOD > @LastDayofPreviousMonth OR T1.TCDOD IS NULL)

)

INSERT INTO @tbl4QAReport11
(
	HVCasePK,
	[PC1ID],
	TCDOB,
	TCName,
	Worker,
	TCAgeInMonths,
	DaysSinceLastMedicalFormEdit,
	currentLevel
)
SELECT * FROM cteQAReport11



if @ReportType='summary'
BEGIN 

DECLARE @numOfALLScreens INT = 0

-- Note: We using sum on TCNumber to get correct number of cases, as there may be twins etc.
SET @numOfALLScreens = (SELECT sum(TCNumber) FROM @tbl4QAReport11Detail)  

DECLARE @numOfActiveIntakeCases INT = 0
SET @numOfActiveIntakeCases = (SELECT count(HVCasePK) FROM @tbl4QAReport11)

-- leave the following here
if @numOfALLScreens is null
SET @numOfALLScreens = 0

if @numOfActiveIntakeCases is null
SET @numOfActiveIntakeCases = 0


DECLARE @tbl4QAReport11Summary TABLE(
	[SummaryId] INT,
	[SummaryText] [varchar](200),
	[SummaryTotal] [varchar](100)
)

INSERT INTO @tbl4QAReport11Summary([SummaryId],[SummaryText],[SummaryTotal])
VALUES(11 ,'Cases with infrequent entries in Target Child Medical (N=' + CONVERT(VARCHAR,@numOfALLScreens) + ')' 
,CONVERT(VARCHAR,@numOfActiveIntakeCases) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfActiveIntakeCases AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
)

SELECT * FROM @tbl4QAReport11Summary	

END
ELSE
BEGIN

SELECT 
	   PC1ID,
		case
		   when TCDOB is not null then
			   convert(varchar(10),TCDOB,101)
		   else
			   ''
		end as TCDOB
		
	 , TCName
	 , Worker
	 , cast(TCAgeInMonths AS DECIMAL(10,1)) AS TCAgeInMonths
	 , DaysSinceLastMedicalFormEdit
	 , currentLevel

 FROM @tbl4QAReport11
ORDER BY Worker, TCName

--- rspQAReport11 1 ,'summary'

END
GO
