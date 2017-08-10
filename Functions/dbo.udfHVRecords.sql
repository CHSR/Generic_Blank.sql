SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Jan 4, 2012>
-- Description:	<udfHVRecords - helper function for HV Achievement Rate reports>
-- =============================================
CREATE function [dbo].[udfHVRecords]
(-- Add the parameters for the function here
 @programfk varchar(max)    = null,
 @sdate     datetime,
 @edate     datetime
 )
returns
@tHVRecords table(
	casefk int,
	startdate datetime,
	enddate datetime,
	levelname varchar(50),
	programfk int,
	workerfk int,
	reqvisitcalc float,
	hvlevelpk int,
	reqvisit float,
	hvlogpk int,
	visittype varchar(5),
	visitlengthminute int,
	visitlengthhour int,
	VisitStartTime datetime,
	pc1id varchar(13),
	dischargedate datetime
)
as
begin

	if @programfk is null
	begin
		select @programfk =
			   substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
							  from HVProgram
							  for xml path ('')),2,8000)
	end

	set @programfk = REPLACE(@programfk,'"','')

	declare @startdate datetime
	declare @enddate datetime;
	
	--set @startdate = convert(datetime,convert(varchar(12), @sdate) + '00:00:00.000') --Chris Papas removed 01/29/2013 
	--set @enddate = convert(datetime,convert(varchar(12), @edate) + '23:59:59.999')

	with cteCohort as 
		(
			select max(CaseProgramPK) as CaseProgramPK
			from CaseProgram cp
			inner join HVLog hl on hl.HVCaseFK = cp.HVCaseFK 
									and convert(date, VisitStartTime) > CaseStartDate 
									and convert(date, VisitStartTime) between @sdate and @edate
			inner join SplitString(@ProgramFK, ',') ss on ss.ListItem = cp.ProgramFK
			group by cp.HVCaseFK
	)
		
	--match the hvlog records to this
	insert
		into @THVRecords
		select tlp.casefk
			 , tlp.startdate
			 , tlp.enddate
			 , tlp.levelname
			 , tlp.programfk
			 , tlp.workerfk
			 , tlp.reqvisitcalc
			 , tlp.hvlevelpk
			 , tlp.reqvisit
			  ,HVLogPK
			  ,VisitType
			  ,VisitLengthMinute
			  ,VisitLengthHour
			  ,VisitStartTime
			  ,cp.PC1id
			  ,cp.DischargeDate
			from cteCohort co
				inner join CaseProgram cp on cp.CaseProgramPK = co.CaseProgramPK
				inner join [dbo].[udfLevelPieces](@programfk,@sdate,@edate) tlp on tlp.casefk = cp.HVCaseFK and tlp.startdate >= cp.CaseStartDate
				left outer join hvlog on tlp.casefk = hvlog.hvcasefk
							   and cast(VisitStartTime AS DATE) between tlp.StartDate and tlp.EndDate

	return

end
GO
