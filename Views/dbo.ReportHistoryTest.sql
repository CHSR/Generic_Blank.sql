SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[ReportHistoryTest]
AS
SELECT     ProgramFK, ReportFK, TimeRun, LOWER(UserFK) AS UserName
FROM         dbo.ReportHistory
GO
