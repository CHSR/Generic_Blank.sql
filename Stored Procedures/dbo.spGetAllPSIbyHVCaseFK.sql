SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Dar Chen
-- Create date: 4/2/2012
-- Description:	PSI data by HVCaseFK
-- =============================================
CREATE PROCEDURE [dbo].[spGetAllPSIbyHVCaseFK]
(
    @HVCaseFK INT
)

AS
BEGIN
	SET NOCOUNT ON;

	SELECT appCodeText AS PSIIntervalText
		 , appCode AS PSIInterval
		 , PSIDateComplete AS PSIDateComplete
		 , PSIPK
		 , HVCaseFK
		 , ProgramFK
		 , Defensive
		 , PD
		 , PCDI
		 , DC
		 , TotalScore
		 , Valid
	FROM
		(SELECT appCodeText
			  , appCode
		 FROM
			 codeApp
		 WHERE
			 appCodeGroup = 'PSIInterval'
			 AND appCodeUsedWhere LIKE '%PS%') a
		LEFT OUTER JOIN (SELECT convert(VARCHAR(20), PSIDateComplete, 101) AS PSIDateComplete
							  , PSIInterval AS PSIInterval
							  , PSIPK
							  , HVCaseFK
							  , ProgramFK
							  , DefensiveRespondingScore [Defensive]
							, ParentalDistressScore [PD]
							, ParentChildDisfunctionalInteractionScore [PCDI]
							, DifficultChildScore [DC]
							, PSITotalScore [TotalScore]
							, CASE WHEN PSITotalScoreValid = 1 THEN 'Yes' ELSE 'No' END [Valid]
						 FROM
							 PSI
						 WHERE
							 HVCaseFK = @HVCaseFK) b
			ON a.appCode = b.PSIInterval
	ORDER BY
		cast(appCode AS INT)


END
GO
