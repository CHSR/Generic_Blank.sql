SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <October 1st, 2012>
-- Description:	<This QA report gets you 'Screens, not assessed or closed and TC greater than 3 months  olds'>
-- rspQAReport2 2, 'summary'	--- for summary page
-- rspQAReport2 2				--- for main report - location = 2
-- rspQAReport2 null				--- for main report for all locations
-- =============================================


CREATE procedure [dbo].[rspQAReport2](
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

-- table variable for holding Init Required Data
DECLARE @tbl4QAReport2Detail TABLE(
	[PC1ID] [char](13),
	ScreenDate [datetime],
	TCDOB [datetime],
	tcdobplus14days [datetime],
	tcdobplus3months [datetime],
	CurrentFAW [varchar](200),
	ReferralSourceName [varchar](200),
	ActivityDate [CHAR] (8)

)

INSERT INTO @tbl4QAReport2Detail(
	PC1ID,
	ScreenDate,
	TCDOB,
	tcdobplus14days,
	tcdobplus3months,
	CurrentFAW,
	ReferralSourceName,
	ActivityDate
)
select 
	cp.PC1ID,
	h.ScreenDate,
	
	case
	   when h.tcdob is not null then
		   h.tcdob
	   else
		   h.edc
	end as tcdob,

	case
	   when h.tcdob is not null then
		   dateadd(dd,14,h.tcdob) 
	   else
		   dateadd(dd,14,h.edc) 
	end as tcdobplus14days,
	
	case
	   when h.tcdob is not null then
		   dateadd(mm,3,h.tcdob) 
	   else
		   dateadd(mm,3,h.edc) 
	end as tcdobplus3months,
	LTRIM(RTRIM(faw.firstname))+' '+LTRIM(RTRIM(faw.lastname)) as CurrentFAW,
	p2.ReferralSourceName,	
	--date as month / year format					 
	right('00' + convert(varchar(2),month(p.PADate)),2) + '/' + cast(datepart(yyyy,p.PADate) as varchar(4)) AS ActivityDate						
	
	from dbo.CaseProgram cp
	inner join dbo.SplitString(@programfk,',') on cp.programfk = listitem
	inner join dbo.HVCase h ON cp.HVCaseFK = h.HVCasePK
	INNER JOIN HVScreen h1 ON h1.HVCaseFK = cp.HVCaseFK
	
	
	--get the latest preassessment form, if there are more than one
	LEFT JOIN (SELECT a.HVCaseFK, max(a.PADate) [PADate]
	FROM Preassessment AS a 
	INNER JOIN CaseProgram cp ON cp.HVCaseFK = a.HVCaseFK
	inner join dbo.SplitString(@programfk,',') on cp.programfk = listitem
	WHERE a.PADate <= @LastDayofPreviousMonth
	GROUP BY a.HVCaseFK) AS p ON p.HVCaseFK = h1.HVCaseFK		
	
	
	inner join listReferralSource as p2 on p2.listReferralSourcePK = h1.ReferralSourceFK
	INNER JOIN Worker faw ON faw.WorkerPK = cp.CurrentFAWFK		
	
	where caseprogress <= 2 -- Engagement efforts continue into next month
	AND h.ScreenDate <= @LastDayofPreviousMonth
	AND cp.DischargeDate IS NULL  --- case not closed

-- rspQAReport2 2, 'summary'	--- for summary page
-- rspQAReport2 2				--- for main report

if @ReportType='summary'
BEGIN 

DECLARE @numOfALLScreens INT = 0
SET @numOfALLScreens = (SELECT count(PC1ID) FROM @tbl4QAReport2Detail)

DECLARE @numOfScreensOver3months INT = 0
SET @numOfScreensOver3months = (
SELECT count(PC1ID) FROM @tbl4QAReport2Detail			
				WHERE datediff(dd, tcdob , @LastDayofPreviousMonth) > datediff(dd, dateadd(m, 3, @LastDayofPreviousMonth), @LastDayofPreviousMonth) * -1
)

if @numOfALLScreens is null
SET @numOfALLScreens = 0

if @numOfScreensOver3months is null
SET @numOfScreensOver3months = 0

DECLARE @tbl4QAReport2Summary TABLE(
	[SummaryId] INT,
	[SummaryText] [varchar](200),
	[SummaryTotal] [varchar](100)
)

INSERT INTO @tbl4QAReport2Summary([SummaryId],[SummaryText],[SummaryTotal])
VALUES(2 ,'Screens, not assessed or closed and TC greater than 3 months  old (N=' + CONVERT(VARCHAR,@numOfALLScreens) + ')' 
,CONVERT(VARCHAR,@numOfScreensOver3months) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfScreensOver3months AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
)

SELECT * FROM @tbl4QAReport2Summary	

END
ELSE
BEGIN
SELECT PC1ID,
		case
		   when ScreenDate is not null then
			   convert(varchar(10),ScreenDate,101)
		   else
			   ''
		end as ScreenDate,

		case
		   when TCDOB is not null then
			   convert(varchar(10),TCDOB,101)
		   else
			   ''
		end as TCDOB,

		case
		   when tcdobplus14days is not null then
			   convert(varchar(10),tcdobplus14days,101)
		   else
			   ''
		end as AssessmentAgeOutDate,

		case
		   when tcdobplus3months is not null then
			   convert(varchar(10),tcdobplus3months,101)
		   else
			   ''
		end as EnrollmentAgeOutDate
		
	 , CurrentFAW
	 , ReferralSourceName,
	 	case
		   when ActivityDate is not null then
			   ActivityDate
		   else
			   ''
		end as PreassessmentFormDate	 
	 
	 
	  FROM @tbl4QAReport2Detail	
WHERE datediff(dd, tcdob , @LastDayofPreviousMonth) > datediff(dd, dateadd(m, 3, @LastDayofPreviousMonth), @LastDayofPreviousMonth) * -1		
ORDER BY CurrentFAW,PC1ID 	

END
GO
