SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <October 1st, 2012>
-- Description:	<This QA report gets you 'Target Child IDs for Active Cases '>
-- rspQAReport5 1, 'summary'	--- for summary page
-- rspQAReport5 31			--- for main report - location = 2
-- rspQAReport5 null			--- for main report for all locations
-- =============================================

CREATE procedure [dbo].[rspQAReport5]
(
    @programfk  varchar(max)    = null,
    @ReportType char(7)         = null
)
as
	if @programfk is null
	begin
		select @programfk = substring((select ',' + ltrim(rtrim(str(HVProgramPK)))
										   from HVProgram
										   for xml path ('')), 2, 8000)
	end

	set @programfk = replace(@programfk, '"', '')

	-- Last Day of Previous Month 
	declare @LastDayofPreviousMonth datetime
	set @LastDayofPreviousMonth = dateadd(s, -1, dateadd(mm, datediff(m, 0, getdate()), 0)) -- analysis point

	--Set @LastDayofPreviousMonth = '05/31/2012'

	-- table variable for holding Init Required Data
	declare @tbl4QAReport5Detail table(
		HVCasePK int,
		[PC1ID] [char](13),
		TCDOB [datetime],
		FormDueDate [datetime],
		Worker [varchar](200),
		currentLevel [varchar](50),
		IntakeDate [datetime],
		DischargeDate [datetime],
		CaseProgress [NUMERIC](3),
		IntakeLevel [char](1),
		TCNumber int,
		MultipleBirth [char](3)
	)

	insert into @tbl4QAReport5Detail (
			   HVCasePK
			 , [PC1ID]
			 , TCDOB
			 , FormDueDate
			 , Worker
			 , currentLevel
			 , IntakeDate
			 , DischargeDate
			 , CaseProgress
			 , IntakeLevel
			 , TCNumber
			 , MultipleBirth
			   )
		select
			  h.HVCasePK
			, cp.PC1ID
			, case
				  when h.tcdob is not null then
					  h.tcdob
				  else
					  h.edc
			  end as tcdob
			, case
				  when (h.IntakeLevel = '1')
					  then
						  case
							  when (h.tcdob is null) then dateadd(mm, 1, h.edc) else dateadd(mm, 1, h.tcdob) end
				  else
					  dateadd(mm, 1, h.IntakeDate)
			  end as FormDueDate
			,
			--	Form due date is 30.44 days after intake if postnatal at intake or 30.44 days after TC DOB if prenatal at intake
			----case
			----   when (h.tcdob is not NULL AND h.tcdob <= h.IntakeDate) THEN -- postnatal
			----	   dateadd(mm,1,h.IntakeDate) 
			----   when (h.tcdob is not NULL AND h.tcdob > h.IntakeDate) THEN -- pretnatal
			----				dateadd(mm,1,h.tcdob) 
			----   when (h.tcdob is NULL AND h.edc > h.IntakeDate) THEN -- pretnatal
			----				dateadd(mm,1,h.edc) 					
			----end as FormDueDate,

			ltrim(rtrim(fsw.firstname)) + ' ' + ltrim(rtrim(fsw.lastname)) as worker
			, codeLevel.LevelName
			, h.IntakeDate
			, cp.DischargeDate
			, h.CaseProgress
			, h.IntakeLevel
			, h.TCNumber
			, case when h.TCNumber > 1 then 'Yes' else 'No' end
			  as [MultipleBirth]

			from dbo.CaseProgram cp
				inner join dbo.SplitString(@programfk, ',') on cp.programfk = listitem
				left join codeLevel on cp.CurrentLevelFK = codeLevel.codeLevelPK
				inner join dbo.HVCase h on cp.HVCaseFK = h.HVCasePK
				inner join worker fsw on cp.CurrentFSWFK = fsw.workerpk

			where ((h.IntakeDate <= dateadd(M, -1, @LastDayofPreviousMonth))
						and (h.IntakeDate is not null))
				 and (cp.DischargeDate is null
						or cp.DischargeDate > @LastDayofPreviousMonth)
				 and (((@LastDayofPreviousMonth >= dateadd(M, 1, h.edc))
						and (h.tcdob is null))
				 or ((@LastDayofPreviousMonth >= dateadd(M, 1, h.tcdob))
						and (h.edc is null)))
			order by cp.OldID -- h.IntakeDate 

	-- to get accurate count of case
	update @tbl4QAReport5Detail
		set TCNumber = 1
		where TCNumber = 0

	-- if you execute the following statement, you may not see all records i.e. two rows for twins etc, there is only one row for twin etc
	-- so number of records in the resultset will be less
	--SELECT * FROM @tbl4QAReport5Detail


	--- rspQAReport5 31 ,'summary'

	if @ReportType = 'summary'
	begin

		declare @numOfActiveIntakeCases int = 0

		-- Note: We using sum on TCNumber to get correct number of cases, as there may be twins etc.
		set @numOfActiveIntakeCases = (select count(HVCasePK) -- count(*) -- sum(TCNumber)
									from @tbl4QAReport5Detail)

		declare @numOfAllCasesWithTCID int = 0
		set @numOfAllCasesWithTCID = (
									   select count(HVCasePK)
										   from @tbl4QAReport5Detail
										   where HVCasePK not in
												(
												 select HVCaseFK
													 from TCID T
													 -- inner join dbo.SplitString(@programfk, ',') on T.programfk = listitem
												)
									  )

		-- leave the following here
		if @numOfActiveIntakeCases is null
			set @numOfActiveIntakeCases = 0

		if @numOfAllCasesWithTCID is null
			set @numOfAllCasesWithTCID = 0

		declare @tbl4QAReport5Summary table(
			[SummaryId] int,
			[SummaryText] [varchar](200),
			[SummaryTotal] [varchar](100)
		)

		insert into @tbl4QAReport5Summary ([SummaryId]
										 , [SummaryText]
										 , [SummaryTotal])
			values (5, 'Target Child IDs for Active Cases (N=' + convert(varchar, @numOfActiveIntakeCases) + ')'
				   , convert(varchar, @numOfAllCasesWithTCID) + ' (' + convert(varchar, round(coalesce(cast(
					   @numOfAllCasesWithTCID as float) * 100 / nullif(@numOfActiveIntakeCases, 0), 0), 0)) + '%)'
				   )

		select *
			from @tbl4QAReport5Summary

	end
	else
	begin
		select
			  [PC1ID]
			, convert(varchar(10), TCDOB, 101) as TCDOB
			, convert(varchar(10), IntakeDate, 101) as IntakeDate
			, convert(varchar(10), FormDueDate, 101) as FormDueDate
			, Worker
			, MultipleBirth
			, currentLevel
			from @tbl4QAReport5Detail
			where HVCasePK not in
				 (
				  select HVCaseFK
					  from @tbl4QAReport5Detail qa
						  inner join TCID T on T.HVCaseFK = qa.HVCasePK
						  -- inner join dbo.SplitString(@programfk, ',') on T.programfk = listitem
				 )

			order by Worker
				   , PC1ID


	end
GO
