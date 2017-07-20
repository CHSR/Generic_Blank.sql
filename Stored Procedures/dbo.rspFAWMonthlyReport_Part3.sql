SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Dar Chen
-- Create date: 06/18/2010
-- Description:	FAW Monthly Report
-- =============================================
CREATE PROCEDURE [dbo].[rspFAWMonthlyReport_Part3] 
	-- Add the parameters for the stored procedure here
	@programfk INT = NULL, 
	@StartDt datetime,
	@EndDt datetime
AS

--DECLARE @StartDt DATE = '01/01/2011'
--DECLARE @EndDt DATE = '01/31/2011'
--DECLARE @programfk INT = 17

SELECT rtrim(d.PCLastName) + ', ' + rtrim(d.PCFirstName) [Participant]
, convert(varchar(12), a.KempeDate,  101) [KempeDate]
, CASE WHEN a.KempeResult = 1 THEN '+' ELSE '-' END [Outcome]
, CASE WHEN faw.WorkerPK IS NULL THEN '(not assigned)' ELSE rtrim(faw.LastName) + ', ' + rtrim(faw.FirstName) END [FAW]
, CASE WHEN fsw.WorkerPK IS NULL THEN '(not assigned)' ELSE rtrim(fsw.LastName) + ', ' + rtrim(fsw.FirstName) END [FSW]
,a.FAWFK, a.KempeResult, b.PAFSWFK
FROM Kempe AS a
JOIN HVCase AS c ON a.HVCaseFK = c.HVCasePK
JOIN PC d ON d.PCPK = c.PC1FK
LEFT OUTER JOIN Preassessment AS b ON a.HVCaseFK = b.HVCaseFK AND b.CaseStatus in ('02', '04')
LEFT OUTER JOIN Worker faw ON a.FAWFK = faw.WorkerPK
LEFT OUTER JOIN Worker fsw ON b.PAFSWFK = fsw.WorkerPK

WHERE a.ProgramFK = @programfk AND (a.KempeDate BETWEEN @StartDt AND @EndDt)
ORDER BY a.KempeDate asc












GO
