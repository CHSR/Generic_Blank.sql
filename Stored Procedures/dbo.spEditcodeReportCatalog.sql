SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditcodeReportCatalog](@codeReportCatalogPK int=NULL,
@CriteriaOptions varchar(25)=NULL,
@Defaults varchar(20)=NULL,
@Keywords varchar(max)=NULL,
@OldReportFK int=NULL,
@OldReportID nchar(5)=NULL,
@ReportCategory varchar(20)=NULL,
@ReportClass varchar(50)=NULL,
@ReportDescription varchar(1000)=NULL,
@ReportName varchar(100)=NULL)
AS
UPDATE codeReportCatalog
SET 
CriteriaOptions = @CriteriaOptions, 
Defaults = @Defaults, 
Keywords = @Keywords, 
OldReportFK = @OldReportFK, 
OldReportID = @OldReportID, 
ReportCategory = @ReportCategory, 
ReportClass = @ReportClass, 
ReportDescription = @ReportDescription, 
ReportName = @ReportName
WHERE codeReportCatalogPK = @codeReportCatalogPK
GO
