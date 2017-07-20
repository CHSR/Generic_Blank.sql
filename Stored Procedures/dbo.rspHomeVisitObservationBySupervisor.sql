SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:    <Jay Robohn>
-- Create date: <Feb 20, 2012>
-- Description: <copied from FamSys - see header below>
-- Edit date: 5/17/17 Bug fix - Report not displaying FSWs that have Home Visits and no supervisor observations and
-- is showing home visits without observations (Benjamin Simmons)
-- Edit date: 5/30/17 Bug fix - Supervisor not always displaying correctly for FSWs that have no home visit observations
-- =============================================
CREATE procedure [dbo].[rspHomeVisitObservationBySupervisor]
(
    @programfk varchar(max)    = null,
    @sitefk		 int		   = null
)
as
	if @programfk is null
	begin
		select @programfk = substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end

	set @programfk = REPLACE(@programfk,'"','')
	set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0 else @SiteFK end;

	with cteWorkerCohort
	as (select distinct FSWFK
			from HVLog
				inner join dbo.SplitString(@programfk,',') on HVLog.programfk = listitem
			where datediff(month,cast(VisitStartTime AS DATE),getdate()) <= 12
	),
	cteHvlogs (VisitStartTime,hvcasepk,visitType,FSWFK)
	as (select VisitStartTime
			  ,hvcasepk
			  ,visitType
			  ,hvlog.FSWFK
			from hvlog
				left join HVCase on HVCase.HVCasePK = hvlog.hvcasefk
				inner join cteWorkerCohort on hvlog.FSWFK = cteWorkerCohort.FSWFK
				inner join dbo.SplitString(@programfk,',') on hvlog.programfk = listitem
			where -- datediff(year,VisitStartTime,getdate()) <= 1 and 
				SupervisorObservation = 1
	),
	--Filter the observed hvlogs
	cteFilteredHvLogs
	as(select cp.PC1ID
			  ,VisitStartTime
			  ,hvcasepk
			  ,visitType
			  ,FSWFK
			  ,w.WorkerPK workerPK
			  ,w.FirstName workerFirstName
			  ,w.LastName workerLastName
			  ,supervisor.FirstName supervisorFirstName
			  ,supervisor.LastName supervisorLastName
			  ,RowNumber = row_number() over (partition by FSWFK order by VisitStartTime desc)
			from cteHvlogs observed
			inner join CaseProgram cp on cp.HVCaseFK = observed.hvcasepk     --and cp.CurrentFSWFK = top7.FSWFK
			inner join dbo.SplitString(@programfk,',') on cp.programfk = ListItem --Restrict to the programs selected
			right join Worker w on w.WorkerPK = observed.FSWFK --Include workers who do not have observed home visits
			left outer join WorkerProgram wp on wp.WorkerFK = w.WorkerPK --and wp.ProgramFK = ListItem
			left outer join Worker supervisor on wp.SupervisorFK = supervisor.WorkerPK
			where w.WorkerPK in (select FSWFK from cteWorkerCohort)
				and wp.TerminationDate is null
				and w.LastName <> 'Transfer Worker'
				and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
				and (cp.TransferredtoProgramFK is null or cp.TransferredtoProgramFK = ListItem) --Eliminate transfer cases

	)
	select coalesce(pc1id,'No Home Visit Observations') pc1id
		  ,VisitStartTime
		  ,hvcasepk
		  ,(select min(VisitStartTime) VisitStartTime
				from hvlog
				where FSWFK = workerPK
				group by fswfk) hvdate_min
		  ,(select max(VisitStartTime) VisitStartTime
				from hvlog
				where FSWFK = workerPK
				group by fswfk) hvdate_max
		  ,RTRIM(workerFirstName)+' '+RTRIM(workerLastName) fsw
		  ,RTRIM(supervisorFirstName)+' '+RTRIM(supervisorLastName) supervisor
		  ,case
				when substring(visitType,1,1) = '1' or substring(visitType,2,1) = '1' then
					'In Home'
				when substring(visitType,3,1) = '1' then
					'Out of Home'
				when visitType is null then
					''
				else
					'Attempted - Family not home or unable to meet after visit to home'
				end as visitType
		from cteFilteredHvLogs allHvLogs
		where allHvLogs.RowNumber <= 7 --select only 7
		order by supervisorLastName
				,workerLastName
				,VisitStartTime desc
				,hvcasepk

GO
