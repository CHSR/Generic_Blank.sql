SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:    <Jay Robohn>
-- Create date: <Feb 20, 2012>
-- Description: <Report: Program caseload summary>
-- rspProgramCaseLoadSummary_delete '02/21/2014', 23


-- =============================================
CREATE procedure [dbo].[rspProgramCaseLoadSummary_delete]
(
    @rpdate    datetime,
    @programfk varchar(max)    = null
)
as
	if @programfk is null
	begin
		select @programfk = substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end

	set @programfk = REPLACE(@programfk,'"','')

	select pc1id
		  ,rtrim(e3.levelname) levelname
		  ,e3.caseweight
		  ,rtrim(worker.firstname) as wfname
		  ,rtrim(worker.lastname) as wlname
		  ,worker.workerpk
		  ,startassignmentdate
		  ,endassignmentdate
		  ,levelassigndate
		-- get cases at all levels (level prior to intake are never in the hvlevel table)
		from 

--#region Main inner select 
(select hvlevel.hvcasefk
					,hvlevel.programfk
					,hvlevel.levelassigndate
					,levelname
					,caseweight
				  from hvlevel
					  inner join codelevel on codelevelpk = levelfk
					  inner join (select hvcasefk
										,programfk
										,max(levelassigndate) as levelassigndate
									  from hvlevel h2
									  where levelassigndate <= @rpdate
									  group by hvcasefk
											  ,programfk) e2 on e2.hvcasefk = hvlevel.hvcasefk and e2.programfk = hvlevel.programfk and e2.levelassigndate = hvlevel.levelassigndate
			  union
			  -- get cases at preintake level
			  select cp.hvcasefk
					,cp.programfk
					,fswassigndate
					,'Preintake'
					,caseweight
				  from hvcase
					  inner join caseprogram cp on cp.hvcasefk = hvcasepk
					  inner join (select hvcasefk
										,programfk
										,max(kempedate) kempedate
										,max(fswassigndate) fswassigndate
									  from preassessment
									  group by hvcasefk
											  ,programfk) p on cp.hvcasefk = p.hvcasefk and cp.programfk = p.programfk
					  left outer join hvlevel hl on hl.hvcasefk = cp.hvcasefk and hl.programfk = cp.programfk and hl.levelassigndate <= @rpdate
					  inner join codelevel on codelevelpk = 7
				  where (intakedate is null or intakedate > @rpdate)
					   and (dischargedate is null or dischargedate > @rpdate)
					   and (fswassigndate is not null and fswassigndate < @rpdate)
					   and hl.hvlevelpk is null
			  union
			  -- get cases at preintake-enroll level
			  select cp.hvcasefk
					,cp.programfk
					,fswassigndate
					,'Preintake'
					,caseweight
				  from hvcase
					  inner join caseprogram cp on cp.hvcasefk = hvcasepk
					  inner join (select hvcasefk
										,programfk
										,max(kempedate) kempedate
										,max(fswassigndate) fswassigndate
									  from preassessment
									  group by hvcasefk
											  ,programfk) p on cp.hvcasefk = p.hvcasefk and cp.programfk = p.programfk
					  left outer join hvlevel hl on hl.hvcasefk = cp.hvcasefk and hl.programfk = cp.programfk and hl.levelassigndate <= @rpdate
					  inner join codelevel on codelevelpk = 8
				  where (intakedate is not null or intakedate <= @rpdate)
					   and (dischargedate is null or dischargedate > @rpdate)
					   and (fswassigndate is not null and fswassigndate < @rpdate)
					   and hl.hvlevelpk is null
					) e3
--#endregion 
			inner join caseprogram on e3.hvcasefk = caseprogram.hvcasefk and e3.programfk = caseprogram.programfk
			inner join workerassignmentdetail wad on wad.programfk = caseprogram.programfk and wad.hvcasefk = caseprogram.hvcasefk  -- and levelassigndate between startassignmentdate and isnull(endassignmentdate,levelassigndate)
			inner join worker
					  --on workerpk = wad.workerfk
					  on workerpk = caseprogram.currentfswfk
			inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
		where (dischargedate is null
			 or dischargedate >= @rpdate)
			 
			 and rtrim(worker.firstname) like 'Matthew'
		order by pc1id
				--,startassignmentdate
				--,wlname
				--,wfname
				
				
-- rspProgramCaseLoadSummary_delete '02/21/2014', 23		
-- rspProgramCaseLoadSummary_delete '12/21/2013', 23				
				

--select pc1id, rtrim(e3.levelname) levelname, e3.caseweight,
--	rtrim(worker.firstname) as wfname, rtrim(worker.lastname) as wlname, worker.workerpk, 
--startassignmentdate, endassignmentdate, levelassigndate
--from (select hvlevel.hvlevelpk, hvlevel.hvcasefk, hvlevel.programfk, hvlevel.levelassigndate, levelname, caseweight
--	from hvlevel
--	inner join codelevel
--	on codelevelpk = levelfk
--	inner JOIN (
--		SELECT hvcasefk, programfk, MAX(levelassigndate) AS levelassigndate
--		FROM hvlevel h2
--		where levelassigndate <= @rpdate
--		GROUP BY hvcasefk, programfk) e2
--	on e2.hvcasefk = hvlevel.hvcasefk
--	and e2.programfk = hvlevel.programfk
--	and e2.levelassigndate = hvlevel.levelassigndate
--) e3
--inner join caseprogram
--on e3.hvcasefk = caseprogram.hvcasefk
--and e3.programfk = caseprogram.programfk
--inner join workerassignmentdetail wad
--on wad.programfk = caseprogram.programfk
--and wad.hvcasefk = caseprogram.hvcasefk
--and levelassigndate between startassignmentdate and isnull(endassignmentdate, levelassigndate)
--inner join worker
--on workerpk = wad.workerfk
--INNER JOIN dbo.SplitString(@programfk,',')
--ON caseprogram.programfk  = listitem
--where (dischargedate is null
--or dischargedate >= @rpdate)
--order by pc1id, startassignmentdate, wlname, wfname
--
----select pc1id,rtrim(cl.levelname) levelname,cl.caseweight,rtrim(worker.firstname) as wfname,rtrim(worker.lastname) as wlname, worker.workerpk
----from (select * from codeLevel where caseweight is not null) cl
----left outer join caseprogram
----on caseprogram.currentLevelFK=cl.codeLevelPK
----inner join worker
----on  caseprogram.currentFSWFK=worker.workerpk
----inner join workerprogram wp
----on wp.workerfk=worker.workerpk 
----and wp.programfk=caseprogram.programfk
----INNER JOIN dbo.SplitString(@programfk,',')
----ON caseprogram.programfk  = listitem
----where dischargedate is null
----and currentleveldate <= @rpdate
----order by wlname,wfname
--
----select pc1id,rtrim(cl.levelname) levelname,cl.caseweight,rtrim(worker.firstname) as wfname,rtrim(worker.lastname) as wlname, worker.workerpk
----from (select * from codeLevel where caseweight is not null) cl
----left outer join
----caseprogram
----on caseprogram.currentLevelFK=cl.codeLevelPK
----inner join worker
----on  caseprogram.currentFSWFK=worker.workerpk
----inner join workerprogram wp
----on wp.workerfk=worker.workerpk 
----and wp.programfk=caseprogram.programfk
----INNER JOIN dbo.SplitString(@programfk,',')
----ON caseprogram.programfk  = listitem
----
----left join (select hvlevel.hvlevelpk, hvlevel.hvcasefk, hvlevel.programfk, hvlevel.levelassigndate, levelname, caseweight
----	from hvlevel
----	inner join codelevel
----	on codelevelpk = levelfk
----	inner JOIN (
----		SELECT hvcasefk, programfk, MAX(levelassigndate) AS levelassigndate
----		FROM hvlevel h2
----		GROUP BY hvcasefk, programfk) e2
----	on e2.hvcasefk = hvlevel.hvcasefk
----	and e2.programfk = hvlevel.programfk
----	and e2.levelassigndate = hvlevel.levelassigndate) e3
----on e3.hvcasefk = caseprogram.hvcasefk
----and e3.programfk = caseprogram.programfk
----
----where dischargedate is null
----and levelassigndate <= @rpdate
----order by pc1id, wlname,wfname
GO
