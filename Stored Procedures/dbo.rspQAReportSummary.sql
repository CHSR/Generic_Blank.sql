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

CREATE procedure [dbo].[rspQAReportSummary](
@programfk    varchar(max)    = NULL
)with recompile


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

DECLARE @tbl4QAReportSummary TABLE(
	[SummaryId] INT,
	[SummaryText] [varchar](200),
	[SummaryTotal] [varchar](100)
)

INSERT INTO @tbl4QAReportSummary EXEC rspQAReport1 @programfk, 'summary'	--- for summary page
INSERT INTO @tbl4QAReportSummary EXEC rspQAReport2 @programfk, 'summary'	--- for summary page
INSERT INTO @tbl4QAReportSummary EXEC rspQAReport3 @programfk, 'summary'	--- for summary page

INSERT INTO @tbl4QAReportSummary EXEC rspQAReport17 @programfk, 'summary'	--- for summary page

INSERT INTO @tbl4QAReportSummary EXEC rspQAReport4 @programfk, 'summary'	--- for summary page
INSERT INTO @tbl4QAReportSummary EXEC rspQAReport5 @programfk, 'summary'	--- for summary page
INSERT INTO @tbl4QAReportSummary EXEC rspQAReport6 @programfk, 'summary'	--- for summary page
INSERT INTO @tbl4QAReportSummary EXEC rspQAReport11 @programfk, 'summary'	--- for summary page
INSERT INTO @tbl4QAReportSummary EXEC rspQAReport12 @programfk, 'summary'	--- for summary page
INSERT INTO @tbl4QAReportSummary EXEC rspQAReport13 @programfk, 'summary'	--- for summary page
INSERT INTO @tbl4QAReportSummary EXEC rspQAReport14 @programfk, 'summary'	--- for summary page
INSERT INTO @tbl4QAReportSummary EXEC rspQAReport15 @programfk, 'summary'	--- for summary page
INSERT INTO @tbl4QAReportSummary EXEC rspQAReport16 @programfk, 'summary'	--- for summary page
INSERT INTO @tbl4QAReportSummary EXEC rspQAReport18 @programfk, 'summary'	--- for summary page
INSERT INTO @tbl4QAReportSummary EXEC rspQAReport19 @programfk, 'summary'	--- for summary page

select * FROM @tbl4QAReportSummary
END
GO
