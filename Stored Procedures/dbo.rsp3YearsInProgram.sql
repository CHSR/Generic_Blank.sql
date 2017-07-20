SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Chris Papas
-- Create date: 08/25/2010
-- Description:	Get everyone who's CASE has EVER been in the program for > 3 years (1095 days)
--				Moved from FamSys - 02/05/12 jrobohn
-- Edit date: 10/11/2013 CP - workerprogram was duplicating cases when worker transferred
-- exec dbo.rsp3YearsInProgram @programfk='1',@SiteFK=0,@casefilterspositive=NULL
-- =============================================
CREATE procedure [dbo].[rsp3YearsInProgram]
(
    @programfk varchar(max)    = null,
    @SiteFK    int             = 0,
    @casefilterspositive varchar(200)
)

as
begin

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set nocount on;

	if @programfk is null
	begin
		select @programfk =
			   substring((select ','+ltrim(rtrim(str(HVProgramPK)))
							  from HVProgram
							  for xml path ('')),2,8000)
	end

	set @programfk = replace(@programfk,'"','')
	set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0 else @SiteFK end
	set @casefilterspositive = case when @casefilterspositive = '' then null else @casefilterspositive end

	select PC1ID
		 ,convert(varchar(10),c.IntakeDate,101) [IntakeDate]
		 ,case when DischargeDate is null then ''
			  else convert(varchar(10),DischargeDate,101) end [DISDate]
		 ,datediff(month,IntakeDate,case when DischargeDate is null then getdate()
			  else DischargeDate end) [MonthsInProgram]
		 ,p.ProgramName as Program_Name
		 ,case when DischargeDate is null then 'Case Open, '+rtrim(LevelName)
				when ltrim(rtrim(codeDischarge.DischargeReason)) = 'Other' then ltrim(rtrim(DischargeReasonSpecify))
			  else ltrim(rtrim(codeDischarge.DischargeReason)) end [Outcome]
		from CaseProgram cp
			left join HVCase c on c.HVCasePK = cp.HVCaseFK
			left join codeDischarge on cp.DischargeReason = codeDischarge.DischargeCode
			left join codeLevel on cp.CurrentLevelFK = codeLevel.codeLevelPK
			left join HVProgram p on cp.ProgramFK = p.HVProgramPK
			inner join dbo.SplitString(@programfk,',') on cp.programfk = listitem
			inner join dbo.udfCaseFilters(@casefilterspositive,'', @programfk) cf on cf.HVCaseFK = HVCasePK
			inner join worker fsw on CurrentFSWFK = fsw.workerpk
			inner join workerprogram wp on wp.workerfk = fsw.workerpk AND wp.programfk = listitem
		where c.IntakeDate is not null
			 and datediff(day,IntakeDate,case when DischargeDate is null then getdate()
				 else DischargeDate end) > 1095
			 and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)			 
		ORDER BY PC1ID
end
GO
