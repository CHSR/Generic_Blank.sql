SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <October 1st, 2012>
-- Description:	<This QA report gets you 'Target Child Medical forms for Active Cases '>
-- rspQAReport6 5, 'summary'	--- for summary page
-- rspQAReport6 31			--- for main report - location = 2
-- rspQAReport6 null			--- for main report for all locations

-- Because of transfer cases, JH said that don't consider ProgramFK for medical forms ... Khalsa 1/27/2014
-- =============================================


CREATE procedure [dbo].[rspQAReport6] (@programfk varchar(max) = null
								, @ReportType char(7) = null 

								 )
	with recompile
as
	if @programfk is null
		begin
			select	@programfk = substring((select	',' + ltrim(rtrim(str(HVProgramPK)))
											from	HVProgram
										   for
											xml	path('')
										   ), 2, 8000);
		end;

	set @programfk = replace(@programfk, '"', '');

-- Last Day of Previous Month 
	declare	@LastDayofPreviousMonth datetime; 
	set @LastDayofPreviousMonth = dateadd(s, -1, dateadd(mm, datediff(m, 0, getdate()), 0)); -- analysis point

--Set @LastDayofPreviousMonth = '05/31/2012'

-- table variable for holding Init Required Data
	declare	@tbl4QAReport6Detail table (HVCasePK int
									  , [PC1ID] [char](13)
									  , TCDOB [datetime]
									  , FormDueDate [datetime]
									  , Worker [varchar](200)
									  , currentLevel [varchar](50)
									  , IntakeDate [datetime]
									  , DischargeDate [datetime]
									  , CaseProgress [numeric](3)
									  , IntakeLevel [char](1)
									  , TCNumber int
									  , TCIDPK int
									  , TCName [varchar](500)
									  , MultipleBirth [char](3)
									   );

	insert	into @tbl4QAReport6Detail
			(HVCasePK
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
		   , TCIDPK
		   , TCName
		   , MultipleBirth
			)
			select	h.HVCasePK
				  , cp.PC1ID
				  , case when h.TCDOB is not null then h.TCDOB
						 else h.EDC
					end as tcdob
				  , case when (h.IntakeLevel = '1') then case when (h.TCDOB is null) then dateadd(mm, 1, h.EDC)
															  else dateadd(mm, 1, h.TCDOB)
														 end
						 else dateadd(mm, 1, h.IntakeDate)
					end as FormDueDate
				  ,
	
	--	Form due date is 30.44 days after intake if postnatal at intake or 30.44 days after TC DOB if prenatal at intake
	--case
	--   when (h.tcdob is not NULL AND h.tcdob <= h.IntakeDate) THEN -- postnatal
	--	   dateadd(mm,1,h.IntakeDate) 
	--   when (h.tcdob is not NULL AND h.tcdob > h.IntakeDate) THEN -- pretnatal
	--				dateadd(mm,1,h.tcdob) 
	--   when (h.tcdob is NULL AND h.edc > h.IntakeDate) THEN -- pretnatal
	--				dateadd(mm,1,h.edc) 					
	--end as FormDueDate,
					ltrim(rtrim(fsw.FirstName)) + ' ' + ltrim(rtrim(fsw.LastName)) as worker
				  , codeLevel.LevelName
				  , h.IntakeDate
				  , cp.DischargeDate
				  , h.CaseProgress
				  , h.IntakeLevel
				  , h.TCNumber
				  , T.TCIDPK
				  , rtrim(T.TCLastName) + ', ' + rtrim(T.TCFirstName) [TCName]
				  , case when T.MultipleBirth = 1 then 'Yes'
						 else 'No'
					end as [MultipleBirth]
			from	dbo.CaseProgram cp
			inner join dbo.SplitString(@programfk, ',') on cp.ProgramFK = ListItem
			left join codeLevel on cp.CurrentLevelFK = codeLevel.codeLevelPK
			inner join dbo.HVCase h on cp.HVCaseFK = h.HVCasePK
			inner join Worker fsw on cp.CurrentFSWFK = fsw.WorkerPK
			-- JOIN TO TCID to get each child for the case
			left join TCID T on T.HVCaseFK = h.HVCasePK
			where	((h.IntakeDate <= dateadd(M, -1, @LastDayofPreviousMonth))
					 and (h.IntakeDate is not null)
					)
					and (cp.DischargeDate is null
						 or cp.DischargeDate > @LastDayofPreviousMonth
						)
			-- as per John, make it one month period (not 45 days)
					and (((@LastDayofPreviousMonth >= dateadd(M, 1, h.EDC))
						  and (h.TCDOB is null)
						 )
						 or ((@LastDayofPreviousMonth >= dateadd(M, 1, h.TCDOB))
							 and (h.EDC is null)
							)
						)  
			-- adding 45 days (not just one month)
			 --AND (( (@LastDayofPreviousMonth >= dateadd(day,15,dateadd(M, 1, h.edc)) ) AND (h.tcdob IS NULL) ) OR ( (@LastDayofPreviousMonth >= dateadd(day,15,dateadd(M, 1, h.tcdob)) ) AND (h.edc IS NULL) ) )  
					and (T.TCDOD > @LastDayofPreviousMonth
						 or T.TCDOD is null
						);

			-- to get accurate count of case
	update	@tbl4QAReport6Detail
	set		TCNumber = 1
	where	TCNumber = 0;
	
			-- if you execute the following statement, you may not see all records i.e. two rows for twins etc, there is only one row for twin etc
			-- so number of records in the resultset will be less
			--SELECT * FROM @tbl4QAReport6Detail


	update	@tbl4QAReport6Detail
	set		TCName = ''
	where	TCName is null;

	
--- rspQAReport6 31 ,'summary'

	if @ReportType = 'summary'
		begin 

			declare	@numOfALLScreens int = 0;

			-- Note: We using sum on TCNumber to get correct number of cases, as there may be twins etc.
			set @numOfALLScreens = (select	count(HVCasePK)
									from	@tbl4QAReport6Detail
								   );  

			declare	@numOfActiveIntakeCases int = 0;
			set @numOfActiveIntakeCases = (select	count(HVCasePK)
										   from		@tbl4QAReport6Detail
										   where	HVCasePK not in (select	HVCaseFK
																	 from TCMedical T
																	 -- because of transfer cases, JH said that don't consider ProgramFK for medical forms ... Khalsa 1/27/2014
																	 --inner join dbo.SplitString(@programfk,',') on T.programfk = listitem  
																	 )
										  );

			-- leave the following here
			if @numOfALLScreens is null
				set @numOfALLScreens = 0;

			if @numOfActiveIntakeCases is null
				set @numOfActiveIntakeCases = 0;

			declare	@tbl4QAReport6Summary table ([SummaryId] int
											   , [SummaryText] [varchar](200)
											   , [SummaryTotal] [varchar](100)
												);

			insert	into @tbl4QAReport6Summary
					([SummaryId]
				   , [SummaryText]
				   , [SummaryTotal]
					)
			values	(6
				   , 'Target Child Medical for Active Cases (N=' + convert(varchar, @numOfALLScreens) + ')'
				   , convert(varchar, @numOfActiveIntakeCases) + ' ('
					 + convert(varchar, round(coalesce(cast(@numOfActiveIntakeCases as float) * 100
													   / nullif(@numOfALLScreens, 0), 0), 0)) + '%)'
					);

			select	*
			from	@tbl4QAReport6Summary;	

		end;
	else
		begin
----SELECT 
----	[PC1ID],
----	convert(varchar(10),TCDOB,101) as TCDOB,
----	convert(varchar(10),IntakeDate,101) as IntakeDate,
----	convert(varchar(10),FormDueDate,101) as FormDueDate,
----	Worker,
----	MultipleBirth,
----	currentLevel 
---- FROM @tbl4QAReport6Detail	
----WHERE HVCasePK NOT IN 
----	(
----	SELECT HVCaseFK FROM TCMedical T 
----	inner join dbo.SplitString(@programfk,',') on T.programfk = listitem	
----	)

----ORDER BY Worker, PC1ID 	

			--select	[PC1ID]
			--	  , convert(varchar(10), TCDOB, 101) as TCDOB
			--	  , convert(varchar(10), IntakeDate, 101) as IntakeDate
			--	  , convert(varchar(10), FormDueDate, 101) as FormDueDate
			--	  , Worker
			--	  , MultipleBirth
			--	  , currentLevel
			--into	#tbl4QAReport6 -- Used temp table, because other way,  SQL Server was taking 3 secs to complete ... Khalsa
			--from	@tbl4QAReport6Detail qa6
			--left join TCMedical T on T.HVCaseFK = qa6.HVCasePK
			--where	T.HVCaseFK is null; 
			
			select [PC1ID]
				  , convert(varchar(10), TCDOB, 101) as TCDOB
				  , convert(varchar(10), IntakeDate, 101) as IntakeDate
				  , convert(varchar(10), FormDueDate, 101) as FormDueDate
				  , Worker
				  , MultipleBirth
				  , currentLevel
			into	#tbl4QAReport6 -- Used temp table, because other way,  SQL Server was taking 3 secs to complete ... Khalsa
			from @tbl4QAReport6Detail
			where HVCasePK not in (select HVCaseFK
									 from TCMedical T
								  )
 
 			select	*
			from	#tbl4QAReport6
			order by Worker
				  , PC1ID; 	

-- rspQAReport6 31, 'summary'
		end;
GO
