SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Jan 4, 2012>
-- Description:	<Report - Screen Referral Source Outcome Summary>
-- =============================================

CREATE procedure [dbo].[rspScreenReferralSourceOutcomeSummary]
(
    @programfk varchar(max)    = null,
    @sdate     datetime,
    @edate     datetime
)
as

--DECLARE @programfk varchar(max)    = '18'
--DECLARE   @sdate     DATETIME  = '01/01/2011'
--DECLARE   @edate     DATETIME = '12/01/2012'

	if @programfk is null
	begin
		select @programfk =
			   substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
							  from HVProgram
							  for xml path ('')),2,8000)
	end

	set @programfk = REPLACE(@programfk,'"','')

	select ReferralSourceName
		  ,screens
		  ,positivescreen
		  ,1 as ppositivescreen -- positivescreen/(screens*1.0) 
		  --,case
			 --  when screens > 0 then
				--   positivescreen/(screens*1.0)
			 --  else
				--   0
		  -- end as pPositiveScreen
		  ,ClosedPreassessment
		  ,case
			   when positivescreen > 0 then
				   ClosedPreassessment/(positivescreen*1.0)
			   else
				   0
		   end as pClosedPreassessment
		  ,PreAssessmentPendingAssessment
		  ,case
			   when positivescreen > 0 then
				   PreAssessmentPendingAssessment/(positivescreen*1.0)
			   else
				   0
		   end as pPreAssessmentPendingAssessment
		  ,PreintakeAssessmentCompleteAssigned
		  ,case
			   when positivescreen > 0 then
				   PreintakeAssessmentCompleteAssigned/(positivescreen*1.0)
			   else
				   0
		   end as pPreintakeAssessmentCompleteAssigned
		  ,ClosedAssessmentCompleteNotAssigned
		  ,case
			   when positivescreen > 0 then
				   ClosedAssessmentCompleteNotAssigned/(positivescreen*1.0)
			   else
				   0
		   end as pClosedAssessmentCompleteNotAssigned
		  ,ClosedPreIntakeAssessmentCompleteAssigned
		  ,case
			   when positivescreen > 0 then
				   ClosedPreIntakeAssessmentCompleteAssigned/(positivescreen*1.0)
			   else
				   0
		   end as pClosedPreIntakeAssessmentCompleteAssigned
		  ,Enrolled
		  ,case
			   when positivescreen > 0 then
				   Enrolled/(positivescreen*1.0)
			   else
				   0
		   end as pEnrolled
		from (
			  select count(HVCase.PC1FK) screens
					,sum(case
							 when ScreenResult = 1 and ReferralMade = 1 then
								 1
							 else
								 0
						 end) as positivescreen
					,sum(case
					-- caseprogress = 3 
							 when CurrentLevelFK = 4 then
								 1
							 else
								 0
						 end) as ClosedPreassessment
					,sum(case
							 when CurrentLevelFK = 3 then
								 1
							 else
								 0
						 end) as PreAssessmentPendingAssessment
					,sum(case
							 when currentlevelfk = 7 then
								 1
							 else
								 0
						 end) as PreintakeAssessmentCompleteAssigned
					,sum(case
						-- CaseProgress = 4 and DischargeDate <> null 
							 when CurrentLevelFK = 6 then
								 1
							 else
								 0
						 end) as ClosedAssessmentCompleteNotAssigned
					,sum(case
						-- CaseProgress = 7 
							 when CurrentLevelFK = 9 then
								 1
							 else
								 0
						 end) as ClosedPreIntakeAssessmentCompleteAssigned
					,sum(case
							 when intakedate is not null then
								 1
							 else
								 0
						 end) as Enrolled
					--,ReferralSourceName
					,CASE WHEN ReferralSourceName IS NULL THEN 'No Referral Source' ELSE ReferralSourceName END ReferralSourceName
				  from hvscreen
					  inner join HVCase on HVScreen.HVCaseFK = HVCasePK
					  inner join caseprogram on caseprogram.hvcasefk = hvcasepk
					  LEFT OUTER join dbo.listReferralSource on ReferralSourceFK = listReferralSourcePK
					  inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
				  where hvscreen.ScreenDate between @sdate and @edate
						-- and CaseProgress=3 and CurrentLevelFK=3
				  group by CASE WHEN ReferralSourceName IS NULL THEN 'No Referral Source' ELSE ReferralSourceName END) t
		order by screens desc
GO
