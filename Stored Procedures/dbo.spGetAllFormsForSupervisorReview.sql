SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jay Robohn
-- Create date: 2012-09-20
-- Description:	Gets a list of all forms to be reviewed that haven't been reviewed yet and
--				fall within the range of dates for that form's review option row.
-- exec spGetAllFormsForSupervisorReview 1,120,null
-- exec spGetAllFormsForSupervisorReview 4,120,null
-- added: How to handle some special url redirections - bug# HW946 ... Khalsa 3/7/2014
-- 
-- =============================================
CREATE PROCEDURE [dbo].[spGetAllFormsForSupervisorReview]
	(
	@ProgramFK int
	, @DaysToLoad int=30
	, @SupervisorFK int=null
	)
	
as
begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	with cteSupervisors	as 
	(
		select ltrim(rtrim(LastName)) + ', ' + ltrim(rtrim(FirstName)) as WorkerName
				, TerminationDate
				, WorkerPK
				, 'SUP' as workertype
		from Worker w
		inner join WorkerProgram wp on wp.WorkerFK = w.WorkerPK
		where programfk = @ProgramFK 
				and current_timestamp between SupervisorStartDate and isnull(SupervisorEndDate,dateadd(dd,1,datediff(dd,0,getdate())))
	)	
	, cteCohort as 
	(
		select max(CaseProgramPK) as CaseProgramPK
			from CaseProgram cp
			inner join FormReview fr on fr.HVCaseFK = cp.HVCaseFK
									and fr.ProgramFK = cp.ProgramFK
									and convert(date, FormDate) >= CaseStartDate
									and convert(date, FormDate) between dateadd(day, @DaysToLoad * -1, current_timestamp) and current_timestamp
			inner join SplitString(@ProgramFK, ',') ss on ss.ListItem = cp.ProgramFK
			group by cp.HVCaseFK
	)
	, cteFormReview as 
	(	
		select FormReviewPK
			  ,PC1ID
			  ,codeFormName
			  ,convert(varchar(10),FormDate,101) as FormDate
			  ,FormFK
			  --,FormReviewCreateDate
			  ,convert(varchar(10),FormReviewCreateDate,101) as FormReviewCreateDate
			  ,FormReviewCreator
			  ,FormReviewEditDate
			  ,FormReviewEditor
			  ,fr.FormType
			  ,fr.HVCaseFK
			  ,fr.ProgramFK
			  ,ReviewDateTime
			  ,ReviewedBy
			  ,FormReviewStartDate
			  ,FormReviewEndDate
			  ,'CaseHome.aspx?pc1id='+PC1ID as CaseHomeLink
			  ,case 
					-- Handling some special url redirections 
					when fr.FormType='PA' then 'preassessment.aspx?pc1id='+PC1ID+ '&papk=' + convert(varchar,FormFK)		  -- Note: here we use preassessment.aspx
					when fr.FormType='PI' then 'PreIntake.aspx?pc1id='+PC1ID+ '&pipk=' + convert(varchar,FormFK)		  -- Note: here we use PreIntakes.aspx
					when fr.FormType='SR' then 'ServiceReferral.aspx?pc1id='+PC1ID+ '&srpk=' + convert(varchar,FormFK)		  -- Note: here we use ServiceReferral.aspx
					when fr.FormType='VL' AND fr.FormDate > '2017-06-05 00:00:00.000' THEN 'HomeVisitLog.aspx?pc1id='+PC1ID+ '&hvlogpk=' + convert(varchar,FormFK)		  -- Note: here we use HomeVisitLogs.aspx
					when fr.FormType='VL' AND fr.FormDate <= '2017-06-05 00:00:00.000' then 'HomeVisitLogOld.aspx?pc1id='+PC1ID+ '&hvlogpk=' + convert(varchar,FormFK)		  -- Note: here we use HomeVisitLogs.aspx
					when fr.FormType='ID' then 'IdContactInformation.aspx?pc1id='+PC1ID		  -- Note: here we use IdContactInformation.aspx
					when fr.FormType='IN' then 'Intake.aspx?pc1id='+PC1ID+ '&ipk=' + convert(varchar,FormFK)		  -- Note: here we use Intake.aspx
					when fr.FormType='DS' then 'PreDischarge.aspx?pc1id='+PC1ID	-- Note: here we use PreDischarge.aspx
					when fr.FormType='TM' then 'SelectTC.aspx?pc1id='+PC1ID+ '&form=TCMedical'	  -- only three forms use SelectTC.aspx
					when fr.FormType='AS' then 'SelectTC.aspx?pc1id='+PC1ID+ '&form=ASQSE'		  -- only three forms use SelectTC.aspx			  
					when fr.FormType='AQ' then 'SelectTC.aspx?pc1id='+PC1ID+ '&form=ASQ1'			  -- only three forms use SelectTC.aspx
					when fr.FormType='PS' then 'PSI.aspx?pc1id='+PC1ID		  -- Note: here we use PSI.aspx
					when fr.FormType='FU' then 'FollowUps.aspx?pc1id='+PC1ID		  -- Note: here we use FollowUps.aspx
					when fr.FormType='SC' then 'HVScreen.aspx?pc1id='+PC1ID+ '&hvscreenpk=' + convert(varchar,FormFK)		  
					when fr.FormType='KE' then 'Kempe.aspx?pc1id='+PC1ID+ '&kempepk=' + convert(varchar,FormFK)		  
					when fr.FormType='TC' then 'TCIDs.aspx?pc1id='+PC1ID		  -- Note: here we use TCIDs.aspx
				else
					ltrim(rtrim(replace(replace(codeFormName,'-',''),' ','')))+'.aspx?pc1id='+PC1ID
				end as FormLink
			  ,isnull(FormReviewEndDate, current_timestamp) as EffectiveEndDate
			  ,dateadd(day, @DaysToLoad*-1, isnull(FormReviewEndDate, current_timestamp)) as EffectiveStartDate
			  ,case when cp.CurrentFSWFK is not null then ltrim(rtrim(wfsw.LastName)) + ', ' + ltrim(rtrim(wfsw.FirstName)) 
					when cp.CurrentFAWFK is not null then ltrim(rtrim(wfaw.LastName)) + ', ' + ltrim(rtrim(wfaw.FirstName)) 
					else '*Unassigned*'
				end as WorkerName
			  ,case when cp.CurrentFSWFK is not null then supfsw.WorkerName
					when cp.CurrentFAWFK is not null then supfaw.WorkerName
					else '*Unassigned*'
				end as SupervisorName
		from cteCohort co
		inner join CaseProgram cp ON cp.CaseProgramPK = co.CaseProgramPK
		inner join FormReview fr on fr.HVCaseFK = cp.HVCaseFK and fr.ProgramFK = cp.ProgramFK and FormDate >= CaseStartDate
		inner join FormReviewOptions fro on fro.FormType = fr.FormType and fro.ProgramFK = isnull(@ProgramFK,fro.ProgramFK)
		inner join codeForm f on codeFormAbbreviation = fr.FormType
		left outer join HVLog vl on vl.ProgramFK = cp.ProgramFK and fr.FormType = 'VL' and fr.FormFK = vl.HVLogPK
		left outer join WorkerProgram wpfsw on wpfsw.WorkerFK = cp.CurrentFSWFK and wpfsw.ProgramFK = @ProgramFK
		left outer join WorkerProgram wpfaw on wpfaw.WorkerFK = cp.CurrentFAWFK and wpfaw.ProgramFK = @ProgramFK
		left outer join Worker wfsw on wfsw.WorkerPK = wpfsw.WorkerFK
		left outer join Worker wfaw on wfaw.WorkerPK = wpfaw.WorkerFK
		left outer join cteSupervisors supfsw on wpfsw.SupervisorFK = supfsw.WorkerPK
		left outer join cteSupervisors supfaw on wpfaw.SupervisorFK = supfaw.WorkerPK
		where fr.ProgramFK = isnull(@ProgramFK, fr.ProgramFK)	
				and ReviewedBy is null
				and FormDate between FormReviewStartDate and isnull(FormReviewEndDate, current_timestamp)
				and FormDate between dateadd(day, @DaysToLoad*-1, isnull(FormReviewEndDate, current_timestamp)) and isnull(FormReviewEndDate, current_timestamp) 
				and case when fr.FormType = 'VL' then FormComplete else 1 end = 1
		union all 
		select FormReviewPK
			  ,case when len(rtrim(TrainingTitle)) <= 16 
					then TrainingTitle
				else left(TrainingTitle,16)+'…' 
				end as PC1ID
			  ,'Training' as codeFormName
			  ,convert(varchar(10),FormDate,101) as FormDate
			  ,FormFK
			  --,FormReviewCreateDate
			  ,convert(varchar(10),FormReviewCreateDate,101) as FormReviewCreateDate
			  ,FormReviewCreator
			  ,FormReviewEditDate
			  ,FormReviewEditor
			  ,fr.FormType
			  ,null as HVCaseFK
			  ,fr.ProgramFK
			  ,ReviewDateTime
			  ,ReviewedBy
			  ,FormReviewStartDate
			  ,FormReviewEndDate
			  ,'Training.aspx?TrainingPK='+rtrim(cast(TrainingPK as varchar(12))) as CaseHomeLink
			  ,'Training.aspx?TrainingPK='+rtrim(cast(TrainingPK as varchar(12))) as FormLink
			  ,isnull(FormReviewEndDate, current_timestamp) as EffectiveEndDate
			  ,dateadd(day, @DaysToLoad*-1, isnull(FormReviewEndDate, current_timestamp)) as EffectiveStartDate
			  ,null as WorkerName
			  ,null as SupervisorName
		from FormReview fr
		inner join FormReviewOptions fro on fro.FormType = fr.FormType and fro.ProgramFK = isnull(@ProgramFK,fro.ProgramFK)
		--inner join codeForm f on codeFormAbbreviation = fr.FormType
		inner join Training t on TrainingPK = FormFK and fr.FormType = 'TR' 
		where fr.ProgramFK = isnull(@ProgramFK, fr.ProgramFK)	
				and ReviewedBy is null
				and FormDate between FormReviewStartDate and isnull(FormReviewEndDate, current_timestamp)
				and FormDate between dateadd(day, @DaysToLoad*-1, isnull(FormReviewEndDate, current_timestamp)) and isnull(FormReviewEndDate, current_timestamp) 
				and IsExempt = 0
		union all 
		select FormReviewPK
			  ,null as PC1ID
			  ,codeFormName
			  ,convert(varchar(10),FormDate,101) as FormDate
			  ,FormFK
			  --,FormReviewCreateDate
			  ,convert(varchar(10),FormReviewCreateDate,101) as FormReviewCreateDate
			  ,FormReviewCreator
			  ,FormReviewEditDate
			  ,FormReviewEditor
			  ,fr.FormType
			  ,null as HVCaseFK
			  ,fr.ProgramFK
			  ,ReviewDateTime
			  ,ReviewedBy
			  ,FormReviewStartDate
			  ,FormReviewEndDate
			  ,'Supervision.aspx?AddSupervision=0&SupervisionPK=' + rtrim(cast(SupervisionPK as varchar(12))) + 
				'&WorkerFK=' + rtrim(cast(s.WorkerFK as varchar(12))) + 
				'&SupervisorFK=' + rtrim(cast(s.SupervisorFK as varchar(12))) as CaseHomeLink
			  ,'Supervision.aspx?AddSupervision=0&SupervisionPK=' + rtrim(cast(SupervisionPK as varchar(12))) + 
				'&WorkerFK=' + rtrim(cast(s.WorkerFK as varchar(12))) + 
				'&SupervisorFK=' + rtrim(cast(s.SupervisorFK as varchar(12))) as FormLink
			  ,isnull(FormReviewEndDate, current_timestamp) as EffectiveEndDate
			  ,dateadd(day, @DaysToLoad*-1, isnull(FormReviewEndDate, current_timestamp)) as EffectiveStartDate
			  ,ltrim(rtrim(w.LastName)) + ', ' + ltrim(rtrim(w.FirstName)) as WorkerName
			  ,ltrim(rtrim(sups.LastName)) + ', ' + ltrim(rtrim(sups.FirstName)) as SupervisorName
		from FormReview fr
		inner join FormReviewOptions fro on fro.FormType = fr.FormType and fro.ProgramFK = isnull(@ProgramFK,fro.ProgramFK)
		inner join codeForm f on codeFormAbbreviation = fr.FormType
		inner join Supervision s on SupervisionPK = FormFK and fr.FormType = 'SU'
		inner join WorkerProgram wp on wp.WorkerFK = s.WorkerFK and wp.ProgramFK = @ProgramFK
		inner join Worker w on w.WorkerPK = s.WorkerFK
		inner join Worker sups on sups.WorkerPK = s.SupervisorFK
		where fr.ProgramFK = isnull(@ProgramFK, fr.ProgramFK)	
				and ReviewedBy is null
				and FormDate between FormReviewStartDate and isnull(FormReviewEndDate, current_timestamp)
				and FormDate between dateadd(day, @DaysToLoad*-1, isnull(FormReviewEndDate, current_timestamp)) and isnull(FormReviewEndDate, current_timestamp) 
	)
	
	select * from cteFormReview
	order by 
	case when FormType='SC' then 1 
				  when FormType='PA' then 2
				  when FormType='KE' then 3
				  when FormType='PI' then 4
				  when FormType='SR' then 5
				  when FormType='ID' then 6
				  when FormType='VL' then 7
				  when FormType='IN' then 8
				  when FormType='LV' then 9
				  when FormType='TC' then 10
				  when FormType='PM' then 11
				  when FormType='DS' then 12
				  when FormType='FF' then 13
				  when FormType='TM' then 14
				  when FormType='AQ' then 15
				  when FormType='AS' then 16
				  when FormType='PS' then 17
				  when FormType='FU' then 18
				  when FormType='SU' then 19
				  when FormType='TR' then 20
				  when FormType='GR' then 21
			end
			, convert(date,FormDate)
			--,
			--PC1ID
			--,FormDate
				  --when fr.FormType='AQ' then 15
				  --when fr.FormType='AS' then 16
				  --when fr.FormType='DS' then 12
				  --when fr.FormType='FF' then 13
				  --when fr.FormType='FU' then 18
				  --when fr.FormType='GR' then 21
				  --when fr.FormType='ID' then 6
				  --when fr.FormType='IN' then 8
				  --when fr.FormType='KE' then 3
				  --when fr.FormType='LV' then 9
				  --when fr.FormType='PA' then 2
				  --when fr.FormType='PI' then 4
				  --when fr.FormType='PM' then 11
				  --when fr.FormType='PS' then 17
				  --when fr.FormType='SC' then 1 
				  --when fr.FormType='SR' then 5
				  --when fr.FormType='SU' then 19
				  --when fr.FormType='TC' then 10
				  --when fr.FormType='TM' then 14
				  --when fr.FormType='TR' then 20
				  --when fr.FormType='VL' then 7	
end

GO
