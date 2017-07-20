SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Jan 24, 2011>
-- Description:	<Gets all items in the codeReportCatalog table>
-- =============================================
CREATE procedure [dbo].[spGetAllReports]
(
    @strProgramFK varchar(3)     = null,
    @UserName     varchar(15)    = null
)
as
begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set nocount on;
	declare @ProgramFK int = cast(@strProgramFK as int);

	-- Insert statements for procedure here
	with cteLastRunByUser
	as (select ProgramFK
			  ,ReportFK
			  ,max(TimeRun) as UserLastRun
			from ReportHistory rh
			where ProgramFK = @ProgramFK
				 and UserFK = @UserName
			group by ProgramFK
					,ReportFK
	),
	cteLastRunByProgram
	as (select ProgramFK
			  ,ReportFK
			  ,max(TimeRun) as ProgramLastRun
			from ReportHistory rh
			where ProgramFK = @ProgramFK
			group by ProgramFK
					,ReportFK
	),
	cteFrequencyByUser
	as (select row_number() over (order by count(ReportFK) desc) as UserRank
			  ,count(ReportFK) as UserCount
			  ,ReportFK
			from ReportHistory rh
			where ProgramFK = @ProgramFK
				 and UserFK = @UserName
			group by ProgramFK
					,ReportFK

	),
	cteFrequencyByProgram
	as (select row_number() over (order by count(ReportFK) desc) as ProgramRank
			  ,count(ReportFK) as ProgramCount
			  ,ReportFK
			from ReportHistory rh
			where ProgramFK = @ProgramFK
			group by ProgramFK
					,ReportFK

	)
	select codeReportCatalogPK
		  ,rc.ReportName
		  ,ReportCategory
		  ,ReportDescription
		  ,ReportClass
		  ,CriteriaOptions
		  ,Defaults
		  --,'O:'+rtrim(CriteriaOptions)+' D(calc):'+rtrim(dbo.CalculateReportDefaults([Defaults]))+' D(raw):'+rtrim([Defaults]) as DefaultsBag
		  ,Keywords
		  ,convert(varchar(10),UserLastRun,101) as UserLastRun
		  ,convert(varchar(10),ProgramLastRun,101) as ProgramLastRun
		  ,UserRank
		  ,UserCount
		  ,ProgramRank
		  ,ProgramCount
		from codeReportCatalog rc
			left outer join cteLastRunByUser lrbu on lrbu.ReportFK = rc.codeReportCatalogPK
			left outer join cteLastRunByProgram lrbp on lrbp.ReportFK = rc.codeReportCatalogPK
			left outer join cteFrequencyByUser fbu on fbu.ReportFK = rc.codeReportCatalogPK
			left outer join cteFrequencyByProgram fbp on fbp.ReportFK = rc.codeReportCatalogPK
		where ReportClass is not null
		order by [ReportCategory]
				,[ReportName]

--	,cteFrequencyByUser
--		as
--		(
--		select ROW_NUMBER() over(order by count(rh.ReportFK), UserLastRun desc) as UserRank
--				,Count(rh.ReportFK) as UserCount
--				,rh.ReportFK
--		from ReportHistory rh
--		inner join cteLastRunByUser lrbu on lrbu.ReportFK=rh.ReportFK
--		where rh.ProgramFK=@ProgramFK
--				and UserFK=@UserName
--		group by rh.ProgramFK, rh.ReportFK, UserLastRun

--		)
--	,cteFrequencyByProgram
--		as
--		(
--		select ROW_NUMBER() over(order by count(rh.ReportFK), ProgramLastRun desc) as ProgramRank
--				,Count(rh.ReportFK) as ProgramCount
--				,rh.ReportFK
--		from ReportHistory rh
--		inner join cteLastRunByProgram lrbp on lrbp.ReportFK=rh.ReportFK
--		where rh.ProgramFK=@ProgramFK
--		group by rh.ProgramFK, rh.ReportFK, ProgramLastRun

--		)
--select codeReportCatalogPK
--		,isnull(UserRank,0) as UserRank
--		,isnull(UserCount,0) as UserCount
--		,isnull(ProgramRank,0) as ProgramRank
--		,isnull(ProgramCount,0) as ProgramCount
--		,case when UserRank is null
--			then 'null'
--			else
--				convert(varchar(5),isnull(UserRank,0)) + ' (' +  convert(varchar(5),isnull(UserCount,0)) + ')'
--		end as UserRank
--	  ,	case when ProgramRank is null
--			then 'null'
--			else
--				convert(varchar(5),isnull(ProgramRank,0)) + ' (' +  convert(varchar(5),isnull(ProgramCount,0)) + ')' 
--		end as ProgramRank
end
GO
