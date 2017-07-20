SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Edit date: 10/11/2013 CP - workerprogram was duplicating cases when worker transferred
CREATE PROCEDURE [dbo].[rspPSIHistory]
( @programfk VARCHAR(MAX) = NULL, 
  @supervisorfk INT = NULL, 
  @workerfk INT = NULL,
  @Over85Percent CHAR(1) = 'N',
  @pc1ID VARCHAR(13) = '',
  @SiteFK int = null, 
  @CaseFiltersPositive varchar(200) = '')
AS

if @programfk is null
  begin
	select @programfk = substring((select ','+ltrim(rtrim(str(HVProgramPK)))
									   from HVProgram
									   for xml path ('')),2,8000)
  end
set @programfk = replace(@programfk,'"','')

set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0
					else @SiteFK
				end
set @CaseFiltersPositive = case	when @CaseFiltersPositive = '' then null
								else @CaseFiltersPositive
						   end;

DECLARE @n INT = 0
SELECT @n = CASE WHEN @Over85Percent = 'Y' THEN 1 ELSE 0 END

SELECT 
LTRIM(RTRIM(supervisor.firstname)) + ' ' + LTRIM(RTRIM(supervisor.lastname)) supervisor,
LTRIM(RTRIM(fsw.firstname)) + ' ' + LTRIM(RTRIM(fsw.lastname)) worker,
d.PC1ID,
ltrim(rtrim(b.[AppCodeText])) PSIInterval, 
convert(VARCHAR(12), a.PSIDateComplete, 101) PSIDateComplete, 
a.DefensiveRespondingScore,
CASE WHEN DefensiveRespondingScore <= 10 THEN '*' ELSE '' END DefensiveRespondingScoreX, 
a.ParentalDistressScore, 
CASE WHEN ParentalDistressScore >= 33 THEN '*' ELSE '' END ParentalDistressScoreX, 
CASE WHEN ParentalDistressValid = 1 THEN '' ELSE '#' END ParentalDistressValidX, 
a.ParentChildDisfunctionalInteractionScore, 
CASE WHEN ParentChildDisfunctionalInteractionScore >= 26 THEN '*' ELSE '' END ParentChildDisfunctionalInteractionScoreX, 
CASE WHEN ParentChildDysfunctionalInteractionValid = 1 THEN '' ELSE '#' END ParentChildDysfunctionalInteractionValidX, 
a.DifficultChildScore, 
CASE WHEN DifficultChildScore >= 33 THEN '*' ELSE '' END DifficultChildScoreX, 
CASE WHEN DifficultChildValid = 1 THEN '' ELSE '#' END DifficultChildValidX,
a.PSITotalScore, 
CASE WHEN PSITotalScore >= 86 THEN '*' ELSE '' END PSITotalScoreX,
CASE WHEN PSITotalScoreValid = 1 THEN '' ELSE '#' END PSITotalScoreValidX,
CASE WHEN PSIInWindow IS NULL THEN 'Unknown' 
WHEN PSIInWindow = 1 THEN 'In Window' ELSE 'Out of Window' END InWindow,
a.PSIInterval

FROM PSI a 
INNER JOIN codeApp b 
ON a.PSIInterval = b.AppCode AND b.AppCodeGroup = 'PSIInterval' 
AND b.AppCodeUsedWhere LIKE '%PS%'
INNER JOIN CaseProgram d ON d.HVCaseFK = a.HVCaseFK
INNER JOIN dbo.SplitString(@programfk,',') on d.programfk = listitem
INNER JOIN worker fsw ON d.CurrentFSWFK = fsw.workerpk
INNER JOIN workerprogram wp ON wp.workerfk = fsw.workerpk AND wp.ProgramFK=ListItem
INNER JOIN worker supervisor ON wp.supervisorfk = supervisor.workerpk
inner join dbo.udfCaseFilters(@CaseFiltersPositive, '', @programfk) cf on cf.HVCaseFK = d.HVCaseFK

INNER JOIN 
(SELECT HVCaseFK, 
SUM(
CASE WHEN DefensiveRespondingScore <= 10 THEN 1 ELSE 0 END +
CASE WHEN ParentalDistressScore >= 33 THEN 1 ELSE 0 END +
CASE WHEN ParentChildDisfunctionalInteractionScore >= 26 THEN 1 ELSE 0 END +
CASE WHEN DifficultChildScore >= 33 THEN 1 ELSE 0 END +
CASE WHEN PSITotalScore >= 86 THEN 1 ELSE 0 END 
) flag
FROM PSI 
GROUP BY HVCaseFK
HAVING SUM(
CASE WHEN DefensiveRespondingScore <= 10 THEN 1 ELSE 0 END +
CASE WHEN ParentalDistressScore >= 33 THEN 1 ELSE 0 END +
CASE WHEN ParentChildDisfunctionalInteractionScore >= 26 THEN 1 ELSE 0 END +
CASE WHEN DifficultChildScore >= 33 THEN 1 ELSE 0 END +
CASE WHEN PSITotalScore >= 86 THEN 1 ELSE 0 END 
) >= @n) x 
ON x.HVCaseFK = a.HVCaseFK

WHERE 
d.DischargeDate IS NULL
AND d.currentFSWFK = ISNULL(@workerfk, d.currentFSWFK)
AND wp.supervisorfk = ISNULL(@supervisorfk, wp.supervisorfk)
--AND d.programfk = @programfk
AND d.PC1ID = CASE WHEN @pc1ID = '' THEN d.PC1ID ELSE @pc1ID END
and case when @SiteFK = 0 then 1
		 when wp.SiteFK = @SiteFK then 1
		 else 0
	end = 1
order BY  supervisor, worker, PC1ID, a.PSIInterval
GO
