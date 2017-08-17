SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Dar Chen
-- Create date: 06/18/2010
-- Description:	FAW Monthly Report
-- exec rspPrimaryCaretaker1Issues 19, N'07/01/12', N'09/30/12', NULL, NULL
-- Edit date: 10/11/2013 CP - workerprogram was NOT duplicating cases when worker transferred
-- =============================================
CREATE procedure [dbo].[rspPrimaryCaretaker1Issues]-- Add the parameters for the stored procedure here
    @programfk VARCHAR(MAX) = null,
    @StartDt   datetime,
    @EndDt     datetime,
    @SiteFK int	= null,
    @casefilterspositive varchar(200)	
as

if @programfk is null
  begin
	select @programfk = substring((select ','+ltrim(rtrim(str(HVProgramPK)))
									   from HVProgram
									   for xml path ('')),2,8000)
  end
set @programfk = replace(@programfk,'"','')

	--DECLARE @programfk INT = 6 
	--DECLARE @StartDt DATETIME = '07/01/2011'
	--DECLARE @EndDt DATETIME = '03/31/2012'

	declare @x int = 0
	declare @y int = 0
	
	set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0 else @SiteFK end
	set @casefilterspositive = case when @casefilterspositive = '' then null else @casefilterspositive end;

	if object_id('tempdb..#cteCohort') is not null drop table #cteCohort
	create table #cteCohort (
		HVCaseFK int
		, PC1IssuesPK int
		, PC1IssuesDate datetime
		, ProgramFK int
		, Interval char(2)
	)
	
	insert into #cteCohort
	select pc1i.HVCaseFK
			, PC1IssuesPK
			, PC1IssuesDate
			, pc1i.ProgramFK
			, Interval
	from dbo.PC1Issues pc1i
		join CaseProgram cp on cp.HVCaseFK = pc1i.HVCaseFK
		INNER JOIN dbo.SplitString(@programfk,',') on pc1i.programfk = listitem
		inner join HVCase h on h.HVCasePK = cp.HVCaseFK
		inner join WorkerProgram wp on wp.WorkerFK = cp.CurrentFSWFK
		inner join dbo.udfCaseFilters(@casefilterspositive,'', @programfk) cf on cf.HVCaseFK = cp.HVCaseFK
	where -- pc1i.PC1IssuesDate between @StartDt and @EndDt
		--pc1i.ProgramFK = @programfk and 
		(cp.DischargeDate is null or cp.DischargeDate >= @StartDt)
		and IntakeDate is not null 
		and IntakeDate <= @EndDt
		and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
	-- group by pc1i.HVCaseFK
						

; with cteTotalCount as (select count(distinct HVCaseFK) as TotalCount
			from #cteCohort
		 ),
	cteKempeCount as (select count(distinct HVCaseFK) as KempeCount
			from #cteCohort
			where rtrim(Interval) = '1'
		 ),

	cteLastIssues as (select HVCaseFK
						,max(PC1IssuesPK) [PC1IssuesPK]
						from #cteCohort coh
						group by HVCaseFK
						),
	cteLastKempeIssues as (select HVCaseFK
			  ,max(PC1IssuesPK) [PC1IssuesPK]
			from #cteCohort coh
			where rtrim(Interval) = '1'
			group by HVCaseFK
		   ),
	sub1
	as (select TotalCount
		  ,str(sum(case when AlcoholAbuse = '1' or SubstanceAbuse = '1' then 1 else 0 end)
		      * 100.0 / cteTotalCount.TotalCount, 10, 0) + ' %'
		  +case when sum(case when AlcoholAbuse in ('1','0','9') or SubstanceAbuse in ('1','0','9')
						  then 1 else 0 end) * 100.0 / cteTotalCount.TotalCount < 75.0 then '**' else '' end [pc1i01SubstanceAbuse]
		 ,str(sum(case when PhysicalDisability = '1' then 1 else 0 end) * 100.0 / cteTotalCount.TotalCount, 10, 0) + ' %'
		  +case when sum(case when PhysicalDisability in ('1','0','9') then 1 else 0 end) * 100.0 / cteTotalCount.TotalCount < 75.0 
				then '**' else '' end [pc1i02PhysicalDisability]
		 ,str(sum(case when MentalIllness = '1' or Depression = '1' then 1 else 0 end)*100.0/cteTotalCount.TotalCount,10,0)+' %'
		  +case when sum(case when MentalIllness in ('1','0','9') or Depression in ('1','0','9')
						  then 1 else 0 end)*100.0/cteTotalCount.TotalCount < 75.0 then '**' else '' end [pc1i03MentalHealth]
		 ,str(sum(case when Stress = '1' then 1 else 0 end)*100.0/cteTotalCount.TotalCount,10,0)+' %'
		  +case when sum(case when Stress in ('1','0','9')
						  then 1 else 0 end)*100.0/cteTotalCount.TotalCount < 75.0 then '**' else '' end [pc1i04Stress]
		 ,str(sum(case when DevelopmentalDisability = '1' then 1 else 0 end) * 100.0 / cteTotalCount.TotalCount, 10, 0) + ' %'
		  +case when sum(case when DevelopmentalDisability in ('1','0','9') then 1 else 0 end) * 100.0 / cteTotalCount.TotalCount < 75.0 
				then '**' else '' end [pc1i05DevelopmentalDisability]
		 ,str(sum(case when DomesticViolence = '1' then 1 else 0 end)*100.0/cteTotalCount.TotalCount,10,0)+' %'
		  +case when sum(case when DomesticViolence in ('1','0','9')
						  then 1 else 0 end)*100.0/cteTotalCount.TotalCount < 75.0 then '**' else '' end [pc1i06Violence]
		 ,str(sum(case when MaritalProblems = '1' then 1 else 0 end)*100.0/cteTotalCount.TotalCount,10,0)+' %'
		  +case when sum(case when MaritalProblems in ('1','0','9')
						  then 1 else 0 end)*100.0/cteTotalCount.TotalCount < 75.0 then '**' else '' end [pc1i07MaritalProblem]
		 ,str(sum(case when CriminalActivity = '1' or OtherLegalProblems = '1' then 1 else 0 end)*100.0/cteTotalCount.TotalCount,10,0)+' %'
		  +case when sum(case when CriminalActivity in ('1','0','9') or OtherLegalProblems in ('1','0','9')
						  then 1 else 0 end)*100.0/cteTotalCount.TotalCount < 75.0 then '**' else '' end [pc1i08LegalIssues]
		 ,str(sum(case when FinancialDifficulty = '1' or InadequateBasics = '1' then 1 else 0 end)*100.0/cteTotalCount.TotalCount,10,0)+' %'
		  +case when sum(case when FinancialDifficulty in ('1','0','9') or InadequateBasics in ('1','0','9')
						  then 1 else 0 end)*100.0/cteTotalCount.TotalCount < 75.0 then '**' else '' end [pc1i09ResourceIssues]
		 ,str(sum(case when Homeless = '1' then 1 else 0 end)*100.0/cteTotalCount.TotalCount,10,0)+' %'
		  +case when sum(case when Homeless in ('1','0','9')
						  then 1 else 0 end)*100.0/cteTotalCount.TotalCount < 75.0 then '**' else '' end [pc1i10Homeless]
		 ,str(sum(case when SocialIsolation = '1' then 1 else 0 end)*100.0/cteTotalCount.TotalCount,10,0)+' %'
		  +case when sum(case when SocialIsolation in ('1','0','9')
						  then 1 else 0 end)*100.0/cteTotalCount.TotalCount < 75.0 then '**' else '' end [pc1i11SocialIsolation]
		 ,str(sum(case when Smoking = '1' then 1 else 0 end)*100.0/cteTotalCount.TotalCount,10,0)+' %'
		  +case when sum(case when Stress in ('1','0','9')
						  then 1 else 0 end)*100.0/cteTotalCount.TotalCount < 75.0 then '**' else '' end [pc1i12Smoking]

		from dbo.PC1Issues a
			join cteLastIssues li on a.PC1IssuesPK = li.PC1IssuesPK
			join cteTotalCount on 1 = 1
		group by TotalCount
	)
	,
	sub2
	as (select KempeCount
		  ,str(sum(case when AlcoholAbuse = '1' or SubstanceAbuse = '1' then 1 else 0 end)*100.0/cteKempeCount.KempeCount,10,0)+' %'
		  +case when sum(case when AlcoholAbuse in ('1','0','9') or SubstanceAbuse in ('1','0','9')
						  then 1 else 0 end)*100.0/cteKempeCount.KempeCount < 75.0 then '**' else '' end [pc1i01SubstanceAbuseAE]
		 ,str(sum(case when PhysicalDisability = '1' then 1 else 0 end) * 100.0 / cteKempeCount.KempeCount, 10, 0) + ' %'
		  +case when sum(case when PhysicalDisability in ('1','0','9') then 1 else 0 end) * 100.0 / cteKempeCount.KempeCount < 75.0 
				then '**' else '' end [pc1i02PhysicalDisabilityAE]
		 ,str(sum(case when MentalIllness = '1' or Depression = '1' then 1 else 0 end)*100.0/cteKempeCount.KempeCount,10,0)+' %'
		  +case when sum(case when MentalIllness in ('1','0','9') or Depression in ('1','0','9')
						  then 1 else 0 end)*100.0/cteKempeCount.KempeCount < 75.0 then '**' else '' end [pc1i03MentalHealthAE]
		 ,str(sum(case when Stress = '1' then 1 else 0 end)*100.0/cteKempeCount.KempeCount,10,0)+' %'
		  +case when sum(case when Stress in ('1','0','9')
						  then 1 else 0 end)*100.0/cteKempeCount.KempeCount < 75.0 then '**' else '' end [pc1i04StressAE]
		 ,str(sum(case when DevelopmentalDisability = '1' then 1 else 0 end) * 100.0 / cteKempeCount.KempeCount, 10, 0) + ' %'
		  +case when sum(case when DevelopmentalDisability in ('1','0','9') then 1 else 0 end) * 100.0 / cteKempeCount.KempeCount < 75.0 
				then '**' else '' end [pc1i05DevelopmentalDisabilityAE]
		 ,str(sum(case when DomesticViolence = '1' then 1 else 0 end)*100.0/cteKempeCount.KempeCount,10,0)+' %'
		  +case when sum(case when DomesticViolence in ('1','0','9')
						  then 1 else 0 end)*100.0/cteKempeCount.KempeCount < 75.0 then '**' else '' end [pc1i06ViolenceAE]
		 ,str(sum(case when MaritalProblems = '1' then 1 else 0 end)*100.0/cteKempeCount.KempeCount,10,0)+' %'
		  +case when sum(case when MaritalProblems in ('1','0','9')
						  then 1 else 0 end)*100.0/cteKempeCount.KempeCount < 75.0 then '**' else '' end [pc1i07MaritalProblemAE]
		 ,str(sum(case when CriminalActivity = '1' or OtherLegalProblems = '1' then 1 else 0 end)*100.0/cteKempeCount.KempeCount,10,0)+' %'
		  +case when sum(case when CriminalActivity in ('1','0','9') or OtherLegalProblems in ('1','0','9')
						  then 1 else 0 end)*100.0/cteKempeCount.KempeCount < 75.0 then '**' else '' end [pc1i08LegalIssuesAE]
		 ,str(sum(case when FinancialDifficulty = '1' or InadequateBasics = '1' then 1 else 0 end)*100.0/cteKempeCount.KempeCount,10,0)+' %'
		  +case when sum(case when FinancialDifficulty in ('1','0','9') or InadequateBasics in ('1','0','9')
						  then 1 else 0 end)*100.0/cteKempeCount.KempeCount < 75.0 then '**' else '' end [pc1i09ResourceIssuesAE]
		 ,str(sum(case when Homeless = '1' then 1 else 0 end)*100.0/cteKempeCount.KempeCount,10,0)+' %'
		  +case when sum(case when Homeless in ('1','0','9')
						  then 1 else 0 end)*100.0/cteKempeCount.KempeCount < 75.0 then '**' else '' end [pc1i10HomelessAE]
		 ,str(sum(case when SocialIsolation = '1' then 1 else 0 end)*100.0/cteKempeCount.KempeCount,10,0)+' %'
		  +case when sum(case when SocialIsolation in ('1','0','9')
						  then 1 else 0 end)*100.0/cteKempeCount.KempeCount < 75.0 then '**' else '' end [pc1i11SocialIsolationAE]
		 ,str(sum(case when Smoking = '1' then 1 else 0 end)*100.0/cteKempeCount.KempeCount,10,0)+' %'
		  +case when sum(case when Stress in ('1','0','9')
						  then 1 else 0 end)*100.0/cteKempeCount.KempeCount < 75.0 then '**' else '' end [pc1i12SmokingAE]

		from dbo.PC1Issues a
			join cteLastKempeIssues lki on a.PC1IssuesPK = lki.PC1IssuesPK
			join cteKempeCount on 1 = 1
		group by KempeCount
	)

	select KempeCount [pc1i00AssessmentN]
		  ,TotalCount [pc1i00CurrentIssueN]
		  ,*
		from sub2
			join sub1 on 1 = 1

	drop table #cteCohort

--------------------------------------------------------------------------------------------------------------		
	--select @x = count(distinct pc1i.HVCaseFK)
	--	from cteCohort
	--	dbo.PC1Issues as pc1i
	--		join CaseProgram cp on cp.HVCaseFK = pc1i.HVCaseFK
	--		inner join WorkerProgram wp on wp.WorkerFK = cp.CurrentFSWFK -- get SiteFK
	--		inner join dbo.udfCaseFilters(@casefilterspositive,'', @programfk) cf on cf.HVCaseFK = cp.HVCaseFK
	--	where pc1i.PC1IssuesDate between @StartDt and @EndDt
	--		 and pc1i.ProgramFK = @programfk
	--		 and (cp.DischargeDate is null
	--		 or cp.DischargeDate >= @StartDt)
	--		 and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)

	--select @y = count(distinct pc1i.HVCaseFK)
	--	from dbo.PC1Issues pc1i
	--		join CaseProgram cp on cp.HVCaseFK = pc1i.HVCaseFK
	--		inner join WorkerProgram wp on wp.WorkerFK = cp.CurrentFSWFK -- get SiteFK
	--		inner join dbo.udfCaseFilters(@casefilterspositive,'', @programfk) cf on cf.HVCaseFK = cp.HVCaseFK
	--	where pc1i.PC1IssuesDate between @StartDt and @EndDt
	--		 and rtrim(pc1i.Interval) = '1'
	--		 and pc1i.ProgramFK = @programfk
	--		 and (cp.DischargeDate is null
	--		 or cp.DischargeDate >= @StartDt)
	--		 and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)

	--if @x = 0
	--begin
	--	set @x = 1
	--end
	--if @y = 0
	--begin
	--	set @y = 1
	--end

	--xxx as (select pc1i.HVCaseFK
	--		  ,max(PC1IssuesPK) [PC1IssuesPK]
	--		from dbo.PC1Issues pc1i
	--			join CaseProgram cp on cp.HVCaseFK = pc1i.HVCaseFK
	--			inner join WorkerProgram wp on wp.WorkerFK = cp.CurrentFSWFK -- get SiteFK
	--			inner join dbo.udfCaseFilters(@casefilterspositive,'', @programfk) cf on cf.HVCaseFK = cp.HVCaseFK
	--		where pc1i.PC1IssuesDate between @StartDt and @EndDt
	--			 and pc1i.ProgramFK = @programfk
	--			 and (cp.DischargeDate is null
	--			 or cp.DischargeDate >= @StartDt)
	--			 and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
	--		group by pc1i.HVCaseFK
	--)
	--,
	--yyy
	--as (
	--select pc1i.HVCaseFK
	--	  ,max(pc1i.PC1IssuesPK) [PC1IssuesPK]
	--	from dbo.PC1Issues pc1i
	--		join CaseProgram cp on cp.HVCaseFK = pc1i.HVCaseFK
	--		inner join WorkerProgram wp on wp.WorkerFK = cp.CurrentFSWFK -- get SiteFK
	--		inner join dbo.udfCaseFilters(@casefilterspositive,'', @programfk) cf on cf.HVCaseFK = cp.HVCaseFK
	--	where pc1i.PC1IssuesDate between @StartDt and @EndDt
	--		 and rtrim(pc1i.Interval) = '1'
	--		 and pc1i.ProgramFK = @programfk
	--		 and (cp.DischargeDate is null
	--		 or cp.DischargeDate >= @StartDt)
	--		 and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
	--	group by pc1i.HVCaseFK
	--)
	--,
	--testsub1
	--as (select str(sum(case when AlcoholAbuse = '1' or SubstanceAbuse = '1' then 1 else 0 end)) as pc1i01SubstanceAbuseCount
	--	  ,str(sum(case when AlcoholAbuse = '1' or SubstanceAbuse = '1' then 1 else 0 end) * 100.0 / cteTotalCount.TotalCount, 10, 0) + ' %'
	--	  +case when sum(case when AlcoholAbuse in ('1','0','9') or SubstanceAbuse in ('1','0','9')
	--					  then 1 else 0 end) * 100.0 / cteTotalCount.TotalCount < 75.0 then '**' else '' end [pc1i01SubstanceAbusePerc]
	--	 ,str(sum(case when PhysicalDisability = '1' then 1 else 0 end)) as pc1i02PhysicalDisabilityCount
	--	 ,str(sum(case when PhysicalDisability = '1' then 1 else 0 end) * 100.0 / cteTotalCount.TotalCount, 10, 0) + ' %'
	--	  +case when sum(case when PhysicalDisability in ('1','0','9') then 1 else 0 end) * 100.0 / cteTotalCount.TotalCount < 75.0 
	--			then '**' else '' end [pc1i02PhysicalDisabilityPerc]
	--	 ,str(sum(case when MentalIllness = '1' or Depression = '1' then 1 else 0 end)) as pc1i03MentalHealthCount
	--	 ,str(sum(case when MentalIllness = '1' or Depression = '1' then 1 else 0 end) * 100.0/cteTotalCount.TotalCount,10,0)+' %'
	--	  +case when sum(case when MentalIllness in ('1','0','9') or Depression in ('1','0','9')
	--					  then 1 else 0 end)*100.0/cteTotalCount.TotalCount < 75.0 then '**' else '' end [pc1i03MentalHealthPerc]
	--	 ,str(sum(case when Stress = '1' then 1 else 0 end)) as pc1i04StressCount
	--	 ,str(sum(case when Stress = '1' then 1 else 0 end) * 100.0/cteTotalCount.TotalCount,10,0)+' %'
	--	  +case when sum(case when Stress in ('1','0','9')
	--					  then 1 else 0 end)*100.0/cteTotalCount.TotalCount < 75.0 then '**' else '' end [pc1i04StressPerc]
	--	 ,str(sum(case when DevelopmentalDisability = '1' then 1 else 0 end) * 100.0 / cteTotalCount.TotalCount, 10, 0) + ' %'
	--	  +case when sum(case when DevelopmentalDisability in ('1','0','9') then 1 else 0 end) * 100.0 / cteTotalCount.TotalCount < 75.0 
	--			then '**' else '' end [pc1i05DevelopmentalDisabilityPerc]
	--	 ,str(sum(case when DomesticViolence = '1' then 1 else 0 end)*100.0/cteTotalCount.TotalCount,10,0)+' %'
	--	  +case when sum(case when DomesticViolence in ('1','0','9')
	--					  then 1 else 0 end)*100.0/cteTotalCount.TotalCount < 75.0 then '**' else '' end [pc1i06ViolencePerc]
	--	 ,str(sum(case when MaritalProblems = '1' then 1 else 0 end)*100.0/cteTotalCount.TotalCount,10,0)+' %'
	--	  +case when sum(case when MaritalProblems in ('1','0','9')
	--					  then 1 else 0 end)*100.0/cteTotalCount.TotalCount < 75.0 then '**' else '' end [pc1i07MaritalProblemPerc]
	--	 ,str(sum(case when CriminalActivity = '1' or OtherLegalProblems = '1' then 1 else 0 end)*100.0/cteTotalCount.TotalCount,10,0)+' %'
	--	  +case when sum(case when CriminalActivity in ('1','0','9') or OtherLegalProblems in ('1','0','9')
	--					  then 1 else 0 end)*100.0/cteTotalCount.TotalCount < 75.0 then '**' else '' end [pc1i08LegalIssuesPerc]
	--	 ,str(sum(case when FinancialDifficulty = '1' or InadequateBasics = '1' then 1 else 0 end)*100.0/cteTotalCount.TotalCount,10,0)+' %'
	--	  +case when sum(case when FinancialDifficulty in ('1','0','9') or InadequateBasics in ('1','0','9')
	--					  then 1 else 0 end)*100.0/cteTotalCount.TotalCount < 75.0 then '**' else '' end [pc1i09ResourceIssuesPerc]
	--	 ,str(sum(case when Homeless = '1' then 1 else 0 end)*100.0/cteTotalCount.TotalCount,10,0)+' %'
	--	  +case when sum(case when Homeless in ('1','0','9')
	--					  then 1 else 0 end)*100.0/cteTotalCount.TotalCount < 75.0 then '**' else '' end [pc1i10HomelessPerc]
	--	 ,str(sum(case when SocialIsolation = '1' then 1 else 0 end)*100.0/cteTotalCount.TotalCount,10,0)+' %'
	--	  +case when sum(case when SocialIsolation in ('1','0','9')
	--					  then 1 else 0 end)*100.0/cteTotalCount.TotalCount < 75.0 then '**' else '' end [pc1i11SocialIsolationPerc]
	--	 ,str(sum(case when Smoking = '1' then 1 else 0 end)*100.0/cteTotalCount.TotalCount,10,0)+' %'
	--	  +case when sum(case when Stress in ('1','0','9')
	--					  then 1 else 0 end)*100.0/cteTotalCount.TotalCount < 75.0 then '**' else '' end [pc1i12SmokingPerc]

	--	from dbo.PC1Issues a
	--		join cteLastIssues li on a.PC1IssuesPK = li.PC1IssuesPK
	--		join cteTotalCount on 1 = 1
	--	group by TotalCount
	--)

	--select * from dbo.PC1Issues a
	--		join cteLastIssues li on a.PC1IssuesPK = li.PC1IssuesPK
	--		join cteTotalCount on 1 = 1
	-- group by TotalCount
		
	--select * from testsub1
GO
