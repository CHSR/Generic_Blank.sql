SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:    <Jay Robohn>
-- Create date: <Feb 20, 2012>
-- Description: <copied from FamSys - see header below>
-- =============================================
create procedure [dbo].[rspServedCases_FamiliesDC]
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

	-- Families DC'd in time period
	select families_served = count(*)
		  ,fortyone = sum(case
							  when dischargecode = '41' then
								  1
							  else
								  0
						  end)
		  ,forty = sum(case
						   when dischargecode = '40' then
							   1
						   else
							   0
					   end)
		  ,thirtyeight = sum(case
								 when dischargecode = '38' then
									 1
								 else
									 0
							 end)
		  ,thirtyseven = sum(case
								 when dischargecode = '37' then
									 1
								 else
									 0
							 end)
		  ,thirtysix = sum(case
							   when dischargecode = '36' then
								   1
							   else
								   0
						   end)
		  ,thirtyfive = sum(case
								when dischargecode = '35' then
									1
								else
									0
							end)
		  ,ninetynine = sum(case
								when dischargecode = '99' then
									1
								else
									0
							end)
		  ,thirtytfour = sum(case
								 when dischargecode = '34' then
									 1
								 else
									 0
							 end)
		  ,thirtythree = sum(case
								 when dischargecode = '33' then
									 1
								 else
									 0
							 end)
		  ,thirtytwo = sum(case
							   when dischargecode = '32' then
								   1
							   else
								   0
						   end)
		  ,thirtyone = sum(case
							   when dischargecode = '31' then
								   1
							   else
								   0
						   end)
		  ,thirty = sum(case
							when dischargecode = '30' then
								1
							else
								0
						end)
		  ,twentynine = sum(case
								when dischargecode = '29' then
									1
								else
									0
							end)
		  ,twentyseven = sum(case
								 when dischargecode = '27' then
									 1
								 else
									 0
							 end)
		  ,twentysix = sum(case
							   when dischargecode = '26' then
								   1
							   else
								   0
						   end)
		  ,twentyfive = sum(case
								when dischargecode = '25' then
									1
								else
									0
							end)
		  ,twentythree = sum(case
								 when dischargecode = '23' then
									 1
								 else
									 0
							 end)
		  ,twentytwo = sum(case
							   when dischargecode = '22' then
								   1
							   else
								   0
						   end)
		  ,twentyone = sum(case
							   when dischargecode = '21' then
								   1
							   else
								   0
						   end)
		  ,twenty = sum(case
							when dischargecode = '20' then
								1
							else
								0
						end)
		  ,nineteen = sum(case
							  when dischargecode = '19' then
								  1
							  else
								  0
						  end)
		  ,eighteen = sum(case
							  when dischargecode = '18' then
								  1
							  else
								  0
						  end)
		  ,seventeen = sum(case
							   when dischargecode = '17' then
								   1
							   else
								   0
						   end)
		  ,sixteen = sum(case
							 when dischargecode = '16' then
								 1
							 else
								 0
						 end)
		  ,fifteen = sum(case
							 when dischargecode = '15' then
								 1
							 else
								 0
						 end)
		  ,fourteen = sum(case
							  when dischargecode = '14' then
								  1
							  else
								  0
						  end)
		  ,twelve = sum(case
							when dischargecode = '12' then
								1
							else
								0
						end)
		  ,eleven = sum(case
							when dischargecode = '11' then
								1
							else
								0
						end)
		  ,eight = sum(case
						   when dischargecode = '08' then
							   1
						   else
							   0
					   end)
		  ,seven = sum(case
						   when dischargecode = '07' then
							   1
						   else
							   0
					   end)
		  ,six = sum(case
						 when dischargecode = '06' then
							 1
						 else
							 0
					 end)
		from hvcase
			inner join caseprogram on caseprogram.hvcasefk = hvcasepk
			inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
			inner join codeDischarge on dischargecode = caseprogram.DischargeReason
		where caseprogress >= 9
			 and dischargedate between @sdate and @edate

GO
