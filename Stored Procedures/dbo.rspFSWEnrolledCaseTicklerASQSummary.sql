SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <Febu. 28, 2013>
-- Description:	<gets you data for Performance Target report - HD7. Age Appropriate Developmental level >
-- rspPerformanceTargetReportSummary 5 ,'10/01/2012' ,'12/31/2012'
-- exec rspFSWEnrolledCaseTicklerLastASQ 5 ,'01/01/2012' ,'03/31/2012'
-- Edited by Benjamin Simmons
-- Edit Date: 08/17/17
-- Edit Reason: Optimized the stored procedure by converting cohort CTE into a temp table
-- =============================================
CREATE procedure [dbo].[rspFSWEnrolledCaseTicklerASQSummary]
(
    @StartDate  datetime,
    @EndDate    datetime,
    @tblPTCases PTCases readonly
)

as
begin

	if object_id('tempdb..#cteCohort') is not null drop table #cteCohort

	create table #cteCohort(
		HVCaseFK int
		, PC1ID varchar(13)
		, OldID varchar(23)
		, PC1FullName varchar(max)
		, CurrentWorkerFK int
		, CurrentWorkerFullName varchar(max)
		, CurrentLevelName varchar(50)
		, ProgramFK int
		, TCIDPK int
		, TCDOB datetime
		, DischargeDate datetime
		, tcAgeDays int
		, tcASQAgeDays int
		, lastdate datetime
		, GestationalAge int
	)

	;
	with cteTotalCases
	as
	(
		select
			  ptc.HVCaseFK
			 ,ptc.PC1ID
			 ,ptc.OldID
			 ,ptc.PC1FullName
			 ,ptc.CurrentWorkerFK
			 ,ptc.CurrentWorkerFullName
			 ,ptc.CurrentLevelName
			 ,ptc.ProgramFK
			 ,ptc.TCIDPK
			 ,ptc.TCDOB
			 ,cp.DischargeDate
			 ,case
				  when DischargeDate is not null and DischargeDate <> '' and DischargeDate <= @EndDate then
					  datediff(day,ptc.tcdob,DischargeDate)
				  else
					  datediff(day,ptc.tcdob,@EndDate)
			  end as tcAgeDays
			 ,case
				  when DischargeDate is not null and DischargeDate <> '' and DischargeDate <= @EndDate then
					  DischargeDate
				  else
					  @EndDate
			  end as lastdate
			 ,h.IntakeDate
			from @tblPTCases ptc
				inner join HVCase h on ptc.hvcaseFK = h.HVCasePK
				inner join CaseProgram cp on cp.CaseProgramPK = ptc.CaseProgramPK
				-- h.hvcasePK = cp.HVCaseFK and cp.ProgramFK = ptc.ProgramFK -- AND cp.DischargeDate IS NULL
	)
	insert into #cteCohort
		select ctc.HVCaseFK
			  , PC1ID
			  , OldID
			  , PC1FullName
			  , CurrentWorkerFK
			  , CurrentWorkerFullName
			  , CurrentLevelName
			  , ctc.ProgramFK
			  , ctc.TCIDPK
			  , ctc.TCDOB
			  , DischargeDate
			  , tcAgeDays
			  , case when datediff(month,ctc.TCDOB,lastdate) >= 24 or GestationalAge = 40
						then tcAgeDays
					when datediff(month,ctc.TCDOB,lastdate) < 24 and GestationalAge < 40
						then tcAgeDays - ((40-GestationalAge) * 7)
				end as tcASQAgeDays
			  , lastdate
			  , GestationalAge			  
			from cteTotalCases ctc
				inner join TCID T on T.HVCaseFK = ctc.HVCaseFK and T.TCIDPK = ctc.TCIDPK 
					-- looking at each child individualy i.e. gestationalage
			where
				 case
					 when T.GestationalAge is null then
						 dateadd(dd,.33*365.25,(((40-0)*7)+ctc.TCDOB))
					 else
						 dateadd(dd,.33*365.25,(((40-gestationalage)*7)+ctc.TCDOB))
				 end <= lastdate -- 4 months 
	-- SELECT * FROM cteCohort
	;
	with cteASQDueInterval -- age appropriate ASQ Intervals that are expected to be there
	as
	(
		select
			  c.HVCaseFK
			 ,c.TCIDPK
			 ,max(cd.Interval) as Interval -- given child age, this is the interval that one expect to find ASQ record in the DB

			from #cteCohort c
				inner join codeDueByDates cd on scheduledevent = 'ASQ' and tcASQAgeDays >= DueBy
			group by HVCaseFK
					,c.TCIDPK 
						-- Must 'group by HVCasePK, TCIDPK' to bring in twins etc (twins have same hvcasepks) (not just 'group by HVCasePK')
	)
	--select a.*,PC1ID, oldid from cteASQDueInterval a
	--inner join CaseProgram cp on cp.HVCaseFK = a.hvcasefk
	,
	cteASQDueIntervalOneBefore -- age appropriate ASQ Intervals that are expected to be there
	as
	(
		select
			  c.HVCaseFK
			 ,c.TCIDPK
			 ,max(cd.Interval) as Interval -- given child age, this is the interval that one expect to find ASQ record in the DB

			from #cteCohort c
				inner join cteASQDueInterval i on i.HVCaseFK = c.HVCaseFK and i.TCIDPK = c.TCIDPK
				inner join codeDueByDates cd on scheduledevent = 'ASQ' and tcASQAgeDays >= DueBy
			where cd.Interval < i.Interval
			group by c.HVCaseFK
					,c.TCIDPK 
						-- Must 'group by HVCasePK, TCIDPK' to bring in twins etc (twins have same hvcasepks) (not just 'group by HVCasePK')
	)
	,
	cteASQDueIntervalTwoBefore -- age appropriate ASQ Intervals that are expected to be there
	as
	(
		select
			  c.HVCaseFK
			 ,c.TCIDPK
			 ,max(cd.Interval) as Interval -- given child age, this is the interval that one expect to find ASQ record in the DB

			from #cteCohort c
				inner join cteASQDueIntervalOneBefore i on i.HVCaseFK = c.HVCaseFK and i.TCIDPK = c.TCIDPK
				inner join codeDueByDates cd on scheduledevent = 'ASQ' and tcASQAgeDays >= DueBy
			where cd.Interval < i.Interval
			group by c.HVCaseFK
					,c.TCIDPK 
						-- Must 'group by HVCasePK, TCIDPK' to bring in twins etc (twins have same hvcasepks) (not just 'group by HVCasePK')
	)
    
	-- Last ASQ Done prior to expected for each tcid
    ,
    cteLastASQDone 
    as 
    (
      select 
          c.HVCaseFK
          , c.TCIDPK   
          , max(A.TCAge) as Interval -- given child age, this is the interval that one expect to find ASQ record in the DB
       
       from #cteCohort c
       inner join codeDueByDates cd on scheduledevent = 'ASQ' and tcASQAgeDays >= DueBy 
       inner join ASQ A on c.HVCaseFK = A.HVCaseFK and A.TCIDFK = c.TCIDPK  
       group by c.HVCaseFK,c.TCIDPK 
    )
    
    -- Determine expected form and form characteristics
	,
	cteExpectedForm
	as
	(
		select 'HD7' as PTCode
			  , c.HVCaseFK
			  , PC1ID
			  , OldID
			  , TCDOB
			  , c.TCIDPK
			  , PC1FullName
			  , CurrentWorkerFullName
			  , CurrentLevelName
			  , case when a1.ASQPK is not null and dbo.IsFormReviewed(a1.DateCompleted,'AQ',a1.ASQPK) = 1 then 1
		  			 when a1.ASQPK is null and charindex('(optional)',capp1.AppCodeText) > 0 and 
		  			 		a2.ASQPK is not null and dbo.IsFormReviewed(a2.DateCompleted,'AQ',a2.ASQPK) = 1 then 1
		  			 when a1.ASQPK is null and charindex('(optional)',capp1.AppCodeText) > 0 and 
		  					a2.ASQPK is null and charindex('(optional)',capp2.AppCodeText) > 0 and 
		  					a3.ASQPK is not null and dbo.IsFormReviewed(a3.DateCompleted,'AQ',a3.ASQPK) = 1 then 1
		  			 when a1.ASQPK is null and charindex('(optional)',capp1.AppCodeText) = 0 and
		  					a4.ASQPK is not null and a4.ASQTCReceiving = '1' and 
		  					dbo.IsFormReviewed(a4.DateCompleted,'AQ',a4.ASQPK) = 1 then 1
		  			 when a1.ASQPK is null and a2.ASQPK is null and a3.ASQPK is null and 
		  					a4.ASQPK is not null and a4.ASQTCReceiving = '1' and 
		  					dbo.IsFormReviewed(a4.DateCompleted,'AQ',a4.ASQPK) = 1 
		  					then 1
		  		else 0
		  		end
		  		as FormReviewed
			  , case when a1.ASQPK is null and charindex('(optional)',capp1.AppCodeText) = 0 then 0
					 when a1.ASQPK is not null and a1.ASQInWindow = 1 then 0
		  			 when a1.ASQPK is null and charindex('(optional)',capp1.AppCodeText) > 0 and 
		  			 		a2.ASQPK is not null and a2.ASQInWindow = 1 then 0
		  			 when a1.ASQPK is null and charindex('(optional)',capp1.AppCodeText) > 0 and 
		  					a2.ASQPK is null and charindex('(optional)',capp2.AppCodeText) = 0 then 0
		  			 when a1.ASQPK is null and charindex('(optional)',capp1.AppCodeText) > 0 and 
		  					a2.ASQPK is null and charindex('(optional)',capp2.AppCodeText) > 0 and 
		  					a3.ASQPK is not null and a3.ASQInWindow = 1 then 0
		  			 when a1.ASQPK is null and charindex('(optional)',capp1.AppCodeText) > 0 and 
		  					a2.ASQPK is null and charindex('(optional)',capp2.AppCodeText) > 0 and
		  					a3.ASQPK is null then 0
		  			 when a1.ASQPK is null and a2.ASQPK is null and a3.ASQPK is null and 
		  					a4.ASQPK is not null and a4.ASQInWindow = 1 
		  					then 0
		  		else 1
		  		end
		  		as FormOutOfWindow
			  , case when a1.ASQPK is not null then 0
					 when a1.ASQPK is null and charindex('(optional)',capp1.AppCodeText) = 0 
							and (a4.ASQPK is not null and (a4.ASQTCReceiving <> '1' or a4.ASQTCReceiving is null)) then 1
		  			 when a1.ASQPK is null and charindex('(optional)',capp1.AppCodeText) > 0 and 
		  			 		a2.ASQPK is not null then 0
		  			 when a1.ASQPK is null and charindex('(optional)',capp1.AppCodeText) > 0 and 
							a2.ASQPK is null and charindex('(optional)',capp2.AppCodeText) = 0 
							and (a4.ASQPK is not null and (a4.ASQTCReceiving <> '1' or a4.ASQTCReceiving is null)) then 1
		  			 when a1.ASQPK is null and charindex('(optional)',capp1.AppCodeText) > 0 and 
		  					a2.ASQPK is null and charindex('(optional)',capp2.AppCodeText) > 0 and 
		  					a3.ASQPK is not null then 0
		  			 when a1.ASQPK is null and a2.ASQPK is null and a3.ASQPK is null and 
		  					(a4.ASQPK is not null and a4.ASQTCReceiving = '1') then 0
		  			 when a1.ASQPK is null and a2.ASQPK is null and a3.ASQPK is null and 
		  					(a4.ASQPK is null or (a4.ASQPK is not null and 
		  						(a4.ASQTCReceiving <> '1' or a4.ASQTCReceiving is null))) then 1
		  		else 0
		  		end
		  		as FormMissing
		  	  , tcAgeDays
		  	  , tcAgeDays / 30.44 as TCAgeMonths
		  	  , tcASQAgeDays
		  	   ,	a1.ASQPK  as asqpk1
		  	   , casi.Interval as interval1
		  	   , a1.ASQInWindow as inwindow1
		  	   , capp1.AppCodeText as FormText1
		  	   , a2.ASQPK as asqpk2
		  	   , casi2.Interval as interval2
		  	   , a2.ASQInWindow as inwindow2
		  	   , capp2.AppCodeText as FormText2
		  	   , a3.ASQPK  as asqpk3
		  	   , casi3.Interval as interval3
		  	   , a3.ASQInWindow as inwindow3
		  	   , capp3.AppCodeText as FormText3
		  	   , a4.ASQPK  as asqpk4
		  	   , lasq.Interval as interval4
		  	   , a4.ASQInWindow as inwindow4
		  	   , capp4.AppCodeText as FormText4
		  	   , a4.ASQTCReceiving as a4TCReceiving
		  	   , a4.DateCompleted as a4DateCompleted
			from #cteCohort c
				left outer join cteASQDueInterval casi on casi.hvcasefk = c.hvcasefk and casi.tcidpk = c.tcidpk
				left outer join ASQ a1 on a1.hvcasefk = c.hvcasefk and casi.tcidpk = a1.tcidfk and a1.TCAge = casi.Interval
				left outer join scoreASQ score1 on score1.TCAge = casi.Interval and score1.ASQVersion = a1.VersionNumber 
				left outer join codeApp capp1 on casi.Interval = capp1.AppCode and capp1.AppCodeGroup = 'TCAge' and 
													charindex('AQ',capp1.AppCodeUsedWhere)>0
				--One interval before due Interval			   
				left outer join cteASQDueIntervalOneBefore casi2 on casi2.hvcasefk = c.hvcasefk and casi2.tcidpk = c.tcidpk
				left outer join ASQ a2 on a2.hvcasefk = c.hvcasefk and casi2.tcidpk = a2.tcidfk and a2.TCAge = casi2.Interval
				left outer join scoreASQ score2 on score2.TCAge = casi2.Interval and score2.ASQVersion = a2.VersionNumber 
				left outer join codeApp capp2 on casi2.Interval = capp2.AppCode and capp2.AppCodeGroup = 'TCAge' and 
													charindex('AQ',capp2.AppCodeUsedWhere)>0
				--Two interval before due Interval			   
				left outer join cteASQDueIntervalTwoBefore casi3 on casi3.hvcasefk = c.hvcasefk and casi3.tcidpk = c.tcidpk
				left outer join ASQ a3 on a3.hvcasefk = c.hvcasefk and casi3.tcidpk = a3.tcidfk and a3.TCAge = casi3.Interval
				left outer join scoreASQ score3 on score3.TCAge = casi3.Interval and score3.ASQVersion = a3.VersionNumber 
				left outer join codeApp capp3 on casi3.Interval = capp3.AppCode and capp3.AppCodeGroup = 'TCAge' and 
													charindex('AQ',capp3.AppCodeUsedWhere)>0
				--Last ASQ Done prior to expected
				left outer join cteLastASQDone lasq on lasq.hvcasefk = c.hvcasefk and lasq.tcidpk = c.tcidpk
				left outer join ASQ a4 on a4.hvcasefk = c.hvcasefk and lasq.tcidpk = a4.tcidfk and a4.TCAge = lasq.Interval
				left outer join scoreASQ score4 on score4.TCAge = lasq.Interval and score4.ASQVersion = a4.VersionNumber 
				left outer join codeApp capp4 on a4.TCAge = capp4.AppCode and capp4.AppCodeGroup = 'TCAge' and 
													charindex('AQ',capp4.AppCodeUsedWhere) > 0
	)
	--SELECT * FROM cteExpectedForm
	--where pc1id = 'AC87140056486'	
	,
	
	-- calculate whether the forms meet the target
	cteMeetsTarget
	as
	(	
		select PTCode
			  , ef.HVCaseFK
			  , PC1ID
			  , OldID
			  , TCDOB
			  , ef.TCIDPK	
			  , PC1FullName
			  , CurrentWorkerFullName
			  , CurrentLevelName
			  , FormMissing
			  , FormOutOfWindow
			  , FormReviewed
		  	  , tcAgeDays
		  	  , tcAgeDays / 30.44 as TCAgeMonths
		  	  ,	a1.ASQPK  as asqpk1
		  	  , casi.Interval as interval1
		  	  , a1.ASQInWindow as inwindow1
		  	  , rtrim(capp1.AppCodeText) + ' ASQ' as FormText1
		  	  , a1.DateCompleted as FormDate1
		  	  , a1.TCReferred as TCReferred1
		  	  , a1.ASQTCReceiving as TCReceiving1
		  	  , a2.ASQPK as asqpk2
		  	  , casi2.Interval as interval2
		  	  , a2.ASQInWindow as inwindow2
		  	  , rtrim(capp2.AppCodeText) + ' ASQ' as FormText2
		  	  , a2.DateCompleted as FormDate2
		  	  , a2.TCReferred as TCReferred2
		  	  , a2.ASQTCReceiving as TCReceiving2
		  	  , a3.ASQPK  as asqpk3
		  	  , casi3.Interval as interval3
		  	  , a3.ASQInWindow as inwindow3
		  	  , rtrim(capp3.AppCodeText) + ' ASQ' as FormText3
		  	  , a3.DateCompleted as FormDate3
		  	  , a3.TCReferred as TCReferred3
		  	  , a3.ASQTCReceiving as TCReceiving3
		  	  , a4.ASQPK  as asqpk4
		  	  , lasq.Interval as interval4
		  	  , a4.ASQInWindow as inwindow4
		  	  , rtrim(capp4.AppCodeText) + ' ASQ' as FormText4
		  	  , a4.DateCompleted as FormDate4
		  	  , a4.TCReferred as TCReferred4
		  	  , a4.ASQTCReceiving as TCReceiving4

		  	  -- calculate the MeetsTargetCode; position 1 = Meets Target (1/0 = Y/N)
		  	  --								position 2 = Which ASQ slot to use for form date and name
			  -- see if we found the expected ASQ 
			  , case when a1.ASQPK is not null and
						   -- check condition a. age appropriate ASQ has all scores >= cutoff
						   ((a1.ASQCommunicationScore >= score1.CommunicationScore
						   		and a1.ASQFineMotorScore >= score1.FineMotorScore
								and a1.ASQGrossMotorScore >= score1.GrossMotorScore
								and a1.ASQPersonalSocialScore >= score1.PersonalScore
								and a1.ASQProblemSolvingScore >= score1.ProblemSolvingScore)
						   -- condition b. at least one below cutoff score and TC Referred = Yes 
								or ((a1.ASQCommunicationScore < score1.CommunicationScore
							   		or a1.ASQFineMotorScore < score1.FineMotorScore
								   	or a1.ASQGrossMotorScore < score1.GrossMotorScore 
								   	or a1.ASQPersonalSocialScore < score1.PersonalScore
								   	or a1.ASQProblemSolvingScore < score1.ProblemSolvingScore) 
								   	and a1.TCReferred = '1'))
							and FormMissing = 0 
							and FormReviewed = 1 
							and FormOutOfWindow = 0
						then '11'
						-- condition d. if expected form is optional, check form for prior interval
						-- and don't forget we may need to skip back 2 for intervals 9 and 10
						when (a1.ASQPK is null and charindex('(optional)',capp1.AppCodeText) > 0 and 
		   						a2.ASQPK is not null and
								((a2.ASQCommunicationScore >= score2.CommunicationScore
									and a2.ASQFineMotorScore >= score2.FineMotorScore
									and a2.ASQGrossMotorScore >= score2.GrossMotorScore
									and a2.ASQPersonalSocialScore >= score2.PersonalScore
									and a2.ASQProblemSolvingScore >= score2.ProblemSolvingScore) 
				   				-- condition d-b. at least one below cutoff score and TC Referred = Yes for last form completed
				   				or ((a2.ASQCommunicationScore < score2.CommunicationScore
										or a2.ASQFineMotorScore < score2.FineMotorScore
										or a2.ASQGrossMotorScore < score2.GrossMotorScore
										or a2.ASQPersonalSocialScore < score2.PersonalScore
										or a2.ASQProblemSolvingScore < score2.ProblemSolvingScore) 
				   					and a2.TCReferred = '1'))
			   					and FormMissing = 0
			   					and FormReviewed = 1 
			   					and FormOutOfWindow = 0)
						then '12'
						-- condition d. if expected form is optional, check form for prior interval
						when (a1.ASQPK is null and charindex('(optional)',capp1.AppCodeText) > 0 and 
   			   					a2.ASQPK is null and charindex('(optional)',capp2.AppCodeText) > 0 and 
		   						a3.ASQPK is not null and
								((a3.ASQCommunicationScore >= score3.CommunicationScore
									and a3.ASQFineMotorScore >= score3.FineMotorScore
									and a3.ASQGrossMotorScore >= score3.GrossMotorScore
									and a3.ASQPersonalSocialScore >= score3.PersonalScore
									and a3.ASQProblemSolvingScore >= score3.ProblemSolvingScore)
							   	-- condition d-b. at least one below cutoff score and TC Referred = Yes for last form completed
							   	or ((a3.ASQCommunicationScore < score3.CommunicationScore or 
										a3.ASQFineMotorScore < score3.FineMotorScore or
										a3.ASQGrossMotorScore < score3.GrossMotorScore or 
										a3.ASQPersonalSocialScore < score3.PersonalScore or
										a3.ASQProblemSolvingScore < score3.ProblemSolvingScore) 
							   		and a3.TCReferred = '1')) 
								and FormMissing = 0
			   					and FormReviewed = 1 
			   					and FormOutOfWindow = 0)
	   					then '13' 
						when a4.ASQPK is not null and a4.ASQTCReceiving = '1'
						 	and FormMissing = 0 
						 	and FormReviewed = 1 
						 	and FormOutOfWindow = 0
					 	then '14'
				else '0'
		      end as MeetsTargetCode -- FormMeetsTarget
		from cteExpectedForm ef
			left outer join cteASQDueInterval casi on casi.hvcasefk = ef.hvcasefk and casi.tcidpk = ef.tcidpk
			left outer join ASQ a1 on a1.hvcasefk = ef.hvcasefk and casi.tcidpk = a1.tcidfk and a1.TCAge = casi.Interval
			left outer join scoreASQ score1 on score1.TCAge = casi.Interval and score1.ASQVersion = a1.VersionNumber 
			left outer join codeApp capp1 on casi.Interval = capp1.AppCode and capp1.AppCodeGroup = 'TCAge' and 
												charindex('AQ',capp1.AppCodeUsedWhere) > 0
			--One interval before due Interval			   
			left outer join cteASQDueIntervalOneBefore casi2 on casi2.hvcasefk = ef.hvcasefk and casi2.tcidpk = ef.tcidpk
			left outer join ASQ a2 on a2.hvcasefk = ef.hvcasefk and casi2.tcidpk = a2.tcidfk and a2.TCAge = casi2.Interval
			left outer join scoreASQ score2 on score2.TCAge = casi2.Interval and score2.ASQVersion = a2.VersionNumber 
			left outer join codeApp capp2 on casi2.Interval = capp2.AppCode and capp2.AppCodeGroup = 'TCAge' and 
												charindex('AQ',capp2.AppCodeUsedWhere) > 0
			--Two interval before due Interval			   
			left outer join cteASQDueIntervalTwoBefore casi3 on casi3.hvcasefk = ef.hvcasefk and casi3.tcidpk = ef.tcidpk
			left outer join ASQ a3 on a3.hvcasefk = ef.hvcasefk and casi3.tcidpk = a3.tcidfk and a3.TCAge = casi3.Interval
			left outer join scoreASQ score3 on score3.TCAge = casi3.Interval and score3.ASQVersion = a3.VersionNumber 
			left outer join codeApp capp3 on casi3.Interval = capp3.AppCode and capp3.AppCodeGroup = 'TCAge' and 
												charindex('AQ',capp3.AppCodeUsedWhere) > 0
			--Last ASQ Done prior to expected
			left outer join cteLastASQDone lasq on lasq.hvcasefk = ef.hvcasefk and lasq.tcidpk = ef.tcidpk
			left outer join ASQ a4 on a4.hvcasefk = ef.hvcasefk and lasq.tcidpk = a4.tcidfk and a4.TCAge = lasq.Interval
			left outer join scoreASQ score4 on score4.TCAge = lasq.Interval and score4.ASQVersion = a4.VersionNumber 
			left outer join codeApp capp4 on a4.TCAge = capp4.AppCode and capp4.AppCodeGroup = 'TCAge' and 
												charindex('AQ',capp4.AppCodeUsedWhere) > 0
	)

--select count(HVCasefk) as TotalCases
--		, sum(FormReviewed) as FormReviewed
--		, sum(FormOutOfWindow) as FormOutOfWIndow
--		, sum(FormMissing) as FormMissing
--		, sum(FormMeetsTarget) as FormMeetsTarget
--		, sum(case when FormReviewed = 1 and FormMissing = 0 and FormOutOfWindow = 0 
--					then 1
--					else 0
--					end) as ValidCases
--from cteMain
	, 
	cteMain
	as
	(
		select PTCode
				, mt.HVCaseFK
				, mt.TCIDPK
				, PC1ID
				, OldID
				, TCDOB
				, PC1FullName
				, CurrentWorkerFullName
				, CurrentLevelName
				, case when substring(MeetsTargetCode,2,1) = '1' then FormText1
						 when substring(MeetsTargetCode,2,1) = '2' then FormText2
						 when substring(MeetsTargetCode,2,1) = '3' then FormText3
						 when substring(MeetsTargetCode,2,1) = '4' then FormText4
						 when MeetsTargetCode = '0' and asqpk1 is null 
							and charindex('(optional)',FormText1) = 0 then FormText1
						 when MeetsTargetCode = '0' and asqpk1 is not null then FormText1
						 when MeetsTargetCode = '0' and asqpk1 is null 
							and charindex('(optional)',FormText1) > 0 
							and asqpk2 is null 
							and charindex('(optional)',FormText2) = 0 
							then FormText2							
						 when MeetsTargetCode = '0' and asqpk2 is not null then FormText2
						 when MeetsTargetCode = '0' and asqpk3 is not null then FormText3
						 when MeetsTargetCode = '0' and asqpk1 is null 
								and charindex('(optional)',FormText1) > 0
								and asqpk2 is not null then FormText2
						 when MeetsTargetCode = '0' and asqpk1 is null 
								and charindex('(optional)',FormText1) > 0
								and asqpk2 is null 
								and charindex('(optional)',FormText2) > 0
								then FormText3
						 --when MeetsTargetCode = '0' and asqpk1 is null 
							--	and asqpk2 is null 
							--	and asqpk3 is null then FormText1
					else null
					end
					as FormName
				, case when substring(MeetsTargetCode,2,1) = '1' then FormDate1
						 when substring(MeetsTargetCode,2,1) = '2' then FormDate2
						 when substring(MeetsTargetCode,2,1) = '3' then FormDate3
						 when substring(MeetsTargetCode,2,1) = '4' then FormDate4
						 when MeetsTargetCode = '0' and ASQPK1 is not null then FormDate1
						 when MeetsTargetCode = '0' and ASQPK2 is not null 
								and charindex('(optional)',FormText1) > 0
							then FormDate2
						 when MeetsTargetCode = '0' and ASQPK3 is not null 
								and charindex('(optional)',FormText1) > 0
								and charindex('(optional)',FormText2) > 0
							then FormDate3
				else null
				end as FormDate
				, FormReviewed
				, FormOutOfWindow
				, FormMissing
				, left(MeetsTargetCode,1) as FormMeetsTarget
				, case when FormMissing = 1 then 'Form missing'
						when FormOutOfWindow = 1 then 'Form out of window'
						when FormReviewed = 0 then 'Form not reviewed by supervisor'
						when MeetsTargetCode = '0' then 'Under cutoff scores without EIP referral'
						else '' end as NotMeetingReason
				
				,TCReceiving1	
				,TCReceiving2	
				,TCReceiving3	
				,TCReceiving4		
						
						
			  --, MeetsTargetCode
			  --, tcAgeDays
			  --, tcAgeDays / 30.44 as TCAgeMonths
			  --, asqpk1
			  --, interval1
			  --, inwindow1
			  --, FormText1
			  --, FormDate1
			  --, asqpk2
			  --, interval2
			  --, inwindow2
			  --, FormText2
			  --, FormDate2
			  --, asqpk3
			  --, interval3
			  --, inwindow3
			  --, FormText3
			  --, FormDate3
			  --, asqpk4
			  --, interval4
			  --, inwindow4
			  --, FormText4
			  --, FormDate4
		  from cteMeetsTarget mt
	)  
	
	select * from cteMain
	--where pc1id = 'AC87140056486'
	--order by PC1ID

	drop table #cteCohort
			
end
GO
