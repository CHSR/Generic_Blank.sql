SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:    <Jay Robohn>
-- Create date: <Feb 20, 2012>
-- Description: <copied from FamSys - see header below>
-- =============================================
create procedure [dbo].[rspServedCases_LOSDC]
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

	-- Length of Service at DC
	select families_served = count(*)
		  ,dc_3plusyr = sum(case
								when (datediff(mm,tcdob,dischargedate) > 36) then
									1
								else
									0
							end)
		  ,dc_3yr = sum(case
							when (datediff(mm,tcdob,dischargedate) between 24 and 36) then
								1
							else
								0
						end)
		  ,dc_2yr = sum(case
							when (datediff(mm,tcdob,dischargedate) between 12 and 23) then
								1
							else
								0
						end)
		  ,dc_1yr = sum(case
							when (datediff(mm,tcdob,dischargedate) between 6 and 11) then
								1
							else
								0
						end)
		  ,dc_6mo = sum(case
							when (datediff(mm,tcdob,dischargedate) between 0 and 5) then
								1
							else
								0
						end)
		  ,dc_pre = sum(case
							when (tcdob > dischargedate or tcdob is null) then
								1
							else
								0
						end)
		from hvcase
			inner join caseprogram on caseprogram.hvcasefk = hvcasepk
			inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
		where caseprogress >= 9
			 and dischargedate between @sdate and @edate
GO
