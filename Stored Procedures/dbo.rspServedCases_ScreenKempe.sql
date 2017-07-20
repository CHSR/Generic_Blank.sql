SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:    <Jay Robohn>
-- Create date: <Feb 20, 2012>
-- Description: <copied from FamSys - see header below>
-- =============================================
create procedure [dbo].[rspServedCases_ScreenKempe]
(
    @programfk varchar(max)    = null,
    @sdate     datetime,
    @edate     datetime
)
as
	if @programfk is null
	begin
		select @programfk = substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end

	set @programfk = REPLACE(@programfk,'"','')

	-- Screens in Time Period
	declare @screens      int,
            @screens_pre  int,
            @screens_post int
	select @screens = count(*)
		  ,@screens_pre = sum(case
								  when isnull(tcdob,edc) > screendate then
									  1
								  else
									  0
							  end)
		  ,@screens_post = sum(case
								   when tcdob <= screendate then
									   1
								   else
									   0
							   end)
		from hvcase
			inner join caseprogram on caseprogram.hvcasefk = hvcasepk
			inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
		where screendate between @sdate and @edate

	-- Kempes in Time Period
	declare @kempes int
	select @kempes = count(*)
		from kempe
			inner join dbo.SplitString(@programfk,',') on kempe.programfk = listitem
		where kempedate between @sdate and @edate

	-- Families Served in Time Period
	select ((families_served-pregnant)-subpreg) nonpreg
		  ,subpreg
		  ,pregnant
		  ,families_served
		  ,@kempes kempes
		  ,@screens screens
		  ,@screens_pre screens_pre
		  ,@screens_post screens_post
		from (select families_served = count(distinct hvcasepk)
					,pregnant = sum(case
										when (isnull(hvcase.tcdob,edc) > intakedate or hvcase.tcdob is null) and isnull(hvcase.tcdob,edc) >= @sdate then
											1
										else
											0
									end)
					,subpreg = sum(case
									   when o.dob between @sdate and dateadd(dd,280,@edate) then
										   1
									   else
										   0
								   end)
				  from hvcase
					  inner join caseprogram on caseprogram.hvcasefk = hvcasepk
					  inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
					  left join tcid on tcid.hvcasefk = caseprogram.hvcasefk and tcid.programfk = caseprogram.programfk
					  left join otherchild o on o.hvcasefk = hvcasepk and o.programfk = caseprogram.programfk and formtype = 'fu'
				  where caseprogress >= 9
					   and intakedate <= @edate
					   and (dischargedate is null
					   or dischargedate >= @sdate)) t



GO
