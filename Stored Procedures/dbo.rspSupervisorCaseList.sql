SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:		<Dorothy Baum>
-- Create date: <June 14, 2010>
-- Description:	<report: Supervisor Case List>
-- Edit date: 10/11/2013 CP - workerprogram was duplicating cases when worker transferred

-- rspSupervisorCaseList 1
-- rspSupervisorCaseList 6
-- 02/07/2014 added program capacity ... khalsa
-- =============================================
CREATE procedure [dbo].[rspSupervisorCaseList]
(
    @ProgramFK varchar(max) = null,
    @SupPK     int = null
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here
	IF @ProgramFK IS NULL
	BEGIN
		SELECT @ProgramFK = SUBSTRING((
			SELECT ',' + LTRIM(RTRIM(STR(HVProgramPK)))
			FROM HVProgram
			FOR XML PATH ('')
		),2,8000)
	END

	SET @ProgramFK = REPLACE(@ProgramFK, '"', '');

	WITH
	ctemain AS (
		SELECT
			pc1id
			,LevelAbbr
			,codeLevelPK
			,caseweight
			,CASE WHEN Enrolled = 0 AND CaseWeight > 0 THEN 1 ELSE 0 END AS PreIntakeCount -- captures all pre-intake levels with caseweights
			,supfname
			,suplname
			,worker.firstname AS wfname
			,worker.lastname AS wlname
			,CaseProgram.ProgramFK
			,ProgramCapacity
		FROM
			(
				SELECT
					*
				FROM
					codeLevel
				WHERE
					caseweight IS NOT NULL
			) cl
			LEFT OUTER JOIN caseprogram ON caseprogram.currentLevelFK = cl.codeLevelPK
			INNER JOIN dbo.SplitString(@programfk, ',') ON caseprogram.programfk = listitem
			INNER JOIN worker ON caseprogram.currentFSWFK = worker.workerpk
			INNER JOIN workerprogram wp on wp.workerfk = worker.workerpk AND wp.programfk = listitem
			LEFT OUTER JOIN (
				SELECT
					workerpk
					,firstName AS supfname
					,LastName AS suplname
				FROM
					worker
			) sw ON wp.supervisorfk = sw.workerpk
			LEFT OUTER JOIN HVProgram h ON h.HVProgramPK = CaseProgram.ProgramFK			   						   
		WHERE
			dischargedate IS NULL
			AND sw.workerpk = ISNULL(@SupPK, sw.workerpk)
	)
 
	,ctemainAgain AS (
		SELECT
			pc1id
			,LevelAbbr
			,codeLevelPK
			,caseweight
			,CASE WHEN Enrolled = 0 AND CaseWeight > 0 THEN 1 ELSE 0 END AS PreIntakeCount -- captures all pre-intake levels with caseweights
			,supfname
			,suplname
			,worker.firstname AS wfname
			,worker.lastname AS wlname
			,CaseProgram.ProgramFK
			,ProgramCapacity
		FROM (
				SELECT
					*
				FROM
					codeLevel
				WHERE
					caseweight IS NOT NULL
			) cl
			LEFT OUTER JOIN caseprogram ON caseprogram.currentLevelFK = cl.codeLevelPK
			INNER JOIN dbo.SplitString(@programfk, ',') ON caseprogram.programfk = listitem
			INNER JOIN worker ON caseprogram.currentFSWFK = worker.workerpk
			INNER JOIN workerprogram wp ON wp.workerfk = worker.workerpk
				AND wp.programfk = listitem
			LEFT OUTER JOIN (
				SELECT
					workerpk
					,firstName AS supfname
					,LastName AS suplname
				FROM
					worker
			) sw ON wp.supervisorfk = sw.workerpk
			LEFT OUTER JOIN HVProgram h ON h.HVProgramPK = CaseProgram.ProgramFK	   			   
		WHERE
			dischargedate IS NULL
			AND sw.workerpk = ISNULL(@SupPK, sw.workerpk)
	)

	,cteProgramCapacity AS (
		SELECT
			CASE WHEN ProgramCapacity IS NULL THEN
				'Program capacity blank on Program Information Form.' 
			ELSE
				CONVERT(VARCHAR,
					COUNT(PC1ID) - SUM(PreIntakeCount)
				)
				+ ' (' 
				+ CONVERT(VARCHAR, 
					ROUND(
						COALESCE(
							CAST((
								COUNT(PC1ID) - SUM(PreIntakeCount)
							) AS FLOAT)
							* 100 / NULLIF(ProgramCapacity, 0), 0
						), 0
					)
				)
				+ '%)'
			END AS PerctOfProgramCapacity
		FROM
			ctemainAgain
		group by
			ProgramFK
			,ProgramCapacity
	)
	
	SELECT
		PC1ID
		,LevelAbbr
		,codeLevelPK
		,CaseWeight
		,supfname
		,suplname
		,wfname
		,wlname
		,PerctOfProgramCapacity AS ProgramCapacity
		,CASE WHEN ProgramCapacity IS NULL THEN
			''
		ELSE
			CONVERT(VARCHAR, ProgramCapacity)
		END AS ContractedCapacity
	FROM
		ctemain,
		cteProgramCapacity		
	ORDER BY
		suplname
		,supfname
		,wlname
		,wfname
END
GO
