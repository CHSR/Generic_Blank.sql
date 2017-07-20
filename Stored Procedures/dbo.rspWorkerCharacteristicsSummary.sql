SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Dar Chen
-- Create date: 04/24/2012
-- Description:	Home Visit Log Summary Quarterly
-- Edit date: 10/11/2013 CP - workerprogram was NOT duplicating cases when worker transferred
-- =============================================
CREATE procedure [dbo].[rspWorkerCharacteristicsSummary]
    @programfk VARCHAR(MAX) = null,
    @StartDt   datetime,
    @EndDt     datetime,
    @SiteFK	   int = null,
    @casefilterspositive varchar(200)
as

--DECLARE @StartDt AS DATE = '07/01/2012'
--DECLARE @EndDt AS DATE = '03/31/2013'
--DECLARE @ProgramFK AS VARCHAR(MAX) = '24'
--DECLARE @SiteFK	   int = null
--DECLARE @casefilterspositive varchar(200) = null


if @programfk is null
  begin
	select @programfk = substring((select ','+ltrim(rtrim(str(HVProgramPK)))
									   from HVProgram
									   for xml path ('')),2,8000)
  end
set @programfk = replace(@programfk,'"','')
set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0 else @SiteFK end
set @casefilterspositive = case when @casefilterspositive = '' then null else @casefilterspositive end

DECLARE @tblOutput TABLE(
    [ID] int,
	[Title] [char](200),
	[ColAll] [char](50),
	[ColFSW] [char](50),
	[ColFAW] [char](50),
	[ColAdv] [char](50),
	[ColSupervisor] [char](50),
	[ColManager] [char](50)
)

; WITH 
fsw AS (
SELECT a.WorkerFK, 1 AS [FSW]
, CASE WHEN a.FSWEndDate BETWEEN @StartDt AND @EndDt THEN 1 ELSE 0 END [FSW_T]
FROM WorkerProgram AS a
INNER JOIN dbo.SplitString(@programfk,',') on a.ProgramFK = listitem
WHERE (a.FSWStartDate IS NOT NULL AND a.FSWStartDate <= @EndDt)
AND (a.FSWEndDate IS NULL OR a.FSWEndDate > @StartDt)
AND (a.TerminationDate IS NULL OR a.TerminationDate > @StartDt)
AND (case when @SiteFK = 0 then 1 when a.SiteFK = @SiteFK then 1 else 0 end = 1)
),

faw AS (
SELECT a.WorkerFK, 1 AS [FAW]
, CASE WHEN a.FAWEndDate BETWEEN @StartDt AND @EndDt THEN 1 ELSE 0 END [FAW_T]
FROM WorkerProgram AS a
INNER JOIN dbo.SplitString(@programfk,',') on a.ProgramFK = listitem
WHERE (a.FAWStartDate IS NOT NULL AND a.FAWStartDate <= @EndDt) 
AND (a.FAWEndDate IS NULL OR a.FAWEndDate > @StartDt)
AND (a.TerminationDate IS NULL OR a.TerminationDate > @StartDt)
AND (case when @SiteFK = 0 then 1 when a.SiteFK = @SiteFK then 1 else 0 end = 1)
),

fsw_faw AS (
SELECT isnull(a.WorkerFK, b.WorkerFK) [WorkerFK]
, isnull(a.FSW, 0) [FSW]
, isnull(a.FSW_T, 0) [FSW_T]
, isnull(b.FAW, 0) [FAW]
, isnull(b.FAW_T, 0) [FAW_T]
FROM fsw AS a
FULL JOIN faw AS b ON a.WorkerFK = b.WorkerFK
),


FAdv AS (
SELECT a.WorkerFK, 1 AS [FAdv]
, CASE WHEN a.FatherAdvocateEndDate BETWEEN @StartDt AND @EndDt THEN 1 ELSE 0 END [FAdv_T]
FROM WorkerProgram AS a
INNER JOIN dbo.SplitString(@programfk,',') on a.ProgramFK = listitem
WHERE (a.FatherAdvocateStartDate IS NOT NULL AND a.FatherAdvocateStartDate <= @EndDt) 
AND (a.FatherAdvocateEndDate IS NULL OR a.FatherAdvocateEndDate > @StartDt)
AND (a.TerminationDate IS NULL OR a.TerminationDate > @StartDt)
AND (case when @SiteFK = 0 then 1 when a.SiteFK = @SiteFK then 1 else 0 end = 1)
),

fsw_faw_fadv AS (
SELECT isnull(a.WorkerFK, b.WorkerFK) [WorkerFK]
, isnull(a.FSW, 0) [FSW]
, isnull(a.FSW_T, 0) [FSW_T]
, isnull(a.FAW, 0) [FAW]
, isnull(a.FAW_T, 0) [FAW_T]
, isnull(b.FAdv, 0) [FAdv]
, isnull(b.FAdv_T, 0) [FAdv_T]
FROM fsw_faw AS a
FULL JOIN fadv AS b ON a.WorkerFK = b.WorkerFK
),

Supervisor AS (
SELECT a.WorkerFK, 1 AS [Supervisor]
, CASE WHEN a.SupervisorEndDate BETWEEN @StartDt AND @EndDt THEN 1 ELSE 0 END [Supervisor_T]
FROM WorkerProgram AS a
INNER JOIN dbo.SplitString(@programfk,',') on a.ProgramFK = listitem
WHERE (a.SupervisorStartDate IS NOT NULL AND a.SupervisorStartDate <= @EndDt) 
AND (a.SupervisorEndDate IS NULL OR a.SupervisorEndDate > @StartDt)
AND (a.TerminationDate IS NULL OR a.TerminationDate > @StartDt)
AND (case when @SiteFK = 0 then 1 when a.SiteFK = @SiteFK then 1 else 0 end = 1)
),


fsw_faw_fadv_supervisor AS (
SELECT isnull(a.WorkerFK, b.WorkerFK) [WorkerFK]
, isnull(a.FSW, 0) [FSW]
, isnull(a.FSW_T, 0) [FSW_T]
, isnull(a.FAW, 0) [FAW]
, isnull(a.FAW_T, 0) [FAW_T]
, isnull(a.FAdv, 0) [FAdv]
, isnull(a.FAdv_T, 0) [FAdv_T]
, isnull(b.Supervisor, 0) [Supervisor]
, isnull(b.Supervisor_T, 0) [Supervisor_T]
FROM fsw_faw_fadv AS a
FULL JOIN Supervisor AS b ON a.WorkerFK = b.WorkerFK
),

Manager AS (
SELECT a.WorkerFK, 1 AS [Manager]
, CASE WHEN a.ProgramManagerEndDate BETWEEN @StartDt AND @EndDt THEN 1 ELSE 0 END [Manager_T]
FROM WorkerProgram AS a
INNER JOIN dbo.SplitString(@programfk,',') on a.ProgramFK = listitem
WHERE (a.ProgramManagerStartDate IS NOT NULL AND a.ProgramManagerStartDate <= @EndDt) 
AND (a.ProgramManagerEndDate IS NULL OR a.ProgramManagerEndDate > @StartDt)
AND (a.TerminationDate IS NULL OR a.TerminationDate > @StartDt)
AND (case when @SiteFK = 0 then 1 when a.SiteFK = @SiteFK then 1 else 0 end = 1)
),

fsw_faw_fadv_supervisor_manager AS (
SELECT isnull(a.WorkerFK, b.WorkerFK) [WorkerFK]
, isnull(a.FSW, 0) [FSW]
, isnull(a.FSW_T, 0) [FSW_T]
, isnull(a.FAW, 0) [FAW]
, isnull(a.FAW_T, 0) [FAW_T]
, isnull(a.FAdv, 0) [FAdv]
, isnull(a.FAdv_T, 0) [FAdv_T]
, isnull(a.Supervisor, 0) [Supervisor]
, isnull(a.Supervisor_T, 0) [Supervisor_T]
, isnull(b.Manager, 0) [Manager]
, isnull(b.Manager_T, 0) [Manager_T]
FROM fsw_faw_fadv_supervisor AS a
FULL JOIN Manager AS b ON a.WorkerFK = b.WorkerFK
),

xxx AS (
SELECT a.*
, CASE WHEN wp.TerminationDate Between @StartDt and @EndDt THEN 1 ELSE 0 END [Terminated]
, CASE WHEN wp.LivesTargetArea = 1 THEN 1 ELSE 0 END [LivesTargetArea]
, CASE WHEN WorkerDOB IS NOT NULL THEN datediff(year, WorkerDOB, getdate()) ELSE NULL END [WorkerAge]
, CASE WHEN Gender = '01' THEN 1 ELSE 0 END [Female]
, CASE WHEN OtherLanguage = 1 THEN 1 ELSE 0 END [OtherLanguage]
, CASE WHEN Children IS NULL THEN 0 ELSE Children END [Parent]
, rtrim(FirstName) + ' ' + rtrim(LastName) [name]
, WorkerDOB, Race, Gender
, EducationLevel, LanguageSpecify
, Zip
FROM fsw_faw_fadv_supervisor_manager AS a
JOIN Worker AS w ON a.WorkerFK = w.WorkerPK
JOIN WorkerProgram AS wp ON wp.WorkerFK = a.WorkerFK
INNER JOIN dbo.SplitString(@programfk,',') on wp.ProgramFK = listitem
)

,
all_case AS (

SELECT count(*) [All]
, sum(Terminated) [All_T]
, sum(FSW) [FSW]
, sum(FSW_T) [FSW_T]
, sum(FAW) [FAW]
, sum(FAW_T) [FAW_T]
, sum(FAdv) [FAdv]
, sum(FAdv_T) [FAdv_T]
, sum(Supervisor) [Supervisor]
, sum(Supervisor_T) [Supervisor_T]
, sum(Manager) [Manager]
, sum(Manager_T) [Manager_T]

, avg(workerAge) [ALL_age]
, avg(CASE WHEN fsw = 1 THEN workerAge ELSE NULL END) [FSW_age]
, avg(CASE WHEN faw = 1 THEN workerAge ELSE NULL END) [FAW_age]
, avg(CASE WHEN fadv = 1 THEN workerAge ELSE NULL END) [FAdv_age]
, avg(CASE WHEN supervisor = 1 THEN workerAge ELSE NULL END) [Supervisor_age]
, avg(CASE WHEN manager = 1 THEN workerAge ELSE NULL END) [Manager_age]

, sum(Female) [ALL_Female]
, sum(CASE WHEN fsw = 1 AND Female = 1 THEN 1 ELSE 0 END) [FSW_Female]
, sum(CASE WHEN faw = 1 AND Female = 1 THEN 1 ELSE 0 END) [FAW_Female]
, sum(CASE WHEN fadv = 1 AND Female = 1 THEN 1 ELSE 0 END) [FAdv_Female]
, sum(CASE WHEN supervisor = 1 AND Female = 1 THEN 1 ELSE 0 END) [Supervisor_Female]
, sum(CASE WHEN manager = 1 AND Female = 1 THEN 1 ELSE 0 END) [Manager_Female]

, sum(Parent) [ALL_Parent]
, sum(CASE WHEN fsw = 1 AND Parent = 1 THEN 1 ELSE 0 END) [FSW_Parent]
, sum(CASE WHEN faw = 1 AND Parent = 1 THEN 1 ELSE 0 END) [FAW_Parent]
, sum(CASE WHEN fadv = 1 AND Parent = 1 THEN 1 ELSE 0 END) [FAdv_Parent]
, sum(CASE WHEN supervisor = 1 AND Parent = 1 THEN 1 ELSE 0 END) [Supervisor_Parent]
, sum(CASE WHEN manager = 1 AND Parent = 1 THEN 1 ELSE 0 END) [Manager_Parent]

, sum(LivesTargetArea) [ALL_LivesTargetArea]
, sum(CASE WHEN fsw = 1 AND LivesTargetArea = 1 THEN 1 ELSE 0 END) [FSW_LivesTargetArea]
, sum(CASE WHEN faw = 1 AND LivesTargetArea = 1 THEN 1 ELSE 0 END) [FAW_LivesTargetArea]
, sum(CASE WHEN fadv = 1 AND LivesTargetArea = 1 THEN 1 ELSE 0 END) [FAdv_LivesTargetArea]
, sum(CASE WHEN supervisor = 1 AND LivesTargetArea = 1 THEN 1 ELSE 0 END) [Supervisor_LivesTargetArea]
, sum(CASE WHEN manager = 1 AND LivesTargetArea = 1 THEN 1 ELSE 0 END) [Manager_LivesTargetArea]

, sum(OtherLanguage) [ALL_OtherLanguage]
, sum(CASE WHEN fsw = 1 AND OtherLanguage = 1 THEN 1 ELSE 0 END) [FSW_OtherLanguage]
, sum(CASE WHEN faw = 1 AND OtherLanguage = 1 THEN 1 ELSE 0 END) [FAW_OtherLanguage]
, sum(CASE WHEN fadv = 1 AND OtherLanguage = 1 THEN 1 ELSE 0 END) [FAdv_OtherLanguage]
, sum(CASE WHEN supervisor = 1 AND OtherLanguage = 1 THEN 1 ELSE 0 END) [Supervisor_OtherLanguage]
, sum(CASE WHEN manager = 1 AND OtherLanguage = 1 THEN 1 ELSE 0 END) [Manager_OtherLanguage]
FROM xxx
),

race AS (
SELECT a.AppCode, a.AppCodeText [Race]
, isnull(b.All_n, 0) [All_Race]
, isnull([FSW_n], 0) [FSW_Race]
, isnull([FAW_n], 0) [FAW_Race]
, isnull([FAdv_n], 0) [FAdv_Race]
, isnull([Supervisor_n], 0) [Supervisor_Race]
, isnull([Manager_n], 0) [Manager_Race]

FROM codeApp AS a
LEFT OUTER JOIN (
SELECT Race
, count(*) [All_n]
, sum(CASE WHEN fsw = 1 THEN 1 ELSE 0 END) [FSW_n]
, sum(CASE WHEN faw = 1 THEN 1 ELSE 0 END) [FAW_n]
, sum(CASE WHEN FAdv = 1 THEN 1 ELSE 0 END) [FAdv_n]
, sum(CASE WHEN Supervisor = 1 THEN 1 ELSE 0 END) [Supervisor_n]
, sum(CASE WHEN Manager = 1 THEN 1 ELSE 0 END) [Manager_n]
FROM xxx
GROUP BY Race
) AS b ON b.Race = a.AppCode
WHERE AppCodeGroup = 'Race'
),

race_all AS (
SELECT a.*, b.[All], b.FSW, b.FAW, b.FAdv, b.Supervisor, b.Manager
FROM race AS a 
CROSS JOIN all_case AS b
),

edu AS (
SELECT a.AppCode, a.AppCodeText [Edu]
, isnull(b.All_n, 0) [All_Edu]
, isnull([FSW_n], 0) [FSW_Edu]
, isnull([FAW_n], 0) [FAW_Edu]
, isnull([FAdv_n], 0) [FAdv_Edu]
, isnull([Supervisor_n], 0) [Supervisor_Edu]
, isnull([Manager_n], 0) [Manager_Edu]
FROM codeApp AS a
LEFT OUTER JOIN (
SELECT EducationLevel
, count(*) [All_n]
, sum(CASE WHEN fsw = 1 THEN 1 ELSE 0 END) [FSW_n]
, sum(CASE WHEN faw = 1 THEN 1 ELSE 0 END) [FAW_n]
, sum(CASE WHEN FAdv = 1 THEN 1 ELSE 0 END) [FAdv_n]
, sum(CASE WHEN Supervisor = 1 THEN 1 ELSE 0 END) [Supervisor_n]
, sum(CASE WHEN Manager = 1 THEN 1 ELSE 0 END) [Manager_n]
FROM xxx
GROUP BY EducationLevel
) AS b ON b.EducationLevel = a.AppCode
WHERE AppCodeGroup = 'WorkerEducationLevel'
),

edu_all AS (
SELECT a.*, b.[All], b.FSW, b.FAW, b.FAdv, b.Supervisor, b.Manager
FROM edu AS a 
CROSS JOIN all_case AS b
)

INSERT INTO @tblOutput([ID], [Title],[ColAll],[ColFSW],[ColFAW],[ColAdv],[ColSupervisor],[ColManager])

(SELECT 1, '1. Period Workers'
, cast([All] as varchar(50))
, cast(FSW as varchar(50))
, cast(FAW as varchar(50))
, cast(FAdv as varchar(50))
, cast(Supervisor as varchar(50))
, cast(Manager as varchar(50))
FROM all_case)

union 
(SELECT 2, '    Period Terminated'
, cast([All_T] as varchar(50))
, cast(FSW_T as varchar(50))
, cast(FAW_T as varchar(50))
, cast(FAdv_T as varchar(50))
, cast(Supervisor_T as varchar(50))
, cast(Manager_T as varchar(50))
FROM all_case)

union 
(SELECT 3, '    Employed at End'
, cast(([All] - [All_T]) as varchar(50))
, cast((FSW - FSW_T) as varchar(50))
, cast((FAW - FAW_T) as varchar(50))
, cast((FAdv - FAdv_T) as varchar(50))
, cast((Supervisor - Supervisor_T) as varchar(50))
, cast((Manager - Manager_T) as varchar(50))
FROM all_case)

union 
(SELECT 4, '2. Average Age'
, cast(All_age as varchar(50))
, cast(FSW_age as varchar(50))
, cast(FAW_age as varchar(50))
, cast(FAdv_age as varchar(50))
, cast(Supervisor_age as varchar(50))
, cast(Manager_age as varchar(50))
FROM all_case)

union 
(SELECT 5, '3. Female'
, cast(cast(Round(100.0 * All_Female / NULLIF([All], 0), 0) as int) as varchar(50)) + '%'
, cast(cast(Round(100.0 * FSW_Female / NULLIF(FSW, 0), 0) as int) as varchar(50)) + '%'
, cast(cast(Round(100.0 * FAW_Female / NULLIF(FAW, 0), 0) as int) as varchar(50)) + '%'
, cast(cast(Round(100.0 * FAdv_Female / NULLIF(FAdv, 0), 0) as int) as varchar(50)) + '%'
, cast(cast(Round(100.0 * Supervisor_Female / NULLIF(Supervisor, 0), 0) as int) as varchar(50)) + '%'
, cast(cast(Round(100.0 * Manager_Female / NULLIF(Manager, 0), 0) as int) as varchar(50)) + '%'
FROM all_case)

union
(SELECT 6, '4. Race', '', '', '', '', '', '')

union
(SELECT 
ROW_NUMBER() OVER(ORDER BY AppCode) + 6 AS Row
, '    ' + Race
, cast(cast(Round(100.0 * All_Race / NULLIF([All], 0), 0) as int) as varchar(50)) + '%'
, cast(cast(Round(100.0 * FSW_Race / NULLIF(FSW, 0), 0) as int) as varchar(50)) + '%'
, cast(cast(Round(100.0 * FAW_Race / NULLIF(FAW, 0), 0) as int) as varchar(50)) + '%'
, cast(cast(Round(100.0 * FAdv_Race / NULLIF(FAdv, 0), 0) as int) as varchar(50)) + '%'
, cast(cast(Round(100.0 * Supervisor_Race / NULLIF(Supervisor, 0), 0) as int) as varchar(50)) + '%'
, cast(cast(Round(100.0 * Manager_Race / NULLIF(Manager, 0), 0) as int) as varchar(50)) + '%'
FROM race_all
)

union
(SELECT 14, '5. Education', '', '', '', '', '', '')

union
(SELECT 
ROW_NUMBER() OVER(ORDER BY AppCode) + 14 AS Row
, '    ' + Edu
, cast(cast(Round(100.0 * All_Edu / NULLIF([All], 0), 0) as int) as varchar(50)) + '%'
, cast(cast(Round(100.0 * FSW_Edu / NULLIF(FSW, 0), 0) as int) as varchar(50)) + '%'
, cast(cast(Round(100.0 * FAW_Edu / NULLIF(FAW, 0), 0) as int) as varchar(50)) + '%'
, cast(cast(Round(100.0 * FAdv_Edu / NULLIF(FAdv, 0), 0) as int) as varchar(50)) + '%'
, cast(cast(Round(100.0 * Supervisor_Edu / NULLIF(Supervisor, 0), 0) as int) as varchar(50)) + '%'
, cast(cast(Round(100.0 * Manager_Edu / NULLIF(Manager, 0), 0) as int) as varchar(50)) + '%'
FROM edu_all
)

union 
(SELECT 23, '6. Parent'
, cast(cast(Round(100.0 * All_Parent / NULLIF([All], 0), 0) as int) as varchar(50)) + '%'
, cast(cast(Round(100.0 * FSW_Parent / NULLIF(FSW, 0), 0) as int) as varchar(50)) + '%'
, cast(cast(Round(100.0 * FAW_Parent / NULLIF(FAW, 0), 0) as int) as varchar(50)) + '%'
, cast(cast(Round(100.0 * FAdv_Parent / NULLIF(FAdv, 0), 0) as int) as varchar(50)) + '%'
, cast(cast(Round(100.0 * Supervisor_Parent / NULLIF(Supervisor, 0), 0) as int) as varchar(50)) + '%'
, cast(cast(Round(100.0 * Manager_Parent / NULLIF(Manager, 0), 0) as int) as varchar(50)) + '%'
FROM all_case)

union 
(SELECT 24, '7. Language Other than English'
, cast(cast(Round(100.0 * All_OtherLanguage / NULLIF([All], 0), 0) as int) as varchar(50)) + '%'
, cast(cast(Round(100.0 * FSW_OtherLanguage / NULLIF(FSW, 0), 0) as int) as varchar(50)) + '%'
, cast(cast(Round(100.0 * FAW_OtherLanguage / NULLIF(FAW, 0), 0) as int) as varchar(50)) + '%'
, cast(cast(Round(100.0 * FAdv_OtherLanguage / NULLIF(FAdv, 0), 0) as int) as varchar(50)) + '%'
, cast(cast(Round(100.0 * Supervisor_OtherLanguage / NULLIF(Supervisor, 0), 0) as int) as varchar(50)) + '%'
, cast(cast(Round(100.0 * Manager_OtherLanguage / NULLIF(Manager, 0), 0) as int) as varchar(50)) + '%'
FROM all_case)

union 
(SELECT 25, '8. Living in Target Area'
, cast(cast(Round(100.0 * All_LivesTargetArea / NULLIF([All], 0), 0) as int) as varchar(50)) + '%'
, cast(cast(Round(100.0 * FSW_LivesTargetArea / NULLIF(FSW, 0), 0) as int) as varchar(50)) + '%'
, cast(cast(Round(100.0 * FAW_LivesTargetArea / NULLIF(FAW, 0), 0) as int) as varchar(50)) + '%'
, cast(cast(Round(100.0 * FAdv_LivesTargetArea / NULLIF(FAdv, 0), 0) as int) as varchar(50)) + '%'
, cast(cast(Round(100.0 * Supervisor_LivesTargetArea / NULLIF(Supervisor, 0), 0) as int) as varchar(50)) + '%'
, cast(cast(Round(100.0 * Manager_LivesTargetArea / NULLIF(Manager, 0), 0) as int) as varchar(50)) + '%'
FROM all_case)

-- display temp table
SELECT * 
FROM @tblOutput
order by id





GO
