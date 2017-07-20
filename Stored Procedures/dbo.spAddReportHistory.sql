SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddReportHistory](@ProgramFK int=NULL,
@ReportCategory varchar(50)=NULL,
@ReportFK int=NULL,
@ReportName char(100)=NULL,
@ReportType char(20)=NULL,
@TimeRun datetime=NULL,
@UserFK char(10)=NULL,
@ReportFK_old int=NULL)
AS
INSERT INTO ReportHistory(
ProgramFK,
ReportCategory,
ReportFK,
ReportName,
ReportType,
TimeRun,
UserFK,
ReportFK_old
)
VALUES(
@ProgramFK,
@ReportCategory,
@ReportFK,
@ReportName,
@ReportType,
@TimeRun,
@UserFK,
@ReportFK_old
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
