SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDellistSite](@listSitePK int)

AS


DELETE 
FROM listSite
WHERE listSitePK = @listSitePK
GO
