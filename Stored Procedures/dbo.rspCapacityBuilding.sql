SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:    dar chen
-- Create date: Feb/25/2015
-- Description: <Report: Capacity Building>
-- =============================================
CREATE procedure [dbo].[rspCapacityBuilding]
(
    @startDt    DATE,
    @endDT      DATE,
    @ProgramFK varchar(max) = null
)
as

--DECLARE @startDT DATE = '02/25/2014'
--DECLARE @endDT DATE = '08/25/2014'
--DECLARE @ProgramFK varchar(max) = '1'

DECLARE @defaultDT DATE = CONVERT(DATE,DATEADD(MS, -3, DATEADD(MM, DATEDIFF(MM, 0, @startDT) , 0)))

SET @endDT = CONVERT(DATE,DATEADD(MS, -3, DATEADD(MM, DATEDIFF(MM, 0, @defaultDT) - 2 , 0)))
SET @startDT = CONVERT(DATE,DATEADD(MS, 0, DATEADD(MM, DATEDIFF(MM, 0, @defaultDT) - 14 , 0)))

DECLARE @endDTRetention DATE = CONVERT(DATE,DATEADD(MS, -3, DATEADD(MM, DATEDIFF(MM, 0, @defaultDT) - 11 , 0)))
DECLARE @startDTRetention DATE = CONVERT(DATE,DATEADD(MS, 0, DATEADD(MM, DATEDIFF(MM, 0, @defaultDT) - 23 , 0)))

DECLARE @endDT3 DATE = @defaultDT
DECLARE @startDT3 DATE = CONVERT(DATE,DATEADD(MS, 0, DATEADD(MM, DATEDIFF(MM, 0, @endDT3) , 0)))

DECLARE @endDT2 DATE = CONVERT(DATE,DATEADD(MS, -3, DATEADD(MM, DATEDIFF(MM, 0, @defaultDT) - 0 , 0)))
DECLARE @startDT2 DATE = CONVERT(DATE,DATEADD(MS, 0, DATEADD(MM, DATEDIFF(MM, 0, @defaultDT) - 1 , 0)))

DECLARE @endDT1 DATE = CONVERT(DATE,DATEADD(MS, -3, DATEADD(MM, DATEDIFF(MM, 0, @defaultDT) - 1 , 0)))
DECLARE @startDT1 DATE = CONVERT(DATE,DATEADD(MS, 0, DATEADD(MM, DATEDIFF(MM, 0, @defaultDT) - 2 , 0)))


	set nocount on;

	-- Insert statements for procedure here
	if @ProgramFK is null
	begin
		select @ProgramFK =
			   substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
						from HVProgram for xml path ('')),2,8000)
	end
	set @ProgramFK = REPLACE(@ProgramFK,'"','')
	
	;
	with 

	ctemainAgain
	as
	(
	select pc1id
		  ,case when levelname in ('Preintake','Preintake-enroll') then 1 else 0 end as PreintakeCount
		  ,CaseProgram.ProgramFK
		  ,ProgramCapacity
		from
			(select * from codeLevel where caseweight is not null) cl
			left outer join caseprogram on caseprogram.currentLevelFK = cl.codeLevelPK
			inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
			inner join worker on caseprogram.currentFSWFK = worker.workerpk
			inner join workerprogram wp on wp.workerfk = worker.workerpk AND wp.programfk = listitem
			left outer join (select workerpk ,firstName as supfname
							,LastName as suplname from worker) sw on wp.supervisorfk = sw.workerpk
			left outer join HVProgram h on h.HVProgramPK = CaseProgram.ProgramFK			   
		where
			 dischargedate is null --and sw.workerpk = isnull(@SupPK,sw.workerpk)
		)	
	,
	
	cteProgramCapacityX
	as
	( 
		select ProgramCapacity, ProgramFK,
			count(PC1ID) - sum(PreintakeCount) AS CurrentCapacity
			--,case when ProgramCapacity is null then 'Program capacity blank on Program Information Form.' 
			--ELSE CONVERT(VARCHAR, round(COALESCE(cast((count(PC1ID) - sum(PreintakeCount)) AS FLOAT) * 100 / 
			--NULLIF(ProgramCapacity,0), 0), 0))  + '%' end AS PerctOfProgramCapacity
		FROM ctemainAgain
		group by ProgramCapacity, ProgramFK
	)	 
	
	,
	cteProgramCapacity
	AS (
	
	select  sum(ProgramCapacity) AS ProgramCapacity,
			sum(CurrentCapacity) AS CurrentCapacity,
			case when sum(ProgramCapacity) is null then 'Program capacity blank on Program Information Form.' 
			ELSE CONVERT(VARCHAR, round(COALESCE(cast(sum(CurrentCapacity) AS FLOAT) * 100 / 
			NULLIF(sum(ProgramCapacity),0), 0), 0))  + '%' end AS PerctOfProgramCapacity
		FROM cteProgramCapacityX
	)
	
	-- C and D
	, cteScreen as
	(
		SELECT count(*) AS TotalScreens,
		sum(CASE WHEN a.ReferralMade = 1 THEN 1 ELSE 0 END) AS PositiveScreens,
		CONVERT(VARCHAR, round(COALESCE(cast((sum(CASE WHEN a.ReferralMade = 1 THEN 1 ELSE 0 END)) AS FLOAT) * 100 / 
		NULLIF(count(*),0), 0), 0))  + '%'
		AS PercentScreen
		FROM HVScreen AS a
		inner join dbo.SplitString(@programfk,',') on a.ProgramFK = listitem
		WHERE a.ScreenDate BETWEEN @startDT AND @endDT
	)
	
	, cteKempe AS
	(
		SELECT 
		sum(CASE WHEN a.CaseStatus IN ('02', '04') THEN 1 ELSE 0 END) AS TotalKempe
		, sum(CASE WHEN a.CaseStatus IN ('02') AND a.FSWAssignDate IS NOT NULL THEN 1 ELSE 0 END) AS PositiveReferredKempe
		, CONVERT(VARCHAR, round(COALESCE(cast((sum(CASE WHEN a.CaseStatus IN ('02') AND 
		a.FSWAssignDate IS NOT NULL THEN 1 ELSE 0 END)) AS FLOAT) * 100 / 
		NULLIF(sum(CASE WHEN a.CaseStatus IN ('02', '04') THEN 1 ELSE 0 END),0), 0), 0))  + '%'
		AS PercentKempe
		FROM Preassessment AS a
		JOIN Kempe AS b ON a.HVCaseFK = b.HVCaseFK  -- new
		inner join dbo.SplitString(@programfk,',') on a.ProgramFK = listitem
		WHERE a.KempeDate BETWEEN @startDT AND @endDT
	)
	
	-- G (acceptance rate)
	,
	cteAcceptanceRateX AS 
	(
	SELECT HVCasePK ,DischargeDate, IntakeDate, k.KempeDate, KempeResult
		 FROM HVCase h
			INNER JOIN CaseProgram cp ON cp.HVCaseFK = h.HVCasePK
			inner join dbo.SplitString(@ProgramFK,',') on cp.programfk = listitem
			INNER JOIN Kempe k ON k.HVCaseFK = h.HVCasePK
			INNER JOIN PC P ON P.PCPK = h.PC1FK
			LEFT JOIN CommonAttributes ca ON ca.hvcasefk = h.hvcasepk AND ca.formtype = 'KE'
		WHERE (h.IntakeDate IS NOT NULL OR cp.DischargeDate IS NOT NULL)
		AND k.KempeResult = 1
		AND k.KempeDate BETWEEN @startDT AND @endDT
	)

	, cteAcceptanceRate AS 
	(SELECT 
	 CONVERT(VARCHAR, CONVERT(VARCHAR, round(COALESCE(cast(sum(Case WHEN IntakeDate IS NOT NULL 
    OR (KempeResult = 1 AND IntakeDate IS NULL AND DischargeDate IS NOT NULL 
	AND (PIVisitMade > 0 AND PIVisitMade IS NOT NULL)) THEN 1 ELSE 0 END) AS FLOAT) 
	* 100/ NULLIF(count(*),0), 0), 0))  + '%') AS AcceptanceRate	

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
	AND k.KempeDate BETWEEN @startDt AND @endDT
	)
	--(SELECT
	--    count(*) AS Totals
	--	, sum(Case WHEN IntakeDate IS NOT NULL THEN 1 ELSE 0 END) TotalEnrolled
	--	--, sum(Case WHEN DischargeDate IS NOT NULL AND IntakeDate IS NULL THEN 1 ELSE 0 END) TotalNotEnrolled
	--	,CONVERT(VARCHAR, CONVERT(VARCHAR, round(COALESCE(cast(sum(Case WHEN IntakeDate IS NOT NULL THEN 1 ELSE 0 END) AS FLOAT) 
	--	* 100/ NULLIF(count(*),0), 0), 0))  + '%') AS AcceptanceRate	 
	-- FROM cteAcceptanceRateX
	--)
	
	-- retention rate
	,
	cteCaseLastHomeVisit AS
	(select HVCaseFK
		   ,max(vl.VisitStartTime) as LastHomeVisit
		   ,count(vl.VisitStartTime) as CountOfHomeVisits
		from HVLog vl
		inner join hvcase c on c.HVCasePK = vl.HVCaseFK
		inner join dbo.SplitString(@ProgramFK, ',') ss on ss.ListItem = vl.ProgramFK
		where VisitType <> '00010' and (IntakeDate is not null and 
		IntakeDate between @startDTRetention and @endDTRetention)
		group by HVCaseFK
	)

	, cteMain as
	(select PC1ID
		   ,IntakeDate
		   ,LastHomeVisit
		   ,DischargeDate
		   ,cp.DischargeReason as DischargeReasonCode
		   ,cd.ReportDischargeText
		   ,case
				when dischargedate is null and current_timestamp-IntakeDate > 182.125 then 1
				when dischargedate is not null and LastHomeVisit-IntakeDate > 182.125 then 1
				else 0
			end as ActiveAt6Months
		   ,case
				when dischargedate is null and current_timestamp-IntakeDate > 365.25 then 1
				when dischargedate is not null and LastHomeVisit-IntakeDate > 365.25 then 1
				else 0
			end as ActiveAt12Months
		   ,case
				when dischargedate is null and current_timestamp-IntakeDate > 547.375 then 1
				when dischargedate is not null and LastHomeVisit-IntakeDate > 547.375 then 1
				else 0
			end as ActiveAt18Months
		   ,case
				when dischargedate is null and current_timestamp-IntakeDate > 730.50 then 1
				when dischargedate is not null and LastHomeVisit-IntakeDate > 730.50 then 1
				else 0
			end as ActiveAt24Months
	 from HVCase c
		inner join cteCaseLastHomeVisit lhv on lhv.HVCaseFK = c.HVCasePK
		inner join CaseProgram cp on cp.HVCaseFK = c.HVCasePK
		inner join dbo.SplitString(@ProgramFK, ',') ss on ss.ListItem = cp.ProgramFK
		 left outer join dbo.codeDischarge cd on cd.DischargeCode = cp.DischargeReason and DischargeUsedWhere like '%DS%'
	 where (IntakeDate is not NULL and IntakeDate between @startDTRetention and @endDTRetention)
	)
	
	, cteRetentionX AS
	(
		select distinct pc1id, IntakeDate, DischargeDate, d.ReportDischargeText, LastHomeVisit
					   ,case when DischargeDate is not null then 
							datediff(mm,IntakeDate,LastHomeVisit)
						else
							datediff(mm,IntakeDate,current_timestamp)
						end as RetentionMonths
					   ,ActiveAt6Months
					   ,ActiveAt12Months
					   ,ActiveAt18Months
					   ,ActiveAt24Months
			from cteMain
				left outer join codeDischarge d on cteMain.DischargeReasonCode = DischargeCode
			where DischargeReasonCode is null
				 or DischargeReasonCode not in ('07', '17', '18', '20', '21', '23', '25', '37') 
	)
	
	,
	cteRetention AS 
	(SELECT
	count(*) AS TotalEnrolledParticipants
	, sum(case when ActiveAt12Months=1 then 1 else 0 end) as TwelveMonthsTotal
	,CONVERT(VARCHAR, CONVERT(VARCHAR, round(COALESCE(cast(sum(case when ActiveAt12Months=1 then 1 else 0 end) AS FLOAT) 
			* 100/ NULLIF(count(*),0), 0), 0))  + '%') AS RetentionRateOneYear	 
	FROM cteRetentionX
	)

	, cteCombined AS
	(
		SELECT *
		FROM cteProgramCapacity
		LEFT OUTER JOIN cteScreen ON 1 = 1
		LEFT OUTER JOIN cteKempe ON 1 = 1
		LEFT OUTER JOIN cteAcceptanceRate ON 1 = 1
		LEFT OUTER JOIN cteRetention ON 1 = 1
	)
	,
	cteRptX AS
	(
	  SELECT ProgramCapacity AS A
	        ,CurrentCapacity AS	B
	        ,PerctOfProgramCapacity AS [B/A]
	        ,TotalScreens AS C
	        ,PositiveScreens AS D
	        ,PercentScreen AS [D/C]
	        ,TotalKempe AS E
	        ,PositiveReferredKempe AS F
	        ,CONVERT(VARCHAR, CONVERT(VARCHAR, round(COALESCE(cast(PositiveReferredKempe AS FLOAT) 
			 * 100/ NULLIF(PositiveScreens,0), 0), 0))  + '%') AS [F/D]
			,ProgramCapacity - CurrentCapacity AS [A-B]
			,AcceptanceRate AS G
			,RetentionRateOneYear AS H
	  FROM cteCombined
	)
	,
	
	cteRpt AS 
	(
	select *
	, round((A - (convert(FLOAT, replace(H,'%','') / 100.0) * A) + (A - B))/3, 0) AS EN3
	, round((A - (convert(FLOAT, replace(H,'%','') / 100.0) * A) + (A - B))/6, 0) AS EN6
	, round((A - (convert(FLOAT, replace(H,'%','') / 100.0) * A) + (A - B))/12, 0) AS EN12
	
	, round((A - (convert(FLOAT, replace(H,'%','') / 100.0) * A) + (A - B))/3/(convert(FLOAT, replace(G,'%','') / 100.0)), 0) AS K3
	, round((A - (convert(FLOAT, replace(H,'%','') / 100.0) * A) + (A - B))/6/(convert(FLOAT, replace(G,'%','') / 100.0)), 0) AS K6
	, round((A - (convert(FLOAT, replace(H,'%','') / 100.0) * A) + (A - B))/12/(convert(FLOAT, replace(G,'%','') / 100.0)), 0) AS K12
	
	, round((A - (convert(FLOAT, replace(H,'%','') / 100.0) * A) + (A - B))/3/(convert(FLOAT, replace(G,'%','') / 100.0))/(convert(FLOAT, replace([F/D],'%','') / 100.0)), 0) AS S3
	, round((A - (convert(FLOAT, replace(H,'%','') / 100.0) * A) + (A - B))/6/(convert(FLOAT, replace(G,'%','') / 100.0))/(convert(FLOAT, replace([F/D],'%','') / 100.0)), 0) AS S6
	, round((A - (convert(FLOAT, replace(H,'%','') / 100.0) * A) + (A - B))/12/(convert(FLOAT, replace(G,'%','') / 100.0))/(convert(FLOAT, replace([F/D],'%','') / 100.0)), 0) AS S12
	
	from cteRptX
	)
    
    -- d1, d2, and d3
    
    , cteD as
	(
		SELECT 
		isnull(sum(CASE WHEN a.ReferralMade = 1 
		AND a.ScreenDate BETWEEN @startDT1 AND @endDT1
		THEN 1 ELSE 0 END), 0) AS D1
		, isnull(sum(CASE WHEN a.ReferralMade = 1 
		AND a.ScreenDate BETWEEN @startDT2 AND @endDT2
		THEN 1 ELSE 0 END), 0) AS D2
		, isnull(sum(CASE WHEN a.ReferralMade = 1 
		AND a.ScreenDate BETWEEN @startDT3 AND @endDT3
		THEN 1 ELSE 0 END), 0) AS D3
		FROM HVScreen AS a
		inner join dbo.SplitString(@programfk,',') on a.ProgramFK = listitem
		WHERE a.ScreenDate BETWEEN @startDT1 AND @endDT3
	)
    
    ,
    cteF AS
	(
		SELECT 
		isnull(sum(CASE WHEN a.CaseStatus IN ('02') 
		AND a.FSWAssignDate IS NOT NULL 
		AND a.KempeDate BETWEEN @startDT1 AND @endDT1
		THEN 1 ELSE 0 END), 0) AS F1
		, isnull(sum(CASE WHEN a.CaseStatus IN ('02') 
		AND a.FSWAssignDate IS NOT NULL 
		AND a.KempeDate BETWEEN @startDT2 AND @endDT2
		THEN 1 ELSE 0 END), 0) AS F2
		, isnull(sum(CASE WHEN a.CaseStatus IN ('02') 
		AND a.FSWAssignDate IS NOT NULL 
		AND a.KempeDate BETWEEN @startDT3 AND @endDT3
		THEN 1 ELSE 0 END), 0) AS F3
		FROM Preassessment AS a
		inner join dbo.SplitString(@programfk,',') on a.ProgramFK = listitem
		WHERE a.KempeDate BETWEEN @startDT1 AND @endDT3
	)
	
	,
	cteX AS 
	(
	SELECT 
	isnull(sum(CASE WHEN h.IntakeDate BETWEEN @startDT1 AND @endDT1
		THEN 1 ELSE 0 END), 0) AS X1
	, isnull(sum(CASE WHEN h.IntakeDate BETWEEN @startDT2 AND @endDT2
		THEN 1 ELSE 0 END), 0) AS X2
	, isnull(sum(CASE WHEN h.IntakeDate BETWEEN @startDT3 AND @endDT3
		THEN 1 ELSE 0 END), 0) AS X3
	FROM HVCase h
		INNER JOIN CaseProgram cp ON cp.HVCaseFK = h.HVCasePK
		inner join dbo.SplitString(@ProgramFK,',') on cp.programfk = listitem
	WHERE (h.IntakeDate IS NOT NULL OR cp.DischargeDate IS NOT NULL)
	AND h.IntakeDate BETWEEN @startDT1 AND @endDT3
	)
	
	, 
	cteDateName AS
	(
	  SELECT 
	  DATENAME(month ,@startDT1) + ' ' + convert(varchar(4), datepart(yyyy, @startDT1)) [d1_name]
	, DATENAME(month ,@startDT2) + ' ' + convert(varchar(4), datepart(yyyy, @startDT2)) [d2_name]
	, DATENAME(month ,@startDT3) + ' ' + convert(varchar(4), datepart(yyyy, @startDT3)) [d3_name]
	
	)
	
	, 
	cteStartEndDate AS
	(
	  SELECT 
	  convert(VARCHAR(10), @startDT, 101) + ' - ' + convert(VARCHAR(10), @endDT, 101) AS [start_end]
	  , convert(VARCHAR(10), @startDTRetention, 101) + ' - ' + convert(VARCHAR(10), @endDTRetention, 101) AS [start_end_retention]
	
	)
	
    -- test A/B
	--SELECT * FROM cteProgramCapacity
	
	-- test C/D
	--SELECT * FROM cteScreen
	
	-- test E/F
	--SELECT * FROM cteKempe
	
	-- test G
    --SELECT * FROM cteAcceptanceRate
    
    -- test H
    --select * FROM cteRetention 
    
  -- SELECT * FROM cteCombined


  
   SELECT * 
   FROM cteRpt
   LEFT	OUTER JOIN cteD ON 1 = 1
   LEFT	OUTER JOIN cteF ON 1 = 1
   LEFT	OUTER JOIN cteX ON 1 = 1
   LEFT	OUTER JOIN cteDateName ON 1 = 1
   LEFT	OUTER JOIN cteStartEndDate ON 1 = 1
GO
