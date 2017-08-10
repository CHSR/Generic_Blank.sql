SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Feb 5, 2012>
-- Description:	<report: Use of Creative Outreach - Detail>
--				Moved from FamSys - 02/05/12 jrobohn
-- Edit date: 10/11/2013 CP - workerprogram was duplicating cases when worker transferred
--            added this code to the workerprogram join condition: AND wp.programfk = listitem
-- =============================================
CREATE procedure [dbo].[rspCreativeOutreach_Detail]
(
    @programfk varchar(max)    = null,
    @sdate     datetime        = null,
    @edate     datetime        = null,
    @casefilterspositive varchar(100) = '',
    @sitefk    int			   = 0
)
as
	if @programfk is null
	begin
		select @programfk = substring((select ','+ltrim(rtrim(str(HVProgramPK)))
						    from HVProgram
						    for xml path ('')),2,8000)
	end

	set @programfk = replace(@programfk,'"','')
	set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0 else @SiteFK end
	set @casefilterspositive = case when @casefilterspositive = '' then null else @casefilterspositive end

	declare @ClosedOnXLess3NoMove int

	select @ClosedOnXLess3NoMove = count(distinct case
			  when datediff(day,e4.LevelAssignDate,dischargedate) < 93 and CurrentLevelFK IN (23,1024,1025,1026,1027,1028,1029) -- level X-term
				  and (dischargedate is not null or dischargedate < @edate) and DischargeCode not in (7,17,18,20,21,23,25,36,37) then
				  PC1ID
		  end)
		from hvcase
			inner join caseprogram on caseprogram.hvcasefk = hvcasepk
			inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
			left join (select hvlevel.hvlevelpk
							 ,hvlevel.hvcasefk
							 ,hvlevel.programfk
							 ,hvlevel.levelassigndate
							 ,levelname
							 ,caseweight
					   from hvlevel
					    inner join codelevel on codelevelpk = levelfk
						where LevelFK IN (22,24,25,26,27,28,29)) e4 on e4.hvcasefk = caseprogram.hvcasefk and e4.programfk = caseprogram.programfk
		   left join codeDischarge on DischargeCode = caseprogram.DischargeReason
		   inner join WorkerProgram wp on CurrentFSWFK = WorkerFK
		   inner join dbo.udfCaseFilters(@casefilterspositive, '', @programfk) cf on cf.HVCaseFK = HVCasePK
		where caseprogress >= 9
			 and intakedate <= @edate
			 and CaseProgram.DischargeDate > @sdate
			 and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)

	-- Length of Service on Level X at DC
	select PC1ID
		  ,'Closed on '+convert(varchar(12),dischargedate,101) as CurrentStatus
		  ,codeDischarge.dischargereason as ReasonClosed
		  ,datediff(day,e3.levelassigndate,dischargedate) as DaysOnLevelX
		  ,rtrim(Worker.FirstName)+' '+rtrim(Worker.LastName) as current_worker
		  ,@ClosedOnXLess3NoMove as ClosedOnXLess3NoMove
		from hvcase
			inner join caseprogram on caseprogram.hvcasefk = hvcasepk
			inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
			inner join (select hvlevel.hvlevelpk
							  ,hvlevel.hvcasefk
							  ,hvlevel.programfk
							  ,hvlevel.levelassigndate
							  ,levelname
							  ,caseweight
			from hvlevel
				inner join codelevel on codelevelpk = levelfk
			where LevelFK IN (22,24,25,26,27,28,29)) e3 on e3.hvcasefk = caseprogram.hvcasefk and e3.programfk = caseprogram.programfk
			inner join codeDischarge on DischargeCode = caseprogram.DischargeReason
			inner join Worker on Worker.WorkerPK = CaseProgram.CurrentFSWFK
		    inner join WorkerProgram wp on CurrentFSWFK = WorkerFK AND wp.programfk = listitem
			inner join dbo.udfCaseFilters(@casefilterspositive, '', @programfk) cf on cf.HVCaseFK = HVCasePK
		where caseprogress >= 9
			 and intakedate <= @edate
			 and datediff(day,e3.LevelAssignDate,dischargedate) < 93
			 and CurrentLevelFK IN (23,1024,1025,1026,1027,1028,1029) -- level X-term
			 and (dischargedate is not null
			 or dischargedate < @edate)
			 and DischargeCode not in (7,17,18,20,21,23,25,36,37)
			 and CaseProgram.DischargeDate > @sdate
			 and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
		order by PC1ID
GO
