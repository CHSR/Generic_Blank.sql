SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <June 6th, 2013>
-- Description:	The FSW Tickler provides the program staff with both a schedule of upcoming events and a form history of the case.
-- Be patient when running this report as it may take a few seconds. This report should be run monthly.

-- rspFSWEnrolledCaseTickler 5, '12/31/2012'
-- rspFSWEnrolledCaseTickler 1, '08/31/2013'
 -- rspFSWEnrolledCaseTickler 4, '09/30/2013'
-- =============================================


CREATE procedure [dbo].[rspFSWEnrolledCaseTickler](
	@programfk    varchar(max)    = NULL,
    @edate     datetime,
    @supervisorfk int             = null,
    @workerfk     int             = null,
    @pc1id        varchar(13)     = null
)
as

IF 1=0 BEGIN
    SET FMTONLY OFF
END
	if @programfk is null
	begin
		select @programfk = substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end

	set @programfk = REPLACE(@programfk,'"','')
	
	-- First day of the Current Month
	declare @FirstDayOfCurrentMonth datetime
	set @FirstDayOfCurrentMonth = DATEADD(DAY, -(DAY(@edate) - 1), @edate)
	
		
	-- Last Month's Home Visits
	
	-- Last day of Previous Month
	declare @lastDayOfPreviousMonth datetime
	set @lastDayOfPreviousMonth = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@edate),0))  

	-- 1st day of previous month
	declare @firstDayOfPreviousMonth datetime
	set @firstDayOfPreviousMonth = DATEADD(DD, -DAY(DATEADD(DD, -DAY(@edate),@edate))+1,DATEADD(DD, -DAY(@edate),@edate))  
	
	-- Previous Month's Name
	declare @NameOfPreviousMonth varchar(50)
	set @NameOfPreviousMonth = DATENAME(MONTH,@lastDayOfPreviousMonth)
	--select @NameOfPreviousMonth
	
	-- Last 3 Month's Home Visits

	-- 1st day of 3rd previous month
	declare @firstDayOfThirdPreviousMonth datetime	
	declare @TwoMonthsBack datetime
	set @TwoMonthsBack = DATEADD(m, -2,@edate) -- it helps to figure out firstDayOfThirdPreviousMonth
	
	set @firstDayOfThirdPreviousMonth = DATEADD(DD, -DAY(DATEADD(DD, -DAY(@TwoMonthsBack),@TwoMonthsBack))+1, DATEADD(DD, -DAY(@TwoMonthsBack),@TwoMonthsBack))  
	

	declare @LastThreeMonthsNames varchar(150)	
	set @LastThreeMonthsNames = DATENAME(MONTH, DATEADD(m, -3,@edate)) 
								+ ', ' + 
								DATENAME(MONTH,DATEADD(m, -2,@edate))
								+ ', ' + 
								DATENAME(MONTH,DATEADD(m, -1,@edate))								
								
	
	create table #tblCommonCohort(
				[HVCasePK] [int],
				[CaseProgramPK] [int],
				[TCIDPK] [int],
				[tcname]  [varchar](200) NULL,								
				[ProgramFK] [int] NULL,	
				[OldID] [char](23) NULL,
				[PC1ID] [char](13) NULL,
				[tcdob] [datetime] NULL,		
				[SupervisorName]  [varchar](200) NULL,
				[SupervisorFK] int,
				[FSWName]  [varchar](200) NULL,
				[FSWFK] int,
				[PCName]  [varchar](200) NULL,	
				[IntakeDate] [datetime] NULL,
				[DischargeDate] [datetime] NULL,
				[CaseProgress] [numeric](3, 1) NULL,
				[TCNumber] [int] NULL,
				[MultipleBirth] char (3) null,
				[Intakedd] varchar(100),
				[tcid_dd] varchar(50),				
				XDateAge int,
				CurrentLevelFK int,
				TCAgeDays int,
				[Childdob] [datetime] null,	)

	insert into #tblCommonCohort
	select distinct
		h.HVCasePK,
		CaseProgramPK,
		t.TCIDPK, 
		T.TCFirstName + ' ' + t.TCLastName as tcname,
		cp.programfk,
		cp.OldID,
		cp.PC1ID,
		case
		   when h.tcdob is not null then
			   h.tcdob
		   else
			   h.edc
		end as tcdob,
		ltrim(rtrim(supervisor.firstname)) + ' ' + ltrim(rtrim(supervisor.lastname)) supervisor,
		supervisor.WorkerPK as SupervisorFK,	
		ltrim(rtrim(fsw.firstname)) + ' ' + ltrim(rtrim(fsw.lastname)) fswworker,
		fsw.WorkerPK as fswFK,	
		ltrim(rtrim(pc.pcfirstname))+' '+ltrim(rtrim(pc.pclastname)) as pcname,
		h.IntakeDate,
		cp.DischargeDate,
		h.CaseProgress,
		h.TCNumber,
		case when h.TCNumber > 1 then 'Yes' else 'No' end
		as [MultipleBirth],
		case when CaseProgress >= 10 and IntakePK is not null then 'Completed on ' + (convert(varchar(100), h.IntakeDate, 1)) + ' (' + (case when isnull(h.TCDOB, h.EDC) > h.IntakeDate then 'Pre-natal)' when isnull(h.TCDOB, h.EDC) <= h.IntakeDate then 'Post-natal)' else '' end) else 'Due by ' + convert(VARCHAR(20), dateadd(dd,30,h.IntakeDate), 101) end as  intakedd,	 
		case when CaseProgress >= 11 then 'Complete' else 'Not Complete' end as  tcid_dd,	 
		 
		case
		   when h.tcdob is not null then
			 datediff(dd, h.tcdob,  @edate)
		   else
			   datediff(dd, h.edc, @edate)
		end as XDateAge,
		cp.CurrentLevelFK,
		'',
		h.tcdob

		
		
		from HVCase h
		inner join CaseProgram cp on cp.hvcasefk = h.hvcasePk	
		inner join dbo.SplitString(@programfk,',') on cp.programfk = listitem
		inner join pc on pc.pcpk = pc1fk
		left join worker fsw on cp.CurrentFSWFK = fsw.workerpk
		INNER JOIN workerprogram wp ON wp.workerfk = fsw.workerpk AND wp.ProgramFK = ListItem
		left JOIN worker supervisor ON wp.supervisorfk = supervisor.workerpk
		left join TCID T on T.HVCaseFK = h.HVCasePK 
		left join dbo.Intake I on I.HVCaseFK = h.HVCasePK		
		
	-- when you go alive with this, uncomment the following lines and use them	... Khalsa
	where
	(h.IntakeDate IS NOT null)	  
				AND 
				(cp.DischargeDate IS null)  --- case not closed. This is enough because we are dealing with either current month or next month
	and cp.CaseStartDate <= @edate
	 and currentFSWFK = isnull(@workerfk,currentFSWFK)
	 and supervisorfk = isnull(@supervisorfk,supervisorfk)
	 and PC1ID = isnull(@pc1id,PC1ID)	

		
	-- The following where clause is temporary. This enables me to sync with FoxPro data (remove this Where clause when you go alive) ... Khalsa	
	--where   
	--(h.IntakeDate IS NOT null and h.IntakeDate <=  @edate)	  
	--			AND 
	--			(cp.DischargeDate IS null or cp.DischargeDate > @edate)  
	--and cp.CaseStartDate <= @edate
	-- and currentFSWFK = isnull(@workerfk,currentFSWFK)
	-- and supervisorfk = isnull(@supervisorfk,supervisorfk)
	-- and PC1ID = isnull(@pc1id,PC1ID)


-- add tcagedays. we need it in when we count shots later
update #tblCommonCohort 
set TCAgeDays = (case when (DischargeDate is not null and DischargeDate <> '' and DischargeDate <= @eDate) then datediff(day,tcdob,DischargeDate) else  datediff(day,tcdob,@eDate)  end )


-- Max CodeDueBy Frequency for each ScheduledEvent table
------------------------

create table #CodeDueByMaxFrequencies (
			[ScheduledEvent] [varchar](20),
			[Frequency] [int]

)

insert into #CodeDueByMaxFrequencies
SELECT 
      [ScheduledEvent]
      ,max([Frequency]) as Frequency
  FROM [codeDueByDates]
  group by [ScheduledEvent]


--SELECT * FROM #CodeDueByMaxFrequencies
-- rspFSWEnrolledCaseTickler 5, '12/31/2012' 

------- start - getting ready for code that will handle Last ASQ for tc ----- 
-- Note: This almost exact same as code performance target HD7 
	
	--- Note: We are not using this approach anymore ... khalsa
	
	create table #tblPTDetails(
		PTCode				char(5)
		, HVCaseFK			int
		, TCIDPK			int
		, PC1ID				varchar(20)
		, OldID				varchar(30)
		, TCDOB				datetime
		, PC1Fullname		varchar(50)
		, WorkerFullName	varchar(50)
		, CurrentLevelName	varchar(30)
		, FormName			varchar(50)
		, FormDate			datetime
		, FormReviewed		int
		, FormOutOfWindow	int
		, FormMissing		int
		, FormMeetsTarget	int
		, ReasonNotMeeting	varchar(50)
		, TCReceiving1 bit
		, TCReceiving2 bit
		, TCReceiving3 bit
		, TCReceiving4 bit
		
		)
	



	declare @tblPTCohort as PTCases; -- PTCases is a user defined type

	/* Add data to the table variable. */
	insert into @tblPTCohort (HVCaseFK
							 , CaseProgramPK
 							 , PC1ID
							 , OldID
							 , PC1FullName
							 , CurrentWorkerFK
							 , CurrentWorkerFullName
							 , CurrentLevelName
							 , ProgramFK
							 , TCIDPK
							 , TCDOB
							)
						SELECT HVCasePK
					    ,CaseProgramPK
						,PC1ID
						,OldID
						,PCName
						,FSWFK
						,FSWName
						,''
						,cc.ProgramFK
						, TCIDPK
						, TCDOB
							 FROM #tblCommonCohort cc
						





	insert into #tblPTDetails
			exec rspFSWEnrolledCaseTicklerASQSummary null,@eDate,@tblPTCohort

------- end - getting ready for code that will handle Last ASQ for tc ----- 
			
		

;
-- last ASQ

with cteLastASQ
as
(
SELECT cc.HVCasePK, cc.TCIDPK
	  ,max(TCAge) Interval -- We mean really the last date in the database as per JR
 FROM #tblCommonCohort cc
 left join ASQ A ON cc.HVCasePK = A.HVCaseFK and A.TCIDFK = cc.TCIDPK
GROUP BY cc.HVCasePK, cc.TCIDPK

)

,
cteLastASQCompleted  -- get other fields belonging to last asq
as
(
SELECT cc.HVCasePK,A.ASQInWindow,A.ASQTCReceiving,A.TCAge,A.TCReferred,A.DateCompleted,cd.EventDescription,cc.TCIDPK
 FROM #tblCommonCohort cc 
 left join cteLastASQ LastASQ on LastASQ.hvcasePK = cc.hvcasePK and LastASQ.TCIDPK = cc.TCIDPK
 left join ASQ A on A.TCAge = LastASQ.Interval and A.HVCaseFK = LastASQ.hvcasePK  and A.TCIDFK = cc.TCIDPK
 
 --- ToDo: on monday .... khalsa
 
 left join codeduebydates cd on scheduledevent = 'ASQ' AND LastASQ.Interval = cd.Interval -- to get dueby, max, min (given interval)
)


-- ASQSE that is due now
, cteASQSEThatIsDueNow
as
(
SELECT 
		cc.HVCasePK	 
		,cc.TCIDPK
	  , max(Interval) Interval

 		FROM #tblCommonCohort cc
			left join codeduebydates on scheduledevent = 'ASQSE-1' AND cc.XDateAge >= DueBy -- minimum interval

 GROUP BY HVCasePK ,cc.TCIDPK
)

, cteASQSEEIPStatus -- is the child referred to EIP
as
(

SELECT cc.HVCasePK,cc.TCIDPK
	  ,max(ASQSEReceiving) ASQSEReceiving -- We mean really the last date in the database as per JR
 FROM #tblCommonCohort cc
 left join ASQSE A ON cc.HVCasePK = A.HVCaseFK and cc.TCIDPK = A.TCIDFK 
GROUP BY cc.HVCasePK,cc.TCIDPK

)

, cteASQSEThatIsDueNowWithEIPStatus
as
(
SELECT 
		cc.HVCasePK	 
		,cc.TCIDPK
	    ,Interval
	    ,ASQSEReceiving

 		FROM cteASQSEThatIsDueNow cc
 			left join cteASQSEEIPStatus eip ON cc.HVCasePK = eip.HVCasePK and cc.TCIDPK = eip.TCIDPK 

)



--SELECT * FROM cteASQSEThatIsDueNowWithEIPStatus
--order by HVCasePK ,TCIDPK

 -- rspFSWEnrolledCaseTickler 4, '09/30/2013'

-- last ASQSE

, cteLastASQSE
as
(
SELECT cc.HVCasePK,cc.TCIDPK
	  ,max(ASQSETCAge) Interval -- We mean really the last date in the database as per JR
 FROM #tblCommonCohort cc
 left join ASQSE A ON cc.HVCasePK = A.HVCaseFK and cc.TCIDPK = A.TCIDFK 
GROUP BY cc.HVCasePK,cc.TCIDPK

)

,
cteLastASQSECompleted  -- get other fields belonging to last ASQSE
as
(
select distinct cc.HVCasePK,cc.TCIDPK,A.ASQSEInWindow,A.ASQSEReceiving,A.ASQSETCAge,A.ASQSEReferred,A.ASQSEDateCompleted,cd.EventDescription
 FROM #tblCommonCohort cc 
 left join cteLastASQSE LastASQSE on LastASQSE.hvcasePK = cc.hvcasePK and cc.tcidpk = LastASQSE.tcidpk
 left join ASQSE A on A.ASQSETCAge = LastASQSE.Interval and A.HVCaseFK = LastASQSE.hvcasePK and A.TCIDFK = LastASQSE.TCIDPK
 
 --- ToDo: on monday .... khalsa
 
 left join codeduebydates cd on scheduledevent = 'ASQSE-1' AND LastASQSE.Interval = cd.Interval -- to get dueby, max, min (given interval)
)


--SELECT * FROM cteLastASQSECompleted
--where HVCasePK = 20624
--order by HVCasePK,TCIDPK


 --rspFSWEnrolledCaseTickler 4, '09/30/2013'




-- missing psi due
,ctePSIIntervalAlreadyShouldHaveBeenDone
as
(
SELECT 
		cc.HVCasePK,
		cc.TCIDPK	
	  , max(Interval) AS Interval 

 		from #tblCommonCohort cc			
			--left join tcid on tcid.hvcasefk = cc.hvcasepk and tcid.programfk = cc.ProgramFK -- you don't need it because psi test is for parent only (not for child) ( or per case)
			left join codeduebydates on scheduledevent = 'PSI' AND cc.XDateAge >= DueBy -- minimum interval
	 
 GROUP BY HVCasePK, TCIDPK
 
)
,
ctePSIFormDueDates
as
(
	select m.HVCasePK, m.TCIDPK
		--, P.PSIInterval as PSIInterval, psim.Interval as psim_Interval,  PSIPK , tcdob,TCAgeDays
		--,case when psim.Interval is null then ''	
		-- ,case when psim.Interval is null and PSIPK is null then 
		  
		--			case when Childdob is not null then  'PSI due  between ' + convert(varchar(20), tcdob, 101) + ' and ' + convert(varchar(20),  convert(varchar(12), dateadd(dd,30, tcdob), 101))  -- there is a baby
		--			else ' PSI due upon Baby''s Birth'  -- baby is not born yet. it is just a EDC
		--			end
				
		--when  PSIPK is null then cd.EventDescription + ' Due  between ' + convert(varchar(20), dateadd(dd,cd.MinimumDue ,tcdob), 101) + ' and ' + convert(varchar(20), dateadd(dd,cd.MaximumDue ,tcdob), 101)
		--else ''
		--end as PSIDue				
		,case when psim.Interval is null and PSIPK is null then 
						-- there is a baby
		  				case when Childdob is not null then 'PSI due between ' + convert(varchar(20), tcdob, 101) + 
															' and ' + convert(varchar(12), dateadd(dd, 30, tcdob), 101)
						-- baby is not born yet. it is just a EDC
						else ' PSI due upon Baby''s Birth'
						end
					when m.IntakeDate >= m.tcdob AND psim.Interval = '00' then
						case when PSIPK is null then cd.EventDescription + ' Due between ' + convert(varchar(20), dateadd(dd,cd.MinimumDue , m.IntakeDate), 101) 
														+ ' and ' + convert(varchar(20), dateadd(dd,cd.MaximumDue , m.IntakeDate), 101)
						else '' 
						end
					when  PSIPK is null then cd.EventDescription + ' Due  between ' 
										+ convert(varchar(20), dateadd(dd, cd.MinimumDue, 
																		case when psim.Interval = '00' and Childdob < IntakeDate 
																				then IntakeDate 
																				else Childdob end), 101)
										+ ' and ' 
										+ convert(varchar(20), dateadd(dd, cd.MaximumDue, 
																		case when psim.Interval = '00' and Childdob < IntakeDate 
																				then IntakeDate 
																				else Childdob end), 101)
					else ''
				end as PSIDue		
	 
	from #tblCommonCohort m
	left join ctePSIIntervalAlreadyShouldHaveBeenDone psim on psim.hvcasepk = m.hvcasepk and m.TCIDPK = psim.TCIDPK 
	left join codeduebydates cd on scheduledevent = 'PSI' AND psim.[Interval] = cd.Interval -- to get dueby, max, min (given interval)
	-- The following line gets those tcid's with PSI's that are due for the Interval
	left join PSI P on P.HVCaseFK = m.HVCasePK and P.PSIInterval= psim.Interval 
)


-- last psi that was completed
,
cteLastPSI
as
(
SELECT cc.HVCasePK ,cc.TCIDPK
	  ,max(PSIDateComplete) AS PSIMaxDate -- We mean really the last date in the database
	  ,max(PSIInterval) as psiinterval
 FROM #tblCommonCohort cc
 left join PSI P on P.HVCaseFK = cc.HVCasePK  -- it is case based because it is for parent only
GROUP BY cc.HVCasePK,cc.TCIDPK

)
,
cteLastPSIGetOtherNeededFields
as
( -- to get other fields like P.PSIInterval, P.PSIInWindow,P.PSIPK 
SELECT ls.HVCasePK ,ls.TCIDPK,ls.PSIMaxDate,P.PSIInterval, P.PSIInWindow,P.PSIPK 
 FROM cteLastPSI ls
 left join PSI P on P.HVCaseFK = ls.HVCasePK and P.PSIDateComplete = ls.PSIMaxDate and P.PSIInterval = ls.psiinterval -- adding interval eliminates if there are two psi on the same date
)
,
cteLastPSIForm
as
(
SELECT cc.HVCasePK ,cc.TCIDPK,
--oldid,PSIPK, 

    
    case 
    when PSIInterval is null then ''	
    when PSIPK is null then ' Missing'	
	when PSIMaxDate is not null then	
		'Last PSI: ' + cd.EventDescription +
		
			case when lpsi.PSIInWindow = 1 then ' In Window on ' else ' Out of Window on ' end 
		
		   + convert(varchar(20), PSIMaxDate, 101)	
	
	
	else ''
	end  as lastpsi

 FROM #tblCommonCohort cc 
 left join cteLastPSIGetOtherNeededFields lpsi on lpsi.hvcasePK = cc.hvcasePK and cc.tcidpk = lpsi.tcidpk
 left join codeduebydates cd on scheduledevent = 'PSI' AND lpsi.psiinterval = cd.Interval -- to get dueby, max, min (given interval)
)


--- Follow Up forms

-- missing Follow Up due
,cteFollowUpIntervalAlreadyShouldHaveBeenDone
as
(
SELECT 
		cc.HVCasePK,
		cc.TCIDPK	
	  , max(Interval) AS Interval -- for tc less than 6 month olds, interval will be null

 		from #tblCommonCohort cc
 		left join codeduebydates on scheduledevent = 'Follow Up' AND cc.XDateAge >= DueBy -- minimum interval

 GROUP BY HVCasePK, TCIDPK

)

,
cteFollowUpFormDueDates
as
(
SELECT m.HVCasePK, m.TCIDPK, OldID 
--, P.PSIInterval as PSIInterval, psim.Interval as psim_Interval,  PSIPK , tcdob
	 	  ,case when fui.Interval is null then ''
	 	  --,case when psim.Interval is null and PSIPK is null then ' Intake/Birth due by ' + convert(varchar(12), dateadd(dd,31, m.IntakeDate), 101)
			when  FollowUpPK is null then cd.EventDescription + ' Due  between ' + convert(varchar(20), dateadd(dd,cd.MinimumDue ,tcdob), 101) + ' and ' + convert(varchar(20), dateadd(dd,cd.MaximumDue ,tcdob), 101)
			else ''
			end as FollowUpDue				
				
	 
 from #tblCommonCohort m
left join cteFollowUpIntervalAlreadyShouldHaveBeenDone fui on fui.hvcasepk = m.hvcasepk and m.TCIDPK = fui.TCIDPK 
left join codeduebydates cd on scheduledevent = 'Follow Up' AND fui.[Interval] = cd.Interval -- to get dueby, max, min (given interval)
left join FollowUp fu on fu.HVCaseFK = m.HVCasePK and fu.FollowUpInterval = fui.Interval  


)


-- last FollowUp that was completed
,
cteLastFollowUp
as
(
SELECT cc.HVCasePK ,cc.TCIDPK
	  ,max(FollowUpDate) AS FollowUpMaxDate -- We mean really the last date in the database
 FROM #tblCommonCohort cc
 left join FollowUp fu on fu.HVCaseFK = cc.HVCasePK 
GROUP BY cc.HVCasePK,cc.TCIDPK

)
 
,
cteLastFollowUpGetOtherNeededFields
as
( -- to get other fields like fu.FollowUpInterval,fu.FUPInWindow, fu.FollowUpPK
SELECT lf.HVCasePK ,lf.TCIDPK,lf.FollowUpMaxDate,fu.FollowUpInterval,fu.FUPInWindow, fu.FollowUpPK
 FROM cteLastFollowUp lf
 left join FollowUp fu on fu.HVCaseFK = lf.HVCasePK and fu.FollowUpDate = lf.FollowUpMaxDate 
)
,
cteLastFollowUpForm
as
(
SELECT cc.HVCasePK ,cc.TCIDPK,oldid,
--oldid,PSIPK, 

    
    case 
    when FollowUpInterval is null then ''	
    when FollowUpPK is null then ' Missing'	
	when FollowUpMaxDate is not null then	
		'Last Follow-Up: ' + cd.EventDescription +
		
			case when lfu.FUPInWindow = 1 then ' In Window on ' else ' Out of Window on ' end 
		
		   + convert(varchar(20), FollowUpMaxDate, 101)	
	
	
	else ''
	end  as lastFollowUp

 FROM #tblCommonCohort cc 
 left join cteLastFollowUpGetOtherNeededFields lfu on lfu.hvcasePK = cc.hvcasePK and cc.tcidpk = lfu.tcidpk
 left join codeduebydates cd on scheduledevent = 'Follow Up' AND lfu.FollowUpInterval = cd.Interval -- to get dueby, max, min (given interval)
)


,cteUniqueHVCases2  -- To handle twins for service referrals count
as
(
	select distinct HVCasePK, ProgramFK, IntakeDate FROM #tblCommonCohort cc

)

,cteReferrals
as
(
SELECT 
		cc.HVCasePK	
		,count(cc.HVCasePK) as ref_enr		
		,sum(case when (startdate is null and 
				(sr.ServiceReceived is null
					or sr.ServiceReceived = 0
						or sr.ServiceReceived = RTRIM(''))
							and (sr.ReasonNoService = rtrim(''))
		
				) then 1 else 0 end) as ref_fup
		
	  , max(sr.ReferralDate) AS ref_last
 
 FROM cteUniqueHVCases2 cc 
	inner join ServiceReferral sr on sr.HVCaseFK = cc.HVCasePK and	sr.ProgramFK = cc.ProgramFK
	inner join codeApp ca on sr.FamilyCode = ca.AppCode
		  and ca.AppCodeGroup = 'FamilyMemberReferred'	

 GROUP BY HVCasePK 
)

,
cteTCIDFormDone
as
(
SELECT 
 HVCasePK
  ,	case when CaseProgress >= 11 then 'Complete' else 		
	
	case when IntakeDate >= tcdob then 'due by ' + convert(VARCHAR(20), dateadd(dd,30,IntakeDate), 101)
		else 'due 30 days after baby''s birth'
	 end 
	 
	 end as  tcid_dd -- dd = done

 
 FROM #tblCommonCohort cc 
)

-- Last Months Home Visits
,cteUniqueCases4Monthly
as
(
select distinct HVCasePK		
	FROM #tblCommonCohort cc
)

,
cteExpectedMonthlyHomeVisits
as
(

	select HVCasePK	
	,floor(sum(reqvisit)) as expectedvisitcount
	
	FROM cteUniqueCases4Monthly cc 
	left join [dbo].[udfLevelPieces](@programfk,@firstDayOfPreviousMonth,@lastDayOfPreviousMonth) tlp on tlp.casefk = cc.HVCasePK 

	group by HVCasePK 
	)

,
cteAttemptedAndActualMonthlyHomeVisits
as
(

	SELECT cc.HVCasePK	
	
	,sum(case
			 when visittype <> '0001' then
				 1
			 else
				 0
		 end) as actualvisitcount
	,sum(case
			 when substring(visittype,1,1) = '1' or substring(visittype,2,1) = '1' then
				 1
			 else
				 0
		 end) as inhomevisitcount
	,sum(case
			 when visittype = '0001' then
				 1
			 else
				 0
		 end) as attemptedvisitcount

	,sum(visitlengthminute)+sum(visitlengthhour)*60  as VisitLengthInminutesMOnthly
	
	FROM #tblCommonCohort cc 	
	left outer join hvlog on cc.hvcasepk = hvlog.hvcasefk
							   and cast(VisitStartTime AS DATE) between @firstDayOfPreviousMonth and @lastDayOfPreviousMonth
							   
	group by cc.HVCasePK 

	)

-- Last 3 Months Home Visits

,cteUniqueCases4ThreeMonthly
as
(
select distinct HVCasePK		
	FROM #tblCommonCohort cc
)



,
cteExpected3MonthsHomeVisits
as
(
	
	SELECT HVCasePK	
	,floor(sum(reqvisit)) as expected3Monthsvisitcount
	
	FROM cteUniqueCases4ThreeMonthly cc 
	left join [dbo].[udfLevelPieces](@programfk,@firstDayOfThirdPreviousMonth,@lastDayOfPreviousMonth) tlp on tlp.casefk = cc.HVCasePK 	
	
	group by HVCasePK
	
	)

,
cteAttemptedAndActual3MonthsHomeVisits
as
(

	SELECT cc.HVCasePK	
	
	,sum(case
			 when visittype <> '0001' then
				 1
			 else
				 0
		 end) as actual3Monthsvisitcount
	,sum(case
			 when visittype = '1000' then
				 1
			 else
				 0
		 end) as inhome3Monthsvisitcount
	,sum(case
			 when visittype = '0001' then
				 1
			 else
				 0
		 end) as attempted3Monthsvisitcount
	,sum(visitlengthminute)+sum(visitlengthhour)*60 as VisitLengthInminutes3MOnthly
	
	FROM #tblCommonCohort cc 	
	left outer join hvlog on cc.hvcasepk = hvlog.hvcasefk
							   and cast(VisitStartTime AS DATE) between @firstDayOfThirdPreviousMonth and @lastDayOfPreviousMonth
							   
	group by cc.HVCasePK 

	)

,cteUniqueHVCases  -- To handle twins for last 5 home visits
as
(
	select distinct HVCasePK FROM #tblCommonCohort cc

)


,cteLast5Visits
as
(
select HVCasePK
		 ,case
			 when visittype = '0001' then
				 Convert(VARCHAR(12), VisitStartTime, 101) + 'a'  -- attempted visits
			 else
				 Convert(VARCHAR(12), VisitStartTime, 101)
		 end
	   as VisitStartTime
	  ,VisitType
	  ,RowNumber = row_number() over (partition by h.HVCaseFK order by VisitStartTime asc)
	   FROM cteUniqueHVCases cc
		inner join HVLog h on h.HVCaseFK = cc.HVCasePK
)

,cteTakeBottom5Visits
as
( -- gets the "last 5" rows from a table without ordering
	SELECT *
	 FROM cteLast5Visits ol
	where RowNumber > (SELECT (MAX([RowNumber]) - 5) FROM cteLast5Visits il where ol.HVCasePK = il.HVCasePK )  -- interesting how I acheived it  ... khalsa

)

,cteLast5VisitsConcatenated
as
(-- Problem: How to concatenate VisitStartTime? Here is a solution ... khalsa
select  cc.HVCasePK,
		(
			select top 5 VisitStartTime + ', '  -- last 5 home visits only please
			from cteTakeBottom5Visits ls
			where ls.HVCasePK = cc.HVCasePK 
			--order by VisitStartTime desc
			order by HVCasePK,RowNumber asc  -- This Order by is important. it gives the latest 5 visits in desc ... khalsa
			for xml path('')  
		
		) as Last5Visits

	   FROM #tblCommonCohort cc	  
	   group by cc.HVCasePK 

)

,cteLevel
as
(  -- Problem: There may be two levels in a given month. one level ending and other starting. How do we pick up the last one? .. khalsa
	select HVCasePK
	,levelname, StartLevelDate 
	,RowNumber = row_number() over (partition by hld.HVCaseFK order by StartLevelDate desc)
	FROM #tblCommonCohort cc 
	inner join [HVLevelDetail] hld on hld.hvcasefk = cc.HVCasePK 
	where (StartLevelDate <= @edate)  -- just within the given month only
	and (EndLevelDate >= @FirstDayOfCurrentMonth or EndLevelDate is null)	

)

,cteCurrentLevel
as
( -- This will help us to pick the latest (last) level if there are two levels in a given month .. khalsa
	select HVCasePK,
		(
			select top 1 levelname  
			from cteLevel ls
			where ls.HVCasePK = cc.HVCasePK 
			order by StartLevelDate desc
			
		
		) as levelname,
		(
			select top 1 StartLevelDate  
			from cteLevel ls
			where ls.HVCasePK = cc.HVCasePK 
			order by StartLevelDate desc
			
		
		) as StartLevelDate
		
	   FROM #tblCommonCohort cc	  
	   group by cc.HVCasePK 


)
,
cteTCID
as
(
	select  
	cc.HVCasePK
			,T.HVCaseFK as tcidHVCaseFK
		   ,T.TCIDPK,
		   --T.TCFirstName + ' ' + t.TCLastName as tcname,
		   --cc.TCDOB,
		   case when T.TCDOD < @edate and T.TCDOD is not null then T.TCDOD else null end as tcdod,
		  dateadd(dd, (40 -T.GestationalAge)*7, T.TCDOB) as dev_bdate,
		  case when T.tcidPK is not null then 'Complete' else '' end as tciddone
	 FROM #tblCommonCohort cc
	left join TCID T on t.HVCaseFK = cc.HVCasePK and T.TCIDPK = cc.TCIDPK 	  
)
,
cteTCMedical
as
(
SELECT cc.HVCasePK ,cc.TCIDPK
	  ,max(TCItemDate) AS TCMedicalMaxDate -- We mean really the last date in the database as per JR
 FROM #tblCommonCohort cc
 LEFT JOIN TCMedical t ON cc.HVCasePK = t.HVCaseFK and cc.TCIDPK = t.TCIDFK
GROUP BY cc.HVCasePK,cc.TCIDPK

)
,
cteLastDateOnMedicalForm
as
(
SELECT cc.HVCasePK ,cc.TCIDPK,oldid,

	case when cc.tcidpk is null 
	 and datediff( d, tcdob, intakedate) >= 0
	 and datediff( d, @edate, dateadd(dd, 30,tcdob)) >= 0 	
	 then 'Missing'
	 when cc.tcidpk is null 
	 and datediff( d, tcdob, intakedate) < 0
	 and datediff( d, @edate, dateadd(dd, 30, intakedate)) < 0 	
     then 'due by ' + convert(varchar(20), dateadd(dd, 30,intakedate), 101)	
     	
	when TCMedicalMaxDate is not null then	
		 convert(varchar(20), TCMedicalMaxDate, 101)
	else ''
	end  as lastdate

 FROM #tblCommonCohort cc 
 left join cteTCMedical tcm on tcm.hvcasePK = cc.hvcasePK and cc.tcidpk = tcm.tcidpk
)

 -- rspFSWEnrolledCaseTickler 5, '12/31/2012'


,cteTCIDCohort
as
(
SELECT cc.HVCasePK,
		T.TCIDPK,
		 case
				  when DischargeDate is not null and DischargeDate <> '' and DischargeDate <= @eDate then
					  DischargeDate
				  else
					  @eDate
			  end as lastdate,
		case
		  when DischargeDate is not null and DischargeDate <> '' and DischargeDate <= @eDate then
			  datediff(day,cc.tcdob,DischargeDate)
		  else
			  datediff(day,cc.tcdob,@eDate)
	  end as tcAgeDays,
	  GestationalAge,
	  cc.TCDOB	  		
		
 FROM #tblCommonCohort cc
left join TCID T on T.HVCaseFK = cc.HVCasePK 		

)
,
cteTCIDCohort2
as
(
	select HVCasePK
		  
		  , TCIDPK
		  
		  , case when datediff(month,TCDOB,lastdate) >= 24 or GestationalAge = 40
					then tcAgeDays
				when datediff(month,TCDOB,lastdate) < 24 and GestationalAge < 40
					then tcAgeDays - ((40-GestationalAge) * 7)
			end as tcASQAgeDays
		  	  
		from cteTCIDCohort ca
	)

,
cteASQDueInterval -- age appropriate ASQ Intervals that are expected to be there
as
(
	select
		  cc.HVCasePK
		 ,cc.TCIDPK
		 ,max(cd.Interval) as Interval -- given child age, this is the interval that one expect to find ASQ record in the DB

		from cteTCIDCohort2 cc
			left join codeDueByDates cd on scheduledevent = 'ASQ' and tcASQAgeDays >= DueBy			
		group by cc.HVCasePK
		 ,cc.TCIDPK
					-- Must 'group by HVCasePK, TCIDPK' to bring in twins etc (twins have same hvcasepks) (not just 'group by HVCasePK')
)


-- Shots

   
	,
	cteImmunizationsPolio
	as
	(
	select coh.HVCasePK
			, coh.TCIDPK
			, MedicalItemTitle
			, count(coh.TCIDPK) as ImmunizationCountPolio
			, count(case when dbo.IsFormReviewed(TCItemDate,'TM',TCMedicalPK) = 1 
					then 1 
					else 0 
					end) as FormReviewedCountPolio
		from #tblCommonCohort coh
			left join TCMedical on TCMedical.hvcasefk = coh.HVCasePK and TCMedical.TCIDFK = coh.TCIDPK
			left join codeMedicalItem cmi on cmi.MedicalItemCode = TCMedical.TCMedicalItem
		where TCItemDate between TCDOB and @edate 
				and MedicalItemTitle = 'Polio'
		group by coh.HVCasePK
				, coh.TCIDPK
				, MedicalItemTitle
				
	)



--SELECT * FROM cteImmunizationsPolio
--order by hvcasepk
---- rspFSWEnrolledCaseTickler 1, '07/31/2013'





	,
	cteImmunizationsDTaP
	as
	(
	select coh.HVCasePK
			, coh.TCIDPK
			, MedicalItemTitle
			, count(coh.TCIDPK) as ImmunizationCountDTaP
			, count(case when dbo.IsFormReviewed(TCItemDate,'TM',TCMedicalPK) = 1 
					then 1 
					else 0 
					end) as FormReviewedCountDTaP
		from #tblCommonCohort coh
			left join TCMedical on TCMedical.hvcasefk = coh.HVCasePK and TCMedical.TCIDFK = coh.TCIDPK
			inner join codeMedicalItem cmi on cmi.MedicalItemCode = TCMedical.TCMedicalItem
		where TCItemDate between TCDOB and @edate
				and MedicalItemTitle = 'DTaP'
				 group by coh.HVCasePK
				, coh.TCIDPK
				, MedicalItemTitle
				
	)	
	
	,
	cteImmunizationsMMR
	as
	(
	select coh.HVCasePK
			, coh.TCIDPK
			, MedicalItemTitle
			, count(coh.TCIDPK) as ImmunizationCountMMR
			, count(case when dbo.IsFormReviewed(TCItemDate,'TM',TCMedicalPK) = 1 
					then 1 
					else 0 
					end) as FormReviewedCountMMR
		from #tblCommonCohort coh
			left join TCMedical on TCMedical.hvcasefk = coh.HVCasePK and TCMedical.TCIDFK = coh.TCIDPK
			inner join codeMedicalItem cmi on cmi.MedicalItemCode = TCMedical.TCMedicalItem
		where TCItemDate between TCDOB and @edate
				and MedicalItemTitle = 'MMR'
				 group by coh.HVCasePK
				, coh.TCIDPK
				, MedicalItemTitle
				
	)	
	,
	cteImmunizationsHIB
	as
	(
	select coh.HVCasePK
			, coh.TCIDPK
			, MedicalItemTitle
			, count(coh.TCIDPK) as ImmunizationCountHIB
			, count(case when dbo.IsFormReviewed(TCItemDate,'TM',TCMedicalPK) = 1 
					then 1 
					else 0 
					end) as FormReviewedCountHIB
		from #tblCommonCohort coh
			left join TCMedical on TCMedical.hvcasefk = coh.HVCasePK and TCMedical.TCIDFK = coh.TCIDPK
			inner join codeMedicalItem cmi on cmi.MedicalItemCode = TCMedical.TCMedicalItem
		where TCItemDate between TCDOB and @edate
				and MedicalItemTitle = 'HIB'
				 group by coh.HVCasePK
				, coh.TCIDPK
				, MedicalItemTitle
				
	)			
	,
	cteImmunizationsHEPB
	as
	(
	select coh.HVCasePK
			, coh.TCIDPK
			, MedicalItemTitle
			, count(coh.TCIDPK) as ImmunizationCountHEP
			, count(case when dbo.IsFormReviewed(TCItemDate,'TM',TCMedicalPK) = 1 
					then 1 
					else 0 
					end) as FormReviewedCountHEP
		from #tblCommonCohort coh
			left join TCMedical on TCMedical.hvcasefk = coh.HVCasePK and TCMedical.TCIDFK = coh.TCIDPK
			inner join codeMedicalItem cmi on cmi.MedicalItemCode = TCMedical.TCMedicalItem
		where TCItemDate between TCDOB and @edate
				and MedicalItemTitle like 'HEP-B'
				--and MedicalItemTitle like 'HEP-%'
				 group by coh.HVCasePK
				, coh.TCIDPK
				, MedicalItemTitle
				
	)	
	
	
	,
	cteImmunizationsHEPA
	as
	(
	select coh.HVCasePK
			, coh.TCIDPK
			, MedicalItemTitle
			, count(coh.TCIDPK) as ImmunizationCountHEPA
			, count(case when dbo.IsFormReviewed(TCItemDate,'TM',TCMedicalPK) = 1 
					then 1 
					else 0 
					end) as FormReviewedCountHEPA
		from #tblCommonCohort coh
			left join TCMedical on TCMedical.hvcasefk = coh.HVCasePK and TCMedical.TCIDFK = coh.TCIDPK
			inner join codeMedicalItem cmi on cmi.MedicalItemCode = TCMedical.TCMedicalItem
		where TCItemDate between TCDOB and @edate
				and MedicalItemTitle like 'HEP-A'
				--and MedicalItemTitle like 'HEP-%'
				 group by coh.HVCasePK
				, coh.TCIDPK
				, MedicalItemTitle
				
	)	
		
	,
	cteImmunizationsFLU
	as
	(
	select coh.HVCasePK
			, coh.TCIDPK
			, MedicalItemTitle
			, count(coh.TCIDPK) as ImmunizationCountFLU
			, count(case when dbo.IsFormReviewed(TCItemDate,'TM',TCMedicalPK) = 1 
					then 1 
					else 0 
					end) as FormReviewedCountFLU
		from #tblCommonCohort coh
			left join TCMedical on TCMedical.hvcasefk = coh.HVCasePK and TCMedical.TCIDFK = coh.TCIDPK
			inner join codeMedicalItem cmi on cmi.MedicalItemCode = TCMedical.TCMedicalItem
		where TCItemDate between TCDOB and @edate
				and MedicalItemTitle like 'FLU'
				 group by coh.HVCasePK
				, coh.TCIDPK
				, MedicalItemTitle
				
	)				
	,
	cteImmunizationsROTO
	as
	(
	select coh.HVCasePK
			, coh.TCIDPK
			, MedicalItemTitle
			, count(coh.TCIDPK) as ImmunizationCountROTO
			, count(case when dbo.IsFormReviewed(TCItemDate,'TM',TCMedicalPK) = 1 
					then 1 
					else 0 
					end) as FormReviewedCountROTO
		from #tblCommonCohort coh
			left join TCMedical on TCMedical.hvcasefk = coh.HVCasePK and TCMedical.TCIDFK = coh.TCIDPK
			inner join codeMedicalItem cmi on cmi.MedicalItemCode = TCMedical.TCMedicalItem
		where TCItemDate between TCDOB and @edate
				and MedicalItemTitle like 'Roto'
				 group by coh.HVCasePK
				, coh.TCIDPK
				, MedicalItemTitle
				
	)				
	,
	cteImmunizationsPCV
	as
	(
	select coh.HVCasePK
			, coh.TCIDPK
			, MedicalItemTitle
			, count(coh.TCIDPK) as ImmunizationCountPCV
			, count(case when dbo.IsFormReviewed(TCItemDate,'TM',TCMedicalPK) = 1 
					then 1 
					else 0 
					end) as FormReviewedCountPCV
		from #tblCommonCohort coh
			left join TCMedical on TCMedical.hvcasefk = coh.HVCasePK and TCMedical.TCIDFK = coh.TCIDPK
			inner join codeMedicalItem cmi on cmi.MedicalItemCode = TCMedical.TCMedicalItem
		where TCItemDate between TCDOB and @edate
				and MedicalItemTitle like 'PCV'
				 group by coh.HVCasePK
				, coh.TCIDPK
				, MedicalItemTitle
				
	)				
	,
	cteImmunizationsVZ  -- Chicken Pox
	as
	(
	select coh.HVCasePK
			, coh.TCIDPK
			, MedicalItemTitle
			, count(coh.TCIDPK) as ImmunizationCountVZ
			, count(case when dbo.IsFormReviewed(TCItemDate,'TM',TCMedicalPK) = 1 
					then 1 
					else 0 
					end) as FormReviewedCountHEP
		from #tblCommonCohort coh
			left join TCMedical on TCMedical.hvcasefk = coh.HVCasePK and TCMedical.TCIDFK = coh.TCIDPK
			inner join codeMedicalItem cmi on cmi.MedicalItemCode = TCMedical.TCMedicalItem
		where TCItemDate between TCDOB and @edate
				and MedicalItemTitle like 'VZ'
				 group by coh.HVCasePK
				, coh.TCIDPK
				, MedicalItemTitle
				
	)		
	,
	cteImmunizationsWBV -- Well Baby Visits
	as
	(
	select coh.HVCasePK
			, coh.TCIDPK
			, MedicalItemTitle
			, count(coh.TCIDPK) as ImmunizationCountWBV
			, count(case when dbo.IsFormReviewed(TCItemDate,'TM',TCMedicalPK) = 1 
					then 1 
					else 0 
					end) as FormReviewedCountHEP
		from #tblCommonCohort coh
			left join TCMedical on TCMedical.hvcasefk = coh.HVCasePK and TCMedical.TCIDFK = coh.TCIDPK
			inner join codeMedicalItem cmi on cmi.MedicalItemCode = TCMedical.TCMedicalItem
		where TCItemDate between TCDOB and @edate
				and MedicalItemTitle like 'WBV'
				 group by coh.HVCasePK
				, coh.TCIDPK
				, MedicalItemTitle
				
	)		

	,
	cteImmunizationsLeadScreening -- Lead screening
	as
	(
	select coh.HVCasePK
			, coh.TCIDPK
			, MedicalItemTitle
			, count(coh.TCIDPK) as ImmunizationCountLeadScreening
			, count(case when dbo.IsFormReviewed(TCItemDate,'TM',TCMedicalPK) = 1 
					then 1 
					else 0 
					end) as FormReviewedCountHEP
		from #tblCommonCohort coh
			left join TCMedical on TCMedical.hvcasefk = coh.HVCasePK and TCMedical.TCIDFK = coh.TCIDPK
			inner join codeMedicalItem cmi on cmi.MedicalItemCode = TCMedical.TCMedicalItem
		where TCItemDate between TCDOB and @edate
				and MedicalItemTitle like 'Lead'
				 group by coh.HVCasePK
				, coh.TCIDPK
				, MedicalItemTitle
				
	)		
	
	
--- intervals	
	
,cteDTPInterval
as
(
SELECT 
		cc.HVCasePK,
		cc.TCIDPK	
	  , max(Interval) AS Interval 
	  , max(DueBy) as DueBy
	  , max(MaximumDue) as MaximumDue	  
	  , max(Frequency) as Frequency
	  
 		from #tblCommonCohort cc			
			left join codeduebydates on scheduledevent = 'DTaP' AND Interval  <= datediff(M, dateadd(dd, -30.44, cc.TCDOB), @eDate)
	 
 GROUP BY HVCasePK, TCIDPK
 
)
,cteHEPBInterval
as
(
SELECT 
		cc.HVCasePK,
		cc.TCIDPK	
	  , max(Interval) AS Interval 
	  , max(DueBy) as DueBy
	  , max(MaximumDue) as MaximumDue	  
	  , max(Frequency) as Frequency
	  
 		from #tblCommonCohort cc			
			left join codeduebydates on scheduledevent = 'HEP-B' AND Interval  <= datediff(M, dateadd(dd, -30.44, cc.TCDOB), @eDate)
	 
 GROUP BY HVCasePK, TCIDPK
 
)	


,cteHEPAInterval
as
(
SELECT 
		cc.HVCasePK,
		cc.TCIDPK	
	  , max(Interval) AS Interval 
	  , max(DueBy) as DueBy
	  , max(MaximumDue) as MaximumDue	  
	  , max(Frequency) as Frequency
	  
 		from #tblCommonCohort cc			
			left join codeduebydates on scheduledevent = 'HEP-A' AND Interval  <= datediff(M, dateadd(dd, -30.44, cc.TCDOB), @eDate)
	 
 GROUP BY HVCasePK, TCIDPK
 
)	

,cteFLUInterval
as
(
SELECT 
		cc.HVCasePK,
		cc.TCIDPK	
	  , max(Interval) AS Interval 
	  , max(DueBy) as DueBy
	  , max(MaximumDue) as MaximumDue	  
	  , max(Frequency) as Frequency
	  
 		from #tblCommonCohort cc			
			left join codeduebydates on scheduledevent = 'Flu' AND Interval  <= datediff(M, dateadd(dd, -30.44, cc.TCDOB), @eDate) -- minimum interval
	 
 GROUP BY HVCasePK, TCIDPK
 
)	
,cteROTOInterval
as
(
SELECT 
		cc.HVCasePK,
		cc.TCIDPK	
	  , max(Interval) AS Interval 
	  , max(DueBy) as DueBy
	  , max(MaximumDue) as MaximumDue	  
	  , max(Frequency) as Frequency
	  
 		from #tblCommonCohort cc			
			left join codeduebydates on scheduledevent = 'Roto' AND Interval  <= datediff(M, dateadd(dd, -30.44, cc.TCDOB), @eDate)
	 
 GROUP BY HVCasePK, TCIDPK
 
)	
,ctePCVInterval
as
(
SELECT 
		cc.HVCasePK,
		cc.TCIDPK	
	  , max(Interval) AS Interval 
	  , max(DueBy) as DueBy
	  , max(MaximumDue) as MaximumDue	  
	  , max(Frequency) as Frequency
	  
 		from #tblCommonCohort cc			
			left join codeduebydates on scheduledevent = 'PCV' AND Interval  <= datediff(M, dateadd(dd, -30.44, cc.TCDOB), @eDate)
	 
 GROUP BY HVCasePK, TCIDPK
 
)	

,cteHIBInterval
as
(
SELECT 
		cc.HVCasePK,
		cc.TCIDPK	
	  , max(Interval) AS Interval 
	  , max(DueBy) as DueBy
	  , max(MaximumDue) as MaximumDue	  
	  , max(Frequency) as Frequency
	  
 		from #tblCommonCohort cc			
			left join codeduebydates on scheduledevent = 'HIB' AND Interval  <= datediff(M, dateadd(dd, -30.44, cc.TCDOB), @eDate)
	 
 GROUP BY HVCasePK, TCIDPK
 
)		
,cteLeadInterval
as
(
SELECT 
		cc.HVCasePK,
		cc.TCIDPK	
	  , max(Interval) AS Interval 
	  , max(DueBy) as DueBy
	  , max(MaximumDue) as MaximumDue	  
	  , max(Frequency) as Frequency
	  
 		from #tblCommonCohort cc			
			left join codeduebydates on scheduledevent = 'Lead' AND Interval  <= datediff(M, dateadd(dd, -30.44, cc.TCDOB), @eDate)
	 
 GROUP BY HVCasePK, TCIDPK
 
)		
,cteMMRInterval
as
(
SELECT 
		cc.HVCasePK,
		cc.TCIDPK	
	  , max(Interval) AS Interval 
	  , max(DueBy) as DueBy
	  , max(MaximumDue) as MaximumDue	  
	  , max(Frequency) as Frequency
	  
 		from #tblCommonCohort cc			
			left join codeduebydates on scheduledevent = 'MMR' AND Interval  <= datediff(M, dateadd(dd, -30.44, cc.TCDOB), @eDate)
	 
 GROUP BY HVCasePK, TCIDPK
 
)		
,ctePolioInterval
as
(
SELECT 
		cc.HVCasePK,
		cc.TCIDPK	
	  , max(Interval) AS Interval 
	  , max(DueBy) as DueBy
	  , max(MaximumDue) as MaximumDue	  
	  , max(Frequency) as Frequency
	  
 		from #tblCommonCohort cc			
			left join codeduebydates on scheduledevent = 'Polio' AND MaximumDue < cc.TCAgeDays  -- minimum interval
	 
 GROUP BY HVCasePK, TCIDPK
 
)		



,cteVZInterval -- Chicken Pox
as
(
SELECT 
		cc.HVCasePK,
		cc.TCIDPK	
	  , max(Interval) AS Interval 
	  , max(DueBy) as DueBy
	  , max(MaximumDue) as MaximumDue	  
	  , max(Frequency) as Frequency
	  
 		from #tblCommonCohort cc			
			left join codeduebydates on scheduledevent = 'VZ' AND Interval  <= datediff(M, dateadd(dd, -30.44, cc.TCDOB), @eDate)
	 
 GROUP BY HVCasePK, TCIDPK
 
)	
,cteWBVInterval
as
(
SELECT 
		cc.HVCasePK,
		cc.TCIDPK	
	  , max(Interval) AS Interval 
	  , max(DueBy) as DueBy
	  , max(MaximumDue) as MaximumDue	  
	  , max(Frequency) as Frequency
	  
 		from #tblCommonCohort cc			
			left join codeduebydates on scheduledevent = 'WBV' AND Interval  <= datediff(M, dateadd(dd, -30.44, cc.TCDOB), @eDate)
	 
 GROUP BY HVCasePK, TCIDPK
 
)	



SELECT distinct cc.HVCasePK
	  ,cc.ProgramFK
	  ,cc.OldID
	  , case when TCNumber > 1 then cc.PC1ID + ' (Pages: ' + convert(varchar, TCNumber) + ')' else cc.PC1ID end PC1ID
	  --,cc.PC1ID
	  ,CONVERT(varchar, cc.tcdob, 101) as tcdob
	  ,TCAgeDays
	  ,SupervisorName
	  ,SupervisorFK
	  ,FSWName
	  ,cc.FSWFK
	  ,PCName
	  ,cc.TCIDPK 
	  ,tcname
	  ,IntakeDate
	  ,DischargeDate
	  ,CaseProgress
	  ,TCNumber
	  ,MultipleBirth
	  ,cl.LevelName	  
	  ,CONVERT(varchar, cl.StartLevelDate, 101) as  StartLevelDate 
	  ,Intakedd   
	  ,tcid_dd

	  ,case when cpsid.PSIDue is null then '' else cpsid.PSIDue end as PSIDue 
	  ,case when cpsiu.lastpsi is null then '' else cpsiu.lastpsi end as lastpsi 
	  

	  ,case when clfd.FollowUpDue is null then '' else clfd.FollowUpDue end as FollowUpDue
	  ,case when clfu.lastFollowUp is null then '' else clfu.lastFollowUp end as lastFollowUp  
	  
	  
	  ,XDateAge
	  ,ref.HVCasePK
	  
	  ,case when ref_enr is null then '' else ref_enr end as ref_enr 
	  ,case when ref_fup is null then '' else ref_fup end as ref_fup   
	  ,case when ref_last is null then '' else CONVERT(varchar, ref_last, 101) end as ref_last	  
	  
	  ,expectedvisitcount
	  ,actualvisitcount
	  ,attemptedvisitcount
	  ,inhomevisitcount
	  ,CONVERT(VARCHAR, round(COALESCE(cast(actualvisitcount AS FLOAT) * 100/ NULLIF(expectedvisitcount,0), 0), 0))   + '%'   as NYSAchievementMonthlyRate 
	  ,CONVERT(VARCHAR, round(COALESCE(cast(inhomevisitcount AS FLOAT) * 100/ NULLIF(actualvisitcount,0), 0), 0))   + '%'   as InHomeVisitMonthlyRate 

	  ,CAST((VisitLengthInminutesMOnthly / 60) AS VARCHAR(8)) + ':' + 
       RIGHT('0' + CAST((VisitLengthInminutesMOnthly % 60) AS VARCHAR(2)), 2) as VisitLengthInOneMonth
	  
	  ,expected3Monthsvisitcount
	  ,actual3Monthsvisitcount
	  ,attempted3Monthsvisitcount
	  ,inhome3Monthsvisitcount
	  ,CONVERT(VARCHAR, round(COALESCE(cast(actual3Monthsvisitcount AS FLOAT) * 100/ NULLIF(expected3Monthsvisitcount,0), 0), 0))   + '%'   as NYSAchievement3MonthlyRate 
	  ,CONVERT(VARCHAR, round(COALESCE(cast(inhome3Monthsvisitcount AS FLOAT) * 100/ NULLIF(actual3Monthsvisitcount,0), 0), 0))   + '%'   as InHomeVisit3MonthlyRate 
	  
	  ,CAST((VisitLengthInminutes3MOnthly / 60) AS VARCHAR(8)) + ':' + 
       RIGHT('0' + CAST((VisitLengthInminutes3MOnthly % 60) AS VARCHAR(2)), 2) as VisitLengthInThreeMonth
	  
      ,case when ls.Last5Visits is not null then left(ls.Last5Visits,len(ls.Last5Visits)-1) else '' end as Last5Visits
     
	  ,case when lastASQ.TCAge >= casq.Interval then ''
			when asqd.TCReceiving1 = 1 or asqd.TCReceiving2 = 1 or asqd.TCReceiving3 = 1 or asqd.TCReceiving4 = 1 then ' Child receiving EIP '
			when casq.Interval is null then ''
	        when casq.Interval = '00' then ' Due by ' + 
	        
	        case when IntakeDate < dev_bdate then 
					convert(varchar(20), dev_bdate, 101) else convert(varchar(20), IntakeDate, 101) end
					
			when casq.Interval < '24' then cdasq.EventDescription + ' Due between ' + convert(varchar(20), dateadd(dd,cdasq.MinimumDue ,dev_bdate), 101) + ' and ' + convert(varchar(20), dateadd(dd,cdasq.MaximumDue ,dev_bdate), 101)
			else cdasq.EventDescription + ' Due  between ' + convert(varchar(20), dateadd(dd, cdasq.MinimumDue, cc.tcdob), 101) + ' and ' + convert(varchar(20), dateadd(dd, cdasq.MaximumDue, cc.tcdob), 101)
			--else cdasq.EventDescription + ' Due  between ' + convert(varchar(20), dateadd(dd,cdasq.MinimumDue ,tcdob), 101) + ' and ' + convert(varchar(20), dateadd(dd,cdasq.MaximumDue ,tcdob), 101)
			end as ASQDue   
     
		--, hvl.levelname as CurrentLevelName
		--, convert(varchar(12), hvl.levelassigndate , 101) as levelassigndate		
		
		 --cd.ASQInWindow,cd.ASQTCReceiving,cd.TCAge,cd.TCReferred
		
		, case 
			 when ASQTCReceiving = 1 then ' Child receiving EIP ' 
		
			 when lastASQ.ASQInWindow = 0  then lastASQ.EventDescription + ' Out of Window On ' + convert(varchar(12), lastASQ.DateCompleted, 101)
			 when lastASQ.ASQInWindow = 1  then lastASQ.EventDescription + ' In Window On ' + convert(varchar(12), lastASQ.DateCompleted , 101)			 
			 else '' end
			 
			 
			 as formname
			 
		--, case 
		--	 when TCReceiving1 = 1 or TCReceiving2 = 1 or TCReceiving3 = 1 or TCReceiving4 = 1 then ' Child receiving EIP ' 
		
		--	 when lastASQ.FormOutOfWindow = 0 and lastASQ.FormName is not null then lastASQ.FormName + ' In Window On ' + convert(varchar(12), lastASQ.FormDate , 101)
		--	 when lastASQ.FormOutOfWindow = 1 and lastASQ.FormName is not null  then lastASQ.FormName + ' Out of Window On ' + convert(varchar(12), lastASQ.FormDate , 101)
		--	 when lastASQ.FormMissing = 1 and lastASQ.FormName is not null  then lastASQ.FormName + ' Missing ' 
			 
		--	 when lastASQ.FormName is null then '' end
			 
			 
		--	 as formname			 
			 
			 
			, case when cc.TCIDPK is not null then ld.lastdate else '' end as lastdateOnMedicalForm	
		
-- rspFSWEnrolledCaseTickler 1, '07/31/2013'
		,ctePolio.Frequency,polio.ImmunizationCountPolio
		,case 	
					when cc.caseprogress <= 10 then '' -- no child, blank it out
					
					when ctePolio.Frequency is  null and polio.ImmunizationCountPolio is null then
						'' -- figure it out what to do w/ John
					
					when ctePolio.Frequency is  null then								
								cast(isnull(ctePolio.Frequency,0) as varchar(2)) + ' Due: ' +  cast(isnull(polio.ImmunizationCountPolio,0) as varchar(2)) + ' completed'
								
					when polio.ImmunizationCountPolio is null then
					cast(ctePolio.Frequency as varchar(2)) + ' Due by ' + convert(varchar(12), dateadd(dd,ctePolio.MaximumDue, cc.tcdob ), 101) + '; ' +
					' 0 completed' 								
								
																 
					-- after this ctePolio.Frequency is not null (contains a number)
					when polio.ImmunizationCountPolio is not null and  ctePolio.Frequency > polio.ImmunizationCountPolio then 
					cast(ctePolio.Frequency as varchar(2)) + ' Due by ' + convert(varchar(12), dateadd(dd,ctePolio.MaximumDue, cc.tcdob ), 101) + '; ' +
					cast(polio.ImmunizationCountPolio as varchar(2)) + ' completed'
					
					when polio.ImmunizationCountPolio is not null and  ctePolio.Frequency <= polio.ImmunizationCountPolio then 
					cast(ctePolio.Frequency as varchar(2)) + ' Due; '  +
					cast(polio.ImmunizationCountPolio as varchar(2)) + ' completed'	

					 
					else ''
					 
						
		end as PolioCount
		

		,case 	
					when cc.caseprogress <= 10 then '' -- no child, blank it out
					
					
					when cteDTP.Frequency is  null and DTap.ImmunizationCountDTaP is null then
						'' -- figure it out what to do w/ John

					when cteDTP.Frequency is  null then 				
								cast(isnull(cteDTP.Frequency,0) as varchar(2))  + ' Due: ' +  cast(isnull(DTap.ImmunizationCountDTaP,0) as varchar(2)) + ' completed'					
								
					when DTap.ImmunizationCountDTaP is null then
					cast(cteDTP.Frequency as varchar(2)) + ' Due by ' + convert(varchar(12), dateadd(dd,cteDTP.MaximumDue, cc.tcdob ), 101) + '; ' +
					' 0 completed' 	
																 
					-- after this cteDTP.Frequency is not null (contains a number)
					when DTap.ImmunizationCountDTaP is not null and  cteDTP.Frequency > DTap.ImmunizationCountDTaP then 
					cast(cteDTP.Frequency as varchar(2)) + ' Due by ' + convert(varchar(12), dateadd(dd,cteDTP.MaximumDue, cc.tcdob ), 101) + '; ' +
					cast(DTap.ImmunizationCountDTaP as varchar(2)) + ' completed'
					
					when DTap.ImmunizationCountDTaP is not null and  cteDTP.Frequency <= DTap.ImmunizationCountDTaP then 
					cast(cteDTP.Frequency as varchar(2)) + ' Due; '  +
					cast(DTap.ImmunizationCountDTaP as varchar(2)) + ' completed'							
					

					 
					else ''
					 
						
		end as DTaPCount
		
		,case 	
					when cc.caseprogress <= 10 then '' -- no child, blank it out
					
					
					when cteMMR.Frequency is  null and  MMR.ImmunizationCountMMR is null then
						'' -- figure it out what to do w/ John

					when cteMMR.Frequency is  null then 				
								cast(isnull(cteMMR.Frequency,0) as varchar(2))  + ' Due: ' +  cast(isnull(MMR.ImmunizationCountMMR,0) as varchar(2)) + ' completed'					
								
					when MMR.ImmunizationCountMMR is null then
					cast(cteMMR.Frequency as varchar(2)) + ' Due by ' + convert(varchar(12), dateadd(dd,cteMMR.MaximumDue, cc.tcdob ), 101) + '; ' +
					' 0 completed' 				
										
																 
					-- after this cteMMR.Frequency is not null (contains a number)
					when MMR.ImmunizationCountMMR is not null and  cteMMR.Frequency > MMR.ImmunizationCountMMR then 
					cast(cteMMR.Frequency as varchar(2)) + ' Due by ' + convert(varchar(12), dateadd(dd,cteMMR.MaximumDue, cc.tcdob ), 101) + '; ' +
					cast(MMR.ImmunizationCountMMR as varchar(2)) + ' completed'
					
					when MMR.ImmunizationCountMMR is not null and  cteMMR.Frequency <= MMR.ImmunizationCountMMR then 
					cast(cteMMR.Frequency as varchar(2)) + ' Due; '  +
					cast(MMR.ImmunizationCountMMR as varchar(2)) + ' completed'							
					

					 
					else ''
					 
						
		end as MMRCount
		
		,case 	
					when cc.caseprogress <= 10 then '' -- no child, blank it out
					
					when cteHIB.Frequency is  null and  HIB.ImmunizationCountHIB is null then
						'' -- figure it out what to do w/ John

					when cteHIB.Frequency is  null then 				
								cast(isnull(cteHIB.Frequency,0) as varchar(2))  + ' Due: ' +  cast(isnull(HIB.ImmunizationCountHIB,0) as varchar(2)) + ' completed'					
								
					when HIB.ImmunizationCountHIB is null then
					cast(cteHIB.Frequency as varchar(2)) + ' Due by ' + convert(varchar(12), dateadd(dd,cteHIB.MaximumDue, cc.tcdob ), 101) + '; ' +
					' 0 completed' 					

																 
					-- after this cteHIB.Frequency is not null (contains a number)
					when HIB.ImmunizationCountHIB is not null and  cteHIB.Frequency > HIB.ImmunizationCountHIB then 
					cast(cteHIB.Frequency as varchar(2)) + ' Due by ' + convert(varchar(12), dateadd(dd,cteHIB.MaximumDue, cc.tcdob ), 101) + '; ' +
					cast(HIB.ImmunizationCountHIB as varchar(2)) + ' completed'
					
					when HIB.ImmunizationCountHIB is not null and  cteHIB.Frequency <= HIB.ImmunizationCountHIB then 
					cast(cteHIB.Frequency as varchar(2)) + ' Due; '  +
					cast(HIB.ImmunizationCountHIB as varchar(2)) + ' completed'							
					

					 
					else ''
					 
						
		end as HIBCount

		-- HEP-B
		,case 	
					when cc.caseprogress <= 10 then '' -- no child, blank it out
					
					
					when cteHEPB.Frequency is  null and  HEPB.ImmunizationCountHEP is null then
						'' -- figure it out what to do w/ John

					when cteHEPB.Frequency is  null then 				
								cast(isnull(cteHEPB.Frequency,0) as varchar(2))  + ' Due: ' +  cast(isnull(HEPB.ImmunizationCountHEP,0) as varchar(2)) + ' completed'					
								
					when HEPB.ImmunizationCountHEP is null then
					cast(cteHEPB.Frequency as varchar(2)) + ' Due by ' + convert(varchar(12), dateadd(dd,cteHEPB.MaximumDue, cc.tcdob ), 101) + '; ' +
					' 0 completed' 
					 			
															 
					-- after this cteHEPB.Frequency is not null (contains a number)
					when HEPB.ImmunizationCountHEP is not null and  cteHEPB.Frequency > HEPB.ImmunizationCountHEP then 
					cast(cteHEPB.Frequency as varchar(2)) + ' Due by ' + convert(varchar(12), dateadd(dd,cteHEPB.MaximumDue, cc.tcdob ), 101) + '; ' +
					cast(HEPB.ImmunizationCountHEP as varchar(2)) + ' completed'
					
					when HEPB.ImmunizationCountHEP is not null and  cteHEPB.Frequency <= HEPB.ImmunizationCountHEP then 
					cast(cteHEPB.Frequency as varchar(2)) + ' Due; '  +
					cast(HEPB.ImmunizationCountHEP as varchar(2)) + ' completed'							
					

					else ''
					 
						
		end as HEPBCount	

	
		-- HEP-A
		,case 	
					when cc.caseprogress <= 10 then '' -- no child, blank it out
					
					when cteHEPA.Frequency is  null and  HEPA.ImmunizationCountHEPA is null then
						'' -- figure it out what to do w/ John

					when cteHEPA.Frequency is  null then 				
								cast(isnull(cteHEPA.Frequency,0) as varchar(2))  + ' Due: ' +  cast(isnull(HEPA.ImmunizationCountHEPA,0) as varchar(2)) + ' completed'					
								
					when HEPA.ImmunizationCountHEPA is null then
					cast(cteHEPA.Frequency as varchar(2)) + ' Due by ' + convert(varchar(12), dateadd(dd,cteHEPA.MaximumDue, cc.tcdob ), 101) + '; ' +
					' 0 completed' 				
																 
					-- after this cteHEPA.Frequency is not null (contains a number)
					when HEPA.ImmunizationCountHEPA is not null and  cteHEPA.Frequency > HEPA.ImmunizationCountHEPA then 
					cast(cteHEPA.Frequency as varchar(2)) + ' Due by ' + convert(varchar(12), dateadd(dd,cteHEPA.MaximumDue, cc.tcdob ), 101) + '; ' +
					cast(HEPA.ImmunizationCountHEPA as varchar(2)) + ' completed'
					
					when HEPA.ImmunizationCountHEPA is not null and  cteHEPA.Frequency <= HEPA.ImmunizationCountHEPA then 
					cast(cteHEPA.Frequency as varchar(2)) + ' Due; '  +
					cast(HEPA.ImmunizationCountHEPA as varchar(2)) + ' completed'							
					

					 
					else ''
					 
						
		end as HEPACount			
		

		-- FLU
		,case 	
					when cc.caseprogress <= 10 then '' -- no child, blank it out
					
					when cteFLU.Frequency is  null and  FLU.ImmunizationCountFLU is null then
						'' -- figure it out what to do w/ John

					when cteFLU.Frequency is  null then 				
								cast(isnull(cteFLU.Frequency,0) as varchar(2))  + ' Due: ' +  cast(isnull(FLU.ImmunizationCountFLU,0) as varchar(2)) + ' completed'					
								
					when FLU.ImmunizationCountFLU is null then
					cast(cteFLU.Frequency as varchar(2)) + ' Due by ' + convert(varchar(12), dateadd(dd,cteFLU.MaximumDue, cc.tcdob ), 101) + '; ' +
					' 0 completed' 								
					
																 
					-- after this cteFLU.Frequency is not null (contains a number)
					when FLU.ImmunizationCountFLU is not null and  cteFLU.Frequency > FLU.ImmunizationCountFLU then 
					cast(cteFLU.Frequency as varchar(2)) + ' Due by ' + convert(varchar(12), dateadd(dd,cteFLU.MaximumDue, cc.tcdob ), 101) + '; ' +
					cast(FLU.ImmunizationCountFLU as varchar(2)) + ' completed'
					
					when FLU.ImmunizationCountFLU is not null and  cteFLU.Frequency <= FLU.ImmunizationCountFLU then 
					cast(cteFLU.Frequency as varchar(2)) + ' Due; '  +
					cast(FLU.ImmunizationCountFLU as varchar(2)) + ' completed'							
					

					 
					else ''
					 
						
		end as FLUCount	
		
		
		-- ROTO
		,case 	
					when cc.caseprogress <= 10 then '' -- no child, blank it out
					
					when cteROTO.Frequency is  null and  ROTO.ImmunizationCountROTO is null then
						'' -- figure it out what to do w/ John

					when cteROTO.Frequency is  null then 				
								cast(isnull(cteROTO.Frequency,0) as varchar(2))  + ' Due: ' +  cast(isnull(ROTO.ImmunizationCountROTO,0) as varchar(2)) + ' completed'					
								
					when ROTO.ImmunizationCountROTO is null then
					cast(cteROTO.Frequency as varchar(2)) + ' Due by ' + convert(varchar(12), dateadd(dd,cteROTO.MaximumDue, cc.tcdob ), 101) + '; ' +
					' 0 completed' 							

																 
					-- after this cteROTO.Frequency is not null (contains a number)
					when ROTO.ImmunizationCountROTO is not null and  cteROTO.Frequency > ROTO.ImmunizationCountROTO then 
					cast(cteROTO.Frequency as varchar(2)) + ' Due by ' + convert(varchar(12), dateadd(dd,cteROTO.MaximumDue, cc.tcdob ), 101) + '; ' +
					cast(ROTO.ImmunizationCountROTO as varchar(2)) + ' completed'
					
					when ROTO.ImmunizationCountROTO is not null and  cteROTO.Frequency <= ROTO.ImmunizationCountROTO then 
					cast(cteROTO.Frequency as varchar(2)) + ' Due; '  +
					cast(ROTO.ImmunizationCountROTO as varchar(2)) + ' completed'							
					

					 
					else ''
					 
						
		end as ROTOCount				
		

		-- PCV
		
		,case 	
					when cc.caseprogress <= 10 then '' -- no child, blank it out
					
					when ctePCV.Frequency is  null and  PCV.ImmunizationCountPCV is null then
						'' -- figure it out what to do w/ John

					when ctePCV.Frequency is  null then 				
								cast(isnull(ctePCV.Frequency,0) as varchar(2))  + ' Due: ' +  cast(isnull(PCV.ImmunizationCountPCV,0) as varchar(2)) + ' completed'					
								
					when PCV.ImmunizationCountPCV is null then
					cast(ctePCV.Frequency as varchar(2)) + ' Due by ' + convert(varchar(12), dateadd(dd,ctePCV.MaximumDue, cc.tcdob ), 101) + '; ' +
					' 0 completed' 						
					
																 
					-- after this ctePCV.Frequency is not null (contains a number)
					when PCV.ImmunizationCountPCV is not null and  ctePCV.Frequency > PCV.ImmunizationCountPCV then 
					cast(ctePCV.Frequency as varchar(2)) + ' Due by ' + convert(varchar(12), dateadd(dd,ctePCV.MaximumDue, cc.tcdob ), 101) + '; ' +
					cast(PCV.ImmunizationCountPCV as varchar(2)) + ' completed'
					
					when PCV.ImmunizationCountPCV is not null and  ctePCV.Frequency <= PCV.ImmunizationCountPCV then 
					cast(ctePCV.Frequency as varchar(2)) + ' Due; '  +
					cast(PCV.ImmunizationCountPCV as varchar(2)) + ' completed'							
					

					 
					else ''
					 
						
		end as PCVCount				
		
		
		-- ChickenPoxCount
		
		,case 	
					when cc.caseprogress <= 10 then '' -- no child, blank it out
					
					
					when cteChickenPox.Frequency is  null and  ChickenPox.ImmunizationCountVZ is null then
						'' -- figure it out what to do w/ John

					when cteChickenPox.Frequency is  null then 				
								cast(isnull(cteChickenPox.Frequency,0) as varchar(2))  + ' Due: ' +  cast(isnull(ChickenPox.ImmunizationCountVZ,0) as varchar(2)) + ' completed'					
								
					when ChickenPox.ImmunizationCountVZ is null then
					cast(cteChickenPox.Frequency as varchar(2)) + ' Due by ' + convert(varchar(12), dateadd(dd,cteChickenPox.MaximumDue, cc.tcdob ), 101) + '; ' +
					' 0 completed' 						
					
																 
					-- after this cteChickenPox.Frequency is not null (contains a number)
					when ChickenPox.ImmunizationCountVZ is not null and  cteChickenPox.Frequency > ChickenPox.ImmunizationCountVZ then 
					cast(cteChickenPox.Frequency as varchar(2)) + ' Due by ' + convert(varchar(12), dateadd(dd,cteChickenPox.MaximumDue, cc.tcdob ), 101) + '; ' +
					cast(ChickenPox.ImmunizationCountVZ as varchar(2)) + ' completed'
					
					when ChickenPox.ImmunizationCountVZ is not null and  cteChickenPox.Frequency <= ChickenPox.ImmunizationCountVZ then 
					cast(cteChickenPox.Frequency as varchar(2)) + ' Due; '  +
					cast(ChickenPox.ImmunizationCountVZ as varchar(2)) + ' completed'							
					

					 
					else ''
					 
						
		end as ChickenPoxCount						
		
		
		-- WBV
		,case 	
					when cc.caseprogress <= 10 then '' -- no child, blank it out
					
					when cteWBV.Frequency is  null and  WBV.ImmunizationCountWBV is null then
						'' -- figure it out what to do w/ John

					when cteWBV.Frequency is  null then 				
								cast(isnull(cteWBV.Frequency,0) as varchar(2))  + ' Due: ' +  cast(isnull(WBV.ImmunizationCountWBV,0) as varchar(2)) + ' completed'					
								
					when WBV.ImmunizationCountWBV is null then
					cast(cteWBV.Frequency as varchar(2)) + ' Due by ' + convert(varchar(12), dateadd(dd,cteWBV.MaximumDue, cc.tcdob ), 101) + '; ' +
					' 0 completed' 							
					
																 
					-- after this cteWBV.Frequency is not null (contains a number)
					when WBV.ImmunizationCountWBV is not null and  cteWBV.Frequency > WBV.ImmunizationCountWBV then 
					cast(cteWBV.Frequency as varchar(2)) + ' Due by ' + convert(varchar(12), dateadd(dd,cteWBV.MaximumDue, cc.tcdob ), 101) + '; ' +
					cast(WBV.ImmunizationCountWBV as varchar(2)) + ' completed'
					
					when WBV.ImmunizationCountWBV is not null and  cteWBV.Frequency <= WBV.ImmunizationCountWBV then 
					cast(cteWBV.Frequency as varchar(2)) + ' Due; '  +
					cast(WBV.ImmunizationCountWBV as varchar(2)) + ' completed'							
					

					 
					else ''
					 
						
		end as WBVCount				
				
	
		, '' as WBVCount1
		

		-- Lead
		,case 	
					when cc.caseprogress <= 10 then '' -- no child, blank it out
					
					when cteLead.Frequency is  null and  LeadScreen.ImmunizationCountLeadScreening is null then
						'' -- figure it out what to do w/ John

					when cteLead.Frequency is  null then 				
								cast(isnull(cteLead.Frequency,0) as varchar(2))  + ' Due: ' +  cast(isnull(LeadScreen.ImmunizationCountLeadScreening,0) as varchar(2)) + ' completed'					
								
					when LeadScreen.ImmunizationCountLeadScreening is null then
					cast(cteLead.Frequency as varchar(2)) + ' Due by ' + convert(varchar(12), dateadd(dd,cteLead.MaximumDue, cc.tcdob ), 101) + '; ' +
					' 0 completed' 						
					
																 
					-- after this cteLead.Frequency is not null (contains a number)
					when LeadScreen.ImmunizationCountLeadScreening is not null and  cteLead.Frequency > LeadScreen.ImmunizationCountLeadScreening then 
					cast(cteLead.Frequency as varchar(2)) + ' Due by ' + convert(varchar(12), dateadd(dd,cteLead.MaximumDue, cc.tcdob ), 101) + '; ' +
					cast(LeadScreen.ImmunizationCountLeadScreening as varchar(2)) + ' completed'
					
					when LeadScreen.ImmunizationCountLeadScreening is not null and  cteLead.Frequency <= LeadScreen.ImmunizationCountLeadScreening then 
					cast(cteLead.Frequency as varchar(2)) + ' Due; '  +
					cast(LeadScreen.ImmunizationCountLeadScreening as varchar(2)) + ' completed'							
					

					 
					else ''
					 
						
		end as LeadScreen		

		
	  
	     ,'Evaluation Form Due Dates' as Header1
	     ,'Evaluation Form History' as Header2
	     ,'Referrals' as Header3
	     , @NameOfPreviousMonth + ' Home Visits' as Header4
	     , @LastThreeMonthsNames + ' Home Visits' as Header5
	     ,'Target Child Due Dates' as Header6

		 ,@NameOfPreviousMonth as LastMonthsName
		 --,Childdob
		 -- cc.HVCasePK,cc.TCIDPK,A.ASQSEInWindow,A.ASQSEReceiving,A.ASQSETCAge,A.ASQSEReferred,A.ASQSEDateCompleted,cd.EventDescription
		 
		  ,case when  lasqse.ASQSETCAge >= casqse.Interval then ''
				when casqse.ASQSEReceiving = 1 then ' Child receiving EIP '
				when casqse.Interval is null then ''
				-- as per JH, dont use dev_date. Use tcdob .... khalsa 06/05/2014				
				--else  cdasqse.EventDescription + ' Due  between ' + convert(varchar(20), dateadd(dd,cdasqse.MinimumDue ,dev_bdate), 101) + ' and ' + convert(varchar(20), dateadd(dd,cdasqse.MaximumDue ,dev_bdate), 101)
				else cdasqse.EventDescription + ' Due  between ' + convert(varchar(20), dateadd(dd,cdasqse.MinimumDue ,cc.tcdob), 101) + ' and ' + convert(varchar(20), dateadd(dd,cdasqse.MaximumDue ,cc.tcdob), 101)
				end as ASQSEDue  		 
		 
		 
		 , case 
			 when lasqse.ASQSEReceiving = 1 then ' Child receiving EIP ' 
		
			 when lasqse.ASQSEInWindow = 0  then lasqse.EventDescription + ' Out of Window On ' + convert(varchar(12), lasqse.ASQSEDateCompleted, 101)
			 when lasqse.ASQSEInWindow = 1  then lasqse.EventDescription + ' In Window On ' + convert(varchar(12), lasqse.ASQSEDateCompleted , 101)			 
			 else '' end
			 
			 
			 as lastASQSEFormCompleted
		 
		 
		 
	  
	   FROM #tblCommonCohort cc
	   
		left join ctePSIFormDueDates psiIntervalDue on psiIntervalDue.hvcasepk = cc.HVCasePK  and cc.TCIDPK = psiIntervalDue.TCIDPK 

	   
	  --inner join cteTCIDFormDone tcidform on tcidform.HVCasePK = cc.HVCasePK
	  left join cteReferrals ref on ref.HVCasePK = cc.HVCasePK
	  left join cteExpectedMonthlyHomeVisits expvisits on expvisits.HVCasePK = cc.HVCasePK 
	  left join cteAttemptedAndActualMonthlyHomeVisits othervisits on othervisits.HVCasePK = cc.HVCasePK

	  left join cteExpected3MonthsHomeVisits exp3Monthsvisits on exp3Monthsvisits.HVCasePK = cc.HVCasePK 
	  left join cteAttemptedAndActual3MonthsHomeVisits other3Monthsvisits on other3Monthsvisits.HVCasePK = cc.HVCasePK
	  
	  inner join cteLast5VisitsConcatenated ls on ls.HVCasePK = cc.HVCasePK 
	  inner join cteCurrentLevel cl on cl.HVCasePK = cc.HVCasePK 
	  
	  left join cteTCID tc on tc.HVCasePK = cc.HVCasePK and tc.TCIDPK = cc.TCIDPK 
	  left join cteASQDueInterval casq on casq.HVCasePK = cc.HVCasePK and casq.TCIDPK = cc.TCIDPK 
	  left join codeDueByDates cdasq on scheduledevent = 'ASQ' and cdasq.Interval = casq.Interval  
	  
	  left join cteASQSEThatIsDueNowWithEIPStatus casqse on casqse.HVCasePK = cc.HVCasePK and casqse.TCIDPK = cc.TCIDPK 
	  left join codeDueByDates cdasqse on cdasqse.scheduledevent = 'ASQSE-1' and cdasqse.Interval = casqse.Interval  
	  
	  
	  
	  
	  
	  left join #tblPTDetails asqd on asqd.HVCaseFK = cc.HVCasePK and asqd.TCIDPK = cc.TCIDPK 
	  
	  left join cteLastASQCompleted lastASQ on lastASQ.HVCasePK = cc.HVCasePK and lastASQ.TCIDPK = cc.TCIDPK   -- for lastasq
	  left join cteLastDateOnMedicalForm ld on ld.HVCasePK = cc.HVCasePK and ld.TCIDPK = cc.TCIDPK
	  left join cteLastASQSECompleted lasqse on lasqse.HVCasePK = cc.HVCasePK and lasqse.TCIDPK = cc.TCIDPK
	  
	  
	  left join dbo.udfHVLevel(@programfk, @edate) hvl on hvl.hvcasefk = cc.HVCasePK  -- to get CurrentLevelName, CurrentLevelDate

	  -- shots count
	  left join cteImmunizationsPolio polio on polio.HVCasePK = cc.HVCasePK and polio.TCIDPK = cc.TCIDPK
	  left join cteImmunizationsDTaP DTap on DTap.HVCasePK = cc.HVCasePK and DTap.TCIDPK = cc.TCIDPK
	  left join cteImmunizationsMMR MMR on MMR.HVCasePK = cc.HVCasePK and MMR.TCIDPK = cc.TCIDPK	  
	  left join cteImmunizationsHIB HIB on HIB.HVCasePK = cc.HVCasePK and HIB.TCIDPK = cc.TCIDPK
	  
	  left join cteImmunizationsHEPB HEPB on HEPB.HVCasePK = cc.HVCasePK and HEPB.TCIDPK = cc.TCIDPK

	  -- Added later on
	  left join cteImmunizationsHEPA HEPA on HEPA.HVCasePK = cc.HVCasePK and HEPA.TCIDPK = cc.TCIDPK
	  left join cteImmunizationsFLU FLU on FLU.HVCasePK = cc.HVCasePK and FLU.TCIDPK = cc.TCIDPK
	  left join cteImmunizationsROTO ROTO on ROTO.HVCasePK = cc.HVCasePK and ROTO.TCIDPK = cc.TCIDPK
	  left join cteImmunizationsPCV PCV on PCV.HVCasePK = cc.HVCasePK and PCV.TCIDPK = cc.TCIDPK  
	  ----
	  
	  left join cteImmunizationsVZ ChickenPox on ChickenPox.HVCasePK = cc.HVCasePK and ChickenPox.TCIDPK = cc.TCIDPK
	  left join cteImmunizationsWBV WBV on WBV.HVCasePK = cc.HVCasePK and WBV.TCIDPK = cc.TCIDPK
	  left join cteImmunizationsLeadScreening LeadScreen on LeadScreen.HVCasePK = cc.HVCasePK and LeadScreen.TCIDPK = cc.TCIDPK
	  
	  
		left join cteDTPInterval cteDTP on cteDTP.HVCasePK = cc.HVCasePK and cteDTP.TCIDPK = cc.TCIDPK
		left join cteHEPBInterval cteHEPB on cteHEPB.HVCasePK = cc.HVCasePK and cteHEPB.TCIDPK = cc.TCIDPK
		
		-- Added later on
		left join cteHEPAInterval cteHEPA on cteHEPA.HVCasePK = cc.HVCasePK and cteHEPA.TCIDPK = cc.TCIDPK	
		left join cteFLUInterval cteFLU on cteFLU.HVCasePK = cc.HVCasePK and cteFLU.TCIDPK = cc.TCIDPK	
		left join cteROTOInterval cteROTO on cteROTO.HVCasePK = cc.HVCasePK and cteROTO.TCIDPK = cc.TCIDPK	
		left join ctePCVInterval ctePCV on ctePCV.HVCasePK = cc.HVCasePK and ctePCV.TCIDPK = cc.TCIDPK			
		---
			
		left join cteHIBInterval cteHIB on cteHIB.HVCasePK = cc.HVCasePK and cteHIB.TCIDPK = cc.TCIDPK
		left join cteLeadInterval cteLead on cteLead.HVCasePK = cc.HVCasePK and cteLead.TCIDPK = cc.TCIDPK
		left join cteMMRInterval cteMMR on cteMMR.HVCasePK = cc.HVCasePK and cteMMR.TCIDPK = cc.TCIDPK
		left join ctePolioInterval ctePolio on ctePolio.HVCasePK = cc.HVCasePK and ctePolio.TCIDPK = cc.TCIDPK
		left join cteVZInterval cteChickenPox on cteChickenPox.HVCasePK = cc.HVCasePK and cteChickenPox.TCIDPK = cc.TCIDPK
		left join cteWBVInterval cteWBV on cteWBV.HVCasePK = cc.HVCasePK and cteWBV.TCIDPK = cc.TCIDPK	  
	  
	  
	  
	  
	  left join ctePSIFormDueDates cpsid on cpsid.HVCasePK = cc.HVCasePK and cpsid.TCIDPK = cc.TCIDPK
	  left join cteLastPSIForm cpsiu on cpsiu.HVCasePK = cc.HVCasePK and cpsiu.TCIDPK = cc.TCIDPK
	  
	  
	  
	  left join cteFollowUpFormDueDates clfd on clfd.HVCasePK = cc.HVCasePK and clfd.TCIDPK = cc.TCIDPK
	  left join cteLastFollowUpForm clfu on clfu.HVCasePK = cc.HVCasePK and clfu.TCIDPK = cc.TCIDPK
	  

order by FSWNAME,PC1ID   
----order by OldID
--order by pc1id
 --order by tcdob
  --order by cc.HVCasePK

drop table #tblCommonCohort
drop table #CodeDueByMaxFrequencies
drop table #tblPTDetails
 -- rspFSWEnrolledCaseTickler 4, '09/30/2013'
GO
