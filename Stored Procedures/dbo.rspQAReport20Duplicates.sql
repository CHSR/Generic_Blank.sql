SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<jrobohn>
-- Create date: <2017-03-23>
-- Description:	<Spits out duplicates from all tables for Quality Assurance report>
-- =============================================
CREATE procedure [dbo].[rspQAReport20Duplicates]
	-- Add the parameters for the stored procedure here
	@ProgramFKs varchar(max)
	, @ReportType char(7) = null 
as
begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set nocount on;

  	if @ProgramFKs is null
	begin
		select @ProgramFKs = substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end

	set @ProgramFKs = REPLACE(@ProgramFKs,'"','')

	declare @tblQAReport20Temp TABLE(
		PC1ID varchar(max),	
		FormType varchar(200),
		FormDate datetime,
		CreateDate datetime, 
		Creator char(10)		
	)

	;with cteDupLevelsSameLevel as (
	  select hl.HVLevelPK	
				, HVCaseFK
				, ProgramFK
				, LevelFK
				, LevelAssignDate
				, HVLevelEditDate
				, HVLevelCreateDate
				, row_number() over(partition by HVCaseFK
												, ProgramFK
												, LevelFK
												, LevelAssignDate 
									order by HVLevelEditDate desc) as [RowNumber]
	  from HVLevel hl
	)
	, cteDupLevelsDiffLevels as 
		(
		  select HVLevelPK
					, HVCaseFK
					, row_number() over(partition by HVCaseFK
													, ProgramFK
													, LevelAssignDate 
										order by HVLevelEditDate desc
													, LevelFK desc) as [RowNumber]
		  from HVLevel hl
		)
	, cteDupWorkerAssignmentsSameWorker as (
	  select WorkerAssignmentPK
				, HVCaseFK
				, ProgramFK
				, WorkerFK
				, WorkerAssignmentDate
				, WorkerAssignmentEditDate
				, WorkerAssignmentCreateDate
				, row_number() over(partition by HVCaseFK
												, ProgramFK
												, WorkerFK
												, WorkerAssignmentDate
									order by WorkerAssignmentEditDate desc) as [RowNumber]
	  from WorkerAssignment wa
	)
	, cteDupWorkerAssignmentsDiffWorkers as 
		(
		  select WorkerAssignmentPK
					, HVCaseFK
					, row_number() over(partition by HVCaseFK
													, ProgramFK
													, WorkerAssignmentDate
										order by WorkerAssignmentEditDate desc) as [RowNumber]
		  from WorkerAssignment wa
		)
	--select HVCaseFK
	--from cteLevelsToDelete2 ltd
	--where RowNumber > 1 and HVCaseFK in (select HVCaseFK from cteLevelsToDelete where RowNumber > 1)
	insert into @tblQAReport20Temp(
			PC1ID,
			FormType,
			FormDate,
			CreateDate, 
			Creator
		)
  
	select PC1ID 
			, 'Attachment-' + FormType  as FormType
			, FormDate
			, AttachmentCreateDate as CreateDate
			, AttachmentCreator as Creator
	from Attachment a
	inner join CaseProgram cp on cp.HVCaseFK = a.HVCaseFK and cp.ProgramFK = a.ProgramFK
	inner join SplitString(@ProgramFKs, ',') ss on ListItem = cp.ProgramFK
	where a.FormType in ('KE', 'VL')
			and convert(char, a.HVCaseFK) + FormType + convert(char,a.FormFK) + convert(char, a.FormDate, 101)
				in (select convert(char, a2.HVCaseFK) + a2.FormType + convert(char,a2.FormFK) + convert(char, a2.FormDate, 101) 
					from Attachment a2
					group by convert(char, a2.HVCaseFK) + a2.FormType + convert(char,a2.FormFK) + convert(char, a2.FormDate, 101) 
					having count(*) > 1)
	union
	select PC1ID 
			, 'Home Visit Log' as FormType
			, convert(date, VisitStartTime) as FormDate
			, HVLogCreateDate as CreateDate
			, HVLogCreator as Creator
	from HVLog h
	inner join CaseProgram cp on cp.HVCaseFK = h.HVCaseFK and cp.ProgramFK = h.ProgramFK
	inner join SplitString(@ProgramFKs, ',') ss on ListItem = cp.ProgramFK
	where convert(char, h.HVCaseFK) + 
			convert(char, h.ProgramFK) + 
			convert(char(20), h.VisitStartTime, 120) + 
			convert(char,h.VisitLengthHour) + 
			convert(char,h.VisitLengthMinute)
				  in (select convert(char, h2.HVCaseFK) + 
								convert(char, h2.ProgramFK) + 
								convert(char(20), VisitStartTime, 120) + 
								convert(char,h2.VisitLengthHour) + 
								convert(char,h2.VisitLengthMinute)
						 from HVLog h2
						 group by convert(char, h2.HVCaseFK)
											 , convert(char, h2.ProgramFK)
											 , convert(char(20), VisitStartTime, 120)
											 , convert(char,h2.VisitLengthHour)
											 , convert(char,h2.VisitLengthMinute)
						 having count(*) > 1)
	union
	select PC1ID 
			, 'LevelForm' as FormType
			, LevelAssignDate as FormDate
			, HVLevelCreateDate as CreateDate
			, HVLevelCreator as Creator
	from HVLevel hl
	inner join CaseProgram cp on cp.HVCaseFK = hl.HVCaseFK and cp.ProgramFK = hl.ProgramFK
	inner join SplitString(@ProgramFKs, ',') ss on ListItem = cp.ProgramFK
	where convert(char, hl.HVCaseFK) + convert(char, hl.ProgramFK) + convert(char, hl.LevelFK) + convert(char(10), hl.LevelAssignDate, 112)
			in (select convert(char, hl2.HVCaseFK) + convert(char, hl2.ProgramFK) + convert(char, hl2.LevelFK) + convert(char(10), hl2.LevelAssignDate, 112)
				from HVLevel hl2
				group by convert(char, hl2.HVCaseFK)
							, convert(char, hl2.ProgramFK)
							, convert(char, hl2.LevelFK)
							, convert(char(10), hl2.LevelAssignDate, 112)
				having count(*) > 1)
	union
	select PC1ID 
			, 'LevelForm-Diff Levels' as FormType
			, LevelAssignDate as FormDate
			, HVLevelCreateDate as CreateDate
			, HVLevelCreator as Creator
	from HVLevel hl
	inner join CaseProgram cp on cp.HVCaseFK = hl.HVCaseFK and cp.ProgramFK = hl.ProgramFK
	inner join SplitString(@ProgramFKs, ',') ss on ListItem = cp.ProgramFK
	where convert(char, hl.HVCaseFK) + convert(char(10), hl.LevelAssignDate, 112)
			in (select convert(char, hl2.HVCaseFK) + convert(char(10), hl2.LevelAssignDate, 112)
				from HVLevel hl2
				group by convert(char, hl2.HVCaseFK)
							, convert(char(10), hl2.LevelAssignDate, 112)
				having count(*) > 1)
			and HVLevelPK not in (select HVLevelPK from cteDupLevelsSameLevel where RowNumber > 1)
	union
	select PC1ID 
			, 'WorkerAssignment' as FormType
			, WorkerAssignmentDate as FormDate
			, WorkerAssignmentCreateDate as CreateDate
			, WorkerAssignmentCreator as Creator
	from WorkerAssignment wa
	inner join CaseProgram cp on cp.HVCaseFK = wa.HVCaseFK and cp.ProgramFK = wa.ProgramFK and WorkerAssignmentDate > CaseStartDate
	inner join SplitString(@ProgramFKs, ',') ss on ListItem = cp.ProgramFK
	where convert(char, wa.HVCaseFK) + convert(char, WorkerFK) + convert(char(10), wa.WorkerAssignmentDate, 112)
			in (select convert(char, wa2.HVCaseFK) + convert(char, WorkerFK) + convert(char(10), wa2.WorkerAssignmentDate, 112)
				from WorkerAssignment wa2
				group by convert(char, wa2.HVCaseFK)
							, convert(char, wa2.WorkerFK)
							, convert(char(10), wa2.WorkerAssignmentDate, 112)
				having count(*) > 1)
	union
	select PC1ID
			, 'WorkerAssigment-Diff Workers' as FormType
			, WorkerAssignmentDate as FormDate
			, WorkerAssignmentCreateDate as CreateDate
			, WorkerAssignmentCreator as Creator
	from WorkerAssignment wa
	inner join CaseProgram cp on cp.HVCaseFK = wa.HVCaseFK and cp.ProgramFK = wa.ProgramFK and WorkerAssignmentDate > CaseStartDate
	inner join SplitString(@ProgramFKs, ',') ss on ListItem = cp.ProgramFK
	where convert(char, wa.HVCaseFK) + convert(char(10), wa.WorkerAssignmentDate, 112)
			in (select convert(char, wa2.HVCaseFK) + convert(char(10), wa2.WorkerAssignmentDate, 112)
				from WorkerAssignment wa2
				group by convert(char, wa2.HVCaseFK)
							, convert(char(10), wa2.WorkerAssignmentDate, 112)
				having count(*) > 1)
			and WorkerAssignmentPK not in (select WorkerAssignmentPK from cteDupWorkerAssignmentsSameWorker where RowNumber > 1)
	union
	select PC1ID
			, 'Screen' as FormType
			, hs.ScreenDate as FormDate
			, ScreenCreateDate as CreateDate
			, ScreenCreator as Creator
	from HVScreen hs
	inner join HVCase hc on hc.HVCasePK = hs.HVCaseFK
	inner join CaseProgram cp on cp.HVCaseFK = hc.HVCasePK
	inner join SplitString(@ProgramFKs, ',') ss on ListItem = cp.ProgramFK
	where convert(char, hs.HVCaseFK) + convert(char, hs.ProgramFK) + convert(char(10), hs.ScreenDate, 112)
			in (select convert(char, hs2.HVCaseFK) + convert(char, hs2.ProgramFK) + convert(char(10), hs2.ScreenDate, 112)
				from HVScreen hs2
				group by convert(char, hs2.HVCaseFK)
							, convert(char, hs2.ProgramFK)
							, convert(char(10), hs2.ScreenDate, 112)
				having count(*) > 1)
	union
	select PC1ID
			, 'Pre-Assessment' as FormType
			, PADate as FormDate
			, PACreateDate as CreateDate
			, PACreator as Creator
	from Preassessment p
	inner join CaseProgram cp on cp.HVCaseFK = p.HVCaseFK and cp.ProgramFK = p.ProgramFK and PADate > CaseStartDate
	inner join SplitString(@ProgramFKs, ',') ss on ListItem = cp.ProgramFK
	where convert(char, p.HVCaseFK) + convert(char, p.ProgramFK) + convert(char(10), p.PADate, 112)
			in (select convert(char, p2.HVCaseFK) + convert(char, p2.ProgramFK) + convert(char(10), p2.PADate, 112)
				from Preassessment p2
				group by convert(char, p2.HVCaseFK)
							, convert(char, p2.ProgramFK)
							, convert(char(10), p2.PADate, 112)
				having count(*) > 1)
	union
	select PC1ID
			, 'Pre-Intake' as FormType
			, PIDate as FormDate
			, PICreateDate as CreateDate
			, PICreator as Creator
	from Preintake p
	inner join CaseProgram cp on cp.HVCaseFK = p.HVCaseFK and cp.ProgramFK = p.ProgramFK and PIDate > CaseStartDate
	inner join SplitString(@ProgramFKs, ',') ss on ListItem = cp.ProgramFK
	where convert(char, p.HVCaseFK) + convert(char, p.ProgramFK) + convert(char(10), p.PIDate, 112)
			in (select convert(char, p2.HVCaseFK) + convert(char, p2.ProgramFK) + convert(char(10), p2.PIDate, 112) as DupKey
				from Preintake p2
				group by convert(char, p2.HVCaseFK)
							, convert(char, p2.ProgramFK)
							, convert(char(10), p2.PIDate, 112)
				having count(*) > 1)
	union
	select PC1ID
			, 'Kempe' as FormType
			, KempeDate as FormDate
			, KempeCreateDate as CreateDate
			, KempeCreator as Creator
	from Kempe k
	inner join CaseProgram cp on cp.HVCaseFK = k.HVCaseFK and cp.ProgramFK = k.ProgramFK and KempeDate > CaseStartDate
	inner join SplitString(@ProgramFKs, ',') ss on ListItem = cp.ProgramFK
	where convert(char, k.HVCaseFK) + convert(char, k.ProgramFK) + convert(char(10), k.KempeDate, 112) 
			in (select convert(char, k2.HVCaseFK) + convert(char, k2.ProgramFK) + convert(char(10), k2.KempeDate, 112)
				from Kempe k2
				group by convert(char, k2.HVCaseFK)
							, convert(char, k2.ProgramFK)
							, convert(char(10), k2.KempeDate, 112)
				having count(*) > 1)
	union
	select PC1ID
			, 'Intake' as FormType
			, IntakeDate as FormDate
			, IntakeCreateDate as CreateDate
			, IntakeCreator as Creator
	from Intake i
	inner join CaseProgram cp on cp.HVCaseFK = i.HVCaseFK and cp.ProgramFK = i.ProgramFK and IntakeDate > CaseStartDate
	inner join SplitString(@ProgramFKs, ',') ss on ListItem = cp.ProgramFK
	where convert(char, i.HVCaseFK) + convert(char, i.ProgramFK)
			in (select convert(char, i2.HVCaseFK) + convert(char, i2.ProgramFK)
				from Intake i2
				group by convert(char, i2.HVCaseFK)
							, convert(char, i2.ProgramFK)
				having count(*) > 1)
	union
	select PC1ID
		 , 'ASQ' as FormType
		 , a.DateCompleted as FormDate
		 , ASQCreateDate as CreateDate
		 , ASQCreator as Creator
	from ASQ a
	inner join CaseProgram cp on cp.HVCaseFK = a.HVCaseFK and cp.ProgramFK = a.ProgramFK
	inner join SplitString(@ProgramFKs, ',') ss on ListItem = cp.ProgramFK
	where convert(char, a.HVCaseFK) + convert(char, a.ProgramFK) + a.TCAge + convert(char, TCIDFK)
			in (select convert(char, a2.HVCaseFK) + convert(char, a2.ProgramFK) + a2.TCAge + convert(char, a2.TCIDFK)
				from ASQ a2
				group by a2.HVCaseFK
							, a2.ProgramFK
							, a2.TCAge
							, a2.TCIDFK
				having count(*) > 1)
	union
	select PC1ID
		 , 'ASQ-SE' as FormType
		 , a.ASQSEDateCompleted as FormDate
		 , ASQSECreateDate as CreateDate
		 , ASQSECreator as Creator
	from ASQSE a
	inner join CaseProgram cp on cp.HVCaseFK = a.HVCaseFK and cp.ProgramFK = a.ProgramFK and ASQSEDateCompleted > CaseStartDate
	inner join SplitString(@ProgramFKs, ',') ss on ListItem = cp.ProgramFK
	where convert(char, a.HVCaseFK) + convert(char, a.ProgramFK) + a.ASQSETCAge + convert(char, a.TCIDFK)
			in (select convert(char, a2.HVCaseFK) + convert(char, a2.ProgramFK) + a2.ASQSETCAge + convert(char, a2.TCIDFK)
				from ASQSE a2
				group by a2.HVCaseFK
							, a2.ProgramFK
							, a2.ASQSETCAge
							, a2.TCIDFK
				having count(*) > 1)
	/*
		TCID - also needs sanity checks for count of TC rows vs. NumberOfChildren, TCNumber and MultipleBirth
	*/
	union
	select PC1ID
			, 'TCID' as FormType
			, TCDOB as FormDate
			, TCIDCreateDate as CreateDate
			, TCIDCreator as Creator
	from TCID t
	inner join CaseProgram cp on cp.HVCaseFK = t.HVCaseFK and cp.ProgramFK = t.ProgramFK and TCDOB > CaseStartDate
	inner join SplitString(@ProgramFKs, ',') ss on ListItem = cp.ProgramFK
	where convert(char, t.HVCaseFK) + TCFirstName in (select convert(char, t2.HVCaseFK) + t2.TCFirstName as DupKey
														from TCID T2
														group by convert(char, t2.HVCaseFK), t2.TCFirstName
														having count(t2.HVCaseFK) > 1)
	union
	select PC1ID
			, 'Follow-Up' as FormType
			, FollowUpDate as FormDate
			, FollowUpCreateDate as CreateDate
			, FollowUpCreator as Creator
	from FollowUp fu
	inner join CaseProgram cp on cp.HVCaseFK = fu.HVCaseFK and cp.ProgramFK = fu.ProgramFK and FollowUpDate > CaseStartDate
	inner join SplitString(@ProgramFKs, ',') ss on ListItem = cp.ProgramFK
	where convert(char, fu.HVCaseFK) + convert(char, fu.ProgramFK) + fu.FollowUpInterval 
			in (select convert(char, fu2.HVCaseFK) + convert(char, fu2.ProgramFK) + fu2.FollowUpInterval
				from FollowUp fu2
				group by convert(char, fu2.HVCaseFK) + convert(char, fu2.ProgramFK) + fu2.FollowUpInterval
				having count(*) > 1)
	union
	select PC1ID
		 , 'Common Attributes - ' + FormType as FormType
		 , FormDate
		 , CommonAttributesCreateDate as CreateDate
		 , CommonAttributesCreator as Creator
	from CommonAttributes ca 
	inner join CaseProgram cp on cp.HVCaseFK = ca.HVCaseFK and cp.ProgramFK = ca.ProgramFK and FormDate > CaseStartDate
	inner join SplitString(@ProgramFKs, ',') ss on ListItem = cp.ProgramFK
	where FormType <> 'TC' and
			FormType <> 'CH' and
			convert(char, ca.ProgramFK) 
			+ convert(char, ca.HVCaseFK) 
			+ ca.FormType 
			+ ca.FormInterval 
			+ convert(char, ca.FormFK) 
			+ convert(char(20), ca.FormDate, 120)
			in (select convert(char, ca2.ProgramFK) 
						+ convert(char, ca2.HVCaseFK)
						+ ca2.FormType + ca2.FormInterval
						+ convert(char, ca2.FormFK)
						+ convert(char(20), ca2.FormDate, 120)
				from CommonAttributes ca2
				group by convert(char, ca2.ProgramFK)
							, convert(char, ca2.HVCaseFK)
							, ca2.FormType 
							, ca2.FormInterval
							, convert(char, ca2.FormFK)
							, convert(char(20), ca2.FormDate, 120)
				having count(*) > 1)
	union
	select PC1ID
		 , 'Audit-C' as FormType
		 , KempeDate as FormDate
		 , ac.AuditCCreateDate as CreateDate
		 , ac.AuditCCreator	as Creator
	from AuditC ac
	inner join CaseProgram cp on cp.HVCaseFK = ac.HVCaseFK and cp.ProgramFK = ac.ProgramFK
	inner join HVCase hc on hc.HVCasePK = cp.HVCaseFK
	inner join SplitString(@ProgramFKs, ',') ss on ListItem = cp.ProgramFK
	where KempeDate > CaseStartDate
			and convert(char, ac.HVCaseFK) + ac.FormType + ac.FormInterval 
				in (select convert(char, ac2.HVCaseFK) + ac2.FormType + ac2.FormInterval
					from AuditC ac2
					group by convert(char, ac2.HVCaseFK) + ac2.FormType + ac2.FormInterval
					having count(*) > 1)
	union
	select	PC1ID
		  , 'Case Filter' as FormType
		  , CaseFilterCreateDate as FormDate
		  , cf.CaseFilterCreateDate as CreateDate
		  , cf.CaseFilterCreator as Creator
	from	CaseFilter cf
	inner join CaseProgram cp on cp.HVCaseFK = cf.HVCaseFK and cp.ProgramFK = cf.ProgramFK and CaseFilterCreateDate > CaseStartDate
	inner join SplitString(@ProgramFKs, ',') ss on ListItem = cp.ProgramFK
	where	convert(char, cf.HVCaseFK) + convert(char, cf.CaseFilterNameFK) in 
			(select	convert(char, cf2.HVCaseFK) + convert(char, cf2.CaseFilterNameFK)
				from	CaseFilter cf2
				group by convert(char, cf2.HVCaseFK) + convert(char, cf2.CaseFilterNameFK)
				having	count(*) > 1)
	union
	select PC1ID
			, 'Case Note' as FormType
			, CaseNoteDate as FormDate
			, CaseNoteCreateDate as CreateDate
			, CaseNoteCreator as Creator
	from CaseNote cn
	inner join CaseProgram cp on cp.HVCaseFK = cn.HVCaseFK and cp.ProgramFK = cn.ProgramFK and CaseNoteDate > CaseStartDate
	inner join SplitString(@ProgramFKs, ',') ss on ListItem = cp.ProgramFK
	where convert(char, cn.HVCaseFK) + convert(char(10), cn.CaseNoteDate, 112) + cn.CaseNoteContents
			in (select convert(char, cn2.HVCaseFK) + convert(char(10), cn2.CaseNoteDate, 112) + cn2.CaseNoteContents
				from CaseNote cn2
				group by convert(char, cn2.HVCaseFK)
							, convert(char(10), cn2.CaseNoteDate, 112)
							, cn2.CaseNoteContents
				having count(*) > 1)
	union
	select PC1ID
			, 'Education-' + FormType as FormType
			, FormDate
			, EducationCreateDate as CreateDate
			, EducationCreator as Creator
	from Education e
	inner join CaseProgram cp on cp.HVCaseFK = e.HVCaseFK and cp.ProgramFK = e.ProgramFK and FormDate > CaseStartDate
	inner join SplitString(@ProgramFKs, ',') ss on ListItem = cp.ProgramFK
	where convert(char, e.HVCaseFK) 
			+ isnull(e.FormType, '')
			+ isnull(e.Interval , '')
			+ isnull(e.PCType, '') 
			+ isnull(e.ProgramType, '') 
			+ isnull(e.ProgramName, '') 
			+ isnull(e.ProgramTypeSpecify, '') 
			in (select convert(char, e2.HVCaseFK) 
						+ isnull(e2.FormType, '')
						+ isnull(e2.Interval, '')
						+ isnull(e2.PCType, '')
						+ isnull(e2.ProgramType, '')
						+ isnull(e2.ProgramName, '')
						+ isnull(e2.ProgramTypeSpecify, '')
				from Education e2
				group by convert(char, e2.HVCaseFK) 
							+ isnull(e2.FormType, '')
							+ isnull(e2.Interval, '')
							+ isnull(e2.PCType, '')
							+ isnull(e2.ProgramType, '')
							+ isnull(e2.ProgramName, '')
							+ isnull(e2.ProgramTypeSpecify, '')
				having count(*) > 1)
	union
	select PC1ID
			, 'Employment-' + FormType as FormType
			, FormDate
			, EmploymentCreateDate as CreateDate
			, EmploymentCreator as Creator
	from Employment e
	inner join CaseProgram cp on cp.HVCaseFK = e.HVCaseFK and cp.ProgramFK = e.ProgramFK and FormDate > CaseStartDate
	inner join SplitString(@ProgramFKs, ',') ss on ListItem = cp.ProgramFK
	where convert(char, e.HVCaseFK)
			+ isnull(e.FormType, '')
			+ isnull(e.Interval, '')
			+ isnull(e.PCType, '')
			+ isnull(convert(char(10), e.EmploymentStartDate, 112), '')
			+ isnull(convert(char, EmploymentMonthlyHours), '')
			+ isnull(convert(char(10), e.EmploymentMonthlyWages), '')
			+ isnull(convert(char(10), e.EmploymentEndDate, 112), '')
			in (select convert(char, e2.HVCaseFK) 
						+ isnull(e2.FormType, '')
						+ isnull(e2.Interval, '')
						+ isnull(e2.PCType, '')
						+ isnull(convert(char(10), e2.EmploymentStartDate, 112), '')
						+ isnull(convert(char, e2.EmploymentMonthlyHours), '')
						+ isnull(convert(char(10), e2.EmploymentMonthlyWages), '')
						+ isnull(convert(char(10), e2.EmploymentEndDate, 112), '')
				from Employment e2
				group by convert(char, e2.HVCaseFK) 
							+ isnull(e2.FormType, '')
							+ isnull(e2.Interval, '')
							+ isnull(e2.PCType, '')
							+ isnull(convert(char(10), e2.EmploymentStartDate, 112), '')
							+ isnull(convert(char, e2.EmploymentMonthlyHours), '')
							+ isnull(convert(char(10), e2.EmploymentMonthlyWages), '')
							+ isnull(convert(char(10), e2.EmploymentEndDate, 112), '')
				having count(*) > 1)
	union
	select PC1ID
			, 'HITS-' + FormType as FormType
			, KempeDate as FormDate
			, HITSCreateDate as CreateDate
			, HITSCreator as Creator
	from HITS h
	left outer join Kempe k on k.HVCaseFK = h.HVCaseFK
	inner join CaseProgram cp on cp.HVCaseFK = h.HVCaseFK and cp.ProgramFK = h.ProgramFK and KempeDate > CaseStartDate
	inner join SplitString(@ProgramFKs, ',') ss on ListItem = cp.ProgramFK
	where convert(char, h.HVCaseFK) + h.FormType + h.FormInterval 
			in (select convert(char, h2.HVCaseFK) + h2.FormType + h2.FormInterval
				from HITS h2
				group by convert(char, h2.HVCaseFK) + h2.FormType + h2.FormInterval
				having count(*) > 1)
	union
	select rtrim(PCFirstName) + ' ' + rtrim(PCLastName) as PC1ID
		 , 'Person' as FormType
		 , null as FormDate
		 , PCCreateDate as CreateDate
		 , PCCreator as Creator
	from PC
	inner join PCProgram pp on pp.PCFK = PC.PCPK
	inner join SplitString(@ProgramFKs, ',') ss on ListItem = pp.ProgramFK
	where PCFirstName + PCLastName + convert(char(10), PCDOB, 112)
			in (select pc2.PCFirstName + pc2.PCLastName + convert(char(10), pc2.PCDOB, 112)
				from PC pc2
				group by pc2.PCFirstName
							, pc2.PCLastName
							, convert(char(10), pc2.PCDOB, 112)
				having count(*) > 1)
	union
	--select * 
	--from PCProgram pp
	--inner join PC p on p.PCPK = pp.PCFK
	--where convert(char, pp.ProgramFK) + convert(char, pp.PCFK)
	--		in (select convert(char, pp2.ProgramFK) + convert(char, pp2.PCFK)
	--			from PCProgram pp2
	--			group by convert(char, pp2.ProgramFK)
	--					, convert(char, pp2.PCFK)
	--			having count(*) > 1)
	--union
	select PC1ID
			, 'PC1 Medical' as FormType
			, PC1ItemDate as FormDate
			, PC1MedicalCreateDate as CreateDate
			, PC1MedicalCreator as Creator
	from PC1Medical pm
	inner join CaseProgram cp on cp.HVCaseFK = pm.HVCaseFK and cp.ProgramFK = pm.ProgramFK and PC1ItemDate > CaseStartDate
	inner join SplitString(@ProgramFKs, ',') ss on ListItem = cp.ProgramFK
	where convert(char, pm.HVCaseFK) + pm.PC1MedicalItem + convert(char(10), pm.PC1ItemDate, 112) + pm.MedicalIssue
			in (select convert(char, pm2.HVCaseFK) + pm2.PC1MedicalItem + convert(char(10), pm2.PC1ItemDate, 112) + pm2.MedicalIssue
				from PC1Medical pm2
				group by convert(char, pm2.HVCaseFK)
							, pm2.PC1MedicalItem
							, convert(char(10), pm2.PC1ItemDate, 112)
							, pm2.MedicalIssue
				having count(*) > 1)
	union
	select PC1ID
			, 'TC Medical' as FormType
			, TCItemDate as FormDate
			, TCMedicalCreateDate as CreateDate
			, TCMedicalCreator as Creator
	from TCMedical tm
	inner join CaseProgram cp on cp.HVCaseFK = tm.HVCaseFK and cp.ProgramFK = tm.ProgramFK and TCItemDate > CaseStartDate
	inner join SplitString(@ProgramFKs, ',') ss on ListItem = cp.ProgramFK
	where convert(char, tm.HVCaseFK) + 
			convert(char, tm.TCIDFK) + 
			tm.TCMedicalItem + 
			convert(char(10), tm.TCItemDate, 112)
			in (select convert(char, tm2.HVCaseFK) + 
						convert(char, tm2.TCIDFK) + 
						tm2.TCMedicalItem + 
						convert(char(10), tm2.TCItemDate, 112)
				from TCMedical tm2
				group by convert(char, tm2.HVCaseFK)
							, convert(char, tm2.TCIDFK)
							, tm2.TCMedicalItem
							, convert(char(10), tm2.TCItemDate, 112)
				having count(*) > 1)
	union
	select PC1ID
			, 'PC1 Issues' as FormType
			, pi.PC1IssuesDate as FormDate
			, PC1IssuesCreateDate as CreateDate
			, PC1IssuesCreator as Creator
	from PC1Issues pi
	inner join CaseProgram cp on cp.HVCaseFK = pi.HVCaseFK and cp.ProgramFK = pi.ProgramFK and PC1IssuesDate > CaseStartDate
	inner join SplitString(@ProgramFKs, ',') ss on ListItem = cp.ProgramFK
	where convert(char, pi.HVCaseFK) + Interval
			in (select convert(char, pi2.HVCaseFK) + pi2.Interval
				from PC1Issues pi2
				group by pi2.HVCaseFK
							, pi2.Interval
				having count(*) > 1)
	union
	-- PC1Issues orphans
	select PC1ID
			, 'PC1 Issues - Orphan' as FormType
			, PC1IssuesDate as FormDate
			, PC1IssuesCreateDate as CreateDate
			, PC1IssuesCreator as Creator
	from PC1Issues pi
	inner join CaseProgram cp on cp.HVCaseFK = pi.HVCaseFK and cp.ProgramFK = pi.ProgramFK and PC1IssuesDate > CaseStartDate
	inner join SplitString(@ProgramFKs, ',') ss on ListItem = cp.ProgramFK
	where PC1IssuesPK not in (select PC1IssuesFK from FollowUp fu
								union all
								select PC1IssuesFK from Kempe k)
	union
	select PC1ID
			, 'PHQ9-' + FormType as FormType
			, DateAdministered as FormDate
			, PHQ9CreateDate as CreateDate
			, PHQ9Creator as Creator 
	from PHQ9 p
	inner join CaseProgram cp on cp.HVCaseFK = p.HVCaseFK and cp.ProgramFK = p.ProgramFK and DateAdministered > CaseStartDate
	inner join SplitString(@ProgramFKs, ',') ss on ListItem = cp.ProgramFK
	where convert(char, p.ProgramFK) + convert(char, p.HVCaseFK) + p.FormType + p.FormInterval + convert(char, p.FormFK)
			in (select convert(char, p2.ProgramFK) + convert(char, p2.HVCaseFK) + p2.FormType + p2.FormInterval + convert(char, p2.FormFK)
				from PHQ9 p2
				group by convert(char, p2.ProgramFK)
							, convert(char, p2.HVCaseFK)
							, p2.FormType 
							, p2.FormInterval
							, convert(char, p2.FormFK)
				having count(*) > 1)
	union
	select PC1ID
			, 'PSI' as FormType
			, PSIDateComplete as FormDate
			, PSICreateDate as CreateDate
			, PSICreator as Creator
	from PSI p
	inner join CaseProgram cp on cp.HVCaseFK = p.HVCaseFK and cp.ProgramFK = p.ProgramFK and PSIDateComplete > CaseStartDate
	inner join SplitString(@ProgramFKs, ',') ss on ListItem = cp.ProgramFK
	where convert(char, p.ProgramFK) + convert(char, p.HVCaseFK) + p.PSIInterval + convert(char(10), p.PSIDateComplete, 112)
			in (select convert(char, p2.ProgramFK) + convert(char, p2.HVCaseFK) + p2.PSIInterval + convert(char(10), p2.PSIDateComplete, 112)
				from PSI p2
				group by convert(char, p2.ProgramFK)
							, convert(char, p2.HVCaseFK)
							, p2.PSIInterval
							, convert(char(10), p2.PSIDateComplete, 112)
				having count(*) > 1)
	union
	select PC1ID
			, 'Service Referral' as FormType
			, ReferralDate as FormDate
			, ServiceReferralCreateDate as CreateDate
			, ServiceReferralCreator as Creator
	from ServiceReferral sr
	inner join CaseProgram cp on cp.HVCaseFK = sr.HVCaseFK and cp.ProgramFK = sr.ProgramFK and ReferralDate > CaseStartDate
	inner join SplitString(@ProgramFKs, ',') ss on ListItem = cp.ProgramFK
	where convert(char, sr.HVCaseFK) + sr.FamilyCode + sr.NatureOfReferral + sr.ServiceCode + isnull(convert(char, sr.ProvidingAgencyFK), '0') + convert(char(10), sr.ReferralDate, 112)
			in (select convert(char, sr2.HVCaseFK) 
						+ sr2.FamilyCode 
						+ sr2.NatureOfReferral 
						+ sr2.ServiceCode 
						+ isnull(convert(char, sr2.ProvidingAgencyFK), '0')
						+ convert(char(10), sr2.ReferralDate, 112)
				from ServiceReferral sr2
				group by convert(char, sr2.HVCaseFK)
							, sr2.FamilyCode
							, sr2.NatureOfReferral
							, sr2.ServiceCode
							, isnull(convert(char, sr2.ProvidingAgencyFK), '0')
							, convert(char(10), sr2.ReferralDate, 112)
				having count(*) > 1)
	union
	select rtrim(FirstName) + ' ' + rtrim(LastName) as PC1ID
			, 'Supervision' as FormType
			, SupervisionDate as FormDate
			, SupervisionCreateDate as CreateDate
			, SupervisionCreator as Creator
	from Supervision s
	inner join Worker w on w.WorkerPK = s.WorkerFK
	inner join WorkerProgram wp on wp.WorkerFK = w.WorkerPK
	inner join SplitString(@ProgramFKs, ',') ss on ListItem = wp.ProgramFK
	where convert(char, s.SupervisorFK) + convert(char, s.WorkerFK) + convert(char(10), s.SupervisionDate, 112) + s.SupervisionStartTime
			in (select convert(char, s2.SupervisorFK) + convert(char, s2.WorkerFK) + convert(char(10), s2.SupervisionDate, 112) + s2.SupervisionStartTime
				from Supervision s2
				group by convert(char, s2.SupervisorFK)
							, convert(char, s2.WorkerFK)
							, s2.SupervisionDate
							, s2.SupervisionStartTime
				having count(*) > 1)
	union
	select TrainingTitle as PC1ID
			, 'Training' as FormType
			, TrainingDate as FormDate
			, TrainingCreateDate as CreateDate
			, TrainingCreator as Creator
	from Training t
	inner join SplitString(@ProgramFKs, ',') ss on ListItem = t.ProgramFK
	where convert(char, t.ProgramFK) + convert(char(10), t.TrainingDate, 112) + t.TrainingTitle
			in (select convert(char, t2.ProgramFK) + convert(char(10), t2.TrainingDate, 112) + t2.TrainingTitle
				from Training t2
				group by convert(char, t2.ProgramFK)
							, convert(char(10), t2.TrainingDate, 112)
							, t2.TrainingTitle
				having count(*) > 1)
	union
	select rtrim(TrainerFirstName) + ' ' + rtrim(TrainerLastName) as PC1ID
			, 'Trainer' as FormType
			, TrainerCreateDate as FormDate
			, TrainerCreateDate as CreateDate
			, TrainerCreator as Creator
	from Trainer t
	inner join SplitString(@ProgramFKs, ',') ss on ListItem = t.ProgramFK
	where convert(char, t.ProgramFK) + t.TrainerFirstName + t.TrainerLastName
			in (select convert(char, t2.ProgramFK) + t2.TrainerFirstName + t2.TrainerLastName
				from Trainer t2
				group by convert(char, t2.ProgramFK)
							, t2.TrainerFirstName
							, t2.TrainerLastName						
				having count(*) > 1)
	union
	select rtrim(SubTopicName) + '/' + rtrim(TrainingTitle) as PC1ID
		 , 'TrainingDetail' as FormType
		 , TrainingDate as FormDate
		 , TrainingDetailCreateDate as CreateDate 
		 , TrainingDetailCreator as Creator
	from TrainingDetail td
	inner join SubTopic st on st.ProgramFK = td.ProgramFK and st.TopicFK = td.TopicFK
	inner join Training t on t.TrainingPK = td.TrainingFK and t.ProgramFK = td.ProgramFK
	inner join SplitString(@ProgramFKs, ',') ss on ListItem = t.ProgramFK
	where convert(char, td.ProgramFK) + convert(char, td.TrainingFK) + convert(char, td.TopicFK) + convert(char, td.SubTopicFK)
			in (select convert(char, td2.ProgramFK) + convert(char, td2.TrainingFK) + convert(char, td2.TopicFK) + convert(char, td2.SubTopicFK)
				from TrainingDetail td2
				group by convert(char, td2.ProgramFK)
							, convert(char, td2.TrainingFK)
							, convert(char, td2.TopicFK)
							, convert(char, td2.SubTopicFK)
				having count(*) > 1)
	union
	select rtrim(MethodName) + ' (' + TrainingCode + ')'
		 , 'TrainingMethod' as FormType
		 , null as FormDate
		 , null as CreateDate
		 , null as Creator
	from TrainingMethod tm
	inner join SplitString(@ProgramFKs, ',') ss on ListItem = tm.ProgramFK
	where convert(char, tm.ProgramFK) + tm.TrainingCode + tm.MethodName
			in (select convert(char, tm2.ProgramFK) + tm2.TrainingCode + tm2.MethodName
				from TrainingMethod tm2
				group by convert(char, tm2.ProgramFK)
							, tm2.TrainingCode
							, tm2.MethodName
				having count(*) > 1)
	union
	select rtrim(FirstName) + ' ' + rtrim(LastName) + ' - ' + TrainingTitle as PC1ID
			, 'TrainingAttendee' as FormType
			, TrainingDate as FormDate
			, TrainingAttendeeCreateDate as CreateDate
			, TrainingAttendeeCreator as Creator
	from TrainingAttendee ta
	inner join Training t on t.TrainingPK = ta.TrainingFK
	inner join Worker w on w.WorkerPK = ta.WorkerFK
	inner join SplitString(@ProgramFKs, ',') ss on ListItem = t.ProgramFK
	where convert(char, ta.TrainingFK) + convert(char, ta.WorkerFK)
			in (select convert(char, ta2.TrainingFK) + convert(char, ta2.WorkerFK)
				from TrainingAttendee ta2
				group by convert(char, ta2.TrainingFK)
							, convert(char, ta2.WorkerFK)
				having count(*) > 1)
	union
	select rtrim(SubTopicName) + ' (' + SubTopicCode + ')' as PC1ID
		 , 'SubTopic' as FormType
		 , TrainingDate as FormDate
		 , SubTopicCreateDate as CreateDate
		 , SubTopicCreator as Creator
	from SubTopic st -- where SubTopicName like '%motivational%'
	inner join TrainingDetail td on td.TopicFK = st.TopicFK and td.ProgramFK = st.ProgramFK
	inner join Training t on t.TrainingPK = td.TrainingFK and t.ProgramFK = td.ProgramFK
	inner join SplitString(@ProgramFKs, ',') ss on ListItem = st.ProgramFK
	where convert(char, st.ProgramFK) + convert(char, st.TopicFK) + convert(char, st.SATFK) + st.SubTopicName
			in (select convert(char, st2.ProgramFK) + convert(char, st2.TopicFK) + convert(char, st2.SATFK) + st2.SubTopicName
				from SubTopic st2
				group by convert(char, st2.ProgramFK)
							, convert(char, st2.TopicFK)
							, convert(char, st2.SATFK)
							, st2.SubTopicName
				having count(*) > 1)
	order by FormType
				, PC1ID
				, FormDate
				, CreateDate

  if @ReportType = 'summary'
	begin
		declare @tblQAReport20Summary table 
				(SummaryID INT,
				SummaryText varchar(200),
				DuplicateRowCount varchar(100)
				)			

		insert into @tblQAReport20Summary
				(SummaryID
			   , SummaryText
			   , DuplicateRowCount
				)
			select 20 as SummaryID
					, FormType
					, count(FormType)
			from @tblQAReport20Temp tqrt
			group by FormType
			
			select * from @tblQAReport20Summary	
	end
else
	begin 
		select * from @tblQAReport20Temp tqrt
	end
end
GO
