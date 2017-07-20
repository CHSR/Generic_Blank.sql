SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Stored Procedure

-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <Jyly 16th, 2012>
-- Description:	<gets you data for Pre-Intake Engagement Termination Reasons Quarterly and Contract Period>
-- exec [rspPreIntakeEngagementTermReasons] ',1,','09/01/2010','11/30/2010',null,0
-- exec [rspPreIntakeEngagementTermReasons] ',1,','09/01/2010','11/30/2010',null,1

-- =============================================
CREATE procedure [dbo].[rspPreIntakeEngagementTermReasons](@programfk    varchar(max)    = null,
                                                        @sdate        datetime,
                                                        @edate        datetime,                                                        
                                                        @sitefk int             = NULL,
                                                        @CustomQuarterlyDates bit                                                         
                                                        )

as
BEGIN

	-- if user picks up custom dates ( not specific quarter dates) then Don't show ContractPeriod Column
	--DECLARE @bDontShowContractPeriod BIT
	-- we will be receiving the value of @bDontShowContractPeriod from UI. 
	-- so time being, let us do the following
	--SET @bDontShowContractPeriod = 0



    declare @ContractStartDate DATE
    declare @ContractEndDate DATE

    if ((@ProgramFK IS not NULL) AND (@CustomQuarterlyDates = 0))
    BEGIN 
		set @ProgramFK = REPLACE(@ProgramFK,',','') -- remove comma's
		set @ContractStartDate = (select ContractStartDate FROM HVProgram P where HVProgramPK=@ProgramFK)
		set @ContractEndDate = (select ContractEndDate FROM HVProgram P where HVProgramPK=@ProgramFK)
	END 

--SELECT @ContractStartDate, @ContractEndDate

-- Let us declare few table variables so that we can manipulate the rows at our will
-- Note: Table variables are a superior alternative to using temporary tables 

---------------------------------------------
-- Initially, get the subset of data that we are interested in ... Good Practice ... Khalsa 
-- table variable for holding Init Required Data
DECLARE @tblInitRequiredData TABLE(
	[HVCasePK] [int]
)


DECLARE @tblInitRequiredDataTemp TABLE(
	[HVCasePK] [int],
	[SiteFK] [int]

)

-- Fill this table i.e. @tblInitRequiredData as below
INSERT INTO @tblInitRequiredDataTemp(
	[HVCasePK],
	[SiteFK]
)
SELECT 
h.HVCasePK
,CASE WHEN wp.SiteFK IS NULL THEN 0 ELSE wp.SiteFK END AS SiteFK
FROM HVCase h 
INNER JOIN CaseProgram cp ON h.HVCasePK = cp.HVCaseFK 
INNER JOIN Worker w ON w.WorkerPK = cp.CurrentFSWFK
INNER JOIN WorkerProgram wp ON wp.WorkerFK = w.WorkerPK -- get SiteFK
inner join dbo.SplitString(@programfk,',') on cp.programfk = listitem

-- SiteFK = isnull(@sitefk,SiteFK) does not work because column SiteFK may be null itself 
-- so to solve this problem we make use of @tblInitRequiredDataTemp
INSERT INTO @tblInitRequiredData( 
	[HVCasePK])
SELECT HVCasePK FROM @tblInitRequiredDataTemp
WHERE SiteFK = isnull(@sitefk,SiteFK)


-- Create two tables i.e. one for quarterly and another one for Contract Period
-- then we will join together

DECLARE @tblTRQuarterly TABLE( 
DischargeReason CHAR(100),
pctDischargeReason CHAR(20)
)


DECLARE @tblTRContractPeriod TABLE( 
DischargeReason CHAR(100),
pctDischargeReason CHAR(20)
)


---------------------------------------------------
-- #Termination Reasons for Period - Quarterly
---------------------------------------------------

DECLARE @tblTerminationReasonQuarterly TABLE( 
DischargeCode CHAR(2),
frequency INT
)


INSERT INTO @tblTerminationReasonQuarterly
(
 DischargeCode
,frequency
)
(
		SELECT  p.DischargeReason, count(HVCasePK)
		FROM @tblInitRequiredData irq
			Left JOIN Preintake p ON HVCasePK = p.HVCaseFK
			WHERE 
			 PIDate BETWEEN @sDate AND @edate			
			AND p.CaseStatus = '03'
			GROUP BY p.DischargeReason

)

-- exec [rspPreIntakeEngagementTermReasons] ',1,','09/01/2010','11/30/2010',null,0
DECLARE @totalNumOfQuarteryTermReason INT 

SET @totalNumOfQuarteryTermReason = (SELECT sum(frequency) FROM @tblTerminationReasonQuarterly)

--SELECT @totalNumOfQuarteryTermReason


INSERT INTO @tblTRQuarterly
( 
DischargeReason,
pctDischargeReason
)
SELECT ds.DischargeReason
, CONVERT(VARCHAR,isnull(trq.frequency,0)) + ' (' + CONVERT(VARCHAR, round(COALESCE (cast(isnull(trq.frequency,0) AS FLOAT) * 100/ NULLIF(@totalNumOfQuarteryTermReason,0), 0), 0))  + '%)' AS QTermReasons
FROM codeDischarge ds
left join @tblTerminationReasonQuarterly trq on trq.DischargeCode = ds.DischargeCode
WHERE DischargeUsedWhere LIKE '%PI%' 
ORDER BY ds.DischargeCode



---------------------------------------------------
-- #Termination Reasons for Period - Contract Period
---------------------------------------------------

DECLARE @tblTerminationReasonContractPeriod TABLE( 
DischargeCode CHAR(2),
frequency INT
)


INSERT INTO @tblTerminationReasonContractPeriod
(
 DischargeCode
,frequency
)
(
		SELECT  p.DischargeReason, count(HVCasePK)
		FROM @tblInitRequiredData irq
			Left JOIN Preintake p ON HVCasePK = p.HVCaseFK
			WHERE 
			 PIDate BETWEEN @ContractStartDate AND @edate			
			AND p.CaseStatus = '03'
			GROUP BY p.DischargeReason

)


DECLARE @totalNumOfContractPeriodTermReason INT 

SET @totalNumOfContractPeriodTermReason = (SELECT sum(frequency) FROM @tblTerminationReasonContractPeriod)

--SELECT @totalNumOfContractPeriodTermReason



INSERT INTO @tblTRContractPeriod
( 
DischargeReason,
pctDischargeReason
)
SELECT ds.DischargeReason
, CONVERT(VARCHAR,isnull(trq.frequency,0)) + ' (' + CONVERT(VARCHAR, round(COALESCE (cast(isnull(trq.frequency,0) AS FLOAT) * 100/ NULLIF(@totalNumOfContractPeriodTermReason,0), 0), 0))  + '%)' AS QTermReasons
FROM codeDischarge ds
left join @tblTerminationReasonContractPeriod trq on trq.DischargeCode = ds.DischargeCode
WHERE DischargeUsedWhere LIKE '%PI%' 
ORDER BY ds.DischargeCode


---------------------------------------------------
---------------------------------------------------


-- exec [rspPreIntakeEngagementTermReasons] ',1,','09/01/2010','11/30/2010',null,0
-- Join Quarterly and ContractPeriod tables to get the desired result
SELECT 
	Qtrly.DischargeReason,
	Qtrly.pctDischargeReason AS QuerterlyTermReasons,
	cp.pctDischargeReason AS ContractPeriodTermReasons
 FROM @tblTRQuarterly Qtrly
INNER JOIN @tblTRContractPeriod cp ON cp.DischargeReason = Qtrly.DischargeReason  




END
GO
