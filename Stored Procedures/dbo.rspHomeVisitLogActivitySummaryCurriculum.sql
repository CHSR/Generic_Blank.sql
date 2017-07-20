SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Dar Chen
-- Create date: 05/22/2010
-- Description:	Home Visit Log Activity Summary Curriculum
-- [rspHomeVisitLogActivitySummaryCurriculum] 1,'10/01/2013','04/30/2014',null,'','N','N'
-- [rspHomeVisitLogActivitySummaryCurriculum] 1,'10/01/2013','04/30/2014',null,'','N','N'
-- =============================================
CREATE PROCEDURE [dbo].[rspHomeVisitLogActivitySummaryCurriculum] 
	-- Add the parameters for the stored procedure here
	(@programfk INT = NULL, 
	@StartDt datetime,
	@EndDt DATETIME,
	@workerfk INT = NULL,
	@pc1id VARCHAR(13) = '',
	@showWorkerDetail CHAR(1) = 'N',
	@showPC1IDDetail CHAR(1) = 'N'
   , @SiteFK int = null
   , @CaseFiltersPositive varchar(200) = null
	)

--DECLARE	@programfk INT = 6
--DECLARE @StartDt DATETIME = '01/01/2011'
--DECLARE @EndDt DATETIME = '01/01/2012'
--DECLARE @workerfk INT = NULL
--DECLARE @pc1id VARCHAR(13) = NULL
--DECLARE @showWorkerDetail CHAR(1) = 'Y'
--DECLARE @showPC1IDDetail CHAR(1) = 'N'
AS

--DECLARE	@programfk INT = 1
--DECLARE @StartDt DATETIME = '04/01/2012'
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

 WITH curriculum01 AS (
SELECT 
CASE WHEN @showWorkerDetail = 'N' THEN 0 ELSE a.FSWFK END FSWFK
,CASE WHEN @showPC1IDDetail = 'N' THEN '' ELSE cp.PC1ID END PC1ID

,count(*) [CompletedVisit]

, sum(Case WHEN (CurriculumPartnersHealthyBaby IS NULL 
    OR CurriculumPartnersHealthyBaby = 0) THEN 0 ELSE 1 END)
    CurriculumPartnersHealthyBaby
        
, sum(Case WHEN (CurriculumPAT IS NULL 
    OR CurriculumPAT = 0) THEN 0 ELSE 1 END)
    CurriculumPAT

, sum(Case WHEN (CurriculumSanAngelo IS NULL 
    OR CurriculumSanAngelo = 0) THEN 0 ELSE 1 END)
    CurriculumSanAngelo

, sum(Case WHEN (CurriculumParentsForLearning IS NULL 
    OR CurriculumParentsForLearning = 0) THEN 0 ELSE 1 END)
    CurriculumParentsForLearning

, sum(Case WHEN (CurriculumHelpingBabiesLearn IS NULL 
    OR CurriculumHelpingBabiesLearn = 0) THEN 0 ELSE 1 END)
    CurriculumHelpingBabiesLearn
       
, sum(Case WHEN (CurriculumGrowingGreatKids IS NULL 
    OR CurriculumGrowingGreatKids = 0) THEN 0 ELSE 1 END)
    CurriculumGrowingGreatKids
    
, sum(Case WHEN (Curriculum247Dads IS NULL 
    OR Curriculum247Dads = 0) THEN 0 ELSE 1 END)
    Curriculum247Dads

, sum(Case WHEN (CurriculumBoyz2Dads IS NULL 
    OR CurriculumBoyz2Dads = 0) THEN 0 ELSE 1 END)
    CurriculumBoyz2Dads

, sum(Case WHEN (CurriculumInsideOutDads IS NULL 
    OR CurriculumInsideOutDads = 0) THEN 0 ELSE 1 END)
    CurriculumInsideOutDads

, sum(Case WHEN (CurriculumMomGateway IS NULL 
    OR CurriculumMomGateway = 0) THEN 0 ELSE 1 END)
    CurriculumMomGateway

, sum(Case WHEN (CurriculumPATFocusFathers IS NULL 
    OR CurriculumPATFocusFathers = 0) THEN 0 ELSE 1 END)
    CurriculumPATFocusFathers

, sum(Case WHEN (CurriculumOther IS NULL 
    OR CurriculumOther = 0) THEN 0 ELSE 1 END)
    CurriculumOther

, sum(Case WHEN ((CurriculumPartnersHealthyBaby IS NULL OR CurriculumPartnersHealthyBaby = 0) AND 
    (CurriculumPAT IS NULL OR CurriculumPAT = 0) AND
    (CurriculumSanAngelo IS NULL OR CurriculumSanAngelo = 0) AND
    (CurriculumParentsForLearning IS NULL OR CurriculumParentsForLearning = 0) AND
    (CurriculumHelpingBabiesLearn IS NULL OR CurriculumHelpingBabiesLearn = 0) AND
    (CurriculumGrowingGreatKids IS NULL OR CurriculumGrowingGreatKids = 0) AND
    (Curriculum247Dads IS NULL OR Curriculum247Dads = 0) AND 
    (CurriculumBoyz2Dads IS NULL OR CurriculumBoyz2Dads = 0) AND 
    (CurriculumInsideOutDads IS NULL OR CurriculumInsideOutDads = 0) AND
    (CurriculumMomGateway IS NULL OR CurriculumMomGateway = 0) AND
    (CurriculumPATFocusFathers IS NULL OR CurriculumPATFocusFathers = 0) AND 
    (CurriculumOther IS NULL OR CurriculumOther = 0)
    ) THEN 1 ELSE 0 END) CurriculumNone
    
FROM HVLog AS a
INNER JOIN worker fsw
ON a.FSWFK = fsw.workerpk
INNER JOIN CaseProgram cp
ON cp.HVCaseFK = a.HVCaseFK
INNER JOIN HVCase AS h
ON h.HVCasePK = a.HVCaseFK
inner join WorkerProgram wp on wp.WorkerFK = fsw.WorkerPK and wp.ProgramFK = cp.ProgramFK
inner join dbo.udfCaseFilters(@CaseFiltersPositive, '', @ProgramFK) cf on cf.HVCaseFK = cp.HVCaseFK
WHERE 
a.ProgramFK = @programfk 
AND cast(VisitStartTime AS date) between @StartDt AND @EndDt 
AND a.FSWFK = ISNULL(@workerfk, a.FSWFK)
AND cp.PC1ID = CASE WHEN @pc1ID = '' THEN cp.PC1ID ELSE @pc1ID END
AND substring(VisitType,4,1) <> '1'
and case when @SiteFK = 0 then 1
		 when wp.SiteFK = @SiteFK then 1
		 else 0
	end = 1
GROUP BY 
CASE WHEN @showWorkerDetail = 'N' THEN 0 ELSE a.FSWFK END, 
CASE WHEN @showPC1IDDetail = 'N' THEN '' ELSE cp.PC1ID END
)

SELECT 
a.FSWFK, a.PC1ID
,CASE WHEN c.WorkerPK IS NULL THEN 'All Workers' ELSE 
rtrim(c.LastName) + ', ' + rtrim(c.FirstName) END WorkerName
, CompletedVisit
, 100 * CurriculumPartnersHealthyBaby / CompletedVisit AS CurriculumPartnersHealthyBaby  
, 100 * CurriculumPAT / CompletedVisit AS CurriculumPAT 
, 100 * CurriculumSanAngelo / CompletedVisit AS CurriculumSanAngelo 
, 100 * CurriculumParentsForLearning / CompletedVisit AS CurriculumParentsForLearning 
, 100 * CurriculumHelpingBabiesLearn / CompletedVisit AS CurriculumHelpingBabiesLearn 
, 100 * CurriculumGrowingGreatKids / CompletedVisit AS CurriculumGrowingGreatKids 
, 100 * Curriculum247Dads / CompletedVisit AS Curriculum247Dads  
, 100 * CurriculumBoyz2Dads / CompletedVisit AS CurriculumBoyz2Dads  
, 100 * CurriculumInsideOutDads / CompletedVisit AS CurriculumInsideOutDads 
, 100 * CurriculumMomGateway / CompletedVisit AS CurriculumMomGateway 
, 100 * CurriculumPATFocusFathers / CompletedVisit AS CurriculumPATFocusFathers  
, 100 * CurriculumOther / CompletedVisit AS CurriculumOther
, 100 * CurriculumNone / CompletedVisit AS CurriculumNone

FROM curriculum01 AS a
LEFT OUTER JOIN Worker AS c ON 
CASE WHEN (@showWorkerDetail = 'N' AND @workerfk IS NOT NULL) THEN @workerfk 
ELSE a.FSWFK END = c.WorkerPK
ORDER BY WorkerName, a.PC1ID
GO
