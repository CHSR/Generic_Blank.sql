SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[rspDaysBetweenHomeVisits](@programfk AS INT)
AS
BEGIN
	--currently served clients cohort
	WITH cteMAIN AS (
		SELECT
			CurrentLevelFK
			,codelevel.LevelName
			,PC1ID
			,HVCaseFK
		FROM
			dbo.CaseProgram
			INNER JOIN dbo.HVCase ON dbo.CaseProgram.HVCaseFK = dbo.HVCase.HVCasePK
			INNER JOIN dbo.codeLevel ON caseprogram.CurrentLevelFK = codeLevelPK
		WHERE
			caseprogram.programfk = @programfk
			AND caseprogress >= 9
			AND CaseStartDate <= GetDate()
			AND DischargeDate IS NULL
	)

	--get the most recent HV Visit from cohort above
	,cteLastVisit AS (
		SELECT DISTINCT
			cteMAIN.HVCaseFK
			,MAX(VisitStartTime) OVER (PARTITION BY cteMAIN.HVCaseFK) AS HVDATE2
		FROM
			dbo.HVLog
			INNER JOIN cteMAIN ON dbo.HVLog.HVCaseFK = cteMAIN.HVCaseFK
		WHERE
			LEFT(visittype, 1) = '1'
	)

	--now get the most recent HVLOGPK from the list above
	,cteLastVisitPlusHVLOGPK AS (
		SELECT DISTINCT
			cteLastVisit.hvcasefk
			,ROW_NUMBER() OVER (PARTITION BY cteLastVisit.hvcasefk ORDER BY hvlog.HVLogCreateDate DESC) AS RowNum
			,HVDATE2
			,hvlogpk
		FROM
			dbo.HVLog
			INNER JOIN cteLastVisit ON dbo.HVLog.HVCaseFK = cteLastVisit.HVCaseFK AND hvlog.VisitStartTime = cteLastVisit.HVDATE2
		WHERE
			LEFT(visittype, 1) = '1'
	)

	,cteSecondToLastVisit AS (
		SELECT
			MAX(VisitStartTime) AS HVDATE1
			,HVLog.HVCaseFK
		FROM
			dbo.HVLog
			INNER JOIN cteLastVisitPlusHVLOGPK CLV ON CLV.hvlogpk <> hvlog.hvlogpk AND CLV.HVCaseFK = hvlog.HVCaseFK
		WHERE
			LEFT(visittype, 1) = '1'
		GROUP BY
			HVLog.HVCaseFK
	)

	,cteDatesBetween AS (
		SELECT
			cteSecondToLastVisit.HVCaseFK
			,cteMAIN.pc1id
			,cteMain.LevelName
			,hvdate1
			,HVDATE2
			,DATEDIFF(dd, hvdate1,  hvdate2) AS DaysBetweenHomeVisits
		FROM
			cteSecondToLastVisit
			INNER JOIN cteLastVisitPlusHVLOGPK CLV ON CLV.HVCaseFK = cteSecondToLastVisit.HVCaseFK
			INNER JOIN cteMAIN ON cteMAIN.HVCaseFK = cteSecondToLastVisit.hvcasefk
		WHERE
			clv.RowNum = 1
	)

	,cteAverageDays AS (
		SELECT
			SUM(DaysBetweenHomeVisits) / COUNT(DaysBetweenHomeVisits) AS AverageDays
		FROM
			cteDatesBetween
	)

	,ctePutTheTwoTogether AS (
		SELECT
			PC1ID AS 'Case #'
			,LevelName AS 'Level'
			,CONVERT(DATE, HVDATE2, 101) AS 'Most Recent Home Visit'
			,CONVERT(DATE, HVDATE1, 101) AS 'Previous Home Visit'
			,DaysBetweenHomeVisits AS 'Days Between Visits'
			,AverageDays AS 'Avg Days Calculated'
		FROM
			cteDatesBetween
			,cteAverageDays
	)

	,cteLevelCodes AS (
		SELECT
			codeLevelPK
			,LevelName
			,MinimumVisit
			,CASE
				WHEN MinimumVisit = 0 THEN NULL
				ELSE (1 / MinimumVisit) * 7
			END AS 'MinDays'
		FROM
			dbo.codeLevel
		WHERE
			codeLevelPK >= 9
			AND MinimumVisit IS NOT NULL
	)

	SELECT
		[Case #]
		,SUBSTRING([Level], 7, LEN([Level]) - 5) AS 'Level' --remove word "Level" from value
		,[Most Recent Home Visit]
		,[Previous Home Visit]
		,[Days Between Visits]
		,[MinDays]
		,[Days Between Visits] - [MinDays] AS 'Difference'
		,[Avg Days Calculated]
		,RTrim(FirstName) + ' ' + RTrim(LastName) AS 'Worker Name'
	FROM
		ctePutTheTwoTogether
		INNER JOIN CaseProgram ON ctePutTheTwoTogether.[Case #] = CaseProgram.PC1ID
		INNER JOIN worker ON workerpk = CaseProgram.CurrentFSWFK
		INNER JOIN hvcase ON hvcase.hvcasepk = caseprogram.hvcasefk
		INNER JOIN cteLevelCodes ON ctePutTheTwoTogether.Level = cteLevelCodes.LevelName
	ORDER BY
		cteLevelCodes.codeLevelPK
		,Difference DESC
END
GO
