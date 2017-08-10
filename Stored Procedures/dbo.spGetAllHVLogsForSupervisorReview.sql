SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jay Robohn
-- Create date: 2017-05-25                                    
-- Description:	Gets a list of all HV Logs to be reviewed that haven't been reviewed yet and
--				fall within the range of dates for that form's review option row.
-- exec spGetAllHVLogsForSupervisorReview 1,120,null
-- exec spGetAllHVLogsForSupervisorReview 4,120,null
-- 
-- =============================================
CREATE procedure [dbo].[spGetAllHVLogsForSupervisorReview]
	(
	@ProgramFK int
	, @DaysToLoad int = 30
	, @SupervisorFK int = null
	)
	
as
begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	--erfering with SELECT statements.
	set nocount on;

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
	),
	cteFormReview as 
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
			  ,case when FormComplete = 0 then 'Pending/Partial' else 'Ready For Review' end as HVLogStatus
			  ,'CaseHome.aspx?pc1id='+PC1ID as CaseHomeLink
			  ,case when VisitStartTime >= '2017-04-01' then 'HomeVisitLog.aspx?pc1id='+PC1ID+ '&hvlogpk=' + convert(varchar,FormFK) 
					else 'HomeVisitLogOld.aspx?pc1id='+PC1ID+ '&hvlogpk=' + convert(varchar,FormFK) end as FormLink
			  ,isnull(FormReviewEndDate, current_timestamp) as EffectiveEndDate
			  ,dateadd(day, @DaysToLoad*-1, isnull(FormReviewEndDate, current_timestamp)) as EffectiveStartDate
			  ,ltrim(rtrim(wvisitorfsw.LastName)) + ', ' + ltrim(rtrim(wvisitorfsw.FirstName)) as HomeVisitorName
			  ,case when cp.CurrentFSWFK is not null then ltrim(rtrim(wfsw.LastName)) + ', ' + ltrim(rtrim(wfsw.FirstName)) 
					when cp.CurrentFAWFK is not null then ltrim(rtrim(wfaw.LastName)) + ', ' + ltrim(rtrim(wfaw.FirstName)) 
					else '*Unassigned*'
				end as WorkerName
			  ,case when cp.CurrentFSWFK is not null then supfsw.WorkerName
					when cp.CurrentFAWFK is not null then supfaw.WorkerName
					else '*Unassigned*'
				end as SupervisorName
		from FormReview fr
		inner join FormReviewOptions fro on fro.FormType = fr.FormType and fro.ProgramFK = isnull(@ProgramFK,fro.ProgramFK)
		inner join codeForm f on codeFormAbbreviation = fr.FormType
		inner join HVLog hl on hl.HVCaseFK = fr.HVCaseFK and hl.HVLogPK = fr.FormFK
		inner join CaseProgram cp on cp.HVCaseFK = fr.HVCaseFK
									and cp.ProgramFK = fr.ProgramFK
		left outer join WorkerProgram wpfsw on wpfsw.WorkerFK = cp.CurrentFSWFK and wpfsw.ProgramFK = @ProgramFK
		left outer join WorkerProgram wpfaw on wpfaw.WorkerFK = cp.CurrentFAWFK and wpfaw.ProgramFK = @ProgramFK
		left outer join WorkerProgram wpvisitorfsw on wpvisitorfsw.WorkerFK = hl.FSWFK and wpvisitorfsw.ProgramFK = @ProgramFK
		left outer join Worker wfsw on wfsw.WorkerPK = wpfsw.WorkerFK
		left outer join Worker wfaw on wfaw.WorkerPK = wpfaw.WorkerFK
		left outer join Worker wvisitorfsw on wvisitorfsw.WorkerPK = wpvisitorfsw.WorkerFK
		left outer join cteSupervisors supfsw on wpfsw.SupervisorFK = supfsw.WorkerPK
		left outer join cteSupervisors supfaw on wpfaw.SupervisorFK = supfaw.WorkerPK
		where fr.ProgramFK = isnull(@ProgramFK, fr.ProgramFK)
				and fr.FormType = 'VL'
				and FormComplete = 0
				and FormDate between FormReviewStartDate and isnull(FormReviewEndDate, current_timestamp)
				and FormDate between dateadd(day, @DaysToLoad*-1, isnull(FormReviewEndDate, current_timestamp)) and isnull(FormReviewEndDate, current_timestamp) 
	)
	
	select * from cteFormReview
	order by convert(date,FormDate)

end
GO
