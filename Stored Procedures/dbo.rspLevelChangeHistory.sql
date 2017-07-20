SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Jan 18, 2012>
-- Description:	<HFNY MIS report - Level Change History>
-- Edit date: 10/11/2013 CP - workerprogram was duplicating cases when worker transferred
-- =============================================
CREATE procedure [dbo].[rspLevelChangeHistory](@programfk varchar(max)    = null,
                                               @pc1id     varchar(13)     = null, 
                                               @WorkerFK int = null,
                                               @SupervisorFK int = null
                                               )

as

--DECLARE @programfk varchar(max)    = '5'
--DECLARE @pc1id     varchar(13)     = null
--DECLARE @WorkerFK int = null
--DECLARE @SupervisorFK int = null

begin

	if @programfk is null
	begin
		select @programfk =
			   substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
							  from HVProgram
							  for xml path ('')),2,8000)
	end;

	if @pc1id = ''
	begin
		set @pc1id = nullif(@pc1id,'')
	end;
	
	select 
	      LTRIM(RTRIM(supervisor.firstname))+' '+LTRIM(RTRIM(supervisor.lastname)) supervisor
		  ,LTRIM(RTRIM(fsw.firstname))+' '+LTRIM(RTRIM(fsw.lastname)) worker
	      ,PC1ID
		  ,levelname
		  ,StartLevelDate
		  ,isnull(EndLevelDate,current_timestamp) as EndLevelDate
		  ,datediff(day,StartLevelDate,isnull(EndLevelDate+1,current_timestamp)) as DaysOnLevel
		  ,DischargeDate
		from HVLevelDetail hld
			inner join CaseProgram cp on cp.HVCaseFK = hld.hvcasefk
			--inner join WorkerProgram wp on wp.WorkerFK = cp.CurrentFSWFK
			--inner join dbo.SplitString(@programfk,',') on hld.programfk = listitem (old code)
			--use cp not hld to show ALL history for a transfer case 
			inner join dbo.SplitString(@programfk,',') on cp.programfk = listitem
			
			--inner join CaseProgram d on d.HVCaseFK = a.HVCaseFK
			inner join worker fsw on cp.CurrentFSWFK = fsw.workerpk
			inner join workerprogram wp on wp.workerfk = fsw.workerpk AND wp.programfk = listitem
			inner join worker supervisor on wp.supervisorfk = supervisor.workerpk
			
		where PC1ID = isnull(@PC1ID,pc1id)
			  and CurrentFSWFK = isnull(@WorkerFK, CurrentFSWFK)
			  and SupervisorFK = isnull(@SupervisorFK, SupervisorFK)
		      AND (CASE WHEN (@pc1id IS NULL AND DischargeDate IS NOT NULL) THEN 0 ELSE 1 END = 1)
		order by supervisor, worker, PC1ID, StartLevelDate desc

end
GO
