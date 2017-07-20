SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[spGetAllcodeRegions]
as
select codeRegionPK ,
		RegionDescription ,
		RegionName
from dbo.codeRegion
order by codeRegionPK
GO
