SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelcodeReportCatalog](@codeReportCatalogPK int)

AS


DELETE 
FROM codeReportCatalog
WHERE codeReportCatalogPK = @codeReportCatalogPK
GO
