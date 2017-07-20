SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:    <Jay Robohn>
-- Create date: <Feb 20, 2012>
-- Description: <copied from FamSys - see header below>
-- =============================================
create procedure [dbo].[rspServedCases_LevelInfo]
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

	-- Level Information (level @ end of report period)
	select families_served = count(distinct pc1id)
		  ,tr = sum(case
						when levelname = 'Level TR' then
							1
						else
							0
					end)
		  ,tr_weight = sum(case
							   when levelname = 'Level TR' then
								   cast(replace(rtrim(replace(replace(rtrim(replace(caseweight,'0',' ')),' ','0'),'.',' ')),' ','.') as float)
							   else
								   0
						   end)
		  ,m_one = sum(case
						   when levelname = 'Level M-1' then
							   1
						   else
							   0
					   end)
		  ,m_one_weight = sum(case
								  when levelname = 'Level M-1' then
									  cast(replace(rtrim(replace(replace(rtrim(replace(caseweight,'0',' ')),' ','0'),'.',' ')),' ','.') as float)
								  else
									  0
							  end)
		  ,x = sum(case
					   when levelname = 'Level X' then
						   1
					   else
						   0
				   end)
		  ,x_weight = sum(case
							  when levelname = 'Level X' then
								  cast(replace(rtrim(replace(replace(rtrim(replace(caseweight,'0',' ')),' ','0'),'.',' ')),' ','.') as float)
							  else
								  0
						  end)
		  ,four = sum(case
						  when levelname = 'Level 4' then
							  1
						  else
							  0
					  end)
		  ,four_weight = sum(case
								 when levelname = 'Level 4' then
									 cast(replace(rtrim(replace(replace(rtrim(replace(caseweight,'0',' ')),' ','0'),'.',' ')),' ','.') as float)
								 else
									 0
							 end)
		  ,three = sum(case
						   when levelname = 'Level 3' then
							   1
						   else
							   0
					   end)
		  ,three_weight = sum(case
								  when levelname = 'Level 3' then
									  cast(replace(rtrim(replace(replace(rtrim(replace(caseweight,'0',' ')),' ','0'),'.',' ')),' ','.') as float)
								  else
									  0
							  end)
		  ,two = sum(case
						 when levelname = 'Level 2' then
							 1
						 else
							 0
					 end)
		  ,two_weight = sum(case
								when levelname = 'Level 2' then
									cast(replace(rtrim(replace(replace(rtrim(replace(caseweight,'0',' ')),' ','0'),'.',' ')),' ','.') as float)
								else
									0
							end)
		  ,one_ss = sum(case
							when levelname = 'Level 1-SS' then
								1
							else
								0
						end)
		  ,one_ss_weight = sum(case
								   when levelname = 'Level 1-SS' then
									   cast(replace(rtrim(replace(replace(rtrim(replace(caseweight,'0',' ')),' ','0'),'.',' ')),' ','.') as float)
								   else
									   0
							   end)
		  ,one = sum(case
						 when levelname = 'Level 1' then
							 1
						 else
							 0
					 end)
		  ,one_weight = sum(case
								when levelname = 'Level 1' then
									cast(replace(rtrim(replace(replace(rtrim(replace(caseweight,'0',' ')),' ','0'),'.',' ')),' ','.') as float)
								else
									0
							end)
		  ,p1 = sum(case
						when levelname = 'Level P-1' then
							1
						else
							0
					end)
		  ,p1_weight = sum(case
							   when levelname = 'Level P-1' then
								   cast(replace(rtrim(replace(replace(rtrim(replace(caseweight,'0',' ')),' ','0'),'.',' ')),' ','.') as float)
							   else
								   0
						   end)
		from hvcase
			inner join caseprogram on caseprogram.hvcasefk = hvcasepk
			inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
			left join (select hvlevel.hvlevelpk
							 ,hvlevel.hvcasefk
							 ,hvlevel.programfk
							 ,hvlevel.levelassigndate
							 ,levelname
							 ,caseweight
						   from hvlevel
							   inner join codelevel on codelevelpk = levelfk
							   inner join (select hvcasefk
												 ,programfk
												 ,max(levelassigndate) as levelassigndate
											   from hvlevel h2
											   where levelassigndate <= @edate
											   group by hvcasefk
													   ,programfk) e2 on e2.hvcasefk = hvlevel.hvcasefk and e2.programfk = hvlevel.programfk and e2.levelassigndate = hvlevel.levelassigndate) e3 on e3.hvcasefk = caseprogram.hvcasefk and e3.programfk = caseprogram.programfk
		where caseprogress >= 9
			 and intakedate <= @edate
			 and (dischargedate is null
			 or dischargedate > @edate)
GO
