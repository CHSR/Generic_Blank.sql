SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Chris Papas
-- Create date: 12/10/2012

-- Description:	<This QA report gets you 'ASQ SE for Active Cases with Target Child 6 months or older '>
-- rspQAReport8 1, 'summary'	--- for summary page
-- rspQAReport8 1			--- for main report - location = 1
-- rspQAReport8 null			--- for main report for all locations
-- =============================================


CREAte procedure [dbo].[rspQAReport8_test](
@programfk    varchar(max)    = NULL,
@ReportType char(7) = NULL 

)
AS
	if @programfk is null
	begin
		select @programfk = substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end

	set @programfk = REPLACE(@programfk,'"','')

declare @reportdate as datetime
declare @lastdayprevmonth as datetime

set @reportdate='12/10/2012'
set @lastdayprevmonth='11/30/2012'
;
With cteCohort as (
	SELECT hvcasepk, tcid.tcdob, PC1ID, GestationalAge, TCLastName + ', ' + TCFirstName as TCName, CurrentLevelFK
	, datediff(dd,dateadd(ww,(40-gestationalage),tcid.tcdob),@lastdayprevmonth) as tcage_days 
	from HVCase h
	INNER join CaseProgram cp on cp.HVCaseFK = h.hvcasepk
	INNER join TCID on tcid.HVCaseFK = h.HVCasePK
	WHERE IntakeDate < @reportdate 
	and (DischargeDate IS NULL OR DischargeDate > @lastdayprevmonth) 
	and cp.ProgramFK=@programfk
	and DATEADD(dd, 183, dateadd(ww,(40-gestationalage),tcid.tcdob)) < @lastdayprevmonth
)

, cteExpected as (
	Select DueBy, Interval, MaximumDue, MinimumDue
	,(Select Top 1 (B.MinimumDue-1) From codeDueByDates B
         Where B.DueBy > A.DueBy and ScheduledEvent = 'ASQSE-1'
         order By A.DueBy) as NewMaximumDue 
     from codeDueByDates A
     where ScheduledEvent = 'ASQSE-1'
)

, cteGetInterval as (
		select hvcasepk, tcdob, TCName
		, DATEADD(dd,-(tcage_days),@lastdayprevmonth) as CalcDOB		
		,PC1ID, GestationalAge,tcage_days
		,CurrentLevelFK
		,  Case WHEN (Select interval from cteexpected where tcage_days between MinimumDue and NewMaximumDue)	
			IS NULL then 48
			ELSE (Select interval from cteexpected where tcage_days between MinimumDue and NewMaximumDue)	
			END AS interval
		from cteCohort
)

, cteExpectedForm as (
		select *, DATEADD(mm, interval, CalcDOB) as FormDueDate
		from cteGetInterval
)
		
, cteGetMostRecentASQ as (
	Select MAX(asqsepk) as ASQSEPK
	, HVCasePK, CurrentLevelFK
	, TCDOB, TCName, CalcDOB, PC1ID, GestationalAge, tcage_days, interval, FormDueDate
	from ASQSE
	Right JOIN cteExpectedForm on cteExpectedForm.hvcasepk=asqse.HVCaseFK
	Group by hvcasepk, CurrentLevelFK, TCDOB, TCName, CalcDOB, PC1ID, GestationalAge, tcage_days, interval, FormDueDate
)

, cteDetails as (
	SELECT cteGetMostRecentASQ.asqsepk
	, ASQSEDateCompleted, ASQSEInWindow
	, HVCasePK, CurrentLevelFK
	, TCDOB, TCName, CalcDOB, PC1ID, GestationalAge, tcage_days, interval, FormDueDate
	FROM cteGetMostRecentASQ
	left join ASQSE on asqse.ASQSEPK=cteGetMostRecentASQ.ASQSEPK
	
)

select --Case when ASQSEPK IS Null then 0 ELSE
	[dbo].[IsFormReviewed](ASQSEDateCompleted, 'AS', ASQSEPK) AS FormReviewed
	--END as formreviewed 
	, ASQSEDateCompleted, ASQSEInWindow
	, HVCasePK, CurrentLevelFK
	, TCDOB, TCName, CalcDOB, PC1ID, GestationalAge, tcage_days, interval, FormDueDate
FROM cteDetails
order by PC1ID
GO
