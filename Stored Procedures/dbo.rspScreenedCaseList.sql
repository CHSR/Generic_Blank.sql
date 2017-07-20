SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:    <Jay Robohn>
-- Create date: <Feb 20, 2012>
-- Description: <copied from FamSys - see header below>
-- =============================================
create procedure [dbo].[rspScreenedCaseList]
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

	select d.ProgramName
		  ,b.PC1ID
		  ,LTRIM(c.PCFirstName)+' '+c.PCLastName [Name]
		  ,c.PCPhone
		  ,a.ScreenDate
		  ,a.HVCaseCreateDate
		  ,c.PCDOB
		  ,case
			   when c.Gender = '01' then
				   'Female'
			   when c.Gender = '02' then
				   'Male'
			   else
				   'Unknown'
		   end [Gender]
		  ,c.PCStreet
		  ,substring(c.PCZip,1,5) [Zip]
		  ,c.PCState
		  ,a.CaseProgress
		  ,case
			   when isnull(a.tcdob,a.edc) > a.screendate then
				   'Yes'
			   else
				   'No'
		   end [screen_pre]
		  ,case
			   when a.tcdob <= a.screendate then
				   'Yes'
			   else
				   'No'
		   end [screen_post]
		  ,isnull(a.tcdob,a.edc) [edc_tcdob]
		  ,p2.ReferralSourceName
		from hvcase as a
			inner join caseprogram as b on b.hvcasefk = a.hvcasepk
			inner join dbo.SplitString(@programfk,',') on b.programfk = listitem
			inner join pc as c on c.PCPK = a.PC1FK
			inner join HVProgram as d on d.HVProgramPK = b.programfk
			inner join HVScreen as p1 on p1.HVCaseFK = a.HVCasePK and p1.ProgramFK = b.programfk
			inner join listReferralSource as p2 on p2.listReferralSourcePK = p1.ReferralSourceFK

		where a.screendate between @sdate and @edate
		order by ProgramName
				,a.screendate

GO
