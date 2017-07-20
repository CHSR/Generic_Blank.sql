SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:    <Jay Robohn>
-- Create date: <Feb 20, 2012>
-- Description: <copied from FamSys - see header below>
-- =============================================
create procedure [dbo].[rspServedCasesList_TANFGA]
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

	select distinct b.PC1ID
				   ,LTRIM(c.PCFirstName)+' '+c.PCLastName [Name]
				   ,a.IntakeDate
				   ,isnull(a.tcdob,a.edc) [edc_tcdob]
				   ,case -- ,ca.PBGA
						when '1' in (ca.PBTANF,ca.PBEmergencyAssistance,ca.PBWIC,ca.PBFoodStamps,ca.PBSSI) then
							1
						else
							0
					end [tanf_emg_ga]
				 --  ,case
					--	when ca.PBGA = '1' then
					--		1
					--	else
					--		0
					--end [ga]
				   ,case
						when ca.PBEmergencyAssistance = '1' then
							1
						else
							0
					end [emg]
				   ,case
						when ca.PBTANF = '1' then
							1
						else
							0
					end [tanf]
				   ,case
						when ca.PBWIC = '1' then
							1
						else
							0
					end [wic]
				   ,case
						when ca.PBFoodStamps = '1' then
							1
						else
							0
					end [foodstamps]
				   ,case
						when ca.PBSSI = '1' then
							1
						else
							0
					end [ssi]
				   ,ca.FormDate
		from hvcase as a
			inner join caseprogram as b on b.hvcasefk = a.hvcasepk
			inner join pc as c on c.PCPK = a.PC1FK
			inner join dbo.SplitString(@programfk,',') on b.programfk = listitem
			left join (select x.commonattributescreator
							 ,x.formtype
							 ,x.hvcasefk
							 ,x.programfk
							 ,x.formdate
							 ,x.PBTANF
							 ,x.PBEmergencyAssistance
							 --,x.PBGA
							 ,x.PBWIC
							 ,x.PBFoodStamps
							 ,x.PBSSI
						   from CommonAttributes x
						   where x.formdate <= @edate
								and x.formtype in ('in','tp')
								and convert(datetime,x.FormDate,112)+x.CommonAttributesPK in (select CAMatchingKey = max(convert(datetime,xx.FormDate,112)+xx.CommonAttributesPK)
																								  from commonattributes xx
																								  where xx.hvcasefk = x.hvcasefk
																									   and xx.formdate <= @edate
																									   and xx.formtype in ('in','tp')
																								  group by xx.hvcasefk
																										  ,xx.programfk)) ca on ca.hvcasefk = a.hvcasepk and ca.programfk = b.programfk
		where a.caseprogress >= 9
			 and a.intakedate <= @edate
			 and (b.dischargedate is null
			 or b.dischargedate >= @sdate)



/*
-- For those served in Time Period (receiving any time in time period)
select 
	families_served = count(distinct hvcasepk),
	tanf_emg_ga = sum(case when '1' in (PBTANF, PBEmergencyAssistance, PBGA, 
    PBWIC, PBFS, PBSSI) then 1 else 0 end),
	ga = sum(case when PBGA = '1' then 1 else 0 end),
	emg = sum(case when PBEmergencyAssistance = '1' then 1 else 0 end),
	tanf = sum(case when PBTANF = '1' then 1 else 0 end),
	wic = sum(case when PBWIC = '1' then 1 else 0 end),
	foodstamps = sum(case when PBFS = '1' then 1 else 0 end),
	ssi = sum(case when PBSSI = '1' then 1 else 0 end)
from hvcase

inner join caseprogram
on caseprogram.hvcasefk = hvcasepk
INNER JOIN dbo.SplitString(@programfk,',')
ON caseprogram.programfk  = listitem
left join 
(select commonattributescreator, formtype, ca.hvcasefk, ca.programfk, ca.formdate, 
PBTANF, PBEmergencyAssistance, PBGA, PBWIC, PBFS, PBSSI
from CommonAttributes ca
where formdate <=@edate	and formtype in ('in','tp')
and CONVERT(DATETIME,FormDate,112)+CommonAttributesPK in (select CAMatchingKey=MAX(CONVERT(DATETIME,FormDate,112)+CommonAttributesPK)
from commonattributes cainner where cainner.hvcasefk=ca.hvcasefk 
and formdate <= @edate and formtype in('in', 'tp') 
group by hvcasefk, programfk)) ca
on ca.hvcasefk = hvcasepk
and ca.programfk = caseprogram.programfk
where caseprogress >= 9
and intakedate <= @edate
and (dischargedate is null
or dischargedate >= @sdate)
*/
GO
