SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <October 18, 2012>
-- Description:	<This QA report gets you '12. No Service Referrals for Active Cases '>
-- rspQAReport12 31, 'summary'	--- for summary page
-- rspQAReport12 31			--- for main report - location = 2
-- rspQAReport12 null			--- for main report for all locations

-- Because of transfer cases, JH said that don't consider ProgramFK for Service Referral forms ... Khalsa 1/27/2014
-- =============================================


CREATE procedure [dbo].[rspQAReport12](
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

DECLARE @tbl4QAReport12 TABLE(
	HVCasePK INT, 
	[PC1ID] [char](13),	
	TCDOB [datetime],
	TCName [varchar](200),
	Worker [varchar](200),
	TCAgeInMonths INT,
	currentLevel [varchar](50),
	LengthInProgram INT  
	
	)


-- table variable for holding Init Required Data
DECLARE @tbl4QAReport12Detail TABLE(
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
	LengthInProgram INT  
	)

INSERT INTO @tbl4QAReport12Detail(
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
	LengthInProgram	
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
	datediff(dd, h.IntakeDate,  @LastDayofPreviousMonth)  AS LengthInProgram
		
	from dbo.CaseProgram cp
	inner join dbo.SplitString(@programfk,',') on cp.programfk = listitem
	left join codeLevel on cp.CurrentLevelFK = codeLevel.codeLevelPK
	inner join dbo.HVCase h ON cp.HVCaseFK = h.HVCasePK	
	inner join worker fsw on cp.CurrentFSWFK = fsw.workerpk
	
	
	where   ((h.IntakeDate <= dateadd(M, -1, @LastDayofPreviousMonth)) AND (h.IntakeDate IS NOT NULL))	 		  
			AND (cp.DischargeDate IS NULL OR cp.DischargeDate > @LastDayofPreviousMonth)
			order by cp.OldID -- h.IntakeDate 

	
-- rspQAReport12 31 ,'summary'



INSERT INTO @tbl4QAReport12
(
	HVCasePK,
	[PC1ID],
	LengthInProgram,
	Worker,
	currentLevel
)
SELECT HVCasePK
	 , PC1ID
	 , LengthInProgram
	 , Worker
	 , currentLevel	 

 FROM @tbl4QAReport12Detail
WHERE HVCasePK NOT  IN (
SELECT HVCaseFK FROM ServiceReferral sr
--inner join dbo.SplitString(@programfk,',') on sr.programfk = listitem -- because of transfer cases, JH said that don't consider ProgramFK for Service Referral forms ... Khalsa 1/27/2014
)



if @ReportType='summary'
BEGIN 

DECLARE @numOfALLScreens INT = 0

-- Note: We using sum on TCNumber to get correct number of cases, as there may be twins etc.
SET @numOfALLScreens = (SELECT count(HVCasePK) FROM @tbl4QAReport12Detail)  

DECLARE @numOfActiveIntakeCases INT = 0
SET @numOfActiveIntakeCases = (SELECT count(HVCasePK) FROM @tbl4QAReport12)

-- leave the following here
if @numOfALLScreens is null
SET @numOfALLScreens = 0

if @numOfActiveIntakeCases is null
SET @numOfActiveIntakeCases = 0


DECLARE @tbl4QAReport12Summary TABLE(
	[SummaryId] INT,
	[SummaryText] [varchar](200),
	[SummaryTotal] [varchar](100)
)

INSERT INTO @tbl4QAReport12Summary([SummaryId],[SummaryText],[SummaryTotal])
VALUES(12 ,'No Service Referrals for Active Cases (N=' + CONVERT(VARCHAR,@numOfALLScreens) + ')' 
,CONVERT(VARCHAR,@numOfActiveIntakeCases) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfActiveIntakeCases AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
)

SELECT * FROM @tbl4QAReport12Summary	

END
ELSE
BEGIN

SELECT 
	   PC1ID
	 , LengthInProgram
	 , Worker
	 , currentLevel	 

 FROM @tbl4QAReport12
ORDER BY Worker, PC1ID 

--- rspQAReport12 31 ,'summary'

END
GO
