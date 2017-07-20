SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Dar Chen
-- Create date: 06/18/2010
-- Description:	FAW Monthly Report
-- =============================================
CREATE procedure [dbo].[rspTimesBetweenKeyPreEnrollmentDates_Part1]-- Add the parameters for the stored procedure here
    @ProgramFK	varchar(max)    = null,
    @StartDt	datetime,
    @EndDt		datetime, 
    @SiteFK		int = null,
    @CaseFiltersPositive	varchar(100)    = ''

as

	if @ProgramFK is null
	begin
		select @ProgramFK = substring((select ',' + ltrim(rtrim(str(HVProgramPK)))
										   from HVProgram
										   for xml path ('')), 2, 8000)
	end
	set @ProgramFK = replace(@ProgramFK, '"', '')
	set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0 else @SiteFK end
	set @CaseFiltersPositive = case when @CaseFiltersPositive = '' then null else @CaseFiltersPositive end

	--DECLARE @StartDt DATE = '01/01/2011'
	--DECLARE @EndDt DATE = '01/31/2011'
	--DECLARE @programfk INT = 17

	SELECT DISTINCT e.PC1ID
		 , rtrim(faw.LastName) + ', ' + rtrim(faw.FirstName) [faw]
		 , b.ScreenDate
		 , d.KempeDate
		 , datediff(day, b.ScreenDate, c.KempeDate) [ScreenToKempe]
		 , c.FSWAssignDate
		 , rtrim(fsw.LastName) + ', ' + rtrim(fsw.FirstName) [fsw]
		 , datediff(day, c.KempeDate, c.FSWAssignDate) [KempeToFSW]
		 , a.IntakeDate
		 , datediff(day, c.FSWAssignDate, a.IntakeDate) [FSWToIntake]
		 , datediff(day, b.ScreenDate, a.IntakeDate) [ScreenToIntake]
		 , datediff(day, d.KempeDate, a.IntakeDate) [KempeToIntake]

		from HVCase as a
			left outer join HVScreen as b on a.HVCasePK = b.HVCaseFK
			left outer join Preassessment as c on c.HVCaseFK = a.HVCasePK and c.CaseStatus = '02'
			left outer join Kempe as d on d.HVCaseFK = a.HVCasePK
			inner join dbo.udfCaseFilters(@CaseFiltersPositive,'',@ProgramFK) cf on cf.HVCaseFK = a.HVCasePK
			join dbo.CaseProgram as e on e.HVCaseFK = a.HVCasePK
			join dbo.SplitString(@programfk, ',') on e.programfk = listitem
			join dbo.Worker as faw on faw.WorkerPK = b.FAWFK
			join dbo.Worker as fsw on fsw.WorkerPK = c.PAFSWFK
			inner join WorkerProgram wp on wp.WorkerFK = fsw.WorkerPK

		where
			--e.ProgramFK = @programfk AND 
			a.IntakeDate between @StartDt and @EndDt
			--siteFK
			and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)

		order by e.PC1ID
GO
