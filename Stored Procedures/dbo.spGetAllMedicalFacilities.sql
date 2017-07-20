SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE procedure [dbo].[spGetAllMedicalFacilities]
@ProgramFK as int = NULL, @ActiveFilter as bit= null

as
select *
from dbo.listMedicalFacility 
where ProgramFK=isnull(@ProgramFK, ProgramFK) and 
MFIsActive=case when @ActiveFilter is null then '1'
		else @ActiveFilter
		end
order by mfname

GO
