SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditReportHistory](@ReportHistoryPK int=NULL,
@ProgramFK int=NULL,
@ReportCategory varchar(50)=NULL,
@ReportFK int=NULL,
@ReportName char(100)=NULL,
@ReportType char(20)=NULL,
@TimeRun datetime=NULL,
@UserFK char(10)=NULL,
@ReportFK_old int=NULL)
AS
UPDATE ReportHistory
SET 
ProgramFK = @ProgramFK, 
ReportCategory = @ReportCategory, 
ReportFK = @ReportFK, 
ReportName = @ReportName, 
ReportType = @ReportType, 
TimeRun = @TimeRun, 
UserFK = @UserFK, 
ReportFK_old = @ReportFK_old
WHERE ReportHistoryPK = @ReportHistoryPK
GO
