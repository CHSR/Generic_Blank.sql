SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddlistSite](@listSitePK_old int=NULL,
@ProgramFK int=NULL,
@SiteCode char(30)=NULL,
@SiteName char(30)=NULL)
AS
INSERT INTO listSite(
listSitePK_old,
ProgramFK,
SiteCode,
SiteName
)
VALUES(
@listSitePK_old,
@ProgramFK,
@SiteCode,
@SiteName
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
