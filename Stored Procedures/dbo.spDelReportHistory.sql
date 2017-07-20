SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelReportHistory](@ReportHistoryPK int)

AS


DELETE 
FROM ReportHistory
WHERE ReportHistoryPK = @ReportHistoryPK
GO
