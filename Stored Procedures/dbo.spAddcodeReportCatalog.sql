SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddcodeReportCatalog](@CriteriaOptions varchar(25)=NULL,
@Defaults varchar(20)=NULL,
@Keywords varchar(max)=NULL,
@OldReportFK int=NULL,
@OldReportID nchar(5)=NULL,
@ReportCategory varchar(20)=NULL,
@ReportClass varchar(50)=NULL,
@ReportDescription varchar(1000)=NULL,
@ReportName varchar(100)=NULL)
AS
INSERT INTO codeReportCatalog(
CriteriaOptions,
Defaults,
Keywords,
OldReportFK,
OldReportID,
ReportCategory,
ReportClass,
ReportDescription,
ReportName
)
VALUES(
@CriteriaOptions,
@Defaults,
@Keywords,
@OldReportFK,
@OldReportID,
@ReportCategory,
@ReportClass,
@ReportDescription,
@ReportName
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
