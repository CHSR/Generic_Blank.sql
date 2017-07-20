SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Jay Robohn orig by Dorothy Baum>
-- Create date: <June 3, 2010>
-- Description:	<report: Credentialing 1-1D. Assessment Info>
-- exec rspCredentialingAssessmentInfo '20050101', '20051231', '34', null, '13Program,13Control', ''
-- Edit date: 10/11/2013 CP - workerprogram was duplicating cases when worker transferred
--            added this code to the workerprogram join condition: AND wp.programfk = listitem
-- =============================================
CREATE procedure [dbo].[rspCredentialingAssessmentInfo]
(
    @StartDate  datetime,
    @EndDate    datetime,
    @ProgramFKs varchar(200),
    @SiteFK		int = 0,
    @posclause  varchar(200),
    @negclause  varchar(200)
)
-- Add the parameters for the stored procedure here
as
begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set nocount on;

	--if left(@ProgramFKs,1) <> ',' or right(@ProgramFKs,1) <> ',' -- charindex(',',@ProgramFKs) = 0
	--	set @ProgramFKs = ',' + @ProgramFKs + ','

	set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0 else @SiteFK end
	set @posclause = case when @posclause = '' then null else @posclause end;
	set @negclause = case when @negclause = '' then null else @negclause end;

	-- Insert statements for procedure here
	-- if @posclause is null and @negclause is null -- don't include filters
		with cteTotals
		as (select count(kempepk) as kempettl
				  ,sum(case
						   when bday > kempedate then
							   1
						   else
							   0
					   end) as prenatal
				  ,sum(case
						   when bday <= kempedate then
							   1
						   else
							   0
					   end) as postnatal
				  ,sum(case
						   when cast(kempedate-bday as int) <= 14 and cast(kempedate-bday as int) >= 0 then
							   1
						   else
							   0
					   end) as within2wks
				  ,sum(case
						   when cast(kempedate-bday as int) <= 14 then
							   1
						   else
							   0
					   end) as b4twoWks
				  ,sum(case
						   when cast(kempedate-bday as int) > 14 then
							   1
						   else
							   0
					   end) as morethan2wks
				  ,sum(case
						   when KempeResult = 0 then
							   1
						   else
							   0
					   end) as NegativeKempes
				  ,sum(case
						   when KempeResult = 1 then
							   1
						   else
							   0
					   end) as PositiveKempes
				from (select kempe.*
							,isnull(hvcase.tcdob,hvcase.edc) as bday
						  from kempe 
						  inner join hvcase ON kempe.hvcasefk = hvcasepk
						  inner join CaseProgram cp on hvcase.HVCasePK = cp.HVcaseFK
						  inner join dbo.SplitString(@ProgramFKs,',') ss on cp.ProgramFK = listitem
						  inner join worker faw on FAWFK = faw.workerpk
				          inner join workerprogram on workerprogram.workerfk = faw.workerpk AND workerprogram.programfk = listitem
						  where 
							   Kempe.KempeDate >= @StartDate
							   and Kempe.KempeDate <= @EndDate
							   AND (CASE WHEN @SiteFK = 0 THEN 1 WHEN workerprogram.SiteFK = @SiteFK THEN 1 ELSE 0 END = 1)) a
							   -- and (@ProgramFKs like ('%,'+cast(kempe.programfk as varchar(100))+',%'))
				inner join dbo.udfCaseFilters(@posclause, @negclause, @ProgramFKs) cf on cf.HVCaseFK = a.HVCaseFK
		)
		select kempettl
			  ,prenatal
			  ,postnatal
			  ,within2wks
			  ,b4twoWks
			  ,morethan2wks
			  ,NegativeKempes
			  ,PositiveKempes
			  ,case
				   when prenatal is not null and prenatal > 0 then
					   prenatal/(kempettl*1.0)
				   else
					   0
			   end as PrenatalPercent
			  ,case
				   when postnatal is not null and postnatal > 0 then
					   postnatal/(kempettl*1.0)
				   else
					   0
			   end as PostnatalPercent
			  ,case
				   when within2wks is not null and within2wks > 0 then
					   within2wks/(kempettl*1.0)
				   else
					   0
			   end as twoWkPercent
			  ,case
				   when morethan2wks is not null and morethan2wks > 0 then
					   morethan2wks/(kempettl*1.0)
				   else
					   0
			   end as After2Percent
			  ,case
				   when prenatal is not null and prenatal > 0 then
					   prenatal+within2wks
				   else
					   within2wks
			   end as Prenatal_2wks
			  ,case
				   when prenatal is not null and prenatal > 0 then
					   (prenatal+within2wks)/(kempettl*1.0)
				   else
					   within2wks/(kempettl*1.0)
			   end as Percent_2wks
			  ,case
				   when NegativeKempes is not null and NegativeKempes > 0 then
					   NegativeKempes/(kempettl*1.0)
				   else
					   0
			   end as NegKempePercent
			  ,case
				   when PositiveKempes is not null and PositiveKempes > 0 then
					   PositiveKempes/(kempettl*1.0)
				   else
					   0
			   end as PosKempePercent
			from cteTotals

	--else
	--	with cteTotals
	--	as (select count(kempepk) as kempettl
	--			  ,sum(case
	--					   when bday > kempedate then
	--						   1
	--					   else
	--						   0
	--				   end) as prenatal
	--			  ,sum(case
	--					   when bday <= kempedate then
	--						   1
	--					   else
	--						   0
	--				   end) as postnatal
	--			  ,sum(case
	--					   when cast(kempedate-bday as int) <= 14 and cast(kempedate-bday as int) >= 0 then
	--						   1
	--					   else
	--						   0
	--				   end) as within2wks
	--			  ,sum(case
	--					   when cast(kempedate-bday as int) <= 14 then
	--						   1
	--					   else
	--						   0
	--				   end) as b4twoWks
	--			  ,sum(case
	--					   when cast(kempedate-bday as int) > 14 then
	--						   1
	--					   else
	--						   0
	--				   end) as morethan2wks
	--			  ,sum(case
	--					   when KempeResult = 0 then
	--						   1
	--					   else
	--						   0
	--				   end) as NegativeKempes
	--			  ,sum(case
	--					   when KempeResult = 1 then
	--						   1
	--					   else
	--						   0
	--				   end) as PositiveKempes
	--			from (select kempe.*
	--						,isnull(hvcase.tcdob,hvcase.edc) as bday
	--					  from kempe 
	--					  JOIN hvcase ON kempe.hvcasefk = hvcasepk
	--					  join caseprogram on hvcase.HVCasePK = caseprogram.HVcaseFK
	--					  inner join worker fsw on CurrentFSWFK = fsw.workerpk
	--			          inner join workerprogram on workerprogram.workerfk = fsw.workerpk
					  
						  
						  
	--					  where 
	--					   Kempe.KempeDate >= @StartDate
	--						   and Kempe.KempeDate <= @EndDate
	--						   AND (CASE WHEN @SiteFK = 0 THEN 1 WHEN workerprogram.SiteFK = @SiteFK THEN 1 ELSE 0 END = 1)
	--						   and (@ProgramFKs like ('%,'+cast(kempe.programfk as varchar(100))+',%'))) a,
	--				(select hvcasefk from udfCaseFilters2(@posclause,@negclause,@ProgramFKs)) b
	--			where a.hvcasefk = b.hvcasefk
	--	)
	--	select kempettl
	--		  ,prenatal
	--		  ,postnatal
	--		  ,within2wks
	--		  ,b4twoWks
	--		  ,morethan2wks
	--		  ,NegativeKempes
	--		  ,PositiveKempes
	--		  ,case
	--			   when prenatal is not null and prenatal > 0 then
	--				   prenatal/(kempettl*1.0)
	--			   else
	--				   0
	--		   end as PrenatalPercent
	--		  ,case
	--			   when postnatal is not null and postnatal > 0 then
	--				   postnatal/(kempettl*1.0)
	--			   else
	--				   0
	--		   end as PostnatalPercent
	--		  ,case
	--			   when within2wks is not null and within2wks > 0 then
	--				   within2wks/(kempettl*1.0)
	--			   else
	--				   0
	--		   end as twoWkPercent
	--		  ,case
	--			   when morethan2wks is not null and morethan2wks > 0 then
	--				   morethan2wks/(kempettl*1.0)
	--			   else
	--				   0
	--		   end as After2Percent
	--		  ,case
	--			   when prenatal is not null and prenatal > 0 then
	--				   prenatal+within2wks
	--			   else
	--				   within2wks
	--		   end as Prenatal_2wks
	--		  ,case
	--			   when prenatal is not null and prenatal > 0 then
	--				   (prenatal+within2wks)/(kempettl*1.0)
	--			   else
	--				   within2wks/(kempettl*1.0)
	--		   end as Percent_2wks
	--		  ,case
	--			   when NegativeKempes is not null and NegativeKempes > 0 then
	--				   NegativeKempes/(kempettl*1.0)
	--			   else
	--				   0
	--		   end as NegKempePercent
	--		  ,case
	--			   when PositiveKempes is not null and PositiveKempes > 0 then
	--				   PositiveKempes/(kempettl*1.0)
	--			   else
	--				   0
	--		   end as PosKempePercent
	--		from cteTotals
end
GO
