SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <July 20, 2012>
-- Description:	<gets you data for Enrolled Program Caseload detail info>
-- exec [rspEnrolledProgramCaseloadDetail] 3,'01/01/2013','03/31/2013', null, null
-- exec [rspEnrolledProgramCaseloadDetail] 37,'01/01/2013','03/31/2013', null, null
-- Edit date: 10/11/2013 CP - workerprogram was duplicating cases when worker transferred
--            added this code to the workerprogram join condition: AND wp.programfk = listitem
-- =============================================
CREATE procedure [dbo].[rspEnrolledProgramCaseloadDetail]
(
    @programfk           varchar(max)    = null,
    @sdate               datetime,
    @edate               datetime,
    @sitefk              int             = null,
    @casefilterspositive varchar(200)                                                  
                                                        
)

as
begin

	set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0 else @SiteFK end
	set @casefilterspositive = case when @casefilterspositive = '' then null else @casefilterspositive end

	-- Let us declare few table variables so that we can manipulate the rows at our will
	-- Note: Table variables are a superior alternative to using temporary tables 
	---------------------------------------------
	-- Initially, get the subset of data that we are interested in ... Good Practice ... Khalsa 
	-- table variable for holding Init Required Data
	declare @tblInitRequiredData table(
		[HVCasePK] [int],
		[IntakeDate] [datetime],
		[TCDOB] [datetime],
		[TCDOD] [datetime],
		[TCNumber] [int],
		[DischargeDate] [datetime],
		[DischargeReason] [char](2),
		[SiteFK] [int],
		[PC1ID] [char](13),
		[LevelChangeStar] [char](1)
	)


	declare @tblInitRequiredDataTemp table(
		[HVCasePK] [int],
		[IntakeDate] [datetime],
		[TCDOB] [datetime],
		[TCDOD] [datetime],
		[TCNumber] [int],
		[DischargeDate] [datetime],
		[DischargeReason] [char](2),
		[SiteFK] [int],
		[PC1ID] [char](13),
		[LevelChangeStar] [char](1)

	);
	
	with cteLevelChange
	as
	(
	select
		  count(*) count
		 ,hd.hvcasefk
		from HVLevelDetail hd
			inner join CaseProgram cp on cp.HVCaseFK = hd.HVCaseFK
			inner join dbo.SplitString(@programfk,',') on cp.programfk = listitem
		where hd.EndLevelDate between @sdate and @edate
			 and DischargeDate <> hd.EndLevelDate
		group by hd.hvcasefk
		having count(*) > 0
	)

	-- Fill this table i.e. @tblInitRequiredData as below
	insert into @tblInitRequiredDataTemp (
			   [HVCasePK]
			  ,[IntakeDate]
			  ,[TCDOB]
			  ,[TCDOD]
			  ,[TCNumber]
			  ,[DischargeDate]
			  ,[DischargeReason]
			  ,[SiteFK]
			  ,[PC1ID]
			  ,[LevelChangeStar]
			   )
		select h.HVCasePK
			 ,h.IntakeDate
			 ,case
				  when h.tcdob is not null then
					  h.tcdob
				  else
					  h.edc
			  end as tcdob
			 ,h.TCDOD
			 ,h.TCNumber
			 ,cp.DischargeDate
			 ,cp.DischargeReason
			 ,case when wp.SiteFK is null then 0 else wp.SiteFK end as SiteFK
			 ,cp.PC1ID
			 ,case when lc.hvcasefk is null then '' else '*' end as levelchange
			from HVCase h
				inner join CaseProgram cp on h.HVCasePK = cp.HVCaseFK
				inner join dbo.SplitString(@programfk,',') on cp.programfk = listitem
				inner join dbo.udfCaseFilters(@casefilterspositive,'', @programfk) cf on cf.HVCaseFK = HVCasePK
				inner join Worker w on w.WorkerPK = cp.CurrentFSWFK
				inner join WorkerProgram wp on wp.WorkerFK = w.WorkerPK AND wp.programfk = listitem
				left join cteLevelChange lc on lc.hvcasefk = cp.HVCaseFK
			where (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
			
			

	insert into @tblInitRequiredData (
			   [HVCasePK]
			  ,[IntakeDate]
			  ,[TCDOB]
			  ,[TCDOD]
			  ,[TCNumber]
			  ,[DischargeDate]
			  ,[DischargeReason]
			  ,[SiteFK]
			  ,[PC1ID]
			  ,[LevelChangeStar]
			   )
		select *
			from @tblInitRequiredDataTemp
			

	---------------------------------------------
	---------------------------------------------
	--- **************************************** ---
	-- Part 1: Families Enrolled at the beginning of the period	(QUARTERLY STATS)
	-- exec [rspEnrolledProgramCaseloadDetail] 1,'06/01/2010','08/31/2010', null, null
	;
	with cteLevelChangeStatus
	as
	(select irq.HVCasePK
			 ,(select max(convert(varchar(12),StartLevelDate,112)+LEFT(levelname,20))
				   from hvleveldetail hld
				   where irq.HVCasePK = hld.hvcasefk
						and StartLevelDate <= @edate) as selectname
			 ,LevelChangeStar
		from @tblInitRequiredData irq
		where IntakeDate is not null
			 and IntakeDate <= @edate
			 and (DischargeDate is null
			 or DischargeDate >= @sdate)
	)

	select distinct 
		  irq.PC1ID
		 ,IntakeDate
		 ,irq.DischargeDate
		 ,irq.TCDOB
		 ,substring(lcs.selectname,9,len(lcs.selectname))+lcs.LevelChangeStar as CurrentLevel
		from @tblInitRequiredData irq
			left join cteLevelChangeStatus lcs on lcs.HVCasePK = irq.HVCasePK
			inner join CaseProgram cp on HVCaseFK = irq.HVCasePK
			inner join WorkerProgram wp on wp.WorkerFK = CurrentFSWFK -- get SiteFK,
			inner join dbo.udfCaseFilters(@casefilterspositive,'', @programfk) cf on cf.HVCaseFK = irq.HVCasePK
		where IntakeDate is not null
		--and IntakeDate <= @edate
			 and IntakeDate <= @sdate -- changed from edate to sdate
			 and (irq.DischargeDate is null
			 or irq.DischargeDate >= @sdate)
			 and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
		order by irq.PC1ID

end
GO
