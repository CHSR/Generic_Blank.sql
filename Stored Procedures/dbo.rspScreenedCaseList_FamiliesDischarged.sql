SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:    <Jay Robohn>
-- Create date: <Feb 20, 2012>
-- Description: <copied from FamSys - see header below>
-- =============================================
create procedure [dbo].[rspScreenedCaseList_FamiliesDischarged]
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

	select b.PC1ID
		  ,RTRIM(c.PCFirstName)+' '+c.PCLastName [Name]
		  ,b.DischargeDate
		  ,d.DischargeReason
		  ,case
			   when (datediff(mm,a.tcdob,b.dischargedate) > 36) then
				   'TC > 3 years old'
			   when (datediff(mm,a.tcdob,b.dischargedate) between 24 and 36) then
				   'TC 2yrs to 3yrs old'
			   when (datediff(mm,a.tcdob,b.dischargedate) between 12 and 23) then
				   'TC 1yr to <2yrs old'
			   when (datediff(mm,a.tcdob,b.dischargedate) between 6 and 11) then
				   'TC 6 months to <1yr old'
			   when (datediff(mm,a.tcdob,b.dischargedate) between 0 and 5) then
				   'birth to <6 months old'
			   when (a.tcdob > b.dischargedate or a.tcdob is null) then
				   'D/C prior to birth (prenatal)'
			   else
				   'Unknown'
		   end [age_length]
		from hvcase as a
			inner join caseprogram as b on b.hvcasefk = a.hvcasepk
			inner join dbo.SplitString(@programfk,',') on b.programfk = listitem
			inner join pc as c on c.PCPK = a.PC1FK
			inner join codeDischarge as d on b.DischargeReason = d.DischargeCode
		where a.caseprogress >= 9
			 and b.dischargedate between @sdate and @edate
GO
