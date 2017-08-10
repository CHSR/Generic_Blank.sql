SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Dhruv Patel
-- Create date: 2015-08-04
-- Description:	Adds an additional report to the QA report for Home 
--				Visit Logs missing attachments
-- exec rspQAReport19 1, 'summary'
-- exec rspQAReport19 1, 'detail'
-- =============================================
CREATE procedure [dbo].[rspQAReport19](
@programfk    varchar(max)    = NULL,
@ReportType char(7) = NULL 

)
as
declare @CutOffDate date
set @CutOffDate = '2015-05-01'
if @programfk is null
	begin
		select @programfk = substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end

	set @programfk = REPLACE(@programfk,'"','')
	
	-- Last Day of Previous Month 
Declare @LastDayofPreviousMonth DateTime 
Set @LastDayofPreviousMonth = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE()),0)) -- analysis point


set @CutOffDate = DATEADD(m, -3,  @LastDayofPreviousMonth) + 1


DECLARE @endDt AS DATE 
SET @endDt = DATEADD(dd, DATEDIFF(dd, 0, @LastDayofPreviousMonth), 0)

DECLARE @tbl4QAReportCohort TABLE(
	HVCaseFK int,
	HVLogPK int,
	PC1ID char(13),
	VisitStartTime datetime,
	CurrentLevel varchar(30), 
	CurrentWorker varchar(40)
)

insert into @tbl4QAReportCohort
        ( HVCaseFK ,
		  HVLogPK ,
          PC1ID ,
          VisitStartTime ,
          CurrentLevel ,
          CurrentWorker 
        )
select hv.HVCaseFK
		, hv.HVLogPK
		, PC1ID
		, VisitStartTime
		, CurrentLevel = cl.LevelName
		, CurrentWorker = rtrim(w.FirstName) + ' ' + rtrim(w.LastName)
		from HVLog hv 
		inner join CaseProgram cp on cp.HVCaseFK = hv.HVCaseFK and cp.ProgramFK = hv.ProgramFK
		left join codeLevel cl on cp.CurrentLevelFK = cl.codeLevelPK
		inner join Worker w on w.WorkerPK = cp.CurrentFSWFK
		where cp.ProgramFK = @ProgramFK 
				and hv.VisitType <> '00010'
				and VisitStartTime >= @CutOffDate AND hv.VisitStartTime <=  @endDt
				--and (cp.DischargeDate IS NULL  
				--		or cp.DischargeDate > @LastDayofPreviousMonth)
						
if @ReportType = 'summary'
	begin

		declare @cohortCount int=0
		set @cohortCount= (select count(PC1ID) from @tbl4QAReportCohort)
		
		declare @missingAttachCount int=0
		set @missingAttachCount = (select count(PC1ID) from @tbl4QAReportCohort qarc
									 left outer join Attachment a on a.HVCaseFK = qarc.HVCaseFK and a.FormType = 'VL' and a.FormFK = HVLogPK
									 where a.AttachmentPK is null)
		

		DECLARE @tbl4QAReportMissingAttachHVSummary TABLE(
			[SummaryId] INT,
			[SummaryText] [varchar](200),
			[SummaryTotal] [varchar](100)
		)
		insert into @tbl4QAReportMissingAttachHVSummary
		        ( SummaryId ,
		          SummaryText ,
		          SummaryTotal
		        )
		values  ( 19 , -- SummaryId - int
		          'Number of HV Log forms since ' + CONVERT(VARCHAR(8), @CutOffDate, 1) + ' without an attachment (N=' + CONVERT(varchar,@cohortCount) + ')', -- SummaryText - varchar(200)
		          CONVERT(varchar,@missingAttachCount) + ' (' + 
		          convert(varchar,round(coalesce(cast(@missingAttachCount as float) * 100 / nullif(@cohortCount,0),0),0)) + '%)' -- SummaryTotal - varchar(100)
		        )
		
		select * from @tbl4QAReportMissingAttachHVSummary
		
	end

else
	begin
		select PC1ID ,
               VisitStartTime , 
               CurrentLevel ,
               CurrentWorker ,
               Link = '<a href="/Pages/HomeVisitLog.aspx?pc1id=' + PC1ID + '&hvlogpk=' + rtrim(convert(varchar(12), qarc.HVLogPK)) + '" target="_blank" alt="Home Visit Log">'
		from @tbl4QAReportCohort qarc
		left outer join Attachment a on a.HVCaseFK = qarc.HVCaseFK and a.FormType = 'VL' and a.FormFK = HVLogPK
		where a.AttachmentPK is null
		order by qarc.PC1ID, qarc.VisitStartTime
	end		

GO
