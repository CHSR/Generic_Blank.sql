SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <04/04/2013>
-- Description:	<This Credentialing report gets you 'Summary for 1-2.A Acceptance Rates and 1-2.B Refusal Rates Analysis'>
-- rspCredentialingKempeAnalysis_Summary 2, '01/01/2011', '12/31/2011'
-- rspCredentialingKempeAnalysis_Summary 1, '04/01/2012', '03/31/2013'

-- =============================================


CREATE procedure [dbo].[rspCredentialingKempeAnalysis_MD](
	@programfk    varchar(max)    = NULL,	
	@StartDate DATETIME,
	@EndDate DATETIME

)
AS

--DECLARE @startDT DATE = '01/01/2015'
--DECLARE @endDT DATE = '03/31/2016'
--DECLARE @ProgramFK varchar(max) = '1'

if @ProgramFK is null
	begin
		select @ProgramFK =
			   substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
						from HVProgram for xml path ('')),2,8000)
	end
	set @ProgramFK = REPLACE(@ProgramFK,'"','')

	; WITH cteMain as (
	SELECT 
		CASE WHEN IntakeDate IS NOT NULL THEN  '1' --'AcceptedFirstVisitEnrolled' 
		WHEN KempeResult = 1 AND IntakeDate IS NULL AND DischargeDate IS NOT NULL 
		AND (PIVisitMade > 0 AND PIVisitMade IS NOT NULL) THEN '2' -- 'AcceptedFirstVisitNotEnrolled'
		ELSE '3' -- 'Refused' 
		END Status
		, DischargeDate
		, IntakeDate
		, k.KempeDate
		, PC1FK
		, cp.DischargeReason
		, OldID
		, PC1ID		 
		, KempeResult

	FROM HVCase h
	INNER JOIN CaseProgram cp ON cp.HVCaseFK = h.HVCasePK
	inner join dbo.SplitString(@ProgramFK, ',') on cp.programfk = listitem
	INNER JOIN Kempe k ON k.HVCaseFK = h.HVCasePK
	INNER JOIN PC P ON P.PCPK = h.PC1FK
	LEFT OUTER JOIN 
	(SELECT KempeFK, sum(CASE WHEN PIVisitMade > 0 THEN 1 ELSE 0 END) PIVisitMade
		FROM Preintake AS a
		INNER JOIN CaseProgram cp ON cp.HVCaseFK = a.HVCaseFK
	    INNER join dbo.SplitString(@ProgramFK, ',') on cp.programfk = listitem
		--WHERE ProgramFK = @ProgramFK
		GROUP BY kempeFK) AS x ON x.KempeFK = k.KempePK
	WHERE (h.IntakeDate IS NOT NULL OR cp.DischargeDate IS NOT NULL) AND k.KempeResult = 1 
	AND k.KempeDate BETWEEN @StartDate AND @EndDate
	)

	, cteMain1 AS (
	SELECT 
	  COUNT(*) AS 'Total'
	, SUM(CASE WHEN Status IN ('1', '2') THEN 1 ELSE 0 END) AS 'Enrolled'
	, SUM(CASE WHEN Status IN ('3') THEN 1 ELSE 0 END) AS 'NotEnrolled'
	, SUM(CASE WHEN Status = '3' AND DischargeReason = '36' THEN 1 ELSE 0 END) 'Refused'
	, SUM(CASE WHEN Status = '3' AND DischargeReason = '12' THEN 1 ELSE 0 END) 'UnableToLocate'
	, SUM(CASE WHEN Status = '3' AND DischargeReason = '19' THEN 1 ELSE 0 END) 'TCAgedOut'
	, SUM(CASE WHEN Status = '3' AND DischargeReason = '07' THEN 1 ELSE 0 END) 'OutOfTargetArea'
	, SUM(CASE WHEN Status = '3' AND DischargeReason IN ('25') THEN 1 ELSE 0 END) 'Transfered'
	, SUM(CASE WHEN Status = '3' AND DischargeReason NOT IN ('36','12','19','07','25')  THEN 1 ELSE 0 END) 'AllOthers'
	FROM cteMain
	)

	, cteMain2 AS (
	SELECT 
	  Total
	, CONVERT(VARCHAR, Enrolled) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( Enrolled AS FLOAT) * 100/ NULLIF(Total,0), 0), 0))  + '%)' AS Enrolled
	, CONVERT(VARCHAR, NotEnrolled) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( NotEnrolled AS FLOAT) * 100/ NULLIF(Total,0), 0), 0))  + '%)' AS NotEnrolled
	, CONVERT(VARCHAR, Refused) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( Refused AS FLOAT) * 100/ NULLIF(NotEnrolled,0), 0), 0))  + '%)' AS Refused
	, CONVERT(VARCHAR, UnableToLocate) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( UnableToLocate AS FLOAT) * 100/ NULLIF(NotEnrolled,0), 0), 0))  + '%)' AS UnableToLocate
	, CONVERT(VARCHAR, TCAgedOut) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( TCAgedOut AS FLOAT) * 100/ NULLIF(NotEnrolled,0), 0), 0))  + '%)' AS TCAgedOut
	, CONVERT(VARCHAR, OutOfTargetArea) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( OutOfTargetArea AS FLOAT) * 100/ NULLIF(NotEnrolled,0), 0), 0))  + '%)' AS OutOfTargetArea
	, CONVERT(VARCHAR, Transfered) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( Transfered AS FLOAT) * 100/ NULLIF(NotEnrolled,0), 0), 0))  + '%)' AS Transfered
	, CONVERT(VARCHAR, AllOthers) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( AllOthers AS FLOAT) * 100/ NULLIF(NotEnrolled,0), 0), 0))  + '%)' AS AllOthers
	
	FROM cteMain1
	)

	SELECT *
	FROM cteMain2
GO
