SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <April 23, 2013>
-- Description:	<udfHVLevel - returns level info>
-- =============================================
create function [dbo].[udfHVLevel]
(-- Add the parameters for the function here
 @programfk varchar(max)    = null,
 @QuarterEndDate     datetime
 )
returns
@tHVLevel table(
hvlevelpk int,
	hvcasefk int,
	programfk int,
	levelassigndate datetime,
	levelname varchar(50),
	caseweight numeric(4,2)
)
as
begin

	if @programfk is null
	begin
		select @programfk =
			   substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
							  from HVProgram
							  for xml path ('')),2,8000)
	end

	set @programfk = REPLACE(@programfk,'"','')

	insert
		into @THVLevel	
		
			select hvlevel.hvlevelpk
			 ,hvlevel.hvcasefk
			 ,hvlevel.programfk
			 ,hvlevel.levelassigndate
			 ,levelname
			 ,caseweight							 
		   from hvlevel
		   inner join dbo.SplitString(@programfk,',') on hvlevel.programfk = listitem
		   inner join codelevel on codelevelpk = levelfk
		   inner join (select hvcasefk
							 ,programfk
							 ,max(levelassigndate) as levelassigndate
						   from hvlevel h2
						   inner join dbo.SplitString(@programfk,',') on h2.programfk = listitem
						   where levelassigndate <= @QuarterEndDate
						   group by hvcasefk ,programfk)		
		
		e2 on e2.hvcasefk = hvlevel.hvcasefk and e2.programfk = hvlevel.programfk and e2.levelassigndate = hvlevel.levelassigndate
		
		

	return

end
GO
