SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Devinder Singh Khalsa/Dar Chen>
-- Create date: <Apr/28/2015>
-- Description:	<This QA report gets you 'Kempe assessment completed but Not data entered '>
-- rspQAReport17 2, 'summary'	--- for summary page
-- rspQAReport17 2				--- for main report - location = 2
-- rspQAReport17 null			--- for main report for all locations
-- =============================================


CREATE procedure [dbo].[rspQAReport17] (@programfk varchar(max) = null
								 , @ReportType char(7) = null 

								  )
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

	-- table variable for holding Init Required Data
	declare	@tbl4QAReport17Detail table (HVCaseFK int
									   , [PC1ID] [char](13)
									   , KempeDate [datetime]
									   , PADate [datetime]
									   , CurrentFAW [varchar](200)
										);

	insert	into @tbl4QAReport17Detail
			(HVCaseFK
		   , PC1ID
		   , KempeDate
		   , PADate
		   , CurrentFAW
			)
			select cp.HVCaseFK
				  , cp.PC1ID
				  , h.KempeDate
				  , p.PADate
				  , ltrim(rtrim(faw.FirstName)) + ' ' + ltrim(rtrim(faw.LastName)) as CurrentFAW
			from	dbo.CaseProgram cp
			inner join dbo.SplitString(@programfk, ',') on cp.ProgramFK = ListItem
			inner join dbo.HVCase h on cp.HVCaseFK = h.HVCasePK
			inner join Preassessment as p on p.HVCaseFK = cp.HVCaseFK
											 and p.KempeDate is not null
			inner join Worker faw on faw.WorkerPK = cp.CurrentFAWFK
			where	h.KempeDate between dateadd(day, 1, dateadd(month, -3, @LastDayofPreviousMonth)) and @LastDayofPreviousMonth 
					-- and cp.DischargeDate is null;  --- case not closed
		
	--- rspQAReport17 2 ,'summary'
	if @ReportType = 'summary'
		begin 

			declare	@numOfAllKempes int = 0;
			set @numOfAllKempes = (select	count(PC1ID)
									from	@tbl4QAReport17Detail
								   );


			declare	@numOfKempesNotEntered int = 0;
			set @numOfKempesNotEntered = (select count(PC1ID)
												from @tbl4QAReport17Detail
												where HVCaseFK not in (select HVCaseFK
																	 	 from Kempe k
																	    inner join dbo.SplitString(@programfk, ',') on k.ProgramFK = ListItem
																	    where KempeDate between dateadd(day, 1, dateadd(month, -3, @LastDayofPreviousMonth)) and @LastDayofPreviousMonth 
																	  )
											);

			-- leave the following here
			if @numOfAllKempes is null
				set @numOfAllKempes = 0;

			if @numOfKempesNotEntered is null
				set @numOfKempesNotEntered = 0;


			declare	@tbl4QAReport17Summary table ([SummaryId] int
												, [SummaryText] [varchar](200)
												, [SummaryTotal] [varchar](100)
												 );

			insert	into @tbl4QAReport17Summary
					([SummaryId]
				   , [SummaryText]
				   , [SummaryTotal]
					)
			values	(17
				   , 'Kempe assessment completed in last three months but not data entered (N='
					 + convert(varchar, @numOfAllKempes) + ')'
				   , convert(varchar, @numOfKempesNotEntered) + ' ('
					 + convert(varchar, round(coalesce(cast(@numOfKempesNotEntered as float) * 100
													   / nullif(@numOfAllKempes, 0), 0), 0)) + '%)'
					);

			select	*
			from	@tbl4QAReport17Summary;	

		end;
	else
		begin


			select	PC1ID
				  , case when KempeDate is not null then convert(varchar(10), KempeDate, 101)
						 else ''
					end as KempeDate
				  , case when PADate is not null then convert(varchar(10), PADate, 101)
						 else ''
					end as PreassessmentFormDate
				  , CurrentFAW
			from	@tbl4QAReport17Detail
				where HVCaseFK not in (select HVCaseFK
									 	 from Kempe k
									    inner join dbo.SplitString(@programfk, ',') on k.ProgramFK = ListItem
									    where KempeDate between dateadd(day, 1, dateadd(month, -3, @LastDayofPreviousMonth)) and @LastDayofPreviousMonth)
			order by CurrentFAW
				  , PC1ID; 		

		end;
GO
