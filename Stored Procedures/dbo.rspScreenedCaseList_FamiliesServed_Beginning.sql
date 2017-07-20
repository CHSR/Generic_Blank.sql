SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:    <Jay Robohn>
-- Create date: <Feb 20, 2012>
-- Description: <copied from FamSys - see header below>
-- =============================================
create procedure [dbo].[rspScreenedCaseList_FamiliesServed_Beginning]
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
		  ,a.IntakeDate
		  ,isnull(TCDOB,EDC) [edc_dob]

		from hvcase as a
			inner join caseprogram as b on b.hvcasefk = a.hvcasepk
			inner join dbo.SplitString(@programfk,',') on b.programfk = listitem
			inner join pc as c on c.PCPK = a.PC1FK

		where a.caseprogress >= 9
			 and intakedate <= @sdate
			 and (dischargedate is null
			 or dischargedate >= @sdate)


GO
