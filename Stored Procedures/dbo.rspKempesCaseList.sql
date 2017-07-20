SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:    <Jay Robohn>
-- Create date: <Feb 20, 2012>
-- Description: <copied from FamSys - see header below>
-- =============================================
create procedure [dbo].[rspKempesCaseList]
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
		  ,UPPER(c.PCFirstName)+' '+UPPER(c.PCLastName) [Name]
		  ,c.PCPhone
		  ,a.ScreenDate
		  ,a.HVCaseCreateDate
		  ,e.kempedate
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

		from hvcase as a
			inner join caseprogram as b on b.hvcasefk = a.hvcasepk
			inner join dbo.SplitString(@programfk,',') on b.programfk = listitem
			inner join pc as c on c.PCPK = a.PC1FK
			inner join HVProgram as d on d.HVProgramPK = b.programfk
			inner join Kempe as e on e.HVCaseFK = a.hvcasepk

		where e.kempedate between @sdate and @edate
		order by ProgramName

GO
