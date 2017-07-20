SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Stored Procedure

-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <May 9th, 2012>
-- Description:	<This report gets you 'ProgramSynopsis i.e. The Program Synopsis is used as a monthly summary of activity for the program.
-- It can be run for any time period as well. Screens, Kempes, enrollment, referrals, home visits and form information give the user a quick management look at program status.'>

-- rspProgramSynopsis 5, '04/01/2013', '04/30/2013'
-- rspProgramSynopsis 3, '05/01/2013', '05/31/2013'
-- rspProgramSynopsis 11, '04/01/2013', '06/30/2013'
-- rspProgramSynopsis 22, '09/01/2012', '08/31/2013'

-- =============================================


CREATE procedure [dbo].[rspProgramSynopsis](
	@programfk    varchar(max)    = NULL,
    @sdate     datetime,
    @edate     datetime,
	@sitefk		  int			 = null,
    @CaseFiltersPositive	varchar(100)    = ''
)
AS
	if @programfk is null
	begin
		select @programfk = substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end

	set @programfk = REPLACE(@programfk,'"','')

	set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0 else @SiteFK end
	set @CaseFiltersPositive = case when @CaseFiltersPositive = '' then null else @CaseFiltersPositive end

DECLARE @tblProgramSynopsisReportTitle TABLE(
	rowNumber int,
	rowOrder int,
	strTotals varchar(100),
	psrCol0 varchar(200),
	psrCol1 varchar(200),
	psrCol2 varchar(200),
	psrCol3 varchar(200),
	psrCol4 varchar(200),
	psrCol5 varchar(200),
	psrCol6 varchar(200),
	psrCol7 varchar(200)
)


DECLARE @tblCommonCohort TABLE(
			[HVCasePK] [int],
			[CaseProgress] [numeric](3, 1) NULL,
			[Confidentiality] [bit] NULL,
			[CPFK] [int] NULL,
			[DateOBPAdded] [datetime] NULL,
			--[EDC] [datetime] NULL,
			[FFFK] [int] NULL,
			[FirstChildDOB] [datetime] NULL,
			[FirstPrenatalCareVisit] [datetime] NULL,
			[FirstPrenatalCareVisitUnknown] [bit] NULL,
			[HVCaseCreateDate] [datetime] NOT NULL,
			[HVCaseCreator] [char](10) NOT NULL,
			[HVCaseEditDate] [datetime] NULL,
			[HVCaseEditor] [char](10) NULL,
			[InitialZip] [char](10) NULL,
			[IntakeDate] [datetime] NULL,
			[IntakeLevel] [char](1) NULL,
			[IntakeWorkerFK] [int] NULL,
			[KempeDate] [datetime] NULL,
			[OBPInformationAvailable] [bit] NULL,
			[OBPFK] [int] NULL,
			[OBPinHomeIntake] [bit] NULL,
			[OBPRelation2TC] [char](2) NULL,
			[PC1FK] [int] NOT NULL,
			[PC1Relation2TC] [char](2) NULL,
			[PC1Relation2TCSpecify] [varchar](30) NULL,
			[PC2FK] [int] NULL,
			[PC2inHomeIntake] [bit] NULL,
			[PC2Relation2TC] [char](2) NULL,
			[PC2Relation2TCSpecify] [varchar](30) NULL,
			[PrenatalCheckupsB4] [int] NULL,
			[ScreenDate] [datetime] NOT NULL,
			--[TCDOB] [datetime] NULL,
			[TCDOB_EDC] [datetime] NULL,
			[TCDOD] [datetime] NULL,
			[TCNumber] [int] NULL,

			[CaseProgramPK] [int],
			[CaseProgramCreateDate] [datetime] NOT NULL,
			[CaseProgramCreator] [char](10) NOT NULL,
			[CaseProgramEditDate] [datetime] NULL,
			[CaseProgramEditor] [char](10) NULL,
			[CaseStartDate] [datetime] NOT NULL,
			[CurrentFAFK] [int] NULL,
			[CurrentFAWFK] [int] NULL,
			[CurrentFSWFK] [int] NULL,
			[CurrentLevelDate] [datetime] NOT NULL,
			[CurrentLevelFK] [int] NOT NULL,
			[DischargeDate] [datetime] NULL,
			[lastdate] [datetime] NULL,
			[DischargeReason] [char](2) NULL,
			[DischargeReasonSpecify] [varchar](500) NULL,
			[ExtraField1] [char](30) NULL,
			[ExtraField2] [char](30) NULL,
			[ExtraField3] [char](30) NULL,
			[ExtraField4] [char](30) NULL,
			[ExtraField5] [char](30) NULL,
			[ExtraField6] [char](30) NULL,
			[ExtraField7] [char](30) NULL,
			[ExtraField8] [char](30) NULL,
			[ExtraField9] [char](30) NULL,
			[HVCaseFK] [int] NOT NULL,
			[HVCaseFK_old] [int] NOT NULL,
			[OldID] [char](23) NULL,
			[PC1ID] [char](13) NOT NULL,
			[ProgramFK] [int] NOT NULL,
			[TransferredtoProgram] [varchar](50) NULL,
			[TransferredtoProgramFK] [int] null,

			XDateAge int,
			--tcAgeDays int,
			workername varchar(200)	     

)

INSERT INTO @tblCommonCohort
	SELECT HVCasePK
		  ,CaseProgress
		  ,Confidentiality
		  ,CPFK
		  ,DateOBPAdded
		  --,EDC
		  ,FFFK
		  ,FirstChildDOB
		  ,FirstPrenatalCareVisit
		  ,FirstPrenatalCareVisitUnknown
		  ,HVCaseCreateDate
		  ,HVCaseCreator
		  ,HVCaseEditDate
		  ,HVCaseEditor
		  ,InitialZip
		  ,IntakeDate
		  ,IntakeLevel
		  ,IntakeWorkerFK
		  ,KempeDate
		  ,OBPInformationAvailable
		  ,OBPFK
		  ,OBPinHomeIntake
		  ,OBPRelation2TC
		  ,PC1FK
		  ,PC1Relation2TC
		  ,PC1Relation2TCSpecify
		  ,PC2FK
		  ,PC2inHomeIntake
		  ,PC2Relation2TC
		  ,PC2Relation2TCSpecify
		  ,PrenatalCheckupsB4
		  ,ScreenDate
		  --,TCDOB		  
		  ,case
			   when h.tcdob is not null then
				   h.tcdob
			   else
				   h.edc
			end as TCDOB_EDC
		  ,TCDOD
		  ,TCNumber

		  ,CaseProgramPK
		  ,CaseProgramCreateDate
		  ,CaseProgramCreator
		  ,CaseProgramEditDate
		  ,CaseProgramEditor
		  ,CaseStartDate
		  ,CurrentFAFK
		  ,CurrentFAWFK
		  ,CurrentFSWFK
		  ,CurrentLevelDate
		  ,CurrentLevelFK
		  ,DischargeDate
		  , case
			  when DischargeDate is not null and DischargeDate <> '' and DischargeDate <= @eDate then
				  DischargeDate
			  else
				  @eDate
		  end as lastdate

		  ,DischargeReason
		  ,DischargeReasonSpecify
		  ,ExtraField1
		  ,ExtraField2
		  ,ExtraField3
		  ,ExtraField4
		  ,ExtraField5
		  ,ExtraField6
		  ,ExtraField7
		  ,ExtraField8
		  ,ExtraField9
		  ,cp.HVCaseFK
		  ,HVCaseFK_old
		  ,OldID
		  ,PC1ID
		  ,cp.ProgramFK
		  ,TransferredtoProgram
		  ,TransferredtoProgramFK
		  ,case
			   when h.tcdob is not null then
				 datediff(dd, h.tcdob,  @edate)
			   else
				   datediff(dd, h.edc, @edate)
			end as XDateAge
		 --,case
			--  when DischargeDate is not null and DischargeDate <> '' and DischargeDate <= @edate and h.tcdob is not null then
			--	  datediff(day,h.tcdob,DischargeDate)
			--  else
			--	  datediff(day,h.edc,@edate)
		 -- end as tcAgeDays	  
		  , ltrim(rtrim(w.FirstName)) + ' ' + ltrim(rtrim(w.LastName)) as workername

		  FROM HVCase h 
	inner join CaseProgram cp on cp.HVCaseFK = h.HVCasePK	
	inner join dbo.SplitString(@programfk,',') on cp.programfk = listitem
	left outer join Worker w on w.WorkerPK = cp.CurrentFSWFK
	left outer join WorkerProgram wp on wp.WorkerFK = w.WorkerPK AND wp.ProgramFK = ListItem -- it now handles transfer work duplication correctly as per CP
	inner join dbo.udfCaseFilters(@casefilterspositive, '', @programfk) cf on cf.HVCaseFK = h.HVCasePK  -- may be we  need to put it somewhere else if no filter is being used
	WHERE 
	case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1
	AND 
	cp.CaseStartDate <= @edate	



	--SELECT * FROM @tblCommonCohort 

-- rspProgramSynopsis 19, '04/01/2011', '04/30/2011'

-- **create cursor without filters for the screen,preasses, kempe, preintake sections
-- Program Screens (no filter)

; WITH cteProgramScreens AS
	(	SELECT 1 as rowNumber,2 as roworder,'' as col0,
		count(HVCasePK) [Q1Screened]

		, sum(CASE WHEN c.ScreenResult = 1 THEN 1 ELSE 0 END) [Q1aScreenResultPositive]
		, sum(CASE WHEN c.ScreenResult != 1 THEN 1 ELSE 0 END) [Q1bScreenResultNegative]

		, sum(CASE WHEN TCDOB_EDC > a.ScreenDate and c.ScreenResult = 1 THEN 1 ELSE 0 END) [Q1cPrenatalPositive]
		, sum(CASE WHEN TCDOB_EDC > a.ScreenDate and c.ScreenResult = 0 THEN 1 ELSE 0 END) [Q1cPrenatalNegative]

		, sum(CASE WHEN TCDOB_EDC <= a.ScreenDate and c.ScreenResult = 1 THEN 1 ELSE 0 END) [Q1cPostnatalPositive]
		, sum(CASE WHEN TCDOB_EDC <= a.ScreenDate and c.ScreenResult = 0 THEN 1 ELSE 0 END) [Q1cPostnatalNegative]
		,'' as psrCol6
		FROM @tblCommonCohort AS a 
		JOIN HVScreen AS c ON a.HVCasePK = c.HVCaseFK
		WHERE a.ScreenDate BETWEEN @sdate AND @edate
	)

INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)
SELECT * FROM cteProgramScreens

;	

With
ctePreAssessments as
	(	SELECT 2 as rowNumber,2 as roworder,'' as col0,
		count(HVCasePK) [Q2TotalPreassessment]
		, sum(CASE WHEN TCDOB_EDC > @edate THEN 1 ELSE 0 END) [Q2cPrenatal]
		, sum(CASE WHEN TCDOB_EDC <= @edate THEN 1 ELSE 0 END) [Q2cPostnatal]
		, sum( case when (datediff( d, PCDOB, @edate) / 365.25) < 21 then 1 else 0 end ) as Q2cTeenAndUder21
		,'' as psrCol4,'' as psrCol5,'' as psrCol6,'' as psrCol7
		FROM @tblCommonCohort AS a 	
		INNER JOIN PC ON a.PC1FK = PC.PCPK -- to get pcdob	
		WHERE a.ScreenDate <= @edate
		and (a.KempeDate > @edate or a.KempeDate is null)
		and ( not (a.DischargeDate BETWEEN a.ScreenDate AND @edate) or DischargeDate is null )

	)

INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)
SELECT * FROM ctePreAssessments

;
With
cteKempeAssessments as
	(	SELECT 3 as rowNumber,2 as roworder,'' as col0,
		count(HVCasePK) [Q2TotalKempe]
		, sum(CASE WHEN k.KempeResult = 1 THEN 1 ELSE 0 END) [Q3aKempeResultPositive]
		, sum(CASE WHEN k.KempeResult = 0 THEN 1 ELSE 0 END) [Q3bKempeResultNegative]

		, sum(CASE WHEN TCDOB_EDC > k.KempeDate and k.KempeResult = 1 THEN 1 ELSE 0 END) [Q3cPrenatalPositive]
		, sum(CASE WHEN TCDOB_EDC > k.KempeDate and k.KempeResult = 0 THEN 1 ELSE 0 END) [Q3cPrenatalNegative]

		, sum(CASE WHEN TCDOB_EDC <= k.KempeDate and k.KempeResult = 1 THEN 1 ELSE 0 END) [Q3cPostnatalPositive]
		, sum(CASE WHEN TCDOB_EDC <= k.KempeDate and k.KempeResult = 0 THEN 1 ELSE 0 END) [Q3cPostnatalNegative]
		,'' as psrCol6

		FROM @tblCommonCohort AS a 
		LEFT JOIN Kempe k ON k.HVCaseFK = a.HVCasePK
		WHERE k.KempeDate BETWEEN @sdate AND @edate
	)

INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)
SELECT * FROM cteKempeAssessments

;

-- Enrollment Data
declare @col1 varchar(100)
declare @col2 varchar(100)
declare @col3 varchar(100)
declare @col4 varchar(100)


	-- Families at the beginning of Period
	set @col1 = (SELECT  count(HVCasePK) [Q4TotalEnrolled]
		FROM @tblCommonCohort AS a 
		where IntakeDate < @sdate and IntakeDate is not null
		and (DischargeDate >= @sdate or DischargeDate is null)
)

	 -- New Families	
	set @col2 = (SELECT 
	    count(HVCasePK) [Q4TotalNewFamiliesEnrolled]
		FROM @tblCommonCohort AS a 
		where (IntakeDate between @sdate and @edate)
)

	-- Discharged Families
	set @col3 = (SELECT count(HVCasePK) [Q4TotalDischargedFamilies]
		FROM @tblCommonCohort AS a 
		where (DischargeDate between @sdate and @edate)
		and IntakeDate is not null	
)

	-- FAmilies at the end of period
	set @col4 = (SELECT 
	    count(HVCasePK) [Q4TotalFamiliesAtEndOfPeriod]
		FROM @tblCommonCohort AS a 
		where IntakeDate <= @edate and IntakeDate is not null
		and (DischargeDate is null or DischargeDate > @edate)
)




INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)
values(4,2,'',
@col1,
@col2,
@col3,
@col4,
'','','',''
)

-- Lead Assessment make it part of FollowUp  ... per JH

-- ASQ
DECLARE @tblASQCohort TABLE(	
	[HVCasePK] [int],
	[TCIDPK] int,
	[Interval]	char(2)
)		

;with cteASQsReceivingEIP as
( 
	select max(HVCaseFK) as HVCaseFK
	from ASQ a
	where HVCaseFK in (select tcc.HVCasePK from @tblCommonCohort tcc)
			and ASQTCReceiving = 1
	group by a.HVCaseFK
)

insert into @tblASQCohort
	select  
		
		  hc.HVCasePK
		  ,t.TCIDPK 
		  ,Interval 		   
      --, DueBy        
      --, dateadd(dd,cdbd.DueBy,(((40-t.GestationalAge)*7)+hc.TCDOB)) as GestLessThan24Age
      --, year(dateadd(dd,cdbd.DueBy,(((40-t.GestationalAge)*7)+hc.TCDOB))) as YearGestLessThan24Age
      --, dateadd(dd,cdbd.DueBy,hc.TCDOB) as Gest24OrGreaterAge
      --, year(dateadd(dd,cdbd.DueBy,hc.TCDOB)) as YearGest24OrGreaterAge
      --, cdbd.EventDescription
		from CaseProgram cp
			inner join HVCase hc on hc.HVCasePK = cp.HVCaseFK
			inner join TCID t on t.HVCaseFK = hc.HVCasePK and t.ProgramFK = cp.ProgramFK AND t.TCDOD IS NULL
			inner join codeDueByDates cdbd on scheduledevent = 'ASQ' --optionValue
			inner join dbo.SplitString(@programfk,',') on cp.ProgramFK = listitem

		where 
		     hc.TCDOD IS NULL
			 and hc.CaseProgress >= 11
			 and (cp.DischargeDate is null or cp.DischargeDate > @edate)

			 and case
				  when cdbd.Interval < 24 then
					  dateadd(dd,cdbd.DueBy,(((40-t.GestationalAge)*7)+hc.TCDOB))
				  else
					  dateadd(dd,cdbd.DueBy,hc.TCDOB)
				end between @sdate and @edate
			and EventDescription not like '%optional%'  -- optionals are not required so take them out		
			and cp.HVCaseFK not in (select HVCaseFK from cteASQsReceivingEIP)
--order by Gest24OrGreaterAge

declare @ASQcol1 varchar(10)
declare @ASQcol2 varchar(10)
declare @ASQcol3 varchar(10)
declare @ASQcol4 varchar(10)
declare @ASQcol5 varchar(10)

-- Number due in Period
set @ASQcol1 =	(SELECT count(HVCasePK) as totalDue FROM @tblASQCohort)

-- Number completed
set @ASQcol2 =	(SELECT count(HVCasePK) as totalDone FROM @tblASQCohort m
				inner join ASQ A on m.HVCasePK = A.HVCaseFK and m.TCIDPK = A.TCIDFK and m.Interval = A.TCAge) 

-- In Window		
set @ASQcol3 =	(SELECT count(HVCasePK) as totalDone FROM @tblASQCohort m
				left join ASQ A on m.HVCasePK = A.HVCaseFK and m.TCIDPK = A.TCIDFK and m.Interval = A.TCAge
				where A.ASQInWindow = 1
				) 


-- Under cut off	

set @ASQcol4 =	(SELECT count(HVCasePK) as totalDone FROM @tblASQCohort m
				left join ASQ A on m.HVCasePK = A.HVCaseFK and m.TCIDPK = A.TCIDFK and m.Interval = A.TCAge
				where 
				UnderCommunication = 1
				or UnderFineMotor = 1
				or UnderGrossMotor = 1
				or UnderPersonalSocial = 1
				or UnderProblemSolving = 1	
				) 


-- Referred to EIP		
set @ASQcol5 =	(SELECT count(HVCasePK) as totalDone FROM @tblASQCohort m
				left join ASQ A on m.HVCasePK = A.HVCaseFK and m.TCIDPK = A.TCIDFK and m.Interval = A.TCAge
				where A.TCReferred = 1
				) 	

--select *
--from @tblASQCohort tac

--SELECT @ASQcol1, @ASQcol2, @ASQcol3, @ASQcol4, @ASQcol5

INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)
values(5,2,'',
@ASQcol1,
@ASQcol2,
@ASQcol3,
@ASQcol4,
@ASQcol5,
'','',''
)





-- ASQSE

DECLARE @tblASQSECohort TABLE(	
	[HVCasePK] [int],
	[TCIDPK] int,
	[Interval]	char(2)
)		

insert into @tblASQSECohort
	select  

		  hvcase.HVCasePK
		  ,TCID.TCIDPK 
		  ,Interval 		   

		from caseprogram
			inner join hvcase on hvcasepk = caseprogram.hvcasefk
			inner join tcid on tcid.hvcasefk = hvcasepk and tcid.programfk = caseprogram.programfk AND TCID.TCDOD IS NULL
			inner join codeduebydates on scheduledevent = 'ASQSE-1' --optionValue
			inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem

		where 
		    HVCase.TCDOD IS NULL
			and caseprogress >= 11
			and (dischargedate is null or dischargedate > @edate)	
			and case when Interval < 24
				then dateadd(dd, DueBy, (((40 - GestationalAge) * 7) + HVCase.TCDOB))
				else dateadd(dd, DueBy, HVCase.TCDOB)
			 end between @sdate and @edate

declare @ASQSEcol1 varchar(10)
declare @ASQSEcol2 varchar(10)
declare @ASQSEcol3 varchar(10)
declare @ASQSEcol4 varchar(10)
declare @ASQSEcol5 varchar(10)

-- Number due in Period
set @ASQSEcol1 =	(SELECT count(HVCasePK) as totalDue FROM @tblASQSECohort)

-- Number completed
set @ASQSEcol2 =	(SELECT count(HVCasePK) as totalDone FROM @tblASQSECohort m
				inner join ASQSE A on m.HVCasePK = A.HVCaseFK and m.TCIDPK = A.TCIDFK and m.Interval = A.ASQSETCAge) 


-- In Window		
set @ASQSEcol3 =	(SELECT count(HVCasePK) as totalDone FROM @tblASQSECohort m
				left join ASQSE A on m.HVCasePK = A.HVCaseFK and m.TCIDPK = A.TCIDFK and m.Interval = A.ASQSETCAge
				where A.ASQSEInWindow = 1
				) 


-- Under cut off	

set @ASQSEcol4 =	(SELECT count(HVCasePK) as totalDone FROM @tblASQSECohort m
				left join ASQSE A on m.HVCasePK = A.HVCaseFK and m.TCIDPK = A.TCIDFK and m.Interval = A.ASQSETCAge
				where 
				ASQSEOverCutOff = 1
				) 


-- Referred to EIP		
set @ASQSEcol5 =	(SELECT count(HVCasePK) as totalDone FROM @tblASQSECohort m
				left join ASQSE A on m.HVCasePK = A.HVCaseFK and m.TCIDPK = A.TCIDFK and m.Interval = A.ASQSETCAge
				where A.ASQSEReferred = 1
				) 	


--SELECT @ASQSEcol1, @ASQSEcol2, @ASQSEcol3, @ASQSEcol4, @ASQSEcol5

INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)
values(6,2,'',
@ASQSEcol1,
@ASQSEcol2,
@ASQSEcol3,
@ASQSEcol4,
@ASQSEcol5,
'','',''
)



-- Follow Up

DECLARE @tblFUMinimumInterval TABLE(
	HVCasePK INT,
	TCIDPK int,
	Interval CHAR (2)
)

INSERT INTO @tblFUMinimumInterval
(
HVCasePK,
TCIDPK,
Interval
)
SELECT 
		cc.HVCasePK	 
		,tcid.TCIDPK
	  , max(Interval) AS Interval 

 		from @tblCommonCohort cc			
			inner join tcid on tcid.hvcasefk = cc.hvcasepk and tcid.programfk = cc.ProgramFK
			inner join codeduebydates on scheduledevent = 'Follow Up' AND cc.XDateAge >= DueBy -- minimum interval
			-- there are no 18 month follow ups (interval code '18') in foxpro, though they're there now
			-- therefore, they're not required until 2013
			where Interval <> case when @sDate >= '01/01/2013' then 'xx'
								else '18'
								end



 GROUP BY HVCasePK
 , tcid.TCIDPK



 DECLARE @tblFUCohort TABLE(	
	[HVCasePK] [int],
	[TCIDPK] int,
	[Interval]	char(2)
)		

insert into @tblFUCohort 
 SELECT 
 cteIn.HVCasePK,
 cteIn.TCIDPK,
 cteIn.Interval  

 FROM @tblCommonCohort cc
 --inner join tcid on tcid.hvcasefk = cc.hvcasepk and tcid.programfk = cc.ProgramFK

 INNER JOIN @tblFUMinimumInterval cteIn ON cc.HVCasePK = cteIn.HVCasePK
  --and TCID.TCIDPK = cteIn.TCIDPK  -- we will use column 'Interval' next, which we just added
 inner join codeduebydates cd on scheduledevent = 'Follow Up' AND cteIn.[Interval] = cd.Interval -- to get dueby, max, min (given interval)

		where 
		     cc.TCDOD IS NULL
			 and caseprogress >= 11
			 and (dischargedate is null or dischargedate > @edate)
			 --and (IntakeDate is not null or IntakeDate <= @edate)
       and dateadd(dd,dueby,cc.TCDOB_EDC) between @sdate and @edate

--select * from @tblFUMinimumInterval
--select * from @tblFUCohort
--order by HVCasePK,TCIDPK 


-- rspProgramSynopsis 1, '04/01/2013', '04/30/2013'	

declare @FUcol1 varchar(10)
declare @FUcol2 varchar(10)
declare @FUcol3 varchar(10)


------ Number due in Period
set @FUcol1 =	(SELECT count(HVCasePK) as totalDone FROM @tblFUCohort m) 

-- Number completed  -- Redo ... khalsa
set @FUcol2 =	(SELECT count(HVCasePK) as totalDone FROM @tblFUCohort m
				 -- The following line gets those tcid's with fu's that are due for the Interval
				INNER JOIN FollowUp fu ON fu.HVCaseFK = m.HVCasePK AND fu.FollowUpInterval = m.Interval -- note 'Interval' is the minimum interval 			
				) 


-- In Window		
set @FUcol3 = (SELECT count(HVCasePK) as totalDone FROM @tblFUCohort m
				left join FollowUp fu ON fu.HVCaseFK = m.HVCasePK AND fu.FollowUpInterval = m.Interval
				where fu.FupInWindow = 1
				) 



INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)
values(7,2,'',
@FUcol1,
@FUcol2,
@FUcol3,
'',
'',
'','',''
)



	-- PSI

DECLARE @tblPSIMinimumInterval TABLE(
	HVCasePK INT,
	TCIDPK int,
	Interval CHAR (2)
)

INSERT INTO @tblPSIMinimumInterval
(
HVCasePK,
TCIDPK,
Interval
)
SELECT 
		cc.HVCasePK	 
		,tcid.TCIDPK
	  , max(Interval) AS Interval 

 		from @tblCommonCohort cc			
			inner join tcid on tcid.hvcasefk = cc.hvcasepk and tcid.programfk = cc.ProgramFK
			inner join codeduebydates on scheduledevent = 'PSI' AND cc.XDateAge >= DueBy -- minimum interval

 GROUP BY HVCasePK
 , tcid.TCIDPK



 --SELECT * FROM @tblPSIMinimumInterval
 -- where HVCasePK = 126505



 DECLARE @tblPSICohort TABLE(	
	[HVCasePK] [int],
	[TCIDPK] int,
	[Interval]	char(2)
)		

;with cteIgnorePSI
as
( -- for psi, ignore due intervals 00 and 01 if baby is born before intake date
SELECT 

 cteIn.HVCasePK,
 cteIn.TCIDPK,
 case
	when datediff(day,IntakeDate,TCDOB_EDC) <= 0 and cteIn.Interval = '00' then 1
	when abs(datediff(m,IntakeDate,TCDOB_EDC)) >= 7 and cteIn.Interval = '01' and datediff(day,IntakeDate,TCDOB_EDC) < 0  then 1
	else
	0
	end as ignore


 FROM @tblCommonCohort cc
 INNER JOIN @tblPSIMinimumInterval cteIn ON cc.HVCasePK = cteIn.HVCasePK

)		



insert into @tblPSICohort 
 SELECT 
 cteIn.HVCasePK,
 cteIn.TCIDPK,
 cteIn.Interval 


 FROM @tblCommonCohort cc
 inner join tcid on tcid.hvcasefk = cc.hvcasepk and tcid.programfk = cc.ProgramFK

 INNER JOIN @tblPSIMinimumInterval cteIn ON cc.HVCasePK = cteIn.HVCasePK
  and TCID.TCIDPK = cteIn.TCIDPK  -- we will use column 'Interval' next, which we just added
  inner join cteIgnorePSI ig on ig.hvcasepk = cc.hvcasepk and cteIn.TCIDPK = ig.TCIDPK
 inner join codeduebydates cd on scheduledevent = 'PSI' AND cteIn.[Interval] = cd.Interval -- to get dueby, max, min (given interval)

 where  
	  ((cc.IntakeDate <= @edate) AND (cc.IntakeDate IS NOT NULL))			  
			AND (cc.DischargeDate IS NULL OR cc.DischargeDate > @edate)  
	 and
	 dateadd(dd,cd.DueBy,TCDOB_EDC) between @sdate and @edate
	and 
	ignore <> 1


--SELECT * FROM @tblPSICohort 



declare @PSIcol1 varchar(10)
declare @PSIcol2 varchar(10)
declare @PSIcol3 varchar(10)
declare @PSIcol4 varchar(10)

------ Number due in Period
set @PSIcol1 =	(SELECT count(HVCasePK) as totalDone FROM @tblPSICohort m) 

-- Number completed  -- Redo ... khalsa
set @PSIcol2 =	(SELECT count(HVCasePK) as totalDone FROM @tblPSICohort m
				 -- The following line gets those tcid's with PSI's that are due for the Interval
				 inner join PSI P on P.HVCaseFK = m.HVCasePK and P.PSIInterval= m.Interval 						
				) 


-- In Window		
set @PSIcol3 =	(SELECT count(HVCasePK) as totalDone FROM @tblPSICohort m
				left join PSI P on P.HVCaseFK = m.HVCasePK and P.PSIInterval= m.Interval 
				where P.PSIInWindow = 1
				) 

-- Valid PSI Score
set @PSIcol4 =	(SELECT count(HVCasePK) as totalDone FROM @tblPSICohort m
				left join PSI P on P.HVCaseFK = m.HVCasePK and P.PSIInterval= m.Interval 
				where P.PSITotalScoreValid  = 1
				) 


INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)
values(8,2,'',
@PSIcol1,
@PSIcol2,
@PSIcol3,
@PSIcol4,
'',
'','',''
)




	-- Referrals

declare @Referralscol1 varchar(10)
declare @Referralscol2 varchar(10)
declare @Referralscol3 varchar(10)

set @Referralscol1 = (SELECT sum(PAOtherHVProgram) as NumOfPAs
FROM @tblCommonCohort cc
inner join Preassessment p on p.HVCaseFK = cc.HVCasePK
where p.PADate between @sdate and @edate)

set @Referralscol2 = (SELECT sum(PIOtherHVProgram) as NumOfPAs
FROM @tblCommonCohort cc
inner join Preintake p on p.HVCaseFK = cc.HVCasePK
where p.PIDate between @sdate and @edate)

set @Referralscol3 = (SELECT count(HVCasePK) as NumAfterEnroll
FROM @tblCommonCohort cc
inner join ServiceReferral sr on sr.HVCaseFK = cc.HVCasePK
where sr.ReferralDate >= cc.IntakeDate and sr.ReferralDate between @sdate and @edate)



INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)
values(9,2,'',
@Referralscol1,
isnull(@Referralscol2,0),
@Referralscol3,
'',
'',
'','',''
)



-- Program Screens (no filter)
INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)
VALUES(1,1,'Program Screens (no filter)', 'Total', 'Positive', 'Negative', 'Prenatal Positive', 'Prenatal Negative', 'Postnatal Positive', 'Postnatal Negative','')

-- add a blank line
INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)
VALUES(1,3,'', '', '', '', '', '', '', '','')

-- Preassessments at End of Period (no filter)
INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)
VALUES(2,1,'Preassessments at End of Period (no filter)', 'Total', 'Prenatal', 'Postnatal', 'Under 21 Years Old', '', '', '','')

-- add a blank line
INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)
VALUES(2,3,'', '', '', '', '', '', '', '','')


-- Kempe Assessments (no filter)
INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)
VALUES(3,1,'Kempe Assessments (no filter)', 'Total', 'Positive', 'Negative', 'Prenatal Positive', 'Prenatal Negative', 'Postnatal Positive', 'Postnatal Negative','')

-- add a blank line
INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)
VALUES(3,3,'', '', '', '', '', '', '', '','')


-- Enrollment Data
INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)
VALUES(4,1,'Enrollment Data', 'Families at Beginning of Period', 'New Families', 'Discharged Families', 'Families at End of Period', '', '', '','')

-- add a blank line
INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)
VALUES(4,3,'', '', '', '', '', '', '', '','')


-- ASQ Data
INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)
VALUES(5,1,'ASQ', 'Number Due in Period', 'Number Completed', 'In Window', 'Under Cut Off', 'Referred to EIP', '', '','')

-- add a blank line
INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)
VALUES(5,3,'', '', '', '', '', '', '', '','')


-- ASQSE Data
INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)
VALUES(6,1,'ASQSE', 'Number Due in Period', 'Number Completed', 'In Window', 'Under Cut Off', 'Referred to EIP', '', '','')

-- add a blank line
INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)
VALUES(6,3,'', '', '', '', '', '', '', '','')

-- FollowUp Data
INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)
VALUES(7,1,'Follow Up / Lead Assessment', 'Number Due in Period', 'Number Completed', 'In Window', '', '', '', '','')

-- add a blank line
INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)
VALUES(7,3,'', '', '', '', '', '', '', '','')

-- FollowUp Data
INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)
VALUES(8,1,'PSI', 'Number Due in Period', 'Number Completed', 'In Window', 'Valid PSI Score', '', '', '','')

-- add a blank line
INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)
VALUES(8,3,'', '', '', '', '', '', '', '','')

-- Referrals Data
INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)
VALUES(9,1,'Referrals', 'Preassessment (no filter)', 'Preintake (no filter)', 'After Enrollment', '', '', '', '','')

-- add a blank line
INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)
VALUES(9,3,'', '', '', '', '', '', '', '','')

-- Details section
-- ASQ Details
INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)
VALUES(10,1,'ASQ Due, but not completed', 'PC1ID', 'Child Name', 'Birth Date', 'Interval', 'Due Date', 'FSW Name', '','')

-- add a blank line
INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)
VALUES(10,3,'', '', '', '', '', '', '', '','')

-- ASQSE Details
INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)
VALUES(11,1,'ASQSE Due, but not completed', 'PC1ID', 'Child Name', 'Birth Date', 'Interval', 'Due Date', 'FSW Name', '','')

-- add a blank line
INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)
VALUES(11,3,'', '', '', '', '', '', '', '','')


-- Follow Up Details
INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)
VALUES(12,1,'Follow Up Due, but not completed', 'PC1ID', 'Child Name', 'Birth Date', 'Interval', 'Due Date', 'FSW Name', '','')

-- add a blank line
INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)
VALUES(12,3,'', '', '', '', '', '', '', '','')

-- PSI Details
INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)
VALUES(13,1,'PSI Due, but not completed', 'PC1ID', 'Child Name', 'Birth Date', 'Interval', 'Due Date', 'FSW Name', '','')

-- add a blank line
INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)
VALUES(13,3,'', '', '', '', '', '', '', '','')

-- New Admission at Enrollment Details
INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)
VALUES(14,1,'New Admission at Enrollment', 'PC1ID','Participant', 'FSW Name', 'Kempe Date', 'Date FSW Assigned', 'Intake Date', 'TANF Services Eligibility', '')

-- add a blank line
INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)
VALUES(14,3,'', '', '', '', '', '', '', '','')

-- Discharges at Preintake Stage Details
INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)
VALUES(15,1,'Discharges at Preintake Stage', 'PC1ID', 'Participant', 'FSW Name', 'Kempe Date', 'Date FSW Assigned', 'Close Date', 'Reason', '')

-- add a blank line
INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)
VALUES(15,3,'', '', '', '', '', '', '', '','')

-- Discharges after Enrollment

DECLARE @tblAverageService TABLE(
	strAverageServiceLength varchar(10)
)

insert into @tblAverageService(strAverageServiceLength)
	SELECT 		
	--Note: The return type of AVG depends on the data type fed to it ... khalsa			
	ceiling(avg(convert(dec(9,2),datediff(day,cc.IntakeDate,DischargeDate)))) as LengthOfServiceInDays

	 FROM @tblCommonCohort AS cc 
		inner join pc on pc.pcpk = cc.pc1fk
		INNER JOIN Intake i on i.HVCaseFK = cc.HVCaseFK
		inner join codeDischarge on DischargeCode = cc.DischargeReason
		INNER JOIN CommonAttributes ca ON ca.HVCaseFK = cc.HVCasePK and ca.FormType = 'IN' 		
	 where (DischargeDate between @sdate and @edate)

declare @AvgServiceLength varchar(10)
set @AvgServiceLength = (select strAverageServiceLength from @tblAverageService)

-- Discharges after Enrollment
INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)
VALUES(16,1,'Discharges after Enrollment Average Length of Service: ' + @AvgServiceLength + ' days' , 'Participant','FSW Name', '# of FSWs', 'Length Of Service (days)', 'Intake Date','TANF Services Eligibility', 'Close Date', 'Reason')

-- add a blank line
INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)
VALUES(16,3,'', '', '', '', '', '', '', '','')

-- Families on Creative Outreach (Level X)
INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)
VALUES(17,1,'Families on Creative Outreach (Level X)', 'PC1ID', 'Participant','FSW Name', 'Days on Level X', 'Level Start Date', 'Period End Date','Level Name', '')

-- add a blank line
INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)
VALUES(17,3,'', '', '', '', '', '', '', '','')

-- Families on Creative Outreach (Level X)
INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)
VALUES(18,1,'Caseload Summary', 'Level', '# of Cases', '', '', '', '','','')

-- add a blank line
INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)
VALUES(18,3,'', '', '', '', '', '', '', '','')

-- rspProgramSynopsis 19, '04/01/2011', '04/30/2011'
--- ASQ DATA ---
;
;with cteASQsReceivingEIPDetail as
( 
	select max(HVCaseFK) as HVCaseFK
	from ASQ a
	where HVCaseFK in (select tcc.HVCasePK from @tblCommonCohort tcc)
			and ASQTCReceiving = 1
	group by a.HVCaseFK
)

, cteASQ as
(
	SELECT PC1ID
			, TCFirstName + ' ' + TCLastName as TCName
			, cc.TCDOB_EDC as TCDOB
			, cc.HVCasePK
			, t.TCIDPK
			, Interval
			, EventDescription 
			, case
			  when Interval < 24 then
				  dateadd(dd,DueBy,(((40-GestationalAge)*7)+ cc.TCDOB_EDC))
			  else
				  dateadd(dd,DueBy,cc.TCDOB_EDC)
			  end as ASQDueDate
			, WorkerName
	FROM @tblCommonCohort cc
	inner join TCID t on t.HVCaseFK = cc.HVCasePK and t.ProgramFK = cc.ProgramFK AND t.TCDOD IS NULL
	inner join codeDueByDates cdbd on scheduledevent = 'ASQ' --optionValue

		where 
			cc.TCDOD IS NULL
			and cc.CaseProgress >= 11
			and (cc.DischargeDate is null or cc.DischargeDate > @edate)
			and case when Interval < 24
					then dateadd(dd, DueBy, (((40 - GestationalAge) * 7) + cc.TCDOB_EDC))
					else dateadd(dd, DueBy, cc.TCDOB_EDC)
				end between @sdate and @edate

			and EventDescription not like '%optional%'  -- optionals are not required so take them out	
			and cc.HVCasePK not in (select HVCaseFK from cteASQsReceivingEIPDetail)
)

-- rspProgramSynopsis 1, '04/01/2013', '04/30/2013'	

-- INSERT ASQ DATA
INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)
				SELECT '10','2', '', PC1ID, TCName, Convert(VARCHAR(12), m.TCDOB, 101) as TCDOB				
				, EventDescription, Convert(VARCHAR(12), ASQDueDate, 101) as ASQDueDate , workername,'',''
				FROM cteASQ m
				left join ASQ A on m.HVCasePK = A.HVCaseFK and m.TCIDPK = A.TCIDFK and m.Interval = A.TCAge
				where A.ASQPK is null
				and	  isnull(A.TCReferred,'0')  <> '1' -- exclude i.e A.TCReferred = '1' if case is referred for EIP service
				-- and (A.TCReferred  is null or A.TCReferred = '0') <-- Another way --  exclude i.e A.TCReferred = '1' if case is referred for EIP service
				order by workername, PC1ID  


--- ASQSE DATA ---
;
with cteASQSE as
(
	SELECT 
	PC1ID, TCFirstName + ' ' + TCLastName as TCName, cc.TCDOB_EDC as TCDOB, cc.HVCasePK,TCID.TCIDPK,Interval, EventDescription 
	,case
	  when interval < 24 then
		  dateadd(dd,dueby,(((40-gestationalage)*7)+ cc.TCDOB_EDC))
	  else
		  dateadd(dd,dueby,cc.TCDOB_EDC)
    end as ASQSEDueDate
	,WorkerName

	FROM @tblCommonCohort cc
	inner join tcid on tcid.hvcasefk = cc.hvcasepk and tcid.programfk = cc.programfk AND TCID.TCDOD IS NULL
	inner join codeduebydates on scheduledevent = 'ASQSE-1' --optionValue

		where 
			cc.TCDOD IS NULL
			and caseprogress >= 11
			and (dischargedate is null or dischargedate > @edate)	
			and case when Interval < 24
					then dateadd(dd, DueBy, (((40 - GestationalAge) * 7) + cc.TCDOB_EDC))
					else dateadd(dd, DueBy, cc.TCDOB_EDC)
				end between @sdate and @edate
)



-- rspProgramSynopsis 1, '04/01/2013', '04/30/2013'	


 -- INSERT ASQ DATA
INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)
				SELECT '11','2', '', PC1ID, TCName, Convert(VARCHAR(12), m.TCDOB, 101) as TCDOB				
				, EventDescription, Convert(VARCHAR(12), ASQSEDueDate, 101) as ASQSEDueDate , workername,'',''
				FROM cteASQSE m
				left join ASQSE A on m.HVCasePK = A.HVCaseFK and m.TCIDPK = A.TCIDFK and m.Interval = A.ASQSETCAge
				where A.ASQSEPK is null
				order by workername, PC1ID  

--- FOLLOW UP DATA ---
;
with cteFollowUp as
(
	SELECT 
	PC1ID, TCFirstName + ' ' + TCLastName as TCName, cc.TCDOB_EDC as TCDOB, cc.HVCasePK,TCID.TCIDPK,cd.Interval, EventDescription 
	,case
	  when cd.interval < 24 then
		  dateadd(dd,dueby,(((40-gestationalage)*7)+ cc.TCDOB_EDC))
	  else
		  dateadd(dd,dueby,cc.TCDOB_EDC)
    end as FollowUpDueDate
	,WorkerName

 FROM @tblCommonCohort cc
 inner join tcid on tcid.hvcasefk = cc.hvcasepk and tcid.programfk = cc.ProgramFK

 INNER JOIN @tblFUMinimumInterval cteIn ON cc.HVCasePK = cteIn.HVCasePK
  --and TCID.TCIDPK = cteIn.TCIDPK  -- we will use column 'Interval' next, which we just added
 inner join codeduebydates cd on scheduledevent = 'Follow Up' AND cteIn.[Interval] = cd.Interval -- to get dueby, max, min (given interval)

		where 
		     cc.TCDOD IS NULL
			 and caseprogress >= 11
			 and (dischargedate is null or dischargedate > @edate)
			 --and (IntakeDate is not null or IntakeDate <= @edate)
       and dateadd(dd,dueby,cc.TCDOB_EDC) between @sdate and @edate
)


-- INSERT Follow Up DATA
INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)
				SELECT '12','2', '', PC1ID, TCName, Convert(VARCHAR(12), m.TCDOB, 101) as TCDOB				
				, EventDescription, Convert(VARCHAR(12), FollowUpDueDate, 101) as FollowUpDueDate , workername,'',''
				FROM cteFollowUp m
				left JOIN FollowUp fu ON fu.HVCaseFK = m.HVCasePK AND fu.FollowUpInterval = m.Interval
				where fu.FollowUpPK is null
				order by workername, PC1ID  

--- PSI DATA ---

;
;with cteIgnorePSI2
as
( -- for psi, ignore due intervals 00 and 01 if baby is born before intake date
SELECT 

 cteIn.HVCasePK,
 cteIn.TCIDPK,
 case
	when datediff(day,IntakeDate,TCDOB_EDC) <= 0 and cteIn.Interval = '00' then 1
	when abs(datediff(m,IntakeDate,TCDOB_EDC)) >= 7 and cteIn.Interval = '01' and datediff(day,IntakeDate,TCDOB_EDC) < 0  then 1
	else
	0
	end as ignore


 FROM @tblCommonCohort cc
 INNER JOIN @tblPSIMinimumInterval cteIn ON cc.HVCasePK = cteIn.HVCasePK

)	

,ctePSI as
(
	SELECT 
	PC1ID, TCFirstName + ' ' + TCLastName as TCName, cc.TCDOB_EDC as TCDOB, cc.HVCasePK,TCID.TCIDPK,cd.Interval, EventDescription 
	,case
	  when cd.interval < 24 then
		  dateadd(dd,dueby,(((40-gestationalage)*7)+ cc.TCDOB_EDC))
	  else
		  dateadd(dd,dueby,cc.TCDOB_EDC)
    end as PSIDueDate
	,WorkerName

 FROM @tblCommonCohort cc
 inner join tcid on tcid.hvcasefk = cc.hvcasepk and tcid.programfk = cc.ProgramFK

 INNER JOIN @tblPSIMinimumInterval cteIn ON cc.HVCasePK = cteIn.HVCasePK
  --and TCID.TCIDPK = cteIn.TCIDPK  -- we will use column 'Interval' next, which we just added
 inner join cteIgnorePSI2 ig on ig.hvcasepk = cc.hvcasepk and cteIn.TCIDPK = ig.TCIDPK
 inner join codeduebydates cd on scheduledevent = 'PSI' AND cteIn.[Interval] = cd.Interval -- to get dueby, max, min (given interval)
WHERE			
	  ((cc.IntakeDate <= @edate) AND (cc.IntakeDate IS NOT NULL))			  
			AND (cc.DischargeDate IS NULL OR cc.DischargeDate > @edate)  
	 and
	 dateadd(dd,cd.DueBy,TCDOB_EDC) between @sdate and @edate	
	and ignore <> 1

)


-- INSERT PSI DATA
INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)
				SELECT '13','2', '', PC1ID, TCName, Convert(VARCHAR(12), m.TCDOB, 101) as TCDOB				
				, EventDescription, Convert(VARCHAR(12), PSIDueDate, 101) as PSIDueDate , workername,'',''
				FROM ctePSI m
				left JOIN PSI P ON P.HVCaseFK = m.HVCasePK AND P.PSIInterval = m.Interval
				where P.PSIPK is null
				order by workername, PC1ID  


-- INSERT New Admission DATA
INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)	
SELECT 	'14','2', '',    
	    PC1ID
	    ,LTRIM(RTRIM(pc.pcfirstname))+' '+LTRIM(RTRIM(pc.pclastname)) as Participant
	    ,workername 
	    ,Convert(VARCHAR(12), cc.KempeDate, 101) as KempeDate
	    ,Convert(VARCHAR(12), p.FSWAssignDate, 101) as FSWAssignDate
	    ,Convert(VARCHAR(12), IntakeDate, 101) as IntakeDate
	    ,CASE WHEN ca.TANFServices = 1 THEN 'Yes' ELSE 'No' END TANFServicesEligibility
	    ,''

		FROM @tblCommonCohort AS cc 
		inner join pc on pc.pcpk = cc.pc1fk
		INNER JOIN Preassessment p ON cc.HVCasePK = p.HVCaseFK 
		INNER JOIN CommonAttributes ca ON ca.HVCaseFK = cc.HVCasePK and ca.FormType = 'IN' 

		where (IntakeDate between @sdate and @edate)
		and p.CaseStatus = '02'


-- rspProgramSynopsis 19, '04/01/2011', '04/30/2011'

-- rspProgramSynopsis 13, '05/01/2013', '05/31/2013'

-- INSERT Discharges at Preintake Stage DATA
--INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)	
--SELECT 	'15','2', '',    
--	    PC1ID
--	    ,LTRIM(RTRIM(pc.pcfirstname))+' '+LTRIM(RTRIM(pc.pclastname)) as Participant
--	    ,workername 
--	    ,Convert(VARCHAR(12), cc.KempeDate, 101) as KempeDate
--	    ,Convert(VARCHAR(12), p.FSWAssignDate, 101) as FSWAssignDate
--	    ,Convert(VARCHAR(12), DischargeDate, 101) as CloseDate
--	    ,codeDischarge.dischargereason as ReasonClosed
--	    ,''

--		FROM @tblCommonCohort AS cc 
--		inner join pc on pc.pcpk = cc.pc1fk
--		INNER JOIN Preassessment p ON cc.HVCasePK = p.HVCaseFK 
--		inner join codeDischarge on DischargeCode = cc.DischargeReason
--		left join codeLevel on cc.CurrentLevelFK = codeLevel.codeLevelPK


--		where (DischargeDate between @sdate and @edate)
--		and codeLevel.LevelName = 'Preintake-term'
--		and IntakeDate is not null	
--		and p.CaseStatus = '02'

INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)
SELECT 	'15','2', '',    
	    PC1ID
	    ,LTRIM(RTRIM(pc.pcfirstname))+' '+LTRIM(RTRIM(pc.pclastname)) as Participant
	    ,workername 
	    ,Convert(VARCHAR(12), cc.KempeDate, 101) as KempeDate
	    ,Convert(VARCHAR(12), p.FSWAssignDate, 101) as FSWAssignDate
	    ,Convert(VARCHAR(12), DischargeDate, 101) as CloseDate
	    ,codeDischarge.dischargereason as ReasonClosed
	    ,''

		FROM @tblCommonCohort AS cc 
		inner join pc on pc.pcpk = cc.pc1fk
		INNER JOIN Preassessment p ON cc.HVCasePK = p.HVCaseFK 
		inner join codeDischarge on DischargeCode = cc.DischargeReason
		left join codeLevel on cc.CurrentLevelFK = codeLevel.codeLevelPK


		where 
		codeLevel.LevelName = 'Preintake-term'
		AND cc.CaseStartDate < @edate  -- handling transfer cases	
		AND (cc.DischargeDate >= @sdate AND cc.DischargeDate <= @edate AND cc.DischargeDate IS NOT NULL)
		and FSWAssignDate is not null

-- Discharges after Enrollment Average Length of Service: 424 days

;with cteNumOfFSWs
as
(
SELECT count(HVCasePK) as count1, HVCasePK  FROM @tblCommonCohort AS cc 
left join WorkerAssignment wa on wa.HVCaseFK = cc.HVCaseFK
group by HVCasePK 
)


-- INSERT Discharges after Enrollment DATA
INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)	
SELECT 	'16','2', ''
		--,cc.HVCasePK     
	    --,PC1ID
	    ,LTRIM(RTRIM(pc.pcfirstname))+' '+LTRIM(RTRIM(pc.pclastname)) as Participant
	    ,workername
	    ,fsws.count1 as NumOfFSWs
	    ,datediff(day,cc.IntakeDate,DischargeDate) as LengthOfServiceInDays
	    ,Convert(VARCHAR(12), cc.IntakeDate, 101) as IntakeDate
	    ,CASE WHEN ca.TANFServices = 1 THEN 'Yes' ELSE 'No' END TANFServicesEligibility
	    ,Convert(VARCHAR(12), DischargeDate, 101) as CloseDate
	    ,codeDischarge.dischargereason as ReasonClosed


		FROM @tblCommonCohort AS cc 
		inner join pc on pc.pcpk = cc.pc1fk
		INNER JOIN Intake i on i.HVCaseFK = cc.HVCaseFK
		inner join codeDischarge on DischargeCode = cc.DischargeReason
		INNER JOIN CommonAttributes ca ON ca.HVCaseFK = cc.HVCasePK and ca.FormType = 'IN' 
		inner join cteNumOfFSWs fsws on fsws.HVCasePK = cc.HVCasePK

		where (DischargeDate between @sdate and @edate)

-- rspProgramSynopsis 19, '04/01/2011', '04/30/2011'


-- Families on Creative Outreach (Level X)

;
with cteLevelInfo
as
(
select hvcasefk, max(hld.StartLevelDate) as StartLevelDate
						  from hvleveldetail hld
						  inner join [dbo].[udfHVRecords](@programfk,@sdate,@edate) hvr on
						 hvr.casefk = hld.hvcasefk
						 where StartLevelDate <= @edate
							   and hvr.programfk = hld.programfk
							   group by hvcasefk 
),

cteLevelXCohort
as
(
select distinct      workername
					,hvr.workerfk
					,count(distinct casefk) as casecount
					,hvr.pc1id
					,startdate
					,enddate
					,hld1.levelname
					,hld1.StartLevelDate as levelstart
					,hvr.dischargedate
					,hvr.pc1id+convert(char(10),hvr.workerfk) as pc1wrkfk --use for a distinct unique field for the OVER(PARTITION BY) above	
					 ,hvr.casefk
					 ,cc.PC1FK
		 from [dbo].[udfHVRecords](@programfk,@sdate,@edate) hvr
			 inner join @tblCommonCohort cc on cc.HVCasePK = hvr.casefk 
			 inner join hvleveldetail hld1 on hld1.hvcasefk = hvr.casefk 
			 inner join cteLevelInfo linfo on linfo.hvcasefk  = hld1.hvcasefk and linfo.StartLevelDate = hld1.StartLevelDate
		 where 
			  startdate < enddate			 
				group by workername
				 ,hvr.workerfk
				 ,hvr.pc1id
				 ,startdate
				 ,enddate
				 ,hld1.levelname
				 ,hld1.StartLevelDate
				 ,reqvisit
				 ,hvr.dischargedate
				 ,hvr.casefk
				 ,hvr.programfk
				 ,cc.PC1FK
)

	,
	cteLevelXSummary
	as
	(select distinct 
	LTRIM(RTRIM(pc.pcfirstname))+' '+LTRIM(RTRIM(pc.pclastname)) as Participant
	,workername
	,datediff(day,levelstart,@edate) as DaysOnLevelX
					,pc1id
					,levelname
					,levelstart
					,max(dischargedate) over (partition by pc1wrkfk) as 'dischargedate'
		 from cteLevelXCohort hvr
			 inner join pc on pc.pcpk = hvr.PC1FK
	)	

-- INSERT Families on Creative Outreach (Level X) DATA	
INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)	
SELECT 	'17','2', ''
		  ,pc1id
		  ,Participant
		  ,workername
		  ,DaysOnLevelX	
		  ,Convert(VARCHAR(12), levelstart, 101) as levelStartDate	  
		  ,Convert(VARCHAR(12), @edate, 101) as levelEndDate
		  ,levelname
		  ,''
		   FROM cteLevelXSummary
	where levelname like 'level x'
	and (dischargedate > @edate or dischargedate is null)


-- Caseload Summary

	declare @tbl4CaseLoadSummary table(
	HVCasePK INT,
	ProgramFK int,
	CurrentLevelFK INT 
	)

	INSERT INTO @tbl4CaseLoadSummary
	(
		HVCasePK,
		ProgramFK,
		CurrentLevelFK

	)	
	SELECT HVCasePK, cc.ProgramFK, CurrentLevelFK  FROM @tblCommonCohort AS cc 
	LEFT JOIN Intake i ON i.HVCaseFK = cc.HVCasePK

	WHERE 
	(
	(cc.IntakeDate IS NOT NULL AND cc.IntakeDate <= @edate)
	AND (cc.DischargeDate IS NULL OR cc.DischargeDate > @edate)
	AND cc.CaseStartDate < @edate  -- handling transfer cases	
	)
	OR 
	(CurrentLevelFK = 8 AND cc.IntakeDate BETWEEN @sdate AND @edate)



	declare @tbl4DataReportRow14RestOfIt table(
	LevelName [char](50),
	levelCount INT
	)	


	;

	WITH cteDataReportRow14RestOfIt AS
	(
	SELECT 
	CASE WHEN CurrentLevelFK = 8 THEN 'Preintake-enroll' ELSE LevelName END AS LevelName, 	
	CASE WHEN hvlevelpk IS NOT NULL OR CurrentLevelFK = 8 THEN 1 ELSE 0 END AS levelcount

	FROM @tbl4CaseLoadSummary t14
			left join (select hvlevel.hvlevelpk
							 ,hvlevel.hvcasefk
							 ,hvlevel.programfk
							 ,hvlevel.levelassigndate
							 ,levelname
							 ,caseweight							 
						   from hvlevel
							   inner join codelevel on codelevelpk = levelfk
							   inner join (select hvcasefk
												 ,programfk
												 ,max(levelassigndate) as levelassigndate
											   from hvlevel h2
											   where levelassigndate <= @edate
											   group by hvcasefk
													   ,programfk) e2 on e2.hvcasefk = hvlevel.hvcasefk and e2.programfk = hvlevel.programfk and e2.levelassigndate = hvlevel.levelassigndate)
													    e3 on e3.hvcasefk = t14.hvcasepk and e3.programfk = t14.programfk

	)

	INSERT INTO @tbl4DataReportRow14RestOfIt
	(
	LevelName,
	levelCount
	)	
	SELECT 
		   lr.LevelName
		  ,CASE when levelCount IS NOT NULL THEN 1 ELSE 0 END AS levelCount
		  FROM cteDataReportRow14RestOfIt	t14Rest
	RIGHT JOIN (SELECT DISTINCT [LevelName] FROM [codeLevel] WHERE ((LevelName LIKE 'level%' AND Enrolled = 1) OR LevelName LIKE 'Preintake-enroll'))  lr ON lr.LevelName = t14Rest.LevelName  -- add missing levelnames
	ORDER BY LevelName 



-- INSERT Caselaod Summary DATA	
INSERT INTO @tblProgramSynopsisReportTitle(rowNumber,rowOrder,strTotals,psrCol0, psrCol1, psrCol2, psrCol3, psrCol4, psrCol5, psrCol6, psrCol7)	
SELECT 	'18','2', ''
	,LevelName
	-- since the null condition in LevelCount was already handled above (in cteDataReportRow14RestOfIt), 
	-- the code below is just adding one to LevelCount when it's 0 for the count of Preintake-Enroll cases
	--,case when LevelName = 'Preintake-enroll' then sum(CASE when levelCount IS NOT NULL THEN 1 ELSE 0 END)
	-- else sum(levelCount)
	-- end  as NumberOfCases	 
	,sum(levelCount) as NumberOfCases	 
	,''
	,''
	,''
	,''
	,''
	,''	
	 FROM @tbl4DataReportRow14RestOfIt
group by LevelName 



-- Now print the report ... Khalsa
SELECT * FROM @tblProgramSynopsisReportTitle
order by rowNumber,rowOrder
GO
