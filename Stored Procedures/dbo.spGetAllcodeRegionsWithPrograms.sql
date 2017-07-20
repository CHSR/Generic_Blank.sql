SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		jrobohn
-- Create date: <June 20, 2014>
-- Description:	<Gets all rows from the codeRegion table and include related ProgramFKs in CSVs>
-- rspDataReport 22, '03/01/2013', '05/31/2013'		
-- exec [spGetAllcodeRegionsWithPrograms]
-- =============================================
CREATE procedure [dbo].[spGetAllcodeRegionsWithPrograms]
as

with cteGetProgramFKs 
as
	( select RegionFK, ProgramFKs = replace((select cast(HVProgramPK as varchar(5)) as [data()]
												  from HVProgram
												  where RegionFK = p.RegionFK
												  order by HVProgramPK for xml path('')), ' ', ',')
		from HVProgram p
		inner join codeRegion r on r.codeRegionPK = p.RegionFK
		where RegionFK is not null
		group by RegionFK
	)

select RegionName, cast(gp.RegionFK as varchar(2)) + '-' + gp.ProgramFKs as RegionFKPrograms
from cteGetProgramFKs gp
inner join codeRegion cr on RegionFK = codeRegionPK
GO
