SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:    <Jay Robohn>
-- Create date: <Feb 20, 2012>
-- Description: <copied from FamSys - see header below>
-- =============================================
create procedure [dbo].[rspServedCasesList_LevelInfo]
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
		  ,LTRIM(c.PCFirstName)+' '+c.PCLastName [Name]
		  ,a.IntakeDate
		  ,isnull(a.tcdob,a.edc) [edc_tcdob]
		  ,e3.levelassigndate
		  ,e3.levelname
		  ,e3.caseweight
		  ,e3.hvlevelpk
		  ,e3.hvcasefk
		  ,e3.programfk
		  ,datediff(dd,e3.levelassigndate,@edate) [days_on_level]

		from hvcase as a
			inner join caseprogram as b on b.hvcasefk = a.hvcasepk
			inner join pc as c on c.PCPK = a.PC1FK
			inner join dbo.SplitString(@programfk,',') on b.programfk = listitem
			left join (select x.hvlevelpk
							 ,x.hvcasefk
							 ,x.programfk
							 ,x.levelassigndate
							 ,y.levelname
							 ,y.caseweight
						   from hvlevel as x
							   inner join codelevel as y on y.codelevelpk = x.levelfk
							   inner join (select h2.hvcasefk
												 ,h2.programfk
												 ,max(h2.levelassigndate) as levelassigndate
											   from hvlevel h2
											   where h2.levelassigndate <= @edate
											   group by h2.hvcasefk
													   ,h2.programfk) e2 on e2.hvcasefk = x.hvcasefk and e2.programfk = x.programfk and e2.levelassigndate = x.levelassigndate) e3 on e3.hvcasefk = b.hvcasefk and e3.programfk = b.programfk

		where a.caseprogress >= 9
			 and a.intakedate <= @edate
			 and (b.dischargedate is null
			 or b.dischargedate > @edate)
		order by b.PC1ID





GO
