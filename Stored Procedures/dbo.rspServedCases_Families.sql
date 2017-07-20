SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:    <Jay Robohn>
-- Create date: <Feb 20, 2012>
-- Description: <copied from FamSys - see header below>
-- =============================================
create procedure [dbo].[rspServedCases_Families]
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

	-- Families Served in Time Period
	-- Families Served at begining of period
	-- Families enrolled in Time Period
	-- Families enrolled prenatally
	-- Families enrolled postnatally
	-- Families DC in time Period
	-- Families active at end of period
	-- # of women pregnant with TC, not born at end of report period
	-- # of women parenting TC at end of the report period
	select *
		  ,(families_served-fam_dc) fam_act_end
		from (select families_served = sum(case
											   when intakedate <= @edate and (dischargedate is null or dischargedate >= @sdate) then
												   1
											   else
												   0
										   end)
					,fam_begin = sum(case
										 when intakedate <= @sdate and (dischargedate is null or dischargedate >= @sdate) then
											 1
										 else
											 0
									 end)
					,enrolled = sum(case
										when intakedate between @sdate and @edate then
											1
										else
											0
									end)
					,enrolled_pre = sum(case
											when isnull(tcdob,edc) > intakedate and intakedate between @sdate and @edate then
												1
											else
												0
										end)
					,enrolled_post = sum(case
											 when tcdob <= intakedate and intakedate between @sdate and @edate then
												 1
											 else
												 0
										 end)
					,fam_dc = sum(case
									  when dischargedate between @sdate and @edate then
										  1
									  else
										  0
								  end)
					,women_tc_end = sum(case
											when intakedate <= @edate and (dischargedate is null or dischargedate > @edate) and tcdob <= @edate then
												1
											else
												0
										end)
					,women_no_tc_end = sum(case
											   when intakedate <= @edate and (dischargedate is null or dischargedate > @edate) and (tcdob > @edate or tcdob is null) then
												   1
											   else
												   0
										   end)
				  from hvcase
					  inner join caseprogram on caseprogram.hvcasefk = hvcasepk
					  inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
				  where caseprogress >= 9) t




GO
