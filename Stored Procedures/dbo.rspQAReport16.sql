SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <October 24, 2012>
-- Description:	<This QA report gets you '16. Cases with Forms to be reviewed '>
-- rspQAReport16 12, 'summary'	--- for summary page
-- rspQAReport16 12			--- for main report - location = 2
-- rspQAReport16 null			--- for main report for all locations
-- Edit date: 10/11/2013 CP - workerprogram was NOT duplicating cases when worker transferred
--			  09/02/2014 JR remove table variable and use cte instead to alleviate performance problem
-- =============================================


CREATE procedure [dbo].[rspQAReport16]
(
    @programfk  varchar(max)    = null,
    @ReportType char(7)         = null
)
as
	if @programfk is null
	begin
		select @programfk = substring((select ','+ltrim(rtrim(str(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end

	set @programfk = replace(@programfk,'"','')

	-- Last Day of Previous Month 
	declare @LastDayofPreviousMonth datetime
	set @LastDayofPreviousMonth = dateadd(s,-1,dateadd(mm,datediff(m,0,getdate()),0)) -- analysis point

	--Set @LastDayofPreviousMonth = '05/31/2012'

	declare @Back2MonthsFromAnalysisPoint datetime
	set @Back2MonthsFromAnalysisPoint = dateadd(m,-2,@LastDayofPreviousMonth)

	;
	with cteMain
	as (select h.HVCasePK
			  ,cp.PC1ID
			  ,case
				   when h.tcdob is not null then
					   h.tcdob
				   else
					   h.edc
			   end as tcdob
			  --	Form due date is 30.44 days after intake if postnatal at intake or 30.44 days after TC DOB if prenatal at intake
			  ,case
				   when (h.tcdob is not null and h.tcdob <= h.IntakeDate) then -- postnatal
					   dateadd(mm,1,h.IntakeDate)
				   when (h.tcdob is not null and h.tcdob > h.IntakeDate) then -- pretnatal
					   dateadd(mm,1,h.tcdob)
				   when (h.tcdob is null and h.edc > h.IntakeDate) then -- pretnatal
					   dateadd(mm,1,h.edc)
			   end as FormDueDate
			  ,ltrim(rtrim(fsw.firstname))+' '+ltrim(rtrim(fsw.lastname)) as worker
			  ,codeLevel.LevelName as currentlevel
			  ,h.IntakeDate
			  ,cp.DischargeDate
			  ,h.CaseProgress
			  ,h.IntakeLevel
			  ,h.TCNumber
			  ,case
				   when h.TCNumber > 1 then
					   'Yes'
				   else
					   'No'
			   end as [MultipleBirth]
			  ,case
				   when h.tcdob is not null then
					   datediff(dd,h.tcdob,@LastDayofPreviousMonth)
				   else
					   datediff(dd,h.edc,@LastDayofPreviousMonth)
			   end as XDateAge
			  ,'' as TCName
			  ,'' as DaysSinceLastMedicalFormEdit
			  ,datediff(dd,h.IntakeDate,@LastDayofPreviousMonth) as LengthInProgress
			  ,cp.CurrentLevelDate
			  ,ltrim(rtrim(sup.firstname))+' '+ltrim(rtrim(sup.lastname)) as Supervisor
			from dbo.CaseProgram cp
				inner join dbo.SplitString(@programfk,',') on cp.programfk = listitem
				left join codeLevel on cp.CurrentLevelFK = codeLevel.codeLevelPK
				inner join dbo.HVCase h on cp.HVCaseFK = h.HVCasePK
				inner join workerprogram wp on wp.workerfk = isnull(CurrentFSWFK, CurrentFAWFK) and wp.ProgramFK = @programfk
				inner join worker fsw on cp.CurrentFSWFK = fsw.workerpk 
				left join worker sup on sup.workerpk = wp.supervisorfk
			where ((h.IntakeDate <= dateadd(M,-1,@LastDayofPreviousMonth))
				 and (h.IntakeDate is not null))
				 and (cp.DischargeDate is null
				 or cp.DischargeDate > @LastDayofPreviousMonth)
			-- order by h.HVCasePK
	)
	-- rspQAReport16 35 ,'summary'
	-- rspQAReport16 35 ,'detail'

	--SELECT * FROM @tbl4QAReport16Detail

	,
	cteFormsRequiringSupervisorReview
	as (select pc1id
			  ,codeFormName
			  ,FormDate
			  ,fro.programfk
			  ,FormReviewStartDate
			from FormReview fr
				inner join FormReviewOptions fro on fro.FormType = fr.FormType and fro.ProgramFK = fr.ProgramFK
				left join codeForm on codeForm.codeFormAbbreviation = fr.formtype
				left join caseprogram on caseprogram.hvcasefk = fr.hvcasefk and CaseProgram.ProgramFK = @programfk
				left join workerprogram on workerprogram.workerfk = case CurrentFSWFK
							 when CurrentFSWFK then
								 CurrentFSWFK
							 else
								 CurrentFAWFK
						 end
				left join worker on worker.workerpk = workerprogram.supervisorfk and WorkerProgram.ProgramFK = @programfk
				inner join dbo.SplitString(@programfk,',') on fr.programfk = listitem
			where ReviewedBy is null
				 and FormDate between FormReviewStartDate and isnull(FormReviewEndDate,current_timestamp)
	),
	cteFormsToBeReviewCount
	as (select HVCasePK
			  ,count(qa1.PC1ID) as NumOfFormsToBeReviewed

			from cteMain qa1
				inner join cteFormsRequiringSupervisorReview fr on fr.PC1ID = qa1.PC1ID
			group by HVCasePK
	)
	select qa1.HVCasePK
		  ,PC1ID
		  ,NumOfFormsToBeReviewed
		  ,Supervisor
		  ,Worker
		  ,currentLevel
		into #tbl4QAReport16 -- Used temp table, because insert same into a variable table name like @tbl4QAReport14, SQL Server was taking 5 secs to complete ... Khalsa
		from cteFormsToBeReviewCount ft
			left join cteMain qa1 on qa1.HVCasePK = ft.HVCasePK
		order by Supervisor
				,Worker



	-- rspQAReport16 12 ,'summary'

	if @ReportType = 'summary'
	begin
		declare @numOfALLScreens int = 0
		set @numOfALLScreens = (select count(HVCasePK)
									from dbo.CaseProgram cp
										inner join dbo.SplitString(@programfk,',') on cp.programfk = listitem
										left join codeLevel on cp.CurrentLevelFK = codeLevel.codeLevelPK
										inner join dbo.HVCase h on cp.HVCaseFK = h.HVCasePK
										inner join worker fsw on cp.CurrentFSWFK = fsw.workerpk
										left join workerprogram on workerprogram.workerfk = case CurrentFSWFK
													 when CurrentFSWFK then
														 CurrentFSWFK
													 else
														 CurrentFAWFK
												 end
										left join worker sup on sup.workerpk = workerprogram.supervisorfk and workerprogram.ProgramFK = @programfk
									where ((h.IntakeDate <= dateadd(M,-1,@LastDayofPreviousMonth))
										 and (h.IntakeDate is not null))
										 and (cp.DischargeDate is null
										 or cp.DischargeDate > @LastDayofPreviousMonth))
									-- from @tbl4QAReport16Detail)

		declare @numOfCasesOnLevelX int = 0
		set @numOfCasesOnLevelX = (select count(HVCasePK)
									   from #tbl4QAReport16)

		drop table #tbl4QAReport16

		-- leave the following here
		if @numOfALLScreens is null
			set @numOfALLScreens = 0

		if @numOfCasesOnLevelX is null
			set @numOfCasesOnLevelX = 0


		declare @tbl4QAReport16Summary table(
			[SummaryId] int,
			[SummaryText] [varchar](200),
			[SummaryTotal] [varchar](100)
		)

		insert into @tbl4QAReport16Summary ([SummaryId]
										   ,[SummaryText]
										   ,[SummaryTotal])
			values (16,'Cases with Forms to be reviewed (N='+convert(varchar,@numOfALLScreens)+')',convert(varchar,@numOfCasesOnLevelX)+' ('+convert(varchar,round(coalesce(cast(@numOfCasesOnLevelX as float)*100/nullif(@numOfALLScreens,0),0),0))+'%)')

		select *
			from @tbl4QAReport16Summary

	end
	else
	begin
		select PC1ID
			  ,NumOfFormsToBeReviewed
			  ,Supervisor
			  ,Worker
			  ,currentLevel

			from #tbl4QAReport16
		--ORDER BY NumOfFormsToBeReviewed DESC


		drop table #tbl4QAReport16

	--- rspQAReport16 12 ,'summary'

	end
GO
