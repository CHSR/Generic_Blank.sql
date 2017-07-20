SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Dar Chen
-- Create date: 04/30/2013
-- Description:	Unique Family Home Visit Log Activity Summary Curriculum
-- =============================================
CREATE PROCEDURE [dbo].[rspUniqueFamilyHomeVisitLogActivitySummaryCurriculum] 
	-- Add the parameters for the stored procedure here
	(@programfk INT = NULL, 
	@StartDt datetime,
	@EndDt DATETIME,
	@workerfk INT = NULL,
	@pc1id VARCHAR(13) = '',
	@showWorkerDetail CHAR(1) = 'N',
	@showPC1IDDetail CHAR(1) = 'N'
   , @SiteFK int = null
   , @CaseFiltersPositive varchar(200) = null)

AS

--DECLARE	@programfk INT = 1
--DECLARE @StartDt DATETIME = '01/01/2013'
--DECLARE @EndDt DATETIME = '09/30/2013'
--DECLARE @workerfk INT = NULL
--DECLARE @pc1id VARCHAR(13) = ''
--DECLARE @showWorkerDetail CHAR(1) = 'N'
--DECLARE @showPC1IDDetail CHAR(1) = 'N'

	set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0
						else @SiteFK
					end
	set @CaseFiltersPositive = case	when @CaseFiltersPositive = '' then null
									else @CaseFiltersPositive
							   end;
; WITH curriculumFamily01 AS (

SELECT 
CASE WHEN @showWorkerDetail = 'N' THEN 0 ELSE a.FSWFK END FSWFK
,CASE WHEN @showPC1IDDetail = 'N' THEN '' ELSE cp.PC1ID END PC1ID
,a.HVCaseFK
--,count(*) [n]
, CASE WHEN (sum(Case WHEN (CurriculumPartnersHealthyBaby IS NULL 
    OR CurriculumPartnersHealthyBaby = 0) THEN 0 ELSE 1 END)) > 0 THEN 1 ELSE 0 END
    CurriculumPartnersHealthyBaby
        
, CASE WHEN (sum(Case WHEN (CurriculumPAT IS NULL 
    OR CurriculumPAT = 0) THEN 0 ELSE 1 END)) > 0 THEN 1 ELSE 0 END
    CurriculumPAT

, CASE WHEN (sum(Case WHEN (CurriculumSanAngelo IS NULL 
    OR CurriculumSanAngelo = 0) THEN 0 ELSE 1 END)) > 0 THEN 1 ELSE 0 END
    CurriculumSanAngelo

, CASE WHEN (sum(Case WHEN (CurriculumParentsForLearning IS NULL 
    OR CurriculumParentsForLearning = 0) THEN 0 ELSE 1 END)) > 0 THEN 1 ELSE 0 END
    CurriculumParentsForLearning

, CASE WHEN (sum(Case WHEN (CurriculumHelpingBabiesLearn IS NULL 
    OR CurriculumHelpingBabiesLearn = 0) THEN 0 ELSE 1 END)) > 0 THEN 1 ELSE 0 END
    CurriculumHelpingBabiesLearn
       
, CASE WHEN (sum(Case WHEN (CurriculumGrowingGreatKids IS NULL 
    OR CurriculumGrowingGreatKids = 0) THEN 0 ELSE 1 END)) > 0 THEN 1 ELSE 0 END
    CurriculumGrowingGreatKids
    
, CASE WHEN (sum(Case WHEN (Curriculum247Dads IS NULL 
    OR Curriculum247Dads = 0) THEN 0 ELSE 1 END)) > 0 THEN 1 ELSE 0 END
    Curriculum247Dads

, CASE WHEN (sum(Case WHEN (CurriculumBoyz2Dads IS NULL 
    OR CurriculumBoyz2Dads = 0) THEN 0 ELSE 1 END)) > 0 THEN 1 ELSE 0 END
    CurriculumBoyz2Dads

, CASE WHEN (sum(Case WHEN (CurriculumInsideOutDads IS NULL 
    OR CurriculumInsideOutDads = 0) THEN 0 ELSE 1 END)) > 0 THEN 1 ELSE 0 END
    CurriculumInsideOutDads

, CASE WHEN (sum(Case WHEN (CurriculumMomGateway IS NULL 
    OR CurriculumMomGateway = 0) THEN 0 ELSE 1 END)) > 0 THEN 1 ELSE 0 END
    CurriculumMomGateway

, CASE WHEN (sum(Case WHEN (CurriculumPATFocusFathers IS NULL 
    OR CurriculumPATFocusFathers = 0) THEN 0 ELSE 1 END)) > 0 THEN 1 ELSE 0 END
    CurriculumPATFocusFathers

, CASE WHEN (sum(Case WHEN (CurriculumOther IS NULL 
    OR CurriculumOther = 0) THEN 0 ELSE 1 END)) > 0 THEN 1 ELSE 0 END
    CurriculumOther

    
FROM HVLog AS a
INNER JOIN worker fsw
ON a.FSWFK = fsw.workerpk
INNER JOIN CaseProgram cp
ON cp.HVCaseFK = a.HVCaseFK
inner join dbo.udfCaseFilters(@CaseFiltersPositive, '', @ProgramFK) cf on cf.HVCaseFK = cp.HVCaseFK
WHERE 
a.ProgramFK = @programfk 
AND cast(VisitStartTime AS date) between @StartDt AND @EndDt
AND substring(a.VisitType,4,1) <> '1'
AND a.FSWFK = ISNULL(@workerfk, a.FSWFK)
AND cp.PC1ID = CASE WHEN @pc1ID = '' THEN cp.PC1ID ELSE @pc1ID END
GROUP BY 
CASE WHEN @showWorkerDetail = 'N' THEN 0 ELSE a.FSWFK END, 
CASE WHEN @showPC1IDDetail = 'N' THEN '' ELSE cp.PC1ID END
, a.HVCaseFK
)

, uniqueFamily AS (
SELECT FSWFK, PC1ID, count(*) [UniqueFamilies]
, sum(a.CurriculumPartnersHealthyBaby) AS CurriculumPartnersHealthyBaby
, sum(a.CurriculumPAT) AS CurriculumPAT
, sum(a.CurriculumSanAngelo) AS CurriculumSanAngelo
, sum(a.CurriculumParentsForLearning) AS CurriculumParentsForLearning
, sum(a.CurriculumHelpingBabiesLearn) AS CurriculumHelpingBabiesLearn
, sum(a.CurriculumGrowingGreatKids) AS CurriculumGrowingGreatKids
, sum(a.Curriculum247Dads) AS Curriculum247Dads 
, sum(a.CurriculumBoyz2Dads) AS CurriculumBoyz2Dads 
, sum(a.CurriculumInsideOutDads) AS CurriculumInsideOutDads
, sum(a.CurriculumMomGateway) AS CurriculumMomGateway
, sum(a.CurriculumPATFocusFathers) AS CurriculumPATFocusFathers 
, sum(a.CurriculumOther) AS CurriculumOther

, sum(CASE WHEN (a.CurriculumPartnersHealthyBaby = 0
AND a.CurriculumPAT = 0
AND a.CurriculumSanAngelo = 0
AND a.CurriculumParentsForLearning = 0
AND a.CurriculumHelpingBabiesLearn = 0
AND a.CurriculumGrowingGreatKids = 0
AND a.Curriculum247Dads = 0
AND a.CurriculumBoyz2Dads = 0
AND a.CurriculumInsideOutDads = 0
AND a.CurriculumMomGateway = 0
AND a.CurriculumPATFocusFathers = 0
AND a.CurriculumOther = 0) THEN 1 ELSE 0 END) AS CurriculumNone

FROM curriculumFamily01 AS a
GROUP BY FSWFK, PC1ID
)

SELECT a.*, CASE WHEN c.WorkerPK IS NULL THEN 'All Workers' ELSE 
rtrim(c.LastName) + ', ' + rtrim(c.FirstName) END WorkerName
FROM uniqueFamily AS a 
LEFT OUTER JOIN Worker AS c ON 
CASE WHEN (@showWorkerDetail = 'N' AND @workerfk IS NOT NULL) THEN @workerfk 
ELSE a.FSWFK END = c.WorkerPK
left outer join WorkerProgram wp on wp.WorkerFK = c.WorkerPK
where case when @SiteFK = 0 then 1
			 when wp.SiteFK = @SiteFK then 1
			 else 0
		end = 1

ORDER BY WorkerName, a.PC1ID
GO
