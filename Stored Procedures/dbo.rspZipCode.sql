SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:    <Jay Robohn> <john & dar made some modification on Sep/24/2013>
-- Create date: <Feb 20, 2012>
-- Description: <copied from FamSys - see header below>
-- exec rspZIPCode '1', '09/01/2013', '08/31/2014'
-- =============================================
CREATE procedure [dbo].[rspZipCode]
(
    @ProgramFK	varchar(max)    = null,
    @StartDate	datetime,
    @EndDate	datetime
)
as
begin
	if @ProgramFK is null
	begin
		select @ProgramFK = substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end

	set @ProgramFK = REPLACE(@ProgramFK,'"','');

	with cteScreens
	as
	(
		select ProgramFK
				, case 
					when InitialZip is null or len(InitialZip) = 0 
						then 'Missing/UNK'
					else
						left(InitialZip, 5)
					end as ZIPCode
				, count(InitialZip) as CountOfScreens
			from HVCase hc
			inner join CaseProgram cp on HVCasePK = HVCaseFK
			inner join PC on PC1FK = PC.PCPK
			inner join dbo.SplitString(@programfk,',') on cp.ProgramFK = listitem
			where ScreenDate between @StartDate and @EndDate
			group by ProgramFK
						, case 
							when InitialZip is null or len(InitialZip) = 0 
								then 'Missing/UNK'
							else
								left(InitialZip, 5)
							end
	)
	, 
	cteServed 
	as
	(
		select ProgramFK
				, case
					when PCZip IS NULL OR len(PCZip) = 0 then       --hvcase.initialzip is null or len(hvcase.initialzip) = 0 then
					   'Missing/UNK'
					else
					   left(PCZip,5) --left(hvcase.initialzip,5)
					end as ZIPCode
			   ,  count(PCZIP) as CountOfServed
			from HVCase hc
			inner join CaseProgram cp on HVCasePK = HVCaseFK
			inner join PC on PC1FK = PC.PCPK
			inner join dbo.SplitString(@programfk,',') on cp.ProgramFK = listitem
			where IntakeDate is not null and IntakeDate <= @EndDate and
					(DischargeDate is null or DischargeDate >= @StartDate)
			group by ProgramFK	
						, case
							when PCZip IS NULL OR len(PCZip) = 0 then       --hvcase.initialzip is null or len(hvcase.initialzip) = 0 then
							   'Missing/UNK'
							else
							   left(PCZip,5) --left(hvcase.initialzip,5)
							end
			   
	)
	select sc.ProgramFK
			, p.TargetZip
			, sc.ZIPCode
			, CountOfScreens
			, CountOfServed
	from cteScreens sc
	inner join cteServed sv on sv.ZIPCode = sc.ZIPCode
	inner join HVProgram p on p.HVProgramPK = sc.ProgramFK
	union all
	select sc.ProgramFK
			, p.TargetZip
			, sc.ZIPCode
			, CountOfScreens
			, 0 as CountOfServed
	from cteScreens sc
	inner join HVProgram p on p.HVProgramPK = sc.ProgramFK
	where ZIPCode not in (select ZIPCode from cteServed)
	union all
	select ProgramFK
			, p.TargetZip
			, ZIPCode
			, 0 as CountOfScreens
			, CountOfServed
	from cteServed se
	inner join HVProgram p on p.HVProgramPK = se.ProgramFK
	where ZIPCode not in (select ZIPCode from cteScreens)
	order by ZIPCode
	
	--with cteAllZips (ProgramFK,zipcode,screenedzip,servedzip)
	--as (select ProgramFK
	--		  ,case
	--			   when PCZip IS NULL OR len(PCZip) = 0 then       --hvcase.initialzip is null or len(hvcase.initialzip) = 0 then
	--				   'Missing/UNK'
	--			   else
	--				   left(PCZip,5) --left(hvcase.initialzip,5)
	--		   end zipcode
	--		  ,(case
	--				when screendate between @sdate and @edate then
	--					1
	--				else
	--					0
	--			end) screenedzip
	--		  ,(case
	--				when intakedate <= @edate and (dischargedate is null or dischargedate >= @sdate) then
	--					1
	--				else
	--					0
	--			end) servedzip
	--		from hvcase
	--			inner join caseprogram on hvcasepk = hvcasefk
	--			inner join pc pc1 on pc1fk = pc1.pcpk)
	----select * from cteAllZips
	--select zipcode
	--	  ,sum(screenedzip) as ScreenedZip
	--	  ,sum(servedzip) as ServedZip
	--	from cteAllZips
	--		inner join dbo.SplitString(@programfk,',') on cteAllZips.ProgramFK = listitem
	--	WHERE NOT (screenedzip = 0 AND servedzip = 0)
	--	group by zipcode
	--	order by zipcode
end
GO
