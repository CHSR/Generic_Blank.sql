SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Chris Papas
-- Create date: 10/22/2010
-- Description:	Report - 1.1.F Timing of First Home Visit
-- moved from FamSys Feb 20, 2012 by jrobohn
-- Edit date: 10/11/2013 CP - workerprogram was duplicating cases when worker transferred
--            added this code to the workerprogram join condition: AND wp.programfk = listitem
--
-- =============================================
CREATE procedure [dbo].[rspFirstHomeVisit_Detail]
(
    @programfk varchar(max)    = null,
    @Case      varchar(50)     = null,--figure the Case Filters out later
    @STDate    datetime,
    @EndDate   datetime, 
    @SiteFK	   int,
    @posclause varchar(200),
    @negclause varchar(200)
)
as
	if @programfk is null
	begin
		select @programfk = substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end

	set @programfk = REPLACE(@programfk,'"','')
	--set @SiteFK = isnull(@SiteFK, 0)
	set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0 else @SiteFK end

	begin
		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		set nocount on;

		select *
			from (select IntakeDate
						,PC1ID
						,ProgramFK 
						,t.hvcasepk
						,rtrim(FirstName) as FirstName
						,rtrim(Lastname) as Lastname
						,t.hvdate
						,case t.tcdob
							 when t.tcdob then
								 t.tcdob
							 else
								 t.edc
						 end as tcdob
						,datediff(day,case t.tcdob
										  when t.tcdob then
											  t.tcdob
										  else
											  t.edc
									  end,HVDate) as numdays
					  from CaseProgram
						  right join (select min(VisitStartTime) as hvdate
											,hvcasepk
											,tcdob
											,edc
										  from hvlog
											  left join HVCase on HVCase.HVCasePK = hvlog.hvcasefk
											  inner join CaseProgram cp on cp.HVCaseFK = HVCase.HVCasePK
											  
											  -- hvlog not limit to current programfk (for transfer cases)
											  inner join dbo.SplitString(@programfk,',') on 1 = 1 --hvlog.programfk = listitem
											  
											  inner join WorkerProgram wp on WorkerFK = CurrentFSWFK AND wp.programfk = listitem
											  inner join dbo.udfCaseFilters(@posclause, @negclause, @programfk) cf on cf.HVCaseFK = HVCasePK
										  where CaseProgress >= 9
											   and IntakeDate between @STDate and @EndDate
											   and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
										  group by hvcasepk
												  ,tcdob
												  ,edc) as t on CaseProgram.HVCaseFK = t.HVCasePK
						  inner join dbo.SplitString(@programfk,',') on CaseProgram.programfk = listitem -- needed again for transfer cases					  
						  left join HVCase on HVCase.HVCasePK = CaseProgram.HVCaseFK
						  left join Worker on Worker.WorkerPK = CaseProgram.CurrentFSWFK) a
			where numdays > 92
			order by numdays desc

	end





GO
