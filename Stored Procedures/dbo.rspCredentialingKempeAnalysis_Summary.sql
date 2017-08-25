SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Dar Chen>
-- Create date: <04/04/2016>
-- Description:	<This Credentialing report gets you 'Summary for 1-2.A Acceptance Rates and 1-2.B Refusal Rates Analysis'>
-- rspCredentialingKempeAnalysis_Summary 2, '01/01/2011', '12/31/2011'
-- rspCredentialingKempeAnalysis_Summary 1, '04/01/2012', '03/31/2013'

-- =============================================


CREATE procedure [dbo].[rspCredentialingKempeAnalysis_Summary](
	@programfk    varchar(max)    = NULL,	
	@StartDate DATETIME,
	@EndDate DATETIME
)
AS
DECLARE @programfkX varchar(max)
DECLARE	@StartDateX DATETIME	 = @StartDate
DECLARE	@EndDateX   DATETIME     = @EndDate

if @programfk is null
begin
	select @programfk = substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
									from HVProgram
									for xml path ('')),2,8000)
end

set @programfk = REPLACE(@programfk,'"','')
SET @programfkX = @programfk
SET @StartDateX = @StartDate
SET @EndDateX = @EndDate

if object_id('tempdb..#cteMain') is not null drop table #cteMain
if object_id('tempdb..#cteMain1') is not null drop table #cteMain1

create table #cteMain (
	HVCasePK int
		 , tcdob datetime
		 , DischargeDate datetime
		 , IntakeDate datetime
		 , KempeDate datetime
		 , PC1FK int
		 , DischargeReason char(2)
		 , OldID char(23)
		 , PC1ID char(13)
		 , KempeResult bit
		 , cCurrentFSWFK int
		 , cCurrentFAWFK int
		 , babydate	datetime
		 , testdate	datetime
		  , PCDOB datetime
		  , Race char(2)
		  ,MaritalStatus char(2)
		  ,HighestGrade char(2)
		  ,IsCurrentlyEmployed char(1)
		  ,OBPInHome char(1)		
		  , MomScore int
		  , DadScore int
		  ,FOBPresent bit
		  ,MOBPresent bit
		  ,OtherPresent bit
		  ,MOBPartnerPresent bit --as MOBPartner 
		  ,FOBPartnerPresent bit --as FOBPartner
		  ,GrandParentPresent bit --as MOBGrandmother
	, PIVisitMade int
	, DV int
	, MH int
	, SA int
	, presentCode int
)

create table #cteMain1 (
	 Status char(1)
	, [IntakeDate2] datetime
	, [KempeResult2] bit
	, [PIVisitMade2] int
	, [DischargeDate2] datetime
	, [DischargeReason2] char(2)
	, age int
	, KempeScore int
	, Trimester int
	, HVCasePK int
	, tcdob datetime
	, DischargeDate datetime
	, IntakeDate datetime
	, KempeDate datetime
	, PC1FK int
	, DischargeReason char(2)
	, OldID char(23)
	, PC1ID char(13)
	, KempeResult bit
	, cCurrentFSWFK int
	, cCurrentFAWFK int
	, babydate	datetime
	, testdate	datetime
	, PCDOB datetime
	, Race char(2)
	, MaritalStatus char(2)
	, HighestGrade char(2)
	, IsCurrentlyEmployed char(1)
	, OBPInHome char(1)		
	, MomScore int
	, DadScore int
	, FOBPresent bit
	, MOBPresent bit
	, OtherPresent bit
	, MOBPartnerPresent bit --as MOBPartner 
	, FOBPartnerPresent bit --as FOBPartner
	, GrandParentPresent bit --as MOBGrandmother
	, PIVisitMade int
	, DV int
	, MH int
	, SA int
	, presentCode int
)

; WITH 	ctePIVisits 
			as (select	KempeFK
						, sum(case when PIVisitMade > 0 then 1
									else 0
							end) PIVisitMade
				from		Preintake pi
				inner join dbo.SplitString(@programfk, ',') on pi.ProgramFK = ListItem
				group by	KempeFK
				) 
		, ctePreviousPC1Issue
		as (select
                    min(PC1IssuesPK) AS PC1IssuesPK
                   ,HVCaseFK
                from PC1Issues
                inner join dbo.SplitString(@programfk, ',') on PC1Issues.ProgramFK = ListItem
				where rtrim(Interval) = '1'
                group by HVCaseFK)
		, cteIssues
		as (select a.HVCaseFK
					,case when DomesticViolence = 1 then 1 else 0 end as DV
					,case when (Depression = 1 or MentalIllness = 1) then 1 else 0 end as MH
					,case when (AlcoholAbuse = 1 or SubstanceAbuse = 1) then 1 else 0 end as SA
				from PC1Issues a
				inner join (select min(PC1IssuesPK) AS PC1IssuesPK
									, HVCaseFK
					from PC1Issues
					where RTRIM(Interval) = '1'
					group BY HVCaseFK) b on a.PC1IssuesPK = b.PC1IssuesPK
			)
insert into #cteMain
	SELECT HVCasePK
		 , 	case
			   when h.tcdob is not null then
				   h.tcdob
			   else
				   h.edc
			end as tcdob
		 , DischargeDate
		 , IntakeDate
		 , k.KempeDate
		 , PC1FK
		 , cp.DischargeReason
		 , OldID
		 , PC1ID		 
		 , KempeResult
		 , cp.CurrentFSWFK
		 , cp.CurrentFAWFK	
		 ,	case
			   when h.tcdob is not null then
				   h.tcdob
			   else
				   h.edc
			end as babydate	
		 ,	case
			   when h.IntakeDate is not null then
				   h.IntakeDate
			   else
				   cp.DischargeDate 
			end as testdate	
		  , P.PCDOB 
		  , P.Race 
		  ,ca.MaritalStatus
		  ,ca.HighestGrade 
		  ,ca.IsCurrentlyEmployed
		  ,ca.OBPInHome  		
		  ,case when MomScore = 'U' then 0 else cast(MomScore as int) end as MomScore
		  ,case when DadScore = 'U' then 0 else cast(DadScore as int) end as DadScore 
		  ,FOBPresent
		  ,MOBPresent 
		  ,OtherPresent 
		  ,MOBPartnerPresent --as MOBPartner 
		  ,FOBPartnerPresent --as FOBPartner
		  ,GrandParentPresent --as MOBGrandmother
	, PIVisitMade
	, i.DV 
	, i.MH
	, i.SA

	, CASE WHEN (ISNULL(k.MOBPartnerPresent,0) = 0 AND ISNULL(k.FOBPartnerPresent,0) = 0 
			 AND ISNULL(k.GrandParentPresent,0) = 0 AND ISNULL(k.OtherPresent,0) = 0) THEN
     CASE WHEN k.MOBPresent = 1 AND k.FOBPresent = 1 THEN 3 -- both parent
		 WHEN k.MOBPresent = 1 THEN  1 -- MOB Only
		 WHEN k.FOBPresent = 1 THEN  2 -- FOB Only
		 ELSE 4  -- parent/other
	 END
	ELSE 4 -- parent/other
	END presentCode


	 FROM HVCase h
	INNER JOIN CaseProgram cp ON cp.HVCaseFK = h.HVCasePK
	inner join dbo.SplitString(@programfkX,',') on cp.programfk = listitem
	INNER JOIN Kempe k ON k.HVCaseFK = h.HVCasePK
	INNER JOIN PC P ON P.PCPK = h.PC1FK
	LEFT OUTER JOIN ctePIVisits piv on piv.KempeFK = k.KempePK
	LEFT OUTER join cteIssues i on i.HVCaseFK = h.HVCasePK
	LEFT JOIN CommonAttributes ca ON ca.hvcasefk = h.hvcasepk AND ca.formtype = 'KE'
	WHERE (h.IntakeDate IS NOT NULL OR cp.DischargeDate IS NOT NULL) -- only include kempes that are positive and where there is a clos_date or an intake date.
	AND k.KempeResult = 1
	AND k.KempeDate BETWEEN @StartDateX AND @EndDateX

insert into #cteMain1	

	SELECT 
	CASE WHEN IntakeDate IS NOT NULL THEN  '1' --'AcceptedFirstVisitEnrolled' 
	WHEN KempeResult = 1 AND IntakeDate IS NULL AND DischargeDate IS NOT NULL 
	AND (PIVisitMade > 0 AND PIVisitMade IS NOT NULL) THEN '2' -- 'AcceptedFirstVisitNotEnrolled'
	ELSE '3' -- 'Refused' 
	END Status

	, a.IntakeDate AS [IntakeDate2], a.KempeResult as [KempeResult2], a.PIVisitMade AS [PIVisitMade2], 
	a.DischargeDate AS [DischargeDate2], a.DischargeReason AS [DischargeReason2]

	, datediff(day,pcdob, testdate)/365.25 AS age
	, CASE WHEN a.MomScore > a.DadScore THEN a.MomScore ELSE a.DadScore END KempeScore
	, CASE WHEN datediff(d, testdate, babydate) > 0 and datediff(d, testdate, babydate) < 30.44*3  then 3 
		WHEN ( datediff(d, testdate, babydate) >= 30.44*3 and datediff(d, testdate, babydate) < 30.44*6 ) then 2
		WHEN datediff(d, testdate, babydate) >= round(30.44*6,0) then 1
		WHEN datediff(d, testdate, babydate) <= 0 then 4	
	end as Trimester 	
	, *
	
	FROM #cteMain AS a

; with total1 AS (
SELECT 
  COUNT(*) AS total
, SUM(CASE WHEN a.Status = '1' THEN 1 ELSE 0 END) AS totalG1
, SUM(CASE WHEN a.Status = '2' THEN 1 ELSE 0 END) AS totalG2
, SUM(CASE WHEN a.Status = '3' THEN 1 ELSE 0 END) AS totalG3
FROM #cteMain1 AS a
)

, total2 AS (
SELECT 
 'Totals (N = ' + CONVERT(VARCHAR, total) + ')' AS [title]
 , CONVERT(VARCHAR, totalG1) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( totalG1 AS FLOAT) * 100/ NULLIF(total,0), 0), 0))  + '%)' AS col1
 , CONVERT(VARCHAR, totalG2) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( totalG2 AS FLOAT) * 100/ NULLIF(total,0), 0), 0))  + '%)' AS col2
 , CONVERT(VARCHAR, totalG3) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( totalG3 AS FLOAT) * 100/ NULLIF(total,0), 0), 0))  + '%)' AS col3
 , '1' AS col4
FROM total1
)

, total3 AS (
SELECT 
 'Acceptance Rate - ' + 
 CONVERT(VARCHAR, round(COALESCE(cast( (totalG1 + totalG2) AS FLOAT) * 100/ NULLIF(total,0), 0), 0))  + '%' AS [title]
 , '' AS col1
 , '' AS col2
 , '' AS col3
 , '1' AS col4
FROM total1

UNION ALL	
SELECT '' AS [title], '' AS col1, '' AS col2, '' AS col3
, '1' AS col4
)

, age1 AS (
SELECT 
    SUM(CASE WHEN a.Status = '1' THEN 1 ELSE 0 END) AS totalG1
  , SUM(CASE WHEN a.Status = '2' THEN 1 ELSE 0 END) AS totalG2
  , SUM(CASE WHEN a.Status = '3' THEN 1 ELSE 0 END) AS totalG3

  , SUM(CASE WHEN age < 18 THEN 1 ELSE 0 END) AS age18
  , SUM(CASE WHEN a.Status = '1' and age < 18 THEN 1 ELSE 0 END) AS age18G1
  , SUM(CASE WHEN a.Status = '2' and age < 18 THEN 1 ELSE 0 END) AS age18G2
  , SUM(CASE WHEN a.Status = '3' and age < 18 THEN 1 ELSE 0 END) AS age18G3

  , SUM(CASE WHEN (age >= 18 AND age < 20) THEN 1 ELSE 0 END) AS age20
  , SUM(CASE WHEN a.Status = '1' and (age >= 18 AND age < 20) THEN 1 ELSE 0 END) AS age20G1
  , SUM(CASE WHEN a.Status = '2' and (age >= 18 AND age < 20) THEN 1 ELSE 0 END) AS age20G2
  , SUM(CASE WHEN a.Status = '3' and (age >= 18 AND age < 20) THEN 1 ELSE 0 END) AS age20G3

  , SUM(CASE WHEN (age >= 20 AND age < 30) THEN 1 ELSE 0 END) AS age30
  , SUM(CASE WHEN a.Status = '1' and (age >= 20 AND age < 30) THEN 1 ELSE 0 END) AS age30G1
  , SUM(CASE WHEN a.Status = '2' and (age >= 20 AND age < 30) THEN 1 ELSE 0 END) AS age30G2
  , SUM(CASE WHEN a.Status = '3' and (age >= 20 AND age < 30) THEN 1 ELSE 0 END) AS age30G3

  , SUM(CASE WHEN (age >= 30) THEN 1 ELSE 0 END) AS age40
  , SUM(CASE WHEN a.Status = '1' and (age >= 30) THEN 1 ELSE 0 END) AS age40G1
  , SUM(CASE WHEN a.Status = '2' and (age >= 30) THEN 1 ELSE 0 END) AS age40G2
  , SUM(CASE WHEN a.Status = '3' and (age >= 30) THEN 1 ELSE 0 END) AS age40G3

  FROM #cteMain1 AS a
)

, age2 AS (
SELECT 'Age' AS [title], '' AS col1, '' AS col2, '' AS col3
 , '1' AS col4
UNION ALL

SELECT
 '  Under 18' AS [title]
 , CONVERT(VARCHAR, age18G1) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( age18G1 AS FLOAT) * 100/ NULLIF(totalG1,0), 0), 0))  + '%)' AS col1
 , CONVERT(VARCHAR, age18G2) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( age18G2 AS FLOAT) * 100/ NULLIF(totalG2,0), 0), 0))  + '%)' AS col2
 , CONVERT(VARCHAR, age18G3) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( age18G3 AS FLOAT) * 100/ NULLIF(totalG3,0), 0), 0))  + '%)' AS col3
 , '1' AS col4
FROM age1

UNION ALL
SELECT 
 '  18 up to 20' AS [title]
 , CONVERT(VARCHAR, age20G1) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( age20G1 AS FLOAT) * 100/ NULLIF(totalG1,0), 0), 0))  + '%)' AS col1
 , CONVERT(VARCHAR, age20G2) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( age20G2 AS FLOAT) * 100/ NULLIF(totalG2,0), 0), 0))  + '%)' AS col2
 , CONVERT(VARCHAR, age20G3) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( age20G3 AS FLOAT) * 100/ NULLIF(totalG3,0), 0), 0))  + '%)' AS col3
 , '1' AS col4
FROM age1

UNION ALL
SELECT 
 '  20 up to 30' AS [title]
 , CONVERT(VARCHAR, age30G1) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( age30G1 AS FLOAT) * 100/ NULLIF(totalG1,0), 0), 0))  + '%)' AS col1
 , CONVERT(VARCHAR, age30G2) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( age30G2 AS FLOAT) * 100/ NULLIF(totalG2,0), 0), 0))  + '%)' AS col2
 , CONVERT(VARCHAR, age30G3) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( age30G3 AS FLOAT) * 100/ NULLIF(totalG3,0), 0), 0))  + '%)' AS col3
 , '1' AS col4
FROM age1

UNION ALL
SELECT 
 '  30 and over' AS [title]
 , CONVERT(VARCHAR, age40G1) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( age40G1 AS FLOAT) * 100/ NULLIF(totalG1,0), 0), 0))  + '%)' AS col1
 , CONVERT(VARCHAR, age40G2) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( age40G2 AS FLOAT) * 100/ NULLIF(totalG2,0), 0), 0))  + '%)' AS col2
 , CONVERT(VARCHAR, age40G3) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( age40G3 AS FLOAT) * 100/ NULLIF(totalG3,0), 0), 0))  + '%)' AS col3
 , '1' AS col4
FROM age1

UNION ALL
SELECT '' AS [title], '' AS col1, '' AS col2, '' AS col3
 , '1' AS col4
)

, race1 AS (
SELECT 
    SUM(CASE WHEN a.Status = '1' THEN 1 ELSE 0 END) AS totalG1
  , SUM(CASE WHEN a.Status = '2' THEN 1 ELSE 0 END) AS totalG2
  , SUM(CASE WHEN a.Status = '3' THEN 1 ELSE 0 END) AS totalG3

  , SUM(CASE WHEN race = '01' THEN 1 ELSE 0 END) AS race01
  , SUM(CASE WHEN a.Status = '1' and race = '01' THEN 1 ELSE 0 END) AS race01G1
  , SUM(CASE WHEN a.Status = '2' and race = '01' THEN 1 ELSE 0 END) AS race01G2
  , SUM(CASE WHEN a.Status = '3' and race = '01' THEN 1 ELSE 0 END) AS race01G3

  , SUM(CASE WHEN race = '02' THEN 1 ELSE 0 END) AS race02
  , SUM(CASE WHEN a.Status = '1' and race = '02' THEN 1 ELSE 0 END) AS race02G1
  , SUM(CASE WHEN a.Status = '2' and race = '02' THEN 1 ELSE 0 END) AS race02G2
  , SUM(CASE WHEN a.Status = '3' and race = '02' THEN 1 ELSE 0 END) AS race02G3

  , SUM(CASE WHEN race = '03' THEN 1 ELSE 0 END) AS race03
  , SUM(CASE WHEN a.Status = '1' and race = '03' THEN 1 ELSE 0 END) AS race03G1
  , SUM(CASE WHEN a.Status = '2' AND race = '03' THEN 1 ELSE 0 END) AS race03G2
  , SUM(CASE WHEN a.Status = '3' and race = '03' THEN 1 ELSE 0 END) AS race03G3

  , SUM(CASE WHEN race = '04' THEN 1 ELSE 0 END) AS race04
  , SUM(CASE WHEN a.Status = '1' and race = '04' THEN 1 ELSE 0 END) AS race04G1
  , SUM(CASE WHEN a.Status = '2' and race = '04' THEN 1 ELSE 0 END) AS race04G2
  , SUM(CASE WHEN a.Status = '3' and race = '04' THEN 1 ELSE 0 END) AS race04G3

  , SUM(CASE WHEN race = '05' THEN 1 ELSE 0 END) AS race05
  , SUM(CASE WHEN a.Status = '1' and race = '05' THEN 1 ELSE 0 END) AS race05G1
  , SUM(CASE WHEN a.Status = '2' and race = '05' THEN 1 ELSE 0 END) AS race05G2
  , SUM(CASE WHEN a.Status = '3' and race = '05' THEN 1 ELSE 0 END) AS race05G3

  , SUM(CASE WHEN race = '06' THEN 1 ELSE 0 END) AS race06
  , SUM(CASE WHEN a.Status = '1' and race = '06' THEN 1 ELSE 0 END) AS race06G1
  , SUM(CASE WHEN a.Status = '2' and race = '06' THEN 1 ELSE 0 END) AS race06G2
  , SUM(CASE WHEN a.Status = '3' and race = '06' THEN 1 ELSE 0 END) AS race06G3

  , SUM(CASE WHEN race = '07' THEN 1 ELSE 0 END) AS race07
  , SUM(CASE WHEN a.Status = '1' and race = '07' THEN 1 ELSE 0 END) AS race07G1
  , SUM(CASE WHEN a.Status = '2' and race = '07' THEN 1 ELSE 0 END) AS race07G2
  , SUM(CASE WHEN a.Status = '3' and race = '07' THEN 1 ELSE 0 END) AS race07G3

  , SUM(CASE WHEN (Race IS NULL or Race = '') THEN 1 ELSE 0 END) AS race08
  , SUM(CASE WHEN a.Status = '1' and (Race IS NULL or Race = '') THEN 1 ELSE 0 END) AS race08G1
  , SUM(CASE WHEN a.Status = '2' and (Race IS NULL or Race = '') THEN 1 ELSE 0 END) AS race08G2
  , SUM(CASE WHEN a.Status = '3' and (Race IS NULL or Race = '') THEN 1 ELSE 0 END) AS race08G3

  FROM #cteMain1 AS a
)

, race2 AS (
SELECT 'Race' AS [title], '' AS col1, '' AS col2, '' AS col3
 , '1' AS col4
UNION ALL
SELECT 
 '  White, non-Hispanic' AS [title]
 , CONVERT(VARCHAR, race01G1) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( race01G1 AS FLOAT) * 100/ NULLIF(totalG1,0), 0), 0))  + '%)' AS col1
 , CONVERT(VARCHAR, race01G2) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( race01G2 AS FLOAT) * 100/ NULLIF(totalG2,0), 0), 0))  + '%)' AS col2
 , CONVERT(VARCHAR, race01G3) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( race01G3 AS FLOAT) * 100/ NULLIF(totalG3,0), 0), 0))  + '%)' AS col3
 , '1' AS col4
FROM race1

UNION ALL
SELECT
 '  Black, non-Hispanic' AS [title]
 , CONVERT(VARCHAR, race02G1) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( race02G1 AS FLOAT) * 100/ NULLIF(totalG1,0), 0), 0))  + '%)' AS col1
 , CONVERT(VARCHAR, race02G2) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( race02G2 AS FLOAT) * 100/ NULLIF(totalG2,0), 0), 0))  + '%)' AS col2
 , CONVERT(VARCHAR, race02G3) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( race02G3 AS FLOAT) * 100/ NULLIF(totalG3,0), 0), 0))  + '%)' AS col3
 , '1' AS col4
FROM race1

UNION ALL
SELECT
 '  Hispanic/Latina/Latino' AS [title]
 , CONVERT(VARCHAR, race03G1) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( race03G1 AS FLOAT) * 100/ NULLIF(totalG1,0), 0), 0))  + '%)' AS col1
 , CONVERT(VARCHAR, race03G2) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( race03G2 AS FLOAT) * 100/ NULLIF(totalG2,0), 0), 0))  + '%)' AS col2
 , CONVERT(VARCHAR, race03G3) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( race03G3 AS FLOAT) * 100/ NULLIF(totalG3,0), 0), 0))  + '%)' AS col3
 , '1' AS col4
FROM race1

UNION ALL
SELECT
 '  Asian' AS [title]
 , CONVERT(VARCHAR, race04G1) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( race04G1 AS FLOAT) * 100/ NULLIF(totalG1,0), 0), 0))  + '%)' AS col1
 , CONVERT(VARCHAR, race04G2) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( race04G2 AS FLOAT) * 100/ NULLIF(totalG2,0), 0), 0))  + '%)' AS col2
 , CONVERT(VARCHAR, race04G3) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( race04G3 AS FLOAT) * 100/ NULLIF(totalG3,0), 0), 0))  + '%)' AS col3
 , '1' AS col4
FROM race1

UNION ALL
SELECT
 '  Native American' AS [title]
 , CONVERT(VARCHAR, race05G1) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( race05G1 AS FLOAT) * 100/ NULLIF(totalG1,0), 0), 0))  + '%)' AS col1
 , CONVERT(VARCHAR, race05G2) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( race05G2 AS FLOAT) * 100/ NULLIF(totalG2,0), 0), 0))  + '%)' AS col2
 , CONVERT(VARCHAR, race05G3) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( race05G3 AS FLOAT) * 100/ NULLIF(totalG3,0), 0), 0))  + '%)' AS col3
 , '1' AS col4
FROM race1

UNION ALL
SELECT
 '  Multiracial' AS [title]
 , CONVERT(VARCHAR, race06G1) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( race06G1 AS FLOAT) * 100/ NULLIF(totalG1,0), 0), 0))  + '%)' AS col1
 , CONVERT(VARCHAR, race06G2) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( race06G2 AS FLOAT) * 100/ NULLIF(totalG2,0), 0), 0))  + '%)' AS col2
 , CONVERT(VARCHAR, race06G3) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( race06G3 AS FLOAT) * 100/ NULLIF(totalG3,0), 0), 0))  + '%)' AS col3
 , '1' AS col4
FROM race1

UNION ALL
SELECT
 '  Other' AS [title]
 , CONVERT(VARCHAR, race07G1) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( race07G1 AS FLOAT) * 100/ NULLIF(totalG1,0), 0), 0))  + '%)' AS col1
 , CONVERT(VARCHAR, race07G2) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( race07G2 AS FLOAT) * 100/ NULLIF(totalG2,0), 0), 0))  + '%)' AS col2
 , CONVERT(VARCHAR, race07G3) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( race07G3 AS FLOAT) * 100/ NULLIF(totalG3,0), 0), 0))  + '%)' AS col3
 , '1' AS col4
FROM race1

UNION ALL
SELECT
 '  Missing' AS [title]
 , CONVERT(VARCHAR, race08G1) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( race08G1 AS FLOAT) * 100/ NULLIF(totalG1,0), 0), 0))  + '%)' AS col1
 , CONVERT(VARCHAR, race08G2) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( race08G2 AS FLOAT) * 100/ NULLIF(totalG2,0), 0), 0))  + '%)' AS col2
 , CONVERT(VARCHAR, race08G3) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( race08G3 AS FLOAT) * 100/ NULLIF(totalG3,0), 0), 0))  + '%)' AS col3
 , '1' AS col4
FROM race1

UNION ALL
SELECT '' AS [title], '' AS col1, '' AS col2, '' AS col3
 , '1' AS col4
)

, martial1 AS (
SELECT 
    SUM(CASE WHEN a.Status = '1' THEN 1 ELSE 0 END) AS totalG1
  , SUM(CASE WHEN a.Status = '2' THEN 1 ELSE 0 END) AS totalG2
  , SUM(CASE WHEN a.Status = '3' THEN 1 ELSE 0 END) AS totalG3

  , SUM(CASE WHEN MaritalStatus = '01' THEN 1 ELSE 0 END) AS MaritalStatus01
  , SUM(CASE WHEN a.Status = '1' and MaritalStatus = '01' THEN 1 ELSE 0 END) AS MaritalStatus01G1
  , SUM(CASE WHEN a.Status = '2' and MaritalStatus = '01' THEN 1 ELSE 0 END) AS MaritalStatus01G2
  , SUM(CASE WHEN a.Status = '3' and MaritalStatus = '01' THEN 1 ELSE 0 END) AS MaritalStatus01G3

  , SUM(CASE WHEN MaritalStatus = '02' THEN 1 ELSE 0 END) AS MaritalStatus02
  , SUM(CASE WHEN a.Status = '1' and MaritalStatus = '02' THEN 1 ELSE 0 END) AS MaritalStatus02G1
  , SUM(CASE WHEN a.Status = '2' and MaritalStatus = '02' THEN 1 ELSE 0 END) AS MaritalStatus02G2
  , SUM(CASE WHEN a.Status = '3' and MaritalStatus = '02' THEN 1 ELSE 0 END) AS MaritalStatus02G3

  , SUM(CASE WHEN MaritalStatus = '03' THEN 1 ELSE 0 END) AS MaritalStatus03
  , SUM(CASE WHEN a.Status = '1' and MaritalStatus = '03' THEN 1 ELSE 0 END) AS MaritalStatus03G1
  , SUM(CASE WHEN a.Status = '2' AND MaritalStatus = '03' THEN 1 ELSE 0 END) AS MaritalStatus03G2
  , SUM(CASE WHEN a.Status = '3' and MaritalStatus = '03' THEN 1 ELSE 0 END) AS MaritalStatus03G3

  , SUM(CASE WHEN MaritalStatus = '04' THEN 1 ELSE 0 END) AS MaritalStatus04
  , SUM(CASE WHEN a.Status = '1' and MaritalStatus = '04' THEN 1 ELSE 0 END) AS MaritalStatus04G1
  , SUM(CASE WHEN a.Status = '2' and MaritalStatus = '04' THEN 1 ELSE 0 END) AS MaritalStatus04G2
  , SUM(CASE WHEN a.Status = '3' and MaritalStatus = '04' THEN 1 ELSE 0 END) AS MaritalStatus04G3
  
  , SUM(CASE WHEN MaritalStatus = '05' THEN 1 ELSE 0 END) AS MaritalStatus05
  , SUM(CASE WHEN a.Status = '1' and MaritalStatus = '05' THEN 1 ELSE 0 END) AS MaritalStatus05G1
  , SUM(CASE WHEN a.Status = '2' and MaritalStatus = '05' THEN 1 ELSE 0 END) AS MaritalStatus05G2
  , SUM(CASE WHEN a.Status = '3' and MaritalStatus = '05' THEN 1 ELSE 0 END) AS MaritalStatus05G3

  , SUM(CASE WHEN (MaritalStatus IS NULL OR MaritalStatus NOT IN ('01', '02', '03', '04', '05')) THEN 1 ELSE 0 END) AS MaritalStatus06
  , SUM(CASE WHEN a.Status = '1' and (MaritalStatus IS NULL OR MaritalStatus NOT IN ('01', '02', '03', '04', '05')) THEN 1 ELSE 0 END) AS MaritalStatus06G1
  , SUM(CASE WHEN a.Status = '2' and (MaritalStatus IS NULL OR MaritalStatus NOT IN ('01', '02', '03', '04', '05')) THEN 1 ELSE 0 END) AS MaritalStatus06G2
  , SUM(CASE WHEN a.Status = '3' and (MaritalStatus IS NULL OR MaritalStatus NOT IN ('01', '02', '03', '04', '05')) THEN 1 ELSE 0 END) AS MaritalStatus06G3

  FROM #cteMain1 AS a
)


, martial2 AS (
SELECT 'Martial Status' AS [title], '' AS col1, '' AS col2, '' AS col3
 , '1' AS col4

UNION ALL
SELECT 
 '  Married' AS [title]
 , CONVERT(VARCHAR, MaritalStatus01G1) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( MaritalStatus01G1 AS FLOAT) * 100/ NULLIF(totalG1,0), 0), 0))  + '%)' AS col1
 , CONVERT(VARCHAR, MaritalStatus01G2) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( MaritalStatus01G2 AS FLOAT) * 100/ NULLIF(totalG2,0), 0), 0))  + '%)' AS col2
 , CONVERT(VARCHAR, MaritalStatus01G3) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( MaritalStatus01G3 AS FLOAT) * 100/ NULLIF(totalG3,0), 0), 0))  + '%)' AS col3
 , '1' AS col4
FROM martial1

UNION ALL
SELECT
 '  Not Married' AS [title]
 , CONVERT(VARCHAR, MaritalStatus02G1) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( MaritalStatus02G1 AS FLOAT) * 100/ NULLIF(totalG1,0), 0), 0))  + '%)' AS col1
 , CONVERT(VARCHAR, MaritalStatus02G2) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( MaritalStatus02G2 AS FLOAT) * 100/ NULLIF(totalG2,0), 0), 0))  + '%)' AS col2
 , CONVERT(VARCHAR, MaritalStatus02G3) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( MaritalStatus02G3 AS FLOAT) * 100/ NULLIF(totalG3,0), 0), 0))  + '%)' AS col3
 , '1' AS col4
FROM martial1

UNION ALL
SELECT
 '  Separated' AS [title]
 , CONVERT(VARCHAR, MaritalStatus03G1) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( MaritalStatus03G1 AS FLOAT) * 100/ NULLIF(totalG1,0), 0), 0))  + '%)' AS col1
 , CONVERT(VARCHAR, MaritalStatus03G2) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( MaritalStatus03G2 AS FLOAT) * 100/ NULLIF(totalG2,0), 0), 0))  + '%)' AS col2
 , CONVERT(VARCHAR, MaritalStatus03G3) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( MaritalStatus03G3 AS FLOAT) * 100/ NULLIF(totalG3,0), 0), 0))  + '%)' AS col3
 , '1' AS col4
FROM martial1

UNION ALL
SELECT
 '  Divorced' AS [title]
 , CONVERT(VARCHAR, MaritalStatus04G1) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( MaritalStatus04G1 AS FLOAT) * 100/ NULLIF(totalG1,0), 0), 0))  + '%)' AS col1
 , CONVERT(VARCHAR, MaritalStatus04G2) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( MaritalStatus04G2 AS FLOAT) * 100/ NULLIF(totalG2,0), 0), 0))  + '%)' AS col2
 , CONVERT(VARCHAR, MaritalStatus04G3) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( MaritalStatus04G3 AS FLOAT) * 100/ NULLIF(totalG3,0), 0), 0))  + '%)' AS col3
 , '1' AS col4
FROM martial1

UNION ALL
SELECT
 '  Widowed' AS [title]
 , CONVERT(VARCHAR, MaritalStatus05G1) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( MaritalStatus05G1 AS FLOAT) * 100/ NULLIF(totalG1,0), 0), 0))  + '%)' AS col1
 , CONVERT(VARCHAR, MaritalStatus05G2) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( MaritalStatus05G2 AS FLOAT) * 100/ NULLIF(totalG2,0), 0), 0))  + '%)' AS col2
 , CONVERT(VARCHAR, MaritalStatus05G3) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( MaritalStatus05G3 AS FLOAT) * 100/ NULLIF(totalG3,0), 0), 0))  + '%)' AS col3
 , '1' AS col4
FROM martial1

UNION ALL
SELECT
 '  Unknown' AS [title]
 , CONVERT(VARCHAR, MaritalStatus06G1) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( MaritalStatus06G1 AS FLOAT) * 100/ NULLIF(totalG1,0), 0), 0))  + '%)' AS col1
 , CONVERT(VARCHAR, MaritalStatus06G2) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( MaritalStatus06G2 AS FLOAT) * 100/ NULLIF(totalG2,0), 0), 0))  + '%)' AS col2
 , CONVERT(VARCHAR, MaritalStatus06G3) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( MaritalStatus06G3 AS FLOAT) * 100/ NULLIF(totalG3,0), 0), 0))  + '%)' AS col3
 , '1' AS col4
FROM martial1

UNION ALL
SELECT '' AS [title], '' AS col1, '' AS col2, '' AS col3
 , '1' AS col4
)

, edu1 AS (
SELECT 
    SUM(CASE WHEN a.Status = '1' THEN 1 ELSE 0 END) AS totalG1
  , SUM(CASE WHEN a.Status = '2' THEN 1 ELSE 0 END) AS totalG2
  , SUM(CASE WHEN a.Status = '3' THEN 1 ELSE 0 END) AS totalG3

  , SUM(CASE WHEN HighestGrade IN ('01','02') THEN 1 ELSE 0 END) AS HighestGrade01
  , SUM(CASE WHEN a.Status = '1' and HighestGrade IN ('01','02') THEN 1 ELSE 0 END) AS HighestGrade01G1
  , SUM(CASE WHEN a.Status = '2' and HighestGrade IN ('01','02') THEN 1 ELSE 0 END) AS HighestGrade01G2
  , SUM(CASE WHEN a.Status = '3' and HighestGrade IN ('01','02') THEN 1 ELSE 0 END) AS HighestGrade01G3

  , SUM(CASE WHEN HighestGrade IN ('03','04') THEN 1 ELSE 0 END) AS HighestGrade02
  , SUM(CASE WHEN a.Status = '1' and HighestGrade IN ('03','04') THEN 1 ELSE 0 END) AS HighestGrade02G1
  , SUM(CASE WHEN a.Status = '2' and HighestGrade IN ('03','04') THEN 1 ELSE 0 END) AS HighestGrade02G2
  , SUM(CASE WHEN a.Status = '3' and HighestGrade IN ('03','04') THEN 1 ELSE 0 END) AS HighestGrade02G3

  , SUM(CASE WHEN HighestGrade IN ('05','06','07','08') THEN 1 ELSE 0 END) AS HighestGrade03
  , SUM(CASE WHEN a.Status = '1' and HighestGrade IN ('05','06','07','08') THEN 1 ELSE 0 END) AS HighestGrade03G1
  , SUM(CASE WHEN a.Status = '2' AND HighestGrade IN ('05','06','07','08') THEN 1 ELSE 0 END) AS HighestGrade03G2
  , SUM(CASE WHEN a.Status = '3' and HighestGrade IN ('05','06','07','08') THEN 1 ELSE 0 END) AS HighestGrade03G3

  , SUM(CASE WHEN HighestGrade IS NULL THEN 1 ELSE 0 END) AS HighestGrade04
  , SUM(CASE WHEN a.Status = '1' and HighestGrade IS NULL THEN 1 ELSE 0 END) AS HighestGrade04G1
  , SUM(CASE WHEN a.Status = '2' and HighestGrade IS NULL THEN 1 ELSE 0 END) AS HighestGrade04G2
  , SUM(CASE WHEN a.Status = '3' and HighestGrade IS NULL THEN 1 ELSE 0 END) AS HighestGrade04G3
 
  FROM #cteMain1 AS a
)

, edu2 AS (
SELECT 'Education' AS [title], '' AS col1, '' AS col2, '' AS col3
 , '2' AS col4

UNION ALL
SELECT 
 '  Less than 12' AS [title]
 , CONVERT(VARCHAR, HighestGrade01G1) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( HighestGrade01G1 AS FLOAT) * 100/ NULLIF(totalG1,0), 0), 0))  + '%)' AS col1
 , CONVERT(VARCHAR, HighestGrade01G2) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( HighestGrade01G2 AS FLOAT) * 100/ NULLIF(totalG2,0), 0), 0))  + '%)' AS col2
 , CONVERT(VARCHAR, HighestGrade01G3) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( HighestGrade01G3 AS FLOAT) * 100/ NULLIF(totalG3,0), 0), 0))  + '%)' AS col3
 , '2' AS col4
FROM edu1

UNION ALL
SELECT
 '  HS/GED' AS [title]
 , CONVERT(VARCHAR, HighestGrade02G1) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( HighestGrade02G1 AS FLOAT) * 100/ NULLIF(totalG1,0), 0), 0))  + '%)' AS col1
 , CONVERT(VARCHAR, HighestGrade02G2) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( HighestGrade02G2 AS FLOAT) * 100/ NULLIF(totalG2,0), 0), 0))  + '%)' AS col2
 , CONVERT(VARCHAR, HighestGrade02G3) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( HighestGrade02G3 AS FLOAT) * 100/ NULLIF(totalG3,0), 0), 0))  + '%)' AS col3
 , '2' AS col4
FROM edu1

UNION ALL
SELECT
 '  More than 12' AS [title]
 , CONVERT(VARCHAR, HighestGrade03G1) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( HighestGrade03G1 AS FLOAT) * 100/ NULLIF(totalG1,0), 0), 0))  + '%)' AS col1
 , CONVERT(VARCHAR, HighestGrade03G2) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( HighestGrade03G2 AS FLOAT) * 100/ NULLIF(totalG2,0), 0), 0))  + '%)' AS col2
 , CONVERT(VARCHAR, HighestGrade03G3) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( HighestGrade03G3 AS FLOAT) * 100/ NULLIF(totalG3,0), 0), 0))  + '%)' AS col3
 , '2' AS col4
FROM edu1

UNION ALL
SELECT
 '  Unknown' AS [title]
 , CONVERT(VARCHAR, HighestGrade04G1) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( HighestGrade04G1 AS FLOAT) * 100/ NULLIF(totalG1,0), 0), 0))  + '%)' AS col1
 , CONVERT(VARCHAR, HighestGrade04G2) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( HighestGrade04G2 AS FLOAT) * 100/ NULLIF(totalG2,0), 0), 0))  + '%)' AS col2
 , CONVERT(VARCHAR, HighestGrade04G3) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( HighestGrade04G3 AS FLOAT) * 100/ NULLIF(totalG3,0), 0), 0))  + '%)' AS col3
 , '2' AS col4
FROM edu1

UNION ALL
SELECT '' AS [title], '' AS col1, '' AS col2, '' AS col3
 , '2' AS col4
)

, employed1 AS (
SELECT 
    SUM(CASE WHEN a.Status = '1' THEN 1 ELSE 0 END) AS totalG1
  , SUM(CASE WHEN a.Status = '2' THEN 1 ELSE 0 END) AS totalG2
  , SUM(CASE WHEN a.Status = '3' THEN 1 ELSE 0 END) AS totalG3

  , SUM(CASE WHEN IsCurrentlyEmployed = 1 THEN 1 ELSE 0 END) AS Employed01
  , SUM(CASE WHEN a.Status = '1' and IsCurrentlyEmployed = 1 THEN 1 ELSE 0 END) AS Employed01G1
  , SUM(CASE WHEN a.Status = '2' and IsCurrentlyEmployed = 1 THEN 1 ELSE 0 END) AS Employed01G2
  , SUM(CASE WHEN a.Status = '3' and IsCurrentlyEmployed = 1 THEN 1 ELSE 0 END) AS Employed01G3

  , SUM(CASE WHEN IsCurrentlyEmployed = 0 THEN 1 ELSE 0 END) AS Employed02
  , SUM(CASE WHEN a.Status = '1' and IsCurrentlyEmployed = 0 THEN 1 ELSE 0 END) AS Employed02G1
  , SUM(CASE WHEN a.Status = '2' and IsCurrentlyEmployed = 0 THEN 1 ELSE 0 END) AS Employed02G2
  , SUM(CASE WHEN a.Status = '3' and IsCurrentlyEmployed = 0 THEN 1 ELSE 0 END) AS Employed02G3

  FROM #cteMain1 AS a
)

, employed2 AS (
SELECT 'Employed' AS [title], '' AS col1, '' AS col2, '' AS col3
 , '2' AS col4

UNION ALL
SELECT 
 '  Yes' AS [title]
 , CONVERT(VARCHAR, Employed01G1) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( Employed01G1 AS FLOAT) * 100/ NULLIF(totalG1,0), 0), 0))  + '%)' AS col1
 , CONVERT(VARCHAR, Employed01G2) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( Employed01G2 AS FLOAT) * 100/ NULLIF(totalG2,0), 0), 0))  + '%)' AS col2
 , CONVERT(VARCHAR, Employed01G3) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( Employed01G3 AS FLOAT) * 100/ NULLIF(totalG3,0), 0), 0))  + '%)' AS col3
 , '2' AS col4
FROM employed1

UNION ALL
SELECT
 '  No' AS [title]
 , CONVERT(VARCHAR, Employed02G1) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( Employed02G1 AS FLOAT) * 100/ NULLIF(totalG1,0), 0), 0))  + '%)' AS col1
 , CONVERT(VARCHAR, Employed02G2) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( Employed02G2 AS FLOAT) * 100/ NULLIF(totalG2,0), 0), 0))  + '%)' AS col2
 , CONVERT(VARCHAR, Employed02G3) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( Employed02G3 AS FLOAT) * 100/ NULLIF(totalG3,0), 0), 0))  + '%)' AS col3
 , '2' AS col4
FROM employed1

UNION ALL
SELECT '' AS [title], '' AS col1, '' AS col2, '' AS col3
 , '2' AS col4
)
 
, inHome1 AS (
SELECT 
    SUM(CASE WHEN a.Status = '1' THEN 1 ELSE 0 END) AS totalG1
  , SUM(CASE WHEN a.Status = '2' THEN 1 ELSE 0 END) AS totalG2
  , SUM(CASE WHEN a.Status = '3' THEN 1 ELSE 0 END) AS totalG3

  , SUM(CASE WHEN OBPInHome = 1 THEN 1 ELSE 0 END) AS InHome01
  , SUM(CASE WHEN a.Status = '1' and OBPInHome = 1 THEN 1 ELSE 0 END) AS InHome01G1
  , SUM(CASE WHEN a.Status = '2' and OBPInHome = 1 THEN 1 ELSE 0 END) AS InHome01G2
  , SUM(CASE WHEN a.Status = '3' and OBPInHome = 1 THEN 1 ELSE 0 END) AS InHome01G3

  , SUM(CASE WHEN OBPInHome = 0 THEN 1 ELSE 0 END) AS InHome02
  , SUM(CASE WHEN a.Status = '1' and OBPInHome = 0 THEN 1 ELSE 0 END) AS InHome02G1
  , SUM(CASE WHEN a.Status = '2' and OBPInHome = 0 THEN 1 ELSE 0 END) AS InHome02G2
  , SUM(CASE WHEN a.Status = '3' and OBPInHome = 0 THEN 1 ELSE 0 END) AS InHome02G3

  
  , SUM(CASE WHEN OBPInHome IS NULL THEN 1 ELSE 0 END) AS InHome03
  , SUM(CASE WHEN a.Status = '1' and OBPInHome IS NULL THEN 1 ELSE 0 END) AS InHome03G1
  , SUM(CASE WHEN a.Status = '2' and OBPInHome IS NULL THEN 1 ELSE 0 END) AS InHome03G2
  , SUM(CASE WHEN a.Status = '3' and OBPInHome IS NULL THEN 1 ELSE 0 END) AS InHome03G3
  FROM #cteMain1 AS a
)

, inHome2 AS (
SELECT 'Bio Father in Home' AS [title], '' AS col1, '' AS col2, '' AS col3
 , '2' AS col4
UNION ALL
SELECT 
 '  Yes' AS [title]
 , CONVERT(VARCHAR, InHome01G1) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( InHome01G1 AS FLOAT) * 100/ NULLIF(totalG1,0), 0), 0))  + '%)' AS col1
 , CONVERT(VARCHAR, InHome01G2) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( InHome01G2 AS FLOAT) * 100/ NULLIF(totalG2,0), 0), 0))  + '%)' AS col2
 , CONVERT(VARCHAR, InHome01G3) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( InHome01G3 AS FLOAT) * 100/ NULLIF(totalG3,0), 0), 0))  + '%)' AS col3
 , '2' AS col4
FROM inHome1

UNION ALL
SELECT
 '  No' AS [title]
 , CONVERT(VARCHAR, InHome02G1) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( InHome02G1 AS FLOAT) * 100/ NULLIF(totalG1,0), 0), 0))  + '%)' AS col1
 , CONVERT(VARCHAR, InHome02G2) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( InHome02G2 AS FLOAT) * 100/ NULLIF(totalG2,0), 0), 0))  + '%)' AS col2
 , CONVERT(VARCHAR, InHome02G3) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( InHome02G3 AS FLOAT) * 100/ NULLIF(totalG3,0), 0), 0))  + '%)' AS col3
 , '2' AS col4
FROM inHome1

UNION ALL
SELECT
 '  Unknown' AS [title]
 , CONVERT(VARCHAR, InHome03G1) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( InHome03G1 AS FLOAT) * 100/ NULLIF(totalG1,0), 0), 0))  + '%)' AS col1
 , CONVERT(VARCHAR, InHome03G2) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( InHome03G2 AS FLOAT) * 100/ NULLIF(totalG2,0), 0), 0))  + '%)' AS col2
 , CONVERT(VARCHAR, InHome03G3) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( InHome03G3 AS FLOAT) * 100/ NULLIF(totalG3,0), 0), 0))  + '%)' AS col3
 , '2' AS col4
FROM inHome1

UNION ALL
SELECT '' AS [title], '' AS col1, '' AS col2, '' AS col3
 , '2' AS col4
)

, score1 AS (
SELECT 
    SUM(CASE WHEN a.Status = '1' THEN 1 ELSE 0 END) AS totalG1
  , SUM(CASE WHEN a.Status = '2' THEN 1 ELSE 0 END) AS totalG2
  , SUM(CASE WHEN a.Status = '3' THEN 1 ELSE 0 END) AS totalG3

  , SUM(CASE WHEN MomScore >= 25 AND DadScore < 25 THEN 1 ELSE 0 END) AS Score01
  , SUM(CASE WHEN a.Status = '1' and MomScore >= 25 AND DadScore < 25 THEN 1 ELSE 0 END) AS Score01G1
  , SUM(CASE WHEN a.Status = '2' and MomScore >= 25 AND DadScore < 25 THEN 1 ELSE 0 END) AS Score01G2
  , SUM(CASE WHEN a.Status = '3' and MomScore >= 25 AND DadScore < 25 THEN 1 ELSE 0 END) AS Score01G3

  , SUM(CASE WHEN MomScore < 25 AND DadScore >= 25 THEN 1 ELSE 0 END) AS Score02
  , SUM(CASE WHEN a.Status = '1' and MomScore < 25 AND DadScore >= 25 THEN 1 ELSE 0 END) AS Score02G1
  , SUM(CASE WHEN a.Status = '2' and MomScore < 25 AND DadScore >= 25 THEN 1 ELSE 0 END) AS Score02G2
  , SUM(CASE WHEN a.Status = '3' and MomScore < 25 AND DadScore >= 25 THEN 1 ELSE 0 END) AS Score02G3

  
  , SUM(CASE WHEN MomScore >= 25 AND DadScore >= 25 THEN 1 ELSE 0 END) AS Score03
  , SUM(CASE WHEN a.Status = '1' and MomScore >= 25 AND DadScore >= 25 THEN 1 ELSE 0 END) AS Score03G1
  , SUM(CASE WHEN a.Status = '2' and MomScore >= 25 AND DadScore >= 25 THEN 1 ELSE 0 END) AS Score03G2
  , SUM(CASE WHEN a.Status = '3' and MomScore >= 25 AND DadScore >= 25 THEN 1 ELSE 0 END) AS Score03G3
  FROM #cteMain1 AS a
)


, score2 AS (
SELECT 'Whose Score Qualifies' AS [title], '' AS col1, '' AS col2, '' AS col3
 , '2' AS col4
UNION ALL
SELECT 
 '  Mother' AS [title]
 , CONVERT(VARCHAR, Score01G1) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( Score01G1 AS FLOAT) * 100/ NULLIF(totalG1,0), 0), 0))  + '%)' AS col1
 , CONVERT(VARCHAR, Score01G2) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( Score01G2 AS FLOAT) * 100/ NULLIF(totalG2,0), 0), 0))  + '%)' AS col2
 , CONVERT(VARCHAR, Score01G3) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( Score01G3 AS FLOAT) * 100/ NULLIF(totalG3,0), 0), 0))  + '%)' AS col3
 , '2' AS col4
FROM score1

UNION ALL
SELECT
 '  Father' AS [title]
 , CONVERT(VARCHAR, Score02G1) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( Score02G1 AS FLOAT) * 100/ NULLIF(totalG1,0), 0), 0))  + '%)' AS col1
 , CONVERT(VARCHAR, Score02G2) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( Score02G2 AS FLOAT) * 100/ NULLIF(totalG2,0), 0), 0))  + '%)' AS col2
 , CONVERT(VARCHAR, Score02G3) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( Score02G3 AS FLOAT) * 100/ NULLIF(totalG3,0), 0), 0))  + '%)' AS col3
 , '2' AS col4
FROM score1

UNION ALL
SELECT
 '  Mother & Father' AS [title]
 , CONVERT(VARCHAR, Score03G1) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( Score03G1 AS FLOAT) * 100/ NULLIF(totalG1,0), 0), 0))  + '%)' AS col1
 , CONVERT(VARCHAR, Score03G2) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( Score03G2 AS FLOAT) * 100/ NULLIF(totalG2,0), 0), 0))  + '%)' AS col2
 , CONVERT(VARCHAR, Score03G3) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( Score03G3 AS FLOAT) * 100/ NULLIF(totalG3,0), 0), 0))  + '%)' AS col3
 , '2' AS col4
FROM score1

UNION ALL
SELECT '' AS [title], '' AS col1, '' AS col2, '' AS col3
 , '2' AS col4
)

, kempescore1 AS (
SELECT 
    SUM(CASE WHEN a.Status = '1' THEN 1 ELSE 0 END) AS totalG1
  , SUM(CASE WHEN a.Status = '2' THEN 1 ELSE 0 END) AS totalG2
  , SUM(CASE WHEN a.Status = '3' THEN 1 ELSE 0 END) AS totalG3

  , SUM(CASE WHEN KempeScore BETWEEN  25 AND 49 THEN 1 ELSE 0 END) AS KempeScore01
  , SUM(CASE WHEN a.Status = '1' and KempeScore BETWEEN  25 AND 49 THEN 1 ELSE 0 END) AS KempeScore01G1
  , SUM(CASE WHEN a.Status = '2' and KempeScore BETWEEN  25 AND 49 THEN 1 ELSE 0 END) AS KempeScore01G2
  , SUM(CASE WHEN a.Status = '3' and KempeScore BETWEEN  25 AND 49 THEN 1 ELSE 0 END) AS KempeScore01G3

  , SUM(CASE WHEN KempeScore BETWEEN  50 AND 74 THEN 1 ELSE 0 END) AS KempeScore02
  , SUM(CASE WHEN a.Status = '1' and KempeScore BETWEEN  50 AND 74 THEN 1 ELSE 0 END) AS KempeScore02G1
  , SUM(CASE WHEN a.Status = '2' and KempeScore BETWEEN  50 AND 74 THEN 1 ELSE 0 END) AS KempeScore02G2
  , SUM(CASE WHEN a.Status = '3' and KempeScore BETWEEN  50 AND 74 THEN 1 ELSE 0 END) AS KempeScore02G3

  
  , SUM(CASE WHEN KempeScore >= 75 THEN 1 ELSE 0 END) AS KempeScore03
  , SUM(CASE WHEN a.Status = '1' and KempeScore >= 75 THEN 1 ELSE 0 END) AS KempeScore03G1
  , SUM(CASE WHEN a.Status = '2' and KempeScore >= 75 THEN 1 ELSE 0 END) AS KempeScore03G2
  , SUM(CASE WHEN a.Status = '3' and KempeScore >= 75 THEN 1 ELSE 0 END) AS KempeScore03G3
  FROM #cteMain1 AS a
)


, kempescore2 AS (
SELECT 'Kempe Score' AS [title], '' AS col1, '' AS col2, '' AS col3
 , '2' AS col4
UNION ALL
SELECT 
 '  25-49' AS [title]
 , CONVERT(VARCHAR, KempeScore01G1) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( KempeScore01G1 AS FLOAT) * 100/ NULLIF(totalG1,0), 0), 0))  + '%)' AS col1
 , CONVERT(VARCHAR, KempeScore01G2) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( KempeScore01G2 AS FLOAT) * 100/ NULLIF(totalG2,0), 0), 0))  + '%)' AS col2
 , CONVERT(VARCHAR, KempeScore01G3) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( KempeScore01G3 AS FLOAT) * 100/ NULLIF(totalG3,0), 0), 0))  + '%)' AS col3
 , '2' AS col4
FROM kempescore1

UNION ALL
SELECT
 '  50-74' AS [title]
 , CONVERT(VARCHAR, KempeScore02G1) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( KempeScore02G1 AS FLOAT) * 100/ NULLIF(totalG1,0), 0), 0))  + '%)' AS col1
 , CONVERT(VARCHAR, KempeScore02G2) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( KempeScore02G2 AS FLOAT) * 100/ NULLIF(totalG2,0), 0), 0))  + '%)' AS col2
 , CONVERT(VARCHAR, KempeScore02G3) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( KempeScore02G3 AS FLOAT) * 100/ NULLIF(totalG3,0), 0), 0))  + '%)' AS col3
 , '2' AS col4
FROM kempescore1


UNION ALL
SELECT
 '  75+' AS [title]
 , CONVERT(VARCHAR, KempeScore03G1) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( KempeScore03G1 AS FLOAT) * 100/ NULLIF(totalG1,0), 0), 0))  + '%)' AS col1
 , CONVERT(VARCHAR, KempeScore03G2) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( KempeScore03G2 AS FLOAT) * 100/ NULLIF(totalG2,0), 0), 0))  + '%)' AS col2
 , CONVERT(VARCHAR, KempeScore03G3) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( KempeScore03G3 AS FLOAT) * 100/ NULLIF(totalG3,0), 0), 0))  + '%)' AS col3
 , '2' AS col4
FROM kempescore1

UNION ALL
SELECT '' AS [title], '' AS col1, '' AS col2, '' AS col3
 , '2' AS col4
)

, issues1 AS (
SELECT 
    SUM(CASE WHEN a.Status = '1' THEN 1 ELSE 0 END) AS totalG1
  , SUM(CASE WHEN a.Status = '2' THEN 1 ELSE 0 END) AS totalG2
  , SUM(CASE WHEN a.Status = '3' THEN 1 ELSE 0 END) AS totalG3

  , SUM(CASE WHEN DV = 1 THEN 1 ELSE 0 END) AS issues01
  , SUM(CASE WHEN a.Status = '1' and DV = 1 THEN 1 ELSE 0 END) AS issues01G1
  , SUM(CASE WHEN a.Status = '2' and DV = 1 THEN 1 ELSE 0 END) AS issues01G2
  , SUM(CASE WHEN a.Status = '3' and DV = 1 THEN 1 ELSE 0 END) AS issues01G3

  , SUM(CASE WHEN MH = 1 THEN 1 ELSE 0 END) AS issues02
  , SUM(CASE WHEN a.Status = '1' and MH = 1 THEN 1 ELSE 0 END) AS issues02G1
  , SUM(CASE WHEN a.Status = '2' and MH = 1 THEN 1 ELSE 0 END) AS issues02G2
  , SUM(CASE WHEN a.Status = '3' and MH = 1 THEN 1 ELSE 0 END) AS issues02G3

  
  , SUM(CASE WHEN SA = 1 THEN 1 ELSE 0 END) AS issues03
  , SUM(CASE WHEN a.Status = '1' and SA = 1 THEN 1 ELSE 0 END) AS issues03G1
  , SUM(CASE WHEN a.Status = '2' and SA = 1 THEN 1 ELSE 0 END) AS issues03G2
  , SUM(CASE WHEN a.Status = '3' and SA = 1 THEN 1 ELSE 0 END) AS issues03G3
  FROM #cteMain1 AS a
)

, issues2 AS (
SELECT 'PC1 Issues' AS [title], '' AS col1, '' AS col2, '' AS col3
 , '3' AS col4
UNION ALL
SELECT 
 '  DV' AS [title]
 , CONVERT(VARCHAR, issues01G1) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( issues01G1 AS FLOAT) * 100/ NULLIF(totalG1,0), 0), 0))  + '%)' AS col1
 , CONVERT(VARCHAR, issues01G2) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( issues01G2 AS FLOAT) * 100/ NULLIF(totalG2,0), 0), 0))  + '%)' AS col2
 , CONVERT(VARCHAR, issues01G3) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( issues01G3 AS FLOAT) * 100/ NULLIF(totalG3,0), 0), 0))  + '%)' AS col3
 , '3' AS col4
FROM issues1

UNION ALL
SELECT
 '  MH' AS [title]
 , CONVERT(VARCHAR, issues02G1) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( issues02G1 AS FLOAT) * 100/ NULLIF(totalG1,0), 0), 0))  + '%)' AS col1
 , CONVERT(VARCHAR, issues02G2) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( issues02G2 AS FLOAT) * 100/ NULLIF(totalG2,0), 0), 0))  + '%)' AS col2
 , CONVERT(VARCHAR, issues02G3) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( issues02G3 AS FLOAT) * 100/ NULLIF(totalG3,0), 0), 0))  + '%)' AS col3
 , '3' AS col4
FROM issues1

UNION ALL
SELECT
 '  SA' AS [title]
 , CONVERT(VARCHAR, issues03G1) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( issues03G1 AS FLOAT) * 100/ NULLIF(totalG1,0), 0), 0))  + '%)' AS col1
 , CONVERT(VARCHAR, issues03G2) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( issues03G2 AS FLOAT) * 100/ NULLIF(totalG2,0), 0), 0))  + '%)' AS col2
 , CONVERT(VARCHAR, issues03G3) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( issues03G3 AS FLOAT) * 100/ NULLIF(totalG3,0), 0), 0))  + '%)' AS col3
 , '3' AS col4
FROM issues1

UNION ALL
SELECT '' AS [title], '' AS col1, '' AS col2, '' AS col3
 , '3' AS col4
)

, trimester1 AS (
SELECT 
    SUM(CASE WHEN a.Status = '1' THEN 1 ELSE 0 END) AS totalG1
  , SUM(CASE WHEN a.Status = '2' THEN 1 ELSE 0 END) AS totalG2
  , SUM(CASE WHEN a.Status = '3' THEN 1 ELSE 0 END) AS totalG3

  , SUM(CASE WHEN Trimester = 1 THEN 1 ELSE 0 END) AS trimester01
  , SUM(CASE WHEN a.Status = '1' and Trimester = 1 THEN 1 ELSE 0 END) AS trimester01G1
  , SUM(CASE WHEN a.Status = '2' and Trimester = 1 THEN 1 ELSE 0 END) AS trimester01G2
  , SUM(CASE WHEN a.Status = '3' and Trimester = 1 THEN 1 ELSE 0 END) AS trimester01G3

  , SUM(CASE WHEN Trimester = 2 THEN 1 ELSE 0 END) AS trimester02
  , SUM(CASE WHEN a.Status = '1' and Trimester = 2 THEN 1 ELSE 0 END) AS trimester02G1
  , SUM(CASE WHEN a.Status = '2' and Trimester = 2 THEN 1 ELSE 0 END) AS trimester02G2
  , SUM(CASE WHEN a.Status = '3' and Trimester = 2 THEN 1 ELSE 0 END) AS trimester02G3

  , SUM(CASE WHEN Trimester = 3 THEN 1 ELSE 0 END) AS trimester03
  , SUM(CASE WHEN a.Status = '1' and Trimester = 3 THEN 1 ELSE 0 END) AS trimester03G1
  , SUM(CASE WHEN a.Status = '2' AND Trimester = 3 THEN 1 ELSE 0 END) AS trimester03G2
  , SUM(CASE WHEN a.Status = '3' and Trimester = 3 THEN 1 ELSE 0 END) AS trimester03G3

  , SUM(CASE WHEN Trimester = 4 THEN 1 ELSE 0 END) AS trimester04
  , SUM(CASE WHEN a.Status = '1' and Trimester = 4 THEN 1 ELSE 0 END) AS trimester04G1
  , SUM(CASE WHEN a.Status = '2' and Trimester = 4 THEN 1 ELSE 0 END) AS trimester04G2
  , SUM(CASE WHEN a.Status = '3' and Trimester = 4 THEN 1 ELSE 0 END) AS trimester04G3
 
  FROM #cteMain1 AS a
)

, trimester2 AS (
SELECT 'Trimester (at time of Enrollment/Discharge)' AS [title], '' AS col1, '' AS col2, '' AS col3
 , '3' AS col4
UNION ALL
SELECT 
 '  1st' AS [title]
 , CONVERT(VARCHAR, trimester01G1) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( trimester01G1 AS FLOAT) * 100/ NULLIF(totalG1,0), 0), 0))  + '%)' AS col1
 , CONVERT(VARCHAR, trimester01G2) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( trimester01G2 AS FLOAT) * 100/ NULLIF(totalG2,0), 0), 0))  + '%)' AS col2
 , CONVERT(VARCHAR, trimester01G3) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( trimester01G3 AS FLOAT) * 100/ NULLIF(totalG3,0), 0), 0))  + '%)' AS col3
 , '3' AS col4
FROM trimester1

UNION ALL
SELECT
 '  2nd' AS [title]
 , CONVERT(VARCHAR, trimester02G1) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( trimester02G1 AS FLOAT) * 100/ NULLIF(totalG1,0), 0), 0))  + '%)' AS col1
 , CONVERT(VARCHAR, trimester02G2) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( trimester02G2 AS FLOAT) * 100/ NULLIF(totalG2,0), 0), 0))  + '%)' AS col2
 , CONVERT(VARCHAR, trimester02G3) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( trimester02G3 AS FLOAT) * 100/ NULLIF(totalG3,0), 0), 0))  + '%)' AS col3
 , '3' AS col4
FROM trimester1

UNION ALL
SELECT
 '  3rd' AS [title]
 , CONVERT(VARCHAR, trimester03G1) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( trimester03G1 AS FLOAT) * 100/ NULLIF(totalG1,0), 0), 0))  + '%)' AS col1
 , CONVERT(VARCHAR, trimester03G2) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( trimester03G2 AS FLOAT) * 100/ NULLIF(totalG2,0), 0), 0))  + '%)' AS col2
 , CONVERT(VARCHAR, trimester03G3) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( trimester03G3 AS FLOAT) * 100/ NULLIF(totalG3,0), 0), 0))  + '%)' AS col3
 , '3' AS col4
FROM trimester1

UNION ALL
SELECT
 '  Postnatal' AS [title]
 , CONVERT(VARCHAR, trimester04G1) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( trimester04G1 AS FLOAT) * 100/ NULLIF(totalG1,0), 0), 0))  + '%)' AS col1
 , CONVERT(VARCHAR, trimester04G2) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( trimester04G2 AS FLOAT) * 100/ NULLIF(totalG2,0), 0), 0))  + '%)' AS col2
 , CONVERT(VARCHAR, trimester04G3) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( trimester04G3 AS FLOAT) * 100/ NULLIF(totalG3,0), 0), 0))  + '%)' AS col3
 , '3' AS col4
FROM trimester1

UNION ALL
SELECT '' AS [title], '' AS col1, '' AS col2, '' AS col3
 , '3' AS col4
)

, assessment1 AS (
SELECT 
    SUM(CASE WHEN a.Status = '1' THEN 1 ELSE 0 END) AS totalG1
  , SUM(CASE WHEN a.Status = '2' THEN 1 ELSE 0 END) AS totalG2
  , SUM(CASE WHEN a.Status = '3' THEN 1 ELSE 0 END) AS totalG3

  , SUM(CASE WHEN presentCode = 1 THEN 1 ELSE 0 END) AS assessment01
  , SUM(CASE WHEN a.Status = '1' and presentCode = 1 THEN 1 ELSE 0 END) AS assessment01G1
  , SUM(CASE WHEN a.Status = '2' and presentCode = 1 THEN 1 ELSE 0 END) AS assessment01G2
  , SUM(CASE WHEN a.Status = '3' and presentCode = 1 THEN 1 ELSE 0 END) AS assessment01G3

  , SUM(CASE WHEN presentCode = 2 THEN 1 ELSE 0 END) AS assessment02
  , SUM(CASE WHEN a.Status = '1' and presentCode = 2 THEN 1 ELSE 0 END) AS assessment02G1
  , SUM(CASE WHEN a.Status = '2' and presentCode = 2 THEN 1 ELSE 0 END) AS assessment02G2
  , SUM(CASE WHEN a.Status = '3' and presentCode = 2 THEN 1 ELSE 0 END) AS assessment02G3

  , SUM(CASE WHEN presentCode = 3 THEN 1 ELSE 0 END) AS assessment03
  , SUM(CASE WHEN a.Status = '1' and presentCode = 3 THEN 1 ELSE 0 END) AS assessment03G1
  , SUM(CASE WHEN a.Status = '2' AND presentCode = 3 THEN 1 ELSE 0 END) AS assessment03G2
  , SUM(CASE WHEN a.Status = '3' and presentCode = 3 THEN 1 ELSE 0 END) AS assessment03G3

  , SUM(CASE WHEN presentCode = 4 THEN 1 ELSE 0 END) AS assessment04
  , SUM(CASE WHEN a.Status = '1' and presentCode = 4 THEN 1 ELSE 0 END) AS assessment04G1
  , SUM(CASE WHEN a.Status = '2' and presentCode = 4 THEN 1 ELSE 0 END) AS assessment04G2
  , SUM(CASE WHEN a.Status = '3' and presentCode = 4 THEN 1 ELSE 0 END) AS assessment04G3
 
  FROM #cteMain1 AS a
)

, assessment2 AS (
SELECT 'Present at Assessment' AS [title], '' AS col1, '' AS col2, '' AS col3
 , '3' AS col4
UNION ALL
SELECT 
 '  MOB only' AS [title]
 , CONVERT(VARCHAR, assessment01G1) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( assessment01G1 AS FLOAT) * 100/ NULLIF(totalG1,0), 0), 0))  + '%)' AS col1
 , CONVERT(VARCHAR, assessment01G2) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( assessment01G2 AS FLOAT) * 100/ NULLIF(totalG2,0), 0), 0))  + '%)' AS col2
 , CONVERT(VARCHAR, assessment01G3) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( assessment01G3 AS FLOAT) * 100/ NULLIF(totalG3,0), 0), 0))  + '%)' AS col3
 , '3' AS col4
FROM assessment1

UNION ALL
SELECT
 '  FOB Only' AS [title]
 , CONVERT(VARCHAR, assessment02G1) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( assessment02G1 AS FLOAT) * 100/ NULLIF(totalG1,0), 0), 0))  + '%)' AS col1
 , CONVERT(VARCHAR, assessment02G2) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( assessment02G2 AS FLOAT) * 100/ NULLIF(totalG2,0), 0), 0))  + '%)' AS col2
 , CONVERT(VARCHAR, assessment02G3) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( assessment02G3 AS FLOAT) * 100/ NULLIF(totalG3,0), 0), 0))  + '%)' AS col3
 , '3' AS col4
FROM assessment1

UNION ALL
SELECT
 '  Both Parents' AS [title]
 , CONVERT(VARCHAR, assessment03G1) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( assessment03G1 AS FLOAT) * 100/ NULLIF(totalG1,0), 0), 0))  + '%)' AS col1
 , CONVERT(VARCHAR, assessment03G2) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( assessment03G2 AS FLOAT) * 100/ NULLIF(totalG2,0), 0), 0))  + '%)' AS col2
 , CONVERT(VARCHAR, assessment03G3) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( assessment03G3 AS FLOAT) * 100/ NULLIF(totalG3,0), 0), 0))  + '%)' AS col3
 , '3' AS col4
FROM assessment1

UNION ALL
SELECT
 '  Parent and Other' AS [title]
 , CONVERT(VARCHAR, assessment04G1) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( assessment04G1 AS FLOAT) * 100/ NULLIF(totalG1,0), 0), 0))  + '%)' AS col1
 , CONVERT(VARCHAR, assessment04G2) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( assessment04G2 AS FLOAT) * 100/ NULLIF(totalG2,0), 0), 0))  + '%)' AS col2
 , CONVERT(VARCHAR, assessment04G3) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( assessment04G3 AS FLOAT) * 100/ NULLIF(totalG3,0), 0), 0))  + '%)' AS col3
 , '3' AS col4
FROM assessment1

UNION ALL
SELECT '' AS [title], '' AS col1, '' AS col2, '' AS col3
 , '3' AS col4
)

, refused1 AS (
SELECT 
	COUNT(*) AS totalG3
	,sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) [Refused]
	,sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) [UnableToLocate]
	,sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) [TCAgedOut]
	,sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) [OutOfTargetArea]
	,sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) [Transfered]
	,sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25')  THEN 1 ELSE 0 END) [AllOthers]
FROM #cteMain1 AS a
WHERE a.Status = '3'

)
, 

refused2 AS (

SELECT 'Reason for Refused' AS [title], '' AS col1, '' AS col2, '' AS col3
 , '3' AS col4
UNION ALL
SELECT
 '  Refused' AS [title]
 , '' AS col1, '' AS col2
 , CONVERT(VARCHAR, Refused) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( Refused AS FLOAT) * 100/ NULLIF(totalG3,0), 0), 0))  + '%)' AS col3
 , '3' AS col4
FROM refused1

UNION ALL
SELECT
 '  Unable To Locate' AS [title]
 , '' AS col1, '' AS col2
 , CONVERT(VARCHAR, UnableToLocate) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( UnableToLocate AS FLOAT) * 100/ NULLIF(totalG3,0), 0), 0))  + '%)' AS col3
 , '3' AS col4
FROM refused1

UNION ALL
SELECT
 '  TC Aged Out' AS [title]
 , '' AS col1, '' AS col2
 , CONVERT(VARCHAR, TCAgedOut) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( TCAgedOut AS FLOAT) * 100/ NULLIF(totalG3,0), 0), 0))  + '%)' AS col3
 , '3' AS col4
FROM refused1

UNION ALL
SELECT
 '  Out of Target Area' AS [title]
 , '' AS col1, '' AS col2
 , CONVERT(VARCHAR, OutOfTargetArea) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( OutOfTargetArea AS FLOAT) * 100/ NULLIF(totalG3,0), 0), 0))  + '%)' AS col3
 , '3' AS col4
FROM refused1

UNION ALL
SELECT
 '  Transfered' AS [title]
 , '' AS col1, '' AS col2
 , CONVERT(VARCHAR, Transfered) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( Transfered AS FLOAT) * 100/ NULLIF(totalG3,0), 0), 0))  + '%)' AS col3
 , '3' AS col4
FROM refused1

UNION ALL
SELECT
 '  All Others' AS [title]
 , '' AS col1, '' AS col2
 , CONVERT(VARCHAR, AllOthers) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( AllOthers AS FLOAT) * 100/ NULLIF(totalG3,0), 0), 0))  + '%)' AS col3
 , '3' AS col4
FROM refused1

UNION ALL
SELECT '' AS [title], '' AS col1, '' AS col2, '' AS col3
 , '3' AS col4
),

rpt1 AS (
SELECT * FROM total2
UNION ALL
SELECT * FROM total3
UNION ALL
SELECT * FROM age2
UNION ALL
SELECT * FROM race2
UNION ALL
SELECT * FROM martial2
UNION ALL 
SELECT * FROM edu2
UNION ALL
SELECT * FROM employed2
UNION ALL 
SELECT * FROM inHome2
UNION ALL
SELECT * FROM score2
UNION ALL 
SELECT * FROM kempescore2
UNION ALL
SELECT * FROM issues2
UNION ALL 
SELECT * FROM trimester2
UNION ALL
SELECT * FROM assessment2
UNION ALL
SELECT * FROM refused2
)

-- listing records
--SELECT * 
--FROM main1 AS a
--WHERE a.Status = 3

SELECT title AS [Title]
, col1 AS [AcceptedFirstVisitEnrolled]
, col2 AS [AcceptedFirstVisitNotEnrolled]
, col3 AS [Refused]
, col4 AS [groupID]
FROM rpt1

drop table #cteMain
drop table #cteMain1
GO
