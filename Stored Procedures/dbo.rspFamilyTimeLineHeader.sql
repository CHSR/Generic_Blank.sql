SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Jay Robohn>
-- Create date: 
-- Description:	<report: Family time line -- header>
--				moved from FamSys Feb 20, 2012 by jrobohn
-- Edit date: 10/11/2013 CP - workerprogram was duplicating cases when worker transferred
--            added this code to the workerprogram join condition: AND wp.programfk = listitem
-- =============================================
CREATE procedure [dbo].[rspFamilyTimeLineHeader]
(
    @pc1id     varchar(13),
    @programfk varchar(max)
)
as


--DECLARE @pc1id VARCHAR(13) = 'DS83010203701'
--DECLARE @programfk varchar(max) = '1'

	if @programfk is null
	begin
		select @programfk = substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end

	set @programfk = REPLACE(@programfk,'"','')

	-- Heading
	select distinct pc1id
				   ,rtrim(pc1.pcfirstname)+' '+rtrim(pc1.pclastname) pc1name
				   ,pc1.pcphone pc1phone
				   ,pc1.pcemergencyphone pc1emgphone
				   ,rtrim(ec.pcfirstname)+' '+rtrim(ec.pclastname) ecname
				   ,ec.pcphone ecphone
				   ,ec.pcemergencyphone ecemgphone
				   ,substring((select distinct ', '+rtrim(tcfirstname)+' '+rtrim(tclastname)
								   from tcid
								   where hvcase.hvcasepk = tcid.hvcasefk
										and tcid.programfk = caseprogram.programfk AND TCID.TCDOD IS NULL
								   for xml path ('')),3,1000) TargetChild
				   ,rtrim(fsw.firstname)+' '+rtrim(fsw.lastname) fswname
				   ,screendate
				   ,hvcase.tcdob
				   ,rtrim(obp.pcfirstname)+' '+rtrim(obp.pclastname) obpname
				   ,rtrim(supervisor.firstname)+' '+rtrim(supervisor.lastname) supervisorname
				   ,hvcase.kempedate
				   ,intakedate
				   ,rtrim(pc2.pcfirstname)+' '+rtrim(pc2.pclastname) pc2name
				   ,tcid.GestationalAge
				   ,(((40-tcid.GestationalAge)*7)+hvcase.tcdob) CDOB
		from caseprogram
			inner join hvcase on hvcasepk = caseprogram.hvcasefk
			inner join pc pc1 on pc1fk = pc1.pcpk
			left join pc ec on cpfk = ec.pcpk
			inner join worker fsw on fsw.workerpk = currentfswfk
			left join pc obp on obpfk = obp.pcpk
			left join kempe on kempe.hvcasefk = hvcasepk 
			left join pc pc2 on pc2fk = pc2.pcpk
			INNER join tcid on tcid.hvcasefk = hvcasepk 
			inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
			inner join workerprogram on currentfswfk = workerprogram.workerfk AND workerprogram.programfk = listitem
			inner join worker supervisor on supervisor.workerpk = workerprogram.supervisorfk
		where pc1id = @pc1id
			 and caseprogress >= 11 
GO
