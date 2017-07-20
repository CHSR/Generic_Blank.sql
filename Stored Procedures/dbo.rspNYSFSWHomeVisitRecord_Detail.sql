SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Jan 4, 2012>
-- Edit date: 7/10/2013 (Chris Papas) - cteMain levelname fix
-- Description:	<Converted FamSys report - Home Visit Achievement Rate - Aggregate>
--				04/29 Changed to NYS FSW Home Visit Record
-- Edit date: 10/11/2013 CP - workerprogram was NOT duplicating cases when worker transferred
--			  02/24/2015 jr - add support for Site and Case Filter criteria
-- =============================================
CREATE procedure [dbo].[rspNYSFSWHomeVisitRecord_Detail]
				(@programfk    varchar(max)    = null
					, @sdate        datetime
					, @edate        datetime
					, @supervisorfk int             = null
					, @workerfk     int             = null
					, @SiteFK int = null
					, @CaseFiltersPositive varchar(100) = ''
				)

as
begin

	if @programfk is null
	begin
		select @programfk =
			   substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
							  from HVProgram
							  for xml path ('')),2,8000)
	end
	set @programfk = REPLACE(@programfk,'"','');

	set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0
					   else @SiteFK
				  end
	set @CaseFiltersPositive = case	when @CaseFiltersPositive = '' then null
									else @CaseFiltersPositive
							   end;

	with cteHVRecords
	as
	(select distinct rtrim(firstname)+' '+rtrim(lastname) as workername
					,hvr.workerfk
					,count(distinct casefk) as casecount
					,pc1id
					,startdate
					,enddate
					,hvr.levelname
					,(select max(hld.StartLevelDate)
						  from hvleveldetail hld
						  where hvr.casefk = hld.hvcasefk
							   and StartLevelDate <= @edate
							   and hvr.programfk = hld.programfk) as levelstart
					,(reqvisit) as expvisitcount
					,sum(case
							 when visittype <> '0001' then
								 1
							 else
								 0
						 end) as actvisitcount
					,sum(case
							 when substring(visittype,1,1) = '1' or substring(visittype,2,1) = '1' then
								 1
							 else
								 0
						 end) as inhomevisitcount
					,sum(case
							 when visittype = '0001' then
								 1
							 else
								 0
						 end) as attvisitcount
					,(dateadd(mi,sum(visitlengthminute),dateadd(hh,sum(visitlengthhour),'01/01/2001'))) DirectServiceTime
					,sum(visitlengthminute)+sum(visitlengthhour)*60 as visitlengthminute
					,sum(visitlengthhour) as visitlengthhour
					,dischargedate
					,pc1id+convert(char(10),hvr.workerfk) as pc1wrkfk --use for a distinct unique field for the OVER(PARTITION BY) above	
					 ,hvr.casefk
		 from [dbo].[udfHVRecords](@programfk,@sdate,@edate) hvr
			inner join worker on workerpk = hvr.workerfk
			inner join workerprogram wp on wp.workerfk = workerpk
			inner join dbo.SplitString(@programfk,',') on wp.programfk = listitem
			inner join dbo.udfCaseFilters(@casefilterspositive, '', @programfk) cf on cf.HVCaseFK = hvr.casefk
			where case when @SiteFK = 0 then 1
							 when wp.SiteFK = @SiteFK then 1
							 else 0
						end = 1
					and workerpk = isnull(@workerfk,workerpk)
					and supervisorfk = isnull(@supervisorfk,supervisorfk)
					and startdate < enddate --Chris Papas 05/25/2011 due to problem with pc1id='IW8601030812'
		 group by firstname
				 ,lastname
				 ,hvr.workerfk
				 ,pc1id
				 ,startdate
				 ,enddate
				 ,hvr.levelname
				 ,reqvisit
				 ,dischargedate
				 ,hvr.casefk
				 ,hvr.programfk --,hld.StartLevelDate
	)
	,
	cteLevelChanges
	as
	(select casefk
		   ,count(casefk)-1 as LevelChanges
		 from cteHVRecords
		 group by casefk
	)
	,
	cteSummary
	as
	(select distinct workername
					,workerfk
					,pc1id
					,hvr.casefk
					,casecount
					,sum(visitlengthminute) over (partition by pc1wrkfk) as 'Minutes'
					,sum(expvisitcount) over (partition by pc1wrkfk) as expvisitcount
					,min(startdate) over (partition by pc1wrkfk) as 'startdate'
					,max(enddate) over (partition by pc1wrkfk) as 'enddate'
					,levelname
					,max(levelstart) over (partition by pc1wrkfk) as 'levelstart'
					,sum(actvisitcount) over (partition by pc1wrkfk) as actvisitcount
					,sum(inhomevisitcount) over (partition by pc1wrkfk) as inhomevisitcount
					,sum(attvisitcount) over (partition by pc1wrkfk) as attvisitcount
					,max(dischargedate) over (partition by pc1wrkfk) as 'dischargedate'
					,IntakeDate
					,case when TCDOB is null
							then EDC
						  else TCDOB
					end as TCDOB
					,LevelChanges
		 from cteHVRecords hvr
			 inner join cteLevelChanges on cteLevelChanges.casefk = hvr.casefk
			 inner join HVCase c on hvr.casefk = c.HVCasePK
)
	--07/10/2013 [Chris Papas], continual errors with getting the correct Level.
	-- both ,max(levelname) over (partition by pc1id) as levelname
	--and (SELECT TOP 1 levelname ORDER BY enddate) AS levelname, were returning the wrong levels in certain circumstances.
	--FIX is below and as follows: Row_Number() OVER (Partition By casefk ORDER BY [levelstart] DESC) as RowNum
	--END 7/10/2013 fix
	
	, cteMain as
	-- make the aggregate table
	(select workername
			,workerfk
			,pc1id
			,casecount
			,DirectServiceTime
			,expvisitcount
			,startdate
			,enddate
			,levelname
			,levelstart
			,actvisitcount
			,inhomevisitcount
			,attvisitcount
			,VisitRate
			,InHomeRate
			,dischargedate
			,IntakeDate
			,TCDOB
			,LevelChanges
			from (
				select distinct workername
					,workerfk
					,pc1id
					,casecount
					,dateadd(yy,(2003-1900),0)+dateadd(mm,11-1,0)+6-1+dateadd(mi,minutes,0) as DirectServiceTime
					,FLOOR(expvisitcount) AS expvisitcount
					,startdate
					,enddate
					,(select top 1 levelname
						  from hvleveldetail hld
						  where hld.hvcasefk = cteSummary.casefk
							   and hld.StartLevelDate = cteSummary.levelstart
							   ) as levelname
					,levelstart
					,actvisitcount
					,inhomevisitcount
					,attvisitcount
					,case
						 when actvisitcount is null or actvisitcount = 0
							 then
							 0
						 when expvisitcount is null or expvisitcount = 0
							 then
							 1
						 else
							 case
								 when (actvisitcount/(expvisitcount*1.000)) > 1
									 then
									 1
								 else
									 actvisitcount/(expvisitcount*1.000)
							 end
					 end as VisitRate
					,case
						 when inhomevisitcount is null or inhomevisitcount = 0
							 then
							 0
						 when expvisitcount is null or expvisitcount = 0
							 then
							 1
						 else
							 case
								 when (inhomevisitcount/(case when expvisitcount>=actvisitcount then actvisitcount else expvisitcount end*1.000)) > 1
									 then
									 1
								 else
									 inhomevisitcount/(case when expvisitcount>=actvisitcount then actvisitcount else expvisitcount end*1.000)
							 end
					 end as InHomeRate
					,dischargedate
					,IntakeDate
					,TCDOB
					,LevelChanges
				from cteSummary
			) a 
	)
	
	
	select *
		  ,case
			   when expvisitcount = 0
				   then
				   0
			   when VisitRate >= .9 and InHomeRate >= .75
				   then
				   3
			   when VisitRate >= .75 and InHomeRate >= .75
				   then
				   2
			   else
				   1
		   end as ScoreForCase
		from cteMain
		where isnull(dischargedate, getdate()) > @sdate
		order by WorkerName
				,pc1id

end
GO
