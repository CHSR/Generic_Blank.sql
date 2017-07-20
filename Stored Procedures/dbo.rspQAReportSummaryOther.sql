SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <October 1st, 2012>
-- Description:	<This QA report gets you 'Summary for all QA reports 7 thru 10 '>

-- rspQAReportSummaryOther 31				--- for summary report - location = 2

-- =============================================

CREATE PROCEDURE [dbo].[rspQAReportSummaryOther](
@programfk    varchar(max)    = NULL
)


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


DECLARE @tbl4QAReportSummaryOther TABLE(
	[SummaryId] INT,
	[SummaryText] [varchar](200),
	[MissingCases] [varchar](200),
	[NotOnTimeCases] [varchar](200),
	[SummaryTotal] [varchar](100)
)



INSERT INTO @tbl4QAReportSummaryOther EXEC rspQAReport7 @programfk, 'summary'	--- for summary page
INSERT INTO @tbl4QAReportSummaryOther EXEC rspQAReport8 @programfk, 'summary'	--- for summary page

INSERT INTO @tbl4QAReportSummaryOther EXEC rspQAReport9 @programfk, 'summary'	--- for summary page
INSERT INTO @tbl4QAReportSummaryOther EXEC rspQAReport10 @programfk, 'summary'	--- for summary page



SELECT * FROM @tbl4QAReportSummaryOther
END
GO
