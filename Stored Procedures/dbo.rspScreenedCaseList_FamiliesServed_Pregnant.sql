SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:    <Jay Robohn>
-- Create date: <Feb 20, 2012>
-- Description: <copied from FamSys - see header below>
-- =============================================
create procedure [dbo].[rspScreenedCaseList_FamiliesServed_Pregnant]
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


	/*
[preg_subpreg] : 1 = pregnant, 2 = subpreg, or 3 = other
*/
	select b.PC1ID
		  ,RTRIM(c.PCFirstName)+' '+c.PCLastName [Name]
		  ,isnull(a.tcdob,a.edc) [edcdob]
		  ,a.IntakeDate
		  ,b.DischargeDate
		  ,case
			   when (isnull(a.tcdob,a.edc) > a.intakedate or a.tcdob is null) and isnull(a.tcdob,a.edc) >= @sdate then
				   1
			   when o.dob between @sdate and dateadd(dd,280,@edate) then
				   2
			   else
				   3
		   end [preg_subpreg]
		  ,o.DOB [subsequent_dob]
		from hvcase as a
			inner join caseprogram as b on b.hvcasefk = a.hvcasepk
			inner join pc as c on c.PCPK = a.PC1FK
			inner join dbo.SplitString(@programfk,',') on b.programfk = listitem
			left join tcid as t on t.hvcasefk = b.hvcasefk and t.programfk = b.programfk
			left join otherchild o on o.hvcasefk = a.hvcasepk and o.programfk = b.programfk and o.formtype = 'fu'

		where a.caseprogress >= 9
			 and a.intakedate <= @edate
			 and (b.dischargedate is null
			 or b.dischargedate >= @sdate)
GO
