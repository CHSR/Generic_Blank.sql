SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:    <Dar Chen>
-- Create date: <Jul 09, 2012>
-- Description: 
-- exec rspFSWPreIntakeTickler 28, '20130201', null, null
-- Edit date: 10/11/2013 CP - workerprogram was duplicating cases when worker transferred
-- Edit date: 12/09/2013 JR - remove FSWFK, SupFK and PC1ID from parameters
-- =============================================
CREATE procedure [dbo].[rspFSWPreIntakeTickler]
(
    @programfk		int			= null,
    @rdate			datetime	
)
as
	
-- Preassessment Table : CaseStatus, HVCaseFK, PADate, ProgramFK
-- CaseStatus = '01' : Engagement Efforts Continue into next month                                                
-- CaseStatus = '02' : Assessment Completed
-- CaseStatus = '03' : Engagement Efforts Terminated, Kempe not Completed

--DECLARE @programfk INT = 6
--DECLARE @workerfk INT = NULL
--DECLARE @supervisorfk INT = NULL
--DECLARE @rdate DATETIME = '01/01/2012'

;
with lastpreintake
as
(
(select HVCaseFK
	   ,max(PIDate) [LastPreIntakeDate]
	from Preintake
	where ProgramFK = @programfk
	group by HVCaseFK)
)

select c.PC1ID [pc1ID]
	  ,rtrim(b.PCFirstName)+' '+rtrim(b.PCLastName) [Name]
	  ,rtrim(b.PCStreet)+case when b.PCApt is null then '' else ' '+rtrim(b.PCApt) end [Street]
	  ,rtrim(b.PCCity)+case when b.PCCity is not null or len(b.PCCity) > 0 then ', NY' else 'NY' end
	   +' '+rtrim(b.PCZip) [City]
	  ,b.PCPhone + CASE when b.PCEmergencyPhone is not null and b.PCEmergencyPhone <> '' then
	   + ' Emr:' + b.PCEmergencyPhone ELSE '' END
	   + CASE when b.PCCellPhone is not null and b.PCCellPhone <> '' then
	   + ' Cell:' + b.PCCellPhone ELSE '' END [Phone]
	  ,datediff(day,d.FSWAssignDate,@rdate) [DaysSinceFSW]
	  ,convert(varchar(12),DATEADD(day,30.44*3,case when a.TCDOB is not null then a.TCDOB else a.EDC end),101) 
		  [EnrollmentAgeOutDate]
	  ,case when DATEADD(day,30.44*3,case when a.TCDOB is not null then a.TCDOB else a.EDC end) <= current_timestamp
			   then '*' else '' end as AgedOut
	  ,substring(convert(varchar(30),e.LastPreIntakeDate,106),4,20) [LastIntakeForm]
	  ,ltrim(rtrim(fsw.firstname))+' '+ltrim(rtrim(fsw.lastname)) fswname
	  ,ltrim(rtrim(supervisor.firstname))+' '+ltrim(rtrim(supervisor.lastname)) as supervisor
	  ,d.PAFSWFK

	  ,e.LastPreIntakeDate
	  ,convert(varchar(12),d.FSWAssignDate,101) [FSWDateAssigned]
	--, *
	from HVCase as a
		join PC as b on a.PC1FK = b.PCPK
		join CaseProgram as c on c.HVCaseFK = a.HVCasePK
		join Preassessment as d on a.HVCasePK = d.HVCaseFK and d.CaseStatus = '02'
		left outer join lastpreintake as e on e.HVCaseFK = a.HVCasePK
		inner join worker fsw on fsw.workerpk = c.currentfswfk
		inner join workerprogram on workerfk = fsw.workerpk  and WorkerProgram.ProgramFK=@programfk
		inner join worker supervisor on supervisorfk = supervisor.workerpk

	where c.DischargeDate is null
		 and c.ProgramFK = @programfk
		 and c.CurrentLevelFK in (7,8)
		 --and caseprogress >= 11
		 --and c.currentFSWFK = isnull(@workerfk,c.CurrentFSWFK)
		 --and SupervisorFK = isnull(@supervisorfk,SupervisorFK)
		 --and PC1ID = isnull(@pc1id, PC1ID)

--where followup.hvcasefk is null
--and CaseProgress >= 11
--and CurrentFSWFK = isnull(@workerfk,CurrentFSWFK)
--and SupervisorFK = isnull(@supervisorfk,SupervisorFK)
--and (DischargeDate is null)
--and year(dateadd(dd,dueby,hvcase.tcdob)) = year(@rdate)
--and month(dateadd(dd,dueby,hvcase.tcdob)) = month(@rdate)
GO
