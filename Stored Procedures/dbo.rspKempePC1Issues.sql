SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:      <Dar Chen>
-- Create date: <Jul 11, 2012>
-- Description: 
-- exec rspKempePC1Issues 19, '20120701', '20120930', '', null
-- Edit date: 10/11/2013 CP - workerprogram was duplicating cases when worker transferred
-- =============================================
CREATE procedure [dbo].[rspKempePC1Issues]
(
    @programfk           VARCHAR(MAX) = null,
    @StartDt             datetime = null,
    @EndDt               datetime = null,
    @sitefk              int      = null,
    @casefilterspositive varchar(200) = null
)

as

--DECLARE @programfk  VARCHAR(MAX)   = '1,35,9'
--DECLARE @StartDt    datetime = '1/1/2012'
--DECLARE @EndDt      datetime = '12/31/2012'
--DECLARE @sitefk     int      = null
--DECLARE @casefilterspositive varchar(200) = NULL

begin
	-- Insert statements for procedure here
	if @programfk is null
	begin
		select @programfk =
			   substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
							  from HVProgram
							  for xml path ('')),2,8000)
	end
	set @programfk = REPLACE(@programfk,'"','')
	set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0 else @SiteFK end
	set @casefilterspositive = case when @casefilterspositive = '' then null else @casefilterspositive end;

	with cteKempeIssues
	as
	(
	select pc1i.HVCaseFK
			, pc1id
		  ,case when sum(case when SubstanceAbuse = 1 then 1 else 0 end) > 0 then 1 else 0 end SubstanceAbuse
		  ,case when sum(case when MentalIllness = 1 then 1 else 0 end) > 0 then 1 else 0 end MentalIllness
		  ,case when sum(case when DomesticViolence = 1 then 1 else 0 end) > 0 then 1 else 0 end DomesticViolence
		  ,case when sum(case when AlcoholAbuse = 1 then 1 else 0 end) > 0 then 1 else 0 end AlcoholAbuse
		  ,case when sum(case when Depression = 1 then 1 else 0 end) > 0 then 1 else 0 end Depression
		  ,case when sum(case when OtherIssue = 1 then 1 else 0 end) > 0 then 1 else 0 end OtherIssue
		from PC1Issues pc1i
		inner join caseprogram cp on cp.HVCaseFK = pc1i.HVCaseFK
		inner join Kempe k on k.PC1IssuesFK = pc1i.PC1IssuesPK
		inner join dbo.SplitString(@programfk,',') on cp.programfk = listitem
		inner join WorkerProgram wp on WorkerFK = FAWFK AND wp.programfk = listitem
		inner join dbo.udfCaseFilters(@casefilterspositive,'', @programfk) cf on cf.HVCaseFK = pc1i.HVCaseFK
		where PC1IssuesDate <= @EndDt
				and Interval='1'
				and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
		group by pc1i.HVCaseFK, PC1ID
	),
	cteReferrals 
	as
	(
	select c.HVCasePK
		  ,sum(case when sr.servicecode in ('49','50') and sr.FamilyCode = '01' then 1 else 0 end) MentalHealthServices
		  ,sum(case when sr.servicecode = '51' and sr.FamilyCode = '01' then 1 else 0 end) DomesticViolenceServices
		  ,sum(case when sr.servicecode = '52' and sr.FamilyCode = '01' then 1 else 0 end) SubstanceAbuseServices
			, pc1id
		from HVCase c
			join ServiceReferral sr on sr.HVCaseFK = c.HVCasePK
			inner join caseprogram cp on cp.HVCaseFK = c.HVCasePK
			inner join dbo.SplitString(@programfk,',') on cp.programfk = listitem
			inner join WorkerProgram wp on WorkerFK = FSWFK AND wp.programfk = listitem
			inner join dbo.udfCaseFilters(@casefilterspositive,'', @programfk) cf on cf.HVCaseFK = c.HVCasePK
		where c.IntakeDate between @StartDt and @EndDt
			 and sr.ReferralDate-c.IntakeDate < 183
			 and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
		group by c.HVCasePK, PC1ID
	)

	select distinct cp.PC1ID
				   ,convert(varchar(12),c.KempeDate,101) KempDate
				   ,convert(varchar(12),c.IntakeDate,101) IntakeDate
				   ,l.LevelName
				   ,case when (pc1i.SubstanceAbuse = 1 or pc1i.AlcoholAbuse = 1) then 'Yes' else '' end+
					case when sr.SubstanceAbuseServices > 0 and (pc1i.SubstanceAbuse = 1 or pc1i.AlcoholAbuse = 1) then ' *' else '' end 
						SubstanceAbuseServices
				   ,case when (pc1i.MentalIllness = 1 or pc1i.Depression = 1) then 'Yes' else '' end+
					case when sr.MentalHealthServices > 0 and (pc1i.MentalIllness = 1 or pc1i.Depression = 1) then ' *' else '' end 
						MentalHealthServices
				   ,case when pc1i.DomesticViolence = 1 then 'Yes' else '' end+
					case when sr.DomesticViolenceServices > 0 and pc1i.DomesticViolence = 1 then ' *' else '' end 
						DomesticViolenceServices
				   ,ltrim(rtrim(fsw.firstname))+' '+ltrim(rtrim(fsw.lastname)) fswname
				   ,ltrim(rtrim(sup.firstname))+' '+ltrim(rtrim(sup.lastname)) supervisor
		from HVCase c
			join cteKempeIssues as pc1i on c.HVCasePK = pc1i.HVCaseFK
			join CaseProgram cp on cp.HVCaseFK = c.HVCasePK
			join codeLevel l on cp.CurrentLevelFK = l.codeLevelPK
			left outer join cteReferrals sr on sr.HVCasePK = c.HVCasePK
			inner join worker fsw on fsw.workerpk = cp.currentfswfk
			inner join dbo.SplitString(@programfk,',') on cp.programfk = listitem
			inner join workerprogram wp on wp.workerfk = fsw.workerpk AND wp.programfk = listitem
			inner join worker sup on supervisorfk = sup.workerpk
			inner join dbo.udfCaseFilters(@casefilterspositive,'', @programfk) cf on cf.HVCaseFK = c.HVCasePK
		where c.IntakeDate between @StartDt and @EndDt
			 --and cp.ProgramFK = @programfk
			 and (cp.DischargeDate is null
			 or cp.DischargeDate <= @EndDt)
			 and (pc1i.SubstanceAbuse = 1
			 or pc1i.AlcoholAbuse = 1
			 or pc1i.MentalIllness = 1
			 or pc1i.Depression = 1
			 or pc1i.DomesticViolence = 1)
			 and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
		order by supervisor
				,cp.PC1ID

	--DECLARE @StartDt DATE = '01/01/2011'
	--DECLARE @EndDt DATE = '12/31/2011'
	--DECLARE @programfk INT = 17

	--;
	--with inserviceReferral
	--as
	--(
	--select c.HVCasePK
	--	  ,sum(case when sr.servicecode in ('49','50') and sr.FamilyCode = '01' then 1 else 0 end) MentalHealthServices
	--	  ,sum(case when sr.servicecode = '51' and sr.FamilyCode = '01' then 1 else 0 end) DomesticViolenceServices
	--	  ,sum(case when sr.servicecode = '52' and sr.FamilyCode = '01' then 1 else 0 end) SubstanceAbuseServices
	--	from HVCase c
	--		join ServiceReferral sr on sr.HVCaseFK = c.HVCasePK
	--		inner join WorkerProgram wp on WorkerFK = FSWFK
	--		inner join dbo.udfCaseFilters(@casefilterspositive,'', @programfk) cf on cf.HVCaseFK = c.HVCasePK
	--	where c.IntakeDate between @StartDt and @EndDt
	--		 and sr.ReferralDate-c.IntakeDate < 183
	--		 and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
	--	group by c.HVCasePK
	--),

	--inPC1Issues
	--as (
	--select pc1i.HVCaseFK
	--	  ,case when sum(case when SubstanceAbuse = 1 then 1 else 0 end) > 0 then 1 else 0 end SubstanceAbuse
	--	  ,case when sum(case when MentalIllness = 1 then 1 else 0 end) > 0 then 1 else 0 end MentalIllness
	--	  ,case when sum(case when DomesticViolence = 1 then 1 else 0 end) > 0 then 1 else 0 end DomesticViolence
	--	  ,case when sum(case when AlcoholAbuse = 1 then 1 else 0 end) > 0 then 1 else 0 end AlcoholAbuse
	--	  ,case when sum(case when Depression = 1 then 1 else 0 end) > 0 then 1 else 0 end Depression
	--	  ,case when sum(case when OtherIssue = 1 then 1 else 0 end) > 0 then 1 else 0 end OtherIssue
	--	from PC1Issues pc1i
	--	inner join Kempe k on k.PC1IssuesFK = pc1i.PC1IssuesPK
	--	inner join WorkerProgram wp on WorkerFK = FAWFK
	--	inner join dbo.udfCaseFilters(@casefilterspositive,'', @programfk) cf on cf.HVCaseFK = pc1i.HVCaseFK
	--	where PC1IssuesDate <= @EndDt
	--			and Interval='1'
	--			and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
	--	group by pc1i.HVCaseFK
	--)

	--select distinct cp.PC1ID
	--			   ,convert(varchar(12),c.KempeDate,101) KempDate
	--			   ,convert(varchar(12),c.IntakeDate,101) IntakeDate
	--			   ,l.LevelName
	--			   ,case when (pc1i.SubstanceAbuse = 1 or pc1i.AlcoholAbuse = 1) then 'Yes' else '' end+
	--				case when sr.SubstanceAbuseServices > 0 and (pc1i.SubstanceAbuse = 1 or pc1i.AlcoholAbuse = 1) then ' *' else '' end 
	--					SubstanceAbuseServices
	--			   ,case when (pc1i.MentalIllness = 1 or pc1i.Depression = 1) then 'Yes' else '' end+
	--				case when sr.MentalHealthServices > 0 and (pc1i.MentalIllness = 1 or pc1i.Depression = 1) then ' *' else '' end 
	--					MentalHealthServices
	--			   ,case when pc1i.DomesticViolence = 1 then 'Yes' else '' end+
	--				case when sr.DomesticViolenceServices > 0 and pc1i.DomesticViolence = 1 then ' *' else '' end 
	--					DomesticViolenceServices
	--			   ,ltrim(rtrim(fsw.firstname))+' '+ltrim(rtrim(fsw.lastname)) fswname
	--			   ,ltrim(rtrim(sup.firstname))+' '+ltrim(rtrim(sup.lastname)) supervisor
	--	from HVCase c
	--		join inPC1Issues as pc1i on c.HVCasePK = pc1i.HVCaseFK
	--		join CaseProgram cp on cp.HVCaseFK = c.HVCasePK
	--		join codeLevel l on cp.CurrentLevelFK = l.codeLevelPK
	--		join inserviceReferral sr on sr.HVCasePK = c.HVCasePK
	--		inner join worker fsw on fsw.workerpk = cp.currentfswfk
	--		inner join workerprogram wp on wp.workerfk = fsw.workerpk
	--		inner join worker sup on supervisorfk = sup.workerpk
	--		inner join dbo.udfCaseFilters(@casefilterspositive,'', @programfk) cf on cf.HVCaseFK = c.HVCasePK
	--	where c.IntakeDate between @StartDt and @EndDt
	--		 and cp.ProgramFK = @programfk
	--		 and (cp.DischargeDate is null
	--		 or cp.DischargeDate <= @EndDt)
	--		 and (pc1i.SubstanceAbuse = 1
	--		 or pc1i.AlcoholAbuse = 1
	--		 or pc1i.MentalIllness = 1
	--		 or pc1i.Depression = 1
	--		 or pc1i.DomesticViolence = 1)
	--		 and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
	--	order by supervisor
	--			,cp.PC1ID

end
GO
