SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Devinder Singh Khalsa
-- Create date: Oct. 3rd, 2013
-- Description:	Screen Referral Source Demographics And Outcome Analysis
-- rspScreenReferralSourceDemographicsAndOutcomeAnalysis 1,'10/01/2012','09/30/2013'
-- rspScreenReferralSourceDemographicsAndOutcomeAnalysis 5,'09/01/2011','08/31/2012'
-- rspScreenReferralSourceDemographicsAndOutcomeAnalysis 5,'09/01/2011','08/31/2012', 449  (note: 449 = self referral)
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


CREATE procedure [dbo].[rspScreenReferralSourceDemographicsAndOutcomeAnalysis]
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
END
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
	
-- Screen Analysis Summary table
	create table #tblScreenAnalysisSummary(	
			[Id] INT,
			[Title] [varchar](200),
			[SubGroupId] INT,
			[TotalScreens] [varchar](12),
			[PositiveScreens] [varchar](12),
			[PositiveScreensNotReferred] [varchar](12),
			[NegativeScreens] [varchar](12),
			[KempesCompleted] [varchar](12),
			[Enrolled] [varchar](12),
			[NumOfUnduplicatedScreens] [varchar](10)	
	)



-- Positive Screens table
	create table #tblPositiveScreens(	
	   ConceptionDate [datetime] NULL
	  ,ReferralMade [char](1) null
	  ,Relation2TC [char](2) null	  
	  ,RiskNoPrenatalCare [char](1) null
	  ,RiskNotMarried [char](1) null
	  ,RiskPoor [char](1) null
	  ,RiskUnder21 [char](1) null 
	  ,ScreenResult [char](1) null
	  ,TargetArea [char](1) null
	  ,HVCasePK int
	  ,CaseProgress numeric(3,1) NULL
	  ,EDC [datetime] NULL
	  ,IntakeDate [datetime] NULL
	  ,KempeDate [datetime] NULL
	  ,PC1FK int
	  ,ScreenDate [datetime] NULL
	  ,TCDOB [datetime] NULL
	  ,CaseStartDate [datetime] NULL
	  ,DischargeDate [datetime] null
	  ,OldID char(23)
	  ,PC1ID char(13)
	  ,ProgramFK int
	  ,GestationalAge int
	  ,ReferralSourceName char(50)
	  ,PCDOB [datetime] NULL 
	  ,pcage int
	  ,babydate [datetime] NULL 
	  ,Race [char](2) null
	  ,OBPInHome [char](1) null 
	  ,ReceivingPreNatalCare [char](1) null
	  ,DischargeReason [char](100) null
	  ,ReferralSource [char](2) null
	  ,AppCodeText [char](100) null
	 
	)

-- Positive Screens Not Referred table
	create table #tblPositiveScreensNotReferred(	
	   ConceptionDate [datetime] NULL
	  ,ReferralMade [char](1) null
	  ,Relation2TC [char](2) null
	  ,RiskNoPrenatalCare [char](1) null
	  ,RiskNotMarried [char](1) null
	  ,RiskPoor [char](1) null
	  ,RiskUnder21 [char](1) null
	  ,ScreenResult [char](1) null
	  ,TargetArea [char](1) null
	  ,HVCasePK int
	  ,CaseProgress numeric(3,1) NULL
	  ,EDC [datetime] NULL
	  ,IntakeDate [datetime] NULL
	  ,KempeDate [datetime] NULL
	  ,PC1FK int
	  ,ScreenDate [datetime] NULL
	  ,TCDOB [datetime] NULL
	  ,CaseStartDate [datetime] NULL
	  ,DischargeDate [datetime] null
	  ,OldID char(23)
	  ,PC1ID char(13)
	  ,ProgramFK int
	  ,GestationalAge int
	  ,ReferralSourceName char(50)
	  ,PCDOB [datetime] null
	  ,pcage int
	  ,babydate [datetime] NULL 
	  ,Race [char](2) null 
	  ,OBPInHome [char](1) null 
	  ,ReceivingPreNatalCare [char](1) null
	  ,DischargeReason [char](100) null
	  ,ReferralSource [char](2) null
	  ,AppCodeText [char](100) null
	)

-- Negative Screens table
	create table #tblNegativeScreens(	
	   ConceptionDate [datetime] NULL
	  ,ReferralMade [char](1) null
	  ,Relation2TC [char](2) null
	  ,RiskNoPrenatalCare [char](1) null
	  ,RiskNotMarried [char](1) null
	  ,RiskPoor [char](1) null
	  ,RiskUnder21 [char](1) null
	  ,ScreenResult [char](1) null
	  ,TargetArea [char](1) null
	  ,HVCasePK int
	  ,CaseProgress numeric(3,1) NULL
	  ,EDC [datetime] NULL
	  ,IntakeDate [datetime] NULL
	  ,KempeDate [datetime] NULL
	  ,PC1FK int
	  ,ScreenDate [datetime] NULL
	  ,TCDOB [datetime] NULL
	  ,CaseStartDate [datetime] NULL
	  ,DischargeDate [datetime] null
	  ,OldID char(23)
	  ,PC1ID char(13)
	  ,ProgramFK int
	  ,GestationalAge int
	  ,ReferralSourceName char(50)
	  ,PCDOB [datetime] null
	  ,pcage int
	  ,babydate [datetime] null
	  ,Race [char](2) null 
	  ,OBPInHome [char](1) null
	  ,ReceivingPreNatalCare [char](1) null 
	  ,DischargeReason [char](100) null
	  ,ReferralSource [char](2) null
	  ,AppCodeText [char](100) null
	)
	
-- Kempes Completed table
	create table #tblKempesCompleted(	
	   ConceptionDate [datetime] NULL
	  ,ReferralMade [char](1) null
	  ,Relation2TC [char](2) null
	  ,RiskNoPrenatalCare [char](1) null
	  ,RiskNotMarried [char](1) null
	  ,RiskPoor [char](1) null
	  ,RiskUnder21 [char](1) null
	  ,ScreenResult [char](1) null
	  ,TargetArea [char](1) null
	  ,HVCasePK int
	  ,CaseProgress numeric(3,1) NULL
	  ,EDC [datetime] NULL
	  ,IntakeDate [datetime] NULL
	  ,KempeDate [datetime] NULL
	  ,PC1FK int
	  ,ScreenDate [datetime] NULL
	  ,TCDOB [datetime] NULL
	  ,CaseStartDate [datetime] NULL
	  ,DischargeDate [datetime] null
	  ,OldID char(23)
	  ,PC1ID char(13)
	  ,ProgramFK int
	  ,GestationalAge int
	  ,ReferralSourceName char(50)
	  ,PCDOB [datetime] null
	  ,pcage int
	  ,babydate [datetime] NULL 
	  ,Race [char](2) null
	  ,OBPInHome [char](1) null 
	  ,ReceivingPreNatalCare [char](1) null
	  ,DischargeReason [char](100) null
	  ,ReferralSource [char](2) null
	  ,AppCodeText [char](100) null
	)	

-- Enrolled Completed table
	create table #tblEnrolled(	
	   ConceptionDate [datetime] NULL
	  ,ReferralMade [char](1) null
	  ,Relation2TC [char](2) null
	  ,RiskNoPrenatalCare [char](1) null
	  ,RiskNotMarried [char](1) null
	  ,RiskPoor [char](1) null
	  ,RiskUnder21 [char](1) null
	  ,ScreenResult [char](1) null
	  ,TargetArea [char](1) null
	  ,HVCasePK int
	  ,CaseProgress numeric(3,1) NULL
	  ,EDC [datetime] NULL
	  ,IntakeDate [datetime] NULL
	  ,KempeDate [datetime] NULL
	  ,PC1FK int
	  ,ScreenDate [datetime] NULL
	  ,TCDOB [datetime] NULL
	  ,CaseStartDate [datetime] NULL
	  ,DischargeDate [datetime] null
	  ,OldID char(23)
	  ,PC1ID char(13)
	  ,ProgramFK int
	  ,GestationalAge int
	  ,ReferralSourceName char(50)
	  ,PCDOB [datetime] NULL	
	  ,pcage int
	  ,babydate [datetime] NULL 
	  ,Race [char](2) null
	  ,OBPInHome [char](1) null 
	  ,ReceivingPreNatalCare [char](1) null
	  ,DischargeReason [char](100) null
	  ,ReferralSource [char](2) null
	  ,AppCodeText [char](100) null
	)	



-- Cohort
	create table #tblMainCohort(
	
	   ConceptionDate [datetime] NULL
	  ,ReferralMade [char](1) null
	  ,Relation2TC [char](2) null
	  ,RiskNoPrenatalCare [char](1) null
	  ,RiskNotMarried [char](1) null
	  ,RiskPoor [char](1) null
	  ,RiskUnder21 [char](1) null
	  ,ScreenResult [char](1) null
	  ,TargetArea [char](1) null
	  ,HVCasePK int
	  ,CaseProgress numeric(3,1) NULL
	  ,EDC [datetime] NULL
	  ,IntakeDate [datetime] NULL
	  ,KempeDate [datetime] NULL
	  ,PC1FK int
	  ,ScreenDate [datetime] NULL
	  ,TCDOB [datetime] NULL
	  ,CaseStartDate [datetime] NULL
	  ,DischargeDate [datetime] null
	  ,OldID char(23)
	  ,PC1ID char(13)
	  ,ProgramFK int
	  ,GestationalAge int
	  ,ReferralSourceName char(50)
	  ,PCDOB [datetime] null
	  ,pcage int
	  ,babydate [datetime] NULL 
	  ,Race [char](2) null 
	  ,OBPInHome [char](1) null
	  ,ReceivingPreNatalCare [char](1) null
	  ,DischargeReason [char](100) null
	  ,ReferralSource [char](2) null
	  ,AppCodeText [char](100) null
	
	)

	INSERT INTO #tblMainCohort
	SELECT 
		 ConceptionDate = case when h.TCDOB is null then dateadd(week, -40, h.EDC)								
								when tcid.TCIDPK is NULL and h.TCDOB is not null
									then dateadd(week, -40, h.TCDOB)
								when tcid.TCIDPK is not NULL and h.TCDOB is not null
									then dateadd(week, -40, dateadd(week, (40 - isnull(GestationalAge, 40)), h.TCDOB) )	
								--when GestationalAge is not null and h.TCDOB is not null
								--	then dateadd(week, -GestationalAge, h.TCDOB)
		  				   end


		  ,ReferralMade
		  ,Relation2TC
		  ,RiskNoPrenatalCare
		  ,RiskNotMarried
		  ,RiskPoor
		  ,RiskUnder21
		  ,ScreenResult
		  ,TargetArea
		  ,HVCasePK
		  ,CaseProgress
		  ,EDC
		  ,IntakeDate
		  ,KempeDate
		  ,PC1FK
		  ,h.ScreenDate
		  ,h.TCDOB
		  ,CaseStartDate
		  ,DischargeDate
		  ,OldID
		  ,PC1ID
		  ,cp.ProgramFK
		  ,tcid.GestationalAge
		  ,ReferralSourceName
		  ,PC.PCDOB 
		  ,datediff( d, pc.PCDOB, hvs.ScreenDate) / 365.25 as pcage
		  ,isnull(h.TCDOB,EDC) + (40-isnull(tcid.GestationalAge, 40))*7 as babydate
		  ,PC.Race 
		  ,ca.OBPInHome
		  ,ca.ReceivingPreNatalCare 
		  ,cd.DischargeReason
		  ,ReferralSource
		  ,b.AppCodeText
		 

		  
		   FROM hvscreen hvs
	inner join HVCase h on h.HVCasePK = hvs.HVCaseFK
	inner join caseprogram cp on h.hvcasepk = cp.hvcasefk
	inner join dbo.SplitString(@programfk, ',') on cp.programfk = listitem	
	INNER JOIN PC ON h.PC1FK = PC.PCPK -- to get pcdob	
	LEFT JOIN CommonAttributes ca ON ca.hvcasefk = h.hvcasepk AND ca.formtype = 'SC'

	left join dbo.TCID ON dbo.TCID.HVCaseFK = h.HVCasePK
	LEFT OUTER JOIN dbo.listReferralSource lrs on lrs.listReferralSourcePK = hvs.ReferralSourceFK
	left outer join dbo.codeDischarge cd on cd.DischargeCode = cp.DischargeReason and DischargeUsedWhere like '%SC%'

	LEFT OUTER JOIN codeApp AS b ON b.AppCode = hvs.ReferralSource AND b.AppCodeGroup = 'TypeofReferral' and b.AppCodeUsedWhere like '%sc%' 
	

	where  
	lrs.listReferralSourcePK = isnull(@listReferralSourcePK,lrs.listReferralSourcePK)
	and
	h.ScreenDate between @sDate and @eDate	
	order by h.HVCasePK 
	

	
	
--SELECT * FROM #tblMainCohort	
--	where pcage < 18

-- now fill in the other temp tables, whicn we need later
	INSERT INTO #tblPositiveScreens
		SELECT * FROM #tblMainCohort where ScreenResult= '1' and ReferralMade= '1'

	INSERT INTO #tblPositiveScreensNotReferred
		SELECT * FROM #tblMainCohort where ScreenResult= '1' and ReferralMade= '0'

	INSERT INTO #tblNegativeScreens
		SELECT * FROM #tblMainCohort where ScreenResult != '1'

	INSERT INTO #tblKempesCompleted
		SELECT * FROM #tblMainCohort where KempeDate is not null

	INSERT INTO #tblEnrolled
		SELECT * FROM #tblMainCohort where IntakeDate is not null




------------------SELECT * FROM #tblMainCohort

-- calculate main totals
DECLARE @numOfALLScreens INT = 0
DECLARE @numOfTotalPositiveScreens INT = 0
DECLARE @numOfTotalPositiveScreensNotReferred INT = 0
DECLARE @numOfTotalNegativeScreens INT = 0
DECLARE @numOfTotalKempesCompleted INT = 0
DECLARE @numOfTotalEnrolled INT = 0

SET @numOfALLScreens = (SELECT count(*) FROM #tblMainCohort)
SET @numOfTotalPositiveScreens = (SELECT count(*) FROM #tblPositiveScreens)
SET @numOfTotalPositiveScreensNotReferred = (SELECT count(*) FROM #tblPositiveScreensNotReferred)
SET @numOfTotalNegativeScreens = (SELECT count(*) FROM #tblNegativeScreens)
SET @numOfTotalKempesCompleted = (SELECT count(*) FROM #tblKempesCompleted)
SET @numOfTotalEnrolled = (SELECT count(*) FROM #tblEnrolled)

	

INSERT INTO #tblScreenAnalysisSummary([Id],[Title],[SubGroupId],[TotalScreens],[PositiveScreens],[PositiveScreensNotReferred],[NegativeScreens],[KempesCompleted],[Enrolled])
VALUES(1, 'Totals', 1 
,CONVERT(VARCHAR,@numOfALLScreens) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfALLScreens AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreens) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreens AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreensNotReferred) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreensNotReferred AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalNegativeScreens) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalNegativeScreens AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalKempesCompleted) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalKempesCompleted AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalEnrolled) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalEnrolled AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
)


/*************************************************/
-- add the title for expectant parent in the row
INSERT INTO #tblScreenAnalysisSummary([Id],[Title],[SubGroupId],[TotalScreens],[PositiveScreens],[PositiveScreensNotReferred],[NegativeScreens],[KempesCompleted],[Enrolled])
VALUES(2, 'Expectant Parent', 2, '', '', '', '', '', '')  


-- calcualte Exprectant Parent - Mother statistics
DECLARE @numOfALLScreens23 INT = 0
DECLARE @numOfTotalPositiveScreens23 INT = 0
DECLARE @numOfTotalPositiveScreensNotReferred23 INT = 0
DECLARE @numOfTotalNegativeScreens23 INT = 0
DECLARE @numOfTotalKempesCompleted23 INT = 0
DECLARE @numOfTotalEnrolled23 INT = 0

SET @numOfALLScreens23 = (SELECT count(*) FROM #tblMainCohort where Relation2TC = '01')
SET @numOfTotalPositiveScreens23 = (SELECT count(*) FROM #tblMainCohort where Relation2TC = '01' and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreens))
SET @numOfTotalPositiveScreensNotReferred23 = (SELECT count(*) FROM #tblMainCohort where Relation2TC = '01' and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreensNotReferred))
SET @numOfTotalNegativeScreens23 = (SELECT count(*) FROM #tblMainCohort where Relation2TC = '01' and hvcasepk in (SELECT hvcasepk FROM #tblNegativeScreens))
SET @numOfTotalKempesCompleted23 = (SELECT count(*) FROM #tblMainCohort where Relation2TC = '01' and hvcasepk in (SELECT hvcasepk FROM #tblKempesCompleted))
SET @numOfTotalEnrolled23 = (SELECT count(*) FROM #tblMainCohort where Relation2TC = '01' and hvcasepk in (SELECT hvcasepk FROM #tblEnrolled))


INSERT INTO #tblScreenAnalysisSummary([Id],[Title],[SubGroupId],[TotalScreens],[PositiveScreens],[PositiveScreensNotReferred],[NegativeScreens],[KempesCompleted],[Enrolled])
VALUES(2, '    Mother', 3 
,CONVERT(VARCHAR,@numOfALLScreens23) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfALLScreens23 AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreens23) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreens23 AS FLOAT) * 100/ NULLIF(@numOfALLScreens23,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreensNotReferred23) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreensNotReferred23 AS FLOAT) * 100/ NULLIF(@numOfALLScreens23,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalNegativeScreens23) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalNegativeScreens23 AS FLOAT) * 100/ NULLIF(@numOfALLScreens23,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalKempesCompleted23) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalKempesCompleted23 AS FLOAT) * 100/ NULLIF(@numOfALLScreens23,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalEnrolled23) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalEnrolled23 AS FLOAT) * 100/ NULLIF(@numOfALLScreens23,0), 0), 0))  + '%)'
)

-- calcualte Exprectant Parent - Father statistics
DECLARE @numOfALLScreens24 INT = 0
DECLARE @numOfTotalPositiveScreens24 INT = 0
DECLARE @numOfTotalPositiveScreensNotReferred24 INT = 0
DECLARE @numOfTotalNegativeScreens24 INT = 0
DECLARE @numOfTotalKempesCompleted24 INT = 0
DECLARE @numOfTotalEnrolled24 INT = 0

SET @numOfALLScreens24 = (SELECT count(*) FROM #tblMainCohort where Relation2TC = '02')
SET @numOfTotalPositiveScreens24 = (SELECT count(*) FROM #tblMainCohort where Relation2TC = '02' and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreens))
SET @numOfTotalPositiveScreensNotReferred24 = (SELECT count(*) FROM #tblMainCohort where Relation2TC = '02' and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreensNotReferred))
SET @numOfTotalNegativeScreens24 = (SELECT count(*) FROM #tblMainCohort where Relation2TC = '02' and hvcasepk in (SELECT hvcasepk FROM #tblNegativeScreens))
SET @numOfTotalKempesCompleted24 = (SELECT count(*) FROM #tblMainCohort where Relation2TC = '02' and hvcasepk in (SELECT hvcasepk FROM #tblKempesCompleted))
SET @numOfTotalEnrolled24 = (SELECT count(*) FROM #tblMainCohort where Relation2TC = '02' and hvcasepk in (SELECT hvcasepk FROM #tblEnrolled))


INSERT INTO #tblScreenAnalysisSummary([Id],[Title],[SubGroupId],[TotalScreens],[PositiveScreens],[PositiveScreensNotReferred],[NegativeScreens],[KempesCompleted],[Enrolled])
VALUES(2, '    Father', 4 
,CONVERT(VARCHAR,@numOfALLScreens24) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfALLScreens24 AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreens24) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreens24 AS FLOAT) * 100/ NULLIF(@numOfALLScreens24,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreensNotReferred24) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreensNotReferred24 AS FLOAT) * 100/ NULLIF(@numOfALLScreens24,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalNegativeScreens24) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalNegativeScreens24 AS FLOAT) * 100/ NULLIF(@numOfALLScreens24,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalKempesCompleted24) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalKempesCompleted24 AS FLOAT) * 100/ NULLIF(@numOfALLScreens24,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalEnrolled24) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalEnrolled24 AS FLOAT) * 100/ NULLIF(@numOfALLScreens24,0), 0), 0))  + '%)'
)

-- calcualte Exprectant Parent - Other statistics
DECLARE @numOfALLScreens25 INT = 0
DECLARE @numOfTotalPositiveScreens25 INT = 0
DECLARE @numOfTotalPositiveScreensNotReferred25 INT = 0
DECLARE @numOfTotalNegativeScreens25 INT = 0
DECLARE @numOfTotalKempesCompleted25 INT = 0
DECLARE @numOfTotalEnrolled25 INT = 0

SET @numOfALLScreens25 = (SELECT count(*) FROM #tblMainCohort where Relation2TC = '03')
SET @numOfTotalPositiveScreens25 = (SELECT count(*) FROM #tblMainCohort where Relation2TC = '03' and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreens))
SET @numOfTotalPositiveScreensNotReferred25 = (SELECT count(*) FROM #tblMainCohort where Relation2TC = '03' and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreensNotReferred))
SET @numOfTotalNegativeScreens25 = (SELECT count(*) FROM #tblMainCohort where Relation2TC = '03' and hvcasepk in (SELECT hvcasepk FROM #tblNegativeScreens))
SET @numOfTotalKempesCompleted25 = (SELECT count(*) FROM #tblMainCohort where Relation2TC = '03' and hvcasepk in (SELECT hvcasepk FROM #tblKempesCompleted))
SET @numOfTotalEnrolled25 = (SELECT count(*) FROM #tblMainCohort where Relation2TC = '03' and hvcasepk in (SELECT hvcasepk FROM #tblEnrolled))


INSERT INTO #tblScreenAnalysisSummary([Id],[Title],[SubGroupId],[TotalScreens],[PositiveScreens],[PositiveScreensNotReferred],[NegativeScreens],[KempesCompleted],[Enrolled])
VALUES(2, '    Other', 5 
,CONVERT(VARCHAR,@numOfALLScreens25) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfALLScreens25 AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreens25) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreens25 AS FLOAT) * 100/ NULLIF(@numOfALLScreens25,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreensNotReferred25) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreensNotReferred25 AS FLOAT) * 100/ NULLIF(@numOfALLScreens25,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalNegativeScreens25) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalNegativeScreens25 AS FLOAT) * 100/ NULLIF(@numOfALLScreens25,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalKempesCompleted25) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalKempesCompleted25 AS FLOAT) * 100/ NULLIF(@numOfALLScreens25,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalEnrolled25) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalEnrolled25 AS FLOAT) * 100/ NULLIF(@numOfALLScreens25,0), 0), 0))  + '%)'
)


/*************************************************/
-- add the title for parent age in the row
INSERT INTO #tblScreenAnalysisSummary([Id],[Title],[SubGroupId],[TotalScreens],[PositiveScreens],[PositiveScreensNotReferred],[NegativeScreens],[KempesCompleted],[Enrolled])
VALUES(3, 'Age of Expectant Parent', 6, '', '', '', '', '', '')  


---- calcualte Exprectant Parent age - Under 18 statistics
DECLARE @numOfALLScreens37 INT = 0
DECLARE @numOfTotalPositiveScreens37 INT = 0
DECLARE @numOfTotalPositiveScreensNotReferred37 INT = 0
DECLARE @numOfTotalNegativeScreens37 INT = 0
DECLARE @numOfTotalKempesCompleted37 INT = 0
DECLARE @numOfTotalEnrolled37 INT = 0

SET @numOfALLScreens37 = (SELECT count(*) FROM #tblMainCohort where (pcage < 18))
SET @numOfTotalPositiveScreens37 = (SELECT count(*) FROM #tblMainCohort where  (pcage < 18) and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreens))
SET @numOfTotalPositiveScreensNotReferred37 = (SELECT count(*) FROM #tblMainCohort where  (pcage < 18) and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreensNotReferred))
SET @numOfTotalNegativeScreens37 = (SELECT count(*) FROM #tblMainCohort where  (pcage < 18) and hvcasepk in (SELECT hvcasepk FROM #tblNegativeScreens))
SET @numOfTotalKempesCompleted37 = (SELECT count(*) FROM #tblMainCohort where  (pcage < 18) and hvcasepk in (SELECT hvcasepk FROM #tblKempesCompleted))
SET @numOfTotalEnrolled37 = (SELECT count(*) FROM #tblMainCohort where  (pcage < 18) and hvcasepk in (SELECT hvcasepk FROM #tblEnrolled))


INSERT INTO #tblScreenAnalysisSummary([Id],[Title],[SubGroupId],[TotalScreens],[PositiveScreens],[PositiveScreensNotReferred],[NegativeScreens],[KempesCompleted],[Enrolled])
VALUES(3, '    Under 18', 7 
,CONVERT(VARCHAR,@numOfALLScreens37) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfALLScreens37 AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreens37) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreens37 AS FLOAT) * 100/ NULLIF(@numOfALLScreens37,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreensNotReferred37) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreensNotReferred37 AS FLOAT) * 100/ NULLIF(@numOfALLScreens37,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalNegativeScreens37) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalNegativeScreens37 AS FLOAT) * 100/ NULLIF(@numOfALLScreens37,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalKempesCompleted37) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalKempesCompleted37 AS FLOAT) * 100/ NULLIF(@numOfALLScreens37,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalEnrolled37) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalEnrolled37 AS FLOAT) * 100/ NULLIF(@numOfALLScreens37,0), 0), 0))  + '%)'
)


---- calcualte Exprectant Parent age - 18 up to 20 statistics
DECLARE @numOfALLScreens38 INT = 0
DECLARE @numOfTotalPositiveScreens38 INT = 0
DECLARE @numOfTotalPositiveScreensNotReferred38 INT = 0
DECLARE @numOfTotalNegativeScreens38 INT = 0
DECLARE @numOfTotalKempesCompleted38 INT = 0
DECLARE @numOfTotalEnrolled38 INT = 0

SET @numOfALLScreens38 = (SELECT count(*) FROM #tblMainCohort where ((pcage >= 18) and (pcage < 20)))
SET @numOfTotalPositiveScreens38 = (SELECT count(*) FROM #tblMainCohort where  ((pcage >= 18) and (pcage < 20)) and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreens))
SET @numOfTotalPositiveScreensNotReferred38 = (SELECT count(*) FROM #tblMainCohort where  ((pcage >= 18) and (pcage < 20)) and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreensNotReferred))
SET @numOfTotalNegativeScreens38 = (SELECT count(*) FROM #tblMainCohort where  ((pcage >= 18) and (pcage < 20)) and hvcasepk in (SELECT hvcasepk FROM #tblNegativeScreens))
SET @numOfTotalKempesCompleted38 = (SELECT count(*) FROM #tblMainCohort where  ((pcage >= 18) and (pcage < 20)) and hvcasepk in (SELECT hvcasepk FROM #tblKempesCompleted))
SET @numOfTotalEnrolled38 = (SELECT count(*) FROM #tblMainCohort where  ((pcage >= 18) and (pcage < 20)) and hvcasepk in (SELECT hvcasepk FROM #tblEnrolled))


INSERT INTO #tblScreenAnalysisSummary([Id],[Title],[SubGroupId],[TotalScreens],[PositiveScreens],[PositiveScreensNotReferred],[NegativeScreens],[KempesCompleted],[Enrolled])
VALUES(3, '    18 up to 20', 8 
,CONVERT(VARCHAR,@numOfALLScreens38) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfALLScreens38 AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreens38) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreens38 AS FLOAT) * 100/ NULLIF(@numOfALLScreens38,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreensNotReferred38) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreensNotReferred38 AS FLOAT) * 100/ NULLIF(@numOfALLScreens38,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalNegativeScreens38) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalNegativeScreens38 AS FLOAT) * 100/ NULLIF(@numOfALLScreens38,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalKempesCompleted38) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalKempesCompleted38 AS FLOAT) * 100/ NULLIF(@numOfALLScreens38,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalEnrolled38) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalEnrolled38 AS FLOAT) * 100/ NULLIF(@numOfALLScreens38,0), 0), 0))  + '%)'
)


---- calcualte Exprectant Parent age - 20 up to 30 statistics
DECLARE @numOfALLScreens39 INT = 0
DECLARE @numOfTotalPositiveScreens39 INT = 0
DECLARE @numOfTotalPositiveScreensNotReferred39 INT = 0
DECLARE @numOfTotalNegativeScreens39 INT = 0
DECLARE @numOfTotalKempesCompleted39 INT = 0
DECLARE @numOfTotalEnrolled39 INT = 0

SET @numOfALLScreens39 = (SELECT count(*) FROM #tblMainCohort where ((pcage >= 20) and (pcage < 30)))
SET @numOfTotalPositiveScreens39 = (SELECT count(*) FROM #tblMainCohort where  ((pcage >= 20) and (pcage < 30)) and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreens))
SET @numOfTotalPositiveScreensNotReferred39 = (SELECT count(*) FROM #tblMainCohort where  ((pcage >= 20) and (pcage < 30)) and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreensNotReferred))
SET @numOfTotalNegativeScreens39 = (SELECT count(*) FROM #tblMainCohort where  ((pcage >= 20) and (pcage < 30)) and hvcasepk in (SELECT hvcasepk FROM #tblNegativeScreens))
SET @numOfTotalKempesCompleted39 = (SELECT count(*) FROM #tblMainCohort where  ((pcage >= 20) and (pcage < 30)) and hvcasepk in (SELECT hvcasepk FROM #tblKempesCompleted))
SET @numOfTotalEnrolled39 = (SELECT count(*) FROM #tblMainCohort where  ((pcage >= 20) and (pcage < 30)) and hvcasepk in (SELECT hvcasepk FROM #tblEnrolled))


INSERT INTO #tblScreenAnalysisSummary([Id],[Title],[SubGroupId],[TotalScreens],[PositiveScreens],[PositiveScreensNotReferred],[NegativeScreens],[KempesCompleted],[Enrolled])
VALUES(3, '    20 up to 30', 9 
,CONVERT(VARCHAR,@numOfALLScreens39) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfALLScreens39 AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreens39) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreens39 AS FLOAT) * 100/ NULLIF(@numOfALLScreens39,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreensNotReferred39) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreensNotReferred39 AS FLOAT) * 100/ NULLIF(@numOfALLScreens39,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalNegativeScreens39) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalNegativeScreens39 AS FLOAT) * 100/ NULLIF(@numOfALLScreens39,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalKempesCompleted39) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalKempesCompleted39 AS FLOAT) * 100/ NULLIF(@numOfALLScreens39,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalEnrolled39) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalEnrolled39 AS FLOAT) * 100/ NULLIF(@numOfALLScreens39,0), 0), 0))  + '%)'
)


---- calcualte Exprectant Parent age - 30 and Over statistics
DECLARE @numOfALLScreens40 INT = 0
DECLARE @numOfTotalPositiveScreens40 INT = 0
DECLARE @numOfTotalPositiveScreensNotReferred40 INT = 0
DECLARE @numOfTotalNegativeScreens40 INT = 0
DECLARE @numOfTotalKempesCompleted40 INT = 0
DECLARE @numOfTotalEnrolled40 INT = 0

SET @numOfALLScreens40 = (SELECT count(*) FROM #tblMainCohort where pcage >= 30)
SET @numOfTotalPositiveScreens40 = (SELECT count(*) FROM #tblMainCohort where  (pcage >= 30) and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreens))
SET @numOfTotalPositiveScreensNotReferred40 = (SELECT count(*) FROM #tblMainCohort where  (pcage >= 30) and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreensNotReferred))
SET @numOfTotalNegativeScreens40 = (SELECT count(*) FROM #tblMainCohort where  (pcage >= 30) and hvcasepk in (SELECT hvcasepk FROM #tblNegativeScreens))
SET @numOfTotalKempesCompleted40 = (SELECT count(*) FROM #tblMainCohort where  (pcage >= 30) and hvcasepk in (SELECT hvcasepk FROM #tblKempesCompleted))
SET @numOfTotalEnrolled40 = (SELECT count(*) FROM #tblMainCohort where  (pcage >= 30) and hvcasepk in (SELECT hvcasepk FROM #tblEnrolled))


INSERT INTO #tblScreenAnalysisSummary([Id],[Title],[SubGroupId],[TotalScreens],[PositiveScreens],[PositiveScreensNotReferred],[NegativeScreens],[KempesCompleted],[Enrolled])
VALUES(3, '    30 and Over', 10 
,CONVERT(VARCHAR,@numOfALLScreens40) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfALLScreens40 AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreens40) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreens40 AS FLOAT) * 100/ NULLIF(@numOfALLScreens40,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreensNotReferred40) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreensNotReferred40 AS FLOAT) * 100/ NULLIF(@numOfALLScreens40,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalNegativeScreens40) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalNegativeScreens40 AS FLOAT) * 100/ NULLIF(@numOfALLScreens40,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalKempesCompleted40) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalKempesCompleted40 AS FLOAT) * 100/ NULLIF(@numOfALLScreens40,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalEnrolled40) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalEnrolled40 AS FLOAT) * 100/ NULLIF(@numOfALLScreens40,0), 0), 0))  + '%)'
)



/*************************************************/
-- add the title for parent age in the row
INSERT INTO #tblScreenAnalysisSummary([Id],[Title],[SubGroupId],[TotalScreens],[PositiveScreens],[PositiveScreensNotReferred],[NegativeScreens],[KempesCompleted],[Enrolled])
VALUES(4, 'Timing of Screen', 11, '', '', '', '', '', '')  


---- calcualte Timing of Screen - First Trimester
DECLARE @numOfALLScreens41 INT = 0
DECLARE @numOfTotalPositiveScreens41 INT = 0
DECLARE @numOfTotalPositiveScreensNotReferred41 INT = 0
DECLARE @numOfTotalNegativeScreens41 INT = 0
DECLARE @numOfTotalKempesCompleted41 INT = 0
DECLARE @numOfTotalEnrolled41 INT = 0


SET @numOfALLScreens41 = (SELECT count(*) FROM #tblMainCohort where datediff(ww, ConceptionDate, ScreenDate) <= 13)
SET @numOfTotalPositiveScreens41 = (SELECT count(*) FROM #tblMainCohort where  (datediff(ww, ConceptionDate, ScreenDate) <= 13) and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreens))
SET @numOfTotalPositiveScreensNotReferred41 = (SELECT count(*) FROM #tblMainCohort where  (datediff(ww, ConceptionDate, ScreenDate) <= 13) and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreensNotReferred))
SET @numOfTotalNegativeScreens41 = (SELECT count(*) FROM #tblMainCohort where  (datediff(ww, ConceptionDate, ScreenDate) <= 13) and hvcasepk in (SELECT hvcasepk FROM #tblNegativeScreens))
SET @numOfTotalKempesCompleted41 = (SELECT count(*) FROM #tblMainCohort where  (datediff(ww, ConceptionDate, ScreenDate) <= 13) and hvcasepk in (SELECT hvcasepk FROM #tblKempesCompleted))
SET @numOfTotalEnrolled41 = (SELECT count(*) FROM #tblMainCohort where  (datediff(ww, ConceptionDate, ScreenDate) <= 13) and hvcasepk in (SELECT hvcasepk FROM #tblEnrolled))


INSERT INTO #tblScreenAnalysisSummary([Id],[Title],[SubGroupId],[TotalScreens],[PositiveScreens],[PositiveScreensNotReferred],[NegativeScreens],[KempesCompleted],[Enrolled])
VALUES(4, '    First Trimester (0-13 weeks)', 12 
,CONVERT(VARCHAR,@numOfALLScreens41) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfALLScreens41 AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreens41) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreens41 AS FLOAT) * 100/ NULLIF(@numOfALLScreens41,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreensNotReferred41) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreensNotReferred41 AS FLOAT) * 100/ NULLIF(@numOfALLScreens41,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalNegativeScreens41) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalNegativeScreens41 AS FLOAT) * 100/ NULLIF(@numOfALLScreens41,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalKempesCompleted41) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalKempesCompleted41 AS FLOAT) * 100/ NULLIF(@numOfALLScreens41,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalEnrolled41) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalEnrolled41 AS FLOAT) * 100/ NULLIF(@numOfALLScreens41,0), 0), 0))  + '%)'
)


---- calcualte Timing of Screen - Second Trimester
DECLARE @numOfALLScreens42 INT = 0
DECLARE @numOfTotalPositiveScreens42 INT = 0
DECLARE @numOfTotalPositiveScreensNotReferred42 INT = 0
DECLARE @numOfTotalNegativeScreens42 INT = 0
DECLARE @numOfTotalKempesCompleted42 INT = 0
DECLARE @numOfTotalEnrolled42 INT = 0


SET @numOfALLScreens42 = (SELECT count(*) FROM #tblMainCohort where ((datediff(ww, ConceptionDate, ScreenDate) > 13) and (datediff(ww, ConceptionDate, ScreenDate) <= 26)))
SET @numOfTotalPositiveScreens42 = (SELECT count(*) FROM #tblMainCohort where  ((datediff(ww, ConceptionDate, ScreenDate) > 13) and (datediff(ww, ConceptionDate, ScreenDate) <= 26)) and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreens))
SET @numOfTotalPositiveScreensNotReferred42 = (SELECT count(*) FROM #tblMainCohort where  ((datediff(ww, ConceptionDate, ScreenDate) > 13) and (datediff(ww, ConceptionDate, ScreenDate) <= 26)) and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreensNotReferred))
SET @numOfTotalNegativeScreens42 = (SELECT count(*) FROM #tblMainCohort where  ((datediff(ww, ConceptionDate, ScreenDate) > 13) and (datediff(ww, ConceptionDate, ScreenDate) <= 26)) and hvcasepk in (SELECT hvcasepk FROM #tblNegativeScreens))
SET @numOfTotalKempesCompleted42 = (SELECT count(*) FROM #tblMainCohort where  ((datediff(ww, ConceptionDate, ScreenDate) > 13) and (datediff(ww, ConceptionDate, ScreenDate) <= 26)) and hvcasepk in (SELECT hvcasepk FROM #tblKempesCompleted))
SET @numOfTotalEnrolled42 = (SELECT count(*) FROM #tblMainCohort where  ((datediff(ww, ConceptionDate, ScreenDate) > 13) and (datediff(ww, ConceptionDate, ScreenDate) <= 26)) and hvcasepk in (SELECT hvcasepk FROM #tblEnrolled))


INSERT INTO #tblScreenAnalysisSummary([Id],[Title],[SubGroupId],[TotalScreens],[PositiveScreens],[PositiveScreensNotReferred],[NegativeScreens],[KempesCompleted],[Enrolled])
VALUES(4, '    Second Trimester (14-26 weeks)', 13 
,CONVERT(VARCHAR,@numOfALLScreens42) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfALLScreens42 AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreens42) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreens42 AS FLOAT) * 100/ NULLIF(@numOfALLScreens42,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreensNotReferred42) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreensNotReferred42 AS FLOAT) * 100/ NULLIF(@numOfALLScreens42,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalNegativeScreens42) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalNegativeScreens42 AS FLOAT) * 100/ NULLIF(@numOfALLScreens42,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalKempesCompleted42) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalKempesCompleted42 AS FLOAT) * 100/ NULLIF(@numOfALLScreens42,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalEnrolled42) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalEnrolled42 AS FLOAT) * 100/ NULLIF(@numOfALLScreens42,0), 0), 0))  + '%)'
)


---- calcualte Timing of Screen - Third Trimester
DECLARE @numOfALLScreens43 INT = 0
DECLARE @numOfTotalPositiveScreens43 INT = 0
DECLARE @numOfTotalPositiveScreensNotReferred43 INT = 0
DECLARE @numOfTotalNegativeScreens43 INT = 0
DECLARE @numOfTotalKempesCompleted43 INT = 0
DECLARE @numOfTotalEnrolled43 INT = 0



--SET @numOfALLScreens43 = (SELECT count(*) FROM #tblMainCohort where datediff(ww, ConceptionDate, ScreenDate) > 26)
--SET @numOfTotalPositiveScreens43 = (SELECT count(*) FROM #tblMainCohort where  (datediff(ww, ConceptionDate, ScreenDate) > 26) and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreens))
--SET @numOfTotalPositiveScreensNotReferred43 = (SELECT count(*) FROM #tblMainCohort where  (datediff(ww, ConceptionDate, ScreenDate) > 26) and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreensNotReferred))
--SET @numOfTotalNegativeScreens43 = (SELECT count(*) FROM #tblMainCohort where  (datediff(ww, ConceptionDate, ScreenDate) > 26) and hvcasepk in (SELECT hvcasepk FROM #tblNegativeScreens))
--SET @numOfTotalKempesCompleted43 = (SELECT count(*) FROM #tblMainCohort where  (datediff(ww, ConceptionDate, ScreenDate) > 26) and hvcasepk in (SELECT hvcasepk FROM #tblKempesCompleted))
--SET @numOfTotalEnrolled43 = (SELECT count(*) FROM #tblMainCohort where  (datediff(ww, ConceptionDate, ScreenDate) > 26) and hvcasepk in (SELECT hvcasepk FROM #tblEnrolled))


SET @numOfALLScreens43 = (SELECT count(*) FROM #tblMainCohort where datediff(ww, ConceptionDate, ScreenDate) > 26 and (ScreenDate < babydate) )
SET @numOfTotalPositiveScreens43 = (SELECT count(*) FROM #tblMainCohort where  (datediff(ww, ConceptionDate, ScreenDate) > 26) and (ScreenDate < babydate)  and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreens))
SET @numOfTotalPositiveScreensNotReferred43 = (SELECT count(*) FROM #tblMainCohort where  (datediff(ww, ConceptionDate, ScreenDate) > 26) and (ScreenDate < babydate) and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreensNotReferred))
SET @numOfTotalNegativeScreens43 = (SELECT count(*) FROM #tblMainCohort where  (datediff(ww, ConceptionDate, ScreenDate) > 26) and (ScreenDate < babydate) and hvcasepk in (SELECT hvcasepk FROM #tblNegativeScreens))
SET @numOfTotalKempesCompleted43 = (SELECT count(*) FROM #tblMainCohort where  (datediff(ww, ConceptionDate, ScreenDate) > 26) and (ScreenDate < babydate) and hvcasepk in (SELECT hvcasepk FROM #tblKempesCompleted))
SET @numOfTotalEnrolled43 = (SELECT count(*) FROM #tblMainCohort where  (datediff(ww, ConceptionDate, ScreenDate) > 26) and (ScreenDate < babydate) and hvcasepk in (SELECT hvcasepk FROM #tblEnrolled))





INSERT INTO #tblScreenAnalysisSummary([Id],[Title],[SubGroupId],[TotalScreens],[PositiveScreens],[PositiveScreensNotReferred],[NegativeScreens],[KempesCompleted],[Enrolled])
VALUES(4, '    Third Trimester (27 weeks or greater)', 14 
,CONVERT(VARCHAR,@numOfALLScreens43) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfALLScreens43 AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreens43) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreens43 AS FLOAT) * 100/ NULLIF(@numOfALLScreens43,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreensNotReferred43) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreensNotReferred43 AS FLOAT) * 100/ NULLIF(@numOfALLScreens43,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalNegativeScreens43) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalNegativeScreens43 AS FLOAT) * 100/ NULLIF(@numOfALLScreens43,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalKempesCompleted43) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalKempesCompleted43 AS FLOAT) * 100/ NULLIF(@numOfALLScreens43,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalEnrolled43) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalEnrolled43 AS FLOAT) * 100/ NULLIF(@numOfALLScreens43,0), 0), 0))  + '%)'
)

---- calcualte Timing of Screen - Postnatal within 2 Weeks of Birth
DECLARE @numOfALLScreens44 INT = 0
DECLARE @numOfTotalPositiveScreens44 INT = 0
DECLARE @numOfTotalPositiveScreensNotReferred44 INT = 0
DECLARE @numOfTotalNegativeScreens44 INT = 0
DECLARE @numOfTotalKempesCompleted44 INT = 0
DECLARE @numOfTotalEnrolled44 INT = 0


SET @numOfALLScreens44 = (SELECT count(*) FROM #tblMainCohort where ScreenDate >= babydate and datediff(dd, babydate, ScreenDate) < 14)
SET @numOfTotalPositiveScreens44 = (SELECT count(*) FROM #tblMainCohort where  ScreenDate >= babydate and datediff(dd, babydate, ScreenDate) < 14 and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreens))
SET @numOfTotalPositiveScreensNotReferred44 = (SELECT count(*) FROM #tblMainCohort where  ScreenDate >= babydate and datediff(dd, babydate, ScreenDate) < 14 and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreensNotReferred))
SET @numOfTotalNegativeScreens44 = (SELECT count(*) FROM #tblMainCohort where  ScreenDate >= babydate and datediff(dd, babydate, ScreenDate) < 14 and hvcasepk in (SELECT hvcasepk FROM #tblNegativeScreens))
SET @numOfTotalKempesCompleted44 = (SELECT count(*) FROM #tblMainCohort where  ScreenDate >= babydate and datediff(dd, babydate, ScreenDate) < 14 and hvcasepk in (SELECT hvcasepk FROM #tblKempesCompleted))
SET @numOfTotalEnrolled44 = (SELECT count(*) FROM #tblMainCohort where  ScreenDate >= babydate and datediff(dd, babydate, ScreenDate) < 14 and hvcasepk in (SELECT hvcasepk FROM #tblEnrolled))


INSERT INTO #tblScreenAnalysisSummary([Id],[Title],[SubGroupId],[TotalScreens],[PositiveScreens],[PositiveScreensNotReferred],[NegativeScreens],[KempesCompleted],[Enrolled])
VALUES(4, '    Postnatal within 2 Weeks of Birth', 15 
,CONVERT(VARCHAR,@numOfALLScreens44) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfALLScreens44 AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreens44) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreens44 AS FLOAT) * 100/ NULLIF(@numOfALLScreens44,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreensNotReferred44) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreensNotReferred44 AS FLOAT) * 100/ NULLIF(@numOfALLScreens44,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalNegativeScreens44) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalNegativeScreens44 AS FLOAT) * 100/ NULLIF(@numOfALLScreens44,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalKempesCompleted44) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalKempesCompleted44 AS FLOAT) * 100/ NULLIF(@numOfALLScreens44,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalEnrolled44) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalEnrolled44 AS FLOAT) * 100/ NULLIF(@numOfALLScreens44,0), 0), 0))  + '%)'
)


---- calcualte Timing of Screen - Postnatal 2 or more Weeks After the Birth

DECLARE @numOfALLScreens45 INT = 0
DECLARE @numOfTotalPositiveScreens45 INT = 0
DECLARE @numOfTotalPositiveScreensNotReferred45 INT = 0
DECLARE @numOfTotalNegativeScreens45 INT = 0
DECLARE @numOfTotalKempesCompleted45 INT = 0
DECLARE @numOfTotalEnrolled45 INT = 0


SET @numOfALLScreens45 = (SELECT count(*) FROM #tblMainCohort where ScreenDate >= babydate and datediff(dd, babydate, ScreenDate) >= 14)
SET @numOfTotalPositiveScreens45 = (SELECT count(*) FROM #tblMainCohort where  ScreenDate >= babydate and datediff(dd, babydate, ScreenDate) >= 14 and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreens))
SET @numOfTotalPositiveScreensNotReferred45 = (SELECT count(*) FROM #tblMainCohort where  ScreenDate >= babydate and datediff(dd, babydate, ScreenDate) >= 14 and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreensNotReferred))
SET @numOfTotalNegativeScreens45 = (SELECT count(*) FROM #tblMainCohort where  ScreenDate >= babydate and datediff(dd, babydate, ScreenDate) >= 14 and hvcasepk in (SELECT hvcasepk FROM #tblNegativeScreens))
SET @numOfTotalKempesCompleted45 = (SELECT count(*) FROM #tblMainCohort where  ScreenDate >= babydate and datediff(dd, babydate, ScreenDate) >= 14 and hvcasepk in (SELECT hvcasepk FROM #tblKempesCompleted))
SET @numOfTotalEnrolled45 = (SELECT count(*) FROM #tblMainCohort where  ScreenDate >= babydate and datediff(dd, babydate, ScreenDate) >= 14 and hvcasepk in (SELECT hvcasepk FROM #tblEnrolled))


INSERT INTO #tblScreenAnalysisSummary([Id],[Title],[SubGroupId],[TotalScreens],[PositiveScreens],[PositiveScreensNotReferred],[NegativeScreens],[KempesCompleted],[Enrolled])
VALUES(4, '    Postnatal 2 or more Weeks After the Birth', 16 
,CONVERT(VARCHAR,@numOfALLScreens45) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfALLScreens45 AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreens45) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreens45 AS FLOAT) * 100/ NULLIF(@numOfALLScreens45,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreensNotReferred45) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreensNotReferred45 AS FLOAT) * 100/ NULLIF(@numOfALLScreens45,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalNegativeScreens45) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalNegativeScreens45 AS FLOAT) * 100/ NULLIF(@numOfALLScreens45,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalKempesCompleted45) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalKempesCompleted45 AS FLOAT) * 100/ NULLIF(@numOfALLScreens45,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalEnrolled45) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalEnrolled45 AS FLOAT) * 100/ NULLIF(@numOfALLScreens45,0), 0), 0))  + '%)'
)



/*************************************************/
-- add the title for Race/Ethnicity in the row
INSERT INTO #tblScreenAnalysisSummary([Id],[Title],[SubGroupId],[TotalScreens],[PositiveScreens],[PositiveScreensNotReferred],[NegativeScreens],[KempesCompleted],[Enrolled])
VALUES(5, 'Race / Ethnicity', 17, '', '', '', '', '', '')  



---- calcualte Race/Ethnicity - White, non-Hispanic
DECLARE @numOfALLScreens46 INT = 0
DECLARE @numOfTotalPositiveScreens46 INT = 0
DECLARE @numOfTotalPositiveScreensNotReferred46 INT = 0
DECLARE @numOfTotalNegativeScreens46 INT = 0
DECLARE @numOfTotalKempesCompleted46 INT = 0
DECLARE @numOfTotalEnrolled46 INT = 0

--01 = White, non-Hispanic
--02 = Black, non-Hispanic
--03 = Hispanic/Latina/Latino   
--04 = Asian              
--05 = Native American    
--06 = Multiracial        
--07 = Other 

SET @numOfALLScreens46 = (SELECT count(*) FROM #tblMainCohort where Race = '01')
SET @numOfTotalPositiveScreens46 = (SELECT count(*) FROM #tblMainCohort where Race = '01' and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreens))
SET @numOfTotalPositiveScreensNotReferred46 = (SELECT count(*) FROM #tblMainCohort where Race = '01' and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreensNotReferred))
SET @numOfTotalNegativeScreens46 = (SELECT count(*) FROM #tblMainCohort where Race = '01' and hvcasepk in (SELECT hvcasepk FROM #tblNegativeScreens))
SET @numOfTotalKempesCompleted46 = (SELECT count(*) FROM #tblMainCohort where Race = '01' and hvcasepk in (SELECT hvcasepk FROM #tblKempesCompleted))
SET @numOfTotalEnrolled46 = (SELECT count(*) FROM #tblMainCohort where Race = '01' and hvcasepk in (SELECT hvcasepk FROM #tblEnrolled))


INSERT INTO #tblScreenAnalysisSummary([Id],[Title],[SubGroupId],[TotalScreens],[PositiveScreens],[PositiveScreensNotReferred],[NegativeScreens],[KempesCompleted],[Enrolled])
VALUES(5, '    White, non-Hispanic', 18 
,CONVERT(VARCHAR,@numOfALLScreens46) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfALLScreens46 AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreens46) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreens46 AS FLOAT) * 100/ NULLIF(@numOfALLScreens46,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreensNotReferred46) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreensNotReferred46 AS FLOAT) * 100/ NULLIF(@numOfALLScreens46,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalNegativeScreens46) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalNegativeScreens46 AS FLOAT) * 100/ NULLIF(@numOfALLScreens46,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalKempesCompleted46) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalKempesCompleted46 AS FLOAT) * 100/ NULLIF(@numOfALLScreens46,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalEnrolled46) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalEnrolled46 AS FLOAT) * 100/ NULLIF(@numOfALLScreens46,0), 0), 0))  + '%)'
)

---- calcualte Race/Ethnicity - Black, non-Hispanic
DECLARE @numOfALLScreens47 INT = 0
DECLARE @numOfTotalPositiveScreens47 INT = 0
DECLARE @numOfTotalPositiveScreensNotReferred47 INT = 0
DECLARE @numOfTotalNegativeScreens47 INT = 0
DECLARE @numOfTotalKempesCompleted47 INT = 0
DECLARE @numOfTotalEnrolled47 INT = 0

--02 = Black, non-Hispanic
--03 = Hispanic/Latina/Latino   
--04 = Asian              
--05 = Native American    
--06 = Multiracial        
--07 = Other 

SET @numOfALLScreens47 = (SELECT count(*) FROM #tblMainCohort where Race = '02')
SET @numOfTotalPositiveScreens47 = (SELECT count(*) FROM #tblMainCohort where Race = '02' and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreens))
SET @numOfTotalPositiveScreensNotReferred47 = (SELECT count(*) FROM #tblMainCohort where Race = '02' and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreensNotReferred))
SET @numOfTotalNegativeScreens47 = (SELECT count(*) FROM #tblMainCohort where Race = '02' and hvcasepk in (SELECT hvcasepk FROM #tblNegativeScreens))
SET @numOfTotalKempesCompleted47 = (SELECT count(*) FROM #tblMainCohort where Race = '02' and hvcasepk in (SELECT hvcasepk FROM #tblKempesCompleted))
SET @numOfTotalEnrolled47 = (SELECT count(*) FROM #tblMainCohort where Race = '02' and hvcasepk in (SELECT hvcasepk FROM #tblEnrolled))


INSERT INTO #tblScreenAnalysisSummary([Id],[Title],[SubGroupId],[TotalScreens],[PositiveScreens],[PositiveScreensNotReferred],[NegativeScreens],[KempesCompleted],[Enrolled])
VALUES(5, '    Black, non-Hispanic', 19 
,CONVERT(VARCHAR,@numOfALLScreens47) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfALLScreens47 AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreens47) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreens47 AS FLOAT) * 100/ NULLIF(@numOfALLScreens47,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreensNotReferred47) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreensNotReferred47 AS FLOAT) * 100/ NULLIF(@numOfALLScreens47,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalNegativeScreens47) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalNegativeScreens47 AS FLOAT) * 100/ NULLIF(@numOfALLScreens47,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalKempesCompleted47) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalKempesCompleted47 AS FLOAT) * 100/ NULLIF(@numOfALLScreens47,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalEnrolled47) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalEnrolled47 AS FLOAT) * 100/ NULLIF(@numOfALLScreens47,0), 0), 0))  + '%)'
)


---- calcualte Race/Ethnicity - Hispanic/Latina/Latino   
DECLARE @numOfALLScreens48 INT = 0
DECLARE @numOfTotalPositiveScreens48 INT = 0
DECLARE @numOfTotalPositiveScreensNotReferred48 INT = 0
DECLARE @numOfTotalNegativeScreens48 INT = 0
DECLARE @numOfTotalKempesCompleted48 INT = 0
DECLARE @numOfTotalEnrolled48 INT = 0
                                                                      
--04 = Asian              
--05 = Native American    
--06 = Multiracial        
--07 = Other 

SET @numOfALLScreens48 = (SELECT count(*) FROM #tblMainCohort where Race = '03')
SET @numOfTotalPositiveScreens48 = (SELECT count(*) FROM #tblMainCohort where Race = '03' and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreens))
SET @numOfTotalPositiveScreensNotReferred48 = (SELECT count(*) FROM #tblMainCohort where Race = '03' and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreensNotReferred))
SET @numOfTotalNegativeScreens48 = (SELECT count(*) FROM #tblMainCohort where Race = '03' and hvcasepk in (SELECT hvcasepk FROM #tblNegativeScreens))
SET @numOfTotalKempesCompleted48 = (SELECT count(*) FROM #tblMainCohort where Race = '03' and hvcasepk in (SELECT hvcasepk FROM #tblKempesCompleted))
SET @numOfTotalEnrolled48 = (SELECT count(*) FROM #tblMainCohort where Race = '03' and hvcasepk in (SELECT hvcasepk FROM #tblEnrolled))


INSERT INTO #tblScreenAnalysisSummary([Id],[Title],[SubGroupId],[TotalScreens],[PositiveScreens],[PositiveScreensNotReferred],[NegativeScreens],[KempesCompleted],[Enrolled])
VALUES(5, '    Hispanic/Latina/Latino', 20 
,CONVERT(VARCHAR,@numOfALLScreens48) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfALLScreens48 AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreens48) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreens48 AS FLOAT) * 100/ NULLIF(@numOfALLScreens48,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreensNotReferred48) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreensNotReferred48 AS FLOAT) * 100/ NULLIF(@numOfALLScreens48,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalNegativeScreens48) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalNegativeScreens48 AS FLOAT) * 100/ NULLIF(@numOfALLScreens48,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalKempesCompleted48) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalKempesCompleted48 AS FLOAT) * 100/ NULLIF(@numOfALLScreens48,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalEnrolled48) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalEnrolled48 AS FLOAT) * 100/ NULLIF(@numOfALLScreens48,0), 0), 0))  + '%)'
)


---- calcualte Race/Ethnicity - Asian   
DECLARE @numOfALLScreens49 INT = 0
DECLARE @numOfTotalPositiveScreens49 INT = 0
DECLARE @numOfTotalPositiveScreensNotReferred49 INT = 0
DECLARE @numOfTotalNegativeScreens49 INT = 0
DECLARE @numOfTotalKempesCompleted49 INT = 0
DECLARE @numOfTotalEnrolled49 INT = 0                                                                     
         
--05 = Native American    
--06 = Multiracial        
--07 = Other 

SET @numOfALLScreens49 = (SELECT count(*) FROM #tblMainCohort where Race = '04')
SET @numOfTotalPositiveScreens49 = (SELECT count(*) FROM #tblMainCohort where Race = '04' and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreens))
SET @numOfTotalPositiveScreensNotReferred49 = (SELECT count(*) FROM #tblMainCohort where Race = '04' and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreensNotReferred))
SET @numOfTotalNegativeScreens49 = (SELECT count(*) FROM #tblMainCohort where Race = '04' and hvcasepk in (SELECT hvcasepk FROM #tblNegativeScreens))
SET @numOfTotalKempesCompleted49 = (SELECT count(*) FROM #tblMainCohort where Race = '04' and hvcasepk in (SELECT hvcasepk FROM #tblKempesCompleted))
SET @numOfTotalEnrolled49 = (SELECT count(*) FROM #tblMainCohort where Race = '04' and hvcasepk in (SELECT hvcasepk FROM #tblEnrolled))


INSERT INTO #tblScreenAnalysisSummary([Id],[Title],[SubGroupId],[TotalScreens],[PositiveScreens],[PositiveScreensNotReferred],[NegativeScreens],[KempesCompleted],[Enrolled])
VALUES(5, '    Asian', 21 
,CONVERT(VARCHAR,@numOfALLScreens49) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfALLScreens49 AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreens49) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreens49 AS FLOAT) * 100/ NULLIF(@numOfALLScreens49,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreensNotReferred49) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreensNotReferred49 AS FLOAT) * 100/ NULLIF(@numOfALLScreens49,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalNegativeScreens49) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalNegativeScreens49 AS FLOAT) * 100/ NULLIF(@numOfALLScreens49,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalKempesCompleted49) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalKempesCompleted49 AS FLOAT) * 100/ NULLIF(@numOfALLScreens49,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalEnrolled49) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalEnrolled49 AS FLOAT) * 100/ NULLIF(@numOfALLScreens49,0), 0), 0))  + '%)'
)

---- calcualte Race/Ethnicity - Native American   
DECLARE @numOfALLScreens50 INT = 0
DECLARE @numOfTotalPositiveScreens50 INT = 0
DECLARE @numOfTotalPositiveScreensNotReferred50 INT = 0
DECLARE @numOfTotalNegativeScreens50 INT = 0
DECLARE @numOfTotalKempesCompleted50 INT = 0
DECLARE @numOfTotalEnrolled50 INT = 0                                                                     
         
--05 = Native American    
--06 = Multiracial        
--07 = Other 

SET @numOfALLScreens50 = (SELECT count(*) FROM #tblMainCohort where Race = '05')
SET @numOfTotalPositiveScreens50 = (SELECT count(*) FROM #tblMainCohort where Race = '05' and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreens))
SET @numOfTotalPositiveScreensNotReferred50 = (SELECT count(*) FROM #tblMainCohort where Race = '05' and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreensNotReferred))
SET @numOfTotalNegativeScreens50 = (SELECT count(*) FROM #tblMainCohort where Race = '05' and hvcasepk in (SELECT hvcasepk FROM #tblNegativeScreens))
SET @numOfTotalKempesCompleted50 = (SELECT count(*) FROM #tblMainCohort where Race = '05' and hvcasepk in (SELECT hvcasepk FROM #tblKempesCompleted))
SET @numOfTotalEnrolled50 = (SELECT count(*) FROM #tblMainCohort where Race = '05' and hvcasepk in (SELECT hvcasepk FROM #tblEnrolled))


INSERT INTO #tblScreenAnalysisSummary([Id],[Title],[SubGroupId],[TotalScreens],[PositiveScreens],[PositiveScreensNotReferred],[NegativeScreens],[KempesCompleted],[Enrolled])
VALUES(5, '    Native American', 22 
,CONVERT(VARCHAR,@numOfALLScreens50) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfALLScreens50 AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreens50) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreens50 AS FLOAT) * 100/ NULLIF(@numOfALLScreens50,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreensNotReferred50) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreensNotReferred50 AS FLOAT) * 100/ NULLIF(@numOfALLScreens50,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalNegativeScreens50) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalNegativeScreens50 AS FLOAT) * 100/ NULLIF(@numOfALLScreens50,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalKempesCompleted50) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalKempesCompleted50 AS FLOAT) * 100/ NULLIF(@numOfALLScreens50,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalEnrolled50) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalEnrolled50 AS FLOAT) * 100/ NULLIF(@numOfALLScreens50,0), 0), 0))  + '%)'
)

---- calcualte Race/Ethnicity - Multiracial  
DECLARE @numOfALLScreens51 INT = 0
DECLARE @numOfTotalPositiveScreens51 INT = 0
DECLARE @numOfTotalPositiveScreensNotReferred51 INT = 0
DECLARE @numOfTotalNegativeScreens51 INT = 0
DECLARE @numOfTotalKempesCompleted51 INT = 0
DECLARE @numOfTotalEnrolled51 INT = 0                                                                     
         
--06 = Multiracial        
--07 = Other 

SET @numOfALLScreens51 = (SELECT count(*) FROM #tblMainCohort where Race = '06')
SET @numOfTotalPositiveScreens51 = (SELECT count(*) FROM #tblMainCohort where Race = '06' and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreens))
SET @numOfTotalPositiveScreensNotReferred51 = (SELECT count(*) FROM #tblMainCohort where Race = '06' and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreensNotReferred))
SET @numOfTotalNegativeScreens51 = (SELECT count(*) FROM #tblMainCohort where Race = '06' and hvcasepk in (SELECT hvcasepk FROM #tblNegativeScreens))
SET @numOfTotalKempesCompleted51 = (SELECT count(*) FROM #tblMainCohort where Race = '06' and hvcasepk in (SELECT hvcasepk FROM #tblKempesCompleted))
SET @numOfTotalEnrolled51 = (SELECT count(*) FROM #tblMainCohort where Race = '06' and hvcasepk in (SELECT hvcasepk FROM #tblEnrolled))


INSERT INTO #tblScreenAnalysisSummary([Id],[Title],[SubGroupId],[TotalScreens],[PositiveScreens],[PositiveScreensNotReferred],[NegativeScreens],[KempesCompleted],[Enrolled])
VALUES(5, '    Multiracial', 23 
,CONVERT(VARCHAR,@numOfALLScreens51) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfALLScreens51 AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreens51) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreens51 AS FLOAT) * 100/ NULLIF(@numOfALLScreens51,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreensNotReferred51) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreensNotReferred51 AS FLOAT) * 100/ NULLIF(@numOfALLScreens51,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalNegativeScreens51) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalNegativeScreens51 AS FLOAT) * 100/ NULLIF(@numOfALLScreens51,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalKempesCompleted51) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalKempesCompleted51 AS FLOAT) * 100/ NULLIF(@numOfALLScreens51,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalEnrolled51) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalEnrolled51 AS FLOAT) * 100/ NULLIF(@numOfALLScreens51,0), 0), 0))  + '%)'
)


---- calcualte Race/Ethnicity - Other  
DECLARE @numOfALLScreens52 INT = 0
DECLARE @numOfTotalPositiveScreens52 INT = 0
DECLARE @numOfTotalPositiveScreensNotReferred52 INT = 0
DECLARE @numOfTotalNegativeScreens52 INT = 0
DECLARE @numOfTotalKempesCompleted52 INT = 0
DECLARE @numOfTotalEnrolled52 INT = 0                                                                     
         
  
--07 = Other 

SET @numOfALLScreens52 = (SELECT count(*) FROM #tblMainCohort where Race = '07')
SET @numOfTotalPositiveScreens52 = (SELECT count(*) FROM #tblMainCohort where Race = '07' and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreens))
SET @numOfTotalPositiveScreensNotReferred52 = (SELECT count(*) FROM #tblMainCohort where Race = '07' and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreensNotReferred))
SET @numOfTotalNegativeScreens52 = (SELECT count(*) FROM #tblMainCohort where Race = '07' and hvcasepk in (SELECT hvcasepk FROM #tblNegativeScreens))
SET @numOfTotalKempesCompleted52 = (SELECT count(*) FROM #tblMainCohort where Race = '07' and hvcasepk in (SELECT hvcasepk FROM #tblKempesCompleted))
SET @numOfTotalEnrolled52 = (SELECT count(*) FROM #tblMainCohort where Race = '07' and hvcasepk in (SELECT hvcasepk FROM #tblEnrolled))


INSERT INTO #tblScreenAnalysisSummary([Id],[Title],[SubGroupId],[TotalScreens],[PositiveScreens],[PositiveScreensNotReferred],[NegativeScreens],[KempesCompleted],[Enrolled])
VALUES(5, '    Other', 24 
,CONVERT(VARCHAR,@numOfALLScreens52) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfALLScreens52 AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreens52) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreens52 AS FLOAT) * 100/ NULLIF(@numOfALLScreens52,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreensNotReferred52) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreensNotReferred52 AS FLOAT) * 100/ NULLIF(@numOfALLScreens52,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalNegativeScreens52) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalNegativeScreens52 AS FLOAT) * 100/ NULLIF(@numOfALLScreens52,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalKempesCompleted52) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalKempesCompleted52 AS FLOAT) * 100/ NULLIF(@numOfALLScreens52,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalEnrolled52) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalEnrolled52 AS FLOAT) * 100/ NULLIF(@numOfALLScreens52,0), 0), 0))  + '%)'
)

-- Here is the rest of the pc1' race - they did not tell what is their race
---- calcualte Race/Ethnicity - Missing  
DECLARE @numOfALLScreens53 INT = 0
DECLARE @numOfTotalPositiveScreens53 INT = 0
DECLARE @numOfTotalPositiveScreensNotReferred53 INT = 0
DECLARE @numOfTotalNegativeScreens53 INT = 0
DECLARE @numOfTotalKempesCompleted53 INT = 0
DECLARE @numOfTotalEnrolled53 INT = 0  


SET @numOfALLScreens53 = (SELECT count(*) FROM #tblMainCohort where Race is null)
SET @numOfTotalPositiveScreens53 = (SELECT count(*) FROM #tblMainCohort where Race is null and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreens))
SET @numOfTotalPositiveScreensNotReferred53 = (SELECT count(*) FROM #tblMainCohort where Race is null and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreensNotReferred))
SET @numOfTotalNegativeScreens53 = (SELECT count(*) FROM #tblMainCohort where Race is null and hvcasepk in (SELECT hvcasepk FROM #tblNegativeScreens))
SET @numOfTotalKempesCompleted53 = (SELECT count(*) FROM #tblMainCohort where Race is null and hvcasepk in (SELECT hvcasepk FROM #tblKempesCompleted))
SET @numOfTotalEnrolled53 = (SELECT count(*) FROM #tblMainCohort where Race is null and hvcasepk in (SELECT hvcasepk FROM #tblEnrolled))


INSERT INTO #tblScreenAnalysisSummary([Id],[Title],[SubGroupId],[TotalScreens],[PositiveScreens],[PositiveScreensNotReferred],[NegativeScreens],[KempesCompleted],[Enrolled])
VALUES(5, '    Missing', 25 
,CONVERT(VARCHAR,@numOfALLScreens53) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfALLScreens53 AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreens53) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreens53 AS FLOAT) * 100/ NULLIF(@numOfALLScreens53,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreensNotReferred53) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreensNotReferred53 AS FLOAT) * 100/ NULLIF(@numOfALLScreens53,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalNegativeScreens53) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalNegativeScreens53 AS FLOAT) * 100/ NULLIF(@numOfALLScreens53,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalKempesCompleted53) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalKempesCompleted53 AS FLOAT) * 100/ NULLIF(@numOfALLScreens53,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalEnrolled53) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalEnrolled53 AS FLOAT) * 100/ NULLIF(@numOfALLScreens53,0), 0), 0))  + '%)'
)


/*************************************************/
-- add the title for Target Area in the row
INSERT INTO #tblScreenAnalysisSummary([Id],[Title],[SubGroupId],[TotalScreens],[PositiveScreens],[PositiveScreensNotReferred],[NegativeScreens],[KempesCompleted],[Enrolled])
VALUES(6, 'Target Area', 26, '', '', '', '', '', '')  

---- calcualte Target Area - Yes  
DECLARE @numOfALLScreens54 INT = 0
DECLARE @numOfTotalPositiveScreens54 INT = 0
DECLARE @numOfTotalPositiveScreensNotReferred54 INT = 0
DECLARE @numOfTotalNegativeScreens54 INT = 0
DECLARE @numOfTotalKempesCompleted54 INT = 0
DECLARE @numOfTotalEnrolled54 INT = 0  


SET @numOfALLScreens54 = (SELECT count(*) FROM #tblMainCohort where TargetArea = 'Y' or TargetArea = '1')
SET @numOfTotalPositiveScreens54 = (SELECT count(*) FROM #tblMainCohort where TargetArea = 'Y' or TargetArea = '1' and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreens))
SET @numOfTotalPositiveScreensNotReferred54 = (SELECT count(*) FROM #tblMainCohort where TargetArea = 'Y' or TargetArea = '1' and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreensNotReferred))
SET @numOfTotalNegativeScreens54 = (SELECT count(*) FROM #tblMainCohort where TargetArea = 'Y' or TargetArea = '1' and hvcasepk in (SELECT hvcasepk FROM #tblNegativeScreens))
SET @numOfTotalKempesCompleted54 = (SELECT count(*) FROM #tblMainCohort where TargetArea = 'Y' or TargetArea = '1' and hvcasepk in (SELECT hvcasepk FROM #tblKempesCompleted))
SET @numOfTotalEnrolled54 = (SELECT count(*) FROM #tblMainCohort where TargetArea = 'Y' or TargetArea = '1' and hvcasepk in (SELECT hvcasepk FROM #tblEnrolled))


INSERT INTO #tblScreenAnalysisSummary([Id],[Title],[SubGroupId],[TotalScreens],[PositiveScreens],[PositiveScreensNotReferred],[NegativeScreens],[KempesCompleted],[Enrolled])
VALUES(6, '    Yes', 27 
,CONVERT(VARCHAR,@numOfALLScreens54) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfALLScreens54 AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreens54) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreens54 AS FLOAT) * 100/ NULLIF(@numOfALLScreens54,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreensNotReferred54) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreensNotReferred54 AS FLOAT) * 100/ NULLIF(@numOfALLScreens54,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalNegativeScreens54) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalNegativeScreens54 AS FLOAT) * 100/ NULLIF(@numOfALLScreens54,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalKempesCompleted54) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalKempesCompleted54 AS FLOAT) * 100/ NULLIF(@numOfALLScreens54,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalEnrolled54) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalEnrolled54 AS FLOAT) * 100/ NULLIF(@numOfALLScreens54,0), 0), 0))  + '%)'
)

---- calcualte Target Area - No  
DECLARE @numOfALLScreens55 INT = 0
DECLARE @numOfTotalPositiveScreens55 INT = 0
DECLARE @numOfTotalPositiveScreensNotReferred55 INT = 0
DECLARE @numOfTotalNegativeScreens55 INT = 0
DECLARE @numOfTotalKempesCompleted55 INT = 0
DECLARE @numOfTotalEnrolled55 INT = 0  


SET @numOfALLScreens55 = (SELECT count(*) FROM #tblMainCohort where TargetArea = 'N' or TargetArea = '0')
SET @numOfTotalPositiveScreens55 = (SELECT count(*) FROM #tblMainCohort where TargetArea = 'N' or TargetArea = '0' and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreens))
SET @numOfTotalPositiveScreensNotReferred55 = (SELECT count(*) FROM #tblMainCohort where TargetArea = 'N' or TargetArea = '0' and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreensNotReferred))
SET @numOfTotalNegativeScreens55 = (SELECT count(*) FROM #tblMainCohort where TargetArea = 'N' or TargetArea = '0' and hvcasepk in (SELECT hvcasepk FROM #tblNegativeScreens))
SET @numOfTotalKempesCompleted55 = (SELECT count(*) FROM #tblMainCohort where TargetArea = 'N' or TargetArea = '0' and hvcasepk in (SELECT hvcasepk FROM #tblKempesCompleted))
SET @numOfTotalEnrolled55 = (SELECT count(*) FROM #tblMainCohort where TargetArea = 'N' or TargetArea = '0' and hvcasepk in (SELECT hvcasepk FROM #tblEnrolled))


INSERT INTO #tblScreenAnalysisSummary([Id],[Title],[SubGroupId],[TotalScreens],[PositiveScreens],[PositiveScreensNotReferred],[NegativeScreens],[KempesCompleted],[Enrolled])
VALUES(6, '    No', 28 
,CONVERT(VARCHAR,@numOfALLScreens55) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfALLScreens55 AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreens55) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreens55 AS FLOAT) * 100/ NULLIF(@numOfALLScreens55,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreensNotReferred55) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreensNotReferred55 AS FLOAT) * 100/ NULLIF(@numOfALLScreens55,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalNegativeScreens55) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalNegativeScreens55 AS FLOAT) * 100/ NULLIF(@numOfALLScreens55,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalKempesCompleted55) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalKempesCompleted55 AS FLOAT) * 100/ NULLIF(@numOfALLScreens55,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalEnrolled55) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalEnrolled55 AS FLOAT) * 100/ NULLIF(@numOfALLScreens55,0), 0), 0))  + '%)'
)

---- calcualte Target Area - Other  
DECLARE @numOfALLScreens56 INT = 0
DECLARE @numOfTotalPositiveScreens56 INT = 0
DECLARE @numOfTotalPositiveScreensNotReferred56 INT = 0
DECLARE @numOfTotalNegativeScreens56 INT = 0
DECLARE @numOfTotalKempesCompleted56 INT = 0
DECLARE @numOfTotalEnrolled56 INT = 0  


SET @numOfALLScreens56 = (SELECT count(*) FROM #tblMainCohort where TargetArea = '9')
SET @numOfTotalPositiveScreens56 = (SELECT count(*) FROM #tblMainCohort where TargetArea = '9' and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreens))
SET @numOfTotalPositiveScreensNotReferred56 = (SELECT count(*) FROM #tblMainCohort where TargetArea = '9' and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreensNotReferred))
SET @numOfTotalNegativeScreens56 = (SELECT count(*) FROM #tblMainCohort where TargetArea = '9' and hvcasepk in (SELECT hvcasepk FROM #tblNegativeScreens))
SET @numOfTotalKempesCompleted56 = (SELECT count(*) FROM #tblMainCohort where TargetArea = '9' and hvcasepk in (SELECT hvcasepk FROM #tblKempesCompleted))
SET @numOfTotalEnrolled56 = (SELECT count(*) FROM #tblMainCohort where TargetArea = '9' and hvcasepk in (SELECT hvcasepk FROM #tblEnrolled))


INSERT INTO #tblScreenAnalysisSummary([Id],[Title],[SubGroupId],[TotalScreens],[PositiveScreens],[PositiveScreensNotReferred],[NegativeScreens],[KempesCompleted],[Enrolled])
VALUES(6, '    Unknown', 29 
,CONVERT(VARCHAR,@numOfALLScreens56) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfALLScreens56 AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreens56) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreens56 AS FLOAT) * 100/ NULLIF(@numOfALLScreens56,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreensNotReferred56) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreensNotReferred56 AS FLOAT) * 100/ NULLIF(@numOfALLScreens56,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalNegativeScreens56) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalNegativeScreens56 AS FLOAT) * 100/ NULLIF(@numOfALLScreens56,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalKempesCompleted56) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalKempesCompleted56 AS FLOAT) * 100/ NULLIF(@numOfALLScreens56,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalEnrolled56) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalEnrolled56 AS FLOAT) * 100/ NULLIF(@numOfALLScreens56,0), 0), 0))  + '%)'
)


-- Here is the rest of the pc1' Target Area - they did not tell waht is their Target Area
---- calcualte Target Area  - Missing  
DECLARE @numOfALLScreens561 INT = 0
DECLARE @numOfTotalPositiveScreens561 INT = 0
DECLARE @numOfTotalPositiveScreensNotReferred561 INT = 0
DECLARE @numOfTotalNegativeScreens561 INT = 0
DECLARE @numOfTotalKempesCompleted561 INT = 0
DECLARE @numOfTotalEnrolled561 INT = 0  


SET @numOfALLScreens561 = (SELECT count(*) FROM #tblMainCohort where TargetArea is null or  TargetArea = '-')
SET @numOfTotalPositiveScreens561 = (SELECT count(*) FROM #tblMainCohort where TargetArea is null or  TargetArea = '-' and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreens))
SET @numOfTotalPositiveScreensNotReferred561 = (SELECT count(*) FROM #tblMainCohort where TargetArea is null or  TargetArea = '-' and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreensNotReferred))
SET @numOfTotalNegativeScreens561 = (SELECT count(*) FROM #tblMainCohort where TargetArea is null or  TargetArea = '-' and hvcasepk in (SELECT hvcasepk FROM #tblNegativeScreens))
SET @numOfTotalKempesCompleted561 = (SELECT count(*) FROM #tblMainCohort where TargetArea is null or  TargetArea = '-' and hvcasepk in (SELECT hvcasepk FROM #tblKempesCompleted))
SET @numOfTotalEnrolled561 = (SELECT count(*) FROM #tblMainCohort where TargetArea is null or  TargetArea = '-' and hvcasepk in (SELECT hvcasepk FROM #tblEnrolled))


INSERT INTO #tblScreenAnalysisSummary([Id],[Title],[SubGroupId],[TotalScreens],[PositiveScreens],[PositiveScreensNotReferred],[NegativeScreens],[KempesCompleted],[Enrolled])
VALUES(6, '    Missing', 29
,CONVERT(VARCHAR,@numOfALLScreens561) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfALLScreens561 AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreens561) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreens561 AS FLOAT) * 100/ NULLIF(@numOfALLScreens561,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreensNotReferred561) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreensNotReferred561 AS FLOAT) * 100/ NULLIF(@numOfALLScreens561,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalNegativeScreens561) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalNegativeScreens561 AS FLOAT) * 100/ NULLIF(@numOfALLScreens561,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalKempesCompleted561) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalKempesCompleted561 AS FLOAT) * 100/ NULLIF(@numOfALLScreens561,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalEnrolled561) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalEnrolled561 AS FLOAT) * 100/ NULLIF(@numOfALLScreens561,0), 0), 0))  + '%)'
)

/*************************************************/
-- add the title for Biological Parents in the row
INSERT INTO #tblScreenAnalysisSummary([Id],[Title],[SubGroupId],[TotalScreens],[PositiveScreens],[PositiveScreensNotReferred],[NegativeScreens],[KempesCompleted],[Enrolled])
VALUES(7, 'OBP In Home', 30, '', '', '', '', '', '')  

---- calcualte Biological Parents- Yes  
DECLARE @numOfALLScreens57 INT = 0
DECLARE @numOfTotalPositiveScreens57 INT = 0
DECLARE @numOfTotalPositiveScreensNotReferred57 INT = 0
DECLARE @numOfTotalNegativeScreens57 INT = 0
DECLARE @numOfTotalKempesCompleted57 INT = 0
DECLARE @numOfTotalEnrolled57 INT = 0  


SET @numOfALLScreens57 = (SELECT count(*) FROM #tblMainCohort where OBPInHome = '1')
SET @numOfTotalPositiveScreens57 = (SELECT count(*) FROM #tblMainCohort where OBPInHome = '1' and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreens))
SET @numOfTotalPositiveScreensNotReferred57 = (SELECT count(*) FROM #tblMainCohort where OBPInHome = '1' and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreensNotReferred))
SET @numOfTotalNegativeScreens57 = (SELECT count(*) FROM #tblMainCohort where OBPInHome = '1' and hvcasepk in (SELECT hvcasepk FROM #tblNegativeScreens))
SET @numOfTotalKempesCompleted57 = (SELECT count(*) FROM #tblMainCohort where OBPInHome = '1' and hvcasepk in (SELECT hvcasepk FROM #tblKempesCompleted))
SET @numOfTotalEnrolled57 = (SELECT count(*) FROM #tblMainCohort where OBPInHome = '1' and hvcasepk in (SELECT hvcasepk FROM #tblEnrolled))


INSERT INTO #tblScreenAnalysisSummary([Id],[Title],[SubGroupId],[TotalScreens],[PositiveScreens],[PositiveScreensNotReferred],[NegativeScreens],[KempesCompleted],[Enrolled])
VALUES(7, '    Yes', 31 
,CONVERT(VARCHAR,@numOfALLScreens57) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfALLScreens57 AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreens57) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreens57 AS FLOAT) * 100/ NULLIF(@numOfALLScreens57,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreensNotReferred57) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreensNotReferred57 AS FLOAT) * 100/ NULLIF(@numOfALLScreens57,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalNegativeScreens57) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalNegativeScreens57 AS FLOAT) * 100/ NULLIF(@numOfALLScreens57,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalKempesCompleted57) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalKempesCompleted57 AS FLOAT) * 100/ NULLIF(@numOfALLScreens57,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalEnrolled57) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalEnrolled57 AS FLOAT) * 100/ NULLIF(@numOfALLScreens57,0), 0), 0))  + '%)'
)

---- calcualte Biological Parents - No  
DECLARE @numOfALLScreens58 INT = 0
DECLARE @numOfTotalPositiveScreens58 INT = 0
DECLARE @numOfTotalPositiveScreensNotReferred58 INT = 0
DECLARE @numOfTotalNegativeScreens58 INT = 0
DECLARE @numOfTotalKempesCompleted58 INT = 0
DECLARE @numOfTotalEnrolled58 INT = 0  


SET @numOfALLScreens58 = (SELECT count(*) FROM #tblMainCohort where OBPInHome = '0')
SET @numOfTotalPositiveScreens58 = (SELECT count(*) FROM #tblMainCohort where OBPInHome = '0' and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreens))
SET @numOfTotalPositiveScreensNotReferred58 = (SELECT count(*) FROM #tblMainCohort where OBPInHome = '0' and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreensNotReferred))
SET @numOfTotalNegativeScreens58 = (SELECT count(*) FROM #tblMainCohort where OBPInHome = '0' and hvcasepk in (SELECT hvcasepk FROM #tblNegativeScreens))
SET @numOfTotalKempesCompleted58 = (SELECT count(*) FROM #tblMainCohort where OBPInHome = '0' and hvcasepk in (SELECT hvcasepk FROM #tblKempesCompleted))
SET @numOfTotalEnrolled58 = (SELECT count(*) FROM #tblMainCohort where OBPInHome = '0' and hvcasepk in (SELECT hvcasepk FROM #tblEnrolled))


INSERT INTO #tblScreenAnalysisSummary([Id],[Title],[SubGroupId],[TotalScreens],[PositiveScreens],[PositiveScreensNotReferred],[NegativeScreens],[KempesCompleted],[Enrolled])
VALUES(7, '    No', 32 
,CONVERT(VARCHAR,@numOfALLScreens58) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfALLScreens58 AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreens58) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreens58 AS FLOAT) * 100/ NULLIF(@numOfALLScreens58,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreensNotReferred58) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreensNotReferred58 AS FLOAT) * 100/ NULLIF(@numOfALLScreens58,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalNegativeScreens58) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalNegativeScreens58 AS FLOAT) * 100/ NULLIF(@numOfALLScreens58,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalKempesCompleted58) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalKempesCompleted58 AS FLOAT) * 100/ NULLIF(@numOfALLScreens58,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalEnrolled58) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalEnrolled58 AS FLOAT) * 100/ NULLIF(@numOfALLScreens58,0), 0), 0))  + '%)'
)


-- Here is the rest of the Biological Parents - they did not tell waht is their Biological Parents
---- calcualte Biological Parents  - Missing  
DECLARE @numOfALLScreens581 INT = 0
DECLARE @numOfTotalPositiveScreens581 INT = 0
DECLARE @numOfTotalPositiveScreensNotReferred581 INT = 0
DECLARE @numOfTotalNegativeScreens581 INT = 0
DECLARE @numOfTotalKempesCompleted581 INT = 0
DECLARE @numOfTotalEnrolled581 INT = 0  


SET @numOfALLScreens581 = (SELECT count(*) FROM #tblMainCohort where OBPInHome is null or  OBPInHome = '-')
SET @numOfTotalPositiveScreens581 = (SELECT count(*) FROM #tblMainCohort where OBPInHome is null or  OBPInHome = '-' and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreens))
SET @numOfTotalPositiveScreensNotReferred581 = (SELECT count(*) FROM #tblMainCohort where OBPInHome is null or  OBPInHome = '-' and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreensNotReferred))
SET @numOfTotalNegativeScreens581 = (SELECT count(*) FROM #tblMainCohort where OBPInHome is null or  OBPInHome = '-' and hvcasepk in (SELECT hvcasepk FROM #tblNegativeScreens))
SET @numOfTotalKempesCompleted581 = (SELECT count(*) FROM #tblMainCohort where OBPInHome is null or  OBPInHome = '-' and hvcasepk in (SELECT hvcasepk FROM #tblKempesCompleted))
SET @numOfTotalEnrolled581 = (SELECT count(*) FROM #tblMainCohort where OBPInHome is null or  OBPInHome = '-' and hvcasepk in (SELECT hvcasepk FROM #tblEnrolled))


INSERT INTO #tblScreenAnalysisSummary([Id],[Title],[SubGroupId],[TotalScreens],[PositiveScreens],[PositiveScreensNotReferred],[NegativeScreens],[KempesCompleted],[Enrolled])
VALUES(7, '    Missing', 32
,CONVERT(VARCHAR,@numOfALLScreens581) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfALLScreens581 AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreens581) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreens581 AS FLOAT) * 100/ NULLIF(@numOfALLScreens581,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreensNotReferred581) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreensNotReferred581 AS FLOAT) * 100/ NULLIF(@numOfALLScreens581,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalNegativeScreens581) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalNegativeScreens581 AS FLOAT) * 100/ NULLIF(@numOfALLScreens581,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalKempesCompleted581) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalKempesCompleted581 AS FLOAT) * 100/ NULLIF(@numOfALLScreens581,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalEnrolled581) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalEnrolled581 AS FLOAT) * 100/ NULLIF(@numOfALLScreens581,0), 0), 0))  + '%)'
)


/*************************************************/
-- add the title for Prenatal Care in the row
INSERT INTO #tblScreenAnalysisSummary([Id],[Title],[SubGroupId],[TotalScreens],[PositiveScreens],[PositiveScreensNotReferred],[NegativeScreens],[KempesCompleted],[Enrolled])
VALUES(8, 'Receiving Prenatal Care', 33, '', '', '', '', '', '')  

---- calcualte Prenatal Care- Yes  
DECLARE @numOfALLScreens59 INT = 0
DECLARE @numOfTotalPositiveScreens59 INT = 0
DECLARE @numOfTotalPositiveScreensNotReferred59 INT = 0
DECLARE @numOfTotalNegativeScreens59 INT = 0
DECLARE @numOfTotalKempesCompleted59 INT = 0
DECLARE @numOfTotalEnrolled59 INT = 0  


SET @numOfALLScreens59 = (SELECT count(*) FROM #tblMainCohort where ReceivingPreNatalCare = '1')
SET @numOfTotalPositiveScreens59 = (SELECT count(*) FROM #tblMainCohort where ReceivingPreNatalCare = '1' and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreens))
SET @numOfTotalPositiveScreensNotReferred59 = (SELECT count(*) FROM #tblMainCohort where ReceivingPreNatalCare = '1' and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreensNotReferred))
SET @numOfTotalNegativeScreens59 = (SELECT count(*) FROM #tblMainCohort where ReceivingPreNatalCare = '1' and hvcasepk in (SELECT hvcasepk FROM #tblNegativeScreens))
SET @numOfTotalKempesCompleted59 = (SELECT count(*) FROM #tblMainCohort where ReceivingPreNatalCare = '1' and hvcasepk in (SELECT hvcasepk FROM #tblKempesCompleted))
SET @numOfTotalEnrolled59 = (SELECT count(*) FROM #tblMainCohort where ReceivingPreNatalCare = '1' and hvcasepk in (SELECT hvcasepk FROM #tblEnrolled))


INSERT INTO #tblScreenAnalysisSummary([Id],[Title],[SubGroupId],[TotalScreens],[PositiveScreens],[PositiveScreensNotReferred],[NegativeScreens],[KempesCompleted],[Enrolled])
VALUES(8, '    Yes', 34 
,CONVERT(VARCHAR,@numOfALLScreens59) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfALLScreens59 AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreens59) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreens59 AS FLOAT) * 100/ NULLIF(@numOfALLScreens59,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreensNotReferred59) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreensNotReferred59 AS FLOAT) * 100/ NULLIF(@numOfALLScreens59,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalNegativeScreens59) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalNegativeScreens59 AS FLOAT) * 100/ NULLIF(@numOfALLScreens59,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalKempesCompleted59) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalKempesCompleted59 AS FLOAT) * 100/ NULLIF(@numOfALLScreens59,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalEnrolled59) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalEnrolled59 AS FLOAT) * 100/ NULLIF(@numOfALLScreens59,0), 0), 0))  + '%)'
)


---- calcualte Prenatal Care- No  
DECLARE @numOfALLScreens60 INT = 0
DECLARE @numOfTotalPositiveScreens60 INT = 0
DECLARE @numOfTotalPositiveScreensNotReferred60 INT = 0
DECLARE @numOfTotalNegativeScreens60 INT = 0
DECLARE @numOfTotalKempesCompleted60 INT = 0
DECLARE @numOfTotalEnrolled60 INT = 0  


SET @numOfALLScreens60 = (SELECT count(*) FROM #tblMainCohort where ReceivingPreNatalCare = '0')
SET @numOfTotalPositiveScreens60 = (SELECT count(*) FROM #tblMainCohort where ReceivingPreNatalCare = '0' and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreens))
SET @numOfTotalPositiveScreensNotReferred60 = (SELECT count(*) FROM #tblMainCohort where ReceivingPreNatalCare = '0' and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreensNotReferred))
SET @numOfTotalNegativeScreens60 = (SELECT count(*) FROM #tblMainCohort where ReceivingPreNatalCare = '0' and hvcasepk in (SELECT hvcasepk FROM #tblNegativeScreens))
SET @numOfTotalKempesCompleted60 = (SELECT count(*) FROM #tblMainCohort where ReceivingPreNatalCare = '0' and hvcasepk in (SELECT hvcasepk FROM #tblKempesCompleted))
SET @numOfTotalEnrolled60 = (SELECT count(*) FROM #tblMainCohort where ReceivingPreNatalCare = '0' and hvcasepk in (SELECT hvcasepk FROM #tblEnrolled))


INSERT INTO #tblScreenAnalysisSummary([Id],[Title],[SubGroupId],[TotalScreens],[PositiveScreens],[PositiveScreensNotReferred],[NegativeScreens],[KempesCompleted],[Enrolled])
VALUES(8, '    No', 35 
,CONVERT(VARCHAR,@numOfALLScreens60) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfALLScreens60 AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreens60) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreens60 AS FLOAT) * 100/ NULLIF(@numOfALLScreens60,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreensNotReferred60) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreensNotReferred60 AS FLOAT) * 100/ NULLIF(@numOfALLScreens60,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalNegativeScreens60) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalNegativeScreens60 AS FLOAT) * 100/ NULLIF(@numOfALLScreens60,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalKempesCompleted60) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalKempesCompleted60 AS FLOAT) * 100/ NULLIF(@numOfALLScreens60,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalEnrolled60) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalEnrolled60 AS FLOAT) * 100/ NULLIF(@numOfALLScreens60,0), 0), 0))  + '%)'
)


---- calcualte Prenatal Care- Unknown  
DECLARE @numOfALLScreens61 INT = 0
DECLARE @numOfTotalPositiveScreens61 INT = 0
DECLARE @numOfTotalPositiveScreensNotReferred61 INT = 0
DECLARE @numOfTotalNegativeScreens61 INT = 0
DECLARE @numOfTotalKempesCompleted61 INT = 0
DECLARE @numOfTotalEnrolled61 INT = 0  


SET @numOfALLScreens61 = (SELECT count(*) FROM #tblMainCohort where ReceivingPreNatalCare = '9')
SET @numOfTotalPositiveScreens61 = (SELECT count(*) FROM #tblMainCohort where ReceivingPreNatalCare = '9' and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreens))
SET @numOfTotalPositiveScreensNotReferred61 = (SELECT count(*) FROM #tblMainCohort where ReceivingPreNatalCare = '9' and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreensNotReferred))
SET @numOfTotalNegativeScreens61 = (SELECT count(*) FROM #tblMainCohort where ReceivingPreNatalCare = '9' and hvcasepk in (SELECT hvcasepk FROM #tblNegativeScreens))
SET @numOfTotalKempesCompleted61 = (SELECT count(*) FROM #tblMainCohort where ReceivingPreNatalCare = '9' and hvcasepk in (SELECT hvcasepk FROM #tblKempesCompleted))
SET @numOfTotalEnrolled61 = (SELECT count(*) FROM #tblMainCohort where ReceivingPreNatalCare = '9' and hvcasepk in (SELECT hvcasepk FROM #tblEnrolled))


INSERT INTO #tblScreenAnalysisSummary([Id],[Title],[SubGroupId],[TotalScreens],[PositiveScreens],[PositiveScreensNotReferred],[NegativeScreens],[KempesCompleted],[Enrolled])
VALUES(8, '    Unknown', 36 
,CONVERT(VARCHAR,@numOfALLScreens61) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfALLScreens61 AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreens61) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreens61 AS FLOAT) * 100/ NULLIF(@numOfALLScreens61,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreensNotReferred61) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreensNotReferred61 AS FLOAT) * 100/ NULLIF(@numOfALLScreens61,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalNegativeScreens61) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalNegativeScreens61 AS FLOAT) * 100/ NULLIF(@numOfALLScreens61,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalKempesCompleted61) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalKempesCompleted61 AS FLOAT) * 100/ NULLIF(@numOfALLScreens61,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalEnrolled61) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalEnrolled61 AS FLOAT) * 100/ NULLIF(@numOfALLScreens61,0), 0), 0))  + '%)'
)


-- Here is the rest of the Prenatal Care - they did not tell waht is their Prenatal Care
---- calcualte Prenatal Care  - Missing  
DECLARE @numOfALLScreens611 INT = 0
DECLARE @numOfTotalPositiveScreens611 INT = 0
DECLARE @numOfTotalPositiveScreensNotReferred611 INT = 0
DECLARE @numOfTotalNegativeScreens611 INT = 0
DECLARE @numOfTotalKempesCompleted611 INT = 0
DECLARE @numOfTotalEnrolled611 INT = 0  


SET @numOfALLScreens611 = (SELECT count(*) FROM #tblMainCohort where ReceivingPreNatalCare is null or  ReceivingPreNatalCare = '-')
SET @numOfTotalPositiveScreens611 = (SELECT count(*) FROM #tblMainCohort where ReceivingPreNatalCare is null or  ReceivingPreNatalCare = '-' and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreens))
SET @numOfTotalPositiveScreensNotReferred611 = (SELECT count(*) FROM #tblMainCohort where ReceivingPreNatalCare is null or  ReceivingPreNatalCare = '-' and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreensNotReferred))
SET @numOfTotalNegativeScreens611 = (SELECT count(*) FROM #tblMainCohort where ReceivingPreNatalCare is null or  ReceivingPreNatalCare = '-' and hvcasepk in (SELECT hvcasepk FROM #tblNegativeScreens))
SET @numOfTotalKempesCompleted611 = (SELECT count(*) FROM #tblMainCohort where ReceivingPreNatalCare is null or  ReceivingPreNatalCare = '-' and hvcasepk in (SELECT hvcasepk FROM #tblKempesCompleted))
SET @numOfTotalEnrolled611 = (SELECT count(*) FROM #tblMainCohort where ReceivingPreNatalCare is null or  ReceivingPreNatalCare = '-' and hvcasepk in (SELECT hvcasepk FROM #tblEnrolled))


INSERT INTO #tblScreenAnalysisSummary([Id],[Title],[SubGroupId],[TotalScreens],[PositiveScreens],[PositiveScreensNotReferred],[NegativeScreens],[KempesCompleted],[Enrolled])
VALUES(8, '    Missing', 36
,CONVERT(VARCHAR,@numOfALLScreens611) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfALLScreens611 AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreens611) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreens611 AS FLOAT) * 100/ NULLIF(@numOfALLScreens611,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreensNotReferred611) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreensNotReferred611 AS FLOAT) * 100/ NULLIF(@numOfALLScreens611,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalNegativeScreens611) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalNegativeScreens611 AS FLOAT) * 100/ NULLIF(@numOfALLScreens611,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalKempesCompleted611) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalKempesCompleted611 AS FLOAT) * 100/ NULLIF(@numOfALLScreens611,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalEnrolled611) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalEnrolled611 AS FLOAT) * 100/ NULLIF(@numOfALLScreens611,0), 0), 0))  + '%)'
)



/*************************************************/
-- Note how we acheived the dynamic nature(# of ReferralSourceType is not known) of the resultset ... khalsa
-- add the title for Type of Referral in the row
INSERT INTO #tblScreenAnalysisSummary([Id],[Title],[SubGroupId],[TotalScreens],[PositiveScreens],[PositiveScreensNotReferred],[NegativeScreens],[KempesCompleted],[Enrolled])
VALUES(9, 'Type of Referral', 37, '', '', '', '', '', '')  


;
with cteReferralSourceTypeCount
as
(

SELECT 
count(HVCasePK) countTotal

,		sum(case when ScreenResult= '1' and ReferralMade= '1' then
				 1
			 else
				 0
			 end) as TotalPositiveScreens
			 
,		sum(case when ScreenResult= '1' and ReferralMade= '0' then
				 1
			 else
				 0
			 end) as PositiveScreensNotReferred
			 
,		sum(case when ScreenResult != '1' then
				 1
			 else
				 0
			 end) as TotalNegativeScreens
			 
,		sum(case when KempeDate is not null then
				 1
			 else
				 0
			 end) as TotalKempesCompleted
			 
,		sum(case when IntakeDate is not null then
				 1
			 else
				 0
			 end) as TotalEnrolled
			 
			 
			 
			 
,CASE WHEN AppCodeText IS NULL THEN '    No Referral Source' ELSE '    ' + AppCodeText END ReferralSourceName
,CASE WHEN ReferralSource = '0…' Then '99' ELSE ReferralSource END AppCode  -- get it for order the resultset later on

FROM #tblMainCohort c
--group by CASE WHEN AppCodeText IS NULL THEN '    No Referral Source' ELSE '    ' + AppCodeText end
group by 
CASE WHEN ReferralSource = '0…' Then '99' ELSE ReferralSource end,
CASE WHEN AppCodeText IS NULL THEN '    No Referral Source' ELSE '    ' + AppCodeText end


)
,
cteReferralSourceTypeStatistics
as
(
SELECT 
AppCode
,9 as reportIndex
,ReferralSourceName
,ROW_NUMBER() OVER(ORDER BY ReferralSourceName) + 37 AS RowNumber  -- note that there are 37 rows before this one

,CONVERT(VARCHAR,countTotal) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(countTotal AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)' as Total
,CONVERT(VARCHAR,TotalPositiveScreens) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(TotalPositiveScreens AS FLOAT) * 100/ NULLIF(countTotal,0), 0), 0))  + '%)' as TotalPositiveScreens
,CONVERT(VARCHAR,PositiveScreensNotReferred) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(PositiveScreensNotReferred AS FLOAT) * 100/ NULLIF(countTotal,0), 0), 0))  + '%)' as PositiveScreensNotReferred
,CONVERT(VARCHAR,TotalNegativeScreens) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(TotalNegativeScreens AS FLOAT) * 100/ NULLIF(countTotal,0), 0), 0))  + '%)' as TotalNegativeScreens
,CONVERT(VARCHAR,TotalKempesCompleted) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(TotalKempesCompleted AS FLOAT) * 100/ NULLIF(countTotal,0), 0), 0))  + '%)' as TotalKempesCompleted
,CONVERT(VARCHAR,TotalEnrolled) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(TotalEnrolled AS FLOAT) * 100/ NULLIF(countTotal,0), 0), 0))  + '%)' as TotalEnrolled



FROM cteReferralSourceTypeCount
)


-- insert all the ReferralSourceType into the table as rows of data
INSERT INTO #tblScreenAnalysisSummary([Id],[Title],[SubGroupId],[TotalScreens],[PositiveScreens],[PositiveScreensNotReferred],[NegativeScreens],[KempesCompleted],[Enrolled])
SELECT 
	   reportIndex
	  ,ReferralSourceName
	  ,RowNumber
	  ,Total
	  ,TotalPositiveScreens
	  ,PositiveScreensNotReferred
	  ,TotalNegativeScreens
	  ,TotalKempesCompleted
	  ,TotalEnrolled

 FROM cteReferralSourceTypeStatistics
 order by AppCode 

-- rspScreenReferralSourceDemographicsAndOutcomeAnalysis 5,'09/01/2011','08/31/2012'


declare @lastRowNumber int
set @lastRowNumber = (select count(*) from #tblScreenAnalysisSummary)

/*************************************************/
-- add the title for Risk Factors in the row
INSERT INTO #tblScreenAnalysisSummary([Id],[Title],[SubGroupId],[TotalScreens],[PositiveScreens],[PositiveScreensNotReferred],[NegativeScreens],[KempesCompleted],[Enrolled])
VALUES(10, 'Risk Factors', @lastRowNumber + 1, '', '', '', '', '', '')  

---- calcualte Risk Factors - Single, Separated, Divorced or Widowed  
DECLARE @numOfALLScreens62 INT = 0
DECLARE @numOfTotalPositiveScreens62 INT = 0
DECLARE @numOfTotalPositiveScreensNotReferred62 INT = 0
DECLARE @numOfTotalNegativeScreens62 INT = 0
DECLARE @numOfTotalKempesCompleted62 INT = 0
DECLARE @numOfTotalEnrolled62 INT = 0  
	  --,RiskNoPrenatalCare [char](1) null
	  
	  --,RiskPoor [char](1) null
	  --,RiskUnder21 [char](1) null

SET @numOfALLScreens62 = (SELECT count(*) FROM #tblMainCohort where RiskNotMarried = '1')
SET @numOfTotalPositiveScreens62 = (SELECT count(*) FROM #tblMainCohort where RiskNotMarried = '1' and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreens))
SET @numOfTotalPositiveScreensNotReferred62 = (SELECT count(*) FROM #tblMainCohort where RiskNotMarried = '1' and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreensNotReferred))
SET @numOfTotalNegativeScreens62 = (SELECT count(*) FROM #tblMainCohort where RiskNotMarried = '1' and hvcasepk in (SELECT hvcasepk FROM #tblNegativeScreens))
SET @numOfTotalKempesCompleted62 = (SELECT count(*) FROM #tblMainCohort where RiskNotMarried = '1' and hvcasepk in (SELECT hvcasepk FROM #tblKempesCompleted))
SET @numOfTotalEnrolled62 = (SELECT count(*) FROM #tblMainCohort where RiskNotMarried = '1' and hvcasepk in (SELECT hvcasepk FROM #tblEnrolled))


INSERT INTO #tblScreenAnalysisSummary([Id],[Title],[SubGroupId],[TotalScreens],[PositiveScreens],[PositiveScreensNotReferred],[NegativeScreens],[KempesCompleted],[Enrolled])
VALUES(10, '    Single, Separated, Divorced or Widowed', @lastRowNumber + 2 
,CONVERT(VARCHAR,@numOfALLScreens62) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfALLScreens62 AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreens62) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreens62 AS FLOAT) * 100/ NULLIF(@numOfALLScreens62,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreensNotReferred62) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreensNotReferred62 AS FLOAT) * 100/ NULLIF(@numOfALLScreens62,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalNegativeScreens62) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalNegativeScreens62 AS FLOAT) * 100/ NULLIF(@numOfALLScreens62,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalKempesCompleted62) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalKempesCompleted62 AS FLOAT) * 100/ NULLIF(@numOfALLScreens62,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalEnrolled62) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalEnrolled62 AS FLOAT) * 100/ NULLIF(@numOfALLScreens62,0), 0), 0))  + '%)'
)

---- calcualte Risk Factors - Late or No Prenatal Care 
DECLARE @numOfALLScreens63 INT = 0
DECLARE @numOfTotalPositiveScreens63 INT = 0
DECLARE @numOfTotalPositiveScreensNotReferred63 INT = 0
DECLARE @numOfTotalNegativeScreens63 INT = 0
DECLARE @numOfTotalKempesCompleted63 INT = 0
DECLARE @numOfTotalEnrolled63 INT = 0  
	  
	  --,RiskPoor [char](1) null
	  --,RiskUnder21 [char](1) null

SET @numOfALLScreens63 = (SELECT count(*) FROM #tblMainCohort where RiskNoPrenatalCare = '1')
SET @numOfTotalPositiveScreens63 = (SELECT count(*) FROM #tblMainCohort where RiskNoPrenatalCare = '1' and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreens))
SET @numOfTotalPositiveScreensNotReferred63 = (SELECT count(*) FROM #tblMainCohort where RiskNoPrenatalCare = '1' and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreensNotReferred))
SET @numOfTotalNegativeScreens63 = (SELECT count(*) FROM #tblMainCohort where RiskNoPrenatalCare = '1' and hvcasepk in (SELECT hvcasepk FROM #tblNegativeScreens))
SET @numOfTotalKempesCompleted63 = (SELECT count(*) FROM #tblMainCohort where RiskNoPrenatalCare = '1' and hvcasepk in (SELECT hvcasepk FROM #tblKempesCompleted))
SET @numOfTotalEnrolled63 = (SELECT count(*) FROM #tblMainCohort where RiskNoPrenatalCare = '1' and hvcasepk in (SELECT hvcasepk FROM #tblEnrolled))


INSERT INTO #tblScreenAnalysisSummary([Id],[Title],[SubGroupId],[TotalScreens],[PositiveScreens],[PositiveScreensNotReferred],[NegativeScreens],[KempesCompleted],[Enrolled])
VALUES(10, '    Late or No Prenatal Care', @lastRowNumber + 3 
,CONVERT(VARCHAR,@numOfALLScreens63) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfALLScreens63 AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreens63) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreens63 AS FLOAT) * 100/ NULLIF(@numOfALLScreens63,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreensNotReferred63) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreensNotReferred63 AS FLOAT) * 100/ NULLIF(@numOfALLScreens63,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalNegativeScreens63) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalNegativeScreens63 AS FLOAT) * 100/ NULLIF(@numOfALLScreens63,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalKempesCompleted63) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalKempesCompleted63 AS FLOAT) * 100/ NULLIF(@numOfALLScreens63,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalEnrolled63) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalEnrolled63 AS FLOAT) * 100/ NULLIF(@numOfALLScreens63,0), 0), 0))  + '%)'
)

---- calcualte Risk Factors - Inadequate Income or No Info on Income
DECLARE @numOfALLScreens64 INT = 0
DECLARE @numOfTotalPositiveScreens64 INT = 0
DECLARE @numOfTotalPositiveScreensNotReferred64 INT = 0
DECLARE @numOfTotalNegativeScreens64 INT = 0
DECLARE @numOfTotalKempesCompleted64 INT = 0
DECLARE @numOfTotalEnrolled64 INT = 0  
	  
	  
	  --,RiskUnder21 [char](1) null

SET @numOfALLScreens64 = (SELECT count(*) FROM #tblMainCohort where RiskPoor = '1')
SET @numOfTotalPositiveScreens64 = (SELECT count(*) FROM #tblMainCohort where RiskPoor = '1' and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreens))
SET @numOfTotalPositiveScreensNotReferred64 = (SELECT count(*) FROM #tblMainCohort where RiskPoor = '1' and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreensNotReferred))
SET @numOfTotalNegativeScreens64 = (SELECT count(*) FROM #tblMainCohort where RiskPoor = '1' and hvcasepk in (SELECT hvcasepk FROM #tblNegativeScreens))
SET @numOfTotalKempesCompleted64 = (SELECT count(*) FROM #tblMainCohort where RiskPoor = '1' and hvcasepk in (SELECT hvcasepk FROM #tblKempesCompleted))
SET @numOfTotalEnrolled64 = (SELECT count(*) FROM #tblMainCohort where RiskPoor = '1' and hvcasepk in (SELECT hvcasepk FROM #tblEnrolled))


INSERT INTO #tblScreenAnalysisSummary([Id],[Title],[SubGroupId],[TotalScreens],[PositiveScreens],[PositiveScreensNotReferred],[NegativeScreens],[KempesCompleted],[Enrolled])
VALUES(10, '    Inadequate Income or No Info on Income', @lastRowNumber + 4 
,CONVERT(VARCHAR,@numOfALLScreens64) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfALLScreens64 AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreens64) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreens64 AS FLOAT) * 100/ NULLIF(@numOfALLScreens64,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreensNotReferred64) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreensNotReferred64 AS FLOAT) * 100/ NULLIF(@numOfALLScreens64,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalNegativeScreens64) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalNegativeScreens64 AS FLOAT) * 100/ NULLIF(@numOfALLScreens64,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalKempesCompleted64) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalKempesCompleted64 AS FLOAT) * 100/ NULLIF(@numOfALLScreens64,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalEnrolled64) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalEnrolled64 AS FLOAT) * 100/ NULLIF(@numOfALLScreens64,0), 0), 0))  + '%)'
)

---- calcualte Risk Factors - Under 21
DECLARE @numOfALLScreens65 INT = 0
DECLARE @numOfTotalPositiveScreens65 INT = 0
DECLARE @numOfTotalPositiveScreensNotReferred65 INT = 0
DECLARE @numOfTotalNegativeScreens65 INT = 0
DECLARE @numOfTotalKempesCompleted65 INT = 0
DECLARE @numOfTotalEnrolled65 INT = 0  
	  
	  --,RiskUnder21 [char](1) null

SET @numOfALLScreens65 = (SELECT count(*) FROM #tblMainCohort where RiskUnder21 = '1')
SET @numOfTotalPositiveScreens65 = (SELECT count(*) FROM #tblMainCohort where RiskUnder21 = '1' and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreens))
SET @numOfTotalPositiveScreensNotReferred65 = (SELECT count(*) FROM #tblMainCohort where RiskUnder21 = '1' and hvcasepk in (SELECT hvcasepk FROM #tblPositiveScreensNotReferred))
SET @numOfTotalNegativeScreens65 = (SELECT count(*) FROM #tblMainCohort where RiskUnder21 = '1' and hvcasepk in (SELECT hvcasepk FROM #tblNegativeScreens))
SET @numOfTotalKempesCompleted65 = (SELECT count(*) FROM #tblMainCohort where RiskUnder21 = '1' and hvcasepk in (SELECT hvcasepk FROM #tblKempesCompleted))
SET @numOfTotalEnrolled65 = (SELECT count(*) FROM #tblMainCohort where RiskUnder21 = '1' and hvcasepk in (SELECT hvcasepk FROM #tblEnrolled))


INSERT INTO #tblScreenAnalysisSummary([Id],[Title],[SubGroupId],[TotalScreens],[PositiveScreens],[PositiveScreensNotReferred],[NegativeScreens],[KempesCompleted],[Enrolled])
VALUES(10, '    Under 21', @lastRowNumber + 5 
,CONVERT(VARCHAR,@numOfALLScreens65) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfALLScreens65 AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreens65) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreens65 AS FLOAT) * 100/ NULLIF(@numOfALLScreens65,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalPositiveScreensNotReferred65) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalPositiveScreensNotReferred65 AS FLOAT) * 100/ NULLIF(@numOfALLScreens65,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalNegativeScreens65) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalNegativeScreens65 AS FLOAT) * 100/ NULLIF(@numOfALLScreens65,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalKempesCompleted65) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalKempesCompleted65 AS FLOAT) * 100/ NULLIF(@numOfALLScreens65,0), 0), 0))  + '%)'
,CONVERT(VARCHAR,@numOfTotalEnrolled65) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfTotalEnrolled65 AS FLOAT) * 100/ NULLIF(@numOfALLScreens65,0), 0), 0))  + '%)'
)





-- get the count of unduplicated screens
;
with cteUnduplicatedScreens as
(
	select
		--distinct  -- We need distinct here to remove duplicates
		distinct
		PC1FK
		 

		  
		   FROM hvscreen hvs
	inner join HVCase h on h.HVCasePK = hvs.HVCaseFK
	inner join caseprogram cp on h.hvcasepk = cp.hvcasefk
	inner join dbo.SplitString(@programfk, ',') on cp.programfk = listitem	
	INNER JOIN PC ON h.PC1FK = PC.PCPK -- to get pcdob	
	LEFT JOIN CommonAttributes ca ON ca.hvcasefk = h.hvcasepk AND ca.formtype = 'SC'

	left join dbo.TCID ON dbo.TCID.HVCaseFK = h.HVCasePK
	LEFT OUTER JOIN dbo.listReferralSource lrs on lrs.listReferralSourcePK = hvs.ReferralSourceFK
	left outer join dbo.codeDischarge cd on cd.DischargeCode = cp.DischargeReason and DischargeUsedWhere like '%SC%'

	LEFT OUTER JOIN codeApp AS b ON b.AppCode = hvs.ReferralSource AND b.AppCodeGroup = 'TypeofReferral' and b.AppCodeUsedWhere like '%sc%' 
	

	where  
	lrs.listReferralSourcePK = isnull(@listReferralSourcePK,lrs.listReferralSourcePK)
	and
	h.ScreenDate between @sDate and @eDate	
	

)

-- update the column i.e. NumOfUnduplicatedScreens		
update #tblScreenAnalysisSummary
set NumOfUnduplicatedScreens = (SELECT count(*) as count1 FROM cteUnduplicatedScreens)			


SELECT * FROM #tblScreenAnalysisSummary



--set statistics time off  
--set statistics IO off 



-- drop all the temp tables
drop table #tblScreenAnalysisSummary
drop table #tblMainCohort
drop table #tblPositiveScreens
drop table #tblPositiveScreensNotReferred
drop table #tblNegativeScreens
drop table #tblKempesCompleted
drop table #tblEnrolled

GO
