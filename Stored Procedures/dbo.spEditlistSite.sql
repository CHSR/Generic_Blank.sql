SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditlistSite](@listSitePK int=NULL,
@listSitePK_old int=NULL,
@ProgramFK int=NULL,
@SiteCode char(30)=NULL,
@SiteName char(30)=NULL)
AS
UPDATE listSite
SET 
listSitePK_old = @listSitePK_old, 
ProgramFK = @ProgramFK, 
SiteCode = @SiteCode, 
SiteName = @SiteName
WHERE listSitePK = @listSitePK
GO
