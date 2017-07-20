SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:    Chris Papas
-- Create date: Feb 5, 2010
-- Description: Get all Agency Sites
-- =============================================
CREATE procedure [dbo].[spGetAllListSites]
(
    @programfk int
)
-- Add the parameters for the stored procedure here
as
begin
	select listSitePK
		  ,listSitePK_old
		  ,ProgramFK
		  ,SiteCode
		  ,SiteName
		from dbo.listSite
		where programfk = isnull(@ProgramFK,ProgramFK)
		order by sitename
end
GO
