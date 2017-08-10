SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <October 1st, 2012>
-- Description:	<This QA report gets you 'Summary for all QA reports '>

-- rspQAReportSummary 31				--- for summary report - location = 2

-- =============================================

create procedure [dbo].[rspQAReportSummary_WithTimings](
@programfk    varchar(max)    = NULL
)


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @tbl4QAReportSummary table (
		[SummaryId] INT,
		[SummaryText] [varchar](200),
		[SummaryTotal] [varchar](100),
		TimeToRun datetime
	)
	declare @StartTime datetime

	set @StartTime = getdate()
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspQAReport1]') and type in (N'P', N'PC'))
		insert into @tbl4QAReportSummary 
		(
		SummaryId,
		SummaryText,
		SummaryTotal
		)
			exec rspQAReport1 @programfk, 'summary'	--- for summary page
	update @tbl4QAReportSummary 
	set TimeToRun = CONVERT(DateTime,GETDATE()-@StartTime)
	where SummaryID = '1'

	set @StartTime = getdate()
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspQAReport2]') and type in (N'P', N'PC'))
		insert into @tbl4QAReportSummary 
		(
		SummaryId,
		SummaryText,
		SummaryTotal
		)
			exec rspQAReport2 @programfk, 'summary'	--- for summary page
	update @tbl4QAReportSummary 
	set TimeToRun = CONVERT(DateTime,GETDATE()-@StartTime)
	where SummaryID = '2'

	set @StartTime = getdate()
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspQAReport3]') and type in (N'P', N'PC'))
		insert into @tbl4QAReportSummary 
		(
		SummaryId,
		SummaryText,
		SummaryTotal
		)
			exec rspQAReport3 @programfk, 'summary'	--- for summary page
	update @tbl4QAReportSummary 
	set TimeToRun = CONVERT(DateTime,GETDATE()-@StartTime)
	where SummaryID = '3'

	set @StartTime = getdate()
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspQAReport17]') and type in (N'P', N'PC'))
		insert into @tbl4QAReportSummary 
		(
		SummaryId,
		SummaryText,
		SummaryTotal
		)
			exec rspQAReport17 @programfk, 'summary'	--- for summary page
	update @tbl4QAReportSummary 
	set TimeToRun = CONVERT(DateTime,GETDATE()-@StartTime)
	where SummaryID = '17'

	set @StartTime = getdate()
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspQAReport4]') and type in (N'P', N'PC'))
		insert into @tbl4QAReportSummary 
		(
		SummaryId,
		SummaryText,
		SummaryTotal
		)
			exec rspQAReport4 @programfk, 'summary'	--- for summary page
	update @tbl4QAReportSummary 
	set TimeToRun = CONVERT(DateTime,GETDATE()-@StartTime)
	where SummaryID = '4'

	set @StartTime = getdate()
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspQAReport5]') and type in (N'P', N'PC'))
		insert into @tbl4QAReportSummary 
		(
		SummaryId,
		SummaryText,
		SummaryTotal
		)
			exec rspQAReport5 @programfk, 'summary'	--- for summary page
	update @tbl4QAReportSummary 
	set TimeToRun = CONVERT(DateTime,GETDATE()-@StartTime)
	where SummaryID = '5'

	set @StartTime = getdate()
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspQAReport6]') and type in (N'P', N'PC'))
		insert into @tbl4QAReportSummary 
		(
		SummaryId,
		SummaryText,
		SummaryTotal
		)
			exec rspQAReport6 @programfk, 'summary'	--- for summary page
	update @tbl4QAReportSummary 
	set TimeToRun = CONVERT(DateTime,GETDATE()-@StartTime)
	where SummaryID = '6'

	set @StartTime = getdate()
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspQAReport11]') and type in (N'P', N'PC'))
		insert into @tbl4QAReportSummary 
		(
		SummaryId,
		SummaryText,
		SummaryTotal
		)
			exec rspQAReport11 @programfk, 'summary'	--- for summary page
	update @tbl4QAReportSummary 
	set TimeToRun = CONVERT(DateTime,GETDATE()-@StartTime)
	where SummaryID = '11'

	set @StartTime = getdate()
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspQAReport12]') and type in (N'P', N'PC'))
		insert into @tbl4QAReportSummary 
		(
		SummaryId,
		SummaryText,
		SummaryTotal
		)
			exec rspQAReport12 @programfk, 'summary'	--- for summary page
	update @tbl4QAReportSummary 
	set TimeToRun = CONVERT(DateTime,GETDATE()-@StartTime)
	where SummaryID = '12'

	set @StartTime = getdate()
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspQAReport13]') and type in (N'P', N'PC'))
		insert into @tbl4QAReportSummary 
		(
		SummaryId,
		SummaryText,
		SummaryTotal
		)
			exec rspQAReport13 @programfk, 'summary'	--- for summary page
	update @tbl4QAReportSummary 
	set TimeToRun = CONVERT(DateTime,GETDATE()-@StartTime)
	where SummaryID = '13'

	set @StartTime = getdate()
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspQAReport14]') and type in (N'P', N'PC'))
		insert into @tbl4QAReportSummary 
		(
		SummaryId,
		SummaryText,
		SummaryTotal
		)
			exec rspQAReport14 @programfk, 'summary'	--- for summary page
	update @tbl4QAReportSummary 
	set TimeToRun = CONVERT(DateTime,GETDATE()-@StartTime)
	where SummaryID = '14'

	set @StartTime = getdate()
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspQAReport15]') and type in (N'P', N'PC'))
		insert into @tbl4QAReportSummary 
		(
		SummaryId,
		SummaryText,
		SummaryTotal
		)
			exec rspQAReport15 @programfk, 'summary'	--- for summary page
	update @tbl4QAReportSummary 
	set TimeToRun = CONVERT(DateTime,GETDATE()-@StartTime)
	where SummaryID = '15'

	set @StartTime = getdate()
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspQAReport16]') and type in (N'P', N'PC'))
		insert into @tbl4QAReportSummary 
		(
		SummaryId,
		SummaryText,
		SummaryTotal
		)
			exec rspQAReport16 @programfk, 'summary'	--- for summary page
	update @tbl4QAReportSummary 
	set TimeToRun = CONVERT(DateTime,GETDATE()-@StartTime)
	where SummaryID = '16'

	set @StartTime = getdate()
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspQAReport18]') and type in (N'P', N'PC'))
		insert into @tbl4QAReportSummary 
		(
		SummaryId,
		SummaryText,
		SummaryTotal
		)
			exec rspQAReport18 @programfk, 'summary'	--- for summary page
	update @tbl4QAReportSummary 
	set TimeToRun = CONVERT(DateTime,GETDATE()-@StartTime)
	where SummaryID = '18'

	set @StartTime = getdate()
	if exists (select * from sys.objects where object_id = object_id('[dbo].[rspQAReport19]') and type in (N'P', N'PC'))
		insert into @tbl4QAReportSummary 
		(
		SummaryId,
		SummaryText,
		SummaryTotal
		)
			exec rspQAReport19 @programfk, 'summary'	--- for summary page
	update @tbl4QAReportSummary 
	set TimeToRun = CONVERT(DateTime,GETDATE()-@StartTime)
	where SummaryID = '19'

--INSERT INTO @tbl4QAReportSummary exec rspQAReport1 @programfk, 'summary'	--- for summary page
--INSERT INTO @tbl4QAReportSummary EXEC rspQAReport2 @programfk, 'summary'	--- for summary page
--INSERT INTO @tbl4QAReportSummary EXEC rspQAReport3 @programfk, 'summary'	--- for summary page

--INSERT INTO @tbl4QAReportSummary EXEC rspQAReport17 @programfk, 'summary'	--- for summary page

--INSERT INTO @tbl4QAReportSummary EXEC rspQAReport4 @programfk, 'summary'	--- for summary page
--INSERT INTO @tbl4QAReportSummary EXEC rspQAReport5 @programfk, 'summary'	--- for summary page
--INSERT INTO @tbl4QAReportSummary EXEC rspQAReport6 @programfk, 'summary'	--- for summary page
--INSERT INTO @tbl4QAReportSummary EXEC rspQAReport11 @programfk, 'summary'	--- for summary page
--INSERT INTO @tbl4QAReportSummary EXEC rspQAReport12 @programfk, 'summary'	--- for summary page
--INSERT INTO @tbl4QAReportSummary EXEC rspQAReport13 @programfk, 'summary'	--- for summary page
--INSERT INTO @tbl4QAReportSummary EXEC rspQAReport14 @programfk, 'summary'	--- for summary page
--INSERT INTO @tbl4QAReportSummary EXEC rspQAReport15 @programfk, 'summary'	--- for summary page
--INSERT INTO @tbl4QAReportSummary EXEC rspQAReport16 @programfk, 'summary'	--- for summary page
--INSERT INTO @tbl4QAReportSummary EXEC rspQAReport18 @programfk, 'summary'	--- for summary page
--INSERT INTO @tbl4QAReportSummary EXEC rspQAReport19 @programfk, 'summary'	--- for summary page

select * FROM @tbl4QAReportSummary
END
GO
