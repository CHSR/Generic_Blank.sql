SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Feb 5, 2012>
-- Description:	<report: Use of Creative Outreach - Aggregate>
--				Moved from FamSys - 02/05/12 jrobohn
-- Edit date: 10/11/2013 CP - workerprogram was duplicating cases when worker transferred
--            added this code to the workerprogram join condition: AND wp.programfk = listitem
-- =============================================
CREATE procedure [dbo].[rspCreativeOutreach_Aggregate]
(
    @programfk varchar(max)    = null,
    @sdate     datetime        = null,
    @edate     datetime        = null,
    @casefilterspositive varchar(100) = '',
    @sitefk	   int			   = 0
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

	select families_served
		  ,x
		  ,x/x as x_percent
		  ,XAndOpen
		  ,XAndOpen/x as XAndOpen_percent
		  ,ClosedOnXLess3
		  ,ClosedOnXLess3/x as ClosedOnXLess3_percent
		  ,ClosedOnXGreater3
		  ,ClosedOnXGreater3/x as ClosedOnXGreater3_percent
		  ,ClosedOnXLess3NoMove
		  ,ClosedOnXLess3NoMove/x as ClosedOnXLess3NoMove_percent
		  ,ReXOpen
		  ,ReXOpen/x as ReXOpen_percent
		  ,ReXClosed
		  ,ReXClosed/x as ReXClosed
		from (
		
	    	select families_served = count(distinct pc1id)
			,x = count(distinct e4.HVCaseFK)
			,XAndOpen = count(distinct case
				     when (dischargedate is null or DischargeDate > @edate) and CurrentLevelFK IN (22,24,25,26,27,28,29) then
					 PC1ID end)*1.0
			,ClosedOnXLess3 = count(distinct case
					 when datediff(day,e4.LevelAssignDate,dischargedate) < 93 and CurrentLevelFK IN (23,1024,1025,1026,1027,1028,1029) -- level X-term
					 and (dischargedate is not null or dischargedate <= @edate) and DischargeCode in (7,17,18,20,21,23,25,36,37) then
					 PC1ID end)*1.0
			,ClosedOnXGreater3 = count(distinct case
	                 when datediff(day,e4.LevelAssignDate,dischargedate) >= 93 and CurrentLevelFK IN (23,1024,1025,1026,1027,1028,1029) -- level X-term
					 and (dischargedate is not null or dischargedate <= @edate) then
					 PC1ID end)*1.0
			,ClosedOnXLess3NoMove = count(distinct case
				     when datediff(day,e4.LevelAssignDate,dischargedate) < 93 and CurrentLevelFK IN (23,1024,1025,1026,1027,1028,1029) -- level X-term
					 and (dischargedate is not null and dischargedate <= @edate) and DischargeCode not in (7,17,18,20,21,23,25,36,37) then
					 PC1ID end)*1.0
			,ReXOpen = count(distinct case
				     when (dischargedate is null or DischargeDate > @edate) and CaseProgram.CurrentLevelDate > e4.LevelAssignDate 
				     and CaseProgram.CurrentLevelFK not in (22,24,25,26,27,28,29,23,1024,1025,1026,1027,1028,1029) then
				     PC1ID end)*1.0
			,ReXClosed = count(distinct case
					 when (dischargedate is not null and dischargedate < @edate) and 
					 CaseProgram.CurrentLevelDate > e4.LevelAssignDate and CaseProgram.CurrentLevelFK not in (22,24,25,26,27,28,29,23,1024,1025,1026,1027,1028,1029) then
					 PC1ID end)*1.0

			  from hvcase
				  inner join caseprogram on caseprogram.hvcasefk = hvcasepk
				  inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
				  left join (
				            select hvlevel.hvcasefk
								   ,hvlevel.programfk
								   ,codelevel.levelname
								   ,max(hvlevel.levelassigndate) [levelassigndate]
								 from hvlevel
									 inner join codelevel on codelevelpk = levelfk
								 where LevelFK IN (22,24,25,26,27,28,29)
								 group by hvlevel.hvcasefk
										 ,hvlevel.programfk
										 ,codelevel.levelname
							) e4 on e4.hvcasefk = caseprogram.hvcasefk and e4.programfk = caseprogram.programfk
				  left join codeDischarge on DischargeCode = caseprogram.DischargeReason
				  inner join dbo.udfCaseFilters(@casefilterspositive, '', @programfk) cf on cf.HVCaseFK = HVCasePK
				  inner join WorkerProgram wp on CurrentFSWFK = WorkerFK AND wp.programfk = listitem
			  where caseprogress >= 9
				   and intakedate <= @edate
				   and (dischargedate is null
				   or (dischargedate between @sdate and @edate))
				   and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
			) t
GO
