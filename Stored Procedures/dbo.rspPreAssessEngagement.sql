SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:      <Dar Chen>
-- Create date: <Jul 16, 2012>
-- Description: 
-- exec rspPreAssessEngagement 19, '07/01/2012', '07/01/2012', '09/30/2012'
-- exec rspPreAssessEngagement 5, '07/01/2012', '07/01/2012', '09/30/2012'
-- exec rspPreAssessEngagement 1, 1, '07/01/2014', '09/30/2014'
-- =============================================
CREATE procedure [dbo].[rspPreAssessEngagement] (@programfk varchar(max) = null
										, @CustomQuarterlyDates bit
										, @StartDt datetime = null
										, @EndDt datetime = null
										)
as 

--DECLARE @StartDtT DATE = '01/01/2012'
--DECLARE @StartDt DATE = '09/01/2012'
--DECLARE @EndDt DATE = '11/30/2012'
--DECLARE @programfk INT = 4

	-- if user select a custom date range (not a specific quarter) then don't show ContractPeriod Column
	
	declare	@ContractStartDate date
	declare	@ContractEndDate date

	if ((@programfk is not null)
		and (@CustomQuarterlyDates = 0)
	   )
		begin 
			set @programfk = replace(@programfk, ',', '') -- remove comma's
			set @ContractStartDate = (select	ContractStartDate
									  from		HVProgram P
									  where		HVProgramPK = @programfk
									 )
			set @ContractEndDate = (select	ContractEndDate
									from	HVProgram P
									where	HVProgramPK = @programfk
								   )		
		end 
	
	if @programfk is null
		begin
			select	@programfk = substring((select	',' + ltrim(rtrim(str(HVProgramPK)))
											from	HVProgram
										   for
											xml	path('')
										   ), 2, 8000)
		end
	set @programfk = replace(@programfk, '"', '');
	
	with ScreensThisPeriod
			  as (select	a.HVCasePK
						  , c.ScreenResult
						  , isnull(a.TCDOB, a.EDC) DOB
						  , a.ScreenDate
						  , c.ReferralMade
						  , b.DischargeReason
				  from		HVCase as a
				  join		CaseProgram as b on a.HVCasePK = b.HVCaseFK
				  join		dbo.SplitString(@programfk, ',') on b.programfk = listitem
				  join		HVScreen as c on a.HVCasePK = c.HVCaseFK
				  where		a.ScreenDate between @StartDt and @EndDt
				 ) ,
			ScreensThisPeriod_1e
			  as (select	HVCasePK
				  from		ScreensThisPeriod
				  where		ScreenResult = 1
							and ReferralMade = 1
				 ) ,
			PreAssessmentCasesAtBeginningOfPeriod
			  as (select distinct
							a.HVCasePK
				  from		HVCase as a
				  join		CaseProgram as b on a.HVCasePK = b.HVCaseFK
				  join		dbo.SplitString(@programfk, ',') on b.programfk = listitem
				  where		(a.ScreenDate < @StartDt)
							and (a.KempeDate >= @StartDt
								 or a.KempeDate is null
								)
							and (b.DischargeDate is null
								 or b.DischargeDate >= @StartDt
								)
				 ) ,
			section2Q
			  as (select	count(*) [Q2PreAssessmentBeforePeriod]
				  from		PreAssessmentCasesAtBeginningOfPeriod
				 ) ,
			TotalCasesToBeAssessedThisPeriod_2_1e
			  as (select distinct
							isnull(a.HVCasePK, b.HVCasePK) [HVCasePK]
				  from		PreAssessmentCasesAtBeginningOfPeriod as a
				  full outer join ScreensThisPeriod_1e as b on a.HVCasePK = b.HVCasePK
				 ) ,
			PreAssessment_MaxPADate
			  as (select	a.HVCaseFK
						  , max(a.PADate) [max_PADATE]
				  from		Preassessment as a
				  join		dbo.SplitString(@programfk, ',') on a.programfk = listitem
				  where		a.PADate between @StartDt and @EndDt
				  group by	a.HVCaseFK
				 ) ,
			PreAssessment_LastOneInPeriod
			  as (select	a.HVCaseFK
						  , a.CaseStatus
						  , a.FSWAssignDate
						  , a.KempeResult
						  , a.PADate
				  from		Preassessment as a
				  join		PreAssessment_MaxPADate as b on a.HVCaseFK = b.HVCaseFK
															and a.PADate = b.max_PADATE
				 ) ,
			Outcomes
			  as (select	a.HVCasePK
						  , b.*
				  from		TotalCasesToBeAssessedThisPeriod_2_1e as a
				  left outer join PreAssessment_LastOneInPeriod as b on a.HVCasePK = b.HVCaseFK
				 ) ,
			section4Q
			  as (select	count(*) [Q3TotalCasesThisPerion]
						  , sum(case when CaseStatus in ('02', '04') then 1
									 else 0
								end) [Q4bCompleted]
						  , sum(case when CaseStatus = '02'
										  and KempeResult = 1
										  and FSWAssignDate <= @EndDt then 1
									 else 0
								end) [Q4b1PositiveAssignd]
						  , sum(case when CaseStatus = '02'
										  and KempeResult = 1
										  and FSWAssignDate > @EndDt then 1
									 else 0
								end) [Q4b2PositivePendingAssignd]
						  , sum(case when CaseStatus = '04'
										  and KempeResult = 1
										  and FSWAssignDate is null then 1
									 else 0
								end) [Q4b3PositiveNotAssignd]
						  , sum(case when CaseStatus = '02'
										  and KempeResult = 0 then 1
									 else 0
								end) [Q4b4Negative]
						  , sum(case when CaseStatus = '03' then 1
									 else 0
								end) [Q4cTerminated]
						  , sum(case when CaseStatus = '01'
										  and datediff(d, PADate, @EndDt) <= 30 then 1
									 else 0
								end) [Q4aEffortContnue]
				  from		Outcomes
				 ) ,
			section1QX
			  as (select	sum(1) [Q1Screened]
						  , sum(case when ScreenResult = 1 then 1
									 else 0
								end) [Q1aScreenResultPositive]
						  , sum(case when ScreenResult != 1 then 1
									 else 0
								end) [Q1bScreenResultNegative]
						  , sum(case when DOB > ScreenDate then 1
									 else 0
								end) [Q1cPrenatal]
						  , sum(case when DOB <= ScreenDate then 1
									 else 0
								end) [Q1dPostnatal]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 1 then 1
									 else 0
								end) [Q1ePositiveReferred]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 0 then 1
									 else 0
								end) [Q1fPositiveNotReferred]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 0
										  and DischargeReason in ('05', '07', '35', '36', '06', '08', '33', '34', '99',
																  '13', '25') then 1
									 else 0
								end) [Q1DischargeAll]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 0
										  and DischargeReason = '05' then 1
									 else 0
								end) [Q1f1IncomeIneligible]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 0
										  and DischargeReason = '07' then 1
									 else 0
								end) [Q1f2OutOfGeoTarget]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 0
										  and DischargeReason = '35' then 1
									 else 0
								end) [Q1f3NonCompliant]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 0
										  and DischargeReason = '36' then 1
									 else 0
								end) [Q1f3Refuse]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 0
										  and DischargeReason = '06' then 1
									 else 0
								end) [Q1f4InappropriateScreen]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 0
										  and DischargeReason = '08' then 1
									 else 0
								end) [Q1f5CaseLoadFull]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 0
										  and DischargeReason = '33' then 1
									 else 0
								end) [Q1f6PositiveScreen]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 0
										  and DischargeReason = '34' then 1
									 else 0
								end) [Q1f7SubsequentBirthOnOpenCase]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 0
										  and DischargeReason = '99' then 1
									 else 0
								end) [Q1f8Other]
						  , 0 [Q1f9NoReason]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 0
										  and DischargeReason = '13' then 1
									 else 0
								end) [Q1f10ControlCase]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 0
										  and DischargeReason = '25' then 1
									 else 0
								end) [Q1f11Transferred]
				  from		ScreensThisPeriod
				 ) ,
			section1Q
			  as (select	Q1Screened
						  , cast(cast(case when Q1Screened > 0
										   then round(100.0 * Q1aScreenResultPositive / Q1Screened, 0)
										   else 0
									  end as int) as varchar(20)) + '%' [Q1aScreenResultPositive]
						  , cast(cast(case when Q1Screened > 0
										   then round(100.0 * Q1bScreenResultNegative / Q1Screened, 0)
										   else 0
									  end as int) as varchar(20)) + '%' [Q1bScreenResultNegative]
						  , cast(cast(case when Q1Screened > 0 then round(100.0 * Q1cPrenatal / Q1Screened, 0)
										   else 0
									  end as int) as varchar(20)) + '%' [Q1cPrenatal]
						  , cast(cast(case when Q1Screened > 0 then round(100.0 * Q1dPostnatal / Q1Screened, 0)
										   else 0
									  end as int) as varchar(20)) + '%' [Q1dPostnatal]
						  , cast(cast(case when Q1Screened > 0 then round(100.0 * Q1ePositiveReferred / Q1Screened, 0)
										   else 0
									  end as int) as varchar(20)) + '%' [Q1ePositiveReferredPercent]
						  , Q1ePositiveReferred
						  , cast(cast(case when Q1Screened > 0
										   then round(100.0 * Q1fPositiveNotReferred / Q1Screened, 0)
										   else 0
									  end as int) as varchar(20)) + '%' [Q1fPositiveNotReferredPercent]
						  , Q1fPositiveNotReferred
						  , cast(cast(case when Q1DischargeAll > 0
										   then round(100.0 * Q1f1IncomeIneligible / Q1DischargeAll, 0)
										   else 0
									  end as int) as varchar(20)) + '%' Q1f1IncomeIneligible
						  , cast(cast(case when Q1DischargeAll > 0
										   then round(100.0 * Q1f2OutOfGeoTarget / Q1DischargeAll, 0)
										   else 0
									  end as int) as varchar(20)) + '%' Q1f2OutOfGeoTarget
						  , cast(cast(case when Q1DischargeAll > 0
										   then round(100.0 * Q1f3NonCompliant / Q1DischargeAll, 0)
										   else 0
									  end as int) as varchar(20)) + '%' Q1f3NonCompliant
						  , cast(cast(case when Q1DischargeAll > 0 then round(100.0 * Q1f3Refuse / Q1DischargeAll, 0)
										   else 0
									  end as int) as varchar(20)) + '%' Q1f3Refuse
						  , cast(cast(case when Q1DischargeAll > 0
										   then round(100.0 * Q1f4InappropriateScreen / Q1DischargeAll, 0)
										   else 0
									  end as int) as varchar(20)) + '%' Q1f4InappropriateScreen
						  , cast(cast(case when Q1DischargeAll > 0
										   then round(100.0 * Q1f5CaseLoadFull / Q1DischargeAll, 0)
										   else 0
									  end as int) as varchar(20)) + '%' Q1f5CaseLoadFull
						  , cast(cast(case when Q1DischargeAll > 0
										   then round(100.0 * Q1f6PositiveScreen / Q1DischargeAll, 0)
										   else 0
									  end as int) as varchar(20)) + '%' Q1f6PositiveScreen
						  , cast(cast(case when Q1DischargeAll > 0
										   then round(100.0 * Q1f7SubsequentBirthOnOpenCase / Q1DischargeAll, 0)
										   else 0
									  end as int) as varchar(20)) + '%' Q1f7SubsequentBirthOnOpenCase
						  , cast(cast(case when Q1DischargeAll > 0 then round(100.0 * Q1f8Other / Q1DischargeAll, 0)
										   else 0
									  end as int) as varchar(20)) + '%' Q1f8Other
						  , cast(cast(case when Q1DischargeAll > 0 then round(100.0 * Q1f9NoReason / Q1DischargeAll, 0)
										   else 0
									  end as int) as varchar(20)) + '%' Q1f9NoReason
						  , cast(cast(case when Q1DischargeAll > 0
										   then round(100.0 * Q1f10ControlCase / Q1DischargeAll, 0)
										   else 0
									  end as int) as varchar(20)) + '%' Q1f10ControlCase
						  , cast(cast(case when Q1DischargeAll > 0
										   then round(100.0 * Q1f11Transferred / Q1DischargeAll, 0)
										   else 0
									  end as int) as varchar(20)) + '%' Q1f11Transferred
				  from		section1QX
				 ) ,
			section5Q
			  as (select	sum(PAParentLetter) [Q5aPAParentLetter]
						  , sum(PACall2Parent) [Q5bPACall2Parent]
						  , sum(PACallFromParent) [Q5cPACallFromParent]
						  , sum(PAVisitAttempt) [Q5dPAVisitAttempt]
						  , sum(PAVisitMade) [Q5ePAVisitMade]
						  , sum(PAOtherHVProgram) [Q5fPAOtherHVProgram]
						  , sum(PAParent2Office) [Q5gPAParent2Office]
						  , sum(PAProgramMaterial) [Q5hPAProgramMaterial]
						  , sum(PAGift) [Q5iPAGift]
						  , sum(PACaseReview) [Q5jPACaseReview]
						  , sum(PAOtherActivity) [Q5kPAOtherActivity]
				  from		Preassessment
				  join		dbo.SplitString(@programfk, ',') on programfk = listitem
				  where		PADate between @StartDt and @EndDt
				 ) ,

/* total */	ScreensThisPeriodT
			  as (select	a.HVCasePK
						  , c.ScreenResult
						  , isnull(a.TCDOB, a.EDC) DOB
						  , a.ScreenDate
						  , c.ReferralMade
						  , b.DischargeReason
				  from		HVCase as a
				  join		CaseProgram as b on a.HVCasePK = b.HVCaseFK
				  join		dbo.SplitString(@programfk, ',') on b.programfk = listitem
				  join		HVScreen as c on a.HVCasePK = c.HVCaseFK
				  where		a.ScreenDate between @ContractStartDate and @ContractEndDate
				 ) ,
			ScreensThisPeriod_1eT
			  as (select	HVCasePK
				  from		ScreensThisPeriodT
				  where		ScreenResult = 1
							and ReferralMade = 1
				 ) ,
			PreAssessmentCasesAtBeginningOfPeriodT
			  as (select distinct
							a.HVCasePK
				  from		HVCase as a
				  join		CaseProgram as b on a.HVCasePK = b.HVCaseFK
				  join		dbo.SplitString(@programfk, ',') on b.programfk = listitem
				  where		(a.ScreenDate < @ContractStartDate)
							and (a.KempeDate >= @ContractStartDate
								 or a.KempeDate is null
								)
							and (b.DischargeDate is null
								 or b.DischargeDate >= @ContractStartDate
								)
				 ) ,
			section2QT
			  as (select	count(*) [T2PreAssessmentBeforePeriod]
				  from		PreAssessmentCasesAtBeginningOfPeriodT
				 ) ,
			TotalCasesToBeAssessedThisPeriod_2_1eT
			  as (select distinct
							isnull(a.HVCasePK, b.HVCasePK) [HVCasePK]
				  from		PreAssessmentCasesAtBeginningOfPeriodT as a
				  full outer join ScreensThisPeriod_1eT as b on a.HVCasePK = b.HVCasePK
				 ) ,
			PreAssessment_MaxPADateT
			  as (select	a.HVCaseFK
						  , max(a.PADate) [max_PADATE]
				  from		Preassessment as a
				  join		dbo.SplitString(@programfk, ',') on a.programfk = listitem
				  where		a.PADate between @ContractStartDate and @ContractEndDate
				  group by	a.HVCaseFK
				 ) ,
			PreAssessment_LastOneInPeriodT
			  as (select	a.HVCaseFK
						  , a.CaseStatus
						  , a.FSWAssignDate
						  , a.KempeResult
						  , a.PADate
				  from		Preassessment as a
				  join		PreAssessment_MaxPADateT as b on a.HVCaseFK = b.HVCaseFK
															 and a.PADate = b.max_PADATE
				 ) ,
			OutcomesT
			  as (select	a.HVCasePK
						  , b.*
				  from		TotalCasesToBeAssessedThisPeriod_2_1eT as a
				  left outer join PreAssessment_LastOneInPeriodT as b on a.HVCasePK = b.HVCaseFK
				 ) ,
			section4QT
			  as (select	count(*) [T3TotalCasesThisPerion]
						  , sum(case when CaseStatus in ('02', '04') then 1
									 else 0
								end) [T4bCompleted]
						  , sum(case when CaseStatus = '02'
										  and KempeResult = 1
										  and FSWAssignDate <= @EndDt then 1
									 else 0
								end) [T4b1PositiveAssignd]
						  , sum(case when CaseStatus = '02'
										  and KempeResult = 1
										  and FSWAssignDate > @EndDt then 1
									 else 0
								end) [T4b2PositivePendingAssignd]
						  , sum(case when CaseStatus = '04'
										  and KempeResult = 1
										  and FSWAssignDate is null then 1
									 else 0
								end) [T4b3PositiveNotAssignd]
						  , sum(case when CaseStatus = '02'
										  and KempeResult = 0 then 1
									 else 0
								end) [T4b4Negative]
						  , sum(case when CaseStatus = '03' then 1
									 else 0
								end) [T4cTerminated]
						  , sum(case when CaseStatus = '01'
										  and datediff(d, PADate, @EndDt) <= 30 then 1
									 else 0
								end) [T4aEffortContnue]
				  from		OutcomesT
				 ) ,
			section1QXT
			  as (select	sum(1) [T1Screened]
						  , sum(case when ScreenResult = 1 then 1
									 else 0
								end) [T1aScreenResultPositive]
						  , sum(case when ScreenResult != 1 then 1
									 else 0
								end) [T1bScreenResultNegative]
						  , sum(case when DOB > ScreenDate then 1
									 else 0
								end) [T1cPrenatal]
						  , sum(case when DOB <= ScreenDate then 1
									 else 0
								end) [T1dPostnatal]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 1 then 1
									 else 0
								end) [T1ePositiveReferred]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 0 then 1
									 else 0
								end) [T1fPositiveNotReferred]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 0
										  and DischargeReason in ('05', '07', '35', '36', '06', '08', '33', '34', '99',
																  '13', '25') then 1
									 else 0
								end) [T1DischargeAll]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 0
										  and DischargeReason = '05' then 1
									 else 0
								end) [T1f1IncomeIneligible]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 0
										  and DischargeReason = '07' then 1
									 else 0
								end) [T1f2OutOfGeoTarget]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 0
										  and DischargeReason = '35' then 1
									 else 0
								end) [T1f3NonCompliant]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 0
										  and DischargeReason = '36' then 1
									 else 0
								end) [T1f3Refuse]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 0
										  and DischargeReason = '06' then 1
									 else 0
								end) [T1f4InappropriateScreen]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 0
										  and DischargeReason = '08' then 1
									 else 0
								end) [T1f5CaseLoadFull]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 0
										  and DischargeReason = '33' then 1
									 else 0
								end) [T1f6PositiveScreen]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 0
										  and DischargeReason = '34' then 1
									 else 0
								end) [T1f7SubsequentBirthOnOpenCase]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 0
										  and DischargeReason = '99' then 1
									 else 0
								end) [T1f8Other]
						  , 0 [T1f9NoReason]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 0
										  and DischargeReason = '13' then 1
									 else 0
								end) [T1f10ControlCase]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 0
										  and DischargeReason = '25' then 1
									 else 0
								end) [T1f11Transferred]
				  from		ScreensThisPeriodT
				 ) ,
			section1QT
			  as (select	T1Screened
						  , cast(cast(case when T1Screened > 0
										   then round(100.0 * T1aScreenResultPositive / T1Screened, 0)
										   else 0
									  end as int) as varchar(20)) + '%' [T1aScreenResultPositive]
						  , cast(cast(case when T1Screened > 0
										   then round(100.0 * T1bScreenResultNegative / T1Screened, 0)
										   else 0
									  end as int) as varchar(20)) + '%' [T1bScreenResultNegative]
						  , cast(cast(case when T1Screened > 0 then round(100.0 * T1cPrenatal / T1Screened, 0)
										   else 0
									  end as int) as varchar(20)) + '%' [T1cPrenatal]
						  , cast(cast(case when T1Screened > 0 then round(100.0 * T1dPostnatal / T1Screened, 0)
										   else 0
									  end as int) as varchar(20)) + '%' [T1dPostnatal]
						  , T1ePositiveReferred
						  , T1fPositiveNotReferred
						  , cast(cast(case when T1Screened > 0 then round(100.0 * T1ePositiveReferred / T1Screened, 0)
										   else 0
									  end as int) as varchar(20)) + '%' [T1ePositiveReferredPercent]
						  , cast(cast(case when T1Screened > 0
										   then round(100.0 * T1fPositiveNotReferred / T1Screened, 0)
										   else 0
									  end as int) as varchar(20)) + '%' [T1fPositiveNotReferredPercent]
						  , cast(cast(case when T1DischargeAll > 0
										   then round(100.0 * T1f1IncomeIneligible / T1DischargeAll, 0)
										   else 0
									  end as int) as varchar(20)) + '%' T1f1IncomeIneligible
						  , cast(cast(case when T1DischargeAll > 0
										   then round(100.0 * T1f2OutOfGeoTarget / T1DischargeAll, 0)
										   else 0
									  end as int) as varchar(20)) + '%' T1f2OutOfGeoTarget
						  , cast(cast(case when T1DischargeAll > 0
										   then round(100.0 * T1f3NonCompliant / T1DischargeAll, 0)
										   else 0
									  end as int) as varchar(20)) + '%' T1f3NonCompliant
						  , cast(cast(case when T1DischargeAll > 0 then round(100.0 * T1f3Refuse / T1DischargeAll, 0)
										   else 0
									  end as int) as varchar(20)) + '%' T1f3Refuse
						  , cast(cast(case when T1DischargeAll > 0
										   then round(100.0 * T1f4InappropriateScreen / T1DischargeAll, 0)
										   else 0
									  end as int) as varchar(20)) + '%' T1f4InappropriateScreen
						  , cast(cast(case when T1DischargeAll > 0
										   then round(100.0 * T1f5CaseLoadFull / T1DischargeAll, 0)
										   else 0
									  end as int) as varchar(20)) + '%' T1f5CaseLoadFull
						  , cast(cast(case when T1DischargeAll > 0
										   then round(100.0 * T1f6PositiveScreen / T1DischargeAll, 0)
										   else 0
									  end as int) as varchar(20)) + '%' T1f6PositiveScreen
						  , cast(cast(case when T1DischargeAll > 0
										   then round(100.0 * T1f7SubsequentBirthOnOpenCase / T1DischargeAll, 0)
										   else 0
									  end as int) as varchar(20)) + '%' T1f7SubsequentBirthOnOpenCase
						  , cast(cast(case when T1DischargeAll > 0 then round(100.0 * T1f8Other / T1DischargeAll, 0)
										   else 0
									  end as int) as varchar(20)) + '%' T1f8Other
						  , cast(cast(case when T1DischargeAll > 0 then round(100.0 * T1f9NoReason / T1DischargeAll, 0)
										   else 0
									  end as int) as varchar(20)) + '%' T1f9NoReason
						  , cast(cast(case when T1DischargeAll > 0
										   then round(100.0 * T1f10ControlCase / T1DischargeAll, 0)
										   else 0
									  end as int) as varchar(20)) + '%' T1f10ControlCase
						  , cast(cast(case when T1DischargeAll > 0
										   then round(100.0 * T1f11Transferred / T1DischargeAll, 0)
										   else 0
									  end as int) as varchar(20)) + '%' T1f11Transferred
				  from		section1QXT
				 ) ,
			section5QT
			  as (select	sum(PAParentLetter) [T5aPAParentLetter]
						  , sum(PACall2Parent) [T5bPACall2Parent]
						  , sum(PACallFromParent) [T5cPACallFromParent]
						  , sum(PAVisitAttempt) [T5dPAVisitAttempt]
						  , sum(PAVisitMade) [T5ePAVisitMade]
						  , sum(PAOtherHVProgram) [T5fPAOtherHVProgram]
						  , sum(PAParent2Office) [T5gPAParent2Office]
						  , sum(PAProgramMaterial) [T5hPAProgramMaterial]
						  , sum(PAGift) [T5iPAGift]
						  , sum(PACaseReview) [T5jPACaseReview]
						  , sum(PAOtherActivity) [T5kPAOtherActivity]
				  from		Preassessment
				  join		dbo.SplitString(@programfk, ',') on programfk = listitem
				  where		PADate between @ContractStartDate and @ContractEndDate
				 ) ,
			xxxx
			  as (select	section1Q.*
							, section2Q.*
							, section4Q.*
							, 0 [Q4dNoStatus1]
							, 0 [Q4dNoStatus2]
							, section4Q.Q3TotalCasesThisPerion - ([Q4aEffortContnue] + [Q4bCompleted] + [Q4cTerminated]) as [Q4dNoStatus]
							, section5Q.*
							, case when @CustomQuarterlyDates = 1 then null else T1Screened end as T1Screened
							, case when @CustomQuarterlyDates = 1 then null else T1aScreenResultPositive end as T1aScreenResultPositive
							, case when @CustomQuarterlyDates = 1 then null else T1bScreenResultNegative end as T1bScreenResultNegative
							, case when @CustomQuarterlyDates = 1 then null else T1cPrenatal end as T1cPrenatal
							, case when @CustomQuarterlyDates = 1 then null else T1dPostnatal end as T1dPostnatal
							, case when @CustomQuarterlyDates = 1 then null else T1ePositiveReferred end as T1ePositiveReferred
							, case when @CustomQuarterlyDates = 1 then null else T1fPositiveNotReferred end as T1fPositiveNotReferred
							, case when @CustomQuarterlyDates = 1 then null else T1ePositiveReferredPercent end as T1ePositiveReferredPercent
							, case when @CustomQuarterlyDates = 1 then null else T1fPositiveNotReferredPercent end as T1fPositiveNotReferredPercent
							, case when @CustomQuarterlyDates = 1 then null else T1f1IncomeIneligible end as T1f1IncomeIneligible
							, case when @CustomQuarterlyDates = 1 then null else T1f2OutOfGeoTarget end as T1f2OutOfGeoTarget
							, case when @CustomQuarterlyDates = 1 then null else T1f3NonCompliant end as T1f3NonCompliant
							, case when @CustomQuarterlyDates = 1 then null else T1f3Refuse end as T1f3Refuse
							, case when @CustomQuarterlyDates = 1 then null else T1f4InappropriateScreen end as T1f4InappropriateScreen
							, case when @CustomQuarterlyDates = 1 then null else T1f5CaseLoadFull end as T1f5CaseLoadFull
							, case when @CustomQuarterlyDates = 1 then null else T1f6PositiveScreen end as T1f6PositiveScreen
							, case when @CustomQuarterlyDates = 1 then null else T1f7SubsequentBirthOnOpenCase end as T1f7SubsequentBirthOnOpenCase
							, case when @CustomQuarterlyDates = 1 then null else T1f8Other end as T1f8Other
							, case when @CustomQuarterlyDates = 1 then null else T1f9NoReason end as T1f9NoReason
							, case when @CustomQuarterlyDates = 1 then null else T1f10ControlCase end as T1f10ControlCase
							, case when @CustomQuarterlyDates = 1 then null else T1f11Transferred end as T1f11Transferred
							, case when @CustomQuarterlyDates = 1 then null else T2PreAssessmentBeforePeriod end as T2PreAssessmentBeforePeriod
							, case when @CustomQuarterlyDates = 1 then null else T3TotalCasesThisPerion end as T3TotalCasesThisPerion
							, case when @CustomQuarterlyDates = 1 then null else T4bCompleted end as T4bCompleted
							, case when @CustomQuarterlyDates = 1 then null else T4b1PositiveAssignd end as T4b1PositiveAssignd
							, case when @CustomQuarterlyDates = 1 then null else T4b2PositivePendingAssignd end as T4b2PositivePendingAssignd
							, case when @CustomQuarterlyDates = 1 then null else T4b3PositiveNotAssignd end as T4b3PositiveNotAssignd
							, case when @CustomQuarterlyDates = 1 then null else T4b4Negative end as T4b4Negative
							, case when @CustomQuarterlyDates = 1 then null else T4cTerminated end as T4cTerminated
							, case when @CustomQuarterlyDates = 1 then null else T4aEffortContnue end as T4aEffortContnue
							, 0 as T4dNoStatus1
							, 0 as T4dNoStatus2
							, section4QT.T3TotalCasesThisPerion - ([T4aEffortContnue] + [T4bCompleted] + [T4cTerminated]) as [T4dNoStatus]
							, case when @CustomQuarterlyDates = 1 then null else T5aPAParentLetter end as T5aPAParentLetter
							, case when @CustomQuarterlyDates = 1 then null else T5bPACall2Parent end as T5bPACall2Parent
							, case when @CustomQuarterlyDates = 1 then null else T5cPACallFromParent end as T5cPACallFromParent
							, case when @CustomQuarterlyDates = 1 then null else T5dPAVisitAttempt end as T5dPAVisitAttempt
							, case when @CustomQuarterlyDates = 1 then null else T5ePAVisitMade end as T5ePAVisitMade
							, case when @CustomQuarterlyDates = 1 then null else T5fPAOtherHVProgram end as T5fPAOtherHVProgram
							, case when @CustomQuarterlyDates = 1 then null else T5gPAParent2Office end as T5gPAParent2Office
							, case when @CustomQuarterlyDates = 1 then null else T5hPAProgramMaterial end as T5hPAProgramMaterial
							, case when @CustomQuarterlyDates = 1 then null else T5iPAGift end as T5iPAGift
							, case when @CustomQuarterlyDates = 1 then null else T5jPACaseReview end as T5jPACaseReview
							, case when @CustomQuarterlyDates = 1 then null else T5kPAOtherActivity end as T5kPAOtherActivity							--, section1QT.*
							--, section2QT.*
							--, section4QT.*
							--, 0 [T4dNoStatus1]
							--, 0 [T4dNoStatus2]
							--, section4QT.T3TotalCasesThisPerion - ([T4aEffortContnue] + [T4bCompleted] + [T4cTerminated]) as [T4dNoStatus]
							--, section5QT.*
				  from		section1Q
				  join		section2Q on 1 = 1
				  join		section4Q on 1 = 1
				  join		section5Q on 1 = 1
				  join		section1QT on 1 = 1
				  join		section2QT on 1 = 1
				  join		section4QT on 1 = 1
				  join		section5QT on 1 = 1
				 )
		select	*
		from	xxxx


GO
