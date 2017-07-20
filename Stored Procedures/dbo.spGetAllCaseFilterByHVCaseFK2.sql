SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Dar Chen
-- Create date: 7/2/2013
-- Description:	CaseFilter 
-- =============================================
CREATE PROCEDURE [dbo].[spGetAllCaseFilterByHVCaseFK2]  (@HVCaseFK int, @ProgramFK int)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SELECT CASE WHEN b.CaseFilterPK IS NULL THEN 0 ELSE b.CaseFilterPK END [CaseFilterPK]
, a.listCaseFilterNamePK, a.FieldTitle, a.Hint, a.FilterType
, b.CaseFilterNameChoice, b.CaseFilterNameOptionFK, b.CaseFilterValue,  b.CaseFilterNameDate
, CASE WHEN a.FilterType = '01' THEN
Case WHEN b.CaseFilterNameChoice = 1 THEN 'Yes' WHEN b.CaseFilterNameChoice = 0 THEN 'No' ELSE '(Missing)' END
WHEN a.FilterType = '03' THEN CASE WHEN b.CaseFilterValue IS NULL THEN '(Missing)' ELSE b.CaseFilterValue END
WHEN a.FilterType = '04' THEN CASE WHEN b.CaseFilterNameDate IS NULL THEN '(Missing)' ELSE convert(VARCHAR(12), b.CaseFilterNameDate, 1) END
WHEN a.FilterType = '02' THEN CASE WHEN b.CaseFilterNameOptionFK IS NULL THEN '(Missing)' ELSE 
(SELECT TOP 1 c.FilterOption FROM listCaseFilterNameOption c
WHERE c.listCaseFilterNameOptionPK =  b.CaseFilterNameOptionFK)
END ELSE '' END [DisplayValue]

FROM listCaseFilterName AS a
LEFT OUTER JOIN CaseFilter AS b ON b.CaseFilterNameFK = a.listCaseFilterNamePK
AND b.HVCaseFK = @HVCaseFK
WHERE a.ProgramFK = @ProgramFK AND (a.Inactive IS NULL OR a.Inactive = 0)
ORDER BY a.listCaseFilterNamePK
END
GO
