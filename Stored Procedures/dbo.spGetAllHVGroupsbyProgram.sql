SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[spGetAllHVGroupsbyProgram]
	@ProgramFK  int           = null
    
as
set nocount on
	
select HVGroupPK, GroupTitle, ActivityTopic, convert(VARCHAR(10), GroupDate, 101) GroupDate
from HVGroup
where ProgramFK = isnull(@ProgramFK, ProgramFK)
ORDER BY GroupTitle, ActivityTopic
GO
