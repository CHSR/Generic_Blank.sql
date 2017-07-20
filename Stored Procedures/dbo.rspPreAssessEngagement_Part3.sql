SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:      <Dar Chen>
-- Create date: <Aug 13, 2012>
-- Description: 
-- =============================================
CREATE procedure [dbo].[rspPreAssessEngagement_Part3]
(
    @programfk varchar(max)    = null,
    @StartDt   datetime        = null,
    @EndDt     datetime        = null
)
as
	if @programfk is null
	begin
		select @programfk = substring((select ','+ltrim(rtrim(str(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end
	set @programfk = replace(@programfk,'"','')

	--DECLARE @StartDtT DATE = '09/01/2012'
	--DECLARE @StartDt DATE = '09/01/2012'
	--DECLARE @EndDt DATE = '11/30/2012'
	--DECLARE @programfk INT = 4

	-- no status pre-assessment cases (no form this month)
	;
	with zzz
	as (select x.HVCaseFK
			  ,x.PADate
			  ,'xx' [CaseStatus]
			  , KempeResult
			  , FSWAssignDate
			from Preassessment as x
				join (select a.HVCaseFK
							,max(a.PADate) [maxDate]
						  from Preassessment as a
							  join dbo.SplitString(@programfk,',') on a.programfk = listitem
						  where --a.ProgramFK = @programfk AND 
							   a.PADate < @StartDt
						  group by a.HVCaseFK) as y on x.HVCaseFK = y.HVCaseFK and x.PADate = maxDate
			where x.CaseStatus = '01'),
	qqq
	as (select *
			from Preassessment as a
				join dbo.SplitString(@programfk,',') on a.programfk = listitem
			where --a.ProgramFK = @programfk AND 
				 a.PADate between @StartDt and @EndDt
	),
	NoStatus
	as (select a.HVCaseFK
		      , a.PADate
			  , a.CaseStatus
			  ,'1' [NoStatus]
			  , a.KempeResult
			  , a.FSWAssignDate
			from zzz as a
				left outer join qqq as b on a.HVCaseFK = b.HVCaseFK
			where b.HVCaseFK is null
	),
	No_PreAssessment
	as (select a.HVCaseFK
			  ,null [PADate]
			  ,'xx' [CaseStatus]
			  ,'1' [NoStatus]
			  , KempeResult
			  , FSWAssignDate
			from HVScreen as a
				join CaseProgram as c on c.HVCaseFK = a.HVCaseFK
				join dbo.SplitString(@programfk,',') on c.programfk = listitem
				left outer join Preassessment as b on b.HVCaseFK = a.HVCaseFK and b.PADate <= @EndDt
			where --a.ProgramFK = @programfk AND 
				 --a.ScreenDate <= @EndDt
				 a.ScreenDate between @StartDt and @EndDt
				 and (c.DischargeDate IS NULL OR c.DischargeDate > @StartDt)
				 and a.ScreenResult = '1'
				 and a.ReferralMade = '1'
				 and b.HVCaseFK is null
	),
	AllPreAssessment
	as (select x.HVCaseFK
			  ,x.PADate
			  ,x.CaseStatus
			  ,'0' [NoStatus]
			  , KempeResult
			  , FSWAssignDate
			from Preassessment as x
				join (select p.HVCaseFK
							,max(p.PADate) [max_PADATE]
						  from PreAssessment as p
							  join dbo.SplitString(@programfk,',') on p.programfk = listitem
						  where p.PADate between @StartDt and @EndDt --AND p.ProgramFK = @programfk
						  group by p.HVCaseFK) as y on x.HVCaseFK = y.HVCaseFK and x.PADate = y.max_PADATE
		union all
		select *
			from NoStatus
		union all
		select *
			from No_PreAssessment
	)
	select b.PC1ID
		  ,convert(varchar(12),a.ScreenDate,101) [ScreenDate]
		  ,convert(varchar(12),x.PADate,101) [PADate]
		  ,x.HVCaseFK
		  ,case
			   when x.NoStatus = '1' then
				   'No Status'
			   when x.CaseStatus = '01' and datediff(d,x.PADate,@EndDt) <= 30 then
				   'Engagement Continues'
			   when x.CaseStatus = '01' and datediff(d,x.PADate,@EndDt) > 30 then
				   'No Status'
			   when x.CaseStatus = '02'
					and KempeResult = 1
					and FSWAssignDate > @EndDt then 
					'Positive, Pending'
			   when x.CaseStatus = '02'
					and KempeResult = 0 then 
					'Negative'
			   when x.CaseStatus = '02' then
				   'Positive, Assigned'
			   when x.CaseStatus = '03' then
				   'Terminated'
			   when x.CaseStatus = '04' then
				   'Positive, Not Assigned'
			   else
				   'No Status'
		   end [CaseStatusText]
		  ,rtrim(w.FirstName)+' '+rtrim(w.LastName) [WorkName]

		from AllPreAssessment x
			join HVCase as a on x.HVCaseFK = a.HVCasePK
			join CaseProgram as b on b.HVCaseFK = x.HVCaseFK
			join Worker as w on w.WorkerPK = b.CurrentFAWFK

		order by [WorkName]
				,b.PC1ID

GO
