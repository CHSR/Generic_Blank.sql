SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:    <Dar Chen>
-- Create date: <Oct 1, 2012>
-- Description: <>
-- Edit date: 10/11/2013 CP - workerprogram was duplicating cases when worker transferred
-- =============================================
CREATE procedure [dbo].[rspIFSPTicklerSummary]
(
    @programfk    varchar(max)    = null,
    @rdate        datetime,
    @supervisorfk int             = null,
    @workerfk     int             = null
)

--  DECLARE  @programfk    varchar(max)    = '1'
--  DECLARE  @rdate        DATETIME = '02/01/2016'
--  DECLARE  @supervisorfk int             = null
--  DECLARE  @workerfk     int             = null

as
	if @programfk is null
	begin
		select @programfk = substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end

	set @programfk = REPLACE(@programfk,'"','')

	------ PSI
	--select distinct pc1id
	--			   ,hvcase.tcdob
	--			   ,eventDescription
	--			   ,dateadd(dd,dueby,hvcase.tcdob) DueDate
	--			   ,substring((select distinct ', '+rtrim(tcfirstname)+' '+rtrim(tclastname)
	--							   from tcid
	--							   where hvcase.hvcasepk = tcid.hvcasefk
	--									and tcid.programfk = caseprogram.programfk
	--							   for xml path ('')),3,1000) TargetChild
	--			   ,rtrim(fsw.firstname)+' '+rtrim(fsw.lastname) fswname
	--			   ,LTRIM(RTRIM(supervisor.firstname))+' '+LTRIM(RTRIM(supervisor.lastname)) supervisor
	--	from caseprogram
	--		inner join hvcase on hvcasepk = caseprogram.hvcasefk
	--		inner join tcid on tcid.hvcasefk = hvcasepk and tcid.programfk = caseprogram.programfk
	--		inner join codeduebydates on scheduledevent = 'PSI'
	--		inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
	--		inner join worker fsw on fsw.workerpk = currentfswfk
	--		inner join workerprogram on workerfk = fsw.workerpk AND workerprogram.ProgramFK = ListItem
	--		inner join worker supervisor on supervisorfk = supervisor.workerpk
			
	--		left join PSI on PSI.hvcasefk = hvcasepk and PSI.programfk = caseprogram.programfk 
	--		and codeduebydates.interval = PSIInterval
	
	--	where PSI.hvcasefk is NULL
	--	     AND HVCase.TCDOD IS NULL
	--		 and CaseProgress >= 11
	--		 and CurrentFSWFK = isnull(@workerfk,CurrentFSWFK)
	--		 and SupervisorFK = isnull(@supervisorfk,SupervisorFK)
	--		 and (DischargeDate is null)
	--		 and year(dateadd(dd,dueby,hvcase.tcdob)) = year(@rdate)
	--		 and month(dateadd(dd,dueby,hvcase.tcdob)) = month(@rdate)
	--	order by fswname
	--			,DueDate

	select DISTINCT LevelName
		,pc1id
		,rtrim(pc1.pcfirstname)+' '+rtrim(pc1.pclastname) pc1name
		--,hvcase.tcdob
		,case
			when hvcase.tcdob is not null then
				hvcase.tcdob
			else
				hvcase.edc
		end as tcdob
		, hvcase.IntakeDate AS IntakeDate
					
		, CASE WHEN ISNULL(hvcase.edc,hvcase.tcdob) <= hvcase.IntakeDate THEN 'Postnatal' ELSE 'Prenatal'
		END AS Status

		,DueBy AS DueBy
		,dateadd(dd,dueby,hvcase.IntakeDate) DueDate
		,eventDescription
		,substring((select distinct ', '+rtrim(tcfirstname)+' '+rtrim(tclastname)
						from tcid
						where hvcase.hvcasepk = tcid.hvcasefk
								and tcid.programfk = caseprogram.programfk
						for xml path ('')),3,1000) TargetChild
		,rtrim(fsw.firstname)+' '+rtrim(fsw.lastname) fswname
		,ltrim(rtrim(supervisor.firstname))+' '+ltrim(rtrim(supervisor.lastname)) supervisor
		,rtrim(tcfirstname)+' '+rtrim(tclastname) ForWhom

		,gestationalage
		from caseprogram
			inner join hvcase on hvcasepk = caseprogram.hvcasefk
			inner join pc pc1 on pc1fk = pc1.pcpk
			inner join tcid on tcid.hvcasefk = hvcasepk and tcid.programfk = caseprogram.programfk
			--inner join appoptions on caseprogram.programfk = appoptions.programfk and optionitem = 'asqse version'
			inner join codeduebydates on scheduledevent = 'IFSP/FGP'  --optionValue
			--inner join codeduebydates on scheduledevent = optionValue
			inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
			inner join worker fsw on fsw.workerpk = currentfswfk
			inner join workerprogram on workerfk = fsw.workerpk AND workerprogram.ProgramFK = ListItem
			inner join worker supervisor on supervisorfk = supervisor.workerpk
			inner join codelevel on codelevelpk = currentlevelfk
			left join asqse on asqse.hvcasefk = hvcasepk and asqse.programfk = caseprogram.programfk 
			and codeduebydates.interval = asqseTCAge
		where asqse.hvcasefk is NULL
			AND HVCase.TCDOD IS NULL
			and caseprogress >= 11
			and currentFSWFK = isnull(@workerfk,currentFSWFK)
			and supervisorfk = isnull(@supervisorfk,supervisorfk)
			and (dischargedate is null)

			and year(dateadd(dd,dueby,hvcase.IntakeDate)) = year(@rdate)
			and month(dateadd(dd,dueby,hvcase.IntakeDate)) = month(@rdate)

		ORDER BY IntakeDate
GO
