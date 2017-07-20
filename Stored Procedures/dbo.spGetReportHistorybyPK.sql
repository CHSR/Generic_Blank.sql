SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetReportHistorybyPK]

(@ReportHistoryPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM ReportHistory
WHERE ReportHistoryPK = @ReportHistoryPK
GO
