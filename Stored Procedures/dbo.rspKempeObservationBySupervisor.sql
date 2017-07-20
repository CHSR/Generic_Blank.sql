SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:    <Jay Robohn>
-- Create date: <Feb 20, 2012>
-- Description: <copied from FamSys - see header below>
-- Edit date: 5/17/17 Bug fix - Report not displaying FAWs that have Kempes and no supervisor observations (Benjamin Simmons)
-- Edit date: 5/30/17 Bug fix - Supervisor not always displaying correctly for FAWs that have no supervisor observations
-- =============================================
CREATE procedure [dbo].[rspKempeObservationBySupervisor]
(
    @programfk varchar(max)	= null,
    @sitefk		 int		= null
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
	as (select distinct FAWFK, ProgramFK
			from Kempe
				inner join dbo.SplitString(@programfk,',') on Kempe.programfk = listitem
			where datediff(m,KempeDate,getdate()) <= 12
	)
	--select * from cteWorkerCohort inner join dbo.Worker on Worker.WorkerPK = FAWFK order by FAWFK
	,
	
	cteKempes
	as (select Kempe.KempeDate
			  ,hvcasepk
			  ,wc.FAWFK
			from cteWorkerCohort wc
				inner join Kempe on Kempe.FAWFK = wc.FAWFK --and SupervisorObservation=1
				inner join HVCase on HVCase.HVCasePK = Kempe.hvcasefk
			where  --datediff(m,Kempe.KempeDate,getdate()) <= 12 and
				SupervisorObservation=1
	),

	--Filter the observed kempes
	cteFilteredKempes
	as(select cp.PC1ID
			  ,KempeDate
			  ,hvcasepk
			  ,FAWFK
			  ,w.WorkerPK workerPK
			  ,w.FirstName workerFirstName
			  ,w.LastName workerLastName
			  ,supervisor.FirstName supervisorFirstName
			  ,supervisor.LastName supervisorLastName
			  ,RowNumber = row_number() over (partition by FAWFK order by KempeDate desc)
			from cteKempes observed
			inner join CaseProgram cp on cp.HVCaseFK = observed.hvcasepk --and cp.CurrentFAWFK = top5.FAWFK
			inner join dbo.SplitString(@programfk,',') on cp.programfk = ListItem --Restrict to the programs selected
			right join Worker w on w.WorkerPK = observed.FAWFK --Include workers who do not have observed kempes
			left outer join WorkerProgram wp on wp.WorkerFK = w.WorkerPK --and wp.ProgramFK = ListItem
			left outer join Worker supervisor on wp.SupervisorFK = supervisor.WorkerPK
			where w.WorkerPK in (select FAWFK from cteWorkerCohort)
				and wp.TerminationDate is null
				and w.LastName <> 'Transfer Worker'
				and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
				and (cp.TransferredtoProgramFK is null or cp.TransferredtoProgramFK = ListItem) --Eliminate transfer cases
	)
	select coalesce(pc1id,'No Kempe Observations') pc1id
		  ,KempeDate
		  ,hvcasepk
		  ,(select min(KempeDate) KempeDate
				from Kempe
				where FAWFK = workerPK) KempeDate_min
		  ,(select max(KempeDate) KempeDate
				from Kempe
				where FAWFK = workerPK) KempeDate_max
		  ,RTRIM(workerFirstName)+' '+RTRIM(workerLastName) FAW
		  ,coalesce(rtrim(supervisorFirstName)+' '+RTRIM(supervisorLastName), 'None') supervisor
		from cteFilteredKempes
		where cteFilteredKempes.RowNumber <= 5
		order by supervisorLastName
				,workerLastName
				,KempeDate desc
				,hvcasepk
GO
