SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Jan 4, 2012>
-- Description:	<Converted FamSys report - Home Visit Achievement Rate - Aggregate>
--				04/29 Changed to NYS FSW Home Visit Record
-- Edit date: 10/11/2013 CP - workerprogram was NOT duplicating cases when worker transferred
--			  02/24/2015 jr - add support for Site and Case Filter criteria
-- =============================================
CREATE procedure [dbo].[rspNYSFSWHomeVisitRecord_Summary]
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
	(select rtrim(firstname)+' '+rtrim(lastname) as workername
					,hvr.workerfk
					,hvr.casefk
					,pc1id
					,startdate
					,enddate
					,hvr.levelname
					,(select max(hld.StartLevelDate)
						  from hvleveldetail hld
						  where hvr.casefk = hld.hvcasefk
							   and StartLevelDate <= @edate
							   and hvr.programfk = hld.programfk) as levelstart
					,reqvisit as expvisitcount
					,sum(case
							 when visittype <> '00010' then
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
							 when visittype = '00010' then
								 1
							 else
								 0
						 end) as attvisitcount
					,(dateadd(mi,sum(visitlengthminute),dateadd(hh,sum(visitlengthhour),'01/01/2001'))) DirectServiceTime
					,sum(visitlengthminute)+sum(visitlengthhour)*60 as visitlengthminute
					,sum(visitlengthhour) as visitlengthhour
					,dischargedate
					,pc1id+convert(char(10),hvr.workerfk) as pc1wrkfk --use for a distinct unique field for the OVER(PARTITION BY) above	
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
		 group by rtrim(firstname)+' '+rtrim(lastname)
				 ,hvr.workerfk
				 ,pc1id
				 ,startdate
				 ,enddate
				 ,hvr.levelname
				 ,reqvisit
				 ,dischargedate
				 ,hvr.casefk
				 ,hvr.programfk --,hld.StartLevelDate
	), 
	cteCaseCount 
	as 
	(select count(distinct casefk) as casecount
		from cteHVRecords
	),
	cteMain 
	as 
	(select workername
			 ,workerfk
			 ,pc1id
			 ,sum(visitlengthminute) as Minutes
			 ,sum(expvisitcount) as expvisitcount
			 ,min(startdate) as startdate
			 ,max(enddate) as enddate
			 ,max(levelstart) as levelstart
			 ,sum(actvisitcount) as actvisitcount
			 ,sum(inhomevisitcount) as inhomevisitcount
			 ,sum(attvisitcount) as attvisitcount
			 ,max(dischargedate) as dischargedate

			 --,sum(casecount) over (partition by pc1wrkfk) as CaseCount
			 --,sum(visitlengthminute) over (partition by pc1wrkfk) as Minutes
			 --,sum(expvisitcount) over (partition by pc1wrkfk) as expvisitcount
			 --,min(startdate) over (partition by pc1wrkfk) as startdate
			 --,max(enddate) over (partition by pc1wrkfk) as enddate
			 --,(select top 1 levelname
				--   from cteHVRecords
				--   where enddate <= @edate) as levelname
			 --,max(levelstart) over (partition by pc1wrkfk) as levelstart
			 --,sum(actvisitcount) over (partition by pc1wrkfk) as actvisitcount
			 --,sum(inhomevisitcount) over (partition by pc1wrkfk) as inhomevisitcount
			 --,sum(attvisitcount) over (partition by pc1wrkfk) as attvisitcount
			 --,max(dischargedate) over (partition by pc1wrkfk) as dischargedate

		from cteHVRecords
		group by workername
			,pc1wrkfk
			,workerfk
			,pc1id
	)
	
	-- make the aggregate table
	select workername
		  ,rtrim(LastName)+', '+rtrim(FirstName) as WorkerLastFirst
		  ,workerfk
		  ,pc1id
		  ,CaseCount
		  ,dateadd(yy,(2003-1900),0)+dateadd(mm,11-1,0)+6-1+dateadd(mi,minutes,0) as DirectServiceTime
		  ,floor(expvisitcount) as expvisitcount
		  ,startdate
		  ,enddate
		  ,levelstart
		  ,actvisitcount
		  ,inhomevisitcount
		  ,attvisitcount
		  ,dischargedate
		from cteMain
		inner join Worker w on workerfk=w.WorkerPK
		left outer join cteCaseCount on casecount=casecount
		where isnull(dischargedate, getdate()) > @sdate
		
end
GO
