SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Devinder Singh Khalsa
-- Create date: Oct. 3rd, 2013
-- Description:	Screen Referral Source Demographics And Outcome Analysis - Reasons for Positive Screens, not referred
-- rspScreenReferralSourceDemographicsAndOutcomeAnalysis_Reasons 5,'09/01/2011','08/31/2012'
-- rspScreenReferralSourceDemographicsAndOutcomeAnalysis_Reasons 5,'09/01/2011','08/31/2012', 449  (note: 449 = self referral)
-- =============================================

/* 
//Add the following new indexes ... khalsa
USE [HFNY]
GO
CREATE NONCLUSTERED INDEX [ixHVCaseScreenDate]
ON [dbo].[HVCase] ([ScreenDate])
INCLUDE ([HVCasePK],[CaseProgress],[EDC],[IntakeDate],[KempeDate],[PC1FK],[TCDOB])
GO
*/


CREATE procedure [dbo].[rspScreenReferralSourceDemographicsAndOutcomeAnalysis_Reasons]
(
    @programfk varchar(max)    = null,
    @sdate     datetime,
    @edate     datetime,
    @listReferralSourcePK int = null -- pk of Referral Source Agency
)
as

set nocount on

IF 1=0 BEGIN
    SET FMTONLY OFF
end

--set statistics time on 
--set statistics IO on 


	if @programfk is null
	begin
		select @programfk =
			   substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
							  from HVProgram
							  for xml path ('')),2,8000)
	end

	set @programfk = REPLACE(@programfk,'"','')
	

-- Positive Screens Not Referred table
	create table #tblPositiveScreensNotReferred(	
	   HVCasePK int
	   ,ScreenResult [char](1) null
	   ,ReferralMade [char](1) null 
	   ,DischargeReason [char](100) null

	)

-- Cohort
	create table #tblMainCohort(
	
	  
	   HVCasePK int
	   ,ScreenResult [char](1) null
	   ,ReferralMade [char](1) null 
	   ,DischargeReason [char](100) null

	
	)

	INSERT INTO #tblMainCohort
	SELECT 


		   HVCasePK
		   ,ScreenResult
		   ,ReferralMade
		  ,cd.DischargeReason
		 

		  
		   FROM hvscreen hvs
	inner join HVCase h on h.HVCasePK = hvs.HVCaseFK
	inner join caseprogram cp on h.hvcasepk = cp.hvcasefk
	inner join dbo.SplitString(@programfk, ',') on cp.programfk = listitem
	LEFT OUTER JOIN dbo.listReferralSource lrs on lrs.listReferralSourcePK = hvs.ReferralSourceFK
	left outer join dbo.codeDischarge cd on cd.DischargeCode = cp.DischargeReason and DischargeUsedWhere like '%SC%'
	
	

	

	where  
	lrs.listReferralSourcePK = isnull(@listReferralSourcePK,lrs.listReferralSourcePK)
	and
	h.ScreenDate between @sDate and @eDate	
	order by h.HVCasePK 
	

	
	
--SELECT * FROM #tblMainCohort	
--	where pcage < 18

-- now fill in the other temp tables, whicn we need later

	INSERT INTO #tblPositiveScreensNotReferred
		SELECT * FROM #tblMainCohort where ScreenResult= '1' and ReferralMade= '0'



------------------SELECT * FROM #tblMainCohort


-- calculate main totals
DECLARE @numOfTotalPositiveScreensNotReferred INT = 0
SET @numOfTotalPositiveScreensNotReferred = (SELECT count(*) FROM #tblPositiveScreensNotReferred)



;
with cteStatistics4PostiveScreensNotReferred
as
(

SELECT 

		sum(case when ScreenResult= '1' and ReferralMade= '0' then
				 1
			 else
				 0
			 end) as PositiveScreensNotReferred	 
			 
			 
		,CASE WHEN DischargeReason IS NULL THEN 'No Discharge Reason Code' ELSE DischargeReason END DischargeReason
		
FROM #tblMainCohort c
where hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreensNotReferred)
group by CASE WHEN DischargeReason IS NULL THEN 'No Discharge Reason Code' ELSE DischargeReason END

)

,
cteReaons4PostiveScreensNotReferred
as
(
SELECT 
@numOfTotalPositiveScreensNotReferred as TotalPositiveScreensButNotReferred
,DischargeReason
,CONVERT(VARCHAR,PositiveScreensNotReferred) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(PositiveScreensNotReferred AS FLOAT) * 100/ NULLIF(@numOfTotalPositiveScreensNotReferred,0), 0), 0))  + '%)' as TotalPositiveScreens


FROM cteStatistics4PostiveScreensNotReferred
)





SELECT * FROM cteReaons4PostiveScreensNotReferred


-- rspScreenReferralSourceDemographicsAndOutcomeAnalysis_Reasons 5,'09/01/2011','08/31/2012'
-- rspScreenReferralSourceDemographicsAndOutcomeAnalysis_Reasons 5,'09/01/2012','08/31/2013'



--set statistics time off  
--set statistics IO off 



-- drop all the temp tables
drop table #tblMainCohort
drop table #tblPositiveScreensNotReferred

GO
