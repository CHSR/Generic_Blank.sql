SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Feb 5, 2012>
-- Description:	<report: ASQSE Tickler Summary>
--				Moved from FamSys - 02/05/12 jrobohn
-- Edit date: 10/11/2013 CP - workerprogram was duplicating cases when worker transferred
--            added this code to the workerprogram join condition: AND wp.programfk = listitem
-- =============================================
CREATE procedure [dbo].[rspASQSETicklerSummary]
(@programfk    varchar(max)    = null,
 @rdate        datetime,
 @supervisorfk int             = null,
 @workerfk     int             = null
)

as

	if @programfk is null
	begin
		select @programfk =
			   substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
							  from HVProgram
							  for xml path ('')),2,8000)
	end

	set @programfk = REPLACE(@programfk,'"','')

	---- ASQ-SE
	select
		  pc1id
		 ,hvcase.tcdob
		 ,eventDescription
		 ,dateadd(dd,dueby,hvcase.tcdob) DueDate
		 ,rtrim(tcfirstname)+' '+rtrim(tclastname) TargetChild
		 ,rtrim(fsw.firstname)+' '+rtrim(fsw.lastname) fswname
		 ,LTRIM(RTRIM(supervisor.firstname))+' '+LTRIM(RTRIM(supervisor.lastname)) supervisor
		from caseprogram
			inner join hvcase
					  on hvcasepk = caseprogram.hvcasefk
			inner join tcid
					  on tcid.hvcasefk = hvcasepk
					  and tcid.programfk = caseprogram.programfk AND TCID.TCDOD IS NULL
			--inner join appoptions
			--		  on caseprogram.programfk = appoptions.programfk
			--		  and optionitem = 'asqse version'
			inner join codeduebydates
					  on scheduledevent = 'ASQSE-1'  --optionValue
			inner join dbo.SplitString(@programfk,',')
					  on caseprogram.programfk = listitem
			inner join worker fsw
					  on fsw.workerpk = currentfswfk
			inner join workerprogram
					  on workerfk = fsw.workerpk  AND workerprogram.programfk = listitem
			inner join worker supervisor
					  on supervisorfk = supervisor.workerpk
			left join asqse
					 on asqse.hvcasefk = hvcasepk
					 and asqse.programfk = caseprogram.programfk
					 and codeduebydates.interval = ASQSETCAge
		where asqse.hvcasefk is null
			 and caseprogress >= 11
			 and currentFSWFK = isnull(@workerfk,currentFSWFK)
			 and supervisorfk = isnull(@supervisorfk,supervisorfk)
			 and (dischargedate is null)
			 and year(dateadd(dd,dueby,hvcase.tcdob)) = year(@rdate)
			 and month(dateadd(dd,dueby,hvcase.tcdob)) = month(@rdate)
			 AND HVCase.TCDOD IS NULL
			 
		order by fswname
				,DueDate


GO
