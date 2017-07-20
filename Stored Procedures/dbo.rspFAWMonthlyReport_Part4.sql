SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Dar Chen
-- Create date: 06/18/2010
-- Description:	FAW Monthly Report
-- =============================================
CREATE PROCEDURE [dbo].[rspFAWMonthlyReport_Part4] 
	-- Add the parameters for the stored procedure here
	@programfk INT = NULL, 
	@StartDt datetime,
	@EndDt datetime
AS

--DECLARE @StartDt DATE = '01/01/2011'
--DECLARE @EndDt DATE = '01/31/2011'
--DECLARE @programfk INT = 17

SELECT a.DischargeReason, 
CASE WHEN x.TerminatedNotAssessed IS NULL THEN 0 ELSE x.TerminatedNotAssessed END 
[TerminatedNotAssessed], 
CASE WHEN y.AssessedPositiveNotAssigned IS NULL THEN 0 ELSE y.AssessedPositiveNotAssigned END
[AssessedPositiveNotAssigned]
FROM codeDischarge AS a
LEFT OUTER JOIN
(SELECT DischargeReason, count(*) [TerminatedNotAssessed]
FROM Preassessment
WHERE ProgramFK = @programfk AND PADate BETWEEN @StartDt AND @EndDt
AND CaseStatus IN ('03')
GROUP BY DischargeReason) AS x
ON x.DischargeReason = a.DischargeCode
LEFT OUTER JOIN
(SELECT DischargeReason, count(*) [AssessedPositiveNotAssigned]
FROM Preassessment
WHERE ProgramFK = @programfk AND PADate BETWEEN @StartDt AND @EndDt
AND CaseStatus IN ('04')
GROUP BY DischargeReason) AS y
ON y.DischargeReason = a.DischargeCode
WHERE a.DischargeUsedWhere LIKE '%PA%'
ORDER BY a.DischargeCode










GO
