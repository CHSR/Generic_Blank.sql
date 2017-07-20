SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:    <Jay Robohn>
-- Create date: <Feb 20, 2012>
-- Description: <copied from FamSys - see header below>
-- Edit date: 10/11/2013 CP - workerprogram was duplicating cases when worker transferred
--            added this code to the workerprogram join condition: AND wp.programfk = listitem
-- =============================================
CREATE procedure [dbo].[rspFollowUpTicklerSummary]
(
    @programfk    varchar(max)    = null,
    @rdate        datetime,
    @supervisorfk int             = null,
    @workerfk     int             = null
)
as
	if @programfk is null
	begin
		select @programfk = substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end

	set @programfk = REPLACE(@programfk,'"','')

	---- FOLLOW UP
	select distinct pc1id
				   ,hvcase.tcdob
				   ,eventDescription
				   ,dateadd(dd,dueby,hvcase.tcdob) DueDate
				   ,substring((select distinct ', '+rtrim(tcfirstname)+' '+rtrim(tclastname)
								   from tcid
								   where hvcase.hvcasepk = tcid.hvcasefk
										and tcid.programfk = caseprogram.programfk
								   for xml path ('')),3,1000) TargetChild
				   ,rtrim(fsw.firstname)+' '+rtrim(fsw.lastname) fswname
				   ,LTRIM(RTRIM(supervisor.firstname))+' '+LTRIM(RTRIM(supervisor.lastname)) supervisor
		from caseprogram
			inner join hvcase on hvcasepk = caseprogram.hvcasefk
			inner join tcid on tcid.hvcasefk = hvcasepk and tcid.programfk = caseprogram.programfk
			inner join codeduebydates on scheduledevent = 'Follow Up'
			inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
			inner join worker fsw on fsw.workerpk = currentfswfk
			inner join workerprogram on workerfk = fsw.workerpk AND workerprogram.programfk = listitem
			inner join worker supervisor on supervisorfk = supervisor.workerpk
			left join followup on followup.hvcasefk = hvcasepk and followup.programfk = caseprogram.programfk and codeduebydates.interval = followupinterval
		where followup.hvcasefk is NULL
		     AND HVCase.TCDOD IS NULL
			 and CaseProgress >= 11
			 and CurrentFSWFK = isnull(@workerfk,CurrentFSWFK)
			 and SupervisorFK = isnull(@supervisorfk,SupervisorFK)
			 and (DischargeDate is null)
			 and year(dateadd(dd,dueby,hvcase.tcdob)) = year(@rdate)
			 and month(dateadd(dd,dueby,hvcase.tcdob)) = month(@rdate)
		order by fswname
				,DueDate


GO
