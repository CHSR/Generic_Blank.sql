SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Dar Chen
-- Create date: 04/24/2013
-- Description:	Worker Characteristics Summary
-- Edit date: 10/11/2013 CP - workerprogram was NOT duplicating cases when worker transferred
-- =============================================
CREATE procedure [dbo].[rspWorkerCharacteristicsSummaryDetail]
    @programfk VARCHAR(MAX) = null,
    @StartDt   datetime,
    @EndDt     datetime,
    @SiteFK	   int = null,
    @casefilterspositive varchar(200)
as

--DECLARE @StartDt AS DATE = '01/01/2012'
--DECLARE @EndDt AS DATE = '03/31/2012'
--DECLARE @ProgramFK AS VARCHAR(MAX) = '1'
--DECLARE @SiteFK	   int = null
--DECLARE @casefilterspositive varchar(200) = ''

if @programfk is null
  begin
	select @programfk = substring((select ','+ltrim(rtrim(str(HVProgramPK)))
									   from HVProgram
									   for xml path ('')),2,8000)
  end
set @programfk = replace(@programfk,'"','')
set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0 else @SiteFK end
set @casefilterspositive = case when @casefilterspositive = '' then null else @casefilterspositive end

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
SELECT a.WorkerFK,
rtrim(FirstName) + ' ' + rtrim(LastName) [Name]
, CASE WHEN a.FSW = 1 THEN 'FSW ' ELSE '' END +
CASE WHEN a.FAW = 1 THEN 'FAW ' ELSE '' END +
CASE WHEN a.FAdv = 1 THEN 'FADV ' ELSE '' END +
CASE WHEN a.Supervisor = 1 THEN 'SUP ' ELSE '' END +
CASE WHEN a.Manager = 1 THEN 'PM' ELSE '' END [Func]
, convert(VARCHAR(12),wp.HireDate, 101) [HireDate]
, convert(VARCHAR(12),wp.TerminationDate, 101) [TerminationDate]
, b.AppCodeText [Education]
, LanguageSpecify
, CASE WHEN Children = 1 THEN 'Yes' ELSE 'No' END [Parents]
, CASE WHEN wp.LivesTargetArea = 1 THEN 'Yes' ELSE 'No' END [LivingInTargetArea]
, LastName
FROM fsw_faw_fadv_supervisor_manager AS a
JOIN Worker AS w ON a.WorkerFK = w.WorkerPK
JOIN WorkerProgram AS wp ON wp.WorkerFK = a.WorkerFK 
INNER JOIN dbo.SplitString(@programfk,',') on wp.ProgramFK = listitem
LEFT OUTER JOIN codeApp AS b ON EducationLevel = b.AppCode AND b.AppCodeGroup = 'WorkerEducationLevel'
)

SELECT DISTINCT * FROM xxx ORDER BY LastName
GO
