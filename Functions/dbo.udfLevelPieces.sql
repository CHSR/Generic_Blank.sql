SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Jan 4, 2012>
-- Description:	<udfLevelPieces - returns distinct level periods for each case in cohort, used in many other sprocs>
-- =============================================
CREATE function [dbo].[udfLevelPieces]
(-- Add the parameters for the function here
 @programfk varchar(max)    = null,
 @sdate     datetime,
 @edate     datetime
 )
returns
@tLevelPieces table(
	casefk int,
	startdate datetime,
	enddate datetime,
	levelname varchar(30),
	programfk varchar(max),
	workerfk int,
	reqvisitcalc float,
	hvlevelpk int,
	reqvisit float
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

	--get the date ranges per worker, per level
	insert
		into @tLevelPieces
		select *
			  , (CAST(datediff(day,beginning,ending)as decimal(10,3)) + 1)/7 * maximumvisit --CP 4/04/2014 needed CAST to create decimal because 01/01 - 03/31 was coming up as 90 days / 7 = .96 not 1.02, where level 4's were showing up without any required visits
			from (
				  select wad.hvcasefk
						,case
							 when hld.StartLevelDate > StartAssignmentDate and EndlevelDate > @sdate and EndLevelDate < @edate and hld.StartLevelDate < @sdate then
								 @sdate --Chris Papas 07/26/2011 --below line did not cover all the bases.
							 when hld.StartLevelDate > StartAssignmentDate and EndlevelDate > @sdate and EndLevelDate < @edate then
								 hld.StartLevelDate --Chris Papas, beginning date CASE was too simple and dates were wrong, this may not cover all the bases, but seems to work now.
							 when hld.StartLevelDate < StartAssignmentDate and StartAssignmentDate > @sdate then
								 StartAssignmentDate
							 when hld.StartLevelDate < @sdate then
								 @sdate
							 when StartAssignmentDate > hld.StartLevelDate then
								 StartAssignmentDate
							 else
								 hld.StartLevelDate
						 end as beginning
						,case
							 when EndAssignmentDate < @edate and EndAssignmentDate < hld.EndLevelDate then
								cast(EndAssignmentDate as datetime) + cast('23:59:59' as datetime)
							 when hld.EndLevelDate > @edate then
								 cast(@edate as datetime) + cast('23:59:59' as datetime)
							 when hld.EndLevelDate > EndAssignmentDate then
								 cast(EndAssignmentDate as datetime) + cast('23:59:59' as datetime)
							 when hld.EndLevelDate is null then
								 case
									 when EndAssignmentDate is null then
										 cast(@edate as datetime) + cast('23:59:59' as datetime)
									 when EndAssignmentDate > @edate then
										 cast(@edate as datetime) + cast('23:59:59' as datetime)
									 else
										 cast(EndAssignmentDate as datetime) + cast('23:59:59' as datetime)
								 end
							 else
								 cast(hld.EndLevelDate as datetime) + cast('23:59:59' as datetime)
						 end as ending
						,levelname
						,wad.programfk
						,workerfk
						,maximumvisit
						,hld.hvlevelpk
					  from workerassignmentdetail wad
						  inner join hvleveldetail hld on wad.hvcasefk = hld.hvcasefk
						  inner join dbo.SplitString(@programfk,',') on wad.programfk = listitem
					  where isnull(hld.endLevelDate,@edate) >= wad.StartAssignmentDate
						   and hld.StartLevelDate <= @edate
						   and wad.StartAssignmentDate <= @edate --get assignments in report range
						   and isnull(wad.EndAssignmentDate,@edate) >= @sdate
						   and isnull(hld.endlevelDate,@EDATE) >= @sdate
				 ) a
			where beginning <= ending
	return
end
GO
