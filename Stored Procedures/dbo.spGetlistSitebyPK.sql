SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetlistSitebyPK]

(@listSitePK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM listSite
WHERE listSitePK = @listSitePK
GO
