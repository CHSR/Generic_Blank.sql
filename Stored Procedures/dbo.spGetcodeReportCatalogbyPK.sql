SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetcodeReportCatalogbyPK]

(@codeReportCatalogPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM codeReportCatalog
WHERE codeReportCatalogPK = @codeReportCatalogPK
GO
