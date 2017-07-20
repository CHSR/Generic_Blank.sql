SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <October 1st, 2012>
-- Description:	<This QA report gets you 'Intakes for Active Cases '>
-- rspQAReport4 31, 'summary'	--- for summary page
-- rspQAReport4 31			--- for main report - location = 2
-- rspQAReport4 null			--- for main report for all locations
-- =============================================


CREATE procedure [dbo].[rspQAReport4](
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

-- table variable for holding Init Required Data
DECLARE @tbl4QAReport4Detail TABLE(
	HVCasePK INT, 
	[PC1ID] [char](13),	
	TCDOB [datetime],
	FormDueDate [datetime],	
	Worker [varchar](200),
	currentLevel [varchar](50),
	IntakeDate [datetime],
	DischargeDate [datetime],
	CaseProgress [NUMERIC] (3)
)

INSERT INTO @tbl4QAReport4Detail(
	HVCasePK,
	[PC1ID],
	TCDOB,
	FormDueDate,
	Worker,
	currentLevel,
	IntakeDate,
	DischargeDate,
	CaseProgress 
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

	-- Form due date is intake date plus 30.44 days
	dateadd(mm,1,h.IntakeDate) as FormDueDate,
	
	LTRIM(RTRIM(fsw.firstname))+' '+LTRIM(RTRIM(fsw.lastname)) as worker,

	codeLevel.LevelName,
	h.IntakeDate,
	cp.DischargeDate,
	h.CaseProgress 			
	
	from dbo.CaseProgram cp
	inner join dbo.SplitString(@programfk,',') on cp.programfk = listitem
	left join codeLevel on cp.CurrentLevelFK = codeLevel.codeLevelPK
	inner join dbo.HVCase h ON cp.HVCaseFK = h.HVCasePK	
	inner join worker fsw on cp.CurrentFSWFK = fsw.workerpk
	
	where   ((h.IntakeDate <= dateadd(M, -1, @LastDayofPreviousMonth)) AND (h.IntakeDate IS NOT NULL))	 		  
			AND (cp.DischargeDate IS NULL OR cp.DischargeDate > @LastDayofPreviousMonth)  --- case not closed
			order by h.IntakeDate 
	
--SELECT * FROM @tbl4QAReport4Detail
	
--- rspQAReport4 31 ,'summary'

IF @ReportType = 'summary'

	BEGIN 

	DECLARE @numOfALLScreens INT = 0
	SET @numOfALLScreens = (SELECT count(PC1ID) FROM @tbl4QAReport4Detail)

	DECLARE @numOfActiveIntakeCases INT = 0
	SET @numOfActiveIntakeCases = (
	SELECT count(HVCasePK) FROM @tbl4QAReport4Detail
	where CaseProgress < 10	

	)

-- leave the following here
if @numOfALLScreens is null
SET @numOfALLScreens = 0

if @numOfActiveIntakeCases is null
SET @numOfActiveIntakeCases = 0


DECLARE @tbl4QAReport4Summary TABLE(
	[SummaryId] INT,
	[SummaryText] [varchar](200),
	[SummaryTotal] [varchar](100)
)

INSERT INTO @tbl4QAReport4Summary([SummaryId],[SummaryText],[SummaryTotal])
VALUES(4 ,'Intakes for Active Cases (N=' + CONVERT(VARCHAR,@numOfALLScreens) + ')' 
	,CONVERT(VARCHAR,@numOfActiveIntakeCases) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfActiveIntakeCases AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
	)

	SELECT * FROM @tbl4QAReport4Summary	

	END
ELSE
	BEGIN
	SELECT 		
		[PC1ID],
		case
		   when IntakeDate is not null then
			   convert(varchar(10),IntakeDate,101)
		   else
			   ''
		end as IntakeDate,
		case
		   when FormDueDate is not null then
			   convert(varchar(10),FormDueDate,101)
		   else
			   ''
		end as FormDueDate,	
		Worker,
		currentLevel 
	 FROM @tbl4QAReport4Detail	
		where CaseProgress < 10

	ORDER BY Worker, PC1ID 	


	END
GO
