SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:    <Dar Chen>
-- Create date: <Dec 11, 2012>
-- Description: <4-1B. Intensive Home Visitation Level after Target Child is Born>
-- Edit date: 10/11/2013 CP - workerprogram was NOT duplicating cases when worker transferred
-- =============================================
CREATE procedure [dbo].[rspHVIntensiveLevel_Detail]
(
    @programfk varchar(max)    = null,
    @sdate     datetime,
    @edate     datetime, 
    @sitefk		 int			 = null,
    @posclause	 varchar(200), 
    @negclause	 varchar(200)
)
as

--declare    @programfk varchar(max)    = '1'
--declare    @sdate     DATETIME = '01/01/2010'
--declare    @edate     DATETIME = '01/01/2011'
--declare    @sitefk		 int			 = null
--declare    @posclause	 varchar(200) = null
--declare    @negclause	 varchar(200) = null

if @programfk is null
begin
	select @programfk = substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
									   from HVProgram
									   for xml path ('')),2,8000)
end

set @programfk = REPLACE(@programfk,'"','')
set @sitefk = case when dbo.IsNullOrEmpty(@sitefk) = 1 then 0 else @sitefk end
set @posclause = case when @posclause = '' then null else @posclause end

if object_id('tempdb..#cteCohort') is not null drop table #cteCohort

	create table #cteCohort (
		PC1ID char(13)
		, [Name] varchar(450)
		, [edc_dob] datetime
		, IntakeDate datetime
		, dischargedate datetime
		, [days_length_total] numeric
		, [WorkerName] char(60)
		, [n] int
		, HVCaseFK int
		, caseprogress numeric(3, 1)
		, SiteFK int
		, Levelfk int
		, StartLevelDate datetime
		, EndLevelDate datetime
	)

	insert into #cteCohort 
	SELECT 
	b.PC1ID
	, rtrim(p.PCFirstName) + ' ' + rtrim(p.PCLastName) [Name]
	, isnull(a.tcdob,a.edc) [edc_dob]
	, a.IntakeDate
	, b.DischargeDate
	, sum((datediff(dd, c.StartLevelDate, CASE When c.EndLevelDate is null THEN @edate
	When c.EndLevelDate > @edate THEN @edate
	ELSE c.EndLevelDate END + 1))) [days_length_total]
	, rtrim(w.FirstName) + ' ' + rtrim(w.LastName) [WorkerName]
	, count(*) [n]
	,b.HVCaseFK
	, a.CaseProgress
	, wp.SiteFK
	, c.LevelFK
	, c.StartLevelDate
	, c.EndLevelDate
	FROM HVCase AS a
		JOIN CaseProgram AS b ON a.HVCasePK = b.HVCaseFK
		join dbo.SplitString(@programfk,',') on b.programfk = listitem
		JOIN HVLevelDetail AS c ON c.hvcasefk = a.HVCasePK AND c.StartLevelDate <= @edate
		JOIN udfCaseFilters(@posclause, @negclause, @programfk) cf on cf.HVCaseFK = a.HVCasePK
		JOIN Worker AS w on w.WorkerPK = b.CurrentFSWFK
		JOIN WorkerProgram AS wp ON wp.WorkerFK = w.WorkerPK
		left outer join PC AS p ON p.PCPK = a.PC1FK
	GROUP BY
		b.HVCaseFK, b.PC1ID
		, rtrim(p.PCFirstName) + ' ' + rtrim(p.PCLastName)
		, isnull(a.tcdob,a.edc)
		, a.IntakeDate
		, rtrim(w.FirstName) + ' ' + rtrim(w.LastName)
		, a.CaseProgress
		, wp.SiteFK
		, c.LevelFK
		, c.StartLevelDate
		, c.EndLevelDate
		, b.DischargeDate

;WITH level2 AS (
SELECT a.hvcasefk, min(a.StartLevelDate) [StartLevelDate_Level2]
FROM dbo.HVLevelDetail AS a
join dbo.SplitString(@programfk,',') on a.programfk = listitem
WHERE a.Levelfk IN (16, 18, 20) --AND ProgramFK = @programfk 
AND a.StartLevelDate <= @edate
GROUP BY a.hvcasefk
)
,

xxx AS (
SELECT 
	PC1ID
	, [Name]
	, [edc_dob]
	, IntakeDate
	, sum((datediff(dd, StartLevelDate, CASE When EndLevelDate is null THEN @edate
	When EndLevelDate > @edate THEN @edate
	ELSE EndLevelDate END + 1))) [days_length_total]
	, [WorkerName]
	, count(*) [n]
	,#cteCohort.HVCaseFK
FROM #cteCohort
left outer join level2 on level2.HVCaseFK = #cteCohort.HVCaseFK
WHERE --b.ProgramFK = @programfk AND 
caseprogress >= 9
AND IntakeDate <= @edate
AND (dischargedate is NULL or dischargedate >= @sdate)
AND (case when @SiteFK = 0 then 1 when SiteFK = @SiteFK then 1 else 0 end = 1)
AND Levelfk IN (12, 14)
AND (StartLevelDate_Level2 IS NULL OR StartLevelDate < StartLevelDate_Level2)
GROUP BY
#cteCohort.HVCaseFK
, PC1ID
, [Name]
, [edc_dob]
, IntakeDate
, WorkerName
)
,

yyy AS (
SELECT DISTINCT HVCaseFK
FROM #cteCohort
WHERE --b.ProgramFK = @programfk AND 
caseprogress >= 9
AND IntakeDate <= @edate
AND (dischargedate is NULL or dischargedate >= @sdate)
AND (case when @SiteFK = 0 then 1 when SiteFK = @SiteFK then 1 else 0 end = 1)
AND Levelfk IN (16,18,20)
),

zzz AS (
SELECT 
sum(CASE WHEN a.days_length_total >= 183 THEN 1 ELSE 0 END) [more_than_6mo]
, sum(CASE WHEN a.days_length_total >= 183 THEN 0 ELSE 1 END) [less_than_6mo]
, count(*) [total_number]
FROM xxx AS a
LEFT OUTER JOIN yyy AS b ON a.HVCaseFK = b.HVCaseFK
WHERE b.HVCaseFK IS NOT NULL OR a.[days_length_total] >= 183
)

SELECT 
CASE WHEN a.days_length_total >= 183 THEN 2 ELSE 1 END [level1_less_183],
a.*,
c.*,
CASE WHEN b.HVCaseFK IS NOT NULL THEN 'Yes' ELSE 'No' END [Level2_3_4]
FROM xxx AS a
JOIN zzz AS c ON 1 = 1
LEFT OUTER JOIN yyy AS b ON a.HVCaseFK = b.HVCaseFK
WHERE b.HVCaseFK IS NOT NULL OR a.[days_length_total] >= 183
ORDER BY level1_less_183, PC1ID

drop table #cteCohort
GO
