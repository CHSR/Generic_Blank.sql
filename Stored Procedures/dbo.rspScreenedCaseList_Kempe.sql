SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:    <Jay Robohn>
-- Create date: <Feb 20, 2012>
-- Description: <copied from FamSys - see header below>
-- =============================================
create procedure [dbo].[rspScreenedCaseList_Kempe]
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

	select b.PC1ID
		  ,LTRIM(c.PCFirstName)+' '+c.PCLastName [Name]
		  ,k.KempeDate
		  ,RTRIM(w.FirstName)+' '+RTRIM(w.LastName) [WorkerName]
		from kempe as k
			inner join dbo.SplitString(@programfk,',') on k.programfk = listitem
			inner join dbo.HVCase as a on a.HVCasePK = k.HVCaseFK
			inner join caseprogram as b on b.hvcasefk = a.hvcasepk
			inner join pc as c on c.PCPK = a.PC1FK
			inner join Worker as w on w.WorkerPK = k.FAWFK

		where k.kempedate between @sdate and @edate
GO
