SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:    <Jay Robohn>
-- Create date: <Feb 20, 2012>
-- Description: <copied from FamSys - see header below>
-- =============================================
create procedure [dbo].[rspServedCases_TANFGA]
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

	-- For those served in Time Period (receiving any time in time period)
	select families_served = count(distinct hvcasepk)
		  ,tanf_emg_ga = sum(case -- ,PBGA
								 when '1' in (PBTANF,PBEmergencyAssistance,PBFoodStamps,PBWIC,PBSSI) then
									 1
								 else
									 0
							 end)
		  --,ga = sum(case
				--		when PBGA = '1' then
				--			1
				--		else
				--			0
				--	end)
		  ,emg = sum(case
						 when PBEmergencyAssistance = '1' then
							 1
						 else
							 0
					 end)
		  ,tanf = sum(case
						  when PBTANF = '1' then
							  1
						  else
							  0
					  end)
		  ,wic = sum(case
						 when PBWIC = '1' then
							 1
						 else
							 0
					 end)
		  ,foodstamps = sum(case
								when PBFoodStamps = '1' then
									1
								else
									0
							end)
		  ,ssi = sum(case
						 when PBSSI = '1' then
							 1
						 else
							 0
					 end)
		from hvcase
			inner join caseprogram on caseprogram.hvcasefk = hvcasepk
			inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
			left join (select commonattributescreator
							 ,formtype
							 ,ca.hvcasefk
							 ,ca.programfk
							 ,ca.formdate
							 ,PBTANF
							 ,PBEmergencyAssistance
							 --,PBGA
							 ,PBWIC
							 ,PBFoodStamps
							 ,PBSSI
						   from CommonAttributes ca
						   where formdate <= @edate
								and formtype in ('in','tp')
								and convert(datetime,FormDate,112)+CommonAttributesPK in (select CAMatchingKey = max(convert(datetime,FormDate,112)+CommonAttributesPK)
																							  from commonattributes cainner
																							  where cainner.hvcasefk = ca.hvcasefk
																								   and formdate <= @edate
																								   and formtype in ('in','tp')
																							  group by hvcasefk
																									  ,programfk)) ca on ca.hvcasefk = hvcasepk and ca.programfk = caseprogram.programfk
		where caseprogress >= 9
			 and intakedate <= @edate
			 and (dischargedate is null
			 or dischargedate >= @sdate)
GO
